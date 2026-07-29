import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/features/auth/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Sign-up (spec M2): .edu email -> verification code
/// screen. Premium UI with gradient background and
/// polished form fields.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  bool _obscurePassword = true;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeCtrl,
      curve: Curves.easeOut,
    );
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final email = _email.text.trim();
    try {
      await ref
          .read(authRepositoryProvider)
          .register(
            email: email,
            password: _password.text,
            displayName: _name.text.trim(),
          );
      if (!mounted) return;
      context.go('/verify', extra: email);
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    cs.primary.withValues(alpha: 0.08),
                    cs.surface,
                    cs.surface,
                  ]
                : [
                    cs.primary.withValues(alpha: 0.06),
                    cs.primaryContainer
                        .withValues(alpha: 0.04),
                    cs.surface,
                  ],
            stops: const [0.0, 0.35, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xxl,
              ),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    autovalidateMode:
                        AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(
                          height: AppSpacing.lg,
                        ),
                        // --- Logo ---
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end:
                                    Alignment.bottomRight,
                                colors: [
                                  cs.primary,
                                  cs.tertiary,
                                ],
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                AppRadius.xl,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: cs.primary
                                      .withValues(
                                    alpha: 0.25,
                                  ),
                                  blurRadius: 20,
                                  offset:
                                      const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: AppSpacing.xl,
                        ),
                        // --- Title ---
                        Text(
                          'Create your account',
                          style: tt.headlineMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: AppSpacing.sm,
                        ),
                        Text(
                          'Join your campus community',
                          style: tt.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: AppSpacing.xxxl,
                        ),
                        // --- Display name ---
                        TextFormField(
                          controller: _name,
                          textCapitalization:
                              TextCapitalization.words,
                          textInputAction:
                              TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Display name',
                            hintText: 'How others see you',
                            prefixIcon: Icon(
                              Icons.person_outline_rounded,
                              color: cs.onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                          validator: (v) =>
                              (v == null ||
                                      v.trim().length < 2)
                                  ? 'Enter your name'
                                  : null,
                        ),
                        const SizedBox(
                          height: AppSpacing.lg,
                        ),
                        // --- Email ---
                        TextFormField(
                          controller: _email,
                          keyboardType:
                              TextInputType.emailAddress,
                          textInputAction:
                              TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.email,
                          ],
                          decoration: InputDecoration(
                            labelText:
                                'Campus email (.edu)',
                            hintText: 'you@campus.edu',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: cs.onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                          validator: (v) {
                            final value =
                                v?.trim() ?? '';
                            if (value.isEmpty) {
                              return 'Enter your '
                                  'campus email';
                            }
                            if (!value.contains('@')) {
                              return 'That does not look '
                                  'like an email';
                            }
                            if (!value.endsWith('.edu')) {
                              return 'Use your .edu '
                                  'campus email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: AppSpacing.lg,
                        ),
                        // --- Password ---
                        TextFormField(
                          controller: _password,
                          obscureText: _obscurePassword,
                          textInputAction:
                              TextInputAction.done,
                          autofillHints: const [
                            AutofillHints.newPassword,
                          ],
                          decoration: InputDecoration(
                            labelText: 'Password',
                            helperText:
                                'At least 8 characters',
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color: cs.onSurfaceVariant,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons
                                        .visibility_outlined
                                    : Icons
                                        .visibility_off_outlined,
                                color:
                                    cs.onSurfaceVariant,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword =
                                    !_obscurePassword,
                              ),
                            ),
                          ),
                          validator: (v) =>
                              (v == null || v.length < 8)
                                  ? 'Use at least '
                                      '8 characters'
                                  : null,
                          onFieldSubmitted: (_) =>
                              _submitting
                                  ? null
                                  : _submit(),
                        ),
                        const SizedBox(
                          height: AppSpacing.xl,
                        ),
                        // --- Terms notice ---
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: Text(
                            'By creating an account, you '
                            'agree to our Terms of Service '
                            'and Privacy Policy.',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(
                          height: AppSpacing.lg,
                        ),
                        // --- Submit button ---
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed: _submitting
                                ? null
                                : _submit,
                            style:
                                FilledButton.styleFrom(
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                            ),
                            child: _submitting
                                ? const SizedBox.square(
                                    dimension: 22,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color:
                                          Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Create account',
                                    style: tt.labelLarge
                                        ?.copyWith(
                                      color:
                                          cs.onPrimary,
                                      fontWeight:
                                          FontWeight
                                              .w700,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(
                          height: AppSpacing.xxxl,
                        ),
                        // --- Sign in link ---
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: tt.bodyMedium
                                  ?.copyWith(
                                color:
                                    cs.onSurfaceVariant,
                              ),
                            ),
                            GestureDetector(
                              onTap: _submitting
                                  ? null
                                  : () => context
                                      .go('/login'),
                              child: Text(
                                'Sign in',
                                style: tt.bodyMedium
                                    ?.copyWith(
                                  color: cs.primary,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: AppSpacing.xl,
                        ),
                      ],
                    ),
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
