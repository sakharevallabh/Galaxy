import 'package:flutter/material.dart';
import 'package:galaxy/model/vehicle_model.dart';
import 'package:galaxy/views/details/vehicle_details.dart';
import 'package:galaxy/views/forms/add_vehicle.dart';
import 'package:galaxy/views/overview/vehicles_overview.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});

  @override
  VehiclesPageState createState() => VehiclesPageState();
}

class VehiclesPageState extends State<VehiclesPage> {
  int _selectedIndex = 0;
  final VehicleModel selectedVehicle =
      const VehicleModel(name: 'Alice', age: 30, address: '123 Main St');

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
            selectedIcon: Icon(Icons.directions_car_rounded),
            icon: Icon(Icons.directions_car_outlined),
            label: 'All Vehicles',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.car_rental_sharp),
            icon: Icon(Icons.car_rental_outlined),
            label: 'Details',
          ),
          NavigationDestination(
            selectedIcon: ImageIcon(
              AssetImage('assets/images/add_car.png'),
              size: 24,
            ),
            icon: ImageIcon(
              AssetImage('assets/images/add_car_outlined.png'),
              size: 24,
            ),
            label: 'Add New',
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text('Vehicles'),
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
            const VehiclesOverview(),

            // Second Route
            VehicleDetailsPage(
                vehicle: selectedVehicle,
                heroTag: 'vehicle_${selectedVehicle.name}'),

            // Third Route
            const AddVehicleView(),
          ],
        ),
      ),
    );
  }
}
