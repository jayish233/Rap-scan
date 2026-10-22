import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/leaderboard.dart';
import 'supabase_client.dart';

/// Public leaderboard via `get_leaderboard()` (PRD §7.8). The server ranks,
/// filters (≥ 3 scored scans, username set) and caps at 50; the response
/// holds username + aggregates only, never health fields.
class LeaderboardRepository {
  LeaderboardRepository(this._client);

  final SupabaseClient _client;

  Future<List<LeaderboardEntry>> fetch() async {
    final rows = await _client.rpc<List<dynamic>>('get_leaderboard');
    return [
      for (final (i, r) in rows.indexed)
        if (r is Map && r['username'] is String)
          LeaderboardEntry(
            rank: i + 1,
            username: r['username'] as String,
            averageScore: (r['avg_score'] as num? ?? 0).round().clamp(0, 100),
            scanCount: (r['scan_count'] as num? ?? 0).toInt(),
          ),
    ];
  }
}

final leaderboardRepositoryProvider =
    Provider<LeaderboardRepository>((ref) => LeaderboardRepository(ref.watch(supabaseClientProvider)));

final leaderboardProvider = FutureProvider.autoDispose<List<LeaderboardEntry>>(
  (ref) => ref.watch(leaderboardRepositoryProvider).fetch(),
);
