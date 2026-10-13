import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/auth/data/auth_repository.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Email verification: 6-digit code (spec §3 VerificationCode, 10-min expiry).
/// After a correct code the user is logged in immediately — no separate login
/// step required (the verify endpoint proves identity, so we can issue tokens
/// right away by calling login() with the password carried from the register
/// screen through the route extra).
class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({required this.email, required this.password, super.key});

  final String email;
  final String password;

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
      // 1. Verify the code — marks email_verified_at on the server.
      await ref
          .read(authRepositoryProvider)
          .verify(email: widget.email, code: _code.text.trim());
      // 2. Log in through the controller (NOT the bare repository) so auth
      // state flips to authenticated and the router guard redirects to /runs.
      // Calling repo.login() directly stores tokens but never updates state —
      // the screen would spin forever.
      await ref
          .read(authControllerProvider.notifier)
          .logIn(email: widget.email, password: widget.password);
    } on Object catch (e) {
      if (!mounted) return;
      _toast(apiErrorMessage(e));
      setState(() => _submitting = false);
    }
    // No setState(_submitting = false) on success — the route is replaced
    // by the guard before the widget would rebuild.
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
    final tokens = context.tokens;
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your email')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(tokens.space4),
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
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: tokens.space6),
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
                    SizedBox(height: tokens.space4),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Verify'),
                    ),
                    SizedBox(height: tokens.space3),
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
