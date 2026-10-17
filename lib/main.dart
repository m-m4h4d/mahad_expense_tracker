import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/expenses/providers/expense_provider.dart';
import 'features/auth/screens/auth_checker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(createApp());
}

// The app with its providers; tests pump this to get the real widget tree.
Widget createApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProxyProvider<AuthProvider, ExpenseProvider>(
        create: (_) => ExpenseProvider(),
        update: (_, auth, expenses) => expenses!..setUser(auth.currentUser?.id),
      ),
    ],
    child: const SpendWiseApp(),
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
