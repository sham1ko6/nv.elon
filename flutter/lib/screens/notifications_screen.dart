// ============================================================
// screens/notifications_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../l10n/app_localizations.dart';
import '../mock_data.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<MockNotif> _notifs = List.of(kMockNotifications);

  @override
  Widget build(BuildContext context) {
    final unread = _notifs.where((n) => !n.isRead).length;
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(l.notificationsTitle,
            style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () => setState(() {
                for (var i = 0; i < _notifs.length; i++) {
                  _notifs[i] = _MockNotifMutable(
                    title: _notifs[i].title,
                    body: _notifs[i].body,
                    time: _notifs[i].time,
                    isRead: true,
                    icon: _notifs[i].icon,
                  );
                }
              }),
              child: Text(l.markAllReadBtn,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: _notifs.isEmpty
          ? _empty()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _notifs.length,
              separatorBuilder: (_, _) =>
                  Container(height: 1, color: AppColors.border),
              itemBuilder: (ctx, i) => _NotifTile(
                notif: _notifs[i],
                onTap: () => setState(() {
                  _notifs[i] = _MockNotifMutable(
                    title: _notifs[i].title,
                    body: _notifs[i].body,
                    time: _notifs[i].time,
                    isRead: true,
                    icon: _notifs[i].icon,
                  );
                }),
              ),
            ),
    );
  }

  Widget _empty() {
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded,
                size: 38, color: AppColors.textHint),
          ),
          const SizedBox(height: 16),
          Text(l.noNotifications,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(l.notificationsHint,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// Simple mutable wrapper — we need to flip isRead
class _MockNotifMutable extends MockNotif {
  const _MockNotifMutable({
    required super.title,
    required super.body,
    required super.time,
    required super.isRead,
    required super.icon,
  });
}

class _NotifTile extends StatelessWidget {
  final MockNotif notif;
  final VoidCallback onTap;
  const _NotifTile({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: notif.isRead
            ? AppColors.surface
            : AppColors.primary.withValues(alpha: 0.04),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left accent bar for unread
            Container(
              width: 3,
              height: double.infinity,
              color: notif.isRead ? Colors.transparent : AppColors.primary,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: notif.isRead
                      ? AppColors.surfaceAlt
                      : AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(notif.icon,
                    size: 20,
                    color: notif.isRead
                        ? AppColors.textSecondary
                        : AppColors.primary),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(notif.title,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: notif.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  color: AppColors.textPrimary)),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notif.body,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(notif.time,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textHint)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
