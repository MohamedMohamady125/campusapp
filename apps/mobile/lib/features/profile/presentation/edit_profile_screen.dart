import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/auth/data/auth_repository.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Edit profile (QA M-06): display name + optional year/major/bio via
/// PATCH /users/me. Empty optional fields are sent as '' (not omitted) so
/// clearing a field actually clears it server-side.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _year;
  late final TextEditingController _major;
  late final TextEditingController _bio;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    _name = TextEditingController(text: user?.displayName ?? '');
    _year = TextEditingController(text: user?.year ?? '');
    _major = TextEditingController(text: user?.major ?? '');
    _bio = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _year.dispose();
    _major.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .updateProfile(
            displayName: _name.text.trim(),
            year: _year.text.trim(),
            major: _major.text.trim(),
            bio: _bio.text.trim(),
          );
      await ref.read(authControllerProvider.notifier).refreshProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.')),
      );
      context.pop();
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(tokens.space4),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    counterText: '',
                  ),
                  validator: (v) => (v ?? '').trim().length < 2
                      ? 'Use at least 2 characters'
                      : null,
                ),
                SizedBox(height: tokens.space4),
                TextFormField(
                  controller: _year,
                  maxLength: 20,
                  decoration: const InputDecoration(
                    labelText: 'Year (optional)',
                    hintText: 'e.g. Junior',
                    counterText: '',
                  ),
                ),
                SizedBox(height: tokens.space4),
                TextFormField(
                  controller: _major,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 120,
                  decoration: const InputDecoration(
                    labelText: 'Major (optional)',
                    hintText: 'e.g. Computer Science',
                    counterText: '',
                  ),
                ),
                SizedBox(height: tokens.space4),
                TextFormField(
                  controller: _bio,
                  maxLength: 1000,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Bio (optional)',
                    hintText: 'A line or two about you',
                    alignLabelWithHint: true,
                  ),
                ),
                SizedBox(height: tokens.space6),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colors.onPrimary,
                          ),
                        )
                      : const Text('Save changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
