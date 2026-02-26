// lib/screens/news/news_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'news_model.dart';
import '../authentication/user_model.dart';
import 'news_viewmodel.dart';
import '../authentication/auth_viewmodel.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewsViewModel(),
      child: const _NewsView(),
    );
  }
}

class _NewsView extends StatefulWidget {
  const _NewsView();

  @override
  State<_NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<_NewsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().user;
      if (user != null) {
        context.read<NewsViewModel>().loadForUser(user);
      } else {
        // Fallback if no user profile yet
        context.read<NewsViewModel>().loadForLocation(
          state: 'Selangor',
          district: 'Shah Alam',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NewsViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        color: const Color(0xFF3A83B7),
        onRefresh: vm.refresh,
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────────────
            _NewsAppBar(vm: vm),

            // ── Breaking news ticker ─────────────────────────────────
            if (!vm.isLoadingNews && vm.breakingCount > 0)
              SliverToBoxAdapter(child: _BreakingTicker(vm: vm)),

            // ── AI Summary card ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _AiSummaryCard(vm: vm),
              ),
            ),

            // ── Stats row ────────────────────────────────────────────
            if (!vm.isLoadingNews)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _StatsRow(vm: vm),
                ),
              ),

            // ── Source filter chips ──────────────────────────────────
            SliverToBoxAdapter(
              child: _SourceFilterRow(vm: vm),
            ),

            // ── Sort & filter bar ────────────────────────────────────
            SliverToBoxAdapter(
              child: _SortBar(vm: vm),
            ),

            // ── News feed ────────────────────────────────────────────
            if (vm.isLoadingNews)
              const SliverFillRemaining(
                child: Center(child: _LoadingShimmer()),
              )
            else if (vm.error != null)
              SliverFillRemaining(child: _ErrorState(vm: vm))
            else if (vm.newsItems.isEmpty)
              const SliverFillRemaining(child: _EmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _NewsCard(
                      item: vm.newsItems[i],
                      verificationStatus:
                          vm.crossVerify(vm.newsItems[i]),
                    ),
                    childCount: vm.newsItems.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────
class _NewsAppBar extends StatelessWidget {
  final NewsViewModel vm;
  const _NewsAppBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      backgroundColor: const Color(0xFF3A83B7),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: vm.isLoadingNews ? null : vm.refresh,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF3A83B7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.feed_outlined,
                          color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      const Text('Flood News',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                      const Spacer(),
                      if (vm.lastFetched != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(children: [
                            Container(
                              width: 6, height: 6,
                              decoration: const BoxDecoration(
                                  color: Colors.greenAccent,
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 5),
                            const Text('Live',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ]),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        vm.currentLocation.isEmpty
                            ? 'Detecting location...'
                            : vm.currentLocation,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Breaking Ticker ──────────────────────────────────────────────────────────
class _BreakingTicker extends StatelessWidget {
  final NewsViewModel vm;
  const _BreakingTicker({required this.vm});

  @override
  Widget build(BuildContext context) {
    final breaking = vm.newsItems.where((n) => n.isBreaking).toList();
    if (breaking.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.red[700],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('BREAKING',
                style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              breaking.first.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AI Summary Card ──────────────────────────────────────────────────────────
class _AiSummaryCard extends StatelessWidget {
  final NewsViewModel vm;
  const _AiSummaryCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoadingNews) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF3A83B7)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF3A83B7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A83B7).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          color: Colors.white, size: 13),
                      SizedBox(width: 4),
                      Text('AI Summary',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Gemini 3.0 Flash',
                    style: TextStyle(
                        color: Colors.white60, fontSize: 11)),
                const Spacer(),
                if (vm.summary != null && !vm.summary!.hasError)
                  _RiskBadge(riskLevel: vm.summary!.riskLevel),
              ],
            ),
            const SizedBox(height: 12),

            // Summary text or loading
            if (vm.isLoadingSummary)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerLine(double.infinity),
                  const SizedBox(height: 8),
                  _shimmerLine(200),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Gemini is analysing posts...',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              )
            else if (vm.summary != null) ...[
              Text(
                vm.summary!.summary,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.5),
              ),
              if (vm.summary!.keyAreas.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: vm.summary!.keyAreas.map((area) =>
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.white70, size: 11),
                          const SizedBox(width: 3),
                          Text(area,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11)),
                        ],
                      ),
                    )
                  ).toList(),
                ),
              ],
              const SizedBox(height: 10),
              // Confidence score
              Row(
                children: [
                  const Icon(Icons.verified_outlined,
                      color: Colors.white70, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Confidence: ${vm.summary!.confidenceScore}%',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: vm.summary!.confidenceScore / 100,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          vm.summary!.confidenceScore > 70
                              ? Colors.greenAccent
                              : Colors.orangeAccent,
                        ),
                        minHeight: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ] else
              const Text(
                'Loading news from multiple sources...',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerLine(double width) {
    return Container(
      height: 12,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  final String riskLevel;
  const _RiskBadge({required this.riskLevel});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (riskLevel) {
      case 'CRITICAL': color = Colors.red; break;
      case 'HIGH': color = Colors.orange; break;
      case 'MODERATE': color = Colors.yellow; break;
      default: color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        riskLevel,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final NewsViewModel vm;
  const _StatsRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          icon: Icons.article_outlined,
          label: '${vm.newsItems.length} Reports',
          color: Colors.blue,
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: Icons.verified,
          label: '${vm.verifiedCount} Verified',
          color: Colors.green,
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: Icons.people_outline,
          label: '${vm.socialCount} Social',
          color: Colors.purple,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Source Filter Row ────────────────────────────────────────────────────────
class _SourceFilterRow extends StatelessWidget {
  final NewsViewModel vm;
  const _SourceFilterRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    final sources = [
      NewsSource.jps,
      NewsSource.x,
      NewsSource.tiktok,
      NewsSource.facebook,
      NewsSource.instagram,
      NewsSource.theStar,
      NewsSource.beritaHarian,
      NewsSource.astroAwani,
    ];

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        children: sources.map((src) {
          final count = vm.countPerSource[src] ?? 0;
          final isActive = vm.filter.activeSources.contains(src);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                '${src.label}${count > 0 ? " ($count)" : ""}',
                style: TextStyle(
                  fontSize: 11,
                  color: isActive ? Colors.white : const Color(0xFF2D3748),
                  fontWeight:
                      isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              avatar: Icon(
                _sourceIcon(src),
                size: 14,
                color: isActive ? Colors.white : _sourceColor(src),
              ),
              selected: isActive,
              onSelected: (_) => vm.toggleSourceFilter(src),
              selectedColor: _sourceColor(src),
              backgroundColor: Colors.white,
              side: BorderSide(
                  color: isActive
                      ? _sourceColor(src)
                      : Colors.grey[300]!),
              showCheckmark: false,
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _sourceIcon(NewsSource src) {
    switch (src) {
      case NewsSource.x: return Icons.close; // X logo approximation
      case NewsSource.facebook: return Icons.facebook;
      case NewsSource.tiktok: return Icons.music_video;
      case NewsSource.instagram: return Icons.photo_camera;
      case NewsSource.jps: return Icons.water;
      default: return Icons.newspaper;
    }
  }

  Color _sourceColor(NewsSource src) {
    switch (src) {
      case NewsSource.x: return Colors.black87;
      case NewsSource.facebook: return const Color(0xFF1877F2);
      case NewsSource.tiktok: return const Color(0xFF010101);
      case NewsSource.instagram: return const Color(0xFFE1306C);
      case NewsSource.jps: return const Color(0xFF1565C0);
      case NewsSource.theStar: return const Color(0xFFD32F2F);
      case NewsSource.beritaHarian: return const Color(0xFF1B5E20);
      case NewsSource.astroAwani: return const Color(0xFFE65100);
      default: return Colors.grey;
    }
  }
}

// ─── Sort Bar ─────────────────────────────────────────────────────────────────
class _SortBar extends StatelessWidget {
  final NewsViewModel vm;
  const _SortBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          Text('${vm.newsItems.length} results',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          // Verified toggle
          GestureDetector(
            onTap: () => vm.setVerifiedOnly(!vm.filter.verifiedOnly),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: vm.filter.verifiedOnly
                    ? Colors.green
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified,
                      size: 13,
                      color: vm.filter.verifiedOnly
                          ? Colors.white
                          : Colors.grey),
                  const SizedBox(width: 4),
                  Text('Verified',
                      style: TextStyle(
                          fontSize: 11,
                          color: vm.filter.verifiedOnly
                              ? Colors.white
                              : Colors.grey[600])),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Sort toggle
          GestureDetector(
            onTap: () => vm.setSortBy(
                vm.filter.sortBy == 'latest' ? 'engagement' : 'latest'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    vm.filter.sortBy == 'latest'
                        ? Icons.access_time
                        : Icons.trending_up,
                    size: 13,
                    color: const Color(0xFF3A83B7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    vm.filter.sortBy == 'latest' ? 'Latest' : 'Trending',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF3A83B7)),
                  ),
                ],
              ),
            ),
          ),
          if (vm.filter.hasActiveFilters) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: vm.clearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Clear',
                    style: TextStyle(
                        fontSize: 11, color: Colors.red[700])),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── News Card ────────────────────────────────────────────────────────────────
class _NewsCard extends StatelessWidget {
  final FloodNews item;
  final VerificationStatus verificationStatus;

  const _NewsCard(
      {required this.item, required this.verificationStatus});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openUrl(item.url),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isBreaking
                ? Colors.red.withOpacity(0.4)
                : _sourceColor(item.source).withOpacity(0.15),
            width: item.isBreaking ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card header ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: [
                  // Source icon
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: _sourceColor(item.source).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _sourceIcon(item.source),
                      size: 16,
                      color: _sourceColor(item.source),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.source.label,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _sourceColor(item.source))),
                      if (item.author != null)
                        Text(item.author!,
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[500])),
                    ],
                  ),
                  const Spacer(),
                  // Verification badge
                  _VerificationBadge(status: verificationStatus),
                  const SizedBox(width: 8),
                  Text(item.timeAgo,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[400])),
                ],
              ),
            ),

            // Breaking banner
            if (item.isBreaking)
              Container(
                width: double.infinity,
                color: Colors.red[700],
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 3),
                child: const Text('BREAKING',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
              ),

            // ── Content ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF2D3748),
                        height: 1.3),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.summary,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.5),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Original text (social media posts)
                  if (item.originalText != null &&
                      item.originalText != item.summary) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.format_quote,
                              color: Colors.grey[400], size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.originalText!,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Engagement + location row
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (item.engagementCount != null) ...[
                        Icon(Icons.trending_up,
                            size: 13, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          _formatCount(item.engagementCount!),
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[400]),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (item.location != null) ...[
                        Icon(Icons.location_on,
                            size: 13, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          item.location!,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[400]),
                        ),
                      ],
                      const Spacer(),
                      Icon(Icons.open_in_new,
                          size: 13, color: Colors.grey[400]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }
}

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  IconData _sourceIcon(NewsSource src) {
    switch (src) {
      case NewsSource.x: return Icons.close;
      case NewsSource.facebook: return Icons.facebook;
      case NewsSource.tiktok: return Icons.music_video;
      case NewsSource.instagram: return Icons.photo_camera;
      case NewsSource.jps: return Icons.water;
      default: return Icons.newspaper;
    }
  }

  Color _sourceColor(NewsSource src) {
    switch (src) {
      case NewsSource.x: return Colors.black87;
      case NewsSource.facebook: return const Color(0xFF1877F2);
      case NewsSource.tiktok: return const Color(0xFF010101);
      case NewsSource.instagram: return const Color(0xFFE1306C);
      case NewsSource.jps: return const Color(0xFF1565C0);
      case NewsSource.theStar: return const Color(0xFFD32F2F);
      case NewsSource.beritaHarian: return const Color(0xFF1B5E20);
      case NewsSource.astroAwani: return const Color(0xFFE65100);
      default: return Colors.grey;
    }
  }
}

