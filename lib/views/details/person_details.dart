import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:galaxy/model/person_model.dart';
import 'package:galaxy/helpers/people_database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:share/share.dart';

class PersonDetailsPage extends StatefulWidget {
  final PersonModel person;
  final String heroTag;

  const PersonDetailsPage(
      {super.key, required this.person, required this.heroTag});

  @override
  PersonDetailsPageState createState() => PersonDetailsPageState();
}

class PersonDetailsPageState extends State<PersonDetailsPage> {
  late PersonModel _person;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final List<String> _selectedFields = [];
  late Map<String, TextEditingController> _controllers;
  XFile? _image;
  Uint8List? _photo;
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    _person = widget.person;
    _controllers = {
      'Name': TextEditingController(text: _person.name),
      'Gender': TextEditingController(text: _person.gender),
      'Date of Birth': TextEditingController(text: _person.dob),
      'Birth Place': TextEditingController(text: _person.birthPlace),
      'Present Address': TextEditingController(text: _person.presentAddress),
      'Present Country': TextEditingController(text: _person.presentCountry),
      'Present Pincode': TextEditingController(text: _person.presentPincode),
      'Permanent Address':
          TextEditingController(text: _person.permanentAddress),
      'Marital Status': TextEditingController(text: _person.maritalStatus),
      'Profession': TextEditingController(text: _person.profession),
    };
    _photo = _person.photo;
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  Future<void> _updatePerson() async {
    PersonModel personUpdated = PersonModel(
      id: _person.id,
      photo: _photo,
      name: _controllers['Name']!.text,
      gender: _controllers['Gender']!.text,
      dob: _controllers['Date of Birth']!.text,
      birthPlace: _controllers['Birth Place']!.text,
      presentAddress: _controllers['Present Address']!.text,
      presentPincode: _controllers['Present Pincode']!.text,
      presentCountry: _controllers['Present Country']!.text,
      permanentAddress: _controllers['Permanent Address']!.text,
      maritalStatus: _controllers['Marital Status']!.text,
      profession: _controllers['Profession']!.text,
    );
    await _databaseHelper.updatePerson(personUpdated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details updated successfully!')),
      );
      // Navigator.pop(context, true); // Indicate that an update has occurred
    }
  }

  Future<void> _deletePerson() async {
    await _databaseHelper.deletePerson(_person.id!);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      pickedFile.readAsBytes().then((value) {
        setState(() {
          //  _image = pickedFile;
          _image = pickedFile;
          _photo = value;
        });
      }).catchError((error) {
        logger.d('Error reading image: $error');
      });
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
        case 'Name':
          return 'Name: ${_person.name}';
        case 'Gender':
          return 'Gender: ${_person.gender}';
        case 'Date of Birth':
          return 'Date of Birth: ${_person.dob}';
        case 'Birth Place':
          return 'Birth Place: ${_person.birthPlace}';
        case 'Present Address':
          return 'Present Address: ${_person.presentAddress}';
        case 'Country':
          return 'Country: ${_person.presentCountry}';
        case 'Pincode':
          return 'Pincode: ${_person.presentPincode}';
        case 'Permanent Address':
          return 'Permanent Address: ${_person.permanentAddress}';
        case 'Marital Status':
          return 'Marital Status: ${_person.maritalStatus}';
        case 'Profession':
          return 'Profession: ${_person.profession}';
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
              Hero(
                tag: 'person_image_${widget.person.id}',
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _image != null
                        ? FileImage(File(_image!.path))
                        : widget.person.photo != null
                            ? MemoryImage(widget.person.photo!)
                            : const AssetImage('assets/images/placeholder.png')
                                as ImageProvider,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Hero(
                tag: widget.heroTag,
                child: _buildEditableField('Name', _controllers['Name']!),
              ),
              _buildEditableField('Gender', _controllers['Gender']!),
              _buildEditableField(
                  'Date of Birth', _controllers['Date of Birth']!),
              _buildEditableField('Birth Place', _controllers['Birth Place']!),
              _buildEditableField(
                  'Present Address', _controllers['Present Address']!),
              _buildEditableField(
                  'Present Country', _controllers['Present Country']!),
              _buildEditableField(
                  'Present Pincode', _controllers['Present Pincode']!),
              _buildEditableField(
                  'Permanent Address', _controllers['Permanent Address']!),
              _buildEditableField(
                  'Marital Status', _controllers['Marital Status']!),
              _buildEditableField('Profession', _controllers['Profession']!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(
      String fieldName, TextEditingController controller) {
    return GestureDetector(
      onTap: () => _toggleFieldSelection(fieldName),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                _selectedFields.contains(fieldName) ? Colors.blue : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fieldName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter $fieldName',
              ),
              onChanged: (value) {
                setState(() {
                  switch (fieldName) {
                    case 'First Name':
                      _person.name = value;
                      break;
                    case 'Gender':
                      _person.gender = value;
                      break;
                    case 'Date of Birth':
                      _person.dob = value;
                      break;
                    case 'Birth Place':
                      _person.birthPlace = value;
                      break;
                    case 'Present Address':
                      _person.presentAddress = value;
                      break;
                    case 'Present Country':
                      _person.presentCountry = value;
                      break;
                    case 'Present Pincode':
                      _person.presentPincode = value;
                      break;
                    case 'Permanent Address':
                      _person.permanentAddress = value;
                      break;
                    case 'Marital Status':
                      _person.maritalStatus = value;
                      break;
                    case 'Profession':
                      _person.profession = value;
                      break;
                    default:
                      break;
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
