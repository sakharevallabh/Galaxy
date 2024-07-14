import 'package:flutter/material.dart';
import 'package:Galaxy/model/asset_model.dart';

class AssetDetailsPage extends StatelessWidget {
  final AssetModel asset;
  final String heroTag;

  const AssetDetailsPage({super.key, required this.asset, required this.heroTag});

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
                  'Name: ${asset.name}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Age: ${asset.age}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Address: ${asset.address}',
              style: const TextStyle(fontSize: 16),
            ),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
