import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:galaxy/helpers/people_database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:searchfield/searchfield.dart';

class AddPersonView extends StatefulWidget {
  final Function()? onPersonAdded;

  const AddPersonView({super.key, this.onPersonAdded});

  @override
  AddPersonViewState createState() => AddPersonViewState();
}

class AddPersonViewState extends State<AddPersonView> {
  final _formKey = GlobalKey<FormState>();
  final logger = Logger();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  XFile? _image;
  Uint8List? _photo;
  final Map<String, dynamic> _formData = {};
  final List<String> _maritalStatuses = ['Married', 'Unmarried', 'Divorced'];
  final List<String> _gender = ['Male', 'Female'];
  List<String> _countries = [];

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  // Controllers for form fields
  late final Map<String, TextEditingController> _controllers = {
    'Name': TextEditingController(),
    'Gender': TextEditingController(),
    'Date of Birth': TextEditingController(),
    'Birth Place': TextEditingController(),
    'Country': TextEditingController(),
    'Pincode': TextEditingController(),
    'Nationality': TextEditingController(),
    'Marital Status': TextEditingController(),
    'Profession': TextEditingController(),
  };

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

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _clearForm() {
    _controllers['Name']!.text = "";
    _controllers['Gender']!.text = "";
    _controllers['Date of Birth']!.text = "";
    _controllers['Birth Place']!.text = "";
    _controllers['Country']!.text = "";
    _controllers['Pincode']!.text = "";
    _controllers['Nationality']!.text = "";
    _controllers['Marital Status']!.text = "";
    _controllers['Profession']!.text = "";
    setState(() {
      _image = null;
      _photo = null;
      _photo!.clear();
    });
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_image != null) {
        _formData['photo'] = _image!.path;
      }
      await _databaseHelper.insertPerson({
        'name': _controllers['Name']!.text,
        'gender': _controllers['Gender']!.text,
        'dob': _controllers['Date of Birth']!.text,
        'birthPlace': _controllers['Birth Place']!.text,
        'country': _controllers['Country']!.text,
        'pincode': _controllers['Pincode']!.text,
        'nationality': _controllers['Nationality']!.text,
        'maritalStatus': _controllers['Marital Status']!.text,
        'profession': _controllers['Profession']!.text,
        'photo': _photo,
      });

      _showSnackBar('Person added successfully!');

      if (widget.onPersonAdded != null) {
        widget.onPersonAdded!();
      }
      _clearForm();
    }
  }

  Future<void> _fetchCountries() async {
    final String response =
        await rootBundle.loadString('assets/data/countries.json');
    final List<dynamic> data = jsonDecode(response);
    _countries = data.map((country) => country.toString()).toList();
  }

  @override
  Widget build(BuildContext context) {
    _fetchCountries();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 100,
                  backgroundImage: _image != null
                      ? MemoryImage(_photo!)
                      : const AssetImage('assets/images/placeholder.png')
                          as ImageProvider,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controllers['Name']!,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter name of the person';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              SearchField(
                controller: _controllers['Gender']!,
                searchInputDecoration: const InputDecoration(
                  labelText: 'Gender',
                ),
                maxSuggestionsInViewPort: 5,
                autoCorrect: true,
                suggestions: _gender
                    .map((e) => SearchFieldListItem(e, child: Text(e)))
                    .toList(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controllers['Date of Birth']!,
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
                      _controllers['Date of Birth']!.text =
                          "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controllers['Birth Place']!,
                decoration: const InputDecoration(labelText: 'Birth Place'),
              ),
              const SizedBox(height: 10),
              SearchField(
                controller: _controllers['Country']!,
                searchInputDecoration: const InputDecoration(
                  labelText: 'Present Country',
                ),
                maxSuggestionsInViewPort: 5,
                autoCorrect: true,
                suggestions: _countries
                    .map((e) => SearchFieldListItem(e, child: Text(e)))
                    .toList(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controllers['Pincode']!,
                decoration: const InputDecoration(labelText: 'Pincode'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controllers['Nationality']!,
                decoration: const InputDecoration(labelText: 'Nationality'),
              ),
              const SizedBox(height: 10),
              SearchField(
                controller: _controllers['Marital Status']!,
                searchInputDecoration: const InputDecoration(
                  labelText: 'Marital Status',
                ),
                maxSuggestionsInViewPort: 5,
                autoCorrect: true,
                suggestions: _maritalStatuses
                    .map((e) => SearchFieldListItem(e, child: Text(e)))
                    .toList(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controllers['Profession']!,
                decoration: const InputDecoration(labelText: 'Profession'),
              ),
              const SizedBox(height: 10),
              // ElevatedButton(
              //   onPressed: _pickImage,
              //   child: const Text('Select Photo'),
              // ),
              // _image == null
              //     ? const Text('No image selected.')
              //     : Image.file(_image!),
              // const SizedBox(height: 20),
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
}
