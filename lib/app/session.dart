import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';

/// Signed-in state, driven by Supabase's auth stream (architecture.md §2.4.4).
/// It is a [Listenable] so go_router re-runs its redirect on every change.
class SessionState extends ChangeNotifier {
  SessionState({this._userId, Stream<String?>? userIdChanges}) {
    _sub = userIdChanges?.listen(_update);
  }

  String? _userId;
  StreamSubscription<String?>? _sub;

  bool get signedIn => _userId != null;
  String? get userId => _userId;

  void _update(String? userId) {
    if (userId == _userId) return;
    _userId = userId;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final sessionStateProvider = Provider<SessionState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final state = SessionState(
    userId: repo.currentSession?.user.id,
    userIdChanges: repo.sessionChanges().map((s) => s?.user.id),
  );
  ref.onDispose(state.dispose);
  return state;
});

/// The signed-in user's id, or null. Rebuilds dependents on sign-in/out so
/// per-user data (quota, history) never leaks across accounts.
final currentUserIdProvider = Provider<String?>((ref) {
  final session = ref.watch(sessionStateProvider);
  void listener() => ref.invalidateSelf();
  session.addListener(listener);
  ref.onDispose(() => session.removeListener(listener));
  return session.userId;
});
