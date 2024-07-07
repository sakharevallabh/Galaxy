import 'package:flutter/material.dart';
import 'package:galaxy/model/person_model.dart';
import 'package:galaxy/provider/people_provider.dart';
import 'package:galaxy/views/details/person_details.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PeopleOverview extends StatelessWidget {
  final List<PersonModel> personList;

  const PeopleOverview({super.key, required this.personList});

  @override
  Widget build(BuildContext context) {
    print('$personList before loading people overview page 1');
    return Scaffold(
      body: _buildPersonList(context),
    );
  }

  Widget _buildPersonList(BuildContext context) {
    print('$personList before loading people overview page 2');
    if (personList.isNotEmpty) {
      print('$personList before loading people overview page 3');
      return ListView.builder(
        itemCount: personList.length,
        itemBuilder: (context, index) {
          PersonModel person = personList[index];
          return Card(
            child: ListTile(
              leading: _buildAvatar(person),
              title: Text(person.name ?? 'Unknown Name'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (person.profession != null &&
                      person.profession!.isNotEmpty)
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
                            launchUrlString(
                                'mailto:${person.emailAddresses![0]}');
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
                            launchUrlString('tel:${person.phoneNumbers![0]}');
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
                  if (context.mounted) {
                    Provider.of<PeopleProvider>(context, listen: false)
                        .refreshPeople();
                  }
                });
              },
            ),
          );
        },
      );
    } else {
      return const Center(child: Text('No data found.'));
    }
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
