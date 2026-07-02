import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../models.dart';
import '../theme.dart';
import 'auto_category_screen.dart';
import 'search_screen.dart';

const _catIcons = {
  'uy-joy': Icons.house_rounded,
  'transport': Icons.directions_car_rounded,
  'elektronika': Icons.devices_rounded,
  'qishloq-texnika': Icons.agriculture_rounded,
  'don-mahsulotlari': Icons.grass_rounded,
  'chorvachilik': Icons.pets_rounded,
  'kiyim': Icons.checkroom_rounded,
  'uy-jihozlari': Icons.chair_rounded,
};

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<AppCategory> get _filtered {
    if (_query.isEmpty) return kCategories;
    return kCategories
        .where((c) => c.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return Scaffold(
      backgroundColor: rc.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.get('categories'),
                      style: spectral(size: 22, weight: FontWeight.w800, color: rc.ink)),
                  const SizedBox(height: 11),
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: rc.card,
                      border: Border.all(color: rc.line),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: TextField(
                      controller: _ctrl,
                      onChanged: (v) => setState(() => _query = v),
                      style: hanken(size: 12.5, color: rc.ink),
                      decoration: InputDecoration(
                        hintText: 'Kategoriya qidirish…',
                        hintStyle: hanken(size: 12.5, color: rc.muted),
                        prefixIcon: Icon(Icons.search_rounded, size: 16, color: rc.muted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 11,
                  crossAxisSpacing: 11,
                  childAspectRatio: 1.5,
                ),
                itemCount: _filtered.length,
                itemBuilder: (ctx, i) {
                  final cat = _filtered[i];
                  return GestureDetector(
                    onTap: () => Navigator.of(ctx).push(MaterialPageRoute(
                      builder: (_) => cat.id == 'transport'
                          ? const AutoCategoryScreen()
                          : SearchScreen(initialCategory: cat.id),
                    )),
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: rc.card,
                        border: Border.all(color: rc.line),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: rc.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(_catIcons[cat.id] ?? Icons.category_rounded,
                                color: rc.accent, size: 22),
                          ),
                          const SizedBox(height: 9),
                          Text(cat.name,
                              style: spectral(size: 13.5, weight: FontWeight.w700, color: rc.ink)),
                          const SizedBox(height: 1),
                          Text("${cat.count} e'lon",
                              style: hanken(size: 10, color: rc.muted)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
