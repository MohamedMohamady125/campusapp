import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/design_system/components/fade_slide_in.dart';
import 'package:campusconnect/design_system/components/pressable.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_motion.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/food_runs/data/runs_repository.dart';
import 'package:campusconnect/features/food_runs/presentation/payment_method_display.dart';
import 'package:campusconnect/shared/image_normalizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// First-run dasher gate — the "get set up to dash" moment.
///
/// A dasher can NEVER post a run without (1) a profile photo and (2) at
/// least one payment handle, so the one time they're missing we turn setup
/// into a two-step animated sheet instead of two scattered nags:
///
///   Step 1 · selfie  — people see who brings their food.
///   Step 2 · handle  — people pay this directly, with a loud
///                      "make sure it matches your real handle" warning.
///
/// Steps the dasher already satisfied are skipped. Returns true only when
/// everything required is in place (photo uploaded + handle saved).
Future<bool> showDasherSetupSheet(
  BuildContext context, {
  required bool needsPhoto,
  required bool needsHandle,
}) async {
  if (!needsPhoto && !needsHandle) return true;
  final done = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _DasherSetupSheet(
      needsPhoto: needsPhoto,
      needsHandle: needsHandle,
    ),
  );
  return done ?? false;
}

class _DasherSetupSheet extends ConsumerStatefulWidget {
  const _DasherSetupSheet({
    required this.needsPhoto,
    required this.needsHandle,
  });

  final bool needsPhoto;
  final bool needsHandle;

  @override
  ConsumerState<_DasherSetupSheet> createState() => _DasherSetupSheetState();
}

class _DasherSetupSheetState extends ConsumerState<_DasherSetupSheet> {
  final _picker = ImagePicker();
  final _handle = TextEditingController();

  late bool _photoDone = !widget.needsPhoto;
  late bool _handleDone = !widget.needsHandle;
  bool _busy = false;
  String? _error;
  PaymentMethodType _type = kSelectablePaymentTypes.first;

  /// Which step is on screen: photo first if missing, else handle.
  bool get _onPhotoStep => !_photoDone;

  int get _stepsTotal =>
      (widget.needsPhoto ? 1 : 0) + (widget.needsHandle ? 1 : 0);

  int get _stepNow => _onPhotoStep ? 1 : _stepsTotal;

  @override
  void dispose() {
    _handle.dispose();
    super.dispose();
  }

