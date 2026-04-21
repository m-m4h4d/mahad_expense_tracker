import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/expense_provider.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpendWise'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ExpenseProvider>().loadExpenses();
            },
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          if (expenseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final expenses = expenseProvider.expenses;

          return Column(
            children: [
              // Search and Filter Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search expenses...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onChanged: (value) {
                          expenseProvider.searchExpenses(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownMenu<String>(
                      initialSelection: expenseProvider.selectedCategory,
                      onSelected: (String? value) {
                        if (value != null) {
                          expenseProvider.setFilterCategory(value);
                        }
                      },
                      dropdownMenuEntries: _categories.map<DropdownMenuEntry<String>>((String value) {
                        return DropdownMenuEntry<String>(value: value, label: value);
                      }).toList(),
                      inputDecorationTheme: InputDecorationTheme(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      width: 120, // To keep it compact
                    ),
                  ],
                ),
              ),

              // Summary Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Spent',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                        ),
                        Text(
                          '\$${expenseProvider.totalSpent.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Expenses List
              Expanded(
                child: expenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No expenses found',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Hero(
                              tag: 'expense_${expense.id}',
                              child: Material(
                                type: MaterialType.transparency,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    // Could navigate to details screen
                                  },
                                  onLongPress: () {
                                    // Show delete confirmation
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Delete Expense?'),
                                        content: Text('Remove ${expense.title}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              expenseProvider.deleteExpense(expense.id!);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                          child: Icon(
                                            _getIconForCategory(expense.category),
                                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                expense.title,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold, fontSize: 16),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                DateFormat.yMMMd().format(expense.date),
                                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '-\$${expense.amount.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Food':
        return Icons.fastfood;
      case 'Transport':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Bills':
        return Icons.receipt;
      default:
        return Icons.category;
    }
  }
}
