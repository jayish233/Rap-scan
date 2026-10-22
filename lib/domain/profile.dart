/// Profile, health info and their validators (PRD §7.9). Pure Dart.
library;

import '../l10n/strings.dart';

enum Gender {
  unspecified('', 'Prefer not to say'),
  female('female', 'Female'),
  male('male', 'Male'),
  nonBinary('non_binary', 'Non-binary'),
  other('other', 'Other');

  const Gender(this.wire, this.label);
  final String wire;
  final String label;

  static Gender fromWire(String? value) =>
      Gender.values.firstWhere((g) => g.wire == (value ?? ''), orElse: () => Gender.unspecified);
}

/// The signed-in user's profile. Plan fields are read-only for the client.
class Profile {
  const Profile({
    required this.id,
    this.email,
    this.username,
    this.gender = Gender.unspecified,
    this.age,
    this.weightKg,
    this.heightCm,
    this.illnesses = '',
    this.allergies = '',
  });

  final String id;
  final String? email;
  final String? username;
  final Gender gender;
  final int? age;
  final double? weightKg;
  final double? heightCm;
  final String illnesses;
  final String allergies;

  double? get bmi => computeBmi(weightKg, heightCm);
}

/// Editable profile fields (never plan or quota columns).
class ProfileUpdate {
  const ProfileUpdate({
    required this.username,
    required this.gender,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.illnesses,
    required this.allergies,
  });

  final String? username;
  final Gender gender;
  final int? age;
  final double? weightKg;
  final double? heightCm;
  final String illnesses;
  final String allergies;
}

final _usernamePattern = RegExp(r'^[A-Za-z0-9_]{3,20}$');

/// 3–20 letters, numbers or underscore; empty clears the username.
String? validateUsername(String value) {
  final v = value.trim();
  if (v.isEmpty) return null;
  return _usernamePattern.hasMatch(v) ? null : Strings.usernameFormatError;
}

String? validateAge(String value) {
  final v = value.trim();
  if (v.isEmpty) return null;
  final n = int.tryParse(v);
  return n != null && n >= 1 && n <= 129 ? null : Strings.ageError;
}

String? validateWeight(String value) => _range(value, max: 500, error: Strings.weightError);

String? validateHeight(String value) => _range(value, max: 300, error: Strings.heightError);

String? _range(String value, {required double max, required String error}) {
  final v = value.trim();
  if (v.isEmpty) return null;
  final n = double.tryParse(v);
  return n != null && n > 0 && n < max ? null : error;
}

String? validateFreeText(String value) => value.length <= 500 ? null : Strings.freeTextTooLong;

/// BMI = weight / (height in metres)², or null unless both are valid.
double? computeBmi(double? weightKg, double? heightCm) {
  if (weightKg == null || heightCm == null || weightKg <= 0 || heightCm <= 0) return null;
  final m = heightCm / 100;
  return weightKg / (m * m);
}

/// One decimal, e.g. "22.0".
String formatBmi(double bmi) => bmi.toStringAsFixed(1);
