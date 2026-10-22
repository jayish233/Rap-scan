import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/session.dart';
import '../../l10n/strings.dart';
import 'article.dart';

/// "The Perfect Healthy Snack" guide (PRD §7.11). Public.
class HealthySnacksScreen extends ConsumerWidget {
  const HealthySnacksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(sessionStateProvider).signedIn;
    return ArticleScreen(
      title: Strings.guideTitle,
      intro: 'The front of the packet sells. The back of the packet tells. '
          'Here is how to read it in under a minute.',
      sections: const [
        ArticleSection(
          heading: 'The short rule',
          paragraphs: [
            'Pick snacks with a short ingredient list you recognise, where a whole food comes first, '
                'and where sugar, salt and refined oil are not doing most of the work.',
          ],
        ),
        ArticleSection(
          heading: 'How to read an ingredient list',
          bullets: [
            'Ingredients are listed by weight, largest first. The first three tell you what you are really eating.',
            'Sugar hides under many names: sugar, invert syrup, liquid glucose, maltodextrin, dextrose, corn syrup, jaggery. Count them together.',
            'Refined wheat flour (maida) is not whole wheat. Look for "whole wheat flour (atta)", oats, millets or pulses.',
            '"Edible vegetable oil" is usually palm oil. "Hydrogenated" or "vanaspati" means trans fat — skip it.',
            'Check salt per 100 g: above 1.5 g is high.',
          ],
        ),
        ArticleSection(
          heading: 'Additives worth a second look',
          bullets: [
            'Artificial colours such as tartrazine (INS 102) and sunset yellow (INS 110).',
            'Flavour enhancers like MSG (INS 621) in salty snacks.',
            'Artificial sweeteners such as aspartame (INS 951) and acesulfame K (INS 950) in "sugar-free" products.',
            'Preservatives such as sodium benzoate (INS 211) and nitrites (INS 250) in processed meats.',
          ],
        ),
        ArticleSection(
          heading: 'What a good snack looks like',
          bullets: [
            'A whole food first: nuts, seeds, roasted chana, makhana, fruit, curd, whole grains.',
            'At least 3 g fibre and a useful amount of protein per 100 g.',
            'Low added sugar (under 5 g per 100 g) and moderate salt.',
            'No trans fat, and few or no additives.',
            'A sensible portion — the serving size on the pack, not the whole pack.',
          ],
        ),
        ArticleSection(
          heading: 'Let RAPscanz read it for you',
          paragraphs: [
            'Paste the ingredient list, photograph the label, or scan the barcode. '
                'RAPscanz gives you a health score, the good and the bad, and the chemicals worth a second look.',
          ],
        ),
      ],
      footer: FilledButton(
        onPressed: () => context.go(signedIn ? Routes.scan : Routes.auth),
        child: const Text(Strings.homeCta),
      ),
    );
  }
}
