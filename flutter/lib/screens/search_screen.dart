// ============================================================
// screens/search_screen.dart  –  Search with filters
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_screen.dart';

const _kRecentKey = 'recent_searches';

const _kPopular = [
  'Traktor', 'iPhone', 'Nexia', 'Kvartira', 'MacBook',
];

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  String _query = '';
  List<String> _recent = [];

  // Filter state (language-neutral keys)
  double _minPrice = 0;
  double _maxPrice = 200000;
  String _condition = 'all';    // 'all' | 'new' | 'used'
  String _sortBy = 'newest';    // 'newest' | 'cheapest' | 'expensive'

  @override
  void initState() {
    super.initState();
    _loadRecent();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recent = prefs.getStringList(_kRecentKey) ?? [];
    });
  }

  Future<void> _saveRecent(String query) async {
    final list = [query, ..._recent.where((q) => q != query)].take(8).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kRecentKey, list);
    setState(() => _recent = list);
  }

  Future<void> _clearRecent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRecentKey);
    setState(() => _recent = []);
  }

  void _search(String q) {
    final trimmed = q.trim();
    if (trimmed.isEmpty) return;
    _saveRecent(trimmed);
    setState(() => _query = trimmed);
    _ctrl.text = trimmed;
    _focus.unfocus();
  }

  List<Listing> _results(List<Listing> all) {
    var list = all.where((l) {
      final q = _query.toLowerCase();
      final matchQ = l.title.toLowerCase().contains(q) ||
          l.description.toLowerCase().contains(q) ||
          l.location.toLowerCase().contains(q);
      final matchPrice = l.price >= _minPrice && l.price <= _maxPrice;
      return matchQ && matchPrice;
    }).toList();

    switch (_sortBy) {
      case 'cheapest':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'expensive':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      default: // newest — keep original order
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final l = AppLocalizations.of(context);
    final results = _query.isEmpty ? <Listing>[] : _results(state.listings);
    final showResults = _query.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar ─────────────────────────────────────────
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.arrow_back_rounded,
                          color: AppColors.textPrimary, size: 22),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        focusNode: _focus,
                        onChanged: (v) {
                          if (v.isEmpty) setState(() => _query = '');
                        },
                        onSubmitted: _search,
                        style: GoogleFonts.inter(
                            fontSize: 14, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: l.searchHint,
                          hintStyle: GoogleFonts.inter(
                              fontSize: 13, color: AppColors.textHint),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.textHint, size: 20),
                          suffixIcon: _query.isNotEmpty || _ctrl.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _ctrl.clear();
                                    setState(() => _query = '');
                                    _focus.requestFocus();
                                  },
                                  child: const Icon(Icons.close_rounded,
                                      size: 18, color: AppColors.textHint),
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showFilterSheet(context),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.tune_rounded,
                          color: AppColors.onPrimary, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: AppColors.border),

            // ── Body ───────────────────────────────────────────────
            Expanded(
              child: showResults
                  ? _ResultsView(
                      results: results,
                      query: _query,
                      state: state,
                    )
                  : _SuggestionsView(
                      recent: _recent,
                      onSearch: _search,
                      onClearRecent: _clearRecent,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        condition: _condition,
        sortBy: _sortBy,
        onApply: (min, max, cond, sort) {
          setState(() {
            _minPrice = min;
            _maxPrice = max;
            _condition = cond;
            _sortBy = sort;
          });
          Navigator.pop(context);
          if (_query.isNotEmpty) setState(() {});
        },
      ),
    );
  }
}

// ── Suggestions view ──────────────────────────────────────────

class _SuggestionsView extends StatelessWidget {
  final List<String> recent;
  final ValueChanged<String> onSearch;
  final VoidCallback onClearRecent;
  const _SuggestionsView(
      {required this.recent,
      required this.onSearch,
      required this.onClearRecent});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        // Recent
        if (recent.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text(l.recentSearches,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ),
              GestureDetector(
                onTap: onClearRecent,
                child: Text(l.clearBtn,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recent
                .map((q) => _SearchChip(
                    label: q,
                    icon: Icons.history_rounded,
                    onTap: () => onSearch(q)))
                .toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Popular
        Text(l.popularSearches,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _kPopular
              .map((q) => _SearchChip(
                  label: q,
                  icon: Icons.trending_up_rounded,
                  accent: true,
                  onTap: () => onSearch(q)))
              .toList(),
        ),
      ],
    );
  }
}

