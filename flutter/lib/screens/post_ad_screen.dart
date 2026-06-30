// ============================================================
// screens/post_ad_screen.dart  –  3-step ad posting
// ============================================================
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../app_theme.dart';
import '../l10n/app_localizations.dart';
import '../mock_data.dart';
import '../models.dart';

class PostAdScreen extends StatefulWidget {
  const PostAdScreen({super.key});
  @override
  State<PostAdScreen> createState() => _PostAdScreenState();
}

class _PostAdScreenState extends State<PostAdScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0; // 0=Asosiy, 1=Batafsil, 2=Nashr

  // Step 1 controllers
  final _titleCtrl = TextEditingController();
  String _catId = kCategories.first.id;
  String _subId = kCategories.first.subcategories.first.id;

  // Step 2 controllers
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(text: '+998 90 ');
  final _locationCtrl = TextEditingController(text: 'Toshkent shahar');
  String _currency = 'USD';
  bool _isTop = false;

  // Images
  final List<XFile> _images = [];
  final _picker = ImagePicker();
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  List<AppSubcategory> get _subs =>
      kCategories.firstWhere((c) => c.id == _catId).subcategories;

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    setState(() {
      final canAdd = 10 - _images.length;
      _images.addAll(picked.take(canAdd));
    });
  }

  void _next() {
    if (_step == 0) {
      if (_titleCtrl.text.trim().isEmpty) {
        _showError(AppLocalizations.of(context).titleError);
        return;
      }
    }
    if (_step == 1) {
      if (!_formKey.currentState!.validate()) return;
    }
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _prev() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _loading = false);
    _showSuccess();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg,
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );
  }

  void _showSuccess() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx);
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 42),
              ),
              const SizedBox(height: 18),
              Text(l.adAccepted,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(
                l.adAcceptedBody(_titleCtrl.text.trim()),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(l.backToHome,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onPrimary)),
                  ),
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _step > 0 ? _prev : () => Navigator.of(context).pop(),
        ),
        title: Text(AppLocalizations.of(context).postAdTitle,
            style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Column(
            children: [
              _StepIndicator(current: _step),
              Container(height: 1, color: AppColors.border),
            ],
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: KeyedSubtree(
            key: ValueKey(_step),
            child: [
              _Step1(
                titleCtrl: _titleCtrl,
                catId: _catId,
                subId: _subId,
                subs: _subs,
                images: _images,
                onPickImages: _pickImages,
                onCatChanged: (id) {
                  if (id == null) return;
                  setState(() {
                    _catId = id;
                    _subId = kCategories
                        .firstWhere((c) => c.id == id)
                        .subcategories
                        .first
                        .id;
                  });
                },
                onSubChanged: (id) {
                  if (id != null) setState(() => _subId = id);
                },
                onRemoveImage: (i) =>
                    setState(() => _images.removeAt(i)),
              ),
              _Step2(
                descCtrl: _descCtrl,
                priceCtrl: _priceCtrl,
                phoneCtrl: _phoneCtrl,
                locationCtrl: _locationCtrl,
                currency: _currency,
                onCurrencyChange: (c) => setState(() => _currency = c),
              ),
              _Step3(
                title: _titleCtrl.text,
                price: _priceCtrl.text,
                currency: _currency,
                location: _locationCtrl.text,
                isTop: _isTop,
                onTopChanged: (v) => setState(() => _isTop = v),
              ),
            ][_step],
          ),
        ),
      ),
      bottomNavigationBar: _BottomAction(
        step: _step,
        loading: _loading,
        onNext: _next,
      ),
    );
  }
}

// ── Step indicator ────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current;
  const _StepIndicator({required this.current});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labels = [l.stepBasic, l.stepDetails, l.stepPublish];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector
            final stepIdx = i ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: stepIdx < current
                      ? AppColors.primary
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }
          final idx = i ~/ 2;
          final done = idx < current;
          final active = idx == current;
          return _StepDot(
              index: idx + 1,
              label: labels[idx],
              done: done,
              active: active);
        }),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final String label;
  final bool done;
  final bool active;
  const _StepDot(
      {required this.index,
      required this.label,
      required this.done,
      required this.active});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: done || active ? AppColors.primary : AppColors.surfaceAlt,
            shape: BoxShape.circle,
            border: Border.all(
                color: done || active ? AppColors.primary : AppColors.border,
                width: active ? 2 : 1),
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check_rounded,
                    size: 14, color: Colors.white)
                : Text('$index',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: active
                            ? AppColors.onPrimary
                            : AppColors.textHint)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color:
                    active ? AppColors.primary : AppColors.textSecondary)),
      ],
    );
  }
}

// ── Step 1: Asosiy ───────────────────────────────────────────

class _Step1 extends StatelessWidget {
  final TextEditingController titleCtrl;
  final String catId;
  final String subId;
  final List<AppSubcategory> subs;
  final List<XFile> images;
  final VoidCallback onPickImages;
  final ValueChanged<String?> onCatChanged;
  final ValueChanged<String?> onSubChanged;
  final ValueChanged<int> onRemoveImage;

