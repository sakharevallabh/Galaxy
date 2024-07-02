import 'package:flutter/material.dart';
import 'package:galaxy/helpers/people_database_helper.dart';
import 'package:galaxy/model/person_model.dart';
import 'package:galaxy/views/overview/people_overview.dart';
import 'package:galaxy/views/forms/add_person.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key});

  @override
  PeoplePageState createState() => PeoplePageState();
}

class PeoplePageState extends State<PeoplePage> {
  int _selectedIndex = 0;
  final ValueNotifier<List<PersonModel>> _personListNotifier = ValueNotifier([]);
  List<PersonModel> _filteredPersonList = [];
  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowBanner();
    });
    _fetchPeople();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      _fetchPeople();
    }
  }

  Future<void> _checkAndShowBanner() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool bannerShown = prefs.getBool('bannerShown') ?? false;
    if (!bannerShown) {
      _showMaterialBanner();
      await prefs.setBool('bannerShown', true);
    }
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
    _personListNotifier.dispose();
    super.dispose();
  }

  void _fetchPeople() async {
    List<PersonModel> fetchedUsers = await databaseHelper.getAllPersons();
    if (mounted) {
      _personListNotifier.value = fetchedUsers;
      _filteredPersonList = fetchedUsers;
    }
  }

  void _filterList(String query) {
    if (query.isEmpty) {
      _filteredPersonList = _personListNotifier.value;
    } else {
      final lowerCaseQuery = query.toLowerCase();
      _filteredPersonList = _personListNotifier.value.where((person) {
        return (person.name?.toLowerCase().contains(lowerCaseQuery) ?? false) ||
            (person.relation?.toLowerCase().contains(lowerCaseQuery) ?? false) ||
            (person.profession?.toLowerCase().contains(lowerCaseQuery) ?? false);
      }).toList();
    }
    _personListNotifier.notifyListeners();
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
                delegate: PeopleSearchDelegate(_filterList, _personListNotifier.value),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<PersonModel>>(
        valueListenable: _personListNotifier,
        builder: (context, personList, child) {
          if (_selectedIndex == 0) {
            return PeopleOverview(personList: _filteredPersonList);
          } else {
            return const AddPersonView();
          }
        },
      ),
      bottomNavigationBar: PeopleNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        personListNotifier: _personListNotifier,
      ),
    );
  }
}

class PeopleNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final ValueNotifier<List<PersonModel>> personListNotifier;

  const PeopleNavigationBar({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.personListNotifier,
    super.key,
  });

  @override
  PeopleNavigationBarState createState() => PeopleNavigationBarState();
}

class PeopleNavigationBarState extends State<PeopleNavigationBar> {
  late String allPeopleLabel;

  @override
  void initState() {
    super.initState();
    widget.personListNotifier.addListener(_updateLabel);
    _updateLabel();
  }

  @override
  void dispose() {
    widget.personListNotifier.removeListener(_updateLabel);
    super.dispose();
  }

  void _updateLabel() {
    setState(() {
      allPeopleLabel = 'All People (${widget.personListNotifier.value.length})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: widget.selectedIndex,
      onDestinationSelected: widget.onItemTapped,
      destinations: <NavigationDestination>[
        NavigationDestination(
          selectedIcon: const Icon(Icons.people),
          icon: const Icon(Icons.people_alt_outlined),
          label: allPeopleLabel,
        ),
        const NavigationDestination(
          selectedIcon: Icon(Icons.person_add_rounded),
          icon: Icon(Icons.person_add_outlined),
          label: 'Add New',
        ),
      ],
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

    return PeopleOverview(personList: filteredList);
  }
}
