import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api.dart' as api;
import '../app_state.dart';
import '../l10n/strings.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_screen.dart';
import 'map_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialCategory;
  const SearchScreen({super.key, this.initialCategory});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;

  String _query = '';
  String _sort = 'newest';
  String _condition = 'all';
  String _sellerType = 'all';
  double _minPrice = 0;
  double _maxPrice = 200000;
  late String _category;

  List<Listing> _results = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory ?? 'all';
    _search();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() => _query = v.trim());
      _search();
    });
  }

  Future<void> _search() async {
    setState(() => _loading = true);
    try {
      final list = await api.getListings(
        q: _query.isEmpty ? null : _query,
        category: _category == 'all' ? null : _category,
      );
      // Client-side filter + sort
      var filtered = list.where((l) {
        if (_condition != 'all' && l.condition != _condition) return false;
        if (_sellerType == 'company' && !l.isCompany) return false;
        if (_sellerType == 'individual' && l.isCompany) return false;
        if (l.price > _maxPrice) return false;
        if (l.price < _minPrice) return false;
        return true;
      }).toList();

      switch (_sort) {
        case 'cheapest':
          filtered.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'expensive':
          filtered.sort((a, b) => b.price.compareTo(a.price));
          break;
        default:
          break;
      }

      if (mounted) setState(() { _results = filtered; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    final state = AppStateScope.of(context);
    return Scaffold(
      backgroundColor: rc.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search header ─────────────────────────────────────
            Container(
              color: rc.card,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(Icons.arrow_back_ios_rounded, color: rc.ink, size: 18),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: rc.bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: rc.line),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        focusNode: _focus,
                        onChanged: _onChanged,
                        style: GoogleFonts.hankenGrotesk(fontSize: 14, color: rc.ink),
                        decoration: InputDecoration(
                          hintText: S.get('searchHint'),
                          hintStyle: GoogleFonts.hankenGrotesk(fontSize: 13, color: rc.muted),
                          prefixIcon: Icon(Icons.search_rounded, color: rc.muted, size: 18),
                          suffixIcon: _ctrl.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _ctrl.clear();
                                    setState(() => _query = '');
                                    _search();
                                  },
                                  child: Icon(Icons.close_rounded, size: 16, color: rc.muted),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MapScreen())),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: rc.bg, border: Border.all(color: rc.line), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.map_outlined, color: cAccent, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showFilters(context),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: cAccent, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: rc.line),

            // ── Category chips ────────────────────────────────────
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                children: [
                  _CatChip(
                    label: S.get('allCategories'),
                    active: _category == 'all',
                    onTap: () { setState(() => _category = 'all'); _search(); },
                    rc: rc,
                  ),
                  ...kCategories.map((c) => Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: _CatChip(
                      label: '${c.emoji} ${c.name}',
                      active: _category == c.id,
                      onTap: () { setState(() => _category = c.id); _search(); },
                      rc: rc,
                    ),
                  )),
                ],
              ),
            ),
            Container(height: 1, color: rc.line),

            // ── Sort row ──────────────────────────────────────────
            Container(
              color: rc.card,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    _loading ? '...' : '${_results.length} ta natija',
                    style: GoogleFonts.hankenGrotesk(fontSize: 12, color: rc.muted),
                  ),
                  const Spacer(),
                  // Sort dropdown
                  GestureDetector(
                    onTap: () => _showSortSheet(context),
                    child: Row(
                      children: [
                        Icon(Icons.sort_rounded, size: 16, color: rc.muted),
                        const SizedBox(width: 4),
                        Text(
                          _sort == 'newest' ? S.get('sortNewest')
                              : _sort == 'cheapest' ? S.get('sortCheap')
                              : S.get('sortExpensive'),
                          style: GoogleFonts.hankenGrotesk(
                              fontSize: 12, fontWeight: FontWeight.w600, color: rc.ink),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Results ───────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: cAccent))
                  : _results.isEmpty
                      ? _Empty(rc: rc)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _results.length,
                          itemBuilder: (ctx, i) {
                            final l = _results[i];
                            return ListingRow(
                              listing: l,
                              isFavorite: state.isFavorite(l.id),
                              onTap: () => Navigator.of(ctx).push(
                                MaterialPageRoute(
                                    builder: (_) => ListingDetailScreen(listing: l)),
                              ),
                              onFavTap: () => state.toggleFavorite(l),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        condition: _condition,
        sellerType: _sellerType,
        rc: RC.of(context),
        onApply: (min, max, cond, sel) {
          setState(() {
            _minPrice = min;
            _maxPrice = max;
            _condition = cond;
            _sellerType = sel;
          });
          _search();
        },
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    final rc = RC.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: rc.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(
                color: rc.line, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ...([
              ('newest', S.get('sortNewest')),
              ('cheapest', S.get('sortCheap')),
              ('expensive', S.get('sortExpensive')),
            ].map((s) => GestureDetector(
              onTap: () {
                setState(() => _sort = s.$1);
                _search();
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    Text(s.$2, style: GoogleFonts.hankenGrotesk(
                        fontSize: 15, color: rc.ink, fontWeight: FontWeight.w500)),
                    const Spacer(),
                    if (_sort == s.$1)
                      Icon(Icons.check_rounded, color: cAccent, size: 18),
                  ],
                ),
              ),
            ))),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────

class _Empty extends StatelessWidget {
  final RC rc;
  const _Empty({required this.rc});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: REmptyState(
        icon: Icons.search_off_rounded,
        title: S.get('noResults'),
        subtitle: "Filtrlarni kengaytiring yoki shu qidiruvga obuna bo'ling — yangi e'lon chiqsa, xabar beramiz.",
        actionLabel: 'Qidiruvga obuna',
        onAction: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Qidiruvga obuna bo\'ldingiz')),
        ),
      ),
    );
  }
}