  const _Step1({
    required this.titleCtrl,
    required this.catId,
    required this.subId,
    required this.subs,
    required this.images,
    required this.onPickImages,
    required this.onCatChanged,
    required this.onSubChanged,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        // Photo upload zone
        _SectionLabel(l.photosLabel),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onPickImages,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.border,
                  style: BorderStyle.solid,
                  width: 1.5),
            ),
            child: images.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo_rounded,
                          color: AppColors.primary, size: 28),
                      const SizedBox(height: 8),
                      Text(l.addPhoto,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary)),
                    ],
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    itemCount:
                        images.length + (images.length < 10 ? 1 : 0),
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: 8),
                    itemBuilder: (ctx, i) {
                      if (i == images.length) {
                        return GestureDetector(
                          onTap: onPickImages,
                          child: Container(
                            width: 80,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(Icons.add_rounded,
                                color: AppColors.primary),
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
        const SizedBox(height: 20),

        // Title
        _SectionLabel(l.titleLabel),
        const SizedBox(height: 8),
        _Field(
          controller: titleCtrl,
          hint: l.titleHint,
        ),
        const SizedBox(height: 20),

        // Category
        _SectionLabel(l.mainCategoryLabel),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showCategorySheet(context, onCatChanged),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Text(
                  kCategories
                          .firstWhere((c) => c.id == catId)
                          .icon +
                      '  ' +
                      kCategories
                          .firstWhere((c) => c.id == catId)
                          .uzName,
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.textPrimary),
                ),
                const Spacer(),
                const Icon(Icons.expand_more_rounded,
                    color: AppColors.textHint),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _SectionLabel(l.subCategoryLabel),
        const SizedBox(height: 8),
        _DropdownField(
          value: subId,
          items: subs
              .map((s) => DropdownMenuItem(
                    value: s.id,
                    child: Text(s.uzName,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textPrimary)),
                  ))
              .toList(),
          onChanged: onSubChanged,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showCategorySheet(
      BuildContext context, ValueChanged<String?> onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Text(AppLocalizations.of(context).selectCategoryTitle,
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            ...kCategories.map((c) => GestureDetector(
                  onTap: () {
                    onSelect(c.id);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(c.icon,
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Text(c.uzName,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary)),
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

// ── Step 2: Batafsil ─────────────────────────────────────────

class _Step2 extends StatelessWidget {
  final TextEditingController descCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController locationCtrl;
  final String currency;
  final ValueChanged<String> onCurrencyChange;

  const _Step2({
    required this.descCtrl,
    required this.priceCtrl,
    required this.phoneCtrl,
    required this.locationCtrl,
    required this.currency,
    required this.onCurrencyChange,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        _SectionLabel(l.descriptionLabel),
        const SizedBox(height: 8),
        _Field(
          controller: descCtrl,
          hint: l.descriptionHint,
          maxLines: 5,
          validator: (v) =>
              (v == null || v.trim().length < 10) ? l.descriptionError : null,
        ),
        const SizedBox(height: 20),

        _SectionLabel(l.priceLabel),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _Field(
                controller: priceCtrl,
                hint: '0',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l.priceError;
                  if (double.tryParse(v.trim()) == null) return l.priceNumberError;
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            // Currency toggle
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: ['USD', "So'm"].map((c) {
                  final sel = currency == c;
                  return GestureDetector(
                    onTap: () => onCurrencyChange(c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(c,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: sel
                                  ? AppColors.onPrimary
                                  : AppColors.textSecondary)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _SectionLabel(l.phoneLabel),
        const SizedBox(height: 8),
        _Field(
          controller: phoneCtrl,
          hint: '+998 90 123 45 67',
          keyboardType: TextInputType.phone,
          validator: (v) =>
              (v == null || v.trim().length < 9) ? l.phoneError : null,
        ),
        const SizedBox(height: 20),

        _SectionLabel(l.locationLabel),
        const SizedBox(height: 8),
        _Field(
          controller: locationCtrl,
          hint: 'Toshkent shahar...',
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? l.locationError : null,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Step 3: Nashr ────────────────────────────────────────────

class _Step3 extends StatelessWidget {
  final String title;
  final String price;
  final String currency;
  final String location;
  final bool isTop;
  final ValueChanged<bool> onTopChanged;

  const _Step3({
    required this.title,
    required this.price,
    required this.currency,
    required this.location,
    required this.isTop,
    required this.onTopChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        // Preview card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: kCardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(l.previewLabel,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(l.readyLabel,
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(title.isEmpty ? l.titlePlaceholder : title,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Text(
                price.isEmpty ? '\$0' : '\$$price $currency',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary),
              ),
              if (location.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 12, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(location,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary)),
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
                colors: AppColors.amberGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.topAdLabel,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text(l.topAdDesc,
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.85))),
                  ],
                ),
              ),
              Switch(
                value: isTop,
                onChanged: onTopChanged,
                activeColor: Colors.white,
                activeTrackColor: Colors.white.withValues(alpha: 0.4),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Bottom action bar ─────────────────────────────────────────

class _BottomAction extends StatelessWidget {
  final int step;
  final bool loading;
  final VoidCallback onNext;
  const _BottomAction(
      {required this.step, required this.loading, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final isLast = step == 2;
    final l = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: GestureDetector(
        onTap: loading ? null : onNext,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.30),
                  blurRadius: 14,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: AppColors.onPrimary, strokeWidth: 2.5))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLast ? l.publishBtn : l.nextBtn,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onPrimary),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isLast
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        size: 18,
                        color: AppColors.onPrimary,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary));
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger, width: 1.5)),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  const _DropdownField(
      {required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
      icon: const Icon(Icons.expand_more_rounded, color: AppColors.textHint),
      dropdownColor: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
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
  late Future<Uint8List> _bytesFuture;
  @override
  void initState() {
    super.initState();
    _bytesFuture = widget.file.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: FutureBuilder<Uint8List>(
              future: _bytesFuture,
              builder: (ctx, snap) {
                if (!snap.hasData) {
                  return Container(color: AppColors.surfaceAlt);
                }
                return Image.memory(snap.data!, fit: BoxFit.cover);
              },
            ),
          ),
          Positioned(
            top: 3,
            right: 3,
            child: GestureDetector(
              onTap: widget.onRemove,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                    color: AppColors.danger, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded,
                    size: 10, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
