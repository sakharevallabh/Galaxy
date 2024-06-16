import 'package:flutter/material.dart';
import 'package:galaxy/model/person_model.dart';
import 'package:galaxy/views/details/person_details.dart';
import 'package:galaxy/views/overview/people_overview.dart';
import 'package:galaxy/views/forms/add_person.dart';

class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key});

  @override
  PeoplePageState createState() => PeoplePageState();
}

class PeoplePageState extends State<PeoplePage> {
  int _selectedIndex = 0;
  final PersonModel selectedPerson =
      const PersonModel(name: 'Alice', age: 30, address: '123 Main St');

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
            selectedIcon: Icon(Icons.people),
            icon: Icon(Icons.people_alt_outlined),
            label: 'All People',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outlined),
            label: 'Details',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person_add_rounded),
            icon: Icon(Icons.person_add_outlined),
            label: 'Add New',
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text('People Galaxy'),
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
            const PeopleOverview(),

            // Second Route
            PersonDetailsPage(
                person: selectedPerson,
                heroTag: 'person_${selectedPerson.name}'),

            // Third Route
            const AddPersonView(),
          ],
        ),
      ),
    );
  }
}
