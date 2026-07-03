import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// iMessage-style bubble: gradient for sent, subtle surface for received,
/// asymmetric tail radius, reduced opacity while optimistically "sending"
/// (design brief §patterns).
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    required this.body,
    required this.isMine,
    this.pending = false,
    this.senderName,
    super.key,
  });

  final String body;
  final bool isMine;
  final bool pending;

  /// Shown above the bubble for group rooms (Discord-style attribution).
  final String? senderName;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(AppRadius.xl),
      topRight: const Radius.circular(AppRadius.xl),
      bottomLeft: Radius.circular(isMine ? AppRadius.xl : AppRadius.sm),
      bottomRight: Radius.circular(isMine ? AppRadius.sm : AppRadius.xl),
    );
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Opacity(
        opacity: pending ? 0.6 : 1,
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (senderName != null)
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.xs,
                ),
                child: Text(
                  senderName!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md - 2,
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.75,
              ),
              decoration: BoxDecoration(
                gradient: isMine
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          scheme.primary,
                          Color.lerp(scheme.primary, scheme.tertiary, 0.35)!,
                        ],
                      )
                    : null,
                color: isMine ? null : scheme.surfaceContainerHigh,
                borderRadius: radius,
              ),
              child: Text(
                body,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isMine ? scheme.onPrimary : scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Messenger-style pill composer: rounded 28 input + filled circular send.
class ChatComposer extends StatelessWidget {
  const ChatComposer({
    required this.controller,
    required this.onSend,
    this.hint = 'Message…',
    super.key,
  });

  final TextEditingController controller;
  final Future<void> Function() onSend;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    borderSide: BorderSide(color: scheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    borderSide: BorderSide(color: scheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    borderSide: BorderSide(color: scheme.primary, width: 1.5),
                  ),
                ),
                onSubmitted: (_) => onSend().ignore(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton.filled(
              tooltip: 'Send',
              onPressed: () => onSend().ignore(),
              icon: const Icon(Icons.arrow_upward_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
