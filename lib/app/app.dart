import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/strings.dart';
import 'router.dart';
import 'theme.dart';

class RapscanzApp extends ConsumerWidget {
  const RapscanzApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'RAPscanz',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      themeMode: ThemeMode.light, // Light only (PRD §4).
      routerConfig: ref.watch(routerProvider),
    );
  }
}

/// Shown when the app was built without the Supabase `--dart-define`s.
class ConfigMissingApp extends StatelessWidget {
  const ConfigMissingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.gutter),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Strings.configMissingTitle, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                SizedBox(height: 8),
                Text(Strings.configMissingBody),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
