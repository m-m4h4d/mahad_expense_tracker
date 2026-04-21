import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../expenses/providers/expense_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kIsWeb
          ? null
          : AppBar(title: const Text('Conversion'), elevation: 0),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.analytics,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Total Spendings',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${expenseProvider.currencySymbol}${expenseProvider.totalSpent.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          Text(
                            'Currency Conversion',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            alignment: WrapAlignment.center,
                            children: expenseProvider
                                .availableConversionCurrencies
                                .map((currency) {
                                  return _CurrencyButton(
                                    currency: currency,
                                    onPressed: () => expenseProvider
                                        .fetchExchangeRate(currency),
                                    expenseProvider: expenseProvider,
                                  );
                                })
                                .toList(),
                          ),
                          const SizedBox(height: 24),
                          if (expenseProvider.isLoading)
                            const CircularProgressIndicator()
                          else if (expenseProvider.targetCurrency !=
                              expenseProvider.baseCurrency)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Equivalent in ${expenseProvider.targetCurrency}:\n${expenseProvider.targetCurrency} ${expenseProvider.convertedTotal.toStringAsFixed(2)}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
      backgroundColor: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      onPressed: onPressed,
    );
  }
}
