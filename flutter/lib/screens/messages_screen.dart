// ============================================================
// screens/messages_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../l10n/app_localizations.dart';
import '../mock_data.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(AppLocalizations.of(context).messagesTitle,
            style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded,
                color: AppColors.textSecondary, size: 20),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: kMockConversations.isEmpty
          ? _empty()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: kMockConversations.length,
              separatorBuilder: (_, _) =>
                  Container(height: 1, color: AppColors.border),
              itemBuilder: (ctx, i) => _ConvTile(
                conv: kMockConversations[i],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatDetailScreen(conv: kMockConversations[i]),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _empty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: AppColors.surfaceAlt, shape: BoxShape.circle),
              child: const Icon(Icons.chat_bubble_outline_rounded,
                  size: 38, color: AppColors.textHint),
            ),
            const SizedBox(height: 16),
            Text("Xabarlar yo'q",
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text("Sotuvchilar bilan suhbat bu yerda",
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
      );
}

class _ConvTile extends StatelessWidget {
  final MockConv conv;
  final VoidCallback onTap;
  const _ConvTile({required this.conv, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryGradient),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(conv.avatar,
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimary)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(conv.name,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                      ),
                      Text(conv.time,
                          style: GoogleFonts.inter(
                              fontSize: 11, color: AppColors.textHint)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(conv.listingTitle,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(conv.lastMessage,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: conv.unread > 0
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                fontWeight: conv.unread > 0
                                    ? FontWeight.w600
                                    : FontWeight.w400),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (conv.unread > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('${conv.unread}',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onPrimary)),
                        ),
                      ],
                    ],
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

// ── Chat Detail ───────────────────────────────────────────────

class ChatDetailScreen extends StatefulWidget {
  final MockConv conv;
  const ChatDetailScreen({super.key, required this.conv});
  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  final List<_Msg> _msgs = [
    _Msg(text: "Assalomu alaykum! E'lon haqida so'ramoqchiman.", isMine: false, time: '14:22'),
    _Msg(text: "Vaalaykum assalom! Yaxshi, savol bering.", isMine: true, time: '14:23'),
    _Msg(text: "Narx haqida gaplasha olamizmi? Biroz qimmat ko'rindi.", isMine: false, time: '14:24'),
    _Msg(text: "Narx muzokarali, shaxsan uchrashib gaplashsak yaxshi bo'ladi.", isMine: true, time: '14:25'),
  ];

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _msgs.add(_Msg(text: text, isMine: true, time: '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}'));
      _ctrl.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryGradient),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(widget.conv.avatar,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimary)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.conv.name,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  Text(widget.conv.listingTitle,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: AppColors.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _msgs.length,
              itemBuilder: (_, i) => _BubbleTile(msg: _msgs[i]),
            ),
          ),
          _InputBar(ctrl: _ctrl, onSend: _send),
        ],
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool isMine;
  final String time;
  const _Msg({required this.text, required this.isMine, required this.time});
}

class _BubbleTile extends StatelessWidget {
  final _Msg msg;
  const _BubbleTile({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            msg.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isMine)
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryGradient),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded,
                  size: 16, color: AppColors.onPrimary),
            ),
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isMine ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(msg.isMine ? 16 : 4),
                  bottomRight: Radius.circular(msg.isMine ? 4 : 16),
                ),
                boxShadow: kCardShadow,
              ),
              child: Column(
                crossAxisAlignment: msg.isMine
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(msg.text,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: msg.isMine
                              ? AppColors.onPrimary
                              : AppColors.textPrimary,
                          height: 1.4)),
                  const SizedBox(height: 4),
                  Text(msg.time,
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          color: msg.isMine
                              ? AppColors.onPrimary.withValues(alpha: 0.7)
                              : AppColors.textHint)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onSend;
  const _InputBar({required this.ctrl, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: ctrl,
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Xabar yozing...',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.textHint),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryGradient),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  color: AppColors.onPrimary, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
