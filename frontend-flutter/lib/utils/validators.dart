import 'constants.dart';

/// Form validation utilities for the application
class Validators {
  /// Validates phone number (Indian format: 10 digits, starts with 6-9)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.fieldRequiredMessage;
    }

    // Remove all spaces and special characters
    final cleanedPhone = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanedPhone.length != AppConstants.maxPhoneLength) {
      return 'Phone number must be ${AppConstants.maxPhoneLength} digits';
    }

    if (!RegExp(AppConstants.phoneNumberRegex).hasMatch(cleanedPhone)) {
      return AppConstants.invalidPhoneMessage;
    }

    return null;
  }

  /// Validates OTP (6 digits)
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.fieldRequiredMessage;
    }

    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP must contain only digits';
    }

    return null;
  }

  /// Validates full name
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.fieldRequiredMessage;
    }

    if (value.length < AppConstants.minNameLength) {
      return 'Name must be at least ${AppConstants.minNameLength} characters';
    }

    if (value.length > AppConstants.maxNameLength) {
      return 'Name must not exceed ${AppConstants.maxNameLength} characters';
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    // Check that it's not just spaces
    if (value.trim().isEmpty) {
      return AppConstants.fieldRequiredMessage;
    }

    return null;
  }

  /// Validates email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.fieldRequiredMessage;
    }

    if (!RegExp(AppConstants.emailRegex).hasMatch(value)) {
      return AppConstants.invalidEmailMessage;
    }

    return null;
  }

  /// Validates email or allows it to be empty (optional field)
  static String? validateEmailOptional(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    if (!RegExp(AppConstants.emailRegex).hasMatch(value)) {
      return AppConstants.invalidEmailMessage;
    }

    return null;
  }

  /// Validates city name
  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.fieldRequiredMessage;
    }

    if (value.length < AppConstants.minCityLength) {
      return 'City name must be at least ${AppConstants.minCityLength} characters';
    }

    if (value.length > AppConstants.maxCityLength) {
      return 'City name must not exceed ${AppConstants.maxCityLength} characters';
    }

    // Check for valid characters
    if (!RegExp(r'^[a-zA-Z\s\-]+$').hasMatch(value)) {
      return 'City name can only contain letters, spaces, and hyphens';
    }

    return null;
  }

  /// Validates dropdown selection
  static String? validateDropdown(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.fieldRequiredMessage;
    }
    return null;
  }

  /// Validates budget/investment amount (minimum 0)
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    try {
      final amount = double.parse(value);
      if (amount < 0) {
        return 'Amount must be a positive number';
      }
    } catch (e) {
      return 'Please enter a valid amount';
    }

    return null;
  }

  /// Validates referral number (optional, same format as phone)
  static String? validateReferralNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final cleanedPhone = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanedPhone.length != AppConstants.maxPhoneLength) {
      return 'Referral number must be ${AppConstants.maxPhoneLength} digits';
    }

    if (!RegExp(AppConstants.phoneNumberRegex).hasMatch(cleanedPhone)) {
      return 'Please enter a valid referral number';
    }

    return null;
  }

  /// Validates profile type selection
  static String? validateProfileType(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.fieldRequiredMessage;
    }

    if (!AppConstants.profileTypes.contains(value)) {
      return 'Please select a valid profile type';
    }

    return null;
  }

  /// Validates password (optional: at least 8 chars, mix of upper, lower, digit)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.fieldRequiredMessage;
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one digit';
    }

    return null;
  }
}
