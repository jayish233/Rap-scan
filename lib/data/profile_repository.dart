import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/session.dart';
import '../domain/plan.dart';
import 'supabase_client.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  /// Read-only quota from the server; never computed on the device.
  Future<Quota> fetchQuota() async {
    final data = await _client.rpc<Map<String, dynamic>?>('get_my_quota');
    if (data == null) throw StateError('No profile for the signed-in user.');
    return Quota(
      remaining: (data['remaining'] as num).toInt(),
      scanLimit: (data['scanLimit'] as num).toInt(),
      plan: data['plan'] as String,
      planLabel: data['planLabel'] as String,
      isUnlimited: data['isUnlimited'] as bool? ?? false,
    );
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(supabaseClientProvider)),
);

/// Current quota for the signed-in user. Invalidate after a scan.
final quotaProvider = FutureProvider.autoDispose<Quota>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) throw StateError('Signed out.');
  return ref.watch(profileRepositoryProvider).fetchQuota();
});
