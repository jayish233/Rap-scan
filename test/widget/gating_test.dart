import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn/app/session.dart';
import 'package:learn/app/theme.dart';
import 'package:learn/data/feedback_repository.dart';
import 'package:learn/data/profile_repository.dart';
import 'package:learn/domain/organs.dart';
import 'package:learn/domain/plan.dart';
import 'package:learn/domain/rating.dart';
import 'package:learn/domain/scan_result.dart';
import 'package:learn/features/plans/plans_sheet.dart';
import 'package:learn/features/scan/result/body_map.dart';
import 'package:learn/features/scan/result/scan_result_view.dart';
import 'package:learn/l10n/strings.dart';

/// A full Pro Max payload, as a stale cache could still hold it.
ScanResult fullResult({int score = 25, bool risky = true}) => ScanResult(
      productName: 'Maggi Noodles Masala 70Grm Pc',
      brand: 'Maggi',
      parentCompany: 'Nestlé India',
      category: 'Instant noodles',
      rating: score >= 70 ? Rating.good : Rating.caution,
      healthScore: score,
      caloriesKcal: 306,
      summary: 'Instant noodles high in salt and saturated fat.',
      advantages: const ['Quick to prepare'],
      disadvantages: const ['High sodium'],
      cautions: const [
        Caution(
          ingredient: 'Salt',
          concern: 'High sodium.',
          severity: Severity.high,
          percentage: '~3%',
          chemicalFormula: 'NaCl',
          scientificName: 'Sodium chloride',
        ),
      ],
      consumptionTip: const ConsumptionTip(
        safeDaily: 'Not recommended daily',
        limit: 'Once a week',
        source: 'WHO sodium guideline',
      ),
      riskProfile: risky
          ? const RiskProfile(
              illnesses: ['Raised blood pressure'],
              addictions: ['Habit-forming snacking'],
              chronicDamage: ['Arterial strain'],
              temporaryEffects: ['Thirst'],
              organDamage: ['Kidney load'],
            )
          : const RiskProfile(),
      bodyDamage: const [
        BodyMarker(part: 'heart', severity: Severity.high, reason: 'SALT-HARMS-HEART', trigger: 'salt'),
        BodyMarker(part: 'kidneys', severity: Severity.medium, reason: 'SODIUM-LOADS-KIDNEYS', trigger: 'salt'),
      ],
      bodyBenefit: const [
        BodyMarker(part: 'bones', severity: Severity.medium, reason: 'CALCIUM-HELPS-BONES', trigger: 'calcium'),
      ],
      dietaryType: DietaryType.veg,
      dietaryReason: 'DIETARY-REASON-WHEAT-AND-PALM',
    );

Quota quotaFor(String plan, {bool unlimited = false}) => Quota(
      remaining: 10,
      scanLimit: 30,
      plan: plan,
      planLabel: switch (plan) {
        'pro' => 'Pro',
        'pro_plus' => 'Pro+',
        'pro_max' => 'Pro Max',
        _ => 'Free',
      },
      isUnlimited: unlimited,
    );

