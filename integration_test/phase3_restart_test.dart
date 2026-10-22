// Phase 3 gate, part 2 (PRD §14.6): after an app restart, the in-store code
// saved by phase3_gate_test.dart is recognised from on-device storage, with
// no dialog and no credit spent.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:learn/l10n/strings.dart';

import 'gate_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('saved in-store code is recognised after restart', (tester) async {
    await launchSignedIn(tester);
    final chipBefore = chipText(tester);
    await tapVisible(tester, find.text(Strings.modeBarcode));
    await setField(tester, 'scan-barcode-field', '2000000123455');
    await tapVisible(tester, find.text(Strings.scanButton));
    await pumpUntil(tester, find.text(Strings.localSavedCard));
    expect(find.text('Gate loose almonds'), findsOneWidget);
    expect(find.text('₹180'), findsOneWidget);
    expect(find.text(Strings.localAddTitle), findsNothing);
    expect(chipText(tester), chipBefore);
  });
}
