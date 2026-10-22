import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import '../app/theme.dart';

/// True under `flutter test` — used to skip live cameras and infinite
/// animations that would never let pumpAndSettle finish.
final bool isTestEnv = Platform.environment.containsKey('FLUTTER_TEST');

/// Platform-adaptive widgets (design handoff spec §2, §6). iOS gets the
/// Cupertino-flavoured variant (sliding segmented, 34px titles, 16-radius
/// buttons, hairline cards), Android the Material 3 variant (outlined
/// segmented, 26px titles in a 64px row, pill buttons, tonal containers).
bool isIos(BuildContext context) => Theme.of(context).platform == TargetPlatform.iOS;

double cardRadius(BuildContext context) => isIos(context) ? AppSizes.cardRadiusIos : AppSizes.cardRadiusAndroid;
double buttonRadius(BuildContext context) => isIos(context) ? AppSizes.buttonRadiusIos : AppSizes.buttonRadiusAndroid;
double inputRadius(BuildContext context) => isIos(context) ? AppSizes.inputRadiusIos : AppSizes.inputRadiusAndroid;
double touchTarget(BuildContext context) => isIos(context) ? AppSizes.touchIos : AppSizes.touchAndroid;

/// Hairline colour: iOS #E3EBE5, Android cards #CBD5CD.
Color outlineColor(BuildContext context) => isIos(context) ? AppColors.border : AppColors.borderStrong;

/// Page title style: 34px on iOS, 26px on Android.
TextStyle? pageTitleStyle(BuildContext context) {
  final text = Theme.of(context).textTheme;
  return isIos(context) ? text.headlineLarge : text.headlineMedium;
}

/// Big screen header used on the five tabs. iOS: title (34) + optional
/// subtitle, optional trailing on the baseline row. Android: 64px row with
/// title (26) + optional trailing, subtitle sits below.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final titleWidget = Semantics(header: true, child: Text(title, style: pageTitleStyle(context)));

    if (isIos(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [titleWidget, ?trailing],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: text.bodyMedium?.copyWith(color: AppColors.textMuted)),
          ],
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.only(left: 4),
          alignment: Alignment.centerLeft,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [titleWidget, ?trailing],
          ),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(subtitle!, style: text.bodyMedium?.copyWith(color: AppColors.textMuted)),
          ),
      ],
    );
  }
}

/// Card per platform: white, hairline border, iOS radius 20 / Android 16.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding, this.onTap, this.radius});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final r = radius ?? cardRadius(context);
    final decoration = BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(r),
      border: Border.all(color: outlineColor(context)),
    );
    if (onTap == null) {
      return Container(decoration: decoration, padding: padding, child: child);
    }
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: decoration,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(r),
          child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ),
      ),
    );
  }
}

/// Section title inside result cards etc. — Bricolage 18 with optional icon.
class CardTitle extends StatelessWidget {
  const CardTitle({super.key, required this.title, this.icon, this.iconColor, this.trailing});

  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: isIos(context) ? 20 : 22, color: iconColor ?? AppColors.primary),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
          ?trailing,
        ],
      ),
    );
  }
}

/// Small pill marking a plan-gated section ("Pro Max", "Pro+").
class PlanBadge extends StatelessWidget {
  const PlanBadge({super.key, required this.label, this.onDark = false});

  final String label;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final ios = isIos(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ios ? 9 : 8, vertical: 3),
      decoration: BoxDecoration(
        color: onDark ? AppColors.accent.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(ios ? 999 : 8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: onDark ? AppColors.accent : AppColors.primary,
        ),
      ),
    );
  }
}

/// Primary action button: iOS radius 16 height 54 (17/w700), Android pill
/// radius 26 height 52 with a soft shadow (16/w600).
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({super.key, required this.label, this.icon, this.onPressed, this.busy = false});

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final ios = isIos(context);
    final effective = busy ? null : onPressed;
    final child = busy
        ? const SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onPrimary),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: ios ? 20 : 22), SizedBox(width: ios ? 8 : 10)],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );
    return SizedBox(
      width: double.infinity,
      height: ios ? 54 : 52,
      child: FilledButton(
        onPressed: effective,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.45),
          disabledForegroundColor: AppColors.onPrimary,
          elevation: ios ? 0 : 1,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius(context))),
          textStyle: TextStyle(fontFamily: AppFonts.body, fontSize: ios ? 17 : 16, fontWeight: ios ? FontWeight.w700 : FontWeight.w600),
        ),
        child: child,
      ),
    );
  }
}

