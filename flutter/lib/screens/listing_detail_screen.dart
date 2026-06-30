// ============================================================
// screens/listing_detail_screen.dart  –  Premium detail view
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_theme.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../mock_data.dart';
import '../models.dart';

class ListingDetailScreen extends StatefulWidget {
  final String listingId;
  const ListingDetailScreen({super.key, required this.listingId});
  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  int _imgIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final loc = AppLocalizations.of(context);
    final listing = state.listings.firstWhere(
      (l) => l.id == widget.listingId,
      orElse: () => state.listings.first,
    );
    final catColor = AppTheme.categoryColor(listing.categoryId);
    final catName = kCategories
        .firstWhere((c) => c.id == listing.categoryId,
            orElse: () => kCategories.first)
        .uzName;

    // Simulate multiple images for demo: repeat the single url 3x
    final images = listing.imageUrl.isNotEmpty
        ? List.generate(3, (_) => listing.imageUrl)
        : <String>[];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Image carousel ────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Carousel
                  images.isNotEmpty
                      ? PageView.builder(
                          itemCount: images.length,
                          onPageChanged: (i) =>
                              setState(() => _imgIndex = i),
                          itemBuilder: (_, i) => Image.network(
                            images[i],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _NoPhoto(catColor: catColor, listing: listing),
                          ),
                        )
                      : _NoPhoto(catColor: catColor, listing: listing),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.45),
                            Colors.transparent
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Page indicator
                  if (images.length > 1)
                    Positioned(
                      bottom: 12,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_imgIndex + 1}/${images.length}',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            leading: _RoundBtn(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
            actions: [
              _RoundBtn(
                icon: listing.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                iconColor:
                    listing.isFavorite ? AppColors.danger : AppColors.textPrimary,
                onTap: () => state.toggleFavorite(listing.id),
              ),
              _RoundBtn(
                icon: Icons.share_rounded,
                onTap: () => HapticFeedback.lightImpact(),
              ),
            ],
          ),

          // ── Body ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + views row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(catName,
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: catColor)),
                      ),
                      const Spacer(),
                      Icon(Icons.remove_red_eye_rounded,
                          size: 14, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(loc.viewCount(listing.views),
                          style: GoogleFonts.inter(
                              fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time_rounded,
                          size: 14, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(listing.date,
                          style: GoogleFonts.inter(
                              fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Price
                  Text(
                    Listing.formatPrice(listing.price, listing.currency),
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    listing.title,
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.3),
                  ),
                  const SizedBox(height: 16),

                  // Property chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _PropChip(
                            icon: Icons.location_on_rounded,
                            text: listing.location),
                        const SizedBox(width: 8),
                        _PropChip(
                            icon: Icons.category_rounded, text: catName),
                        if (listing.isCompany) ...[
                          const SizedBox(width: 8),
                          _PropChip(
                              icon: Icons.business_rounded,
                              text: loc.companyLabel),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Seller card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: kCardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                colors: AppColors.primaryGradient),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              listing.sellerName.isNotEmpty
                                  ? listing.sellerName
                                      .substring(0, 1)
                                      .toUpperCase()
                                  : '?',
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onPrimary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(listing.sellerName,
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(Icons.verified_rounded,
                                      size: 12, color: AppColors.success),
                                  const SizedBox(width: 4),
                                  Text(
                                    listing.isCompany
                                        ? loc.companyVerified
                                        : loc.individualVerified,
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(Icons.star_rounded,
                                      size: 12,
                                      color: i < 4
                                          ? AppColors.amber
                                          : AppColors.border),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 14, color: AppColors.textHint),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(loc.descriptionTitle,
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  Text(listing.description,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.65)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Sticky bottom bar ──────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _ContactSheet(
                        name: listing.sellerName,
                        phone: listing.phone),
                  ),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone_rounded,
                            color: AppColors.onPrimary, size: 18),
                        const SizedBox(width: 8),
                        Text(loc.callBtn,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onPrimary)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _ContactSheet(
                      name: listing.sellerName, phone: listing.phone),
                ),
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded,
                      color: AppColors.textPrimary, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  const _RoundBtn(
      {required this.icon, required this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: kCardShadow,
        ),
        child: Icon(icon,
            color: iconColor ?? AppColors.textPrimary, size: 20),
      ),
    );
  }
}

class _PropChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PropChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(text,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _NoPhoto extends StatelessWidget {
  final Color catColor;
  final Listing listing;
  const _NoPhoto({required this.catColor, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: catColor.withValues(alpha: 0.08),
      child: Center(
        child: Icon(AppTheme.categoryIcon(listing.categoryId),
            size: 72, color: catColor.withValues(alpha: 0.4)),
      ),
    );
  }
}

class _ContactSheet extends StatelessWidget {
  final String name;
  final String phone;
  const _ContactSheet({required this.name, required this.phone});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: kCardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.person_rounded, color: AppColors.primary, size: 30),
          ),
          const SizedBox(height: 14),
          Text(name,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(phone,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _SheetBtn(
                  label: loc.callBtn,
                  icon: Icons.call_rounded,
                  color: AppColors.success,
                  onTap: () async {
                    final uri = Uri.parse('tel:$phone');
                    if (await canLaunchUrl(uri)) launchUrl(uri);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SheetBtn(
                  label: loc.messageBtn,
                  icon: Icons.sms_rounded,
                  color: AppColors.primary,
                  onTap: () async {
                    final uri = Uri.parse('sms:$phone');
                    if (await canLaunchUrl(uri)) launchUrl(uri);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.closeBtn,
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _SheetBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SheetBtn(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
