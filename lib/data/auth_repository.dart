import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_client.dart';

/// Result of a sign-in / sign-up attempt. `error` carries the provider's
/// message verbatim (PRD §7.1: show the provider message).
class AuthOutcome {
  const AuthOutcome.success() : error = null, needsEmailConfirmation = false;
  const AuthOutcome.confirmEmail() : error = null, needsEmailConfirmation = true;
  const AuthOutcome.failure(this.error) : needsEmailConfirmation = false;

  final String? error;
  final bool needsEmailConfirmation;

  bool get ok => error == null;
}

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Session? get currentSession => _client.auth.currentSession;

  Stream<Session?> sessionChanges() => _client.auth.onAuthStateChange.map((s) => s.session);

  Future<AuthOutcome> signIn({required String email, required String password}) =>
      _guard(() async {
        await _client.auth.signInWithPassword(email: email, password: password);
        return const AuthOutcome.success();
      });

  Future<AuthOutcome> signUp({required String email, required String password}) =>
      _guard(() async {
        final res = await _client.auth.signUp(email: email, password: password);
        // With email confirmation on, sign-up succeeds without a session.
        return res.session == null ? const AuthOutcome.confirmEmail() : const AuthOutcome.success();
      });

  Future<void> signOut() => _client.auth.signOut();

  Future<AuthOutcome> _guard(Future<AuthOutcome> Function() run) async {
    try {
      return await run();
    } on AuthException catch (e) {
      return AuthOutcome.failure(e.message);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(supabaseClientProvider)),
);
