import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_screen.dart';
import 'messages_screen.dart';

class SellerShopScreen extends StatefulWidget {
  final String sellerName;
  final String sellerInitials;
  const SellerShopScreen({super.key, required this.sellerName, required this.sellerInitials});

  @override
  State<SellerShopScreen> createState() => _SellerShopScreenState();
}

class _SellerShopScreenState extends State<SellerShopScreen> {
  int _tab = 0;
  bool _subscribed = false;

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    final items = kMockListings.take(4).toList();

    return Scaffold(
      backgroundColor: rc.bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: 118,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(kMockListings.first.imageUrl),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.3), BlendMode.darken),
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14, top: 8),
                    child: RRoundIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.of(context).pop()),
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Transform.translate(
                offset: const Offset(0, -32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(
                            color: rc.accent,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: rc.bg, width: 3),
                          ),
                          alignment: Alignment.center,
                          child: Text(widget.sellerInitials, style: spectral(size: 22, weight: FontWeight.w800, color: Colors.white)),
                        ),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(widget.sellerName, style: spectral(size: 17, weight: FontWeight.w700, color: rc.ink)),
                                  const SizedBox(width: 5),
                                  Icon(Icons.verified_rounded, size: 14, color: rc.accent),
                                ],
                              ),
                              Text('Rasmiy diler · Toshkent', style: hanken(size: 10.5, color: rc.muted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(color: rc.card, border: Border.all(color: rc.line), borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          _stat('★ 4.9', '218 sharh', rc, true),
                          _stat('64', "E'lon", rc, true),
                          _stat('3 yil', 'Ravoqda', rc, false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: RPrimaryButton(
                            label: _subscribed ? 'Obuna bo\'lindi' : 'Obuna',
                            icon: Icons.notifications_active_rounded,
                            height: 42,
                            onTap: () => setState(() => _subscribed = !_subscribed),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: RSecondaryButton(
                            label: 'Xabar',
                            icon: Icons.chat_bubble_outline_rounded,
                            height: 42,
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => MessagesScreen(peerName: widget.sellerName, peerInitials: widget.sellerInitials),
                            )),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _Tab(label: "E'lonlar 64", active: _tab == 0, onTap: () => setState(() => _tab = 0), rc: rc),
                        const SizedBox(width: 18),
                        _Tab(label: 'Sharhlar', active: _tab == 1, onTap: () => setState(() => _tab = 1), rc: rc),
                        const SizedBox(width: 18),
                        _Tab(label: 'Haqida', active: _tab == 2, onTap: () => setState(() => _tab = 2), rc: rc),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_tab == 0)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.68,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => ListingCard(
                    listing: items[i],
                    onTap: () => Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: items[i]))),
                    onFavTap: () {},
                  ),
                  childCount: items.length,
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(child: Text('Tez orada', style: hanken(size: 13, color: rc.muted))),
              ),
            ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, RC rc, bool divider) => Expanded(
        child: Container(
          decoration: divider ? BoxDecoration(border: Border(right: BorderSide(color: rc.line))) : null,
          child: Column(
            children: [
              Text(value, style: spectral(size: 16, weight: FontWeight.w800, color: rc.ink)),
              Text(label, style: hanken(size: 9, color: rc.muted)),
            ],
          ),
        ),
      );
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
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: active ? rc.accent : Colors.transparent, width: 2))),
        child: Text(label, style: hanken(size: 12.5, weight: FontWeight.w700, color: active ? rc.accent : rc.muted)),
      ),
    );
  }
}
