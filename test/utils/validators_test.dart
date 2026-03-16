import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/utils/validators.dart';

void main() {
  group('Validators.required', () {
    test('returns null for a non-empty string', () {
      expect(Validators.required('hello'), isNull);
    });

    test('returns null for a string with surrounding whitespace', () {
      expect(Validators.required('  hello  '), isNull);
    });

    test('returns error message for null', () {
      expect(Validators.required(null), 'This field is required');
    });

    test('returns error message for empty string', () {
      expect(Validators.required(''), 'This field is required');
    });

    test('returns error message for whitespace-only string', () {
      expect(Validators.required('   '), 'This field is required');
    });

    test('returns error message for tab-only string', () {
      expect(Validators.required('\t'), 'This field is required');
    });

    test('returns error message for newline-only string', () {
      expect(Validators.required('\n'), 'This field is required');
    });

    test('returns null for a single character', () {
      expect(Validators.required('a'), isNull);
    });

    test('returns null for a string with special characters', () {
      expect(Validators.required('!@#\$%'), isNull);
    });

    test('returns null for a numeric string', () {
      expect(Validators.required('12345'), isNull);
    });
  });

  group('Validators.email', () {
    test('returns null for a valid email', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('returns null for email with subdomain', () {
      expect(Validators.email('user@mail.example.com'), isNull);
    });

    test('returns null for email with plus sign', () {
      expect(Validators.email('user+tag@example.com'), isNull);
    });

    test('returns null for email with dots in local part', () {
      expect(Validators.email('first.last@example.com'), isNull);
    });

    test('returns null for email with numbers', () {
      expect(Validators.email('user123@example456.com'), isNull);
    });

    test('returns "Email is required" for null', () {
      expect(Validators.email(null), 'Email is required');
    });

    test('returns "Email is required" for empty string', () {
      expect(Validators.email(''), 'Email is required');
    });

    test('returns "Enter a valid email" for missing @ sign', () {
      expect(Validators.email('userexample.com'), 'Enter a valid email');
    });

    test('returns "Enter a valid email" for missing domain', () {
      expect(Validators.email('user@'), 'Enter a valid email');
    });

    test('returns "Enter a valid email" for missing TLD dot', () {
      expect(Validators.email('user@example'), 'Enter a valid email');
    });

    test('returns "Enter a valid email" for missing local part', () {
      expect(Validators.email('@example.com'), 'Enter a valid email');
    });

    test('returns "Enter a valid email" for plain text', () {
      expect(Validators.email('just some text'), 'Enter a valid email');
    });

    test('accepts email with spaces in local part (regex allows it)', () {
      // The current regex r'^[^@]+@[^@]+\.[^@]+' does not reject spaces
      // in the local part, so 'user @example.com' is considered valid.
      expect(Validators.email('user @example.com'), isNull);
    });

    test('returns "Enter a valid email" for double @ sign', () {
      expect(Validators.email('user@@example.com'), 'Enter a valid email');
    });
  });

  group('Validators.password', () {
    test('returns null for password with exactly 6 characters', () {
      expect(Validators.password('123456'), isNull);
    });

    test('returns null for password longer than 6 characters', () {
      expect(Validators.password('mysecurepassword'), isNull);
    });

    test('returns null for password with special characters', () {
      expect(Validators.password('p@ss!w'), isNull);
    });

    test('returns "Password is required" for null', () {
      expect(Validators.password(null), 'Password is required');
    });

    test('returns "Password is required" for empty string', () {
      expect(Validators.password(''), 'Password is required');
    });

    test('returns error for password with 5 characters', () {
      expect(
          Validators.password('12345'), 'Password must be at least 6 characters');
    });

    test('returns error for password with 1 character', () {
      expect(
          Validators.password('a'), 'Password must be at least 6 characters');
    });

    test('returns null for very long password', () {
      expect(Validators.password('a' * 100), isNull);
    });

    test('returns null for password with spaces (6+ chars)', () {
      expect(Validators.password('a b c d'), isNull);
    });

    test('returns null for password with unicode characters', () {
      expect(Validators.password('\u00fc\u00f6\u00e4\u00df\u00e9\u00e8'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('returns null when passwords match', () {
      expect(Validators.confirmPassword('password', 'password'), isNull);
    });

    test('returns error when passwords do not match', () {
      expect(Validators.confirmPassword('password1', 'password2'),
          'Passwords do not match');
    });

    test('returns error when value is null and password is not empty', () {
      expect(
          Validators.confirmPassword(null, 'password'), 'Passwords do not match');
    });

    test('returns null when both are empty strings', () {
      expect(Validators.confirmPassword('', ''), isNull);
    });

    test('returns error when value has trailing whitespace', () {
      expect(Validators.confirmPassword('password ', 'password'),
          'Passwords do not match');
    });

    test('returns error when value has leading whitespace', () {
      expect(Validators.confirmPassword(' password', 'password'),
          'Passwords do not match');
    });

    test('returns error for case mismatch', () {
      expect(Validators.confirmPassword('Password', 'password'),
          'Passwords do not match');
    });

    test('returns null for matching complex passwords', () {
      expect(
          Validators.confirmPassword('P@ss!w0rd#123', 'P@ss!w0rd#123'), isNull);
    });
  });
}
