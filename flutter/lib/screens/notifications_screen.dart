import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/strings.dart';
import '../theme.dart';

class _Notif {
  final String title, body, time;
  final IconData icon;
  final String group;
  bool isRead;
  _Notif({required this.title, required this.body, required this.time,
      required this.icon, required this.group, this.isRead = false});
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final List<_Notif> _notifs;

  @override
  void initState() {
    super.initState();
    _notifs = [
      _Notif(
        title: "Narx tushdi!",
        body: "John Deere traktor narxi \$28,500 dan \$26,000 ga tushirildi.",
        time: '10:24',
        icon: Icons.trending_down_rounded,
        group: 'today',
      ),
      _Notif(
        title: 'Yangi xabar',
        body: 'Mansur Xolmatov sizga xabar yubordi.',
        time: '09:15',
        icon: Icons.chat_bubble_outline_rounded,
        group: 'today',
      ),
      _Notif(
        title: "TOP e'lon tugadi",
        body: "iPhone 15 Pro e'loningizning TOP muddati tugadi. Qayta ulashing.",
        time: 'Kecha, 22:00',
        icon: Icons.star_outline_rounded,
        group: 'yesterday',
        isRead: true,
      ),
      _Notif(
        title: "E'lon tasdiqlandi",
        body: "Toyota Camry e'loningiz ko'rib chiqildi va nashr etildi.",
        time: 'Kecha, 15:30',
        icon: Icons.check_circle_outline_rounded,
        group: 'yesterday',
        isRead: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    final unreadCount = _notifs.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: rc.bg,
      appBar: AppBar(
        backgroundColor: rc.card,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: rc.ink, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(S.get('notifications'),
            style: GoogleFonts.spectral(
                fontSize: 18, fontWeight: FontWeight.w700, color: rc.ink)),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => setState(() {
                for (final n in _notifs) {
                  n.isRead = true;
                }
              }),
              child: Text(S.get('markAllRead'),
                  style: GoogleFonts.hankenGrotesk(
                      fontSize: 12, fontWeight: FontWeight.w600, color: cAccent)),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: rc.line),
        ),
      ),
      body: _notifs.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 48, color: rc.muted),
                  const SizedBox(height: 12),
                  Text(S.get('noNotif'),
                      style: GoogleFonts.spectral(
                          fontSize: 18, fontWeight: FontWeight.w700, color: rc.ink)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 32),
              children: [
                // Today
                _GroupHeader(label: S.get('today'), rc: rc),
                ..._notifs.where((n) => n.group == 'today').map(
                      (n) => _NotifTile(
                        notif: n,
                        rc: rc,
                        onTap: () => setState(() => n.isRead = true),
                      ),
                    ),
                // Yesterday
                _GroupHeader(label: S.get('yesterday'), rc: rc),
                ..._notifs.where((n) => n.group == 'yesterday').map(
                      (n) => _NotifTile(
                        notif: n,
                        rc: rc,
                        onTap: () => setState(() => n.isRead = true),
                      ),
                    ),
              ],
            ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String label;
  final RC rc;
  const _GroupHeader({required this.label, required this.rc});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(label,
          style: GoogleFonts.hankenGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: rc.muted,
              letterSpacing: 0.8)),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final _Notif notif;
  final RC rc;
  final VoidCallback onTap;
  const _NotifTile({required this.notif, required this.rc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        decoration: BoxDecoration(
          color: notif.isRead ? rc.card : cAccent.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notif.isRead ? rc.line : cAccent.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left accent
            if (!notif.isRead)
              Container(
                width: 3,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: cAccent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: notif.isRead
                      ? rc.line
                      : cAccent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(notif.icon,
                    size: 20,
                    color: notif.isRead ? rc.muted : cAccent),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(notif.title,
                              style: GoogleFonts.hankenGrotesk(
                                  fontSize: 13,
                                  fontWeight: notif.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  color: rc.ink)),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 7, height: 7,
                            decoration: const BoxDecoration(
                                color: cAccent, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notif.body,
                        style: GoogleFonts.hankenGrotesk(
                            fontSize: 12, color: rc.muted, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(notif.time,
                        style: GoogleFonts.hankenGrotesk(
                            fontSize: 11, color: rc.muted)),
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
