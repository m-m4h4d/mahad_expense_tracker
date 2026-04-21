import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/database/db_helper.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String _errorMessage = '';
  User? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      _currentUser = await DatabaseHelper.instance.getUserById(userId);
      if (_currentUser != null) {
        _isAuthenticated = true;
      } else {
        await prefs.remove('userId');
        _isAuthenticated = false;
      }
    } else {
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final user = await DatabaseHelper.instance.getUserByUsernameOrEmail(
      identifier,
    );

    if (user != null && user.password == password) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user.id!);
      _currentUser = user;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Invalid username/email or password';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(
    String fullName,
    String username,
    String email,
    String password,
  ) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    // Check uniqueness
    final existingUser = await DatabaseHelper.instance.getUserByUsernameOrEmail(
      username,
    );
    final existingEmail = await DatabaseHelper.instance
        .getUserByUsernameOrEmail(email);

    if (existingUser != null && existingUser.username == username) {
      _errorMessage = 'Username already exists';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (existingEmail != null && existingEmail.email == email) {
      _errorMessage = 'Email already exists';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final newUser = User(
        fullName: fullName,
        username: username,
        email: email,
        password: password,
      );
      final createdUser = await DatabaseHelper.instance.createUser(newUser);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', createdUser.id!);
      _currentUser = createdUser;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'An error occurred during registration';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changeUsername(String newUsername) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final existingUser = await DatabaseHelper.instance.getUserByUsername(
      newUsername,
    );
    if (existingUser != null && existingUser.id != _currentUser!.id) {
      _errorMessage = 'Username already exists. Please choose another one.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    await DatabaseHelper.instance.updateUserUsername(
      _currentUser!.id!,
      newUsername,
    );
    _currentUser = _currentUser!.copyWith(username: newUsername);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    if (_currentUser!.password != currentPassword) {
      _errorMessage = 'Current password is incorrect';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    await DatabaseHelper.instance.updateUserPassword(
      _currentUser!.id!,
      newPassword,
    );
    _currentUser = _currentUser!.copyWith(password: newPassword);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
