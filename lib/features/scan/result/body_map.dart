import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../domain/organs.dart';
import '../../../domain/scan_result.dart';
import '../../../l10n/strings.dart';
import '../../../widgets/adaptive.dart';
import '../../plans/plans_sheet.dart';
import 'result_widgets.dart';

/// Organ shapes on a front-facing silhouette, in a 1 × 2 normalised box.
/// Anatomical front view: the subject's left is the viewer's RIGHT, so the
/// heart and stomach sit right of centre and the liver left of centre.
abstract final class BodyGeometry {
  static const aspect = 0.5; // width / height

  static Rect _r(double cx, double cy, double w, double h) => Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);

  /// Paint order (back to front). Hit-testing walks it in reverse.
  static final Map<Organ, List<Rect>> organs = {
    Organ.skin: [_r(0.225, 0.40, 0.09, 0.12), _r(0.775, 0.40, 0.09, 0.12)],
    Organ.bones: [_r(0.40, 0.70, 0.06, 0.17), _r(0.60, 0.70, 0.06, 0.17), _r(0.40, 0.88, 0.05, 0.12), _r(0.60, 0.88, 0.05, 0.12)],
    Organ.lungs: [_r(0.41, 0.27, 0.13, 0.13), _r(0.59, 0.27, 0.13, 0.13)],
    Organ.intestines: [_r(0.50, 0.505, 0.26, 0.085)],
    Organ.liver: [_r(0.42, 0.37, 0.16, 0.055)],
    Organ.stomach: [_r(0.585, 0.385, 0.11, 0.055)],
    Organ.kidneys: [_r(0.40, 0.45, 0.06, 0.045), _r(0.60, 0.45, 0.06, 0.045)],
    Organ.pancreas: [_r(0.52, 0.425, 0.14, 0.022)],
    Organ.heart: [_r(0.555, 0.29, 0.09, 0.065)],
    Organ.throat: [_r(0.50, 0.158, 0.07, 0.028)],
    Organ.teeth: [_r(0.50, 0.122, 0.08, 0.016)],
    Organ.eyes: [_r(0.46, 0.09, 0.045, 0.02), _r(0.54, 0.09, 0.045, 0.02)],
    Organ.brain: [_r(0.50, 0.058, 0.16, 0.055)],
  };

  static Path silhouette(Size size) {
    Rect s(Rect r) => Rect.fromLTRB(r.left * size.width, r.top * size.height, r.right * size.width, r.bottom * size.height);
    final radius = Radius.circular(size.width * 0.06);
    return Path()
      ..addOval(s(_r(0.50, 0.08, 0.24, 0.12)))
      ..addRect(s(const Rect.fromLTRB(0.45, 0.13, 0.55, 0.18)))
      ..addRRect(RRect.fromRectAndRadius(s(const Rect.fromLTRB(0.30, 0.17, 0.70, 0.58)), radius))
      ..addRRect(RRect.fromRectAndRadius(s(const Rect.fromLTRB(0.17, 0.19, 0.28, 0.56)), radius))
      ..addRRect(RRect.fromRectAndRadius(s(const Rect.fromLTRB(0.72, 0.19, 0.83, 0.56)), radius))
      ..addOval(s(_r(0.225, 0.585, 0.09, 0.045)))
      ..addOval(s(_r(0.775, 0.585, 0.09, 0.045)))
      ..addRRect(RRect.fromRectAndRadius(s(const Rect.fromLTRB(0.32, 0.56, 0.48, 0.97)), radius))
      ..addRRect(RRect.fromRectAndRadius(s(const Rect.fromLTRB(0.52, 0.56, 0.68, 0.97)), radius));
  }

  static Rect scaled(Rect r, Size size) =>
      Rect.fromLTRB(r.left * size.width, r.top * size.height, r.right * size.width, r.bottom * size.height);

  /// The highlighted organ under [point], front-most first.
  static Organ? hitTest(Offset point, Size size, Set<Organ> highlighted) {
    for (final entry in organs.entries.toList().reversed) {
      if (!highlighted.contains(entry.key)) continue;
      for (final rect in entry.value) {
        // Generous touch area around small organs.
        if (scaled(rect, size).inflate(6).contains(point)) return entry.key;
      }
    }
    return null;
  }
}

Color harmColor(Severity s) => severityColor(s);

Color benefitColor(Severity s) => switch (s) {
      Severity.low => AppColors.benefitLow,
      Severity.medium => AppColors.benefitMedium,
      Severity.high => AppColors.benefitHigh,
    };

