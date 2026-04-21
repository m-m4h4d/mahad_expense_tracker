import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isLoggedIn') ?? false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Simple validation for demonstration
    if (email.isNotEmpty && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Invalid email or password (must be at least 6 chars)';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    
    if (email.isNotEmpty && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Form invalid. Password must be 6+ characters.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    _isAuthenticated = false;
    notifyListeners();
  }
}
