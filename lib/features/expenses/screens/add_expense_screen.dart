import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense_model.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedType = 'Expense';
  String _selectedCategory = 'General';
  DateTime _selectedDate = DateTime.now();

  final Map<String, List<String>> _categoryMap = {
    'Expense': [
      'General',
      'Food',
      'Transport',
      'Utilities',
      'Sbscriptions',
      'Other',
    ],
    'Income': ['Salary', 'Business', 'Investments', 'Freelance', 'Other'],
    'Loan': ['Borrowed', 'Lent', 'Repayment', 'Other'],
  };

  List<String> get _currentCategories => _categoryMap[_selectedType]!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Hero(
            tag: 'add_expense_fab',
            child: Material(
              type: MaterialType.transparency,
              child: Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'Expense',
                              label: Text('Expense'),
                            ),
                            ButtonSegment(
                              value: 'Income',
                              label: Text('Income'),
                            ),
                            ButtonSegment(value: 'Loan', label: Text('Loan')),
                          ],
                          selected: {_selectedType},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() {
                              _selectedType = newSelection.first;
                              _selectedCategory =
                                  _categoryMap[_selectedType]!.first;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            filled: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _amountController,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            filled: true,
                            prefixText: context
                                .read<ExpenseProvider>()
                                .currencySymbol,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          key: ValueKey(_selectedType),
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            filled: true,
                          ),
                          items: _currentCategories.map((String category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.calendar_today),
                              label: const Text('Select Date'),
                              onPressed: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null && picked != _selectedDate) {
                                  setState(() {
                                    _selectedDate = picked;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final newExpense = Expense(
                                title: _titleController.text,
                                amount: double.parse(_amountController.text),
                                category: _selectedCategory,
                                date: _selectedDate,
                                type: _selectedType,
                              );

                              context.read<ExpenseProvider>().addExpense(
                                newExpense,
                              );
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Save Expense'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