class _SilhouettePainter extends CustomPainter {
  _SilhouettePainter({required this.fills});

  final Map<Organ, Color> fills;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(BodyGeometry.silhouette(size), Paint()..color = AppColors.surfaceMuted);
    canvas.drawPath(
      BodyGeometry.silhouette(size),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = AppColors.border,
    );
    final faint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.textMuted.withValues(alpha: 0.25);
    for (final entry in BodyGeometry.organs.entries) {
      final color = fills[entry.key];
      for (final rect in entry.value) {
        final r = BodyGeometry.scaled(rect, size);
        if (color == null) {
          canvas.drawOval(r, faint);
        } else {
          canvas.drawOval(r, Paint()..color = color.withValues(alpha: 0.85));
          canvas.drawOval(
            r,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..color = color,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_SilhouettePainter old) => old.fills != fills;
}

/// Markers keyed by organ, ignoring unknown keys and duplicates.
Map<Organ, BodyMarker> markersByOrgan(List<BodyMarker> markers) {
  final out = <Organ, BodyMarker>{};
  for (final m in markers) {
    final organ = Organ.fromKey(m.part);
    if (organ != null) out.putIfAbsent(organ, () => m);
  }
  return out;
}

/// Block 11 for Pro Max (mockups): dark card with organ chips and a button
/// opening the full-screen body map.
class BodyMapCard extends StatelessWidget {
  const BodyMapCard({super.key, required this.damage, required this.benefit});

  final List<BodyMarker> damage;
  final List<BodyMarker> benefit;

  @override
  Widget build(BuildContext context) {
    final harms = markersByOrgan(damage);
    final benefits = markersByOrgan(benefit);
    final ios = isIos(context);

    final chips = <Widget>[
      for (final e in harms.entries) _OrganChip(organ: e.key, marker: e.value, color: harmColor(e.value.severity)),
      for (final e in benefits.entries) _OrganChip(organ: e.key, marker: e.value, color: benefitColor(e.value.severity)),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.darkPanel, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(Strings.bodyMapTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                ),
              ),
              const PlanBadge(label: 'Pro Max', onDark: true),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            Strings.bodyMapCardSubtitle,
            style: TextStyle(fontFamily: AppFonts.body, fontSize: 13, height: 1.45, color: AppColors.onDarkMuted),
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: chips),
          ] else ...[
            const SizedBox(height: 12),
            Text(
              '${Strings.bodyMapNoHarm} · ${Strings.bodyMapNoBenefit}',
              style: const TextStyle(fontFamily: AppFonts.body, fontSize: 13, color: AppColors.onDarkMuted),
            ),
          ],
          const SizedBox(height: 14),
          AppAccentButton(
            label: Strings.openBodyMap,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => BodyMapPage(damage: damage, benefit: benefit)),
            ),
          ),
          SizedBox(height: ios ? 0 : 0),
        ],
      ),
    );
  }
}

class _OrganChip extends StatelessWidget {
  const _OrganChip({required this.organ, required this.marker, required this.color});

