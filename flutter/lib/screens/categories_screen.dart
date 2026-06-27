// ============================================================
// screens/categories_screen.dart  –  Light categories list
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../app_state.dart';
import '../mock_data.dart';
import 'main_shell.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String? _expandedId;

  // Apply category + subcategory filter, then jump back to the Home feed.
  void _openCategory(String categoryId, String subcategoryId) {
    AppStateProvider.of(context).setSubcategory(categoryId, subcategoryId);
    MainShellScope.of(context)?.goToTab(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Text("Bo'limlar",
                  style: GoogleFonts.outfit(
                      fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                physics: const BouncingScrollPhysics(),
                itemCount: kCategories.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final cat = kCategories[i];
                  final isExpanded = _expandedId == cat.id;
                  final color = AppTheme.categoryColor(cat.id);
                  final gradient = AppTheme.categoryGradient(cat.id);

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isExpanded ? color.withValues(alpha: 0.5) : AppColors.border),
                      boxShadow: kCardShadow,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        // Header row (tap to expand)
                        GestureDetector(
                          onTap: () => setState(() => _expandedId = isExpanded ? null : cat.id),
                          child: Container(
                            color: Colors.transparent,
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 46, height: 46,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: gradient,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(AppTheme.categoryIcon(cat.id),
                                      color: AppColors.onPrimary, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(cat.uzName,
                                          style: GoogleFonts.outfit(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary)),
                                      const SizedBox(height: 2),
                                      Text(cat.name,
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                AnimatedRotation(
                                  turns: isExpanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 250),
                                  child: const Icon(Icons.expand_more_rounded, color: AppColors.textHint),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Subcategories
                        if (isExpanded) ...[
                          const Divider(height: 1, color: AppColors.border),
                          ...cat.subcategories.asMap().entries.map((e) {
                            final sub = e.value;
                            final isLast = e.key == cat.subcategories.length - 1;
                            return GestureDetector(
                              onTap: () => _openCategory(cat.id, sub.id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: isLast ? Colors.transparent : AppColors.border),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6, height: 6,
                                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(sub.uzName,
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary)),
                                    ),
                                    const Icon(Icons.arrow_forward_ios_rounded,
                                        size: 12, color: AppColors.textHint),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