// ── Category chip ─────────────────────────────────────────────

class _CatChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final RC rc;
  const _CatChip(
      {required this.label, required this.active, required this.onTap, required this.rc});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? cAccent : rc.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: active ? cAccent : rc.line),
        ),
        child: Text(label,
            style: GoogleFonts.hankenGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : rc.ink)),
      ),
    );
  }
}

// ── Filter sheet ──────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final double minPrice, maxPrice;
  final String condition, sellerType;
  final RC rc;
  final void Function(double, double, String, String) onApply;
  const _FilterSheet({
    required this.minPrice, required this.maxPrice,
    required this.condition, required this.sellerType,
    required this.rc, required this.onApply,
  });
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late double _min, _max;
  late String _cond, _sel;

  @override
  void initState() {
    super.initState();
    _min = widget.minPrice;
    _max = widget.maxPrice;
    _cond = widget.condition;
    _sel = widget.sellerType;
  }

  @override
  Widget build(BuildContext context) {
    final rc = widget.rc;
    return Container(
      decoration: BoxDecoration(
        color: rc.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(
            width: 36, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: rc.line, borderRadius: BorderRadius.circular(2)),
          )),
          Row(
            children: [
              Text(S.get('filterTitle'),
                  style: GoogleFonts.spectral(fontSize: 20, fontWeight: FontWeight.w700, color: rc.ink)),
              const Spacer(),
              GestureDetector(
                onTap: () { setState(() { _min = 0; _max = 200000; _cond = 'all'; _sel = 'all'; }); },
                child: Text(S.get('clearFilter'),
                    style: GoogleFonts.hankenGrotesk(fontSize: 13, color: cAccent)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Price
          Text(S.get('priceRange'),
              style: GoogleFonts.hankenGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: rc.ink)),
          RangeSlider(
            values: RangeValues(_min, _max),
            min: 0, max: 200000, divisions: 200,
            activeColor: cAccent, inactiveColor: rc.line,
            onChanged: (v) => setState(() { _min = v.start; _max = v.end; }),
          ),
          Row(
            children: [
              Text('\$${_min.toInt()}', style: GoogleFonts.hankenGrotesk(fontSize: 12, color: rc.muted)),
              const Spacer(),
              Text('\$${_max.toInt()}', style: GoogleFonts.hankenGrotesk(fontSize: 12, color: rc.muted)),
            ],
          ),
          const SizedBox(height: 16),
          // Condition
          Text(S.get('condition'),
              style: GoogleFonts.hankenGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: rc.ink)),
          const SizedBox(height: 8),
          _ChipRow(keys: const ['all', 'new', 'used'],
              labels: [S.get('conditionAll'), S.get('conditionNew'), S.get('conditionUsed')],
              selected: _cond, onSelect: (v) => setState(() => _cond = v), rc: rc),
          const SizedBox(height: 16),
          // Seller type
          Text(S.get('sellerType'),
              style: GoogleFonts.hankenGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: rc.ink)),
          const SizedBox(height: 8),
          _ChipRow(keys: const ['all', 'individual', 'company'],
              labels: [S.get('conditionAll'), S.get('individual'), S.get('company')],
              selected: _sel, onSelect: (v) => setState(() => _sel = v), rc: rc),
          const SizedBox(height: 24),
          // Apply
          GestureDetector(
            onTap: () { widget.onApply(_min, _max, _cond, _sel); Navigator.pop(context); },
            child: Container(
              height: 50, width: double.infinity,
              decoration: BoxDecoration(color: cAccent, borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(S.get('showResults'),
                  style: GoogleFonts.hankenGrotesk(
                      fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white))),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  final List<String> keys, labels;
  final String selected;
  final ValueChanged<String> onSelect;
  final RC rc;
  const _ChipRow({required this.keys, required this.labels, required this.selected,
      required this.onSelect, required this.rc});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(keys.length, (i) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => onSelect(keys[i]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected == keys[i] ? cAccent : rc.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: selected == keys[i] ? cAccent : rc.line),
            ),
            child: Text(labels[i], style: GoogleFonts.hankenGrotesk(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: selected == keys[i] ? Colors.white : rc.ink)),
          ),
        ),
      )),
    );
  }
}
