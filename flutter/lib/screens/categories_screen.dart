import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/strings.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/ravoq_shield.dart';
import 'search_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return Scaffold(
      backgroundColor: rc.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: rc.card,
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                RavoqShield(size: 22, color: cAccent, letterColor: Colors.white),
                const SizedBox(width: 8),
                Text('Ravoq.',
                    style: GoogleFonts.spectral(
                        fontSize: 18, fontWeight: FontWeight.w700, color: rc.accent)),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: rc.line),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                S.get('categories'),
                style: GoogleFonts.spectral(
                    fontSize: 24, fontWeight: FontWeight.w700, color: rc.ink),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final cat = kCategories[i];
                  return GestureDetector(
                    onTap: () => Navigator.of(ctx).push(MaterialPageRoute(
                      builder: (_) => SearchScreen(initialCategory: cat.id),
                    )),
                    child: Container(
                      decoration: BoxDecoration(
                        color: rc.card,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: warmShadow(rc.dark),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Background image
                            if (cat.imageUrl.isNotEmpty)
                              Image.network(
                                cat.imageUrl,
                                fit: BoxFit.cover,
                                color: Colors.black.withValues(alpha: 0.38),
                                colorBlendMode: BlendMode.darken,
                                errorBuilder: (_, __, ___) => Container(color: cAccent.withValues(alpha: 0.12)),
                              )
                            else
                              Container(color: cAccent.withValues(alpha: 0.12)),
                            // Gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.6),
                                  ],
                                ),
                              ),
                            ),
                            // Label
                            Positioned(
                              bottom: 12, left: 12, right: 12,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cat.emoji, style: const TextStyle(fontSize: 22)),
                                  const SizedBox(height: 4),
                                  Text(
                                    cat.name,
                                    style: GoogleFonts.hankenGrotesk(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: kCategories.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
