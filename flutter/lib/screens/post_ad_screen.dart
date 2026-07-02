import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../api.dart' as api;
import '../app_state.dart';
import '../l10n/strings.dart';
import '../models.dart';
import '../theme.dart';
import 'auth_screen.dart';

class PostAdScreen extends StatefulWidget {
  const PostAdScreen({super.key});
  @override
  State<PostAdScreen> createState() => _PostAdScreenState();
}

class _PostAdScreenState extends State<PostAdScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0;

  // Fields
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController(text: 'Toshkent shahar');
  final _phoneCtrl = TextEditingController(text: '+998 ');
  List<Category> _categories = kCategoryFallback;
  Category? _category;
  String _currency = 'USD';
  String _condition = 'used';
  bool _isTop = false;
  bool _loading = false;

  final List<XFile> _images = [];
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _category = _categories.first;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await api.getCategories();
      if (!mounted || cats.isEmpty) return;
      setState(() {
        _categories = cats;
        _category = cats.first;
      });
    } catch (_) {
      // Keep the fallback list (matches the real seeded ids) so posting
      // still works with a valid category_id even if this call fails.
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    setState(() => _images.addAll(picked.take(10 - _images.length)));
  }

  void _next() {
    if (_step == 0) {
      if (_titleCtrl.text.trim().isEmpty) {
        _snack('Sarlavha kiriting');
        return;
      }
    } else if (_step == 1) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
    }
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    final state = AppStateScope.of(context);

    if (!state.isLoggedIn) {
      _snack("E'lon joylash uchun avval tizimga kiring");
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
      return;
    }

    final category = _category;
    if (category == null) {
      _snack('Kategoriya yuklanmadi, birozdan so\'ng qayta urining');
      return;
    }

    // Backend requires +998XXXXXXXXX with no spaces.
    final contactPhone = _phoneCtrl.text.replaceAll(RegExp(r'\s'), '');
    if (!RegExp(r'^\+998\d{9}$').hasMatch(contactPhone)) {
      setState(() => _step = 1);
      _snack("Telefon raqami formati noto'g'ri (+998XXXXXXXXX)");
      return;
    }

    final price = double.tryParse(_priceCtrl.text.trim());
    if (price == null || price <= 0) {
      setState(() => _step = 1);
      _snack("Narx to'g'ri kiritilmagan");
      return;
    }

    setState(() => _loading = true);

    final body = {
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price': price,
      'currency': _currency,
      'category_id': category.id,
      'location': _locationCtrl.text.trim(),
      'contact_phone': contactPhone,
    };

    final token = state.token!;
    try {
      final res = await api.postListing(body, token);
      final listing = res['listing'] as Map<String, dynamic>?;
      final listingId = listing?['id']?.toString();
      final orderId = res['order_id'];

      String? imageError;
      if (listingId != null && _images.isNotEmpty) {
        try {
          await api.uploadListingImages(listingId, _images, token);
        } catch (e) {
          imageError = e.toString().replaceFirst('Exception: ', '');
        }
      }

      if (!mounted) return;
      setState(() => _loading = false);
      _showSuccess(pendingPayment: orderId != null, imageError: imageError);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.hankenGrotesk(color: Colors.white)),
      backgroundColor: cAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showSuccess({bool pendingPayment = false, String? imageError}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final rc = RC.of(ctx);
        return AlertDialog(
          backgroundColor: rc.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68, height: 68,
                decoration: BoxDecoration(
                    color: const Color(0xFF22A06B).withValues(alpha: 0.12),
                    shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF22A06B), size: 40),
              ),
              const SizedBox(height: 16),
              Text(S.get('adPosted'),
                  style: GoogleFonts.spectral(
                      fontSize: 20, fontWeight: FontWeight.w700, color: rc.ink)),
              const SizedBox(height: 8),
              Text(
                  pendingPayment
                      ? "E'lon saqlandi. U ro'yxatda ko'rinishi uchun joylashtirish to'lovini amalga oshiring (Profil → To'lovlar tarixi)."
                      : S.get('adPostedHint'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.hankenGrotesk(
                      fontSize: 13, color: rc.muted, height: 1.5)),
              if (imageError != null) ...[
                const SizedBox(height: 8),
                Text("Rasmlarni yuklashda xatolik: $imageError",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.hankenGrotesk(fontSize: 12, color: Colors.red)),
              ],
              const SizedBox(height: 22),
              GestureDetector(
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: 48, width: double.infinity,
                  decoration: BoxDecoration(
                      color: cAccent, borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text(S.get('backHome'),
                      style: GoogleFonts.hankenGrotesk(
                          fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    final steps = [S.get('basicInfo'), S.get('details'), S.get('preview')];
    return Scaffold(
      backgroundColor: rc.bg,
      appBar: AppBar(
        backgroundColor: rc.card,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: rc.ink, size: 18),
          onPressed: _step > 0 ? () => setState(() => _step--) : () => Navigator.pop(context),
        ),
        title: Text(S.get('postAd'),
            style: GoogleFonts.spectral(fontSize: 18, fontWeight: FontWeight.w700, color: rc.ink)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Column(
            children: [
              _StepBar(step: _step, steps: steps, rc: rc),
              Container(height: 1, color: rc.line),
            ],
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: KeyedSubtree(
            key: ValueKey(_step),
            child: _step == 0
                ? _Step1(
                    images: _images,
                    onPickImages: _pickImages,
                    onRemoveImage: (i) => setState(() => _images.removeAt(i)),
                    titleCtrl: _titleCtrl,
                    category: _category,
                    onCatTap: () => _showCategorySheet(context),
                    rc: rc,
                  )
                : _step == 1
                    ? _Step2(
                        descCtrl: _descCtrl,
                        priceCtrl: _priceCtrl,
                        locationCtrl: _locationCtrl,
                        phoneCtrl: _phoneCtrl,
                        currency: _currency,
                        onCurrencyChange: (c) => setState(() => _currency = c),
                        condition: _condition,
                        onConditionChange: (c) => setState(() => _condition = c),
                        rc: rc,
                      )
                    : _Step3(
                        title: _titleCtrl.text,
                        price: _priceCtrl.text,
                        currency: _currency,
                        location: _locationCtrl.text,
                        category: _category,
                        isTop: _isTop,
                        onTopChanged: (v) => setState(() => _isTop = v),
                        rc: rc,
                      ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: rc.card,
          border: Border(top: BorderSide(color: rc.line)),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: cAccent))
            : GestureDetector(
                onTap: _next,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: cAccent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(
                      color: cAccent.withValues(alpha: 0.35),
                      blurRadius: 14, offset: const Offset(0, 6))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _step == 2 ? S.get('publish') : S.get('next'),
                        style: GoogleFonts.hankenGrotesk(
                            fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _step == 2 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                        size: 18, color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void _showCategorySheet(BuildContext context) {
    final rc = RC.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: rc.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4, margin: const EdgeInsets.only(top: 8, bottom: 16),
                decoration: BoxDecoration(color: rc.line, borderRadius: BorderRadius.circular(2))),
            Text(S.get('selectCategory'),
                style: GoogleFonts.spectral(
                    fontSize: 18, fontWeight: FontWeight.w700, color: rc.ink)),
            const SizedBox(height: 14),
            ..._categories.map((c) => GestureDetector(
              onTap: () { setState(() => _category = c); Navigator.pop(context); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: _category?.id == c.id ? cAccent.withValues(alpha: 0.08) : rc.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _category?.id == c.id ? cAccent : rc.line),
                ),
                child: Row(
                  children: [
                    Text(c.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text(c.nameUz, style: GoogleFonts.hankenGrotesk(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: _category?.id == c.id ? cAccent : rc.ink)),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// ── Step bar ──────────────────────────────────────────────────

class _StepBar extends StatelessWidget {
  final int step;
  final List<String> steps;
  final RC rc;
  const _StepBar({required this.step, required this.steps, required this.rc});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: i ~/ 2 < step ? cAccent : rc.line,
              ),
            );
          }
          final idx = i ~/ 2;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 26, height: 26,
                decoration: BoxDecoration(
                  color: idx <= step ? cAccent : rc.card,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: idx <= step ? cAccent : rc.line,
                    width: idx == step ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: idx < step
                      ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                      : Text('${idx + 1}',
                          style: GoogleFonts.hankenGrotesk(
                              fontSize: 11, fontWeight: FontWeight.w700,
                              color: idx == step ? Colors.white : rc.muted)),
                ),
              ),
              const SizedBox(height: 3),
              Text(steps[idx],
                  style: GoogleFonts.hankenGrotesk(
                      fontSize: 9,
                      fontWeight: idx == step ? FontWeight.w700 : FontWeight.w400,
                      color: idx == step ? cAccent : rc.muted)),
            ],
          );
        }),
      ),
    );
  }
}

// ── Step 1: Basic info ────────────────────────────────────────

class _Step1 extends StatelessWidget {
  final List<XFile> images;
  final VoidCallback onPickImages;
  final ValueChanged<int> onRemoveImage;
  final TextEditingController titleCtrl;
  final Category? category;
  final VoidCallback onCatTap;
  final RC rc;
  const _Step1({
    required this.images, required this.onPickImages, required this.onRemoveImage,
    required this.titleCtrl, required this.category, required this.onCatTap, required this.rc,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Photos
        _Label(S.get('addPhoto'), rc: rc),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPickImages,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: rc.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: rc.line),
            ),
            child: images.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_rounded, color: cAccent, size: 26),
                      const SizedBox(height: 8),
                      Text(S.get('addPhoto'),
                          style: GoogleFonts.hankenGrotesk(
                              fontSize: 13, color: rc.muted)),
                    ],
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(10),
                    itemCount: images.length + (images.length < 10 ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      if (i == images.length) {
                        return GestureDetector(
                          onTap: onPickImages,
                          child: Container(
                            width: 74,
                            decoration: BoxDecoration(
                              color: rc.bg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: rc.line),
                            ),
                            child: Icon(Icons.add_rounded, color: cAccent),
                          ),
                        );
                      }
                      return _ImageThumb(
                        key: ValueKey(images[i].path),
                        file: images[i],
                        onRemove: () => onRemoveImage(i),
                      );
                    },
                  ),
          ),
        ),
        const SizedBox(height: 18),
        // Title
        _Label(S.get('title'), rc: rc),
        const SizedBox(height: 8),
        _Field(ctrl: titleCtrl, hint: 'Masalan: Traktor John Deere', rc: rc),
        const SizedBox(height: 18),
        // Category
        _Label(S.get('categories'), rc: rc),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onCatTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: rc.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: rc.line),
            ),
            child: Row(
              children: [
                Text(category?.icon ?? '📦', style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Text(category?.nameUz ?? "Kategoriya tanlanmagan",
                    style: GoogleFonts.hankenGrotesk(fontSize: 14, color: rc.ink)),
                const Spacer(),
                Icon(Icons.expand_more_rounded, color: rc.muted),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Step 2: Details ───────────────────────────────────────────

class _Step2 extends StatelessWidget {
  final TextEditingController descCtrl, priceCtrl, locationCtrl, phoneCtrl;
  final String currency, condition;
  final ValueChanged<String> onCurrencyChange, onConditionChange;
  final RC rc;
  const _Step2({
    required this.descCtrl, required this.priceCtrl,
    required this.locationCtrl, required this.phoneCtrl,
    required this.currency, required this.onCurrencyChange,
    required this.condition, required this.onConditionChange,
    required this.rc,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Label(S.get('description'), rc: rc),
        const SizedBox(height: 8),
        _Field(ctrl: descCtrl, hint: "Mahsulot haqida yozing...", maxLines: 4, rc: rc,
            validator: (v) => (v?.trim().length ?? 0) < 10 ? 'Kamida 10 belgi' : null),
        const SizedBox(height: 18),
        _Label(S.get('price'), rc: rc),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _Field(ctrl: priceCtrl, hint: '0',
                  keyboardType: TextInputType.number, rc: rc,
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Narx kiriting' : null),
            ),
            const SizedBox(width: 10),
            // Currency toggle
            Container(
              height: 50,
              decoration: BoxDecoration(
                  color: rc.card, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: rc.line)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: ['USD', "So'm"].map((c) {
                  final sel = currency == c || (c == "So'm" && currency == 'UZS');
                  return GestureDetector(
                    onTap: () => onCurrencyChange(c == "So'm" ? 'UZS' : 'USD'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? cAccent : Colors.transparent,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(c,
                          style: GoogleFonts.hankenGrotesk(
                              fontSize: 13, fontWeight: FontWeight.w700,
                              color: sel ? Colors.white : rc.muted)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        // Condition
        _Label(S.get('condition'), rc: rc),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final c in [('used', S.get('conditionUsed')), ('new', S.get('conditionNew'))])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onConditionChange(c.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: condition == c.$1 ? cAccent : rc.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: condition == c.$1 ? cAccent : rc.line),
                    ),
                    child: Text(c.$2,
                        style: GoogleFonts.hankenGrotesk(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: condition == c.$1 ? Colors.white : rc.ink)),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        _Label(S.get('location'), rc: rc),
        const SizedBox(height: 8),
        _Field(ctrl: locationCtrl, hint: 'Toshkent shahar...', rc: rc),
        const SizedBox(height: 18),
        _Label(S.get('phone'), rc: rc),
        const SizedBox(height: 8),
        _Field(ctrl: phoneCtrl, hint: '+998 90 123 45 67',
            keyboardType: TextInputType.phone, rc: rc),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Step 3: Preview ───────────────────────────────────────────

class _Step3 extends StatelessWidget {
  final String title, price, currency, location;
  final Category? category;
  final bool isTop;
  final ValueChanged<bool> onTopChanged;
  final RC rc;
  const _Step3({
    required this.title, required this.price, required this.currency,
    required this.location, required this.category,
    required this.isTop, required this.onTopChanged, required this.rc,
  });

  @override
  Widget build(BuildContext context) {
    final displayPrice = price.isNotEmpty
        ? (currency == 'USD' ? '\$$price' : '$price so\'m')
        : '—';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Preview card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: rc.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: rc.line),
            boxShadow: warmShadow(rc.dark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(S.get('preview'),
                      style: GoogleFonts.hankenGrotesk(
                          fontSize: 11, fontWeight: FontWeight.w600, color: rc.muted)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22A06B).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Tayyor', style: GoogleFonts.hankenGrotesk(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: const Color(0xFF22A06B))),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(category?.icon ?? '📦', style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(category?.nameUz ?? '', style: GoogleFonts.hankenGrotesk(
                      fontSize: 11, color: cAccent, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              Text(title.isEmpty ? S.get('title') : title,
                  style: GoogleFonts.spectral(
                      fontSize: 17, fontWeight: FontWeight.w700, color: rc.ink)),
              const SizedBox(height: 6),
              Text(displayPrice,
                  style: GoogleFonts.spectral(
                      fontSize: 22, fontWeight: FontWeight.w700, color: rc.accent)),
              if (location.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 12, color: rc.muted),
                    const SizedBox(width: 4),
                    Text(location, style: GoogleFonts.hankenGrotesk(fontSize: 12, color: rc.muted)),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        // TOP upgrade card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2C1810), Color(0xFF3D2410)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.star_rounded, color: cAmber, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.get('topUpgrade'),
                        style: GoogleFonts.hankenGrotesk(
                            fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text(S.get('topUpgradeDesc'),
                        style: GoogleFonts.hankenGrotesk(
                            fontSize: 11, color: Colors.white.withValues(alpha: 0.75))),
                  ],
                ),
              ),
              Switch(
                value: isTop,
                onChanged: onTopChanged,
                activeColor: cAmber,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                inactiveThumbColor: Colors.white,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Shared ────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  final RC rc;
  const _Label(this.text, {required this.rc});
  @override
  Widget build(BuildContext context) => Text(text,
      style: GoogleFonts.hankenGrotesk(
          fontSize: 13, fontWeight: FontWeight.w700, color: rc.ink));
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final RC rc;
  const _Field({
    required this.ctrl, required this.hint, this.maxLines = 1,
    this.keyboardType = TextInputType.text, this.validator, required this.rc,
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.hankenGrotesk(fontSize: 14, color: rc.ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.hankenGrotesk(fontSize: 13, color: rc.muted),
        filled: true,
        fillColor: rc.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: rc.line)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: cAccent, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      ),
    );
  }
}

class _ImageThumb extends StatefulWidget {
  final XFile file;
  final VoidCallback onRemove;
  const _ImageThumb({super.key, required this.file, required this.onRemove});
  @override
  State<_ImageThumb> createState() => _ImageThumbState();
}

class _ImageThumbState extends State<_ImageThumb> {
  late Future<Uint8List> _bytes;
  @override
  void initState() {
    super.initState();
    _bytes = widget.file.readAsBytes();
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: FutureBuilder<Uint8List>(
              future: _bytes,
              builder: (_, snap) => snap.hasData
                  ? Image.memory(snap.data!, fit: BoxFit.cover)
                  : Container(color: cLine),
            ),
          ),
          Positioned(
            top: 3, right: 3,
            child: GestureDetector(
              onTap: widget.onRemove,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: cAccent, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded, size: 9, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
