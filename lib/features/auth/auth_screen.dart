import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../l10n/strings.dart';
import '../../widgets/adaptive.dart';
import '../../widgets/brand.dart';
import '../../widgets/common.dart';
import 'auth_controller.dart';

/// Sign in / Create account (handoff spec §4.1, mockups ios/android-signin).
/// Brand lockup, Welcome back title, platform mode switch, platform fields,
/// primary button, footer disclaimer.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref.read(authControllerProvider.notifier).submit(email: _email.text, password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(authControllerProvider);
    final isSignIn = form.mode == AuthMode.signIn;
    final ios = isIos(context);
    final text = Theme.of(context).textTheme;

    ref.listen(authControllerProvider.select((s) => s.error), (_, error) {
      if (error != null) showToast(context, error, error: true);
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: ContentWidth(
                  padding: EdgeInsets.fromLTRB(24, ios ? 24 : 32, 24, 0),
                  child: Form(
                    key: _formKey,
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              BrandMark(size: ios ? 44 : 48),
                              SizedBox(width: ios ? 10 : 12),
                              const Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Wordmark(fontSize: 26),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ios ? 22 : 24),
                          Semantics(
                            header: true,
                            child: Text(isSignIn ? Strings.welcomeBack : Strings.createAccount, style: pageTitleStyle(context)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isSignIn ? Strings.signInSubtitle : Strings.createAccountSubtitle,
                            style: (ios ? text.bodyMedium : text.bodyLarge)?.copyWith(color: AppColors.textMuted),
                          ),
                          SizedBox(height: ios ? 22 : 24),
                          AppSegmented<AuthMode>(
                            options: const [(AuthMode.signIn, Strings.signIn, null), (AuthMode.signUp, Strings.createAccount, null)],
                            selected: form.mode,
                            onChanged: form.busy ? null : (_) => ref.read(authControllerProvider.notifier).toggleMode(),
                          ),
                          SizedBox(height: ios ? 22 : 20),
                          ios ? _iosFormCard(form) : _androidFields(form),
                          if (form.error != null) ...[
                            const SizedBox(height: 12),
                            Semantics(
                              liveRegion: true,
                              child: Text(form.error!, style: text.bodyMedium?.copyWith(color: AppColors.danger)),
                            ),
                          ],
                          if (form.notice != null) ...[
                            const SizedBox(height: 12),
                            Semantics(
                              liveRegion: true,
                              child: Text(form.notice!, style: text.bodyMedium?.copyWith(color: AppColors.primary)),
                            ),
                          ],
                          SizedBox(height: ios ? 22 : 20),
                          AppPrimaryButton(
                            label: isSignIn ? Strings.signIn : Strings.createAccount,
                            onPressed: _submit,
                            busy: form.busy,
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: form.busy ? null : ref.read(authControllerProvider.notifier).toggleMode,
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              height: 48,
                              child: Center(
                                child: Text.rich(
                                  TextSpan(
                                    style: text.bodyMedium?.copyWith(color: AppColors.textMuted),
                                    children: [
                                      TextSpan(text: isSignIn ? Strings.newToRapscanz : '${Strings.haveAccount.split('?').first}? '),
                                      TextSpan(
                                        text: isSignIn ? Strings.createAnAccount : Strings.signIn,
                                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 16),
              child: Text(
                '${Strings.createAccountSubtitle}\n${Strings.disclaimer}',
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(color: AppColors.textMuted, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// iOS grouped card with the 5px leaf-green offset shadow (brand detail).
  Widget _iosFormCard(AuthFormState form) {
    Widget row({
      required String label,
      required TextEditingController controller,
      required String? Function(String) validator,
      bool obscure = false,
      TextInputType? keyboard,
      TextInputAction? action,
      List<String>? autofill,
      bool last = false,
    }) {
      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: last ? null : const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 76,
              child: Text(label, style: const TextStyle(fontFamily: AppFonts.body, fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            Expanded(
              child: TextFormField(
                controller: controller,
                obscureText: obscure && !_showPassword,
                keyboardType: keyboard,
                textInputAction: action,
                autofillHints: autofill,
                autocorrect: false,
                enabled: !form.busy,
                validator: (v) => validator(v ?? ''),
                onFieldSubmitted: last ? (_) => _submit() : null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontFamily: AppFonts.body, fontSize: 16, color: AppColors.text),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: AppColors.accent, offset: AppSizes.hardShadowOffsetLarge, blurRadius: 0)],
      ),
      child: Column(
        children: [
          row(
            label: Strings.email,
            controller: _email,
            validator: validateEmail,
            keyboard: TextInputType.emailAddress,
            action: TextInputAction.next,
            autofill: const [AutofillHints.email],
          ),
          row(
            label: Strings.password,
            controller: _password,
            validator: validatePassword,
            obscure: true,
            action: TextInputAction.done,
            autofill: [form.mode == AuthMode.signIn ? AutofillHints.password : AutofillHints.newPassword],
            last: true,
          ),
        ],
      ),
    );
  }

  /// Android outlined fields with prefix icons and an eye toggle.
  Widget _androidFields(AuthFormState form) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          autocorrect: false,
          enabled: !form.busy,
          validator: (v) => validateEmail(v ?? ''),
          decoration: appInputDecoration(context, label: Strings.email, prefixIcon: Icons.mail_outline),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _password,
          obscureText: !_showPassword,
          textInputAction: TextInputAction.done,
          autofillHints: [form.mode == AuthMode.signIn ? AutofillHints.password : AutofillHints.newPassword],
          enabled: !form.busy,
          validator: (v) => validatePassword(v ?? ''),
          onFieldSubmitted: (_) => _submit(),
          decoration: appInputDecoration(
            context,
            label: Strings.password,
            prefixIcon: Icons.lock_outline,
            suffix: IconButton(
              tooltip: _showPassword ? 'Hide password' : 'Show password',
              icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 22),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
        ),
        const FieldHelper(text: Strings.passwordHint),
      ],
    );
  }
}
