import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:spend_wise/core/database/db_helper.dart';
import 'package:spend_wise/features/auth/models/user_model.dart';
import 'package:spend_wise/features/expenses/models/expense_model.dart';
import 'package:spend_wise/features/expenses/providers/expense_provider.dart';

Expense _expense(String title, {int? userId}) => Expense(
  title: title,
  amount: 10,
  category: 'Food',
  date: DateTime(2026, 1, 1),
  type: 'Expense',
  userId: userId,
);

void main() {
  late int alice;
  late int bob;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await databaseFactory.deleteDatabase(
      join(await getDatabasesPath(), 'spendwise.db'),
    );

    final db = DatabaseHelper.instance;
    alice = (await db.createUser(
      User(
        fullName: 'Alice',
        username: 'alice',
        email: 'a@x.com',
        password: 'p',
      ),
    )).id!;
    bob = (await db.createUser(
      User(fullName: 'Bob', username: 'bob', email: 'b@x.com', password: 'p'),
    )).id!;
    // A row from before per-user storage existed.
    await db.createExpense(_expense('Legacy'));
  });

  test('expenses are scoped to the logged-in user', () async {
    final provider = ExpenseProvider();

    await provider.setUser(alice);
    expect(provider.expenses.map((e) => e.title), ['Legacy']);
    await provider.addExpense(_expense('Alice lunch'));
    expect(provider.expenses, hasLength(2));

    await provider.setUser(bob);
    expect(provider.expenses, isEmpty);
    expect(provider.totalExpenses, 0);
    await provider.addExpense(_expense('Bob taxi'));

    // Bob cannot delete Alice's rows even with a known id.
    await provider.setUser(alice);
    final aliceIds = provider.expenses.map((e) => e.id!).toList();
    await provider.setUser(bob);
    for (final id in aliceIds) {
      await provider.deleteExpense(id);
    }
    expect(provider.expenses.map((e) => e.title), ['Bob taxi']);

    await provider.setUser(alice);
    expect(
      provider.expenses.map((e) => e.title),
      unorderedEquals(['Legacy', 'Alice lunch']),
    );

    await provider.setUser(null);
    expect(provider.expenses, isEmpty);
  });
}
