/// Public leaderboard rows (PRD §7.8) and per-scan feedback (§7.4.12).
/// Pure Dart.
library;

class LeaderboardEntry {
  const LeaderboardEntry({required this.rank, required this.username, required this.averageScore, required this.scanCount});

  final int rank; // 1-based, server order
  final String username;
  final int averageScore; // rounded by the server
  final int scanCount;

  /// 🥇🥈🥉 for the top three, otherwise "#n".
  String get rankLabel => switch (rank) {
        1 => '🥇',
        2 => '🥈',
        3 => '🥉',
        _ => '#$rank',
      };

  String get handle => '@$username';
}

enum BuyAgain {
  yes('Yes'),
  maybe('Maybe'),
  no('No');

  const BuyAgain(this.label);
  final String label;

  static BuyAgain? fromWire(String? value) => switch (value) {
        'yes' => BuyAgain.yes,
        'maybe' => BuyAgain.maybe,
        'no' => BuyAgain.no,
        _ => null,
      };
}

const maxFeedbackComment = 1000;

class ScanFeedback {
  const ScanFeedback({required this.rating, required this.buyAgain, this.comment = ''});

  final int rating; // 1–5
  final BuyAgain buyAgain;
  final String comment;
}
