import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class PasswordStrength {
  const PasswordStrength({
    required this.minimumCharacters,
    required this.hasNumber,
    required this.hasUppercaseLetter,
    required this.hasLowercaseLetter,
  });

  final bool minimumCharacters;
  final bool hasNumber;
  final bool hasUppercaseLetter;
  final bool hasLowercaseLetter;

  PasswordStrength copyWith({
    bool? minimumCharacters,
    bool? hasNumber,
    bool? hasLowercaseLetter,
    bool? hasUppercaseLetter,
  }) {
    return PasswordStrength(
      minimumCharacters: minimumCharacters ?? this.minimumCharacters,
      hasNumber: hasNumber ?? this.hasNumber,
      hasUppercaseLetter: hasUppercaseLetter ?? this.hasUppercaseLetter,
      hasLowercaseLetter: hasLowercaseLetter ?? this.hasLowercaseLetter,
    );
  }
}

class PasswordStrengthNotifier extends Notifier<PasswordStrength> {
  // We initialize the list of todos to an empty list
  @override
  PasswordStrength build() {
    return const PasswordStrength(
      minimumCharacters: false,
      hasNumber: false,
      hasUppercaseLetter: false,
      hasLowercaseLetter: false,
    );
  }

  void update(String? password) {
    final text = password ?? "";

    print(text);
    final hasNumber = RegExp(r'[0-9]');
    final hasUppercaseLetter = RegExp(r"[A-Z]");
    final hasLowercaseLetter = RegExp(r"[a-z]");

    state = state.copyWith(
      minimumCharacters: text.length >= 8,
      hasNumber: text.contains(hasNumber),
      hasLowercaseLetter: text.contains(hasLowercaseLetter),
      hasUppercaseLetter: text.contains(hasUppercaseLetter),
    );
  }
}

final passwordStrengthNotifierProvider =
    NotifierProvider<PasswordStrengthNotifier, PasswordStrength>(() {
  return PasswordStrengthNotifier();
});
