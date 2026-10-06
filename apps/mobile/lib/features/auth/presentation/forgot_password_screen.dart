import 'dart:async' show unawaited;
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/core/validation.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Forgot-password flow (QA M-11): email → 6-digit code + new password.
/// Uses the real /auth/forgot-password + /auth/reset-password endpoints;
/// the API always answers 200 on step 1 so account existence never leaks.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  bool _obscurePassword = true;
  bool _triedSubmit = false;
  // false = asking for the email; true = asking for code + new password.
  bool _codeSent = false;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    setState(() => _triedSubmit = true);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .forgotPassword(email: _email.text.trim());
      if (!mounted) return;
      setState(() {
        _codeSent = true;
        _triedSubmit = false;
      });
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resetPassword() async {
    setState(() => _triedSubmit = true);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .resetPassword(
            email: _email.text.trim(),
            code: _code.text.trim(),
            newPassword: _password.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated — sign in with your new password.'),
        ),
      );
      context.go('/login');
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            apiErrorMessage(e, fallback: 'That code did not work — try again.'),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/login')),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space6,
              vertical: tokens.space8,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                autovalidateMode: _triedSubmit
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Reset your password',
                      style: AppTextStyles.heading,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: tokens.space2),
                    Text(
                      _codeSent
                          ? 'Enter the 6-digit code we sent to '
                                '${_email.text.trim()} and pick a new '
                                'password.'
                          : "Enter your campus email and we'll send you a "
                                'reset code.',
                      style: text.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: tokens.space8),
                    TextFormField(
                      controller: _email,
                      enabled: !_codeSent,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Campus email',
                        hintText: 'you@campus.edu',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: colors.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isEmpty) return 'Enter your email';
                        if (!kEmailPattern.hasMatch(value)) {
                          return 'That does not look like an email';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        if (!_codeSent && !_submitting) unawaited(_sendCode());
                      },
                    ),
                    if (_codeSent) ...[
                      SizedBox(height: tokens.space4),
                      TextFormField(
                        controller: _code,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Reset code',
                          hintText: '6-digit code',
                          counterText: '',
                          prefixIcon: Icon(
                            Icons.pin_outlined,
                            color: colors.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                        validator: (v) =>
                            ((v ?? '').trim().length == 6)
                                ? null
                                : 'Enter the 6-digit code',
                      ),
                      SizedBox(height: tokens.space4),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscurePassword,
                        autofillHints: const [AutofillHints.newPassword],
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'New password',
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: colors.onSurfaceVariant,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: colors.onSurfaceVariant,
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        // Mirrors the API password rules (schemas/auth.py).
                        validator: (v) {
                          final value = v ?? '';
                          if (value.length < 8) {
                            return 'Use at least 8 characters';
                          }
                          if (!value.contains(RegExp('[A-Z]'))) {
                            return 'Add an uppercase letter';
                          }
                          if (!value.contains(RegExp('[a-z]'))) {
                            return 'Add a lowercase letter';
                          }
                          if (!value.contains(RegExp('[0-9]'))) {
                            return 'Add a number';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          if (!_submitting) unawaited(_resetPassword());
                        },
                      ),
                    ],
                    SizedBox(height: tokens.space6),
                    FilledButton(
                      onPressed: _submitting
                          ? null
                          : (_codeSent ? _resetPassword : _sendCode),
                      child: _submitting
                          ? SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: colors.onPrimary,
                              ),
                            )
                          : Text(
                              _codeSent ? 'Reset password' : 'Send reset code',
                            ),
                    ),
                    if (_codeSent) ...[
                      SizedBox(height: tokens.space2),
                      TextButton(
                        onPressed: _submitting ? null : _sendCode,
                        child: const Text('Resend code'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
