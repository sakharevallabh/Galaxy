import 'dart:math';

import 'package:flutter/material.dart';

class AccountsOverview extends StatefulWidget {
  const AccountsOverview({super.key});

  @override
  AccountsOverviewState createState() => AccountsOverviewState();
}

class AccountsOverviewState extends State<AccountsOverview> {
  final List<String> _names = ['Alice', 'Bob', 'Charlie', 'David', 'Eve'];
  final List<IconData> _icons = [
    Icons.account_balance,
    Icons.tv,
    Icons.email,
    Icons.web_outlined,
    Icons.gas_meter_rounded,
  ];

  final List<Map<String, dynamic>> _cards = [];

  void _addRandomCard() {
    setState(() {
      String randomName = _names[Random().nextInt(_names.length)];
      IconData randomIcon = _icons[Random().nextInt(_icons.length)];
      _cards.add({'name': randomName, 'icon': randomIcon});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: _addRandomCard,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.amber, // Text color
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: const Text('Add Account'),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Number of columns in the grid
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0), // Adjust padding here
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _cards[index]['icon'],
                            size: 50,
                          ),
                          const SizedBox(height: 2), // Add spacing between icon and text
                          Text(
                            _cards[index]['name'],
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
