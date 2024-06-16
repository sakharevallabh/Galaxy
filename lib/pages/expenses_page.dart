import 'package:flutter/material.dart';
import 'package:galaxy/model/expense_model.dart';
import 'package:galaxy/views/details/expense_details.dart';
import 'package:galaxy/views/forms/add_expense.dart';
import 'package:galaxy/views/overview/expenses_overview.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  ExpensesPageState createState() => ExpensesPageState();
}

class ExpensesPageState extends State<ExpensesPage> {
  int _selectedIndex = 0;
  final ExpenseModel selectedExpense =
      const ExpenseModel(name: 'Alice', age: 30, address: '123 Main St');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.account_balance_wallet),
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'All Expenses',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.monetization_on),
            icon: Icon(Icons.monetization_on_outlined),
            label: 'Details',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.money_rounded),
            icon: Icon(Icons.money_outlined),
            label: 'Add New',
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text('Expenses Galaxy'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            // First Route
            const ExpensesOverview(),

            // Second Route
            ExpenseDetailsPage(
                expense: selectedExpense,
                heroTag: 'expense_${selectedExpense.name}'),

            // Third Route
            const AddExpenseView(),
          ],
        ),
      ),
    );
  }
}