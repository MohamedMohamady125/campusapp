import 'dart:async' show unawaited;
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_colors.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Login — Fifty Free: flat white, hairline borders, no gradients or
/// shadows. Forgiving form: inline validation, preserved input, submit
/// disabled only while in-flight.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  bool _obscurePassword = true;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: Durations.medium2);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    unawaited(_fadeCtrl.forward());
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .logIn(email: _email.text.trim(), password: _password.text);
      // Router guard redirects on auth state change.
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space6,
              vertical: tokens.space8,
            ),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: tokens.space6),
                      // --- Wordmark (flat, hairline — Fifty Free) ---
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: ShapeDecoration(
                            color: AppColors.primaryBg,
                            shape: RoundedRectangleBorder(
                              borderRadius: tokens.brMd,
                              side: const BorderSide(
                                color: AppColors.primaryBorder,
                              ),
                            ),
                          ),
                          child: const Icon(
                            Icons.school_outlined,
                            color: AppColors.primaryDark,
                            size: 30,
                          ),
                        ),
                      ),
                      SizedBox(height: tokens.space6),
                      // --- Title ---
                      Text(
                        'CampusConnect',
                        style: AppTextStyles.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: tokens.space2),
                      Text(
                        'Sign in with your campus email',
                        style: text.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: tokens.space12),
                      // --- Email field ---
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.next,
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
                          if (value.isEmpty) {
                            return 'Enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'That does not look like an email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: tokens.space4),
                      // --- Password field ---
                      TextFormField(
                        controller: _password,
                        obscureText: _obscurePassword,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Password',
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
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Enter your password'
                            : null,
                        onFieldSubmitted: (_) => _submitting ? null : _submit(),
                      ),
                      // --- Forgot password (link — Law 3 allows primary) ---
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(top: tokens.space2),
                          child: TextButton(
                            onPressed: _submitting
                                ? null
                                : () => context.go('/forgot-password'),
                            child: const Text('Forgot password?'),
                          ),
                        ),
                      ),
                      SizedBox(height: tokens.space6),
                      // --- Submit button (theme = blue pill, 52dp) ---
                      FilledButton(
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: colors.onPrimary,
                                ),
                              )
                            : const Text('Sign in'),
                      ),
                      SizedBox(height: tokens.space8),
                      // --- Register link ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              'New here? ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _submitting
                                ? null
                                : () => context.go('/register'),
                            child: const Text('Create an account'),
                          ),
                        ],
                      ),
                      SizedBox(height: tokens.space6),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
