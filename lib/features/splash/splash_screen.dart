import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/session.dart';
import '../../widgets/brand.dart';

/// Brand mark + wordmark, then Home (signed out) or Scan (signed in).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const holdDuration = Duration(milliseconds: 700);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(SplashScreen.holdDuration, () {
      if (!mounted) return;
      context.go(ref.read(sessionStateProvider).signedIn ? Routes.scan : Routes.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [BrandMark(size: 96), SizedBox(height: 16), Wordmark(fontSize: 34)],
        ),
      ),
    );
  }
}
