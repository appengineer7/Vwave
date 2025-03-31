final RegExp _emailRegExp = RegExp(
  r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
);
final RegExp numberRegExp = RegExp(r'^\d+$'); // RegExp fto validate numbers

String? emailValidator(String? email, [bool allowEmpty = false]) {
  String e = email?.trim() ?? '';
  if (e.isEmpty) {
    return allowEmpty ? null : '* Please enter an email address';
  } else if (!_emailRegExp.hasMatch(e)) {
    return '* Please enter a valid email address';
  }
  return null;
}

String? textValidator(String? text) {
  String e = text ?? "";
  if (e.isEmpty) {
    return '* This field cannot be empty';
  }
  return null;
}

String? newpasswordValidator(String? password) {
  // String p = password?.trim();
  if (password?.isEmpty ?? true) {
    return '* Please enter password';
  } else if (password!.length < 8) {
    return '* Password must be at least 8 characters';
  } else if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$')
      .hasMatch(password)) {
    return '* Password is too weak';
  }
  return null;
}

String? otpValidator(String? text) {
  text = text?.trim() ?? '';
  if (text.isEmpty) {
    return '* Otp must be  6 digits';
  } else if (!numberRegExp.hasMatch(text) || text.length != 6) {
    return '* Otp must be  6 digits';
  }
  return null;
}

String? numberValidator(String? text) {
  text = text?.trim() ?? '';

  if (text.isEmpty) {
    return '* Please enter a valid number';
  }
  if (double.parse(text) == 0) {
    return '* Please enter an amount greater than zero';
  }
  return null;
}
