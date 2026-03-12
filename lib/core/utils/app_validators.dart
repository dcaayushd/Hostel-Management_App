class AppValidators {
  const AppValidators._();

  static String? requiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required.';
    }
    return null;
  }

  static String? email(String? value) {
    final String? baseValidation = requiredField(value, 'Email');
    if (baseValidation != null) {
      return baseValidation;
    }
    final RegExp emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(value!.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? emailOrPhone(String? value) {
    final String? baseValidation = requiredField(value, 'Email or phone');
    if (baseValidation != null) {
      return baseValidation;
    }
    final String trimmed = value!.trim();
    final RegExp emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    final RegExp phonePattern = RegExp(r'^\d{10}$');
    if (!emailPattern.hasMatch(trimmed) && !phonePattern.hasMatch(trimmed)) {
      return 'Enter a valid email address or 10 digit phone number.';
    }
    return null;
  }

  static String? password(String? value) {
    final String? baseValidation = requiredField(value, 'Password');
    if (baseValidation != null) {
      return baseValidation;
    }
    if (value!.trim().length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  static String? phoneNumber(String? value) {
    final String? baseValidation = requiredField(value, 'Phone number');
    if (baseValidation != null) {
      return baseValidation;
    }
    final RegExp phonePattern = RegExp(r'^\d{10}$');
    if (!phonePattern.hasMatch(value!.trim())) {
      return 'Enter a 10 digit phone number.';
    }
    return null;
  }

  static String? verificationCode(String? value) {
    final String? baseValidation = requiredField(value, 'Verification code');
    if (baseValidation != null) {
      return baseValidation;
    }
    final RegExp codePattern = RegExp(r'^\d{6}$');
    if (!codePattern.hasMatch(value!.trim())) {
      return 'Enter the 6 digit code.';
    }
    return null;
  }
}
