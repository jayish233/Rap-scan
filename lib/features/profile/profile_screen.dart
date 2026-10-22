import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/session.dart';
import '../../app/theme.dart';
import '../../data/auth_repository.dart';
import '../../data/profile_repository.dart';
import '../../domain/profile.dart';
import '../../l10n/strings.dart';
import '../../widgets/adaptive.dart';
import '../../widgets/common.dart';
import '../plans/plans_sheet.dart';

/// Profile (handoff spec §4.7, mockups ios/android-profile): display name,
/// plan card with progress, private health info with live BMI, sign out.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final ios = isIos(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            ContentWidth(
              padding: EdgeInsets.symmetric(horizontal: ios ? 20 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ScreenHeader(title: Strings.navProfile),
                  const SizedBox(height: 14),
                  switch (profile) {
                    AsyncData(:final value) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (value.stale) const OfflineBanner(),
                          _ProfileForm(key: ValueKey(value.value.id), profile: value.value),
                        ],
                      ),
                    AsyncError() => ErrorState(message: Strings.loadFailed, onRetry: () => ref.invalidate(profileProvider)),
                    _ => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
                  },
                  const SizedBox(height: 14),
                  const _PlanCard(),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        final auth = ref.read(authRepositoryProvider);
                        // Leave the gated tab first so sign-out lands on Home, not Auth.
                        context.go(Routes.home);
                        auth.signOut();
                      },
                      style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                      child: Text(
                        Strings.signOut,
                        style: TextStyle(fontFamily: AppFonts.body, fontSize: ios ? 16 : 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const DisclaimerFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Plan card (mockups): plan name, "N of M scans left", progress bar,
/// accent Upgrade button and the "payments coming soon" price line.
class _PlanCard extends ConsumerWidget {
  const _PlanCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quota = ref.watch(quotaProvider).value;
    final text = Theme.of(context).textTheme;
    final ios = isIos(context);
    final fraction = quota == null || quota.isUnlimited ? 1.0 : (quota.remaining / quota.scanLimit).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ios ? AppColors.surface : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: ios ? Border.all(color: AppColors.border) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                quota == null ? Strings.planTitle : Strings.planName(quota.planLabel),
                style: text.titleMedium,
              ),
              if (quota != null)
                Text(
                  quota.isUnlimited ? Strings.unlimitedScans : Strings.scansLeftOf(quota.remaining, quota.scanLimit),
                  style: text.bodySmall?.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w600, fontSize: 13),
                ),
            ],
          ),
          SizedBox(height: ios ? 10 : 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(ios ? 4 : 2),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: ios ? 8 : 4,
              backgroundColor: ios ? AppColors.segmentTrack : AppColors.borderStrong,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          SizedBox(height: ios ? 12 : 14),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppAccentButton(label: Strings.upgrade, expand: false, onPressed: () => showPlansSheet(context)),
              Text(
                Strings.planPriceLine,
                style: text.bodySmall?.copyWith(color: AppColors.textMuted, height: 1.4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({super.key, required this.profile});

  final Profile profile;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  final _form = GlobalKey<FormState>();
  late final _username = TextEditingController(text: widget.profile.username ?? '');
  late final _age = TextEditingController(text: widget.profile.age?.toString() ?? '');
  late final _weight = TextEditingController(text: _num(widget.profile.weightKg));
  late final _height = TextEditingController(text: _num(widget.profile.heightCm));
  late final _conditions = TextEditingController(text: widget.profile.illnesses);
  late final _allergies = TextEditingController(text: widget.profile.allergies);
  late Gender _gender = widget.profile.gender;
  String? _usernameServerError;
  bool _saving = false;

  static String _num(double? v) => v == null ? '' : (v == v.roundToDouble() ? v.toInt().toString() : v.toString());

  @override
  void initState() {
    super.initState();
    // Live BMI.
    _weight.addListener(_rebuild);
    _height.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    for (final c in [_username, _age, _weight, _height, _conditions, _allergies]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _parse(TextEditingController c) => double.tryParse(c.text.trim());

  Future<void> _save() async {
    setState(() => _usernameServerError = null);
    if (!_form.currentState!.validate()) return;
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(profileRepositoryProvider).saveProfile(
            userId,
            ProfileUpdate(
              username: _username.text,
              gender: _gender,
              age: int.tryParse(_age.text.trim()),
              weightKg: _parse(_weight),
              heightCm: _parse(_height),
              illnesses: _conditions.text,
              allergies: _allergies.text,
            ),
          );
      if (!mounted) return;
      showToast(context, Strings.profileSaved);
    } on UsernameTaken {
      if (mounted) setState(() => _usernameServerError = Strings.usernameTaken);
    } catch (_) {
      if (mounted) showToast(context, Strings.profileSaveFailed, error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ios = isIos(context);
    final bmi = computeBmi(_parse(_weight), _parse(_height));
    final weightOk = validateWeight(_weight.text) == null;
    final heightOk = validateHeight(_height.text) == null;

    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ios) ..._iosFields(bmi, weightOk, heightOk) else ..._androidFields(bmi, weightOk, heightOk),
          const SizedBox(height: 16),
          AppPrimaryButton(label: Strings.saveProfile, onPressed: _save, busy: _saving),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: AppColors.danger), const SizedBox(width: 6)],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }

  // --- iOS: grouped cards with inline rows. ---

  List<Widget> _iosFields(double? bmi, bool weightOk, bool heightOk) {
    final text = Theme.of(context).textTheme;

    Widget group(List<Widget> rows) {
      final children = <Widget>[];
      for (var i = 0; i < rows.length; i++) {
        children.add(rows[i]);
        if (i < rows.length - 1) children.add(const Divider(height: 1, indent: 16));
      }
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(children: children),
      );
    }

    Widget valueRow(String label, TextEditingController controller, String? Function(String) validator,
        {TextInputType? keyboard, bool numeric = false}) {
      return SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(label, style: const TextStyle(fontFamily: AppFonts.body, fontSize: 15, fontWeight: FontWeight.w600)),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  enabled: !_saving,
                  keyboardType: keyboard,
                  textAlign: TextAlign.right,
                  validator: (v) => validator(v ?? ''),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                    isCollapsed: true,
                  ),
                  style: const TextStyle(fontFamily: AppFonts.body, fontSize: 16, color: AppColors.text),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return [
      _sectionLabel(Strings.displayNameTitle.toUpperCase()),
      group([
        SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(Strings.usernameLabel, style: TextStyle(fontFamily: AppFonts.body, fontSize: 15, fontWeight: FontWeight.w600)),
                const Spacer(),
                const Text('@', style: TextStyle(fontFamily: AppFonts.body, fontSize: 16, color: AppColors.textMuted)),
                const SizedBox(width: 4),
                SizedBox(
                  width: 160,
                  child: TextFormField(
                    key: const ValueKey('profile-username'),
                    controller: _username,
                    enabled: !_saving,
                    autocorrect: false,
                    maxLength: 20,
                    validator: (v) => validateUsername(v ?? ''),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      filled: false,
                      isCollapsed: true,
                      counterText: '',
                      errorText: _usernameServerError,
                      errorStyle: const TextStyle(height: 0, fontSize: 0),
                    ),
                    style: const TextStyle(fontFamily: AppFonts.body, fontSize: 16, color: AppColors.text),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
      if (_usernameServerError != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
          child: Text(_usernameServerError!, style: text.bodySmall?.copyWith(color: AppColors.danger)),
        ),
      const FieldHelper(text: Strings.usernameHelpShort),
      const SizedBox(height: 14),
      _sectionLabel(Strings.healthInfoTitle.toUpperCase(), icon: Icons.favorite),
      group([
        SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(Strings.genderLabel, style: TextStyle(fontFamily: AppFonts.body, fontSize: 15, fontWeight: FontWeight.w600)),
                const Spacer(),
                DropdownButtonHideUnderline(
                  child: DropdownButton<Gender>(
                    key: const ValueKey('profile-gender'),
                    value: _gender,
                    borderRadius: BorderRadius.circular(14),
                    items: [for (final g in Gender.values) DropdownMenuItem(value: g, child: Text(g.label))],
                    onChanged: _saving ? null : (g) => setState(() => _gender = g ?? Gender.unspecified),
                    icon: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                    style: const TextStyle(fontFamily: AppFonts.body, fontSize: 15, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
        valueRow(Strings.ageLabel, _age, validateAge, keyboard: TextInputType.number),
        valueRow(Strings.weightLabel, _weight, validateWeight, keyboard: const TextInputType.numberWithOptions(decimal: true)),
        valueRow(Strings.heightLabel, _height, validateHeight, keyboard: const TextInputType.numberWithOptions(decimal: true)),
        SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('BMI', style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textMuted)),
                const Spacer(),
                if (bmi != null && weightOk && heightOk)
                  Semantics(
                    liveRegion: true,
                    child: Text(formatBmi(bmi), style: const TextStyle(fontFamily: AppFonts.display, fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ),
        ),
      ]),
      const FieldHelper(text: Strings.healthInfoHelp),
      const SizedBox(height: 14),
      _sectionLabel(Strings.conditionsLabel.toUpperCase()),
      TextFormField(
        key: const ValueKey('profile-conditions'),
        controller: _conditions,
        enabled: !_saving,
        maxLength: 500,
        minLines: 2,
        maxLines: 4,
        validator: (v) => validateFreeText(v ?? ''),
        decoration: appInputDecoration(context, hint: Strings.conditionsHint),
        buildCounter: (_, {required currentLength, required isFocused, required maxLength}) => null,
      ),
      const SizedBox(height: 14),
      _sectionLabel(Strings.allergiesLabel.toUpperCase()),
      TextFormField(
        key: const ValueKey('profile-allergies'),
        controller: _allergies,
        enabled: !_saving,
        maxLength: 500,
        minLines: 2,
        maxLines: 4,
        validator: (v) => validateFreeText(v ?? ''),
        decoration: appInputDecoration(context, hint: Strings.allergiesHint),
        buildCounter: (_, {required currentLength, required isFocused, required maxLength}) => null,
      ),
    ];
  }

  // --- Android: outlined fields with floating labels. ---

  List<Widget> _androidFields(double? bmi, bool weightOk, bool heightOk) {
    final text = Theme.of(context).textTheme;
    return [
      TextFormField(
        key: const ValueKey('profile-username'),
        controller: _username,
        enabled: !_saving,
        autocorrect: false,
        maxLength: 20,
        validator: (v) => validateUsername(v ?? ''),
        decoration: appInputDecoration(context, label: Strings.usernameLabel, prefixIcon: Icons.alternate_email, error: _usernameServerError),
        buildCounter: (_, {required currentLength, required isFocused, required maxLength}) => null,
      ),
      const FieldHelper(text: Strings.usernameHelpShort),
      const SizedBox(height: 18),
      Row(
        children: [
          const Icon(Icons.favorite, size: 20, color: AppColors.danger),
          const SizedBox(width: 8),
          Expanded(child: Text(Strings.healthInfoTitle, style: text.titleLarge?.copyWith(fontSize: 20))),
        ],
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(4, 4, 4, 0),
        child: FieldHelper(text: Strings.healthInfoHelp),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<Gender>(
        key: const ValueKey('profile-gender'),
        initialValue: _gender,
        isExpanded: true,
        decoration: appInputDecoration(context, label: Strings.genderLabel),
        items: [
          for (final g in Gender.values)
            DropdownMenuItem(value: g, child: Text(g.label, overflow: TextOverflow.ellipsis)),
        ],
        onChanged: _saving ? null : (g) => setState(() => _gender = g ?? Gender.unspecified),
      ),
      const SizedBox(height: 16),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              key: const ValueKey('profile-age'),
              controller: _age,
              enabled: !_saving,
              keyboardType: TextInputType.number,
              validator: (v) => validateAge(v ?? ''),
              decoration: appInputDecoration(context, label: Strings.ageLabel),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              key: const ValueKey('profile-weight'),
              controller: _weight,
              enabled: !_saving,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => validateWeight(v ?? ''),
              decoration: appInputDecoration(context, label: Strings.weightLabel),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              key: const ValueKey('profile-height'),
              controller: _height,
              enabled: !_saving,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => validateHeight(v ?? ''),
              decoration: appInputDecoration(context, label: Strings.heightLabel),
            ),
          ),
        ],
      ),
      if (bmi != null && weightOk && heightOk) ...[
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Semantics(
            liveRegion: true,
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('BMI', style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(width: 8),
                  Text(formatBmi(bmi), style: const TextStyle(fontFamily: AppFonts.display, fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
      ],
      const SizedBox(height: 16),
      TextFormField(
        key: const ValueKey('profile-conditions'),
        controller: _conditions,
        enabled: !_saving,
        maxLength: 500,
        minLines: 2,
        maxLines: 4,
        validator: (v) => validateFreeText(v ?? ''),
        decoration: appInputDecoration(context, label: Strings.conditionsLabel, hint: Strings.conditionsHint),
        buildCounter: (_, {required currentLength, required isFocused, required maxLength}) => null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        key: const ValueKey('profile-allergies'),
        controller: _allergies,
        enabled: !_saving,
        maxLength: 500,
        minLines: 2,
        maxLines: 4,
        validator: (v) => validateFreeText(v ?? ''),
        decoration: appInputDecoration(context, label: Strings.allergiesLabel, hint: Strings.allergiesHint),
        buildCounter: (_, {required currentLength, required isFocused, required maxLength}) => null,
      ),
    ];
  }
}
