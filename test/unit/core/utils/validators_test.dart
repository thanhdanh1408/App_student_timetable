import 'package:flutter_test/flutter_test.dart';
import 'package:student_timetable_app/core/utils/validators.dart';

void main() {
  group('FormValidator', () {
    test('validateRequired returns failure for empty value', () {
      final result = FormValidator.validateRequired('   ', 'Field');
      expect(result.isFailure(), true);
    });

    test('validateRequired returns success for non-empty value', () {
      final result = FormValidator.validateRequired('abc', 'Field');
      expect(result.isSuccess(), true);
    });

    test('validateOptionalLength allows empty string', () {
      final result = FormValidator.validateOptionalLength('', 'Notes', 20);
      expect(result.isSuccess(), true);
    });

    test('validateOptionalLength fails for oversized value', () {
      final result = FormValidator.validateOptionalLength('x' * 21, 'Notes', 20);
      expect(result.isFailure(), true);
    });

    test('validateNumberRange passes in range', () {
      final result = FormValidator.validateNumberRange(8.5, 'Score', 0, 10);
      expect(result.isSuccess(), true);
    });

    test('validateNumberRange fails out of range', () {
      final result = FormValidator.validateNumberRange(11, 'Score', 0, 10);
      expect(result.isFailure(), true);
    });

    test('validateTimeRange fails when start after end', () {
      final result = FormValidator.validateTimeRange('10:00', '09:00');
      expect(result.isFailure(), true);
    });

    test('validateTimeRange passes for valid range', () {
      final result = FormValidator.validateTimeRange('08:00', '09:30');
      expect(result.isSuccess(), true);
    });
  });
}