// ─── Verification Badge ───────────────────────────────────────────────────────
class _VerificationBadge extends StatelessWidget {
  final VerificationStatus status;
  const _VerificationBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case VerificationStatus.verified:
        return Row(
          children: [
            const Icon(Icons.verified, color: Colors.green, size: 14),
            const SizedBox(width: 3),
            Text('Verified',
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold)),
          ],
        );
      case VerificationStatus.partiallyVerified:
        return Row(
          children: [
            Icon(Icons.check_circle_outline,
                color: Colors.orange[600], size: 14),
            const SizedBox(width: 3),
            Text('Partial',
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange[700])),
          ],
        );
      case VerificationStatus.unverified:
        return Row(
          children: [
            Icon(Icons.help_outline, color: Colors.grey[400], size: 14),
            const SizedBox(width: 3),
            Text('Unverified',
                style: TextStyle(
                    fontSize: 10, color: Colors.grey[500])),
          ],
        );
    }
  }
}

// ─── Loading Shimmer ──────────────────────────────────────────────────────────
class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(
            2,
            (_) => Container(
              height: 130,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final NewsViewModel vm;
  const _ErrorState({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 52, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(vm.error ?? 'Something went wrong',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: vm.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A83B7),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.newspaper_outlined, size: 52, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No flood reports found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('No news for your area right now — that\'s good news!',
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        ],
      ),
    );
  }
}