  final Organ organ;
  final BodyMarker marker;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${organ.label}, ${marker.severity.label} severity. ${marker.reason}',
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: isIos(context) ? 5 : 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(isIos(context) ? 999 : 8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                '${organ.label} · ${marker.severity.label}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: AppFonts.body, fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Block 11 below Pro Max: locked dark card. Fixed decoration only — never
/// organs, severities or reasons from the scan (PRD §7.4.2).
class LockedBodyMapCard extends StatelessWidget {
  const LockedBodyMapCard({super.key});

  static final _decoration = <Organ, Color>{
    Organ.brain: AppColors.severityLow,
    Organ.lungs: AppColors.severityMedium,
    Organ.intestines: AppColors.benefitMedium,
    Organ.bones: AppColors.benefitLow,
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '${Strings.bodyMapTitle} locked. ${Strings.bodyMapLocked}.',
      child: Container(
        decoration: BoxDecoration(color: AppColors.darkPanel, borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ExcludeSemantics(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                child: Opacity(
                  opacity: 0.5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                    child: Row(
                      children: [
                        for (var i = 0; i < 2; i++) ...[
                          if (i == 1) const SizedBox(width: 24),
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: BodyGeometry.aspect,
                              child: CustomPaint(painter: _SilhouettePainter(fills: _decoration)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.lock, color: AppColors.onPrimary, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Strings.proMaxFeature,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  AppAccentButton(
                    label: Strings.bodyMapLocked,
                    icon: Icons.workspace_premium_outlined,
                    onPressed: () => showPlansSheet(context),
                    expand: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen body map (opened from [BodyMapCard]): both silhouettes with
/// tappable organs plus the text list, so screen readers get identical
/// information (design.md §8).
class BodyMapPage extends StatelessWidget {
  const BodyMapPage({super.key, required this.damage, required this.benefit});

  final List<BodyMarker> damage;
  final List<BodyMarker> benefit;

  @override
  Widget build(BuildContext context) {
    final harms = markersByOrgan(damage);
    final benefits = markersByOrgan(benefit);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.bodyMapTitle)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.gutter),
          children: [
            Text(Strings.bodyMapTapHint, style: text.bodySmall?.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _SilhouettePanel(
                    title: Strings.bodyMapHarms,
                    markers: harms,
                    colorOf: harmColor,
                    emptyText: Strings.bodyMapNoHarm,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SilhouettePanel(
                    title: Strings.bodyMapBenefits,
                    markers: benefits,
                    colorOf: benefitColor,
                    emptyText: Strings.bodyMapNoBenefit,
                  ),
                ),
              ],
            ),
            if (harms.isNotEmpty || benefits.isNotEmpty) ...[
              const SizedBox(height: 14),
              Semantics(header: true, child: Text(Strings.bodyMapListTitle, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
              const SizedBox(height: 6),
              for (final e in harms.entries) _OrganRow(organ: e.key, marker: e.value, kind: Strings.bodyMapHarms, color: harmColor(e.value.severity)),
              for (final e in benefits.entries)
                _OrganRow(organ: e.key, marker: e.value, kind: Strings.bodyMapBenefits, color: benefitColor(e.value.severity)),
            ],
          ],
        ),
      ),
    );
  }
}

class _SilhouettePanel extends StatelessWidget {
  const _SilhouettePanel({required this.title, required this.markers, required this.colorOf, required this.emptyText});

  final String title;
  final Map<Organ, BodyMarker> markers;
  final Color Function(Severity) colorOf;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final fills = {for (final e in markers.entries) e.key: colorOf(e.value.severity)};
    final summary = markers.isEmpty
        ? emptyText
        : markers.entries.map((e) => '${e.key.label} ${e.value.severity.label}').join(', ');

    return Column(
      children: [
        Text(title, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        AspectRatio(
          aspectRatio: BodyGeometry.aspect,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest;
              return Semantics(
                label: '$title map: $summary',
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (d) {
                    final organ = BodyGeometry.hitTest(d.localPosition, size, markers.keys.toSet());
                    if (organ != null) _showOrgan(context, organ, markers[organ]!, title, colorOf);
                  },
                  child: CustomPaint(size: size, painter: _SilhouettePainter(fills: fills)),
                ),
              );
            },
          ),
        ),
        if (markers.isEmpty) ...[
          const SizedBox(height: 6),
          Text(emptyText, textAlign: TextAlign.center, style: text.bodySmall?.copyWith(color: AppColors.textMuted)),
        ],
      ],
    );
  }
}

void _showOrgan(BuildContext context, Organ organ, BodyMarker marker, String kind, Color Function(Severity) colorOf) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final text = Theme.of(context).textTheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.gutter, 0, AppSizes.gutter, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('${organ.label} · $kind', style: text.titleLarge)),
                  LabelChip(label: marker.severity.label, color: colorOf(marker.severity), semanticPrefix: 'Severity'),
                ],
              ),
              const SizedBox(height: 10),
              Text(marker.reason, style: text.bodyLarge),
              if (marker.trigger != null) ...[
                const SizedBox(height: 6),
                Text(Strings.triggerLine(marker.trigger!), style: text.bodyMedium?.copyWith(color: AppColors.textMuted)),
              ],
            ],
          ),
        ),
      );
    },
  );
}

/// Text equivalent of the map so screen readers get identical information.
class _OrganRow extends StatelessWidget {
  const _OrganRow({required this.organ, required this.marker, required this.kind, required this.color});

  final Organ organ;
  final BodyMarker marker;
  final String kind;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, right: 8),
            child: Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${organ.label} — $kind, ${marker.severity.label}. ', style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: marker.reason),
                  if (marker.trigger != null) TextSpan(text: ' (${Strings.triggerLine(marker.trigger!)})'),
                ],
              ),
              style: text.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
