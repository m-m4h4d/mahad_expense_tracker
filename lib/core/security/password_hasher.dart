import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

// Stored format: pbkdf2_sha256$<iterations>$<salt base64>$<hash base64>
class PasswordHasher {
  static const _scheme = 'pbkdf2_sha256';
  static const _iterations = 100000;
  static const _saltLength = 16;
  static const _hashBits = 256;

  static Future<String> hash(String password) async {
    final random = Random.secure();
    final salt = List<int>.generate(_saltLength, (_) => random.nextInt(256));
    final derived = await _derive(password, salt, _iterations);
    return [
      _scheme,
      _iterations,
      base64Encode(salt),
      base64Encode(derived),
    ].join(r'$');
  }

  static Future<bool> verify(String password, String stored) async {
    final parts = stored.split(r'$');
    if (parts.length != 4 || parts[0] != _scheme) return false;
    final iterations = int.tryParse(parts[1]);
    if (iterations == null) return false;
    final List<int> salt;
    final List<int> expected;
    try {
      salt = base64Decode(parts[2]);
      expected = base64Decode(parts[3]);
    } on FormatException {
      return false;
    }
    final actual = await _derive(password, salt, iterations);
    return _constantTimeEquals(actual, expected);
  }

  static bool isHashed(String stored) => stored.startsWith('$_scheme\$');

  static Future<List<int>> _derive(
    String password,
    List<int> salt,
    int iterations,
  ) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: _hashBits,
    );
    final key = await pbkdf2.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    return key.extractBytes();
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
