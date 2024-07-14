import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Galaxy/helpers/people_database_helper.dart';
import 'package:Galaxy/pages/people_page.dart';
import 'package:Galaxy/provider/assets_data_provider.dart';
import 'package:Galaxy/provider/people_provider.dart';
import 'package:Galaxy/utils/image_utils.dart';
import 'package:Galaxy/widget/educationfield.dart';
import 'package:Galaxy/widget/searchfield.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class AddPersonView extends StatefulWidget {
  const AddPersonView({super.key});

  @override
  AddPersonViewState createState() => AddPersonViewState();
}

class AddPersonViewState extends State<AddPersonView> {
  final _formKey = GlobalKey<FormState>();
  final logger = Logger();
  final DatabaseHelper databaseHelper = DatabaseHelper();
  Uint8List? _photo;
  bool _isLoading = true;
  final List<TextEditingController> _degreeControllers = [];
  final List<TextEditingController> _institutionControllers = [];
  final List<TextEditingController> _yearControllers = [];
  final List<String> _selectedInterests = [];
  final List<String> _phoneNumbers = [];
  final List<String> _emailAddresses = [];
  final List<String> _links = [];
  final List<Map<String, String>> _educationDetails = [];
  Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _photo = null;
    _controllers.forEach((_, controller) {
      controller.removeListener(_onNameFieldChanged);
      controller.dispose();
    });
    super.dispose();
  }

  void _initializeControllers() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    await dataProvider.fetchData();
    _controllers = {
      'Name': TextEditingController(),
      'Relation': TextEditingController(),
      'Gender': TextEditingController(),
      'Date of Birth': TextEditingController(),
      'Place of Birth': TextEditingController(),
      'Present Address': TextEditingController(),
      'Present Pincode': TextEditingController(),
      'Present Country': TextEditingController(),
      'Permanent Address': TextEditingController(),
      'Marital Status': TextEditingController(),
      'Profession': TextEditingController(),
    };
    _controllers['Name']!.addListener(_onNameFieldChanged);
    setState(() {
      _isLoading = false;
    });
  }

  void _onNameFieldChanged() {
    setState(() {});
  }

  void _clearForm({bool dispose = false}) {
    if (!dispose) {
      _formKey.currentState!.reset();

      _controllers.forEach((_, controller) {
        controller.text = '';
      });

      _photo = null;
    }
  }

  void _pickImage() async {
    final bytes = await ImageUtils.pickImage();
    if (bytes != null) {
      setState(() {
        _photo = bytes;
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

      Map<String, dynamic> newPerson = {
        'name': _controllers['Name']?.text.trim(),
        'gender': _controllers['Gender']?.text.trim(),
        'dob': _controllers['Date of Birth']?.text.trim(),
        'birthPlace': _controllers['Place of Birth']?.text.trim(),
        'presentAddress': _controllers['Present Address']?.text.trim(),
        'presentPincode': _controllers['Present Pincode']?.text.trim(),
        'presentCountry': _controllers['Present Country']?.text.trim(),
        'permanentAddress': _controllers['Permanent Address']?.text.trim(),
        'maritalStatus': _controllers['Marital Status']?.text.trim(),
        'profession': _controllers['Profession']?.text.trim(),
        'relation': _controllers['Relation']?.text.trim(),
        'photo': _photo,
        'interests': jsonEncode(_selectedInterests),
        'phoneNumbers': jsonEncode(_phoneNumbers),
        'emailAddresses': jsonEncode(_emailAddresses),
        'educationDetails': jsonEncode(_educationDetails),
      };

      if (await Provider.of<PeopleProvider>(context, listen: false)
          .addPerson(newPerson)) {
        _showSnackBar('Person added successfully!');
      } else {
        _showSnackBar('Could not add person!');
      }

      Provider.of<PeopleProvider>(context, listen: false).refreshPeople();
      _clearForm();
    }
  }

  Widget _buildSearchFields(
      {required String key, required List<String> suggestions}) {
    return Column(
      children: [
        SearchableField(
          fieldName: key,
          suggestions: suggestions,
          controller: _controllers[key]!,
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildTextFields(
      {required String key, TextInputType inputType = TextInputType.text}) {
    return Column(
      children: [
        TextFormField(
          key: Key(key),
          controller: _controllers[key],
          decoration: InputDecoration(
            suffixIcon: key == "Name" ? const Icon(Icons.person) : null,
            labelText: key,
            hintText: key,
          ),
          keyboardType:
              key == "Present Pincode" ? TextInputType.number : inputType,
          validator: (value) =>
              key == "Name" && (value == null || value.isEmpty)
                  ? 'Please enter $key'
                  : null,
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildInterests(List<String> interests) {
    return Wrap(
      spacing: 8,
      children: interests.map((interest) {
        return FilterChip(
          label: Text(interest.trim()),
          selected: _selectedInterests.contains(interest.trim()),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedInterests.add(interest.trim());
              } else {
                _selectedInterests.remove(interest.trim());
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildEducationRows(String fieldName, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fieldName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        EducationField(
          index: index,
          degreeControllers: _degreeControllers,
          institutionControllers: _institutionControllers,
          yearControllers: _yearControllers,
          educationDetails: _educationDetails,
        )
      ],
    );
  }

  Widget _buildEducationFields() {
    return Column(
      children: [
        if (_educationDetails.isNotEmpty)
          for (int i = 0; i < _educationDetails.length; i++)
            _buildEducationRows('Education Details ${i + 1}', i),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _educationDetails
                  .add({'degree': '', 'institution': '', 'year': ''});
              _degreeControllers.add(TextEditingController());
              _institutionControllers.add(TextEditingController());
              _yearControllers.add(TextEditingController());
            });
          },
          child: const Text('Add Education'),
        ),
      ],
    );
  }

  Widget _buildDateOfBirthField() {
    return TextFormField(
      controller: _controllers['Date of Birth'],
      decoration: const InputDecoration(
        labelText: 'Date of Birth',
        hintText: 'Enter your date of birth',
        suffixIcon: Icon(Icons.calendar_today),
      ),
      readOnly: true,
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          String formattedDate =
              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
          setState(() {
            _controllers['Date of Birth']?.text = formattedDate;
          });
        }
      },
    );
  }

  Widget _buildPhoneNumberFields() {
    return _buildDynamicFields('Phone Number', _phoneNumbers, (index, value) {
      setState(() {
        _phoneNumbers[index] = value;
      });
    });
  }

  Widget _buildEmailFields() {
    return _buildDynamicFields('Email Address', _emailAddresses,
        (index, value) {
      setState(() {
        _emailAddresses[index] = value;
      });
    });
  }

  Widget _buildLinkFields() {
    return _buildDynamicFields('Link', _links, (index, value) {
      setState(() {
        _links[index] = value;
      });
    });
  }

  Widget _buildDynamicFields(
      String label, List<String> values, Function(int, String) onChanged) {
    return Column(
      children: [
        for (int i = 0; i < values.length; i++)
          TextFormField(
            initialValue: values[i],
            decoration: InputDecoration(
              labelText: label,
              suffixIcon: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    values.removeAt(i);
                  });
                },
              ),
            ),
            keyboardType: label == "Phone Number" ? TextInputType.number
                : label == "Email Address" ? TextInputType.emailAddress
                    : label == "Link" ? TextInputType.url : TextInputType.text,
            onChanged: (value) {
              onChanged(i, value);
            },
          ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            setState(() {
              values.add('');
            });
          },
          child: Text('Add $label'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Person'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PeoplePage()),
            );
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 90,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage:
                            _photo != null ? MemoryImage(_photo!) : null,
                        child: _photo == null
                            ? const Icon(Icons.add_a_photo,
                                size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                    _buildTextFields(key: 'Name'),
                    _buildSearchFields(key: 'Relation', suggestions: dataProvider.relations),
                    _buildSearchFields(key: 'Gender', suggestions: dataProvider.genders),
                    _buildDateOfBirthField(),
                    const SizedBox(height: 16.0),
                    _buildTextFields(key: 'Place of Birth'),
                    _buildTextFields(key: 'Present Address'),
                    _buildTextFields(key: 'Present Pincode'),
                    _buildSearchFields(key: 'Present Country', suggestions: dataProvider.countries),
                    _buildTextFields(key: 'Permanent Address'),
                    _buildSearchFields(key: 'Marital Status', suggestions: dataProvider.maritalStatuses),
                    _buildSearchFields(key: 'Profession', suggestions: dataProvider.professions),
                    _buildTextFields(key: 'Work Address'),
                    _buildPhoneNumberFields(),
                    _buildEmailFields(),
                    _buildLinkFields(),
                    _buildEducationFields(),
                    const Text('Interests', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8.0),
                    _buildInterests(dataProvider.interests),
                    const SizedBox(height: 100.0),
                  ],
                ),
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        verticalDirection: VerticalDirection.down,
        children: [
          if (_controllers.isNotEmpty)
            ValueListenableBuilder(
              valueListenable: _controllers['Name']!,
              builder: (context, TextEditingValue value, __) {
                return value.text.trim().isNotEmpty
                    ? FloatingActionButton(
                        onPressed: _saveForm,
                        tooltip: 'Save',
                        child: const Icon(Icons.save_rounded),
                      )
                    : const SizedBox.shrink();
              },
            ),
        ],
      ),
    );
  }
}
