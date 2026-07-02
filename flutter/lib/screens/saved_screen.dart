import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_state.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import '../widgets/common.dart';
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
            const RavoqShield(size: 20),
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
      child: REmptyState(
        icon: Icons.favorite_border_rounded,
        title: S.get('noSaved'),
        subtitle: S.get('noSavedHint'),
        actionLabel: S.get('backHome'),
        onAction: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()),
          (_) => false,
        ),
      ),
    );
  }
}
