import 'package:flutter/material.dart';
import 'package:galaxy/model/person_model.dart';
import 'package:galaxy/provider/people_provider.dart';
import 'package:galaxy/views/details/person_details.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PeopleOverview extends StatefulWidget {
  final List<PersonModel> personList;

  const PeopleOverview({super.key, required this.personList});

  @override
  PeopleOverviewState createState() => PeopleOverviewState();
}

class PeopleOverviewState extends State<PeopleOverview> {
  final Set<int> _selectedIds = {};
  bool _selectModeOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('People Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: PeopleSearchDelegate(
                  personList: widget.personList,
                  selectedIds: _selectedIds,
                  selectModeOn: _selectModeOn,
                  showListMenu: _showListMenu,
                  selectPerson: _selectPerson,
                  openPersonDetails: _openPersonDetails,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showSettingsMenu(context);
            },
          ),
        ],
      ),
      body: _buildPersonList(context, widget.personList),
    );
  }

  Future<void> _deletePerson(
      BuildContext context, int personId, String personName) async {
    bool success = await Provider.of<PeopleProvider>(context, listen: false)
        .deletePerson(personId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Person deleted successfully!' : 'Error deleting person!',
          ),
        ),
      );
    }
    _refrshPeople();
  }

  void _selectPerson(int personId, String personName) {
    setState(() {
      _selectModeOn = true;
      if (_selectedIds.contains(personId)) {
        _selectedIds.remove(personId);
      } else {
        _selectedIds.add(personId);
      }
    });
  }

  void _openPersonDetails(
      BuildContext context, int personId, String personName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonDetailsPage(
          personId: personId,
          heroTag: 'person_$personName',
        ),
      ),
    ).then((value) {
      if (context.mounted) {
        _refrshPeople();
      }
    });
    _selectModeOn = false;
  }

  void _showListMenu(BuildContext context, int personId, String personName,
      Offset tapPosition) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          tapPosition,
          tapPosition,
        ),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'open',
          onTap: () => _openPersonDetails(context, personId, personName),
          child: const Text('Open'),
        ),
        PopupMenuItem(
          value: 'delete',
          onTap: () => _deletePerson(context, personId, personName),
          child: const Text('Delete'),
        ),
        PopupMenuItem(
          value: 'select',
          onTap: () => _selectPerson(personId, personName),
          child: const Text('Select'),
        ),
      ],
      elevation: 8.0,
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1000.0, 80.0, 0.0, 0.0),
      items: [
        PopupMenuItem(
          value: 'delete_selected',
          onTap: () => _deleteSelectedPersons(),
          child: const Text('Delete Selected'),
        ),
        PopupMenuItem(
          value: 'delete_all',
          onTap: () => _deleteAllPersons(),
          child: const Text('Delete All'),
        ),
      ],
      elevation: 8.0,
    );
  }

  void _deleteSelectedPersons() {
    for (int id in _selectedIds) {
      _deletePerson(context, id, 'Selected Person');
    }
    setState(() {
      _selectedIds.clear();
    });
  }

  void _deleteAllPersons() {
    final peopleProvider = Provider.of<PeopleProvider>(context, listen: false);
    for (PersonModel person in peopleProvider.personList) {
      _deletePerson(context, person.id!, person.name!);
    }
    setState(() {
      _selectedIds.clear();
    });
  }

  void _refrshPeople() {
    Provider.of<PeopleProvider>(context, listen: false).refreshPeople();
  }

  Widget _buildPersonList(BuildContext context, List<PersonModel> personList) {
    if (personList.isNotEmpty) {
      return ListView.builder(
        itemCount: personList.length,
        itemBuilder: (context, index) {
          PersonModel person = personList[index];
          bool isSelected = _selectedIds.contains(person.id!);
          return GestureDetector(
            onLongPressStart: (details) {
              _showListMenu(
                context,
                person.id!,
                person.name!,
                details.globalPosition,
              );
            },
            child: PersonListItem(
              person: person,
              isSelected: isSelected,
              selectModeOn: _selectModeOn,
              onTap: () {
                if (_selectModeOn) {
                  _selectPerson(person.id!, person.name!);
                } else {
                  _openPersonDetails(context, person.id!, person.name!);
                }
              },
            ),
          );
        },
      );
    } else {
      return const Center(child: Text('No data found.'));
    }
  }
}

class PersonListItem extends StatelessWidget {
  final PersonModel person;
  final bool isSelected;
  final bool selectModeOn;
  final VoidCallback onTap;

  const PersonListItem({
    required this.person,
    required this.isSelected,
    required this.selectModeOn,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? Colors.lightBlueAccent : null,
      child: ListTile(
        leading: _buildAvatar(person),
        title: Text(person.name ?? 'Unknown Name'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (person.profession != null && person.profession!.isNotEmpty)
              Text(person.profession!),
            if (person.relation != null && person.relation!.isNotEmpty)
              Text('(${person.relation!})'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (person.emailAddresses != null &&
                person.emailAddresses!.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.email),
                onPressed: () {
                  launchUrlString('mailto:${person.emailAddresses![0]}');
                },
              ),
            if (person.phoneNumbers != null && person.phoneNumbers!.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.phone),
                onPressed: () {
                  launchUrlString('tel:${person.phoneNumbers![0]}');
                },
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAvatar(PersonModel person) {
    return CircleAvatar(
      child: person.photo != null
          ? ClipOval(
              child: Image.memory(
                person.photo!,
                fit: BoxFit.cover,
                width: 60,
                height: 60,
              ),
            )
          : const Icon(Icons.person),
    );
  }
}

class PeopleSearchDelegate extends SearchDelegate<String> {
  final List<PersonModel> personList;
  final Set<int> selectedIds;
  final bool selectModeOn;
  final Function(int, String) selectPerson;
  final Function(BuildContext, int, String) openPersonDetails;
  final Function(BuildContext, int, String, Offset) showListMenu;

  PeopleSearchDelegate({
    required this.personList,
    required this.selectedIds,
    required this.selectModeOn,
    required this.selectPerson,
    required this.openPersonDetails,
    required this.showListMenu,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
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
        Provider.of<PeopleProvider>(context, listen: false).refreshPeople();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredList = personList.where(
        (person) => person.name!.toLowerCase().contains(query.toLowerCase()));
    return _buildFilteredList(context, filteredList.toList());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredList = personList.where(
        (person) => person.name!.toLowerCase().contains(query.toLowerCase()));
    return _buildFilteredList(context, filteredList.toList());
  }

  Widget _buildFilteredList(
      BuildContext context, List<PersonModel> filteredList) {
    if (filteredList.isNotEmpty) {
      return ListView.builder(
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          PersonModel person = filteredList[index];
          bool isSelected = selectedIds.contains(person.id!);
          return GestureDetector(
            onLongPressStart: (details) {
              showListMenu(
                context,
                person.id!,
                person.name!,
                details.globalPosition,
              );
            },
            child: PersonListItem(
              person: person,
              isSelected: isSelected,
              selectModeOn: selectModeOn,
              onTap: () {
                if (selectModeOn) {
                  selectPerson(person.id!, person.name!);
                } else {
                  openPersonDetails(context, person.id!, person.name!);
                }
              },
            ),
          );
        },
      );
    } else {
      return const Center(child: Text('No data found.'));
    }
  }
}
