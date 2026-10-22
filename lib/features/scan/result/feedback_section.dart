import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/session.dart';
import '../../../app/theme.dart';
import '../../../data/feedback_repository.dart';
import '../../../domain/leaderboard.dart';
import '../../../l10n/strings.dart';
import '../../../widgets/adaptive.dart';
import '../../../widgets/common.dart';

/// Block 12 (PRD §7.4.12, mockups: "Rate this scan"): stars, buy-again and
/// an optional note. One row per user per scan; re-saving updates it.
class FeedbackSection extends ConsumerWidget {
  const FeedbackSection({super.key, required this.scanId});

  final String scanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(feedbackProvider(scanId));
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: switch (saved) {
        AsyncData(:final value) => _FeedbackForm(key: ValueKey(scanId), scanId: scanId, saved: value),
        AsyncError() => _FeedbackForm(key: ValueKey(scanId), scanId: scanId, saved: null),
        _ => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
      },
    );
  }
}

class _FeedbackForm extends ConsumerStatefulWidget {
  const _FeedbackForm({super.key, required this.scanId, required this.saved});

  final String scanId;
  final ScanFeedback? saved;

  @override
  ConsumerState<_FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends ConsumerState<_FeedbackForm> {
  late int _rating = widget.saved?.rating ?? 0;
  late BuyAgain? _buyAgain = widget.saved?.buyAgain;
  late final _comment = TextEditingController(text: widget.saved?.comment ?? '');
  late bool _thanked = widget.saved != null;
  bool _saving = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final buyAgain = _buyAgain;
    final userId = ref.read(currentUserIdProvider);
    if (_rating == 0 || buyAgain == null) {
      showToast(context, Strings.feedbackNeedsAnswers, error: true);
      return;
    }
    if (userId == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(feedbackRepositoryProvider).save(
            userId: userId,
            scanId: widget.scanId,
            feedback: ScanFeedback(rating: _rating, buyAgain: buyAgain, comment: _comment.text),
          );
      if (!mounted) return;
      setState(() => _thanked = true);
      // Other open views of this scan (e.g. History detail while the Scan tab
      // stays alive) must reload the saved row.
      ref.invalidate(feedbackProvider(widget.scanId));
    } catch (_) {
      if (mounted) showToast(context, Strings.feedbackFailed, error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    if (_thanked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(Strings.feedbackThanks, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
            ],
          ),
          const SizedBox(height: 8),
          StarRating(rating: _rating),
          const SizedBox(height: 4),
          Text('${Strings.feedbackPrompt} ${_buyAgain?.label ?? ''}', style: text.bodyMedium),
          if (_comment.text.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('“${_comment.text.trim()}”', style: text.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: () => setState(() => _thanked = false), child: const Text(Strings.feedbackEdit)),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(header: true, child: Text(Strings.rateThisScan, style: text.titleMedium)),
        const SizedBox(height: 8),
        Row(
          children: [
            StarRating(rating: _rating, size: isIos(context) ? 34 : 38, onChanged: _saving ? null : (r) => setState(() => _rating = r)),
            if (_rating > 0) ...[
              const SizedBox(width: 8),
              Text('$_rating/5', style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Text(Strings.feedbackPrompt, style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        AppSegmented<BuyAgain>(
          options: [for (final b in BuyAgain.values) (b, b.label, null)],
          selected: _buyAgain,
          onChanged: _saving ? null : (b) => setState(() => _buyAgain = _buyAgain == b ? null : b),
        ),
        const SizedBox(height: 12),
        const FieldCaption(label: Strings.addNoteOptional),
        TextField(
          key: const ValueKey('feedback-comment'),
          controller: _comment,
          enabled: !_saving,
          maxLength: maxFeedbackComment,
          minLines: 2,
          maxLines: 4,
          decoration: appInputDecoration(context, hint: Strings.feedbackNoteHint),
          buildCounter: (_, {required currentLength, required isFocused, required maxLength}) => null,
        ),
        const SizedBox(height: 12),
        AppOutlinedAction(label: Strings.sendFeedback, onPressed: _saving ? null : _submit),
      ],
    );
  }
}

/// Tappable 1–5 stars (mockups: amber fill, darker outline).
class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.rating, this.onChanged, this.size = 22});

  final int rating;
  final ValueChanged<int>? onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    final readOnly = onChanged == null;
    Widget star(int i) {
      final filled = i <= rating;
      return Icon(
        filled ? Icons.star_rounded : Icons.star_outline_rounded,
        color: filled ? AppColors.warning : AppColors.textMuted,
        size: size,
      );
    }

    return Semantics(
      label: readOnly ? 'Rated ${Strings.starsLabel(rating)} out of 5' : null,
      excludeSemantics: readOnly,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            readOnly
                ? Padding(padding: const EdgeInsets.only(right: 2), child: star(i))
                : InkResponse(
                    onTap: () => onChanged!(i),
                    radius: size * 0.75,
                    child: Semantics(button: true, label: Strings.starsLabel(i), child: Padding(padding: const EdgeInsets.all(4), child: star(i))),
                  ),
        ],
      ),
    );
  }
}
