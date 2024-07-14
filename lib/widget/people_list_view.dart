import 'package:flutter/material.dart';
import 'package:Galaxy/model/person_model.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PeopleListView extends StatelessWidget {
  final List<PersonModel> personList;
  final Set<int> selectedIds;
  final bool selectModeOn;
  final Function(int, String) selectPerson;
  final Function(BuildContext, int, String) openPersonDetails;
  final Function(BuildContext, int, String, Offset) showListMenu;

  const PeopleListView({
    required this.personList,
    required this.selectedIds,
    required this.selectModeOn,
    required this.selectPerson,
    required this.openPersonDetails,
    required this.showListMenu,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (personList.isNotEmpty) {
      return ListView.builder(
        itemCount: personList.length,
        itemBuilder: (context, index) {
          PersonModel person = personList[index];
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
            if ((person.emailAddresses != null && person.emailAddresses!.isNotEmpty && person.emailAddresses![0].isNotEmpty) || 
                (person.phoneNumbers != null && person.phoneNumbers!.isNotEmpty && person.phoneNumbers![0].isNotEmpty))
              IconButton(
                icon: const Icon(Icons.email),
                onPressed: () {
                  _showCommunicationMenu(context, person);
                },
              ),
            if (person.phoneNumbers != null && person.phoneNumbers!.isNotEmpty && person.phoneNumbers![0].isNotEmpty)
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

  void _showCommunicationMenu(BuildContext context, PersonModel person) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            if (person.emailAddresses != null && person.emailAddresses!.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Send Email'),
              onTap: () {
                launchUrlString('mailto:${person.emailAddresses![0]}');
                Navigator.of(context).pop();
              },
            ),
            if (person.phoneNumbers != null && person.phoneNumbers!.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Send WhatsApp Message'),
              onTap: () {
                launchUrlString('https://wa.me/${person.phoneNumbers![0]}?text=Hi');
                Navigator.of(context).pop();
              },
            ),
            if (person.phoneNumbers != null && person.phoneNumbers!.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Send SMS'),
              onTap: () {
                launchUrlString('sms:${person.phoneNumbers![0]}');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
