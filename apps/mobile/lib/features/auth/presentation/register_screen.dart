import 'dart:async' show unawaited;
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/core/legal.dart';
import 'package:campusconnect/core/validation.dart';
import 'package:campusconnect/design_system/components/trot_mark.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_colors.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Sign-up (spec M2): .edu email -> verification code screen.
/// Fifty Free: flat white surfaces, hairline borders, no gradients.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _emailFocus = FocusNode();
  bool _submitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  // Errors appear only after the first submit attempt — typing in one
  // field must never flash "empty" errors on the others.
  bool _triedSubmit = false;
  // true = this email already has an account (blur check).
  bool? _emailTaken;
  String _checkedEmail = '';
  String _passwordValue = '';
  String _confirmValue = '';
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: Durations.medium2);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    unawaited(_fadeCtrl.forward());
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) unawaited(_checkEmailTaken());
    });
  }

  /// On email blur: warn right away if this email already has an account,
  /// instead of failing at submit time.
  Future<void> _checkEmailTaken() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@') || email == _checkedEmail) {
      return;
    }
    _checkedEmail = email;
    try {
      final exists = await ref.read(authRepositoryProvider).emailExists(email);
      if (!mounted || _email.text.trim() != email) return;
      setState(() => _emailTaken = exists);
    } on Object {
      // Convenience check only — never block sign-up on a network blip.
      if (mounted) setState(() => _emailTaken = null);
    }
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _fadeCtrl.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _triedSubmit = true);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final email = _email.text.trim();
    final displayName = '${_firstName.text.trim()} ${_lastName.text.trim()}'
        .trim();
    try {
      await ref
          .read(authRepositoryProvider)
          .register(
            email: email,
            password: _password.text,
            displayName: displayName,
          );
      if (!mounted) return;
      context.go('/verify', extra: (email, _password.text));
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// Tappable legal-page span (QA M-10) — opens the hosted page in the
  /// device browser. WidgetSpan avoids gesture-recognizer lifecycle fuss.
  InlineSpan _legalLink(BuildContext context, String label, Uri url) =>
      WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: GestureDetector(
          onTap: () => unawaited(openLegalUrl(url)),
          child: Text(
            label,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.primary,
              decoration: TextDecoration.underline,
              height: 1.4,
            ),
          ),
        ),
      );

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
                  autovalidateMode: _triedSubmit
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: tokens.space4),
                      // --- Brand mark (Trot "t" + Drop-off dot, UX #9) ---
                      const Center(child: TrotMark(size: 56)),
                      SizedBox(height: tokens.space6),
                      // --- Title ---
                      Text(
                        'Create your account',
                        style: AppTextStyles.heading,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: tokens.space2),
                      Text(
                        'Join your campus community',
                        style: text.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: tokens.space12),
                      // --- First name + Last name (side by side) ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstName,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'First name',
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  color: colors.onSurfaceVariant,
                                  size: 20,
                                ),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                          SizedBox(width: tokens.space3),
                          Expanded(
                            child: TextFormField(
                              controller: _lastName,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Last name',
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: tokens.space4),
                      // --- Email ---
                      TextFormField(
                        controller: _email,
                        focusNode: _emailFocus,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        onChanged: (_) {
                          if (_emailTaken != null) {
                            setState(() => _emailTaken = null);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Campus email (.edu)',
                          hintText: 'you@campus.edu',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: colors.onSurfaceVariant,
                            size: 20,
                          ),
                          helperText: (_emailTaken ?? false)
                              ? 'This email already has an account. Sign in '
                                    'instead.'
                              : null,
                          helperStyle: (_emailTaken ?? false)
                              ? text.bodySmall?.copyWith(color: colors.error)
                              : null,
                        ),
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) {
                            return 'Enter your campus email';
                          }
                          // QA M-01: "sharif@.edu" must fail here — a bare
                          // `.edu` suffix check let it through to the server.
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
                      // --- Password ---
                      TextFormField(
                        controller: _password,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        onChanged: (v) => setState(() => _passwordValue = v),
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
                        // Mirrors the API rules (schemas/auth.py
                        // _check_password_complexity) so failures surface
                        // inline, not as a server round-trip.
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
                      ),
                      SizedBox(height: tokens.space3),
                      // --- Live password requirements checklist ---
                      _PasswordRequirements(password: _passwordValue),
                      SizedBox(height: tokens.space4),
                      // --- Confirm password ---
                      TextFormField(
                        controller: _confirmPassword,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Confirm password',
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: colors.onSurfaceVariant,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            tooltip: _obscureConfirm
                                ? 'Show password'
                                : 'Hide password',
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: colors.onSurfaceVariant,
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                        ),
                        onChanged: (v) => setState(() => _confirmValue = v),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (v != _password.text) {
                            return "Passwords don't match";
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _submitting ? null : _submit(),
                      ),
                      // Live match indicator — only appears once the user
                      // has typed something in the confirm field.
                      if (_confirmValue.isNotEmpty) ...[
                        SizedBox(height: tokens.space2),
                        _MatchIndicator(
                          matches: _confirmValue == _passwordValue,
                        ),
                      ],
                      SizedBox(height: tokens.space6),
                      // --- Terms notice ---
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: tokens.space2,
                        ),
                        // QA M-10: the legal names must actually open the
                        // hosted pages, not sit there as dead text.
                        child: Text.rich(
                          TextSpan(
                            text: 'By creating an account, you agree to our ',
                            children: [
                              _legalLink(
                                context,
                                'Terms of Service',
                                kTermsUrl,
                              ),
                              const TextSpan(text: ' and '),
                              _legalLink(
                                context,
                                'Privacy Policy',
                                kPrivacyUrl,
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                          style: text.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant.withValues(
                              alpha: 0.7,
                            ),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: tokens.space4),
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
                            : const Text('Create account'),
                      ),
                      SizedBox(height: tokens.space8),
                      // --- Sign in link ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              'Already have an account? ',
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
                                : () => context.go('/login'),
                            child: const Text('Sign in'),
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

/// Live checklist of password rules — each line flips to a green check as
/// the user satisfies it (industry-standard sign-up affordance).
class _PasswordRequirements extends StatelessWidget {
  const _PasswordRequirements({required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final rules = <(String, bool)>[
      ('At least 8 characters', password.length >= 8),
      ('One uppercase letter', password.contains(RegExp('[A-Z]'))),
      ('One lowercase letter', password.contains(RegExp('[a-z]'))),
      ('One number', password.contains(RegExp('[0-9]'))),
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.space2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (label, met) in rules)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.space1),
              child: _RequirementRow(label: label, met: met),
            ),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final color = met ? AppColors.success : colors.onSurfaceVariant;
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: text.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

/// Single-row indicator shown below the confirm-password field as soon as
/// the user starts typing. Flips from a grey "no match" state to a green
/// check the moment both fields are identical.
class _MatchIndicator extends StatelessWidget {
  const _MatchIndicator({required this.matches});

  final bool matches;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = matches ? AppColors.success : colors.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(
            matches ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            matches ? 'Passwords match' : "Passwords don't match yet",
            style: context.text.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
