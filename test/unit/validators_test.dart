import 'package:flutter_test/flutter_test.dart';
import 'package:jobologyx_flutter/core/utils/validators.dart';

void main() {
  test('Validators enforce email format and password length/matching', () {
    expect(Validators.email(''), 'Email is required');
    expect(Validators.email('not-an-email'), 'Enter a valid email address');
    expect(Validators.email('user@example.com'), isNull);

    expect(Validators.password('abc'), 'Password must be at least 6 characters');
    expect(Validators.password('abcdef'), isNull);
    expect(Validators.confirmPassword('abcxyz', 'abcdef'), 'Passwords do not match');
    expect(Validators.confirmPassword('abcdef', 'abcdef'), isNull);
  });
}
