import 'package:flutter/material.dart';
import 'package:Galaxy/model/asset_model.dart';
import 'package:Galaxy/views/details/asset_details.dart';
import 'package:Galaxy/views/forms/add_asset.dart';
import 'package:Galaxy/views/overview/assets_overview.dart';

class AssetsPage extends StatefulWidget {
  const AssetsPage({super.key});

  @override
  AssetsPageState createState() => AssetsPageState();
}

class AssetsPageState extends State<AssetsPage> {
  int _selectedIndex = 0;
  final AssetModel selectedAsset =
      const AssetModel(name: 'Alice', age: 30, address: '123 Main St');

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
            selectedIcon: Icon(Icons.real_estate_agent_sharp),
            icon: Icon(Icons.real_estate_agent_outlined),
            label: 'All Assets',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.home_work_rounded),
            icon: Icon(Icons.home_work_outlined),
            label: 'Details',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.add_home_work_rounded),
            icon: Icon(Icons.add_home_work_outlined),
            label: 'Add New',
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text('Assets Galxy'),
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
            const AssetsOverview(),

            // Second Route
            AssetDetailsPage(
                asset: selectedAsset,
                heroTag: 'asset_${selectedAsset.name}'),

            // Third Route
            const AddAssetView(),
          ],
        ),
      ),
    );
  }
}
