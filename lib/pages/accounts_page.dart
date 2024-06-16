import 'package:flutter/material.dart';
import 'package:galaxy/model/account_model.dart';
import 'package:galaxy/views/details/account_details.dart';
import 'package:galaxy/views/forms/add_account.dart';
import 'package:galaxy/views/overview/accounts_overview.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

    @override
  AccountsPageState createState() => AccountsPageState();
}

class AccountsPageState extends State<AccountsPage> {
  int _selectedIndex = 0;
  final AccountModel selectedPerson = const AccountModel(name: 'Alice', age: 30, address: '123 Main St');

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
              selectedIcon: Icon(Icons.account_balance_rounded),
              icon: Icon(Icons.account_balance_outlined),
              label: 'All Accounts',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.account_circle),
              icon: Icon(Icons.account_circle_outlined),
              label: 'Details',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.add_circle_sharp),
              icon: Icon(Icons.add_circle_outline_sharp),
              label: 'Add New',
            ),
          ],
        ),
        appBar: AppBar(
          title: const Text('Accounts Galaxy'),
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
            const AccountsOverview(),

            // Second Route
            AccountDetailsPage(
                person: selectedPerson,
                heroTag: 'person_${selectedPerson.name}'),

            // Third Route
            const AddAccountView(),
          ],
          ),
        ),
    );
  }
}
