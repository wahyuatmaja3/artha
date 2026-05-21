import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'core/ui/neo_widgets.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/transactions/transactions_screen.dart';
import '../../features/transactions/add_transaction_screen.dart';
import '../../features/budget/budget_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/savings_goals/savings_goals_screen.dart';
import '../../features/investment_plans/investment_plans_screen.dart';

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
    const SavingsGoalsScreen(),
    const InvestmentPlansScreen(),
    const BudgetScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final showAddTransactionFab = _currentIndex == 0 || _currentIndex == 1;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: NeoCard(
          padding: EdgeInsets.zero,
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              height: 68,
              indicatorColor: scheme.primary.withValues(alpha: 0.22),
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
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
                  label: 'Catatan',
                ),
                NavigationDestination(
                  icon: Icon(FontAwesomeIcons.bullseye),
                  selectedIcon: Icon(FontAwesomeIcons.bullseye),
                  label: 'Goals',
                ),
                NavigationDestination(
                  icon: Icon(FontAwesomeIcons.chartLine),
                  selectedIcon: Icon(FontAwesomeIcons.chartLine),
                  label: 'Invest',
                ),
                NavigationDestination(
                  icon: Icon(FontAwesomeIcons.chartPie),
                  selectedIcon: Icon(FontAwesomeIcons.chartPie),
                  label: 'Budget',
                ),
                NavigationDestination(
                  icon: Icon(FontAwesomeIcons.gear),
                  selectedIcon: Icon(FontAwesomeIcons.gear),
                  label: 'Setelan',
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: showAddTransactionFab
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AddTransactionScreen(),
                  ),
                );
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const FaIcon(FontAwesomeIcons.plus),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
