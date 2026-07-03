import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/features/auth/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Email verification: 6-digit code (spec §3 VerificationCode, 10-min expiry).
class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({required this.email, super.key});

  final String email;

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _toast(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .verify(email: widget.email, code: _code.text.trim());
      if (!mounted) return;
      _toast('Email verified — sign in to continue.');
      context.go('/login');
    } on Object catch (e) {
      if (!mounted) return;
      _toast(apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resend() async {
    try {
      await ref.read(authRepositoryProvider).resendCode(email: widget.email);
      if (!mounted) return;
      _toast('New code sent to ${widget.email}.');
    } on Object catch (e) {
      if (!mounted) return;
      _toast(apiErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your email')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'We sent a 6-digit code to\n${widget.email}',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TextFormField(
                      controller: _code,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        labelText: 'Verification code',
                        counterText: '',
                      ),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.length != 6 || int.tryParse(value) == null) {
                          return 'Enter the 6-digit code';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _submitting ? null : _submit(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Verify'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: _submitting ? null : _resend,
                      child: const Text('Resend code'),
                    ),
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
