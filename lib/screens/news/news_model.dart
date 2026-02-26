// lib/models/news_model.dart

// ─── News source enum ─────────────────────────────────────────────────────────
enum NewsSource {
  x,          // X (Twitter)
  facebook,
  tiktok,
  instagram,
  theStar,
  beritaHarian,
  astroAwani,
  freeMalaysia,
  jps,        // Official JPS InfoBanjir
  other,
}

extension NewsSourceExt on NewsSource {
  String get label {
    switch (this) {
      case NewsSource.x: return 'X';
      case NewsSource.facebook: return 'Facebook';
      case NewsSource.tiktok: return 'TikTok';
      case NewsSource.instagram: return 'Instagram';
      case NewsSource.theStar: return 'The Star';
      case NewsSource.beritaHarian: return 'Berita Harian';
      case NewsSource.astroAwani: return 'Astro Awani';
      case NewsSource.freeMalaysia: return 'Free Malaysia Today';
      case NewsSource.jps: return 'JPS InfoBanjir';
      case NewsSource.other: return 'Other';
    }
  }

  String get logoAsset {
    // Return icon identifiers — map to Icons in UI layer
    switch (this) {
      case NewsSource.x: return 'x';
      case NewsSource.facebook: return 'facebook';
      case NewsSource.tiktok: return 'tiktok';
      case NewsSource.instagram: return 'instagram';
      case NewsSource.jps: return 'jps';
      default: return 'news';
    }
  }

  bool get isSocialMedia => [
    NewsSource.x,
    NewsSource.facebook,
    NewsSource.tiktok,
    NewsSource.instagram,
  ].contains(this);

  bool get isOfficial => this == NewsSource.jps;
}

// ─── Verification status ──────────────────────────────────────────────────────
enum VerificationStatus {
  unverified,
  partiallyVerified, // matches 1-2 other sources
  verified,          // matches official JPS data or 3+ sources
}

// ─── Individual news/post item ────────────────────────────────────────────────
class FloodNews {
  final String id;
  final String title;
  final String summary;
  final String? originalText; // raw social media post text
  final NewsSource source;
  final String url;
  final String? imageUrl;
  final String? videoUrl;
  final DateTime timestamp;
  final String? author;
  final int? engagementCount; // likes + shares + comments
  final String? location;     // specific area mentioned
  final VerificationStatus verificationStatus;
  final bool isBreaking;

  FloodNews({
    required this.id,
    required this.title,
    required this.summary,
    this.originalText,
    required this.source,
    required this.url,
    this.imageUrl,
    this.videoUrl,
    required this.timestamp,
    this.author,
    this.engagementCount,
    this.location,
    this.verificationStatus = VerificationStatus.unverified,
    this.isBreaking = false,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  factory FloodNews.fromJson(Map<String, dynamic> json) {
    return FloodNews(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      originalText: json['originalText'],
      source: NewsSource.values.firstWhere(
        (s) => s.name == json['source'],
        orElse: () => NewsSource.other,
      ),
      url: json['url'] ?? '',
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      author: json['author'],
      engagementCount: json['engagementCount'],
      location: json['location'],
      verificationStatus: VerificationStatus.values.firstWhere(
        (v) => v.name == json['verificationStatus'],
        orElse: () => VerificationStatus.unverified,
      ),
      isBreaking: json['isBreaking'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'summary': summary,
    'originalText': originalText,
    'source': source.name,
    'url': url,
    'imageUrl': imageUrl,
    'videoUrl': videoUrl,
    'timestamp': timestamp.toIso8601String(),
    'author': author,
    'engagementCount': engagementCount,
    'location': location,
    'verificationStatus': verificationStatus.name,
    'isBreaking': isBreaking,
  };
}

// ─── AI-generated summary for a location ─────────────────────────────────────
class NewsSummary {
  final String locationLabel;   // e.g. "Shah Alam, Selangor"
  final String summary;         // 2-3 sentence AI summary
  final int confidenceScore;    // 0-100 — how many sources agree
  final String riskLevel;       // LOW / MODERATE / HIGH / CRITICAL
  final List<String> keyAreas;  // specific areas mentioned most
  final DateTime generatedAt;
  final bool hasError;

  NewsSummary({
    required this.locationLabel,
    required this.summary,
    required this.confidenceScore,
    required this.riskLevel,
    required this.keyAreas,
    required this.generatedAt,
    this.hasError = false,
  });

  factory NewsSummary.error(String location) => NewsSummary(
    locationLabel: location,
    summary: 'Could not generate summary. Check individual reports below.',
    confidenceScore: 0,
    riskLevel: 'UNKNOWN',
    keyAreas: [],
    generatedAt: DateTime.now(),
    hasError: true,
  );

  factory NewsSummary.fromJson(Map<String, dynamic> json, String location) {
    return NewsSummary(
      locationLabel: location,
      summary: json['summary'] ?? '',
      confidenceScore: (json['confidenceScore'] as num?)?.toInt() ?? 0,
      riskLevel: json['riskLevel'] ?? 'UNKNOWN',
      keyAreas: List<String>.from(json['keyAreas'] ?? []),
      generatedAt: DateTime.now(),
    );
  }
}

// ─── Active filter state ──────────────────────────────────────────────────────
class NewsFilter {
  final Set<NewsSource> activeSources;
  final bool verifiedOnly;
  final String sortBy; // 'latest', 'engagement'

  const NewsFilter({
    this.activeSources = const {},  // empty = all sources
    this.verifiedOnly = false,
    this.sortBy = 'latest',
  });

  NewsFilter copyWith({
    Set<NewsSource>? activeSources,
    bool? verifiedOnly,
    String? sortBy,
  }) => NewsFilter(
    activeSources: activeSources ?? this.activeSources,
    verifiedOnly: verifiedOnly ?? this.verifiedOnly,
    sortBy: sortBy ?? this.sortBy,
  );

  bool get hasActiveFilters =>
      activeSources.isNotEmpty || verifiedOnly || sortBy != 'latest';
}