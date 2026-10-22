import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'data/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!SupabaseConfig.isConfigured) {
    runApp(const ConfigMissingApp());
    return;
  }
  await initSupabase();
  runApp(const ProviderScope(child: RapscanzApp()));
}
