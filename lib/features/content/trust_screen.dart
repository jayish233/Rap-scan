import 'package:flutter/material.dart';

import 'article.dart';

/// Trust & privacy (PRD §7.10, design.md §4.11).
class TrustScreen extends StatelessWidget {
  const TrustScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ArticleScreen(
      title: 'Trust & privacy',
      intro: 'What we collect, how we protect it, and what we never do with it.',
      sections: [
        ArticleSection(
          heading: 'Your account',
          bullets: [
            'Sign-in is handled by our authentication provider, which stores passwords hashed. RAPscanz never stores your password.',
            'One account per email address.',
          ],
        ),
        ArticleSection(
          heading: 'Who can see your data',
          bullets: [
            'Only you can read or edit your profile, scans and the foods you mark as eaten. This is enforced in the database with row-level security.',
            'Your health info is never shown on the leaderboard. The leaderboard only shows your username, average score and scan count.',
          ],
        ),
        ArticleSection(
          heading: 'What we collect',
          bullets: [
            'Your email address.',
            'An optional username.',
            'An optional health profile: gender, age, weight, height, conditions and allergies.',
            'Your scan history: product names, the ingredients you submit, and the analysis.',
            'The items you mark as consumed.',
          ],
        ),
        ArticleSection(
          heading: 'How we use it',
          bullets: [
            'To personalise your scan insights and your weekly intake.',
            'We do not sell your personal data.',
            'Label photos are analysed and then discarded. We do not keep a photo archive.',
          ],
        ),
        ArticleSection(
          heading: 'Security',
          bullets: [
            'Everything travels over HTTPS.',
            'You cannot edit your plan, scan count or subscription. Those are managed on our server.',
            'Scan quotas and leaderboard rankings are calculated on our server, not on your phone.',
          ],
        ),
        ArticleSection(
          heading: 'Storage and tracking',
          bullets: [
            'We only store what is needed to keep you signed in.',
            'No third-party ad trackers.',
          ],
        ),
        ArticleSection(
          heading: 'Who processes your data',
          bullets: [
            'Hosting and database: Supabase.',
            'An AI service that analyses the ingredient lists and label photos you submit.',
          ],
        ),
        ArticleSection(
          heading: 'Your choices',
          bullets: [
            'You can edit your health profile in the app at any time.',
            'To delete your account, contact the RAPscanz team and we will remove it.',
          ],
        ),
      ],
      closing: 'RAPscanz provides general informational analysis. It is not a medical service.',
    );
  }
}
