import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class _Msg {
  final String text;
  final bool mine;
  final String time;
  final bool read;
  final Listing? listing;
  _Msg(this.text, this.mine, this.time, {this.read = false, this.listing});
}

class MessagesScreen extends StatefulWidget {
  final String peerName;
  final String peerInitials;
  final Listing? listing;
  const MessagesScreen({super.key, required this.peerName, required this.peerInitials, this.listing});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _ctrl = TextEditingController();
  late final List<_Msg> _msgs;

  @override
  void initState() {
    super.initState();
    _msgs = [
      _Msg('Assalomu alaykum! E\'lon hali aktualmi?', false, '14:02'),
      if (widget.listing != null) _Msg('', false, '', listing: widget.listing),
      _Msg('Vaalaykum assalom! Ha, aktual. Ko\'rishga kelishingiz mumkin.', true, '14:05', read: true),
      _Msg('Ajoyib! Ertaga soat 11:00 da bo\'ladimi?', false, '14:06'),
    ];
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _msgs.add(_Msg(text, true, 'Hozir', read: false));
      _ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return Scaffold(
      backgroundColor: rc.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: rc.card,
              padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: rc.line))),
              child: Row(
                children: [
                  RRoundIconButton(icon: Icons.arrow_back_ios_new_rounded, size: 32, onTap: () => Navigator.of(context).pop()),
                  const SizedBox(width: 11),
                  RInitialsAvatar(widget.peerInitials, size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(widget.peerName, style: hanken(size: 13, weight: FontWeight.w700, color: rc.ink)),
                            const SizedBox(width: 5),
                            Icon(Icons.verified_rounded, size: 12, color: rc.accent),
                          ],
                        ),
                        Text('● Onlayn', style: hanken(size: 10, weight: FontWeight.w600, color: const Color(0xFF3AA76D))),
                      ],
                    ),
                  ),
                  RRoundIconButton(icon: Icons.phone_rounded, color: rc.accent, size: 34, onTap: () {}),
                ],
              ),
            ),
            // Messages
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: rc.line.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20)),
                      child: Text('Bugun', style: hanken(size: 9.5, weight: FontWeight.w600, color: rc.muted)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final m in _msgs) _Bubble(msg: m, rc: rc),
                ],
              ),
            ),
            // Input
            Container(
              color: rc.card,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: rc.line))),
              child: Row(
                children: [
                  RRoundIconButton(icon: Icons.add_rounded, color: rc.accent, size: 38, onTap: () {}),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: rc.bg,
                        border: Border.all(color: rc.line),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        style: hanken(size: 12.5, color: rc.ink),
                        decoration: InputDecoration(
                          hintText: 'Xabar yozing…',
                          hintStyle: hanken(size: 12.5, color: rc.muted),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: rc.accent, shape: BoxShape.circle),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 17),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final _Msg msg;
  final RC rc;
  const _Bubble({required this.msg, required this.rc});

  @override
  Widget build(BuildContext context) {
    if (msg.listing != null) {
      final l = msg.listing!;
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          constraints: const BoxConstraints(maxWidth: 260),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: rc.card,
            border: Border.all(color: rc.line),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.network(l.imageUrl, width: 52, height: 52, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 52, height: 52, color: rc.line)),
              ),
              const SizedBox(width: 9),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: hanken(size: 11, weight: FontWeight.w600, color: rc.ink)),
                    Text(l.formattedPrice, style: spectral(size: 13, weight: FontWeight.w700, color: rc.accent)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Align(
      alignment: msg.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: msg.mine ? rc.accent : rc.card,
          border: msg.mine ? null : Border.all(color: rc.line),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(msg.mine ? 14 : 4),
            topRight: Radius.circular(msg.mine ? 4 : 14),
            bottomLeft: const Radius.circular(14),
            bottomRight: const Radius.circular(14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(msg.text, style: hanken(size: 12, color: msg.mine ? Colors.white : rc.ink, height: 1.45)),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(msg.time, style: hanken(size: 9, color: msg.mine ? Colors.white.withValues(alpha: 0.7) : rc.muted)),
                if (msg.mine) ...[
                  const SizedBox(width: 3),
                  Icon(Icons.done_all_rounded, size: 13, color: Colors.white.withValues(alpha: 0.7)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
