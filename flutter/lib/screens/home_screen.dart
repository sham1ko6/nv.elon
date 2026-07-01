import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api.dart' as api;
import '../app_state.dart';
import '../l10n/strings.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/listing_card.dart';
import '../widgets/ravoq_shield.dart';
import 'listing_detail_screen.dart';
import 'notifications_screen.dart';
import 'post_ad_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Listing> _listings = [];
  bool _loading = true;
  String? _error;
  String _activeCat = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await api.getListings(
        category: _activeCat == 'all' ? null : _activeCat,
      );
      if (mounted) setState(() { _listings = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<Listing> get _filtered {
    if (_activeCat == 'all') return _listings;
    return _listings.where((l) => l.category.toLowerCase() == _activeCat).toList();
  }

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    final state = AppStateScope.of(context);
    final initials = state.user?['name']?.toString().isNotEmpty == true
        ? state.user!['name'].toString().substring(0, 1).toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: rc.bg,
      body: RefreshIndicator(
        color: cAccent,
        onRefresh: _load,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App bar ───────────────────────────────────────────
            SliverAppBar(
              floating: true,
              backgroundColor: rc.card,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Logo
                    RavoqShield(size: 22, color: cAccent, letterColor: Colors.white),
                    const SizedBox(width: 7),
                    Text('Ravoq.',
                        style: GoogleFonts.spectral(
                            fontSize: 20, fontWeight: FontWeight.w700, color: rc.accent)),
                    const SizedBox(width: 10),
                    // Location pill
                    Expanded(
                      child: Container(
                        height: 34,
                        decoration: BoxDecoration(
                          color: rc.bg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: rc.line),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on_rounded, size: 13, color: cAccent),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text('Toshkent sh.',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.hankenGrotesk(
                                      fontSize: 12, fontWeight: FontWeight.w500, color: rc.ink)),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: rc.muted),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Bell
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      ),
                      child: Stack(
                        children: [
                          Icon(Icons.notifications_outlined, color: rc.ink, size: 24),
                          Positioned(
                            top: 0, right: 0,
                            child: Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(color: cAccent, shape: BoxShape.circle),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Avatar
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 36, height: 36,
                        decoration: const BoxDecoration(color: cAccent, shape: BoxShape.circle),
                        child: Center(
                          child: Text(initials,
                              style: GoogleFonts.spectral(
                                  fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: rc.line),
              ),
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  // ── Search bar ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      ),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: rc.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: rc.line),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            Icon(Icons.search_rounded, color: rc.muted, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(S.get('searchHint'),
                                  style: GoogleFonts.hankenGrotesk(
                                      fontSize: 13, color: rc.muted)),
                            ),
                            Container(
                              width: 36, height: 36,
                              margin: const EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                color: cAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                                ),
                                child: const Icon(Icons.tune_rounded, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Story circles ───────────────────────────────
                  SizedBox(
                    height: 86,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        // Post ad circle
                        _StoryCircle(
                          child: Icon(Icons.add_rounded, color: rc.muted, size: 22),
                          label: S.get('postAd'),
                          isDashed: true,
                          rc: rc,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const PostAdScreen()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Category circles
                        ...kCategories.map((cat) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _StoryCircle(
                            imageUrl: cat.imageUrl,
                            label: cat.name,
                            isDashed: false,
                            rc: rc,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) =>
                                SearchScreen(initialCategory: cat.id)),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Category chips ──────────────────────────────
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _Chip(label: S.get('allCategories'), active: _activeCat == 'all',
                            onTap: () { setState(() => _activeCat = 'all'); _load(); }, rc: rc),
                        ...kCategories.map((c) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _Chip(
                            label: '${c.emoji} ${c.name}',
                            active: _activeCat == c.id,
                            onTap: () { setState(() => _activeCat = c.id); _load(); },
                            rc: rc,
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Hero banner ─────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  S.get('heroBanner'),
                                  style: GoogleFonts.spectral(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  S.get('heroSub'),
                                  style: GoogleFonts.hankenGrotesk(
                                    fontSize: 11.5,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const PostAdScreen()),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(S.get('postAd'),
                                        style: GoogleFonts.hankenGrotesk(
                                            fontSize: 13, fontWeight: FontWeight.w700, color: cAccent)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const RavoqShield(size: 60, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Listings header ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(S.get('recommended'),
                            style: GoogleFonts.spectral(
                                fontSize: 18, fontWeight: FontWeight.w700, color: rc.ink)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SearchScreen()),
                          ),
                          child: Text(S.get('seeAll'),
                              style: GoogleFonts.hankenGrotesk(
                                  fontSize: 13, fontWeight: FontWeight.w600, color: rc.accent)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),

            // ── Listings grid ─────────────────────────────────────
            if (_loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator(color: cAccent)),
                ),
              )
            else if (_error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.wifi_off_rounded, color: cMuted, size: 40),
                      const SizedBox(height: 10),
                      Text(_error!, style: GoogleFonts.hankenGrotesk(color: cMuted)),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _load,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                              color: cAccent, borderRadius: BorderRadius.circular(10)),
                          child: Text('Qayta urinish',
                              style: GoogleFonts.hankenGrotesk(
                                  color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final l = _filtered[i];
                      return ListingCard(
                        listing: l,
                        isFavorite: state.isFavorite(l.id),
                        onTap: () => Navigator.of(ctx).push(
                          MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: l)),
                        ),
                        onFavTap: () => state.toggleFavorite(l),
                      );
                    },
                    childCount: _filtered.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Story circle ──────────────────────────────────────────────

class _StoryCircle extends StatelessWidget {
  final Widget? child;
  final String? imageUrl;
  final String label;
  final bool isDashed;
  final RC rc;
  final VoidCallback onTap;

  const _StoryCircle({
    this.child,
    this.imageUrl,
    required this.label,
    required this.isDashed,
    required this.rc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 62,
        child: Column(
          children: [
            Container(
              width: 62, height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rc.card,
                border: isDashed
                    ? Border.all(color: rc.line, width: 1.5)
                    : Border.all(color: rc.line, width: 2),
              ),
              child: ClipOval(
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(imageUrl!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(child: Icon(Icons.photo, color: rc.muted, size: 20)))
                    : child,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.hankenGrotesk(fontSize: 9, color: rc.ink),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category chip ─────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final RC rc;
  const _Chip({required this.label, required this.active, required this.onTap, required this.rc});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? cAccent : rc.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? cAccent : rc.line),
        ),
        child: Text(
          label,
          style: GoogleFonts.hankenGrotesk(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : rc.ink,
          ),
        ),
      ),
    );
  }
}
