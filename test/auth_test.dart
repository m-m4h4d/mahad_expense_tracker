import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:spend_wise/core/database/db_helper.dart';
import 'package:spend_wise/core/security/password_hasher.dart';
import 'package:spend_wise/features/auth/providers/auth_provider.dart';

const _v3Users = '''
  CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    fullName TEXT NOT NULL,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL
  )
''';
const _v3Expenses = '''
  CREATE TABLE expenses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    amount REAL NOT NULL,
    category TEXT NOT NULL,
    date TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'Expense'
  )
''';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = Directory.systemTemp.createTempSync('spendwise_test').path;
    await databaseFactory.setDatabasesPath(dir);

    // Simulate a database left behind by an older build: plaintext
    // passwords and the seeded test account.
    final old = await openDatabase(
      join(dir, 'spendwise.db'),
      version: 3,
      onCreate: (db, _) async {
        await db.execute(_v3Users);
        await db.execute(_v3Expenses);
        await db.insert('users', {
          'fullName': 'Main Character',
          'username': 'test',
          'email': 'user@example.com',
          'password': 'abc123',
        });
        await db.insert('users', {
          'fullName': 'Mahad',
          'username': 'mahad',
          'email': 'm@x.com',
          'password': 'oldpass',
        });
      },
    );
    await old.close();
  });

  test('upgrade removes the seeded account and hashes passwords', () async {
    final helper = DatabaseHelper.instance;
    expect(await helper.getUserByUsername('test'), isNull);

    final mahad = (await helper.getUserByUsername('mahad'))!;
    expect(mahad.password, isNot('oldpass'));
    expect(PasswordHasher.isHashed(mahad.password), isTrue);
  });

  test('existing user can still log in after the upgrade', () async {
    final auth = AuthProvider();
    expect(await auth.login('mahad', 'wrong'), isFalse);
    expect(await auth.login('mahad', 'oldpass'), isTrue);
    expect(await auth.login('test', 'abc123'), isFalse);
  });

  test('sign up, change password and log in with the new one', () async {
    final auth = AuthProvider();
    expect(await auth.signUp('New', 'newbie', 'n@x.com', 'first1'), isTrue);
    final stored = (await DatabaseHelper.instance.getUserByUsername('newbie'))!;
    expect(stored.password, isNot('first1'));

    expect(await auth.changePassword('nope', 'second2'), isFalse);
    expect(await auth.changePassword('first1', 'second2'), isTrue);

    await auth.logout();
    expect(await auth.login('newbie', 'first1'), isFalse);
    expect(await auth.login('n@x.com', 'second2'), isTrue);
  });
}
