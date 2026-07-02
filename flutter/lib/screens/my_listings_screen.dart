import 'package:flutter/material.dart';
import '../api.dart' as api;
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});
  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  int _tab = 0;
  bool _loading = true;
  String? _error;
  List<Listing> _listings = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final token = AppStateScope.of(context).token;
    if (token == null) {
      setState(() { _loading = false; _error = "Tizimga kirmagansiz"; });
      return;
    }
    try {
      final list = await api.getMyListings(token);
      if (!mounted) return;
      setState(() { _listings = list; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  List<Listing> get _active => _listings.where((l) => l.status == 'active' || l.status == 'pending_payment').toList();
  List<Listing> get _sold => _listings.where((l) => l.status == 'sold').toList();
  List<Listing> get _archived => _listings.where((l) => l.status == 'draft' || l.status == 'expired' || l.status == 'rejected').toList();

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    final shown = _tab == 0 ? _active : _tab == 1 ? _sold : _archived;

    return Scaffold(
      backgroundColor: rc.bg,
      appBar: RScreenHeader(title: "Mening e'lonlarim"),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: rc.card, border: Border(bottom: BorderSide(color: rc.line))),
            child: Row(
              children: [
                _Tab(label: 'Faol ${_active.length}', active: _tab == 0, onTap: () => setState(() => _tab = 0), rc: rc),
                const SizedBox(width: 18),
                _Tab(label: 'Sotilgan ${_sold.length}', active: _tab == 1, onTap: () => setState(() => _tab = 1), rc: rc),
                const SizedBox(width: 18),
                _Tab(label: 'Arxiv', active: _tab == 2, onTap: () => setState(() => _tab = 2), rc: rc),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: cAccent))
                : _error != null
                    ? Center(
                        child: REmptyState(
                          icon: Icons.wifi_off_rounded,
                          title: 'Yuklab bo\'lmadi',
                          subtitle: _error!,
                          actionLabel: 'Qayta urinish',
                          onAction: _load,
                        ),
                      )
                    : shown.isEmpty
                        ? Center(
                            child: REmptyState(
                              icon: Icons.inventory_2_outlined,
                              title: _tab == 1 ? "Sotilgan e'lonlar yo'q" : _tab == 2 ? "Arxiv bo'sh" : "Faol e'lonlar yo'q",
                              subtitle: 'Bu yerda hozircha hech narsa yo\'q.',
                            ),
                          )
                        : RefreshIndicator(
                            color: cAccent,
                            onRefresh: _load,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: shown.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (_, i) => _ListingCard(l: shown[i], rc: rc),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final RC rc;
  const _Tab({required this.label, required this.active, required this.onTap, required this.rc});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: active ? rc.accent : Colors.transparent, width: 2))),
        child: Text(label, style: hanken(size: 12.5, weight: FontWeight.w700, color: active ? rc.accent : rc.muted)),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final Listing l;
  final RC rc;
  const _ListingCard({required this.l, required this.rc});

  @override
  Widget build(BuildContext context) {
    final pendingPayment = l.status == 'pending_payment';
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(color: rc.card, border: Border.all(color: rc.line), borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: l.imageUrl.isNotEmpty
                        ? Image.network(l.imageUrl, width: 60, height: 60, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: rc.line))
                        : Container(width: 60, height: 60, color: rc.line,
                            child: Icon(Icons.image_outlined, color: rc.muted, size: 22)),
                  ),
                  if (l.isTop)
                    Positioned(
                      top: 3, left: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(color: cAmber, borderRadius: BorderRadius.circular(4)),
                        child: Text('TOP', style: hanken(size: 7, weight: FontWeight.w800, color: cInk)),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: hanken(size: 12.5, weight: FontWeight.w600, color: rc.ink)),
                    Text(l.formattedPrice, style: spectral(size: 14, weight: FontWeight.w700, color: rc.accent)),
                    Row(
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: pendingPayment ? cAmber : const Color(0xFF2F9E5C)),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pendingPayment ? "To'lov kutilmoqda" : 'Faol',
                          style: hanken(size: 9.5, weight: FontWeight.w700, color: pendingPayment ? cAmber : const Color(0xFF2F9E5C)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!pendingPayment) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: rc.line))),
              child: Row(
                children: [
                  Icon(Icons.remove_red_eye_outlined, size: 12, color: rc.muted),
                  const SizedBox(width: 4),
                  Text('${l.views}', style: hanken(size: 10.5, color: rc.muted)),
                  const Spacer(),
                  Text('Tahrirlash', style: hanken(size: 10.5, weight: FontWeight.w700, color: rc.accent)),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 10),
            RSecondaryButton(label: "To'lovni yakunlash", icon: Icons.credit_card_rounded, height: 36, onTap: () {}),
          ],
        ],
      ),
    );
  }
}
