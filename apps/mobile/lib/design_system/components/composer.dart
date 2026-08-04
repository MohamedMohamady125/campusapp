import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';

/// Bottom-anchored message composer (spec §10.5).
///
/// Expands to five lines then scrolls. Send is enabled only with content.
/// Never blocks on network — the caller is responsible for optimistic send.
class Composer extends StatefulWidget {
  const Composer({
    required this.onSend,
    super.key,
    this.controller,
    this.onAttach,
    this.hintText = 'Message',
    this.enabled = true,
  });

  final ValueChanged<String> onSend;

  /// Optional external controller so callers can restore input on a
  /// failed send (spec §6.3 — forgiving forms preserve input).
  final TextEditingController? controller;
  final VoidCallback? onAttach;
  final String hintText;
  final bool enabled;

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _hasContent = _controller.text.trim().isNotEmpty;
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    final has = _controller.text.trim().isNotEmpty;
    if (has != _hasContent) setState(() => _hasContent = has);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;

    return ColoredBox(
      color: colors.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space2,
            vertical: tokens.space2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (widget.onAttach != null)
                IconButton(
                  onPressed: widget.enabled ? widget.onAttach : null,
                  tooltip: 'Attach a photo',
                  icon: const Icon(Icons.photo_camera_outlined),
                ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled,
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(hintText: widget.hintText),
                ),
              ),
              SizedBox(width: tokens.space2),
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton.filled(
                  onPressed: widget.enabled && _hasContent ? _send : null,
                  tooltip: 'Send',
                  icon: const Icon(Icons.arrow_upward, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
