// ============================================================
// screens/categories_screen.dart  –  Category browser
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../mock_data.dart';
import 'main_shell.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String? _expandedId;

  void _openCategory(String categoryId, String subcategoryId) {
    AppStateProvider.of(context).setSubcategory(categoryId, subcategoryId);
    MainShellScope.of(context)?.goToTab(0);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Text(l.categoriesTitle,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ),
            Container(height: 1, color: AppColors.border),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                physics: const BouncingScrollPhysics(),
                itemCount: kCategories.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
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
                          color: isExpanded
                              ? color.withValues(alpha: 0.4)
                              : AppColors.border),
                      boxShadow: kCardShadow,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        // Header row
                        GestureDetector(
                          onTap: () => setState(() =>
                              _expandedId = isExpanded ? null : cat.id),
                          child: Container(
                            color: Colors.transparent,
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: gradient,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(cat.icon,
                                        style:
                                            const TextStyle(fontSize: 22)),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(cat.uzName,
                                          style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary)),
                                      const SizedBox(height: 2),
                                      Text(
                                          l.subcategoryCount(cat.subcategories.length),
                                          style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                AnimatedRotation(
                                  turns: isExpanded ? 0.5 : 0,
                                  duration:
                                      const Duration(milliseconds: 250),
                                  child: const Icon(
                                      Icons.expand_more_rounded,
                                      color: AppColors.textHint),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Subcategories
                        if (isExpanded) ...[
                          Container(height: 1, color: AppColors.border),
                          ...cat.subcategories.asMap().entries.map((e) {
                            final sub = e.value;
                            final isLast =
                                e.key == cat.subcategories.length - 1;
                            return GestureDetector(
                              onTap: () =>
                                  _openCategory(cat.id, sub.id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: isLast
                                            ? Colors.transparent
                                            : AppColors.border),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(sub.uzName,
                                          style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textPrimary)),
                                    ),
                                    const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 12,
                                        color: AppColors.textHint),
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
