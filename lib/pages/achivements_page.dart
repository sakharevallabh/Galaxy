import 'package:flutter/material.dart';
import 'package:Galaxy/model/achievement_model.dart';
import 'package:Galaxy/views/details/achivement_details.dart';
import 'package:Galaxy/views/forms/add_achievement.dart';
import 'package:Galaxy/views/overview/achivements_overview.dart';

class AchivementsPage extends StatefulWidget {
  const AchivementsPage({super.key});

  @override
  AchivementsPageState createState() => AchivementsPageState();
}

class AchivementsPageState extends State<AchivementsPage> {
  int _selectedIndex = 0;
  final AchievementModel selectedAchievement =
      const AchievementModel(name: 'Alice', age: 30, address: '123 Main St');

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
            selectedIcon: Icon(Icons.workspace_premium),
            icon: Icon(Icons.workspace_premium_outlined),
            label: 'All Achievements',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.stars),
            icon: Icon(Icons.stars_outlined),
            label: 'Details',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.flag_circle),
            icon: Icon(Icons.flag_circle_outlined),
            label: 'Add New',
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text('Achievements Galaxy'),
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
            const AchievementsOverview(),

            // Second Route
            AchievementDetailsPage(
                achievement: selectedAchievement,
                heroTag: 'achievement_${selectedAchievement.name}'),

            // Third Route
            const AddAchievementView(),
          ],
        ),
      ),
    );
  }
}