class _SearchChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool accent;
  final VoidCallback onTap;
  const _SearchChip({
    required this.label,
    required this.icon,
    this.accent = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: accent
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color:
                  accent ? AppColors.primary.withValues(alpha: 0.2) : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 13,
                color: accent ? AppColors.primary : AppColors.textHint),
            const SizedBox(width: 5),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: accent ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Results view ──────────────────────────────────────────────

class _ResultsView extends StatelessWidget {
  final List<Listing> results;
  final String query;
  final AppState state;
  const _ResultsView(
      {required this.results, required this.query, required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 48, color: AppColors.textHint),
            const SizedBox(height: 14),
            Text(l.searchNotFound(query),
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(l.tryAnotherKeyword,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text('"$query"',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ),
              Text(l.resultsCount(results.length),
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: results.length,
            itemBuilder: (ctx, i) {
              final l = results[i];
              return ListingRow(
                listing: l,
                onTap: () => Navigator.of(ctx).push(MaterialPageRoute(
                    builder: (_) => ListingDetailScreen(listingId: l.id))),
                onFavoriteTap: () => state.toggleFavorite(l.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Filter bottom sheet ───────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final double minPrice;
  final double maxPrice;
  final String condition;
  final String sortBy;
  final void Function(double, double, String, String) onApply;
  const _FilterSheet({
    required this.minPrice,
    required this.maxPrice,
    required this.condition,
    required this.sortBy,
    required this.onApply,
  });
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late double _min, _max;
  late String _cond, _sort;
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _min = widget.minPrice;
    _max = widget.maxPrice;
    _cond = widget.condition;  // 'all' | 'new' | 'used'
    _sort = widget.sortBy;     // 'newest' | 'cheapest' | 'expensive'
    _minCtrl.text = _min.toInt().toString();
    _maxCtrl.text = _max.toInt().toString();
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 8, bottom: 20),
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(l.filterTitle,
                style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 20),

            // Price range
            Text(l.priceRange,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            RangeSlider(
              values: RangeValues(_min, _max),
              min: 0,
              max: 200000,
              divisions: 400,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.border,
              onChanged: (v) {
                setState(() {
                  _min = v.start;
                  _max = v.end;
                  _minCtrl.text = v.start.toInt().toString();
                  _maxCtrl.text = v.end.toInt().toString();
                });
              },
            ),
            Row(
              children: [
                Expanded(
                  child: _PriceInput(
                    label: l.priceFrom,
                    ctrl: _minCtrl,
                    onChanged: (v) =>
                        setState(() => _min = double.tryParse(v) ?? _min),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PriceInput(
                    label: l.priceTo,
                    ctrl: _maxCtrl,
                    onChanged: (v) =>
                        setState(() => _max = double.tryParse(v) ?? _max),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Condition
            Text(l.conditionLabel,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            _ChipRow(
              keys: const ['all', 'new', 'used'],
              labels: [l.conditionAll, l.conditionNew, l.conditionUsed],
              selected: _cond,
              onSelect: (v) => setState(() => _cond = v),
            ),
            const SizedBox(height: 20),

            // Sort
            Text(l.sortLabel,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            _ChipRow(
              keys: const ['newest', 'cheapest', 'expensive'],
              labels: [l.sortNewest, l.sortCheapest, l.sortExpensive],
              selected: _sort,
              onSelect: (v) => setState(() => _sort = v),
            ),
            const SizedBox(height: 24),

            // Apply button
            GestureDetector(
              onTap: () => widget.onApply(_min, _max, _cond, _sort),
              child: Container(
                height: 52,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 5)),
                  ],
                ),
                child: Center(
                  child: Text(l.showResultsBtn,
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimary)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceInput extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final ValueChanged<String> onChanged;
  const _PriceInput(
      {required this.label, required this.ctrl, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          style: GoogleFonts.inter(
              fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.surfaceAlt,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
      ],
    );
  }
}

class _ChipRow extends StatelessWidget {
  final List<String> keys;
  final List<String> labels;
  final String selected;
  final ValueChanged<String> onSelect;
  const _ChipRow({
    required this.keys,
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(keys.length, (i) {
        final key = keys[i];
        final label = labels[i];
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onSelect(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: selected == key
                    ? AppColors.primary
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: selected == key
                        ? AppColors.primary
                        : AppColors.border),
              ),
              child: Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: selected == key
                          ? AppColors.onPrimary
                          : AppColors.textPrimary)),
            ),
          ),
        );
      }),
    );
  }
}
