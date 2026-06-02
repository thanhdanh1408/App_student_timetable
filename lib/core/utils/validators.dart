import '../errors/failure.dart';
import '../utils/result.dart';

/// Form and input validators for all forms
class FormValidator {
  FormValidator._(); // Private constructor to prevent instantiation

  /// Validate email format
  static Result<String> validateEmail(String email) {
    if (email.isEmpty) {
      return FailureResult(ValidationFailure(message: 'Email is required'));
    }
    if (!_isValidEmail(email)) {
      return FailureResult(
        ValidationFailure(message: 'Please enter a valid email address'),
      );
    }
    return Success(email);
  }

  /// Validate password strength (min 6 characters)
  static Result<String> validatePassword(String password) {
    if (password.isEmpty) {
      return FailureResult(ValidationFailure(message: 'Password is required'));
    }
    if (password.length < 6) {
      return FailureResult(
        ValidationFailure(message: 'Password must be at least 6 characters long'),
      );
    }
    return Success(password);
  }

  /// Validate required string (non-empty)
  static Result<String> validateRequired(String value, String fieldName) {
    if (value.trim().isEmpty) {
      return FailureResult(
        ValidationFailure(message: '$fieldName is required'),
      );
    }
    return Success(value.trim());
  }

  /// Validate string length
  static Result<String> validateLength(
    String value,
    String fieldName,
    int minLength,
    int maxLength,
  ) {
    if (value.trim().isEmpty) {
      return FailureResult(
        ValidationFailure(message: '$fieldName is required'),
      );
    }
    if (value.length < minLength) {
      return FailureResult(
        ValidationFailure(
          message: '$fieldName must be at least $minLength characters long',
        ),
      );
    }
    if (value.length > maxLength) {
      return FailureResult(
        ValidationFailure(
          message: '$fieldName cannot exceed $maxLength characters',
        ),
      );
    }
    return Success(value.trim());
  }

  /// Validate optional string length (allows empty)
  static Result<String?> validateOptionalLength(
    String value,
    String fieldName,
    int maxLength,
  ) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return const Success(null);
    if (trimmed.length > maxLength) {
      return FailureResult(
        ValidationFailure(
          message: '$fieldName cannot exceed $maxLength characters',
        ),
      );
    }
    return Success(trimmed);
  }

  /// Validate number range
  static Result<double> validateNumberRange(
    double value,
    String fieldName,
    double min,
    double max,
  ) {
    if (value < min || value > max) {
      return FailureResult(
        ValidationFailure(
          message: '$fieldName must be between $min and $max',
        ),
      );
    }
    return Success(value);
  }

  /// Validate time format (HH:mm)
  static Result<String> validateTimeFormat(String time) {
    if (time.isEmpty) {
      return FailureResult(ValidationFailure(message: 'Time is required'));
    }
    final pattern = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!pattern.hasMatch(time)) {
      return FailureResult(
        ValidationFailure(message: 'Please enter time in HH:mm format'),
      );
    }
    return Success(time);
  }

  /// Validate that start time is before end time
  static Result<String> validateTimeRange(String startTime, String endTime) {
    final startResult = validateTimeFormat(startTime);
    final endResult = validateTimeFormat(endTime);

    if (startResult.isFailure()) return startResult;
    if (endResult.isFailure()) return endResult;

    final startHour = int.parse(startTime.split(':')[0]);
    final startMin = int.parse(startTime.split(':')[1]);
    final endHour = int.parse(endTime.split(':')[0]);
    final endMin = int.parse(endTime.split(':')[1]);

    final startInMinutes = startHour * 60 + startMin;
    final endInMinutes = endHour * 60 + endMin;

    if (startInMinutes >= endInMinutes) {
      return FailureResult(
        ValidationFailure(message: 'Start time must be before end time'),
      );
    }

    return Success('$startTime-$endTime');
  }

  /// Validate day of week (0-6)
  static Result<int> validateDayOfWeek(int dayOfWeek) {
    if (dayOfWeek < 0 || dayOfWeek > 6) {
      return FailureResult(ValidationFailure(message: 'Invalid day of week'));
    }
    return Success(dayOfWeek);
  }

  /// Validate that fields are equal (e.g., password confirmation)
  static Result<String> validateFieldsMatch(
    String value1,
    String value2,
    String fieldName,
  ) {
    if (value1 != value2) {
      return FailureResult(
        ValidationFailure(message: '$fieldName do not match'),
      );
    }
    return Success(value1);
  }

  /// Validate credit value
  static Result<int> validateCredit(int credit) {
    if (credit < 1 || credit > 4) {
      return FailureResult(
        ValidationFailure(message: 'Credit must be between 1 and 4'),
      );
    }
    return Success(credit);
  }

  /// Validate subject name
  static Result<String> validateSubjectName(String name) {
    return validateLength(name, 'Subject name', 1, 100);
  }

  /// Validate teacher name
  static Result<String> validateTeacherName(String name) {
    return validateLength(name, 'Teacher name', 1, 100);
  }

  /// Validate room/location
  static Result<String> validateLocation(String location) {
    return validateLength(location, 'Location', 1, 50);
  }

  /// Validate hex color format
  static Result<String> validateHexColor(String color) {
    if (color.isEmpty) {
      return FailureResult(ValidationFailure(message: 'Color is required'));
    }
    if (!_isValidHexColor(color)) {
      return FailureResult(
        ValidationFailure(
          message: 'Please enter a valid hex color (e.g., #FF0000)',
        ),
      );
    }
    return Success(color);
  }

  // Helper methods
  static bool _isValidEmail(String email) {
    final pattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return pattern.hasMatch(email);
  }

  static bool _isValidHexColor(String color) {
    final pattern = RegExp(r'^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');
    return pattern.hasMatch(color);
  }
}

// Legacy validators (keep for backward compatibility)
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email không được để trống';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Mật khẩu không được để trống';
    if (value.length < 6) return 'Mật khẩu phải ít nhất 6 ký tự';
    return null;
  }
}