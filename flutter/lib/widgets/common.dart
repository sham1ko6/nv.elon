import 'package:flutter/material.dart';
import '../theme.dart';

/// Small spec/attribute chip — e.g. "88 m²", "4 xona".
class RTag extends StatelessWidget {
  final String label;
  final bool active;
  const RTag(this.label, {super.key, this.active = false});

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active ? rc.accent.withValues(alpha: 0.1) : rc.card,
        border: Border.all(color: active ? rc.accent : rc.line),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        style: hanken(
          size: 10.5,
          weight: active ? FontWeight.w700 : FontWeight.w600,
          color: active ? rc.accent : rc.ink,
        ),
      ),
    );
  }
}

/// Uppercase eyebrow / section label, e.g. "NARX ORALIG'I".
class RLabel extends StatelessWidget {
  final String text;
  const RLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return Text(
      text.toUpperCase(),
      style: hanken(size: 11, weight: FontWeight.w700, color: rc.muted)
          .copyWith(letterSpacing: 0.6),
    );
  }
}

/// Full-width accent primary button.
class RPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final double height;
  const RPrimaryButton({super.key, required this.label, this.onTap, this.icon, this.height = 50});

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: rc.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 17), const SizedBox(width: 7)],
            Text(label, style: hanken(size: 13.5, weight: FontWeight.w700, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

/// Outlined secondary button.
class RSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final double height;
  const RSecondaryButton({super.key, required this.label, this.onTap, this.icon, this.height = 46});

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: rc.accent,
          side: BorderSide(color: rc.accent, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 17), const SizedBox(width: 7)],
            Text(label, style: hanken(size: 13, weight: FontWeight.w700, color: rc.accent)),
          ],
        ),
      ),
    );
  }
}

/// Circular avatar with initials on accent background — used for
/// sellers/shops without a photo (e.g. "TR" for Tashkent Realty).
class RInitialsAvatar extends StatelessWidget {
  final String initials;
  final double size;
  const RInitialsAvatar(this.initials, {super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: rc.accent, borderRadius: BorderRadius.circular(size * 0.3)),
      alignment: Alignment.center,
      child: Text(initials, style: spectral(size: size * 0.38, weight: FontWeight.w700, color: Colors.white)),
    );
  }
}

/// Small circular icon button on a translucent card — used for back/share/
/// favorite buttons floating over images.
class RRoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final double size;
  const RRoundIconButton({super.key, required this.icon, this.onTap, this.color, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), blurRadius: 8)],
        ),
        child: Icon(icon, size: size * 0.5, color: color ?? rc.ink),
      ),
    );
  }
}

/// Bottom sheet drag handle bar.
class RDragHandle extends StatelessWidget {
  const RDragHandle({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 4,
      margin: const EdgeInsets.only(bottom: 12, top: 2),
      decoration: BoxDecoration(color: const Color(0xFFD8CAB3), borderRadius: BorderRadius.circular(3)),
    );
  }
}

/// Full-screen empty state — icon in a soft circle, headline, hint, and an
/// optional call-to-action button. Screen 25 "Bo'sh holat".
class REmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const REmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: rc.line.withValues(alpha: 0.6), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, size: 40, color: rc.muted),
          ),
          const SizedBox(height: 22),
          Text(title, textAlign: TextAlign.center, style: spectral(size: 19, weight: FontWeight.w700, color: rc.ink)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: hanken(size: 13, color: rc.muted, height: 1.5)),
          if (actionLabel != null) ...[
            const SizedBox(height: 22),
            RPrimaryButton(label: actionLabel!, onTap: onAction, height: 48),
          ],
        ],
      ),
    );
  }
}

/// Status badge pill — e.g. "Faol", "Ko'rib chiqilmoqda", "Tugagan".
class RStatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const RStatusPill({super.key, required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: hanken(size: 10, weight: FontWeight.w700, color: color)),
    );
  }
}

/// Simple star rating row.
class RStars extends StatelessWidget {
  final double rating;
  final double size;
  const RStars({super.key, required this.rating, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.round();
        return Icon(
          filled ? Icons.star_rounded : Icons.star_border_rounded,
          size: size,
          color: cAmber,
        );
      }),
    );
  }
}

/// Screen header used by secondary (pushed) screens: back button + title,
/// optionally a trailing action.
class RScreenHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? trailing;
  const RScreenHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return Container(
      color: rc.card,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            RRoundIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.of(context).maybePop()),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: spectral(size: 17, weight: FontWeight.w700, color: rc.ink)),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(58);
}
