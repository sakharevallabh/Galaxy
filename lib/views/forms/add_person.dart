import 'dart:convert';
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
  List<String> _professions = [];

  @override
  void initState() {
    super.initState();
    _fetchCountries();
    _fetchProfessions();
  }

  // Controllers for form fields
  late final Map<String, TextEditingController> _controllers = {
    'Name': TextEditingController(),
    'Gender': TextEditingController(),
    'Date of Birth': TextEditingController(),
    'Birth Place': TextEditingController(),
    'Present Address': TextEditingController(),
    'Present Pincode': TextEditingController(),
    'Present Country': TextEditingController(),
    'Permanent Address': TextEditingController(),
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
    _controllers['Present Address']!.text = "";
    _controllers['Present Pincode']!.text = "";
    _controllers['Present Country']!.text = "";
    _controllers['Permanent Address']!.text = "";
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
        'presentAddress': _controllers['Present Address']!.text,
        'presentPincode': _controllers['Present Pincode']!.text,
        'presentCountry': _controllers['Present Country']!.text,
        'permanentAddress': _controllers['Permanent Address']!.text,
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
    final String responseContries =
        await rootBundle.loadString('assets/data/countries.json');
    final List<dynamic> data = jsonDecode(responseContries);
    _countries = data.map((countries) => countries.toString()).toList();
  }

  Future<void> _fetchProfessions() async {
    final String responseProfessions =
        await rootBundle.loadString('assets/data/professions.json');
    final List<dynamic> data = jsonDecode(responseProfessions);
    _professions = data.map((professions) => professions.toString()).toList();
  }

  @override
  Widget build(BuildContext context) {
    _fetchCountries();
    _fetchProfessions();
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
                decoration: const InputDecoration(labelText: 'Place of Birth'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controllers['Present Address']!,
                decoration: const InputDecoration(labelText: 'Present Address'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controllers['Present Pincode']!,
                decoration: const InputDecoration(labelText: 'Present Pincode'),
              ),
              const SizedBox(height: 10),
              SearchField(
                controller: _controllers['Present Country']!,
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
                controller: _controllers['Permanent Address']!,
                decoration: const InputDecoration(labelText: 'Permanent Address'),
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
              SearchField(
                controller: _controllers['Profession']!,
                searchInputDecoration: const InputDecoration(
                  labelText: 'Profession',
                ),
                maxSuggestionsInViewPort: 5,
                autoCorrect: true,
                suggestions: _professions
                    .map((e) => SearchFieldListItem(e, child: Text(e)))
                    .toList(),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        verticalDirection: VerticalDirection.down,
        children: [
          FloatingActionButton(
            onPressed: _saveForm,
            tooltip: 'Save',
            child: const Icon(Icons.save_rounded),
          )
        ],
      ),
    );
  }
}
