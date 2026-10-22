import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend config from `--dart-define` (or `--dart-define-from-file`).
/// Only the anon key ever ships in the app; the service-role and AI keys
/// live in the edge-function environment.
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}

/// Persists the Supabase session (incl. refresh token) in the platform
/// keychain / keystore instead of plain shared preferences (PRD §7.1).
class SecureSessionStorage extends LocalStorage {
  const SecureSessionStorage();

  static const _storage = FlutterSecureStorage();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() => _storage.containsKey(key: supabasePersistSessionKey);

  @override
  Future<String?> accessToken() => _storage.read(key: supabasePersistSessionKey);

  @override
  Future<void> removePersistedSession() => _storage.delete(key: supabasePersistSessionKey);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: supabasePersistSessionKey, value: persistSessionString);
}

Future<void> initSupabase() {
  return Supabase.initialize(
    url: SupabaseConfig.url,
    // The legacy anon JWT and the newer publishable key are both accepted.
    publishableKey: SupabaseConfig.anonKey,
    authOptions: const FlutterAuthClientOptions(localStorage: SecureSessionStorage()),
  );
}

/// The single Supabase client. Only repositories read this provider.
final supabaseClientProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);
