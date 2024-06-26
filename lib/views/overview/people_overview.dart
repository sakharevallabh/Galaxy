import 'package:flutter/material.dart';
import 'package:galaxy/helpers/people_database_helper.dart';
import 'package:galaxy/model/person_model.dart';
import 'package:galaxy/views/details/person_details.dart';
import 'package:url_launcher/url_launcher.dart';

class PeopleOverview extends StatefulWidget {
  final List<PersonModel> personList;

  const PeopleOverview({super.key, required this.personList});

  @override
  PeopleOverviewState createState() => PeopleOverviewState();
}

class PeopleOverviewState extends State<PeopleOverview> {
  List<PersonModel> _personList = [];
  List<PersonModel> fetchedUsers = [];
  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _fetchPeople();
  }

  Future<void> _fetchPeople() async {
    fetchedUsers = await databaseHelper.getAllPersons();
    setState(() {
      _personList = fetchedUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPersonList(),
    );
  }

  Widget _buildPersonList() {
      if (widget.personList.length != _personList.length) {
        fetchedUsers = widget.personList;
      }
      return ListView.builder(
        itemCount: fetchedUsers.length,
        itemBuilder: (context, index) {
          PersonModel person = fetchedUsers[index];
          return Card(
            child: ListTile(
              leading: _buildAvatar(person),
              title: Text(person.name!),
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
                  (person.emailAddresses != null &&
                          person.emailAddresses!.isNotEmpty)
                      ? IconButton(
                          icon: const Icon(Icons.email),
                          onPressed: () {
                            launch('mailto:${person.emailAddresses![0]}');
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.mail_lock_rounded),
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('No email address saved.'),
                            ));
                          },
                        ),
                  (person.phoneNumbers != null &&
                          person.phoneNumbers!.isNotEmpty)
                      ? IconButton(
                          icon: const Icon(Icons.phone),
                          onPressed: () {
                            launch('tel:${person.phoneNumbers![0]}');
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.phone_disabled_rounded),
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('No phone number saved.'),
                            ));
                          },
                        ),
                ],
              ),
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
                  // Refresh the list when returning from details page
                  _fetchPeople();
                });
              },
            ),
          );
        },
      );
    // }
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
