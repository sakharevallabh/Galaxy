import 'package:flutter/material.dart';
import 'package:Galaxy/model/vehicle_model.dart';

class VehicleDetailsPage extends StatelessWidget {
  final VehicleModel vehicle;
  final String heroTag;

  const VehicleDetailsPage({super.key, required this.vehicle, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${vehicle.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Age: ${vehicle.age}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Address: ${vehicle.address}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
