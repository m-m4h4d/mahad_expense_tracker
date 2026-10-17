import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:spend_wise/core/database/db_helper.dart';
import 'package:spend_wise/features/auth/models/user_model.dart';
import 'package:spend_wise/features/expenses/models/expense_model.dart';
import 'package:spend_wise/features/expenses/providers/expense_provider.dart';

Expense _expense(
  String title, {
  int? userId,
  double amount = 10,
  String category = 'Food',
  String type = 'Expense',
}) => Expense(
  title: title,
  amount: amount,
  category: category,
  date: DateTime(2026, 1, 1),
  type: type,
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
    // Each test file runs in its own isolate; give each its own database.
    await databaseFactory.setDatabasesPath(
      Directory.systemTemp.createTempSync('spendwise_test').path,
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

  test('search and category filters do not change totals', () async {
    final db = DatabaseHelper.instance;
    final carol = (await db.createUser(
      User(
        fullName: 'Carol',
        username: 'carol',
        email: 'c@x.com',
        password: 'p',
      ),
    )).id!;
    final provider = ExpenseProvider();
    await provider.setUser(carol);
    await provider.addExpense(_expense('Coffee', amount: 5));
    await provider.addExpense(
      _expense('Bus', amount: 20, category: 'Transport'),
    );
    await provider.addExpense(
      _expense('Pay', amount: 1000, category: 'Salary', type: 'Income'),
    );
    await provider.addExpense(
      _expense('From Dan', amount: 300, category: 'Borrowed', type: 'Loan'),
    );

    void expectFullTotals() {
      expect(provider.totalExpenses, 25);
      expect(provider.totalIncome, 1000);
      expect(provider.netBalance, 975);
      expect(provider.totalBorrowed, 300);
    }

    expectFullTotals();

    provider.searchExpenses('coffee');
    expect(provider.expenses.map((e) => e.title), ['Coffee']);
    expectFullTotals();

    provider.searchExpenses('');
    provider.setFilterCategory('Transport');
    expect(provider.expenses.map((e) => e.title), ['Bus']);
    expectFullTotals();
  });
}
