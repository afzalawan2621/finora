import '../constants/app_strings.dart';

class Validators {
  Validators._();

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired(field);
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorEmailRequired;
    }
    final regex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return AppStrings.errorInvalidEmail;
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorPasswordRequired;
    }
    if (value.length < 6) return AppStrings.errorPasswordMinLength;
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorNameRequired;
    }
    if (value.trim().length < 3) {
      return AppStrings.errorNameTooShort;
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorConfirmPasswordRequired;
    }
    if (value != original) {
      return AppStrings.errorPasswordsDoNotMatch;
    }
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorAmountRequired;
    }
    final num = double.tryParse(value.trim());
    if (num == null || num <= 0) return AppStrings.errorInvalidAmount;
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorPhoneRequired;
    }
    // Sirf digits count karo (+ - space ignore)
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 10) {
      return AppStrings.errorInvalidPhone;
    }
    if (cleaned.length > 15) {
      return AppStrings.errorInvalidPhone;
    }
    return null;
  }

  static String? minLength(String? value, int len, {String field = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired(field);
    }
    if (value.trim().length < len) {
      return AppStrings.minLengthError(len);
    }
    return null;
  }
}