/// Accent (leaf-green) button: "Open body map", "Upgrade". #72D66F with
/// dark-green text.
class AppAccentButton extends StatelessWidget {
  const AppAccentButton({super.key, required this.label, this.icon, this.onPressed, this.expand = true});

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final ios = isIos(context);
    final button = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.45),
        disabledForegroundColor: AppColors.onAccent,
        minimumSize: Size(0, ios ? 48 : 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ios ? 14 : 24)),
        textStyle: TextStyle(fontFamily: AppFonts.body, fontSize: ios ? 15 : 15, fontWeight: ios ? FontWeight.w700 : FontWeight.w600),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Tonal button (Android "I ate this": #CDEFCB / #0A2E17). On iOS the same
/// action uses [AppPrimaryButton]; this widget picks per platform.
class AppTonalButton extends StatelessWidget {
  const AppTonalButton({super.key, required this.label, this.icon, this.onPressed, this.expand = false});

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final ios = isIos(context);
    final button = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: ios ? AppColors.primary : AppColors.tonal,
        foregroundColor: ios ? AppColors.onPrimary : AppColors.onTonal,
        disabledBackgroundColor: (ios ? AppColors.primary : AppColors.tonal).withValues(alpha: 0.5),
        disabledForegroundColor: ios ? AppColors.onPrimary : AppColors.onTonal,
        minimumSize: Size(0, ios ? 44 : 48),
        padding: EdgeInsets.symmetric(horizontal: ios ? 16 : 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ios ? 12 : 24)),
        textStyle: TextStyle(fontFamily: AppFonts.body, fontSize: 14, fontWeight: ios ? FontWeight.w700 : FontWeight.w600),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Outlined action: iOS 1.5px primary border radius 14, Android 1px
/// #6F7A72 pill with primary text.
class AppOutlinedAction extends StatelessWidget {
  const AppOutlinedAction({super.key, required this.label, this.icon, this.onPressed, this.expand = true});

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final ios = isIos(context);
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: Size(0, ios ? 48 : 48),
        side: BorderSide(color: ios ? AppColors.primary : AppColors.inputOutline, width: ios ? 1.5 : 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ios ? 14 : 24)),
        textStyle: TextStyle(fontFamily: AppFonts.body, fontSize: 15, fontWeight: ios ? FontWeight.w700 : FontWeight.w600),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Mode selector: iOS sliding segmented (track #E8EFEA, white pill),
/// Android outlined segmented (border #6F7A72, selected #CDEFCB + check).
class AppSegmented<T> extends StatelessWidget {
  const AppSegmented({super.key, required this.options, required this.selected, required this.onChanged});

  /// (value, label, optional icon) per segment.
  final List<(T, String, IconData?)> options;

  /// The selected value; null renders nothing selected (e.g. feedback's
  /// buy-again before the user answers).
  final T? selected;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final ios = isIos(context);
    if (!ios) {
      return SizedBox(
        // 48 keeps the Android minimum touch target (mockup shows 44).
        height: 48,
        child: SegmentedButton<T>(
          segments: [
            for (final (value, label, icon) in options)
              ButtonSegment(
                value: value,
                icon: icon == null ? null : Icon(icon, size: 18),
                label: Text(label, overflow: TextOverflow.ellipsis),
              ),
          ],
          emptySelectionAllowed: true,
          selected: {if (selected != null) selected!},
          showSelectedIcon: true,
          selectedIcon: const Icon(Icons.check, size: 18),
          onSelectionChanged: onChanged == null ? null : (s) => onChanged!(s.first),
          style: SegmentedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          ),
        ),
      );
    }
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: AppColors.segmentTrack, borderRadius: BorderRadius.circular(11)),
      child: Row(
        children: [
          for (final (value, label, icon) in options)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onChanged == null || value == selected ? null : () => onChanged!(value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: value == selected ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: value == selected
                        ? const [
                            BoxShadow(color: Color(0x24000000), blurRadius: 3, offset: Offset(0, 1)),
                            BoxShadow(color: Color(0x0D000000), blurRadius: 0, spreadRadius: 0.5),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 16, color: value == selected ? AppColors.text : AppColors.textMuted),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 13,
                            fontWeight: value == selected ? FontWeight.w700 : FontWeight.w600,
                            color: value == selected ? AppColors.text : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Input decoration per platform: Android outlined (radius 4, #6F7A72),
/// iOS plain card field (radius 14, #E3EBE5 hairline).
InputDecoration appInputDecoration(
  BuildContext context, {
  String? label,
  String? hint,
  IconData? prefixIcon,
  Widget? suffix,
  String? error,
}) {
  final ios = isIos(context);
  final r = BorderRadius.circular(inputRadius(context));
  if (!ios) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: error,
      prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 22, color: AppColors.textMuted),
      suffixIcon: suffix,
    );
  }
  InputBorder border([Color color = AppColors.border, double width = 1]) =>
      OutlineInputBorder(borderRadius: r, borderSide: BorderSide(color: color, width: width));
  return InputDecoration(
    hintText: hint ?? label,
    errorText: error,
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20, color: AppColors.textMuted),
    suffixIcon: suffix,
    border: border(),
    enabledBorder: border(),
    focusedBorder: border(AppColors.primary, 1.5),
    errorBorder: border(AppColors.danger),
    focusedErrorBorder: border(AppColors.danger, 1.5),
  );
}

/// Field caption above an iOS field (12/w600 muted), e.g. "Or type the
/// number"; on Android the floating label covers this, so render nothing.
class FieldCaption extends StatelessWidget {
  const FieldCaption({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    if (!isIos(context)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Muted 12px helper under a field.
class FieldHelper extends StatelessWidget {
  const FieldHelper({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 6, left: isIos(context) ? 0 : 16, right: isIos(context) ? 0 : 16),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted, height: 1.4),
      ),
    );
  }
}
