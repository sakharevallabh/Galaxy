import 'package:flutter/material.dart';
import 'package:galaxy/helpers/people_database_helper.dart';
import 'package:galaxy/model/person_model.dart';
import 'package:galaxy/views/details/person_details.dart';

class PeopleOverview extends StatefulWidget {
  const PeopleOverview({super.key});

  @override
  PeopleOverviewState createState() => PeopleOverviewState();
}

class PeopleOverviewState extends State<PeopleOverview> {
  late List<PersonModel> _personList;
  late DatabaseHelper databaseHelper;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
    _searchController = TextEditingController();
    _fetchPeople();
  }

  void _fetchPeople() async {
    List<Map<String, dynamic>> fetchedUsers = await databaseHelper.getPerson();
    setState(() {
      _personList = fetchedUsers.map((userMap) => PersonModel.fromMap(userMap)).toList();
    });
  }

  void _filterList(String query) {
    List<PersonModel> filteredList = _personList.where((person) {
      return person.firstName.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _personList = filteredList;
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose of the search controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All People (${_personList.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _SearchDelegate(_filterList),
              );
            },
          ),
        ],
      ),
      body: _buildPersonList(),
    );
  }

  Widget _buildPersonList() {
    return ListView.builder(
      itemCount: _personList.length,
      itemBuilder: (context, index) {
        PersonModel person = _personList[index];
        return Card(
          child: ListTile(
            leading: _buildAvatar(person),
            title: Text(person.firstName),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonDetailsPage(
                    person: person,
                    heroTag: 'person_${person.firstName}',
                  ),
                ),
              ).then((value) => _fetchPeople());
            },
          ),
        );
      },
    );
  }

  Widget _buildAvatar(PersonModel person) {
    return person.photo != null
        ? CircleAvatar(
            backgroundImage: MemoryImage(person.photo!),
          )
        : const CircleAvatar(child: Icon(Icons.person));
  }
}

class _SearchDelegate extends SearchDelegate<String> {
  final Function(String) _filterCallback;

  _SearchDelegate(this._filterCallback);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
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
    _filterCallback(query);
    return const SizedBox(); // Adjust to show actual search results
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const SizedBox(); // Suggestions based on query, if needed
  }
}
