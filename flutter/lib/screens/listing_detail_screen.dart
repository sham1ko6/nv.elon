// ============================================================
// screens/listing_detail_screen.dart  –  Light detail view
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../app_state.dart';
import '../mock_data.dart';

class ListingDetailScreen extends StatelessWidget {
  final String listingId;
  const ListingDetailScreen({super.key, required this.listingId});

  String _formatPrice(double price, String currency) {
    final priceInt = price.toInt();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final pStr = priceInt.toString().replaceAllMapped(reg, (m) => '${m[1]} ');
    return '$pStr $currency';
  }

  // A small round button (back / share / favorite) shown over the photo.
  Widget _circleButton({required IconData icon, required VoidCallback onTap, Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: kCardShadow,
        ),
        child: Icon(icon, color: iconColor ?? AppColors.textPrimary, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final listing = state.listings.firstWhere(
      (l) => l.id == listingId,
      orElse: () => state.listings.first,
    );

    final catGradient = AppTheme.categoryGradient(listing.categoryId);
    final catName = kCategories
        .firstWhere((c) => c.id == listing.categoryId, orElse: () => kCategories.first)
        .uzName;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Image header ──
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: _circleButton(
                icon: Icons.arrow_back_rounded, onTap: () => Navigator.of(context).pop()),
            actions: [
              _circleButton(
                icon: listing.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                iconColor: listing.isFavorite ? AppColors.danger : AppColors.textPrimary,
                onTap: () => state.toggleFavorite(listing.id),
              ),
              _circleButton(icon: Icons.share_rounded, onTap: () => HapticFeedback.lightImpact()),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: listing.imageUrl.isNotEmpty
                  ? Image.network(listing.imageUrl, fit: BoxFit.cover)
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: catGradient.map((c) => c.withValues(alpha: 0.18)).toList(),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                      ),
                      child: Center(
                        child: Icon(AppTheme.categoryIcon(listing.categoryId),
                            size: 72, color: AppTheme.categoryColor(listing.categoryId).withValues(alpha: 0.6)),
                      ),
                    ),
            ),
          ),

          // ── Body ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.categoryColor(listing.categoryId).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(catName,
                        style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.categoryColor(listing.categoryId))),
                  ),
                  const SizedBox(height: 12),
                  // Price
                  Text(_formatPrice(listing.price, listing.currency),
                      style: GoogleFonts.outfit(
                          fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  // Title
                  Text(listing.title,
                      style: GoogleFonts.outfit(
                          fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3)),
                  const SizedBox(height: 14),
                  // Meta chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(icon: Icons.location_on_rounded, text: listing.location),
                      _MetaChip(icon: Icons.calendar_today_rounded, text: listing.date),
                      _MetaChip(icon: Icons.remove_red_eye_rounded, text: "${listing.views} ko'rildi"),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Seller card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: kCardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46, height: 46,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: AppColors.primaryGradient),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              listing.sellerName.isNotEmpty
                                  ? listing.sellerName.substring(0, 1).toUpperCase()
                                  : '?',
                              style: GoogleFonts.outfit(
                                  fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onPrimary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(listing.sellerName,
                                  style: GoogleFonts.outfit(
                                      fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text(listing.isCompany ? 'Kompaniya' : 'Jismoniy shaxs',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.verified_rounded, color: AppColors.success, size: 12),
                              const SizedBox(width: 4),
                              Text('Tekshirilgan',
                                  style: GoogleFonts.outfit(
                                      fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.success)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Tavsif',
                      style: GoogleFonts.outfit(
                          fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text(listing.description,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5, color: AppColors.textSecondary, height: 1.6)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Sticky bottom: price + call ──
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Narxi',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(_formatPrice(listing.price, listing.currency),
                      style: GoogleFonts.outfit(
                          fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _CallSheet(name: listing.sellerName, phone: listing.phone),
                  ),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppColors.primaryGradient),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withValues(alpha: 0.30), blurRadius: 12, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone_rounded, color: AppColors.onPrimary, size: 18),
                        const SizedBox(width: 8),
                        Text('Sotuvchi bilan aloqa',
                            style: GoogleFonts.outfit(
                                fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.onPrimary)),
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

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _CallSheet extends StatelessWidget {
  final String name;
  final String phone;
  const _CallSheet({required this.name, required this.phone});

  @override
  Widget build(BuildContext context) {
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
            width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 16),
          Text(name,
              style: GoogleFonts.outfit(
                  fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(phone, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.call_rounded, size: 18),
              label: Text("Qo'ng'iroq qilish",
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Yopish',
                style: GoogleFonts.outfit(
                    color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
