import 'package:flutter_test/flutter_test.dart';

import 'package:spend_wise/core/security/password_hasher.dart';

void main() {
  test('hash verifies only the original password', () async {
    final sw = Stopwatch()..start();
    final stored = await PasswordHasher.hash('hunter22');
    // ignore: avoid_print
    print('hash took ${sw.elapsedMilliseconds}ms');

    expect(stored, isNot(contains('hunter22')));
    expect(PasswordHasher.isHashed(stored), isTrue);
    expect(await PasswordHasher.verify('hunter22', stored), isTrue);
    expect(await PasswordHasher.verify('hunter23', stored), isFalse);
  });

  test('same password gets a different salt each time', () async {
    final a = await PasswordHasher.hash('same');
    final b = await PasswordHasher.hash('same');
    expect(a, isNot(b));
  });

  test('malformed or plaintext stored values never verify', () async {
    expect(await PasswordHasher.verify('abc123', 'abc123'), isFalse);
    expect(await PasswordHasher.verify('x', r'pbkdf2_sha256$x$y$z'), isFalse);
    expect(PasswordHasher.isHashed('abc123'), isFalse);
  });
}
