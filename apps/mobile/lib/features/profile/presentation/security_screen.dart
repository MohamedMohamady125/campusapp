import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/core/validation.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/auth/data/auth_repository.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Account security: change password (rotates every session, keeps this
/// device signed in) and change email (code sent to the NEW .edu address).
class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  // --- Change password ---
  final _passwordFormKey = GlobalKey<FormState>();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _changingPassword = false;

  // --- Change email ---
  final _emailFormKey = GlobalKey<FormState>();
  final _newEmail = TextEditingController();
  final _emailPassword = TextEditingController();
  final _emailCode = TextEditingController();
  bool _obscureEmailPassword = true;
  bool _codeSent = false;
  bool _changingEmail = false;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _newEmail.dispose();
    _emailPassword.dispose();
    _emailCode.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    setState(() => _changingPassword = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .changePassword(
            currentPassword: _currentPassword.text,
            newPassword: _newPassword.text,
          );
      if (!mounted) return;
      _snack('Password updated. Other devices were signed out.');
      context.pop();
    } on Object catch (e) {
      if (!mounted) return;
      _snack(apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _changingPassword = false);
    }
  }

  Future<void> _submitEmailChange() async {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() => _changingEmail = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      if (!_codeSent) {
        await repo.requestEmailChange(
          newEmail: _newEmail.text.trim(),
          password: _emailPassword.text,
        );
        if (!mounted) return;
        setState(() => _codeSent = true);
        _snack('Code sent to ${_newEmail.text.trim()}.');
      } else {
        await repo.confirmEmailChange(code: _emailCode.text.trim());
        await ref.read(authControllerProvider.notifier).refreshProfile();
        if (!mounted) return;
        _snack('Email updated.');
        context.pop();
      }
    } on Object catch (e) {
      if (!mounted) return;
      _snack(apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _changingEmail = false);
    }
  }

  String? _validateNewPassword(String? v) {
    final value = v ?? '';
    if (value.length < 8) return 'Use at least 8 characters';
    if (!value.contains(RegExp('[A-Z]'))) return 'Add an uppercase letter';
    if (!value.contains(RegExp('[a-z]'))) return 'Add a lowercase letter';
    if (!value.contains(RegExp('[0-9]'))) return 'Add a number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final email = ref.watch(authControllerProvider).user?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(tokens.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Change password', style: context.text.titleMedium),
              SizedBox(height: tokens.space3),
              Form(
                key: _passwordFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _currentPassword,
                      obscureText: _obscureCurrent,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Current password',
                        suffixIcon: IconButton(
                          tooltip: _obscureCurrent
                              ? 'Show password'
                              : 'Hide password',
                          icon: Icon(
                            _obscureCurrent
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscureCurrent = !_obscureCurrent,
                          ),
                        ),
                      ),
                      validator: (v) => (v ?? '').isEmpty
                          ? 'Enter your current password'
                          : null,
                    ),
                    SizedBox(height: tokens.space4),
                    TextFormField(
                      controller: _newPassword,
                      obscureText: _obscureNew,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: 'New password',
                        suffixIcon: IconButton(
                          tooltip: _obscureNew
                              ? 'Show password'
                              : 'Hide password',
                          icon: Icon(
                            _obscureNew
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscureNew = !_obscureNew),
                        ),
                      ),
                      validator: _validateNewPassword,
                      onFieldSubmitted: (_) =>
                          _changingPassword ? null : _changePassword(),
                    ),
                    SizedBox(height: tokens.space4),
                    FilledButton(
                      onPressed: _changingPassword ? null : _changePassword,
                      child: _changingPassword
                          ? SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: colors.onPrimary,
                              ),
                            )
                          : const Text('Update password'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: tokens.space6),
              Divider(color: colors.outlineVariant),
              SizedBox(height: tokens.space6),
              Text('Change email', style: context.text.titleMedium),
              SizedBox(height: tokens.space1),
              Text(
                'Signed in as $email',
                style: context.text.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: tokens.space3),
              Form(
                key: _emailFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _newEmail,
                      enabled: !_codeSent,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'New campus email (.edu)',
                        hintText: 'you@campus.edu',
                      ),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isEmpty) return 'Enter your new email';
                        if (!kEmailPattern.hasMatch(value)) {
                          return 'That does not look like an email';
                        }
                        if (!value.endsWith('.edu')) {
                          return 'Use your .edu campus email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: tokens.space4),
                    if (!_codeSent)
                      TextFormField(
                        controller: _emailPassword,
                        obscureText: _obscureEmailPassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            tooltip: _obscureEmailPassword
                                ? 'Show password'
                                : 'Hide password',
                            icon: Icon(
                              _obscureEmailPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _obscureEmailPassword =
                                  !_obscureEmailPassword,
                            ),
                          ),
                        ),
                        validator: (v) =>
                            (v ?? '').isEmpty ? 'Enter your password' : null,
                      )
                    else
                      TextFormField(
                        controller: _emailCode,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          labelText: '6-digit code',
                          helperText: 'Check your new email inbox',
                          counterText: '',
                        ),
                        validator: (v) =>
                            RegExp(r'^\d{6}$').hasMatch(v?.trim() ?? '')
                            ? null
                            : 'Enter the 6-digit code',
                      ),
                    SizedBox(height: tokens.space4),
                    FilledButton.tonal(
                      onPressed: _changingEmail ? null : _submitEmailChange,
                      child: _changingEmail
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(_codeSent ? 'Confirm code' : 'Send code'),
                    ),
                    if (_codeSent) ...[
                      SizedBox(height: tokens.space2),
                      TextButton(
                        onPressed: _changingEmail
                            ? null
                            : () => setState(() {
                                _codeSent = false;
                                _emailCode.clear();
                              }),
                        child: const Text('Use a different email'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
