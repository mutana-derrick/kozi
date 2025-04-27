// lib/utils/form_validation.dart
import 'package:flutter/material.dart';

class FormValidation {
  // Generic validation for required fields
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    // Check for valid email format
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Simple phone number validation - can be customized based on country format
    if (value.length < 10) {
      return 'Enter a valid phone number';
    }
    
    return null;
  }

  // Required dropdown validation
  static String? validateDropdown(String? value, String fieldName) {
    if (value == null || value.isEmpty || 
        value.contains('Select') || 
        value == 'DD/MM/YYYY') {
      return 'Please select a $fieldName';
    }
    return null;
  }
}

// Extension to help with styling
extension InputDecorationExtension on InputDecoration {
  // Create error-styled decoration
  static InputDecoration withValidationError(
    String? errorText, {
    String? hintText,
    Widget? suffixIcon,
    EdgeInsetsGeometry? contentPadding,
  }) {
    final hasError = errorText != null;
    
    return InputDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon,
      contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: hasError ? Colors.red : const Color(0xFFEA60A7), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      errorText: errorText,
      errorStyle: const TextStyle(color: Colors.red),
    );
  }
}

// Color constants to use consistently for validation
class ValidationColors {
  static const errorRed = Color(0xFFE53935);
  static const errorRedLight = Color(0xFFFFEBEE);
  static const errorRedBorder = Color(0xFFEF9A9A);
  static const primaryPink = Color(0xFFEA60A7);
}