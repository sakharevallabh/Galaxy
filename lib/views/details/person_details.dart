import 'package:flutter/material.dart';
import 'package:galaxy/model/person_model.dart';

class PersonDetailsPage extends StatelessWidget {
  final PersonModel person;
  final String heroTag;

  const PersonDetailsPage({super.key, required this.person, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Person Details'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: heroTag,
              child: Material(
                color: Colors.transparent,
                child: Text(
                  'Name: ${person.name}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Age: ${person.age}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Address: ${person.address}',
              style: const TextStyle(fontSize: 16),
            ),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
