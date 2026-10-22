// Phase 3 gate, in-store half (PRD §14.6), part 1: save an in-store code
// with no server call and no credit. Part 2 (phase3_restart_test.dart) must
// run as a fresh launch over the same install:
//   tool/phase3_restart_gate.sh
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:learn/l10n/strings.dart';

import 'gate_helpers.dart';

const inStoreCode = '2000000123455';
const inStoreName = 'Gate loose almonds';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('in-store code opens local inventory and saves on device, no credit', (tester) async {
    await launchSignedIn(tester);
    final chipBefore = chipText(tester);

    // §14.6 In-store code: local inventory, no server call, no credit.
    await tapVisible(tester, find.text(Strings.modeBarcode));
    await setField(tester, 'scan-barcode-field', inStoreCode);
    await tapVisible(tester, find.text(Strings.scanButton));
    await pumpUntil(tester, find.text(Strings.localAddTitle));
    await tester.enterText(find.byKey(const ValueKey('local-name')), inStoreName);
    await tester.enterText(find.byKey(const ValueKey('local-price')), '₹180');
    await tester.tap(find.text(Strings.save));
    await pumpUntil(tester, find.text(Strings.localSavedCard));
    expect(find.text(inStoreName), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(chipText(tester), chipBefore, reason: 'in-store lookup must not spend a credit');

  });
}
