import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/transactions/transactions_screen.dart';
import '../../features/transactions/add_transaction_screen.dart';
import '../../features/budget/budget_screen.dart';
import '../../features/settings/settings_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionsScreen(),
    const BudgetScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(FontAwesomeIcons.tableColumns),
            selectedIcon: Icon(FontAwesomeIcons.tableColumns),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(FontAwesomeIcons.receipt),
            selectedIcon: Icon(FontAwesomeIcons.receipt),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(FontAwesomeIcons.chartPie),
            selectedIcon: Icon(FontAwesomeIcons.chartPie),
            label: 'Budget',
          ),
          NavigationDestination(
            icon: Icon(FontAwesomeIcons.gear),
            selectedIcon: Icon(FontAwesomeIcons.gear),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
            ),
          );
        },
        child: const FaIcon(FontAwesomeIcons.plus),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
