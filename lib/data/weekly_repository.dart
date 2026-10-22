import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/session.dart';
import '../domain/weekly.dart';
import 'supabase_client.dart';

/// "I ate this" log (consumption table, PRD §7.7).
class WeeklyRepository {
  WeeklyRepository(this._client);

  final SupabaseClient _client;

  /// Explicit logging only; the same scan may be logged again.
  Future<void> logConsumption({
    required String userId,
    required String scanId,
    required String productName,
    required int caloriesKcal,
  }) async {
    await _client.from('consumption').insert({
      'user_id': userId,
      'scan_id': scanId,
      'product_name': productName,
      'calories_kcal': caloriesKcal,
    });
  }

  /// Entries since local midnight six days ago (the 7-day window).
  Future<WeeklySummary> week(DateTime now) async {
    final rows = await _client
        .from('consumption')
        .select('id, scan_id, product_name, calories_kcal, consumed_at')
        .gte('consumed_at', weekWindowStart(now).toUtc().toIso8601String())
        .order('consumed_at', ascending: false);
    final entries = [
      for (final r in rows)
        ConsumptionEntry(
          id: r['id'] as String,
          scanId: r['scan_id'] as String,
          productName: (r['product_name'] as String?)?.trim().isNotEmpty == true
              ? r['product_name'] as String
              : 'Unidentified product',
          caloriesKcal: r['calories_kcal'] as num?,
          consumedAt: DateTime.parse(r['consumed_at'] as String).toLocal(),
        ),
    ];
    return WeeklySummary.from(entries, now);
  }

  /// Removes that log row only — never the scan. RLS makes another user's
  /// row a silent no-op (PRD §15).
  Future<void> delete(String entryId) => _client.from('consumption').delete().eq('id', entryId);
}

final weeklyRepositoryProvider = Provider<WeeklyRepository>((ref) => WeeklyRepository(ref.watch(supabaseClientProvider)));

/// Clock seam for tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final weeklyProvider = FutureProvider.autoDispose<WeeklySummary>((ref) {
  if (ref.watch(currentUserIdProvider) == null) throw StateError('Signed out.');
  return ref.watch(weeklyRepositoryProvider).week(ref.watch(clockProvider)());
});
