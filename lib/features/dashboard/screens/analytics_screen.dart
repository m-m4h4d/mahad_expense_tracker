import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../expenses/providers/expense_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        elevation: 0,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Icon(Icons.analytics, size: 48, color: Colors.blue),
                        const SizedBox(height: 16),
                        Text(
                          'Total Spendings',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${expenseProvider.totalSpent.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          'Currency Conversion (Cloud API)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _CurrencyButton(
                              currency: 'EUR',
                              onPressed: () => expenseProvider.fetchExchangeRate('EUR'),
                              expenseProvider: expenseProvider,
                            ),
                            _CurrencyButton(
                              currency: 'GBP',
                              onPressed: () => expenseProvider.fetchExchangeRate('GBP'),
                              expenseProvider: expenseProvider,
                            ),
                            _CurrencyButton(
                              currency: 'PKR',
                              onPressed: () => expenseProvider.fetchExchangeRate('PKR'),
                              expenseProvider: expenseProvider,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (expenseProvider.isLoading)
                          const CircularProgressIndicator()
                        else if (expenseProvider.targetCurrency != 'USD')
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Equivalent in ${expenseProvider.targetCurrency}:\n${expenseProvider.targetCurrency} ${expenseProvider.convertedTotal.toStringAsFixed(2)}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onTertiaryContainer,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: const [
                        Icon(Icons.pie_chart, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Detailed charts coming soon!'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CurrencyButton extends StatelessWidget {
  final String currency;
  final VoidCallback onPressed;
  final ExpenseProvider expenseProvider;

  const _CurrencyButton({
    required this.currency,
    required this.onPressed,
    required this.expenseProvider,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = expenseProvider.targetCurrency == currency;
    return ActionChip(
      label: Text(currency),
      backgroundColor: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      onPressed: onPressed,
    );
  }
}
