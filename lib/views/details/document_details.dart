import 'package:flutter/material.dart';
import 'package:Galaxy/model/document_model.dart';

class DocumentDetailsPage extends StatelessWidget {
  final DocumentModel person;
  final String heroTag;

  const DocumentDetailsPage(
      {super.key, required this.person, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Age: ${person.age}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Address: ${person.address}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
