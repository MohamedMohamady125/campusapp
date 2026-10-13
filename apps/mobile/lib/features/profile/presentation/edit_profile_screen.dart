import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/auth/data/auth_repository.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Edit profile: name + email only. Email is immutable (verified campus
/// identity). Name is changeable exactly once per lifetime — enforced
/// server-side (`name_locked`); the field locks here after the rename.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    _name = TextEditingController(text: user?.displayName ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .updateProfile(displayName: _name.text.trim());
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
    final user = ref.watch(authControllerProvider).user;
    final nameLocked = user?.nameLocked ?? false;

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
                  enabled: !nameLocked,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 80,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    counterText: '',
                    helperText: nameLocked
                        ? 'Name was changed once — now locked.'
                        : 'You can change your name once.',
                    suffixIcon: nameLocked
                        ? const Icon(Icons.lock_outline, size: 20)
                        : null,
                  ),
                  validator: (v) => (v ?? '').trim().length < 2
                      ? 'Use at least 2 characters'
                      : null,
                ),
                SizedBox(height: tokens.space4),
                TextFormField(
                  initialValue: user?.email ?? '',
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Campus email',
                    helperText: 'Verified identity — cannot change.',
                    suffixIcon: Icon(Icons.lock_outline, size: 20),
                  ),
                ),
                SizedBox(height: tokens.space6),
                FilledButton(
                  onPressed: (_saving || nameLocked) ? null : _save,
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
