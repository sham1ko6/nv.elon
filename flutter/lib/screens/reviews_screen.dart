import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ReviewsScreen extends StatefulWidget {
  final String peerName;
  final String peerInitials;
  const ReviewsScreen({super.key, required this.peerName, required this.peerInitials});

  static Future<void> show(BuildContext context, {required String peerName, required String peerInitials}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReviewsScreen(peerName: peerName, peerInitials: peerInitials),
    );
  }

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  int _rating = 4;
  final _tags = <String>{"Rost ma'lumot"};
  final _allTags = ['Tez javob berdi', "Rost ma'lumot", 'Xushmuomala'];

  static const _labels = ['', 'Yomon', 'Qoniqarsiz', "O'rtacha", 'Yaxshi', "A'lo"];

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return Container(
      decoration: BoxDecoration(color: rc.bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const RDragHandle(),
          RInitialsAvatar(widget.peerInitials, size: 54),
          const SizedBox(height: 10),
          Text('Bitim qanday o\'tdi?', style: spectral(size: 18, weight: FontWeight.w700, color: rc.ink)),
          const SizedBox(height: 3),
          Text('${widget.peerName} bilan savdoyingizni baholang', style: hanken(size: 11.5, color: rc.muted)),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < _rating;
              return GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Icon(filled ? Icons.star_rounded : Icons.star_border_rounded, size: 38, color: filled ? cAmber : const Color(0xFFD8CAB3)),
                ),
              );
            }),
          ),
          const SizedBox(height: 9),
          Text(_labels[_rating], style: hanken(size: 12, weight: FontWeight.w700, color: rc.accent)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
            children: _allTags.map((t) {
              final active = _tags.contains(t);
              return GestureDetector(
                onTap: () => setState(() => active ? _tags.remove(t) : _tags.add(t)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFFFBEEE4) : rc.card,
                    border: Border.all(color: active ? rc.accent : rc.line),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(t, style: hanken(size: 11, weight: active ? FontWeight.w700 : FontWeight.w600, color: active ? rc.accent : rc.ink)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 60),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: rc.card, border: Border.all(color: rc.line), borderRadius: BorderRadius.circular(13)),
            child: TextField(
              maxLines: 3,
              style: hanken(size: 12, color: rc.ink),
              decoration: InputDecoration(
                hintText: 'Izoh qoldiring (ixtiyoriy)…',
                hintStyle: hanken(size: 12, color: rc.muted),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          const SizedBox(height: 14),
          RPrimaryButton(label: 'Sharhni yuborish', onTap: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}
