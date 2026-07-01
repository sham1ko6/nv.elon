import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_state.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import '../widgets/listing_card.dart';
import '../widgets/ravoq_shield.dart';
import 'listing_detail_screen.dart';
import 'main_shell.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    final state = AppStateScope.of(context);
    final favs = state.favorites;

    return Scaffold(
      backgroundColor: rc.bg,
      appBar: AppBar(
        backgroundColor: rc.card,
        title: Row(
          children: [
            RavoqShield(size: 20, color: cAccent, letterColor: Colors.white),
            const SizedBox(width: 8),
            Text(S.get('saved'),
                style: GoogleFonts.spectral(
                    fontSize: 20, fontWeight: FontWeight.w700, color: rc.ink)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: rc.line),
        ),
      ),
      body: favs.isEmpty
          ? _Empty(rc: rc)
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemCount: favs.length,
              itemBuilder: (ctx, i) {
                final l = favs[i];
                return ListingCard(
                  listing: l,
                  isFavorite: true,
                  onTap: () => Navigator.of(ctx).push(
                    MaterialPageRoute(
                        builder: (_) => ListingDetailScreen(listing: l)),
                  ),
                  onFavTap: () => state.toggleFavorite(l),
                );
              },
            ),
    );
  }
}

class _Empty extends StatelessWidget {
  final RC rc;
  const _Empty({required this.rc});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                  color: cAccent.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: Icon(Icons.favorite_border_rounded, size: 38, color: cAccent.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 18),
            Text(S.get('noSaved'),
                style: GoogleFonts.spectral(
                    fontSize: 20, fontWeight: FontWeight.w700, color: rc.ink)),
            const SizedBox(height: 8),
            Text(S.get('noSavedHint'),
                textAlign: TextAlign.center,
                style: GoogleFonts.hankenGrotesk(fontSize: 13, color: rc.muted)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                // Navigate to home tab
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainShell()),
                  (_) => false,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: cAccent, borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(
                      color: cAccent.withValues(alpha: 0.3), blurRadius: 12,
                      offset: const Offset(0, 5))],
                ),
                child: Text(S.get('backHome'),
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
