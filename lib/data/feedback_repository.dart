import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/session.dart';
import '../domain/leaderboard.dart';
import 'supabase_client.dart';

/// One feedback row per (user, scan); saving again updates it (PRD §7.4.12).
class FeedbackRepository {
  FeedbackRepository(this._client);

  final SupabaseClient _client;

  Future<ScanFeedback?> load(String scanId) async {
    final row = await _client
        .from('scan_feedback')
        .select('rating, buy_again, comment')
        .eq('scan_id', scanId)
        .maybeSingle();
    if (row == null) return null;
    final buyAgain = BuyAgain.fromWire(row['buy_again'] as String?);
    if (buyAgain == null) return null;
    return ScanFeedback(
      rating: (row['rating'] as num).toInt().clamp(1, 5),
      buyAgain: buyAgain,
      comment: (row['comment'] as String?) ?? '',
    );
  }

  Future<void> save({required String userId, required String scanId, required ScanFeedback feedback}) async {
    final comment = feedback.comment.trim();
    await _client.from('scan_feedback').upsert(
      {
        'user_id': userId,
        'scan_id': scanId,
        'rating': feedback.rating.clamp(1, 5),
        'buy_again': feedback.buyAgain.name,
        'comment': comment.isEmpty ? null : comment.substring(0, comment.length.clamp(0, maxFeedbackComment)),
      },
      onConflict: 'user_id,scan_id',
    );
  }
}

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) => FeedbackRepository(ref.watch(supabaseClientProvider)));

final feedbackProvider = FutureProvider.autoDispose.family<ScanFeedback?, String>((ref, scanId) {
  if (ref.watch(currentUserIdProvider) == null) throw StateError('Signed out.');
  return ref.watch(feedbackRepositoryProvider).load(scanId);
});
