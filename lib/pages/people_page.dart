import 'package:flutter/material.dart';
import 'package:galaxy/helpers/people_database_helper.dart';
import 'package:galaxy/model/person_model.dart';
import 'package:galaxy/views/overview/people_overview.dart';
import 'package:galaxy/views/forms/add_person.dart';

class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key});

  @override
  PeoplePageState createState() => PeoplePageState();
}

class PeoplePageState extends State<PeoplePage> {
  int _selectedIndex = 0;
  List<PersonModel> _personList = [];
  List<PersonModel> _filteredPersonList = [];
  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _fetchPeople();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _fetchPeople() async {
    List<Map<String, dynamic>> fetchedUsers = await databaseHelper.getPerson();
    if (mounted) {
      setState(() {
        _personList = fetchedUsers.map((userMap) => PersonModel.fromMap(userMap)).toList();
        _filteredPersonList = _personList;
      });
    }
  }

  void _filterList(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPersonList = _personList;
      } else {
        _filteredPersonList = _personList.where((person) {
          return person.firstName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _SearchDelegate(_filterList, _personList),
              );
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? PeopleOverview(personList: _filteredPersonList)
          : const AddPersonView(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: <NavigationDestination>[
          NavigationDestination(
            selectedIcon: const Icon(Icons.people),
            icon: const Icon(Icons.people_alt_outlined),
            label: 'All People (${_filteredPersonList.length})',
          ),
          const NavigationDestination(
            selectedIcon: Icon(Icons.person_add_rounded),
            icon: Icon(Icons.person_add_outlined),
            label: 'Add New',
          ),
        ],
      ),
    );
  }
}

class _SearchDelegate extends SearchDelegate<String> {
  final Function(String) _filterCallback;
  final List<PersonModel> _originalPersonList;

  _SearchDelegate(this._filterCallback, this._originalPersonList);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          _filterCallback(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredList = _originalPersonList.where((person) {
      return person.firstName.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return PeopleOverview(personList: filteredList);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredList = _originalPersonList.where((person) {
      return person.firstName.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return PeopleOverview(personList: filteredList);
  }
}
