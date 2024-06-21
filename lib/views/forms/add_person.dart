import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:galaxy/helpers/people_database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class AddPersonView extends StatefulWidget {
  final Function()? onPersonAdded;

  const AddPersonView({super.key, this.onPersonAdded});

  @override
  AddPersonViewState createState() => AddPersonViewState();
}

class AddPersonViewState extends State<AddPersonView> {
  final _formKey = GlobalKey<FormState>();
  final logger = Logger();
  File? _image;
  final Map<String, dynamic> _formData = {};

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _genderController = TextEditingController();
  final _dobController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _countryController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _maritalStatusController = TextEditingController();
  final _professionController = TextEditingController();
  Uint8List? _photo;
  final List<Map<String, TextEditingController>> _additionalFields = [];

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void dispose() {
    _nameController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    _birthPlaceController.dispose();
    _countryController.dispose();
    _pincodeController.dispose();
    _nationalityController.dispose();
    _maritalStatusController.dispose();
    _professionController.dispose();
    for (var field in _additionalFields) {
      field['name']?.dispose();
      field['value']?.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
    pickedFile.readAsBytes().then((value) {
    setState(() {
      _image = File(pickedFile.path);
      _photo = value;
    });
    }).catchError((error) {
        logger.d('Error reading image: $error');
      });
    }
  }

  void _showSnackBar(String message) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
       _formKey.currentState!.save();
      if (_image != null) {
        _formData['photo'] = _image!.path;
      }
      final userId = await _databaseHelper.insertPerson({
        'name': _nameController.text,
        'gender': _genderController.text,
        'dob': _dobController.text,
        'birthPlace': _birthPlaceController.text,
        'country': _countryController.text,
        'pincode': _pincodeController.text,
        'nationality': _nationalityController.text,
        'maritalStatus': _maritalStatusController.text,
        'photo': _photo,
        'profession': _professionController.text,
      });

      for (var field in _additionalFields) {
        await _databaseHelper.insertAdditionalField({
          'userId': userId,
          'fieldName': field['name']?.text,
          'fieldValue': field['value']?.text,
        });
      }

      // Show a confirmation dialog or navigate to another page
      _showSnackBar('Person added successfully!');
       if (widget.onPersonAdded != null) {
        widget.onPersonAdded!();
      }
    }   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _genderController,
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(labelText: 'Date of Birth'),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dobController.text =
                          "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                    });
                  }
                },
              ),
              TextFormField(
                controller: _birthPlaceController,
                decoration: const InputDecoration(labelText: 'Birth Place'),
              ),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(labelText: 'Country'),
              ),
              TextFormField(
                controller: _pincodeController,
                decoration: const InputDecoration(labelText: 'Pincode'),
              ),
              TextFormField(
                controller: _nationalityController,
                decoration: const InputDecoration(labelText: 'Nationality'),
              ),
              TextFormField(
                controller: _maritalStatusController,
                decoration: const InputDecoration(labelText: 'Marital Status'),
              ),
              TextFormField(
                controller: _professionController,
                decoration: const InputDecoration(labelText: 'Profession'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Select Photo'),
              ),
               _image == null
                ? const Text('No image selected.')
                : Image.file(_image!),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _additionalFields.add({
                      'name': TextEditingController(),
                      'value': TextEditingController(),
                    });
                  });
                },
                child: const Text('Add Additional Field'),
              ),
              ..._additionalFields.map((field) {
                return Column(
                  children: [
                    TextFormField(
                      controller: field['name'],
                      decoration: const InputDecoration(
                        labelText: 'Field Name',
                      ),
                    ),
                    TextFormField(
                      controller: field['value'],
                      decoration: const InputDecoration(
                        labelText: 'Field Value',
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDynamicFields(
    BuildContext context,
    String label,
    List<TextEditingController> controllers,
  ) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                controllers.add(TextEditingController());
              });
            },
          ),
        ],
      ),
      ...controllers.map((controller) {
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
        );
      }),
    ];
  }
}
