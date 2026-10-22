import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/session.dart';
import '../domain/scan_result.dart';
import 'cache_store.dart';
import 'dto/scan_dto.dart';
import 'supabase_client.dart';

/// A value plus whether it came from the offline cache.
class Cached<T> {
  const Cached(this.value, {this.stale = false});
  final T value;
  final bool stale;
}

class ScanNotFound implements Exception {
  const ScanNotFound();
}

class HistoryRepository {
  HistoryRepository(this._client, this._cache);

  final SupabaseClient _client;
  final CacheStore _cache;

  static const listLimit = 50;
  static const _listColumns = 'id, product_name, scan_type, rating, health_score, calories_kcal, summary, created_at';

  /// Newest first, up to 50 (PRD §7.6). Falls back to the cached list when
  /// offline; rethrows only when there is nothing cached.
  Future<Cached<List<ScanSummary>>> list(String userId) async {
    try {
      final rows = await _client
          .from('scans')
          .select(_listColumns)
          .order('created_at', ascending: false)
          .limit(listLimit);
      await _cache.write(userId, 'history', rows);
      return Cached(_parseList(rows));
    } catch (_) {
      final cached = await _cache.read(userId, 'history');
      if (cached is List) return Cached(_parseList(cached), stale: true);
      rethrow;
    }
  }

  /// The cached list only, for an instant first paint.
  Future<List<ScanSummary>?> cachedList(String userId) async {
    final cached = await _cache.read(userId, 'history');
    return cached is List ? _parseList(cached) : null;
  }

  /// Saved analysis; never re-runs the model (PRD §7.6).
  Future<Cached<ScanDetail>> detail(String userId, String scanId) async {
    try {
      final row = await _client
          .from('scans')
          .select('id, scan_type, created_at, result')
          .eq('id', scanId)
          .maybeSingle();
      if (row == null) throw const ScanNotFound();
      await _cache.write(userId, 'scan.$scanId', row);
      return Cached(ScanDetailRowDto.fromJson(row).toDomain());
    } on ScanNotFound {
      rethrow;
    } on PostgrestException catch (e) {
      // A malformed id is simply a missing scan.
      if (e.code == '22P02') throw const ScanNotFound();
      return _cachedDetail(userId, scanId, e);
    } catch (e) {
      return _cachedDetail(userId, scanId, e);
    }
  }

  Future<Cached<ScanDetail>> _cachedDetail(String userId, String scanId, Object error) async {
    final cached = await _cache.read(userId, 'scan.$scanId');
    if (cached is Map) {
      return Cached(ScanDetailRowDto.fromJson(Map<String, dynamic>.from(cached)).toDomain(), stale: true);
    }
    throw error;
  }

  List<ScanSummary> _parseList(List<dynamic> rows) => [
        for (final r in rows)
          if (r is Map) ScanRowDto.fromJson(Map<String, dynamic>.from(r)).toDomain(),
      ];
}

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepository(ref.watch(supabaseClientProvider), ref.watch(cacheStoreProvider)),
);

/// History list for the signed-in user. Invalidate after a new scan.
final historyProvider = FutureProvider.autoDispose<Cached<List<ScanSummary>>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) throw StateError('Signed out.');
  return ref.watch(historyRepositoryProvider).list(userId);
});

final scanDetailProvider = FutureProvider.autoDispose.family<Cached<ScanDetail>, String>((ref, scanId) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) throw StateError('Signed out.');
  return ref.watch(historyRepositoryProvider).detail(userId, scanId);
});
