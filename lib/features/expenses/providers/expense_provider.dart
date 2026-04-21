import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/database/db_helper.dart';
import '../models/expense_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  List<Expense> _filteredExpenses = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<Expense> get expenses => _filteredExpenses;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  double get totalSpent {
    return _filteredExpenses.fold(0, (sum, item) => sum + item.amount);
  }

  // Currency Exchange state
  String _baseCurrency = 'PKR';
  String get baseCurrency => _baseCurrency;

  String get currencySymbol {
    switch (_baseCurrency) {
      case 'PKR':
        return 'Rs ';
      case 'INR':
        return '₹';
      case 'GBP':
        return '£';
      case 'EUR':
        return '€';
      case 'USD':
      default:
        return '\$';
    }
  }

  double _exchangeRate = 1.0;
  String _targetCurrency = 'PKR';
  String get targetCurrency => _targetCurrency;
  double get convertedTotal => totalSpent * _exchangeRate;

  final List<String> supportedCurrencies = ['PKR', 'INR', 'GBP', 'USD', 'EUR'];

  List<String> get availableConversionCurrencies {
    return supportedCurrencies.where((c) => c != _baseCurrency).toList();
  }

  ExpenseProvider() {
    _loadBaseCurrency();
    loadExpenses();
  }

  Future<void> _loadBaseCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _baseCurrency = prefs.getString('baseCurrency') ?? 'PKR';
    _targetCurrency = _baseCurrency; // Default conversion target to self
    notifyListeners();
  }

  Future<void> setBaseCurrency(String currency) async {
    _baseCurrency = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('baseCurrency', currency);
    // Reset target currency to base to avoid immediate wrong conversions
    _targetCurrency = currency;
    _exchangeRate = 1.0;
    notifyListeners();
  }

  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();

    _expenses = await DatabaseHelper.instance.readAllExpenses();
    _applyFiltersAndSearch();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await DatabaseHelper.instance.createExpense(expense);
    await loadExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    await DatabaseHelper.instance.updateExpense(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(int id) async {
    await DatabaseHelper.instance.deleteExpense(id);
    await loadExpenses();
  }

  void searchExpenses(String query) {
    _searchQuery = query;
    _applyFiltersAndSearch();
    notifyListeners();
  }

  void setFilterCategory(String category) {
    _selectedCategory = category;
    _applyFiltersAndSearch();
    notifyListeners();
  }

  void _applyFiltersAndSearch() {
    _filteredExpenses = _expenses.where((expense) {
      final matchesCategory =
          _selectedCategory == 'All' || expense.category == _selectedCategory;
      final matchesSearch = expense.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // API Call to get exchange rates from current base Currency
  Future<void> fetchExchangeRate(String target) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(
        'https://api.exchangerate-api.com/v4/latest/$_baseCurrency',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _exchangeRate = (data['rates'][target] ?? 1.0).toDouble();
        _targetCurrency = target;
      }
    } catch (e) {
      debugPrint("Error fetching exchange rates: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
