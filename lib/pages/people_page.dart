import 'package:flutter/material.dart';
import 'package:galaxy/helpers/people_database_helper.dart';
import 'package:galaxy/views/overview/people_overview.dart';
import 'package:galaxy/views/forms/add_person.dart';

class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key});

  @override
  PeoplePageState createState() => PeoplePageState();
}

class PeoplePageState extends State<PeoplePage> {
  int _selectedIndex = 0;
  static const List<Widget> _pages = <Widget>[
    PeopleOverview(),
    AddPersonView(),
  ];

 void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Instantiate DatabaseHelper
  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            activeIcon:  Icon(Icons.people),
            icon:  Icon(Icons.people_alt_outlined),
            label: 'All People',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.person_add_rounded),
            icon: Icon(Icons.person_add_outlined),
            label: 'Add New',
          ),
        ],
      ),
    );
  }
}
