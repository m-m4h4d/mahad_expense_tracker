import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../expenses/screens/expenses_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';
import '../../expenses/screens/add_expense_screen.dart';
import '../../../core/theme/theme_provider.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ExpensesScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                _currentIndex == 0 ? Icons.home : Icons.home_outlined,
                color: _currentIndex == 0 ? Theme.of(context).colorScheme.primary : null,
              ),
              onPressed: () {
                setState(() => _currentIndex = 0);
              },
            ),
            IconButton(
              icon: Icon(
                _currentIndex == 1 ? Icons.currency_exchange : Icons.currency_exchange,
                color: _currentIndex == 1 ? Theme.of(context).colorScheme.primary : null,
              ),
              onPressed: () {
                setState(() => _currentIndex = 1);
              },
            ),
            IconButton(
              icon: Icon(
                _currentIndex == 2 ? Icons.settings : Icons.settings_outlined,
                color: _currentIndex == 2 ? Theme.of(context).colorScheme.primary : null,
              ),
              onPressed: () {
                setState(() => _currentIndex = 2);
              },
            ),
            // Dark Mode Toggle Switcher
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return RotationTransition(
                    turns: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  key: ValueKey<bool>(isDarkMode),
                  color: isDarkMode ? Colors.yellow : Colors.grey,
                ),
              ),
              onPressed: () {
                themeProvider.toggleTheme(!isDarkMode);
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              heroTag: 'add_expense_fab',
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const AddExpenseScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
