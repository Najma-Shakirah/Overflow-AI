// lib/repositories/news_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'news_model.dart';

class NewsRepository {
  // ── API keys & endpoints ───────────────────────────────────────────────────
  static const String _newsDataKey = 'pub_a3ad1afbe56f4e47812a06163430f564';
  static const String _newsDataBase = 'https://newsdata.io/api/1/news';
  static const String _functionsBase =
      'https://us-central1-overflowai.cloudfunctions.net';

  // ─── PUBLIC ENTRY POINT ────────────────────────────────────────────────────
  Future<List<FloodNews>> fetchAllNews({
    required String state,
    required String district,
  }) async {
    final results = await Future.wait([
      _fetchNewsData(state: state, district: district),
      _fetchJpsRss(),
      _fetchSocialMediaViaFunction(state: state, district: district),
    ]);

    final all = results.expand((list) => list).toList();
    return _deduplicate(all);
  }

  // ─── SOURCE 1: NewsData.io ─────────────────────────────────────────────────
  // Returns REAL article links — each article.url is the actual news page.
  Future<List<FloodNews>> _fetchNewsData({
    required String state,
    required String district,
  }) async {
    try {
      // Two queries to maximise results within the 200 req/day free limit
      final queries = [
        'banjir $district OR flood $district',
        'banjir $state OR flood $state',
      ];

      final allArticles = <FloodNews>[];

      for (final q in queries) {
        final uri = Uri.parse(_newsDataBase).replace(queryParameters: {
          'apikey': _newsDataKey,
          'q': q,
          'country': 'my',
          'language': 'en,ms',
          'timeframe': '24', // last 24 hours only
        });

        final resp = await http.get(uri).timeout(const Duration(seconds: 10));

        if (resp.statusCode != 200) {
          debugPrint('NewsData non-200: ${resp.statusCode}');
          continue;
        }

        final data = jsonDecode(resp.body);
        final articles = data['results'] as List? ?? [];

        debugPrint('NewsData returned ${articles.length} articles for "$q"');

        for (final a in articles) {
          // Skip articles with no real link
          final link = (a['link'] ?? '') as String;
          if (link.isEmpty) continue;

          final sourceName = (a['source_id'] ?? '').toString().toLowerCase();

          allArticles.add(FloodNews(
            id: 'news_${a['article_id'] ?? DateTime.now().millisecondsSinceEpoch}',
            title: a['title'] ?? '',
            summary: a['description'] ?? a['title'] ?? '',
            source: _mapNewsSource(sourceName),
            // ← This is the REAL article URL returned by NewsData.io
            url: link,
            imageUrl: a['image_url'] as String?,
            timestamp: a['pubDate'] != null
                ? DateTime.tryParse(a['pubDate'] as String) ?? DateTime.now()
                : DateTime.now(),
            author: (a['creator'] is List && (a['creator'] as List).isNotEmpty)
                ? (a['creator'] as List).first as String?
                : null,
            location: district,
            verificationStatus: VerificationStatus.partiallyVerified,
            isBreaking: _isBreakingTitle(a['title'] ?? ''),
          ));
        }
      }

      if (allArticles.isEmpty) {
        debugPrint('NewsData returned no articles — using mock');
        return _mockNewsItems(district);
      }

      return allArticles;
    } catch (e) {
      debugPrint('fetchNewsData error: $e');
      return _mockNewsItems(district);
    }
  }

