import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/session.dart';
import '../domain/plan.dart';
import '../domain/profile.dart';
import 'cache_store.dart';
import 'history_repository.dart';
import 'supabase_client.dart';

/// Username already used by someone else (case-insensitive unique index).
class UsernameTaken implements Exception {
  const UsernameTaken();
}

class ProfileRepository {
  ProfileRepository(this._client, this._cache);

  final SupabaseClient _client;
  final CacheStore _cache;

  static const _columns = 'id, email, username, gender, age, weight_kg, height_cm, illnesses, allergies';

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

  /// Profile from the server, or the cached copy when offline.
  Future<Cached<Profile>> fetchProfile(String userId) async {
    try {
      final row = await _client.from('profiles').select(_columns).eq('id', userId).single();
      await _cache.write(userId, 'profile', row);
      return Cached(_parse(row));
    } catch (_) {
      final cached = await _cache.read(userId, 'profile');
      if (cached is Map) return Cached(_parse(Map<String, dynamic>.from(cached)), stale: true);
      rethrow;
    }
  }

  /// Writes only the user-editable columns; plan and quota columns are not
  /// client-writable (column grants + trigger on the server).
  Future<Profile> saveProfile(String userId, ProfileUpdate update) async {
    try {
      final row = await _client
          .from('profiles')
          .update({
            'username': (update.username?.trim().isEmpty ?? true) ? null : update.username!.trim(),
            'gender': update.gender.wire,
            'age': update.age,
            'weight_kg': update.weightKg,
            'height_cm': update.heightCm,
            'illnesses': update.illnesses.trim(),
            'allergies': update.allergies.trim(),
          })
          .eq('id', userId)
          .select(_columns)
          .single();
      await _cache.write(userId, 'profile', row);
      return _parse(row);
    } on PostgrestException catch (e) {
      if (e.code == '23505') throw const UsernameTaken();
      rethrow;
    }
  }

  static Profile _parse(Map<String, dynamic> r) => Profile(
        id: r['id'] as String,
        email: r['email'] as String?,
        username: r['username'] as String?,
        gender: Gender.fromWire(r['gender'] as String?),
        age: (r['age'] as num?)?.toInt(),
        weightKg: (r['weight_kg'] as num?)?.toDouble(),
        heightCm: (r['height_cm'] as num?)?.toDouble(),
        illnesses: (r['illnesses'] as String?) ?? '',
        allergies: (r['allergies'] as String?) ?? '',
      );
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(supabaseClientProvider), ref.watch(cacheStoreProvider)),
);

/// Current quota for the signed-in user. Invalidate after a scan.
final quotaProvider = FutureProvider.autoDispose<Quota>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) throw StateError('Signed out.');
  return ref.watch(profileRepositoryProvider).fetchQuota();
});

final profileProvider = FutureProvider.autoDispose<Cached<Profile>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) throw StateError('Signed out.');
  return ref.watch(profileRepositoryProvider).fetchProfile(userId);
});
