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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showMaterialBanner();
    });
    _fetchPeople();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _fetchPeople();
  }

  void _showMaterialBanner() {
    _clearMaterialBanner();
    ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
      padding: const EdgeInsets.all(16),
      leading: const Icon(Icons.info, color: Colors.black, size: 32),
      backgroundColor: Colors.white,
      content: const Text(
          'All details are stored on your phone or cloud of your choice and not on our servers.'),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () =>
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
        )
      ],
    ));
  }

  void _clearMaterialBanner() {
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<PersonModel>> _fetchPeople() async {
    return await databaseHelper.getAllPersons();
  }

  void _filterList(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredPersonList = _personList;
      });
    } else {
      final lowerCaseQuery = query.toLowerCase();
      setState(() {
        _filteredPersonList = _personList.where((person) {
          return (person.name?.toLowerCase().contains(lowerCaseQuery) ?? false) ||
              (person.relation?.toLowerCase().contains(lowerCaseQuery) ?? false) ||
              (person.profession?.toLowerCase().contains(lowerCaseQuery) ?? false);
        }).toList();
      });
    }
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
                delegate: PeopleSearchDelegate(_filterList, _personList),
              );
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? FutureBuilder<List<PersonModel>>(
              future: _fetchPeople(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No persons available'));
                } else {
                  _personList = snapshot.data!;
                  _filteredPersonList = _personList;
                  return PeopleOverview(personList: _filteredPersonList);
                }
              },
            )
          : const AddPersonView(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: <NavigationDestination>[
          NavigationDestination(
            selectedIcon: const Icon(Icons.people),
            icon: const Icon(Icons.people_alt_outlined),
            label: 'All People (${_personList.length})',
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

class PeopleSearchDelegate extends SearchDelegate<String> {
  final Function(String) filterCallback;
  final List<PersonModel> personList;

  PeopleSearchDelegate(this.filterCallback, this.personList);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          filterCallback(query);
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
    final filteredList = personList.where((person) {
      final lowerCaseQuery = query.toLowerCase();
      return (person.name?.toLowerCase().contains(lowerCaseQuery) ?? false) ||
          (person.relation?.toLowerCase().contains(lowerCaseQuery) ?? false) ||
          (person.profession?.toLowerCase().contains(lowerCaseQuery) ?? false);
    }).toList();

    // Call the filterCallback function from PeoplePage to update state
    WidgetsBinding.instance.addPostFrameCallback((_) => filterCallback(query));
    return PeopleOverview(personList: filteredList);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredList = personList.where((person) {
      final lowerCaseQuery = query.toLowerCase();
      return (person.name?.toLowerCase().contains(lowerCaseQuery) ?? false) ||
          (person.relation?.toLowerCase().contains(lowerCaseQuery) ?? false) ||
          (person.profession?.toLowerCase().contains(lowerCaseQuery) ?? false);
    }).toList();
    // Call the filterCallback function from PeoplePage to update state
    WidgetsBinding.instance.addPostFrameCallback((_) => filterCallback(query));
    return PeopleOverview(personList: filteredList);
  }
}
