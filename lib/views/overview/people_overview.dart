import 'package:flutter/material.dart';
import 'package:galaxy/model/person_model.dart';
import 'package:galaxy/views/details/person_details.dart';

class PeopleOverview extends StatelessWidget {
  final List<PersonModel> personList;

  const PeopleOverview({super.key, required this.personList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPersonList(),
    );
  }

  Widget _buildPersonList() {
    return ListView.builder(
      itemCount: personList.length,
      itemBuilder: (context, index) {
        PersonModel person = personList[index];
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
              );
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
