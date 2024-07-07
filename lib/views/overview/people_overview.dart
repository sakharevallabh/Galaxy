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
    return Scaffold(
      body: _buildPersonList(context),
    );
  }

  Future<void> _deletePerson(
      BuildContext context, int personId, String personName) async {
    bool success = await Provider.of<PeopleProvider>(context, listen: false)
        .deletePerson(personId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Person deleted successfully!' : 'Error deleting person!',
          ),
        ),
      );
      if (context.mounted) {
        Provider.of<PeopleProvider>(context, listen: false).refreshPeople();
      }
    }
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
        Provider.of<PeopleProvider>(context, listen: false).refreshPeople();
      }
    });
  }

  void _showListMenu(BuildContext context, int personId, String personName, Offset tapPosition) {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
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
      ],
      elevation: 8.0,
    );
  }

  Widget _buildPersonList(BuildContext context) {
    if (personList.isNotEmpty) {
      return ListView.builder(
        itemCount: personList.length,
        itemBuilder: (context, index) {
          PersonModel person = personList[index];
          return GestureDetector(
            onLongPressStart: (details) {
              _showListMenu(
                context,
                person.id!,
                person.name!,
                details.globalPosition,
              );
            },
            child: Card(
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
                    if (person.emailAddresses != null && person.emailAddresses!.isNotEmpty)
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
                onTap: () => _openPersonDetails(context, person.id!, person.name!),
              ),
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
