import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_state.dart';
import '../l10n/strings.dart';
import '../models.dart';
import '../theme.dart';
import 'ai_price_screen.dart';
import 'escrow_screen.dart';
import 'messages_screen.dart';
import 'offer_screen.dart';
import 'seller_shop_screen.dart';

class ListingDetailScreen extends StatefulWidget {
  final Listing listing;
  const ListingDetailScreen({super.key, required this.listing});
  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  int _imgIdx = 0;
  // Simulate 3 images
  late final List<String> _images;

  @override
  void initState() {
    super.initState();
    final url = widget.listing.imageUrl;
    _images = url.isNotEmpty ? [url, url, url] : [];
  }

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    final l = widget.listing;
    final state = AppStateScope.of(context);
    final isFav = state.isFavorite(l.id);

    return Scaffold(
      backgroundColor: rc.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Image carousel ────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: rc.card,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _images.isNotEmpty
                      ? PageView.builder(
                          itemCount: _images.length,
                          onPageChanged: (i) => setState(() => _imgIdx = i),
                          itemBuilder: (_, i) => Image.network(
                            _images[i],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: rc.line),
                          ),
                        )
                      : Container(color: rc.line,
                          child: Icon(Icons.image_outlined, size: 60, color: rc.muted)),
                  // Gradient
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  // Dot indicator
                  if (_images.length > 1)
                    Positioned(
                      bottom: 12, right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${_imgIdx + 1}/${_images.length}',
                            style: GoogleFonts.hankenGrotesk(
                                fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                ],
              ),
            ),
            leading: _OvBtn(
              icon: Icons.arrow_back_ios_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
            actions: [
              _OvBtn(
                icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                iconColor: isFav ? Colors.red : null,
                onTap: () {
                  state.toggleFavorite(l);
                  HapticFeedback.lightImpact();
                },
              ),
              _OvBtn(
                icon: Icons.share_rounded,
                onTap: () => HapticFeedback.lightImpact(),
              ),
            ],
          ),

          // ── Body ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: cAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(l.category,
                            style: GoogleFonts.hankenGrotesk(
                                fontSize: 11, fontWeight: FontWeight.w600, color: cAccent)),
                      ),
                      const Spacer(),
                      Icon(Icons.remove_red_eye_outlined, size: 12, color: rc.muted),
                      const SizedBox(width: 4),
                      Text('${l.views} ${S.get('views')}',
                          style: GoogleFonts.hankenGrotesk(fontSize: 11, color: rc.muted)),
                      const SizedBox(width: 10),
                      Icon(Icons.access_time_rounded, size: 12, color: rc.muted),
                      const SizedBox(width: 4),
                      Text(l.date,
                          style: GoogleFonts.hankenGrotesk(fontSize: 11, color: rc.muted)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Price
                  Text(
                    l.formattedPrice,
                    style: GoogleFonts.spectral(
                        fontSize: 30, fontWeight: FontWeight.w700, color: rc.accent),
                  ),
                  const SizedBox(height: 8),
                  // AI price badge
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AiPriceScreen(listing: l)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F4EC),
                        border: Border.all(color: const Color(0xFFBFE0C9)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFF2F9E5C)),
                          const SizedBox(width: 6),
                          Text('AI: Yaxshi narx — bozordan 9% arzon',
                              style: GoogleFonts.hankenGrotesk(fontSize: 10.5, fontWeight: FontWeight.w700, color: const Color(0xFF1F7A44))),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF1F7A44)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    l.title,
                    style: GoogleFonts.spectral(
                        fontSize: 20, fontWeight: FontWeight.w600, color: rc.ink, height: 1.3),
                  ),
                  const SizedBox(height: 14),
                  // Props
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _PropChip(
                            icon: Icons.location_on_rounded,
                            text: l.location, rc: rc),
                        const SizedBox(width: 8),
                        _PropChip(
                            icon: Icons.inventory_2_outlined,
                            text: l.condition == 'new' ? S.get('conditionNew') : S.get('conditionUsed'),
                            rc: rc),
                        if (l.isCompany) ...[
                          const SizedBox(width: 8),
                          _PropChip(
                              icon: Icons.business_rounded,
                              text: S.get('company'), rc: rc),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ── Seller card ───────────────────────────────
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => SellerShopScreen(
                        sellerName: l.sellerName,
                        sellerInitials: l.sellerName.isNotEmpty ? l.sellerName.substring(0, 1).toUpperCase() : '?',
                      ),
                    )),
                    child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: rc.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: rc.line),
                      boxShadow: warmShadow(rc.dark),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: cAccent, shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              l.sellerName.isNotEmpty
                                  ? l.sellerName.substring(0, 1).toUpperCase()
                                  : '?',
                              style: GoogleFonts.spectral(
                                  fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.sellerName,
                                  style: GoogleFonts.hankenGrotesk(
                                      fontSize: 14, fontWeight: FontWeight.w700, color: rc.ink)),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(Icons.verified_rounded,
                                      size: 12, color: Color(0xFF22A06B)),
                                  const SizedBox(width: 4),
                                  Text(S.get('verified'),
                                      style: GoogleFonts.hankenGrotesk(
                                          fontSize: 11, color: rc.muted)),
                                  const SizedBox(width: 8),
                                  Icon(Icons.star_rounded, size: 12, color: cAmber),
                                  const SizedBox(width: 2),
                                  Text('${l.sellerRating}',
                                      style: GoogleFonts.hankenGrotesk(
                                          fontSize: 11, fontWeight: FontWeight.w600, color: rc.ink)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: rc.muted),
                      ],
                    ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Offer + safe checkout ───────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => OfferScreen.show(context, l),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: rc.card,
                              border: Border.all(color: rc.line),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sell_outlined, size: 15, color: rc.accent),
                                const SizedBox(width: 6),
                                Text('Narx taklif qilish',
                                    style: GoogleFonts.hankenGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: rc.ink)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EscrowScreen(listing: l))),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBEEE4),
                              border: Border.all(color: rc.accent),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shield_outlined, size: 15, color: rc.accent),
                                const SizedBox(width: 6),
                                Text('Xavfsiz sotib olish',
                                    style: GoogleFonts.hankenGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: rc.accent)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // ── Description ───────────────────────────────
                  Text(S.get('description'),
                      style: GoogleFonts.spectral(
                          fontSize: 18, fontWeight: FontWeight.w700, color: rc.ink)),
                  const SizedBox(height: 10),
                  Text(l.description,
                      style: GoogleFonts.hankenGrotesk(
                          fontSize: 14, color: rc.muted, height: 1.65)),
                ],
              ),
            ),
          ),
        ],
      ),
      // ── Sticky bottom ─────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        decoration: BoxDecoration(
          color: rc.card,
          border: Border(top: BorderSide(color: rc.line)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Message
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => MessagesScreen(
                      peerName: l.sellerName,
                      peerInitials: l.sellerName.isNotEmpty ? l.sellerName.substring(0, 1).toUpperCase() : '?',
                      listing: l,
                    ),
                  )),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: rc.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: rc.line),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 16, color: rc.ink),
                        const SizedBox(width: 7),
                        Text(S.get('message'),
                            style: GoogleFonts.hankenGrotesk(
                                fontSize: 14, fontWeight: FontWeight.w600, color: rc.ink)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Call
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse('tel:${l.phone}');
                    if (await canLaunchUrl(uri)) launchUrl(uri);
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: cAccent,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(
                        color: cAccent.withValues(alpha: 0.35),
                        blurRadius: 12, offset: const Offset(0, 5),
                      )],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone_rounded, size: 16, color: Colors.white),
                        const SizedBox(width: 7),
                        Text(S.get('call'),
                            style: GoogleFonts.hankenGrotesk(
                                fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OvBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  const _OvBtn({required this.icon, required this.onTap, this.iconColor});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8)],
        ),
        child: Icon(icon, color: iconColor ?? cInk, size: 18),
      ),
    );
  }
}

class _PropChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final RC rc;
  const _PropChip({required this.icon, required this.text, required this.rc});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: rc.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: rc.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: cAccent),
          const SizedBox(width: 5),
          Text(text,
              style: GoogleFonts.hankenGrotesk(
                  fontSize: 12, fontWeight: FontWeight.w500, color: rc.ink)),
        ],
      ),
    );
  }
}
