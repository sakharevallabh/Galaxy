import 'package:flutter/material.dart';
import 'package:galaxy/helpers/people_database_helper.dart';
import 'package:galaxy/model/person_model.dart';
import 'package:galaxy/views/details/person_details.dart';

class PeopleOverview extends StatefulWidget {
  final List<PersonModel> personList;
  
  const PeopleOverview({super.key, required this.personList});
  @override
  PeopleOverviewPageState createState() => PeopleOverviewPageState();
}

class PeopleOverviewPageState extends State<PeopleOverview> {
 List<PersonModel> _personList = [];
 DatabaseHelper databaseHelper = DatabaseHelper();

  // @override
  // void initState() {
  //   super.initState();
  //   _fetchPeople();
  // }

  //   Future<void> _fetchPeople() async {
  //   List<PersonModel> fetchedUsers = await databaseHelper.getPerson();
  //     setState(() {
  //       _personList = fetchedUsers;
  //     });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPersonList(),
    );
  }

  Widget _buildPersonList() {
    if (widget.personList.isEmpty) {
      return const Center(
        child: Text('No persons available'),
      );
    }
    _personList = widget.personList;

    return ListView.builder(
      itemCount: _personList.length,
      itemBuilder: (context, index) {
        PersonModel person = _personList[index];
        return Card(
          child: ListTile(
            leading: _buildAvatar(person),
            title: Text(person.name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonDetailsPage(
                    person: person,
                    heroTag: 'person_${person.name}',
                  ),
                ),
              ).then((value) {
                if (value == true) {
                  // Trigger a refresh when coming back from details page
                  (context as Element).markNeedsBuild();
                }
              });
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

