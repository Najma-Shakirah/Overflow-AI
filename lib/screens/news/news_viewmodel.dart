// lib/viewmodels/news_viewmodel.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'news_model.dart';
import '../authentication/user_model.dart';
import 'news_repository.dart';
import '../../services/location_service.dart';

class NewsViewModel extends ChangeNotifier {
  final NewsRepository _repo;
  late final GenerativeModel _aiModel;

  NewsViewModel({NewsRepository? repository})
      : _repo = repository ?? NewsRepository() {
    _aiModel = FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash');
  }

  // ── State ──────────────────────────────────────────────────────────────────
  List<FloodNews> _allItems = [];
  NewsSummary? _summary;
  NewsFilter _filter = const NewsFilter();
  bool _isLoadingNews = false;
  bool _isLoadingSummary = false;
  String? _error;
  String _currentLocation = '';
  DateTime? _lastFetched;

  // ── Getters ────────────────────────────────────────────────────────────────
  bool get isLoadingNews => _isLoadingNews;
  bool get isLoadingSummary => _isLoadingSummary;
  String? get error => _error;
  NewsSummary? get summary => _summary;
  NewsFilter get filter => _filter;
  String get currentLocation => _currentLocation;
  DateTime? get lastFetched => _lastFetched;

  // Filtered + sorted list exposed to UI
  List<FloodNews> get newsItems {
    var items = List<FloodNews>.from(_allItems);

    // Source filter
    if (_filter.activeSources.isNotEmpty) {
      items = items
          .where((n) => _filter.activeSources.contains(n.source))
          .toList();
    }

    // Verified only
    if (_filter.verifiedOnly) {
      items = items
          .where((n) =>
              n.verificationStatus != VerificationStatus.unverified)
          .toList();
    }

    // Sort
    if (_filter.sortBy == 'engagement') {
      items.sort((a, b) =>
          (b.engagementCount ?? 0).compareTo(a.engagementCount ?? 0));
    } else {
      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    return items;
  }

  // Counts per source for the filter chips
  Map<NewsSource, int> get countPerSource {
    final counts = <NewsSource, int>{};
    for (final item in _allItems) {
      counts[item.source] = (counts[item.source] ?? 0) + 1;
    }
    return counts;
  }

  int get breakingCount => _allItems.where((n) => n.isBreaking).length;
  int get verifiedCount =>
      _allItems.where((n) => n.verificationStatus == VerificationStatus.verified).length;
  int get socialCount => _allItems.where((n) => n.source.isSocialMedia).length;

  // ── MAIN LOAD ──────────────────────────────────────────────────────────────
  Future<void> loadForUser(UserModel user) async {
    // 1st priority: live GPS location (most accurate)
    // 2nd priority: user profile state/district
    // 3rd priority: hardcoded fallback
    try {
      final location = await LocationService.getCurrentLocation();
      await loadForLocation(
        state: location.state,
        district: location.district,
      );
    } catch (e) {
      debugPrint('GPS location failed, using profile: $e');
      final state = user.state ?? 'Selangor';
      final district = user.district ?? 'Shah Alam';
      await loadForLocation(state: state, district: district);
    }
  }

  Future<void> loadForLocation({
    required String state,
    required String district,
  }) async {
    _currentLocation = '$district, $state';
    _isLoadingNews = true;
    _error = null;
    notifyListeners();

    try {
      _allItems = await _repo.fetchAllNews(
          state: state, district: district);
      _lastFetched = DateTime.now();
      _isLoadingNews = false;
      notifyListeners();

      // Generate AI summary in background after news loads
      _generateSummary(state: state, district: district);
    } catch (e) {
      _error = 'Failed to load news. Please try again.';
      _isLoadingNews = false;
      debugPrint('loadForLocation error: $e');
      notifyListeners();
    }
  }

  Future<void> refresh() => loadForLocation(
      state: _currentLocation.split(', ').last,
      district: _currentLocation.split(', ').first);

  // ── AI SUMMARY ─────────────────────────────────────────────────────────────
  // Sends up to 8 posts to Gemini. It:
  // 1. Cleans up messy Malay slang ("air naik dh" → "water level rising")
  // 2. Finds consensus across sources
  // 3. Returns structured JSON with summary + confidence + risk level
  Future<void> _generateSummary({
    required String state,
    required String district,
  }) async {
    if (_allItems.isEmpty) return;

    _isLoadingSummary = true;
    notifyListeners();

    try {
      // Take top 8 most recent items for summarization
      final sample = _allItems.take(8).toList();

      final postsText = sample.asMap().entries.map((e) {
        final n = e.value;
        final text = n.originalText ?? n.summary;
        return '${e.key + 1}. [${n.source.label}] ${n.title}\n   "$text"';
      }).join('\n\n');

      final prompt = Content.text('''
You are a flood monitoring AI assistant for Malaysia. 
I will give you social media posts and news articles about flooding in $district, $state.
Many posts are in informal Malay (e.g. "air naik dh kt tmn sri muda" = "water level rising in Taman Sri Muda").

Here are the posts:

$postsText

Analyze these posts and respond ONLY in this exact JSON format (no markdown, no extra text):
{
  "summary": "2-3 professional sentences summarizing the current flood situation in $district. Include specific areas if mentioned. Translate any Malay content to English.",
  "confidenceScore": number from 0 to 100 based on how many sources are independently reporting the same event,
  "riskLevel": "LOW" or "MODERATE" or "HIGH" or "CRITICAL",
  "keyAreas": ["specific area 1", "specific area 2"],
  "isFakeRisk": true or false — true if posts look like old/recycled footage,
  "headline": "One-line breaking news style headline"
}
''');

      final response = await _aiModel.generateContent([prompt]);
      final raw = response.text ?? '';
      final clean = raw
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final json = jsonDecode(clean);
      _summary = NewsSummary.fromJson(json, '$district, $state');
    } catch (e) {
      debugPrint('AI summary error: $e');
      _summary = NewsSummary.error('$district, $state');
    }

    _isLoadingSummary = false;
    notifyListeners();
  }

  // ── FILTERS ────────────────────────────────────────────────────────────────
  void toggleSourceFilter(NewsSource source) {
    final current = Set<NewsSource>.from(_filter.activeSources);
    if (current.contains(source)) {
      current.remove(source);
    } else {
      current.add(source);
    }
    _filter = _filter.copyWith(activeSources: current);
    notifyListeners();
  }

  void setVerifiedOnly(bool value) {
    _filter = _filter.copyWith(verifiedOnly: value);
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _filter = _filter.copyWith(sortBy: sortBy);
    notifyListeners();
  }

  void clearFilters() {
    _filter = const NewsFilter();
    notifyListeners();
  }

  // ── VERIFICATION LOGIC ─────────────────────────────────────────────────────
  // Cross-checks a social media post against official JPS data
  // If JPS has an alert for the same location, upgrades the verification
  VerificationStatus crossVerify(FloodNews item) {
    if (item.source.isOfficial) return VerificationStatus.verified;

    final jpsItems = _allItems
        .where((n) => n.source == NewsSource.jps)
        .toList();

    if (jpsItems.isEmpty) return item.verificationStatus;

    final location = (item.location ?? item.title).toLowerCase();
    final jpsMatch = jpsItems.any((jps) =>
        (jps.title + jps.summary).toLowerCase().contains(
            location.split(' ').first));

    return jpsMatch
        ? VerificationStatus.verified
        : item.verificationStatus;
  }
}