  void _finishIfDone() {
    if (_photoDone && _handleDone) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {}); // advance to the next step
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 90,
      preferredCameraDevice: CameraDevice.front,
    );
    if (file == null || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final normalized = await normalizeAvatar(await file.readAsBytes());
      await ref
          .read(runsRepositoryProvider)
          .uploadAvatar(
            bytes: normalized.bytes,
            contentType: normalized.contentType,
          );
      await ref.read(authControllerProvider.notifier).refreshProfile();
      if (!mounted) return;
      _photoDone = true;
      _busy = false;
      _finishIfDone();
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = apiErrorMessage(e);
        });
      }
    }
  }

  Future<void> _saveHandle() async {
    final handle = _handle.text.trim();
    if (handle.length < 2) {
      setState(() => _error = 'Enter the handle people will pay.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(runsRepositoryProvider).savePaymentMethods([
        PaymentMethod(
          (b) => b
            ..type = _type
            ..handle = handle,
        ),
      ]);
      if (!mounted) return;
      _handleDone = true;
      _busy = false;
      _finishIfDone();
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = apiErrorMessage(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          tokens.space4,
          0,
          tokens.space4,
          // Keep the handle field above the keyboard.
          tokens.space4 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeSlideIn(child: _header(context)),
            SizedBox(height: tokens.space4),
            if (_stepsTotal > 1) ...[
              FadeSlideIn(index: 1, child: _progress(context)),
              SizedBox(height: tokens.space4),
            ],
            if (_error != null) ...[
              Text(
                _error!,
                style: context.text.bodySmall?.copyWith(color: colors.error),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: tokens.space2),
            ],
            // The active step slides in from the right as steps complete.
            AnimatedSwitcher(
              duration: AppMotion.resolve(context, AppMotion.enter),
              switchInCurve: AppMotion.decelerate,
              switchOutCurve: AppMotion.accelerate,
              transitionBuilder: (child, animation) {
                final entering =
                    (child.key == const ValueKey('photo')) == _onPhotoStep;
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(entering ? 0.15 : -0.15, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _onPhotoStep
                  ? _PhotoStep(
                      key: const ValueKey('photo'),
                      busy: _busy,
                      onPick: _pickPhoto,
                    )
                  : _HandleStep(
                      key: const ValueKey('handle'),
                      busy: _busy,
                      type: _type,
                      handle: _handle,
                      onTypeChanged: (t) => setState(() => _type = t),
                      onSave: _saveHandle,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    return Column(
      children: [
        // Coral badge pops in — the "you're about to become a dasher" moment.
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: AppMotion.resolve(context, AppMotion.screen),
          curve: Curves.easeOutBack,
          builder: (context, v, child) =>
              Transform.scale(scale: v, child: child),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_run,
              size: 32,
              color: colors.onPrimaryContainer,
            ),
          ),
        ),
        SizedBox(height: tokens.space3),
        Text(
          'Before your first run',
          textAlign: TextAlign.center,
          style: context.text.titleLarge,
        ),
        SizedBox(height: tokens.space1),
        Text(
          _stepsTotal > 1
              ? 'Two quick things so people trust you — and can pay you.'
              : _onPhotoStep
              ? 'One quick thing so people see who brings their food.'
              : 'One quick thing so people can pay you.',
          textAlign: TextAlign.center,
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Two-segment progress bar that fills as steps complete.
  Widget _progress(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    return Row(
      children: [
        for (var i = 1; i <= _stepsTotal; i++) ...[
          if (i > 1) SizedBox(width: tokens.space2),
          Expanded(
            child: AnimatedContainer(
              duration: AppMotion.resolve(context, AppMotion.micro),
              height: 4,
              decoration: BoxDecoration(
                color: i <= _stepNow ? colors.primary : colors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Step 1 — selfie. Camera-first; people see who brings their food.
class _PhotoStep extends StatelessWidget {
  const _PhotoStep({required this.busy, required this.onPick, super.key});

  final bool busy;
  final ValueChanged<ImageSource> onPick;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    if (busy) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Add a photo of yourself',
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: tokens.space1),
        Text(
          'Requesters see who is bringing their food — a clear face photo '
          'is required to dash.',
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: tokens.space4),
        FilledButton.icon(
          onPressed: () => onPick(ImageSource.camera),
          icon: const Icon(Icons.photo_camera_outlined),
          label: const Text('Take a selfie'),
        ),
        SizedBox(height: tokens.space2),
        OutlinedButton.icon(
          onPressed: () => onPick(ImageSource.gallery),
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Choose from photos'),
        ),
      ],
    );
  }
}

/// Step 2 — payment handle, with the match-your-real-handle warning.
class _HandleStep extends StatelessWidget {
  const _HandleStep({
    required this.busy,
    required this.type,
    required this.handle,
    required this.onTypeChanged,
    required this.onSave,
    super.key,
  });

  final bool busy;
  final PaymentMethodType type;
  final TextEditingController handle;
  final ValueChanged<PaymentMethodType> onTypeChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'How do people pay you?',
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: tokens.space1),
        Text(
          'Add at least one handle. You can add more later in Profile.',
          style: context.text.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: tokens.space3),
        Wrap(
          spacing: tokens.space2,
          runSpacing: tokens.space2,
          children: [
            for (final t in kSelectablePaymentTypes)
              Pressable(
                onTap: () => onTypeChanged(t),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.space3,
                    vertical: tokens.space2,
                  ),
                  decoration: ShapeDecoration(
                    color: t == type ? colors.primary : colors.surface,
                    shape: StadiumBorder(
                      side: t == type
                          ? BorderSide.none
                          : BorderSide(color: colors.outlineVariant),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        t.icon,
                        size: 16,
                        color: t == type ? Colors.white : colors.onSurface,
                      ),
                      SizedBox(width: tokens.space1),
                      Text(
                        t.label,
                        style: context.text.labelMedium?.copyWith(
                          fontWeight: t == type
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: t == type ? Colors.white : colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: tokens.space3),
        TextField(
          controller: handle,
          autofocus: true,
          decoration: InputDecoration(
            labelText: '${type.label} handle',
            hintText: type.handleHint,
          ),
        ),
        SizedBox(height: tokens.space3),
        // Loud money copy (payment terms are exempt from the copy diet):
        // a wrong handle sends someone else your money.
        Container(
          padding: EdgeInsets.all(tokens.space3),
          decoration: BoxDecoration(
            color: tokens.warningContainer,
            borderRadius: tokens.brSm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, size: 18, color: tokens.warning),
              SizedBox(width: tokens.space2),
              Expanded(
                child: Text(
                  'Make sure this matches your real ${type.label} handle '
                  'exactly — requesters send money to it directly.',
                  style: context.text.bodySmall?.copyWith(
                    color: tokens.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.space4),
        FilledButton(
          onPressed: busy ? null : onSave,
          child: busy
              ? const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : const Text('Save and start dashing'),
        ),
      ],
    );
  }
}
