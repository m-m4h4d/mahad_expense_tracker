import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../features/expenses/models/expense_model.dart';

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
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
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
        date $textType
      )
    ''');
  }

  // CREATE
  Future<Expense> createExpense(Expense expense) async {
    final db = await instance.database;
    final id = await db.insert('expenses', expense.toMap());
    return expense.copyWith(id: id);
  }

  // READ ALL
  Future<List<Expense>> readAllExpenses() async {
    final db = await instance.database;
    const orderBy = 'date DESC';
    final result = await db.query('expenses', orderBy: orderBy);
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  // UPDATE
  Future<int> updateExpense(Expense expense) async {
    final db = await instance.database;
    return db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // DELETE
  Future<int> deleteExpense(int id) async {
    final db = await instance.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
