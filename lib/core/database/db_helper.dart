import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../security/password_hasher.dart';
import '../../features/expenses/models/expense_model.dart';
import '../../features/auth/models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('spendwise.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Database db;
    if (kIsWeb) {
      var factory = databaseFactoryFfiWeb;
      db = await factory.openDatabase(
        filePath,
        options: OpenDatabaseOptions(
          version: 5,
          onCreate: _createDB,
          onUpgrade: _upgradeDB,
        ),
      );
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      db = await openDatabase(
        path,
        version: 5,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      );
    }

    return db;
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE expenses (
        id $idType,
        title $textType,
        amount $realType,
        category $textType,
        date $textType,
        type $textType,
        user_id INTEGER REFERENCES users(id)
      )
    ''');
    await db.execute('CREATE INDEX idx_expenses_user_id ON expenses (user_id)');

    await db.execute('''
      CREATE TABLE users (
        id $idType,
        fullName $textType,
        username $textType UNIQUE,
        email $textType UNIQUE,
        password $textType
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';

      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id $idType,
          fullName $textType,
          username $textType UNIQUE,
          email $textType UNIQUE,
          password $textType
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE expenses ADD COLUMN type TEXT NOT NULL DEFAULT "Expense"',
      );
    }
    if (oldVersion < 4) {
      // Existing rows keep a NULL user_id; they are claimed by the first
      // user who logs in after the upgrade (see claimUnownedExpenses).
      await db.execute(
        'ALTER TABLE expenses ADD COLUMN user_id INTEGER REFERENCES users(id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_expenses_user_id ON expenses (user_id)',
      );
    }
    if (oldVersion < 5) {
      // Older builds seeded a public test account (test / abc123) on every
      // launch. Drop it unless someone has changed its password or put
      // transactions in it.
      await db.delete(
        'users',
        where: '''
          username = 'test' AND email = 'user@example.com'
          AND password = 'abc123'
          AND id NOT IN (
            SELECT user_id FROM expenses WHERE user_id IS NOT NULL
          )
        ''',
      );

      // Passwords used to be stored in plain text.
      final users = await db.query('users', columns: ['id', 'password']);
      for (final user in users) {
        final password = user['password'] as String;
        if (PasswordHasher.isHashed(password)) continue;
        await db.update(
          'users',
          {'password': await PasswordHasher.hash(password)},
          where: 'id = ?',
          whereArgs: [user['id']],
        );
      }
    }
  }

  // --- Expenses CRUD ---
  Future<Expense> createExpense(Expense expense) async {
    final db = await instance.database;
    final id = await db.insert('expenses', expense.toMap());
    return expense.copyWith(id: id);
  }

  Future<List<Expense>> readExpensesForUser(int userId) async {
    final db = await instance.database;
    const orderBy = 'date DESC';
    final result = await db.query(
      'expenses',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: orderBy,
    );
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  Future<int> updateExpense(Expense expense, int userId) async {
    final db = await instance.database;
    return db.update(
      'expenses',
      expense.copyWith(userId: userId).toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [expense.id, userId],
    );
  }

  Future<int> deleteExpense(int id, int userId) async {
    final db = await instance.database;
    return await db.delete(
      'expenses',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  // Assigns expenses created before per-user storage existed to [userId].
  Future<int> claimUnownedExpenses(int userId) async {
    final db = await instance.database;
    return await db.update('expenses', {
      'user_id': userId,
    }, where: 'user_id IS NULL');
  }

  // --- Users CRUD ---
  Future<User> createUser(User user) async {
    final db = await instance.database;
    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  Future<User?> getUserById(int id) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByUsernameOrEmail(String identifier) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ? OR email = ?',
      whereArgs: [identifier, identifier],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUserPassword(int userId, String passwordHash) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'password': passwordHash},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> updateUserUsername(int userId, String newUsername) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'username': newUsername},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
