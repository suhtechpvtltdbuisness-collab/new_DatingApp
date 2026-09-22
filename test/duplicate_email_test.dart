import 'package:flutter_test/flutter_test.dart';
import 'package:dating_app/controllers/registration_controller.dart';
import 'package:dating_app/models/api_models.dart';

ApiResponse<String> _fail(String message, {int? statusCode, String? error}) =>
    ApiResponse<String>(
      success: false,
      message: message,
      statusCode: statusCode,
      error: error,
    );

void main() {
  group('isDuplicateEmailFailure', () {
    test('matches the common duplicate-email phrasings', () {
      expect(
        RegistrationController.isDuplicateEmailFailure(
          _fail('Email already exists'),
        ),
        isTrue,
      );
      expect(
        RegistrationController.isDuplicateEmailFailure(
          _fail('This email is already registered'),
        ),
        isTrue,
      );
      expect(
        RegistrationController.isDuplicateEmailFailure(
          _fail('Conflict', statusCode: 409, error: 'duplicate email key'),
        ),
        isTrue,
      );
    });

    test('ignores unrelated failures', () {
      expect(
        RegistrationController.isDuplicateEmailFailure(
          _fail('Phone number already exists'),
        ),
        isFalse,
      );
      expect(
        RegistrationController.isDuplicateEmailFailure(
          _fail('Invalid email format'),
        ),
        isFalse,
      );
      expect(
        RegistrationController.isDuplicateEmailFailure(
          ApiResponse<String>(success: true, message: 'ok'),
        ),
        isFalse,
      );
    });
  });
}
