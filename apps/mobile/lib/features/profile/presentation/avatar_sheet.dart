import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/food_runs/data/runs_repository.dart';
import 'package:campusconnect/shared/image_normalizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Profile-photo bottom sheet (Uber-style trust: requesters see who brings
/// their food). Camera-first selfie, uploaded + saved via PATCH /users/me,
/// profile refreshed before the sheet pops. Returns true once a photo is up.
///
/// Used as the Start-a-run gate (server enforces AVATAR_REQUIRED) and from
/// Profile to change the photo anytime — a sheet instead of an inline form
/// card, so the run form stays clean for the 99% who already have one.
Future<bool> showAvatarSheet(BuildContext context, {bool gate = false}) async {
  final added = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (_) => _AvatarSheet(gate: gate),
  );
  return added ?? false;
}

class _AvatarSheet extends ConsumerStatefulWidget {
  const _AvatarSheet({required this.gate});

  /// True when posting a run is blocked on the photo — copy says why.
  final bool gate;

  @override
  ConsumerState<_AvatarSheet> createState() => _AvatarSheetState();
}

class _AvatarSheetState extends ConsumerState<_AvatarSheet> {
  final _picker = ImagePicker();
  bool _uploading = false;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 90,
      preferredCameraDevice: CameraDevice.front,
    );
    if (file == null || !mounted) return;
    setState(() {
      _uploading = true;
      _error = null;
    });
    try {
      // Any photo, any size: EXIF-rotate, square-crop, downscale, compress.
      final normalized = await normalizeAvatar(await file.readAsBytes());
      await ref
          .read(runsRepositoryProvider)
          .uploadAvatar(
            bytes: normalized.bytes,
            contentType: normalized.contentType,
          );
      await ref.read(authControllerProvider.notifier).refreshProfile();
      if (mounted) Navigator.of(context).pop(true);
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _uploading = false;
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
          tokens.space4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.gate ? 'Add a profile photo' : 'Update your photo',
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.space1),
            Text(
              widget.gate
                  ? 'Required to post a run — people see who '
                        'brings their food.'
                  : 'This is what requesters see.',
              style: context.text.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (_error != null) ...[
              SizedBox(height: tokens.space2),
              Text(
                _error!,
                style: context.text.bodySmall?.copyWith(color: colors.error),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: tokens.space4),
            if (_uploading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              FilledButton.icon(
                onPressed: () => _pick(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Take a selfie'),
              ),
              SizedBox(height: tokens.space2),
              OutlinedButton.icon(
                onPressed: () => _pick(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Choose from photos'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