Future<void> pumpResult(WidgetTester tester, {required Quota quota, ScanResult? result}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        quotaProvider.overrideWith((ref) async => quota),
        currentUserIdProvider.overrideWithValue('u1'),
        feedbackProvider.overrideWith((ref, id) async => null),
      ],
      child: MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ScanResultView(result: result ?? fullResult(), access: quota.access, scanId: 's1'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

const _secrets = [
  'DIETARY-REASON-WHEAT-AND-PALM',
  'SALT-HARMS-HEART',
  'SODIUM-LOADS-KIDNEYS',
  'CALCIUM-HELPS-BONES',
  'Vegetarian',
  'Heart',
  'Kidneys',
  'Raised blood pressure',
  'WHO sodium guideline',
  'NaCl',
  'Sodium chloride',
];

void main() {
  for (final plan in ['free', 'pro']) {
    testWidgets('$plan: locked teasers reveal nothing from a stale full payload (PRD §14.11)', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpResult(tester, quota: quotaFor(plan));

      expect(find.text(Strings.dietaryLockedTitle), findsOneWidget);
      expect(find.text(Strings.dietaryLockedBody), findsOneWidget);
      expect(find.byType(LockedBodyMapCard), findsOneWidget);
      expect(find.text(Strings.bodyMapLocked), findsOneWidget);
      expect(find.text(Strings.consumptionTitle), findsNothing);
      expect(find.text(Strings.riskTitle), findsNothing);
      expect(find.text(Strings.bodyMapHarms), findsNothing);

      // Neither on screen nor in the screen-reader tree.
      for (final secret in _secrets) {
        expect(find.textContaining(secret, findRichText: true), findsNothing, reason: '"$secret" shown on $plan');
        expect(find.bySemanticsLabel(RegExp(RegExp.escape(secret))), findsNothing, reason: '"$secret" in semantics on $plan');
      }
      semantics.dispose();
    });
  }

  testWidgets('pro_plus: guide, % and formula; still no dietary, risk or body map', (tester) async {
    await pumpResult(tester, quota: quotaFor('pro_plus'));
    expect(find.text(Strings.consumptionTitle), findsOneWidget);
    expect(find.textContaining('WHO sodium guideline'), findsOneWidget);
    expect(find.textContaining('NaCl'), findsOneWidget);
    expect(find.textContaining('~3%'), findsOneWidget);
    expect(find.text(Strings.dietaryLockedTitle), findsOneWidget);
    expect(find.byType(LockedBodyMapCard), findsOneWidget);
    expect(find.text(Strings.riskTitle), findsNothing);
  });

  for (final (name, quota) in [
    ('pro_max', quotaFor('pro_max')),
    ('unlimited role', quotaFor('free', unlimited: true)),
    ('unlimited plan', quotaFor('unlimited')),
  ]) {
    testWidgets('$name: dietary + reason, header mark, body map card, risk profile (PRD §14.12)', (tester) async {
      await pumpResult(tester, quota: quota);
      expect(find.text(Strings.dietaryTitle.toUpperCase()), findsOneWidget);
      expect(find.text('DIETARY-REASON-WHEAT-AND-PALM'), findsOneWidget);
      expect(find.text('Vegetarian'), findsNWidgets(2)); // header mark + section
      expect(find.text(Strings.dietaryLockedTitle), findsNothing);
      // Dark card with organ chips; silhouettes live on the full-screen page.
      expect(find.byType(BodyMapCard), findsOneWidget);
      expect(find.byType(LockedBodyMapCard), findsNothing);
      expect(find.text('Heart · High'), findsOneWidget);
      expect(find.text('Kidneys · Medium'), findsOneWidget);
      expect(find.text(Strings.riskTitle), findsOneWidget);
      for (final group in [Strings.riskIllnesses, Strings.riskAddictions, Strings.riskChronic, Strings.riskTemporary, Strings.riskOrgan]) {
        expect(find.text(group), findsOneWidget);
      }
      // Full-screen map: both silhouettes + the text-list equivalent.
      await tester.ensureVisible(find.text(Strings.openBodyMap));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Strings.openBodyMap));
      await tester.pumpAndSettle();
      expect(find.text(Strings.bodyMapHarms), findsOneWidget);
      expect(find.text(Strings.bodyMapBenefits), findsOneWidget);
      expect(find.textContaining('SALT-HARMS-HEART'), findsOneWidget);
      expect(find.textContaining('CALCIUM-HELPS-BONES'), findsOneWidget);
    });
  }

  testWidgets('Pro Max: healthy-band product hides the empty risk profile', (tester) async {
    await pumpResult(tester, quota: quotaFor('pro_max'), result: fullResult(score: 82, risky: false));
    expect(find.text(Strings.riskTitle), findsNothing);
  });

  testWidgets('Pro Max: tapping a highlighted organ shows reason and trigger', (tester) async {
    await pumpResult(tester, quota: quotaFor('pro_max'));
    await tester.ensureVisible(find.text(Strings.openBodyMap));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.openBodyMap));
    await tester.pumpAndSettle();
    final harms = find.descendant(
      of: find.ancestor(of: find.text(Strings.bodyMapHarms), matching: find.byType(Column)).first,
      matching: find.byType(CustomPaint),
    );
    await tester.ensureVisible(harms.first);
    await tester.pumpAndSettle();
    final box = tester.getRect(harms.first);
    final heart = BodyGeometry.organs[Organ.heart]!.first.center;
    await tester.tapAt(box.topLeft + Offset(heart.dx * box.width, heart.dy * box.height));
    await tester.pumpAndSettle();
    expect(find.text('Heart · ${Strings.bodyMapHarms}'), findsOneWidget);
    expect(find.text(Strings.triggerLine('salt')), findsWidgets);
  });

  testWidgets('empty side still draws and says so', (tester) async {
    final r = fullResult();
    await pumpResult(
      tester,
      quota: quotaFor('pro_max'),
      result: ScanResult(
        productName: r.productName,
        rating: r.rating,
        healthScore: r.healthScore,
        caloriesKcal: r.caloriesKcal,
        summary: r.summary,
        bodyDamage: r.bodyDamage,
        dietaryType: DietaryType.nonVeg,
      ),
    );
    expect(find.text('Non-Vegetarian'), findsWidgets);
    await tester.ensureVisible(find.text(Strings.openBodyMap));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.openBodyMap));
    await tester.pumpAndSettle();
    expect(find.text(Strings.bodyMapNoBenefit), findsOneWidget);
    expect(find.text(Strings.bodyMapNoHarm), findsNothing);
  });

  test('anatomy: heart and stomach on the viewer\'s right, liver on the left', () {
    expect(BodyGeometry.organs[Organ.heart]!.first.center.dx, greaterThan(0.5));
    expect(BodyGeometry.organs[Organ.stomach]!.first.center.dx, greaterThan(0.5));
    expect(BodyGeometry.organs[Organ.liver]!.first.center.dx, lessThan(0.5));
    expect(BodyGeometry.organs.keys.toSet(), Organ.values.toSet());
  });

  test('hit-testing only finds highlighted organs', () {
    const size = Size(100, 200);
    final heart = BodyGeometry.organs[Organ.heart]!.first.center;
    final point = Offset(heart.dx * 100, heart.dy * 200);
    expect(BodyGeometry.hitTest(point, size, {Organ.heart}), Organ.heart);
    expect(BodyGeometry.hitTest(point, size, {Organ.kidneys}), isNull);
  });

  testWidgets('locked teaser opens the plans sheet; upgrade says payments are coming', (tester) async {
    await pumpResult(tester, quota: quotaFor('free'));
    await tester.ensureVisible(find.text(Strings.bodyMapLocked));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.bodyMapLocked));
    await tester.pumpAndSettle();
    expect(find.text(Strings.plansTitle), findsOneWidget);
    expect(find.text(Strings.currentPlanLine('Free · 10 of 30 scans left')), findsOneWidget);
    expect(find.text(Strings.currentPlanBadge), findsOneWidget);
    // The sheet's own button shares the teaser's label; scroll to it.
    final upgrade = find.widgetWithText(OutlinedButton, Strings.upgradeTo('Pro Max'));
    await tester.scrollUntilVisible(
      upgrade,
      200,
      scrollable: find.descendant(of: find.byType(PlansSheet), matching: find.byType(Scrollable)).first,
    );
    await tester.ensureVisible(upgrade);
    await tester.pumpAndSettle();
    await tester.tap(upgrade);
    await tester.pumpAndSettle();
    expect(find.text(Strings.billingPlaceholder), findsWidgets);
  });
}
