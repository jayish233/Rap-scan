import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/common.dart';

/// A heading followed by paragraphs and/or bullets.
class ArticleSection {
  const ArticleSection({required this.heading, this.paragraphs = const [], this.bullets = const []});

  final String heading;
  final List<String> paragraphs;
  final List<String> bullets;
}

/// Static, public long-form page (trust, guides). No sign-in required.
class ArticleScreen extends StatelessWidget {
  const ArticleScreen({
    super.key,
    required this.title,
    this.intro,
    required this.sections,
    this.closing,
    this.footer,
  });

  final String title;
  final String? intro;
  final List<ArticleSection> sections;
  final String? closing;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.canPop() ? context.pop() : context.go(Routes.home)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          children: [
            ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(header: true, child: Text(title, style: text.headlineMedium)),
                  if (intro != null) ...[
                    const SizedBox(height: 12),
                    Text(intro!, style: text.bodyLarge?.copyWith(color: AppColors.textMuted)),
                  ],
                  for (final section in sections) ...[
                    const SizedBox(height: 24),
                    Semantics(header: true, child: Text(section.heading, style: text.titleLarge)),
                    for (final p in section.paragraphs) ...[
                      const SizedBox(height: 8),
                      Text(p, style: text.bodyLarge),
                    ],
                    if (section.bullets.isNotEmpty) const SizedBox(height: 8),
                    for (final b in section.bullets)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 9, right: 10),
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                              ),
                            ),
                            Expanded(child: Text(b, style: text.bodyLarge)),
                          ],
                        ),
                      ),
                  ],
                  if (closing != null) ...[
                    const SizedBox(height: 24),
                    Text(closing!, style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                  if (footer != null) ...[const SizedBox(height: 24), footer!],
                  const DisclaimerFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
