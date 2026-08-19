import 'package:flutter/material.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/generated/l10n.dart';

typedef SubmitReviewCallback = Future<void> Function({
  required double rating,
  required String text,
});

class _ReviewDraft {
  const _ReviewDraft({required this.rating, required this.text});

  final double rating;
  final String text;
}

/// Bottom sheet for 1–5 star rating + optional comment.
class SubmitReviewSheet {
  SubmitReviewSheet._();

  static Future<void> show(
    BuildContext context, {
    required SubmitReviewCallback onSubmit,
    double initialRating = 5,
    String initialText = '',
    String? title,
    String? submitLabel,
  }) async {
    final ok = await AuthGuard.requireAuth(context);
    if (!ok || !context.mounted) return;

    final draft = await showModalBottomSheet<_ReviewDraft>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _SubmitReviewSheetBody(
        initialRating: initialRating,
        initialText: initialText,
        title: title,
        submitLabel: submitLabel,
      ),
    );

    if (draft == null || !context.mounted) return;
    await onSubmit(rating: draft.rating, text: draft.text);
  }
}

class _SubmitReviewSheetBody extends StatefulWidget {
  const _SubmitReviewSheetBody({
    required this.initialRating,
    required this.initialText,
    this.title,
    this.submitLabel,
  });

  final double initialRating;
  final String initialText;
  final String? title;
  final String? submitLabel;

  @override
  State<_SubmitReviewSheetBody> createState() => _SubmitReviewSheetBodyState();
}

class _SubmitReviewSheetBodyState extends State<_SubmitReviewSheetBody> {
  late double _rating;
  late final TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _textCtrl = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final draft = _ReviewDraft(
      rating: _rating,
      text: _textCtrl.text.trim(),
    );
    Navigator.pop(context, draft);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: stickyBottomPadding(context),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title ?? s.writeReview,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final star = i + 1;
                final filled = _rating >= star - 0.5;
                return IconButton(
                  onPressed: () => setState(() => _rating = star.toDouble()),
                  icon: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: colors.warning,
                    size: 36,
                  ),
                );
              }),
            ),
            TextField(
              controller: _textCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: s.reviewCommentHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _submit,
              child: Text(widget.submitLabel ?? s.submitReview),
            ),
          ],
        ),
      ),
    );
  }
}
