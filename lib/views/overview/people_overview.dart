import 'package:flutter/material.dart';
import 'package:galaxy/model/person_model.dart';
import 'package:galaxy/provider/people_provider.dart';
import 'package:galaxy/views/details/person_details.dart';
import 'package:galaxy/widget/people_list_view.dart';
import 'package:provider/provider.dart';

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
  void initState() {
    super.initState();
    _refreshPeople();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectModeOn
            ? '${_selectedIds.length} selected'
            : 'People Overview'),
        leading: _selectModeOn
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _selectModeOn = false;
                    _selectedIds.clear();
                  });
                },
              )
            : null,
        actions: [
          if (_selectModeOn)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedPersons,
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _selectModeOn = false;
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
        ],
      ),
      body: PeopleListView(
        personList: widget.personList,
        selectedIds: _selectedIds,
        selectModeOn: _selectModeOn,
        selectPerson: _selectPerson,
        openPersonDetails: _openPersonDetails,
        showListMenu: _showListMenu,
      ),
    );
  }

  Future<void> _deletePerson(
      BuildContext parentContext, int personId, String personName) async {
    bool success = await Provider.of<PeopleProvider>(parentContext, listen: false)
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
    _refreshPeople();
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

  void _importFromContacts() {
    print("Add code to import from contacts...");
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
        _refreshPeople();
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
      position: _calculateMenuPosition(tapPosition, overlay.size),
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

  RelativeRect _calculateMenuPosition(Offset tapPosition, Size overlaySize) {
    return RelativeRect.fromRect(
      Rect.fromPoints(tapPosition, tapPosition),
      Offset.zero & overlaySize,
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1000.0, 80.0, 0.0, 0.0),
      items: [
        PopupMenuItem(
          value: 'import_contacts',
          onTap: () => _importFromContacts(),
          child: const Text('Import From Contacts'),
        ),
        PopupMenuItem(
          value: 'delete_all',
          onTap: () async {
            await showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Confirm Delete'),
                content: const Text('Are you sure you want to delete?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: const Text('Delete'),
                    onPressed: () async {
                      await _deleteAllPersons(context);
                    },
                  ),
                ],
              ),
            );
          },
          child: const Text('Delete All'),
        ),
      ],
      elevation: 8.0,
    );
  }

  void _deleteSelectedPersons() {
    for (int id in _selectedIds.toList()) {
      _deletePerson(context, id, 'Selected Person');
    }
    setState(() {
      _selectedIds.clear();
      _selectModeOn = false;
    });
  }

  Future<void> _deleteAllPersons(BuildContext parentContext) async {
    final peopleProvider = Provider.of<PeopleProvider>(context, listen: false);
    for (PersonModel person in peopleProvider.personList.toList()) {
      _deletePerson(context, person.id!, person.name!);
    }
    setState(() {
      _selectedIds.clear();
      _selectModeOn = false;
    });
      Navigator.of(parentContext).pop();
  }

  void _refreshPeople() {
    Provider.of<PeopleProvider>(context, listen: false).refreshPeople();
  }
}

class PeopleSearchDelegate extends SearchDelegate<String> {
  final List<PersonModel> personList;
  final Set<int> selectedIds;
  bool selectModeOn;
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
          // selectModeOn = false;
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
        // selectModeOn = false;
        Provider.of<PeopleProvider>(context, listen: false).refreshPeople();
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

    return PeopleListView(
      personList: filteredList,
      selectedIds: selectedIds,
      selectModeOn: selectModeOn,
      selectPerson: selectPerson,
      openPersonDetails: openPersonDetails,
      showListMenu: showListMenu,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredList = personList.where((person) {
      final lowerCaseQuery = query.toLowerCase();
      return (person.name?.toLowerCase().contains(lowerCaseQuery) ?? false) ||
          (person.relation?.toLowerCase().contains(lowerCaseQuery) ?? false) ||
          (person.profession?.toLowerCase().contains(lowerCaseQuery) ?? false);
    }).toList();

    return PeopleListView(
      personList: filteredList,
      selectedIds: selectedIds,
      selectModeOn: selectModeOn,
      selectPerson: selectPerson,
      openPersonDetails: openPersonDetails,
      showListMenu: showListMenu,
    );
  }
}
