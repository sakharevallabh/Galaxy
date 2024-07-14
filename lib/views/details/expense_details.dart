import 'package:flutter/material.dart';
import 'package:Galaxy/model/expense_model.dart';

class ExpenseDetailsPage extends StatelessWidget {
  final ExpenseModel expense;
  final String heroTag;

  const ExpenseDetailsPage({super.key, required this.expense, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${expense.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Age: ${expense.age}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Address: ${expense.address}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
