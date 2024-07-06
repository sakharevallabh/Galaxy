import 'package:flutter/material.dart';
import 'package:galaxy/model/person_model.dart';
import 'package:galaxy/provider/people_provider.dart';
import 'package:galaxy/views/details/person_details.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
                      personId: person.id!,
                      heroTag: 'person_${person.name}',
                    ),
                  ),
                ).then((value) {
                  // Refresh the list when returning from details page
                  Provider.of<PeopleProvider>(context, listen: false).refreshPeople();
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
