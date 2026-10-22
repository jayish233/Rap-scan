import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../widgets/brand.dart';
import '../../widgets/common.dart';
import 'widgets/quota_chip.dart';

/// Scan tab. Phase 1 shell: plan chip + disclaimer. Input modes, the
/// primary action and results arrive in Phase 2.
class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const BrandLockup(), centerTitle: false),
      body: SafeArea(
        top: false,
        child: ListView(
          children: const [
            ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  QuotaChip(),
                  SizedBox(height: 24),
                  PageHeader(title: Strings.navScan, subtitle: Strings.homeSupportingCopy),
                  SizedBox(height: 24),
                  DisclaimerFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
