import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/expenses/providers/expense_provider.dart';
import 'features/auth/screens/auth_checker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: const SpendWiseApp(),
    ),
  );
}

class SpendWiseApp extends StatelessWidget {
  const SpendWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'SpendWise',
          themeMode: themeProvider.themeMode,
          theme: ThemeProvider.lightTheme,
          darkTheme: ThemeProvider.darkTheme,
          debugShowCheckedModeBanner: false,
          home: const AuthChecker(),
        );
      },
    );
  }
}
