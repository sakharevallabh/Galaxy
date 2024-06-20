import 'package:flutter/material.dart';
import 'package:galaxy/model/person_model.dart';
import 'package:galaxy/helpers/people_database_helper.dart';
import 'package:share/share.dart';

class PersonDetailsPage extends StatefulWidget {
  final PersonModel person;
  final String heroTag;

  const PersonDetailsPage({super.key, required this.person, required this.heroTag});

  @override
  PersonDetailsPageState createState() => PersonDetailsPageState();
}

class PersonDetailsPageState extends State<PersonDetailsPage> {
  late PersonModel _person;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final List<String> _selectedFields = [];

  @override
  void initState() {
    super.initState();
    _person = widget.person;
  }

  Future<void> _updatePerson() async {
    await _databaseHelper.updatePerson(_person);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details updated successfully!')),
      );
    }
  }

  Future<void> _deletePerson() async {
    await _databaseHelper.deletePerson(_person.id!);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _toggleFieldSelection(String fieldName) {
    setState(() {
      if (_selectedFields.contains(fieldName)) {
        _selectedFields.remove(fieldName);
      } else {
        _selectedFields.add(fieldName);
      }
    });
  }

  void _shareSelectedFields() {
    final selectedData = _selectedFields.map((field) {
      switch (field) {
        case 'First Name':
          return 'First Name: ${_person.firstName}';
        case 'Middle Name':
          return 'Middle Name: ${_person.middleName}';
        case 'Last Name':
          return 'Last Name: ${_person.lastName}';
        case 'Gender':
          return 'Gender: ${_person.gender}';
        case 'Date of Birth':
          return 'Date of Birth: ${_person.dob}';
        case 'Birth Place':
          return 'Birth Place: ${_person.birthPlace}';
        case 'Country':
          return 'Country: ${_person.country}';
        case 'Pincode':
          return 'Pincode: ${_person.pincode}';
        case 'Nationality':
          return 'Nationality: ${_person.nationality}';
        case 'Marital Status':
          return 'Marital Status: ${_person.maritalStatus}';
        case 'Profession':
          return 'Profession: ${_person.profession}';
        case 'Addresses':
          return 'Addresses: ${_person.addresses?.join(', ')}';
        case 'Phone Numbers':
          return 'Phone Numbers: ${_person.phoneNumbers?.join(', ')}';
        case 'Email Addresses':
          return 'Email Addresses: ${_person.emailAddresses?.join(', ')}';
        case 'Social Media Profiles':
          return 'Social Media Profiles: ${_person.socialMediaProfiles?.join(', ')}';
        case 'Additional Fields':
          return 'Additional Fields: ${_person.additionalFields}';
        default:
          return '';
      }
    }).join('\n');

    Share.share(selectedData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Person Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deletePerson,
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'save',
            onPressed: _updatePerson,
            child: const Icon(Icons.save),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'share',
            onPressed: _shareSelectedFields,
            child: const Icon(Icons.share),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (_person.photo != null)
                CircleAvatar(
                  backgroundImage: MemoryImage(_person.photo!),
                  radius: 50,
                ),
              const SizedBox(height: 16),
              Hero(
                tag: widget.heroTag,
                child: Material(
                  color: Colors.transparent,
                  child: Text('First Name: ${_person.firstName}',
                      style: const TextStyle(fontSize: 18)),
                ),
              ),
              GestureDetector(
                onTap: () => _toggleFieldSelection('First Name'),
                child: Text('First Name: ${_person.firstName}',
                    style: TextStyle(
                      fontSize: 18,
                      color: _selectedFields.contains('First Name')
                          ? Colors.blue
                          : Colors.black,
                    )),
              ),
              GestureDetector(
                onTap: () => _toggleFieldSelection('Middle Name'),
                child: Text('Middle Name: ${_person.middleName}',
                    style: TextStyle(
                      fontSize: 18,
                      color: _selectedFields.contains('Middle Name')
                          ? Colors.blue
                          : Colors.black,
                    )),
              ),
              GestureDetector(
                onTap: () => _toggleFieldSelection('Last Name'),
                child: Text('Last Name: ${_person.lastName}',
                    style: TextStyle(
                      fontSize: 18,
                      color: _selectedFields.contains('Last Name')
                          ? Colors.blue
                          : Colors.black,
                    )),
              ),
              GestureDetector(
                onTap: () => _toggleFieldSelection('Gender'),
                child: Text('Gender: ${_person.gender}',
                    style: TextStyle(
                      fontSize: 18,
                      color: _selectedFields.contains('Gender')
                          ? Colors.blue
                          : Colors.black,
                    )),
              ),
              GestureDetector(
                onTap: () => _toggleFieldSelection('Date of Birth'),
                child: Text('Date of Birth: ${_person.dob}',
                    style: TextStyle(
                      fontSize: 18,
                      color: _selectedFields.contains('Date of Birth')
                          ? Colors.blue
                          : Colors.black,
                    )),
              ),
              GestureDetector(
                onTap: () => _toggleFieldSelection('Birth Place'),
                child: Text('Birth Place: ${_person.birthPlace}',
                    style: TextStyle(
                      fontSize: 18,
                      color: _selectedFields.contains('Birth Place')
                          ? Colors.blue
                          : Colors.black,
                    )),
              ),
              GestureDetector(
                onTap: () => _toggleFieldSelection('Country'),
                child: Text('Country: ${_person.country}',
                    style: TextStyle(
                      fontSize: 18,
                      color: _selectedFields.contains('Country')
                          ? Colors.blue
                          : Colors.black,
                    )),
              ),
              GestureDetector(
                onTap: () => _toggleFieldSelection('Pincode'),
                child: Text('Pincode: ${_person.pincode}',
                    style: TextStyle(
                      fontSize: 18,
                      color: _selectedFields.contains('Pincode')
                          ? Colors.blue
                          : Colors.black,
                    )),
              ),
              GestureDetector(
                onTap: () => _toggleFieldSelection('Nationality'),
                child: Text('Nationality: ${_person.nationality}',
                    style: TextStyle(
                      fontSize: 18,
                      color: _selectedFields.contains('Nationality')
                          ? Colors.blue
                          : Colors.black,
                    )),
              ),
              GestureDetector(
                onTap: () => _toggleFieldSelection('Marital Status'),
                child: Text('Marital Status: ${_person.maritalStatus}',
                    style: TextStyle(
                      fontSize: 18,
                      color: _selectedFields.contains('Marital Status')
                          ? Colors.blue
                          : Colors.black,
                    )),
              ),
              GestureDetector(
                onTap: () => _toggleFieldSelection('Profession'),
                child: Text('Profession: ${_person.profession}',
                    style: TextStyle(
                      fontSize: 18,
                      color: _selectedFields.contains('Profession')
                          ? Colors.blue
                          : Colors.black,
                    )),
              ),
              GestureDetector(
                onTap: () => _toggleFieldSelection('Addresses'),
                child: Text('Addresses: ${_person.addresses?.join(', ')}',
                    style: TextStyle(
                      fontSize: 18,
                      color: _selectedFields.contains('Addresses')
                          ? Colors.blue
                          : Colors.black,
                    )),
              ),
              GestureDetector(
                onTap: () => _toggleFieldSelection('Phone Numbers'),
                child: Text('Phone Numbers: ${_person.phoneNumbers?.join(', ')}',
                    style: TextStyle(
                      fontSize: 18,
                      color: _selectedFields.contains('Phone Numbers')
                          ? Colors.blue
                          : Colors.black,
                    )),
              ),
              GestureDetector(
                onTap: () => _toggleFieldSelection('Email Addresses'),
                child: Text('Email Addresses: ${_person.emailAddresses?.join(', ')}',
                    style: TextStyle(
                      fontSize: 18,
                      color: _selectedFields.contains('Email Addresses')
                          ? Colors.blue
                          : Colors.black,
                    )),
              ),
              GestureDetector(
                onTap: () => _toggleFieldSelection('Social Media Profiles'),
                child: Text('Social Media Profiles: ${_person.socialMediaProfiles?.join(', ')}',
                    style: TextStyle(
                      fontSize: 18,
                      color: _selectedFields.contains('Social Media Profiles')
                          ? Colors.blue
                          : Colors.black,
                    )),
              ),
              GestureDetector(
                onTap: () => _toggleFieldSelection('Additional Fields'),
                child: Text('Additional Fields: ${_person.additionalFields}',
                    style: TextStyle(
                      fontSize: 18,
                      color: _selectedFields.contains('Additional Fields')
                          ? Colors.blue
                          : Colors.black,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
