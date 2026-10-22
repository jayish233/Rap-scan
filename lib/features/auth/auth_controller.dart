import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';
import '../../l10n/strings.dart';

enum AuthMode { signIn, signUp }

class AuthFormState {
  const AuthFormState({this.mode = AuthMode.signIn, this.busy = false, this.error, this.notice});

  final AuthMode mode;
  final bool busy;
  final String? error;
  final String? notice;

  AuthFormState copyWith({AuthMode? mode, bool? busy, String? error, String? notice}) =>
      AuthFormState(mode: mode ?? this.mode, busy: busy ?? this.busy, error: error, notice: notice);
}

/// Client-side hints only; the auth provider is authoritative (design.md §4.3).
String? validateEmail(String value) {
  final v = value.trim();
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v) ? null : Strings.emailInvalid;
}

String? validatePassword(String value) => value.length >= 6 ? null : Strings.passwordTooShort;

class AuthController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  void toggleMode() => state = AuthFormState(
        mode: state.mode == AuthMode.signIn ? AuthMode.signUp : AuthMode.signIn,
      );

  /// On success the session stream fires and the router redirects to Scan.
  Future<void> submit({required String email, required String password}) async {
    if (state.busy) return;
    state = state.copyWith(busy: true);
    final repo = ref.read(authRepositoryProvider);
    try {
      final outcome = state.mode == AuthMode.signIn
          ? await repo.signIn(email: email.trim(), password: password)
          : await repo.signUp(email: email.trim(), password: password);
      if (!ref.mounted) return;
      if (outcome.needsEmailConfirmation) {
        state = AuthFormState(mode: AuthMode.signIn, notice: Strings.confirmEmail);
      } else {
        state = state.copyWith(busy: false, error: outcome.error);
      }
    } catch (_) {
      if (ref.mounted) state = state.copyWith(busy: false, error: Strings.genericError);
    }
  }
}

final authControllerProvider = NotifierProvider.autoDispose<AuthController, AuthFormState>(AuthController.new);