  // ─── SOURCE 2: JPS InfoBanjir RSS ─────────────────────────────────────────
  // Official government data — links go to publicinfobanjir.water.gov.my
  Future<List<FloodNews>> _fetchJpsRss() async {
    try {
      const rssUrl =
          'https://publicinfobanjir.water.gov.my/cerapan/amaran-semasa/?lang=en';
      final resp = await http
          .get(Uri.parse(rssUrl))
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode != 200) return [];

      final items = _parseRssItems(resp.body);
      debugPrint('JPS RSS returned ${items.length} items');

      return items.map((item) {
        final link = item['link'] ?? '';
        return FloodNews(
          id: 'jps_${link.hashCode}',
          title: item['title'] ?? 'JPS Flood Alert',
          summary: item['description'] ?? '',
          source: NewsSource.jps,
          // ← Real JPS alert page link
          url: link.isNotEmpty
              ? link
              : 'https://publicinfobanjir.water.gov.my/cerapan/amaran-semasa/?lang=en',
          timestamp: item['pubDate'] != null
              ? _parseRssDate(item['pubDate']!)
              : DateTime.now(),
          verificationStatus: VerificationStatus.verified,
          isBreaking: _isBreakingTitle(item['title'] ?? ''),
        );
      }).toList();
    } catch (e) {
      debugPrint('fetchJpsRss error: $e');
      return [];
    }
  }

  // ─── SOURCE 3: Social Media via Cloud Function ─────────────────────────────
  // The Cloud Function now returns social media SEARCH links (free, no API key).
  // Tapping a card opens TikTok/X/Facebook search for the flood query.
  Future<List<FloodNews>> _fetchSocialMediaViaFunction({
    required String state,
    required String district,
  }) async {
    try {
      final url = Uri.parse('$_functionsBase/getFloodSocialMedia');
      final resp = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'state': state, 'district': district}),
          )
          .timeout(const Duration(seconds: 15));

      if (resp.statusCode != 200) {
        debugPrint('Social function error: ${resp.statusCode}');
        return _mockSocialItems(district);
      }

      final data = jsonDecode(resp.body) as List;
      debugPrint('Social function returned ${data.length} items');
      return data.map((item) => FloodNews.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('fetchSocialMedia error: $e');
      return _mockSocialItems(district);
    }
  }

  // ─── DEDUPLICATION ────────────────────────────────────────────────────────
  List<FloodNews> _deduplicate(List<FloodNews> items) {
    final seen = <String>{};
    final result = <FloodNews>[];
    for (final item in items) {
      final key = item.title
          .toLowerCase()
          .replaceAll(' ', '')
          .substring(0, item.title.replaceAll(' ', '').length.clamp(0, 40));
      if (!seen.contains(key)) {
        seen.add(key);
        result.add(item);
      }
    }
    result.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return result;
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────
  bool _isBreakingTitle(String title) {
    final t = title.toLowerCase();
    return t.contains('amaran') ||
        t.contains('warning') ||
        t.contains('darurat') ||
        t.contains('emergency') ||
        t.contains('banjir kilat');
  }

  NewsSource _mapNewsSource(String sourceName) {
    if (sourceName.contains('star')) return NewsSource.theStar;
    if (sourceName.contains('berita') || sourceName.contains('bharian')) {
      return NewsSource.beritaHarian;
    }
    if (sourceName.contains('awani')) return NewsSource.astroAwani;
    if (sourceName.contains('fmt') || sourceName.contains('freemalaysia')) {
      return NewsSource.freeMalaysia;
    }
    return NewsSource.other;
  }

  // ─── RSS PARSER ───────────────────────────────────────────────────────────
  List<Map<String, String>> _parseRssItems(String xml) {
    final items = <Map<String, String>>[];
    final itemPattern = RegExp(r'<item>(.*?)<\/item>', dotAll: true);
    final titlePattern =
        RegExp(r'<title><!\[CDATA\[(.*?)\]\]><\/title>|<title>(.*?)<\/title>');
    final descPattern = RegExp(
        r'<description><!\[CDATA\[(.*?)\]\]><\/description>|<description>(.*?)<\/description>');
    final linkPattern = RegExp(r'<link>(.*?)<\/link>');
    final datePattern = RegExp(r'<pubDate>(.*?)<\/pubDate>');

    for (final match in itemPattern.allMatches(xml)) {
      final block = match.group(1) ?? '';
      final item = <String, String>{};
      final titleM = titlePattern.firstMatch(block);
      item['title'] = titleM?.group(1) ?? titleM?.group(2) ?? '';
      final descM = descPattern.firstMatch(block);
      item['description'] = descM?.group(1) ?? descM?.group(2) ?? '';
      final linkM = linkPattern.firstMatch(block);
      item['link'] = linkM?.group(1) ?? '';
      final dateM = datePattern.firstMatch(block);
      item['pubDate'] = dateM?.group(1) ?? '';
      items.add(item);
    }
    return items;
  }

  DateTime _parseRssDate(String raw) {
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return DateTime.now();
    }
  }

  // ─── MOCK DATA ─────────────────────────────────────────────────────────────
  // News mocks use real search URLs so tapping still does something useful.
  // Social mocks use real search URLs for the flood query.
  List<FloodNews> _mockNewsItems(String district) => [
        FloodNews(
          id: 'mock_news_1',
          title: 'Banjir kilat melanda beberapa kawasan di $district',
          summary:
              'Flash floods hit several areas in $district following heavy rainfall. '
              'Residents are advised to stay alert and monitor water levels.',
          source: NewsSource.beritaHarian,
          // Real search page — user can find actual articles
          url:
              'https://www.bharian.com.my/search?q=banjir+${Uri.encodeComponent(district)}',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          verificationStatus: VerificationStatus.partiallyVerified,
          isBreaking: true,
        ),
        FloodNews(
          id: 'mock_news_2',
          title: 'Water level rising — JPS issues flood warning',
          summary:
              'The Department of Irrigation and Drainage (JPS) has issued a flood '
              'warning for areas along the Klang River.',
          source: NewsSource.theStar,
          url:
              'https://www.thestar.com.my/search?q=flood+${Uri.encodeComponent(district)}',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          verificationStatus: VerificationStatus.partiallyVerified,
        ),
        FloodNews(
          id: 'mock_news_3',
          title: 'Flood alert: residents urged to prepare',
          summary:
              'City Council has activated its emergency response team as water '
              'levels continue to rise.',
          source: NewsSource.astroAwani,
          url:
              'https://www.astroawani.com/search?q=banjir+${Uri.encodeComponent(district)}',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          verificationStatus: VerificationStatus.unverified,
        ),
      ];

  // Social media mocks use real search/hashtag URLs — tapping opens live results
  List<FloodNews> _mockSocialItems(String district) {
    final q = Uri.encodeComponent('banjir $district');
    final tag = district.replaceAll(' ', '').toLowerCase();

    return [
      FloodNews(
        id: 'mock_tiktok_1',
        title: '#banjir$tag — TikTok',
        summary:
            'Tap to see live TikTok videos about flooding in $district. '
            'Real footage from residents showing current conditions.',
        source: NewsSource.tiktok,
        // Real TikTok search — shows actual current videos
        url: 'https://www.tiktok.com/search?q=$q',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        verificationStatus: VerificationStatus.unverified,
      ),
      FloodNews(
        id: 'mock_x_1',
        title: 'banjir $district — X Live',
        summary:
            'Tap to see the most recent posts on X about flooding in $district. '
            'Sorted by latest for real-time reports.',
        source: NewsSource.x,
        // Real X live search
        url: 'https://x.com/search?q=$q&f=live',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        verificationStatus: VerificationStatus.unverified,
      ),
      FloodNews(
        id: 'mock_fb_infobanjir',
        title: 'myinfobanjir — Official JPS Facebook',
        summary:
            'Tap to visit the official JPS InfoBanjir Facebook page for '
            'verified flood warnings and water level alerts.',
        source: NewsSource.facebook,
        // Real official JPS Facebook page
        url: 'https://www.facebook.com/myinfobanjir',
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        verificationStatus: VerificationStatus.verified,
      ),
      FloodNews(
        id: 'mock_fb_search',
        title: 'banjir $district — Facebook Posts',
        summary:
            'Tap to search Facebook for recent flood posts in $district. '
            'Community reports, rescue updates, and relief centre info.',
        source: NewsSource.facebook,
        // Real Facebook search
        url: 'https://www.facebook.com/search/posts/?q=$q',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        verificationStatus: VerificationStatus.unverified,
      ),
    ];
  }
}