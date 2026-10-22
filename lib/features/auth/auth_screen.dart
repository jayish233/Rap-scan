import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../l10n/strings.dart';
import '../../widgets/brand.dart';
import '../../widgets/common.dart';
import 'auth_controller.dart';

/// Sign in / Create account toggle (PRD §7.1, design.md §4.3).
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

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
    final title = isSignIn ? Strings.signIn : Strings.createAccount;
    final text = Theme.of(context).textTheme;

    ref.listen(authControllerProvider.select((s) => s.error), (_, error) {
      if (error != null) showToast(context, error, error: true);
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.canPop() ? context.pop() : context.go(Routes.home)),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: ContentWidth(
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    const Center(child: BrandMark(size: 64)),
                    const SizedBox(height: 16),
                    Semantics(
                      header: true,
                      child: Text(title, textAlign: TextAlign.center, style: text.headlineMedium),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: Strings.email),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      autocorrect: false,
                      enabled: !form.busy,
                      validator: (v) => validateEmail(v ?? ''),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      decoration: const InputDecoration(labelText: Strings.password, helperText: Strings.passwordHint),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: [isSignIn ? AutofillHints.password : AutofillHints.newPassword],
                      enabled: !form.busy,
                      validator: (v) => validatePassword(v ?? ''),
                      onFieldSubmitted: (_) => _submit(),
                    ),
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
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: form.busy ? null : _submit,
                      child: form.busy
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onPrimary),
                            )
                          : Text(title),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: form.busy ? null : ref.read(authControllerProvider.notifier).toggleMode,
                      child: Text(isSignIn ? Strings.needAccount : Strings.haveAccount),
                    ),
                    const DisclaimerFooter(),
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
