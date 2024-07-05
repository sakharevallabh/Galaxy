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
  final DatabaseHelper databaseHelper =
      DatabaseHelper(); // Update with your actual database helper class
  XFile? _image;
  Uint8List? _photo;
  final Map<String, TextEditingController> _controllers = {
    'Name': TextEditingController(),
    'Gender': TextEditingController(),
    'Date of Birth': TextEditingController(),
    'Place of Birth': TextEditingController(),
    'Present Address': TextEditingController(),
    'Present Pincode': TextEditingController(),
    'Present Country': TextEditingController(),
    'Permanent Address': TextEditingController(),
    'Marital Status': TextEditingController(),
    'Profession': TextEditingController(),
    'Relation': TextEditingController(),
  };
  final List<String> _maritalStatuses = ['Married', 'Unmarried', 'Divorced'];
  final List<String> _gender = ['Male', 'Female'];
  List<String> _countries = [];
  List<String> _professions = [];
  List<String> _interests = [];
  List<String> _relations = [];
  final List<String> _degrees = [
    'Graduate',
    'Bachelor',
    'Master',
    'PhD',
    'Other'
  ];
  final List<String> _selectedInterests = [];
  final List<String> _phoneNumbers = [];
  final List<String> _emailAddresses = [];
    final List<String> _links = [];
  final List<Map<String, String>> _educationDetails = [];

  @override
  void initState() {
    super.initState();
    _fetchCountries();
    _fetchProfessions();
    _fetchInterests();
    _fetchRelations();
  }

  @override
  void dispose() {
    _clearForm();
    _controllers.forEach((key, controller) {
      controller.dispose();
    });
    _countries = [];
    _professions = [];
    _interests = [];
    _relations = [];
    super.dispose();
  }

  void _clearForm() {
    _formKey.currentState!.reset();
    _controllers.forEach((key, controller) {
      controller.clear();
    });
    setState(() {
      _image = null;
      _photo = null;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      pickedFile.readAsBytes().then((value) {
        setState(() {
          _image = pickedFile;
          _photo = value;
        });
      }).catchError((error) {
        logger.d('Error reading image: $error');
      });
    }
  }

  void _showSnackBar(String message) {
    // ScaffoldMessenger.of(context).removeCurrentSnackBar();
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
        _controllers['Photo']?.text =
            _image!.path;
      }

      await databaseHelper.insertPerson({
        'name': _controllers['Name']?.text,
        'gender': _controllers['Gender']?.text,
        'dob': _controllers['Date of Birth']?.text,
        'birthPlace': _controllers['Place of Birth']?.text,
        'presentAddress': _controllers['Present Address']?.text,
        'presentPincode': _controllers['Present Pincode']?.text,
        'presentCountry': _controllers['Present Country']?.text,
        'permanentAddress': _controllers['Permanent Address']?.text,
        'maritalStatus': _controllers['Marital Status']?.text,
        'profession': _controllers['Profession']?.text,
        'relation': _controllers['Relation']?.text,
        'photo': _photo,
        'interests': jsonEncode(_selectedInterests),
        'phoneNumbers': jsonEncode(_phoneNumbers),
        'emailAddresses': jsonEncode(_emailAddresses),
        'educationDetails': jsonEncode(_educationDetails),
      });

      _showSnackBar('Person added successfully!');

      if (widget.onPersonAdded != null) {
        widget.onPersonAdded!();
      }
      _clearForm();
    }
  }

  Future<void> _fetchCountries() async {
    if (mounted) {
      final String responseCountries =
          await rootBundle.loadString('assets/data/countries.json');
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        final List<dynamic> data = jsonDecode(responseCountries);
        _countries = data.map((country) => country.toString()).toList();
      });
    }
  }

  Future<void> _fetchProfessions() async {
    if (mounted) {
      final String responseProfessions =
          await rootBundle.loadString('assets/data/professions.json');
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        final List<dynamic> data = jsonDecode(responseProfessions);
        _professions = data.map((profession) => profession.toString()).toList();
      });
    }
  }

  Future<void> _fetchInterests() async {
    if (mounted) {
      final String responseInterests =
          await rootBundle.loadString('assets/data/person_interests.json');
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        final List<dynamic> data = jsonDecode(responseInterests);
        _interests = data.map((interests) => interests.toString()).toList();
      });
    }
  }

  Future<void> _fetchRelations() async {
    if (mounted) {
      final String responseRelations =
          await rootBundle.loadString('assets/data/person_relations.json');
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        final List<dynamic> data = jsonDecode(responseRelations);
        _relations = data.map((relations) => relations.toString()).toList();
      });
    }
  }

  void _addEducationField() {
    setState(() {
      _educationDetails.add({});
    });
  }

  Widget _buildEducationFields() {
    return Column(
      children: _educationDetails.map((education) {
        int index = _educationDetails.indexOf(education);
        return Column(
          children: [
            DropdownButtonFormField<String>(
              value: education['type'],
              onChanged: (newValue) {
                setState(() {
                  _educationDetails[index]['type'] = newValue!;
                  // Clear the value when the type changes
                  _educationDetails[index]['value'] = '';
                });
              },
              items: [
                'Primary School Name',
                'Secondary School Name',
                'College Name',
                'University Name',
                'Institute Name',
                'Course',
                'Degree',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Education Type'),
            ),
            if (education['type'] == 'Degree')
              SearchField(
                controller: TextEditingController(text: education['value']),
                searchInputDecoration: const InputDecoration(
                  labelText: 'Degree',
                ),
                maxSuggestionsInViewPort: 5,
                autoCorrect: true,
                suggestions: _degrees
                    .map((e) => SearchFieldListItem(e, child: Text(e)))
                    .toList(),
                onSuggestionTap: (suggestion) {
                  setState(() {
                    _educationDetails[index]['value'] = suggestion.searchKey;
                  });
                },
              )
            else
              TextFormField(
                initialValue: education['value'],
                onChanged: (newValue) {
                  setState(() {
                    _educationDetails[index]['value'] = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: education['type'],
                ),
              ),
            const SizedBox(height: 10),
          ],
        );
      }).toList(),
    );
  }

  void _addPhoneNumber(List<String> phoneNumbers, String type) {
    setState(() {
      phoneNumbers.add('');
    });
  }

  void _addEmail(List<String> emailAddresses) {
    setState(() {
      emailAddresses.add('');
    });
  }

   void _addLink(List<String> links) {
    setState(() {
      links.add('');
    });
  }

  Widget _buildSearchFields(String fieldName, List<String> suggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchField(
          controller: _controllers[fieldName]!,
          searchInputDecoration: InputDecoration(
            labelText: fieldName,
          ),
          maxSuggestionsInViewPort: 5,
          autoCorrect: true,
          suggestions: suggestions
              .map((e) => SearchFieldListItem(e, child: Text(e)))
              .toList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTextFields(String fieldName, [TextInputType keyboardType = TextInputType.text]) {
    return Column(
      children: [
        TextFormField(
          controller: _controllers[fieldName],
          keyboardType: keyboardType,
          decoration: InputDecoration(labelText: fieldName),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPhoneNumberFields(String label, List<String> phoneNumbers) {
    return Column(
      children: [
        for (int i = 0; i < phoneNumbers.length; i++)
          TextFormField(
            initialValue: phoneNumbers[i],
            keyboardType: TextInputType.phone,
            onChanged: (newValue) {
              setState(() {
                phoneNumbers[i] = newValue;
              });
            },
            decoration: InputDecoration(
              labelText: '$label ${i + 1}',
            ),
          ),
        ElevatedButton(
          onPressed: () => _addPhoneNumber(phoneNumbers, label),
          child: Text('Add $label'),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildEmailFields(String label, List<String> emailAddresses) {
    return Column(
      children: [
        for (int i = 0; i < emailAddresses.length; i++)
          TextFormField(
            initialValue: emailAddresses[i],
            keyboardType: TextInputType.emailAddress,
            onChanged: (newValue) {
              setState(() {
                emailAddresses[i] = newValue;
              });
            },
            decoration: InputDecoration(
              labelText: '$label ${i + 1}',
            ),
          ),
        ElevatedButton(
          onPressed: () => _addEmail(emailAddresses),
          child: Text('Add $label'),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildLinkFields(String label, List<String> userLinks) {
    return Column(
      children: [
        for (int i = 0; i < userLinks.length; i++)
          TextFormField(
            initialValue: userLinks[i],
            keyboardType: TextInputType.url,
            onChanged: (newValue) {
              setState(() {
                userLinks[i] = newValue;
              });
            },
            decoration: InputDecoration(
              labelText: '$label ${i + 1}',
            ),
          ),
        ElevatedButton(
          onPressed: () => _addLink(userLinks),
          child: Text('Add $label'),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildInterests() {
    return Wrap(
      spacing: 8.0,
      children: _interests.map((interest) {
        return FilterChip(
          label: Text(interest),
          selected: _selectedInterests.contains(interest),
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _selectedInterests.add(interest);
              } else {
                _selectedInterests.remove(interest);
              }
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  radius: 90,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _photo != null ? MemoryImage(_photo!) : null,
                  child: _photo == null
                      ? const Icon(Icons.person, size: 90)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _controllers['Name'],
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              _buildSearchFields('Relation', _relations),
              _buildSearchFields('Gender', _gender),
              TextFormField(
                controller: _controllers['Date of Birth']!,
                // keyboardType: TextInputType.datetime,
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
              _buildTextFields('Place of Birth', TextInputType.text),
              _buildTextFields('Present Address', TextInputType.text),
              _buildTextFields('Present Pincode', TextInputType.number),
              _buildSearchFields('Present Country', _countries),
              _buildTextFields('Permanent Address', TextInputType.number),
              _buildSearchFields('Marital Status', _maritalStatuses),
              _buildSearchFields('Profession', _professions),
              _buildPhoneNumberFields('Phone Number', _phoneNumbers),
              _buildEmailFields('Email Address', _emailAddresses),
              _buildLinkFields('Link', _links),
              _buildEducationFields(),
              ElevatedButton(
                onPressed: _addEducationField,
                child: const Text('Add Education'),
              ),
              const SizedBox(height: 10),
              const Text('Interests', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              _buildInterests(),
              const SizedBox(height: 75),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        verticalDirection: VerticalDirection.down,
        children: [
          FloatingActionButton(
            onPressed: () {
              _saveForm();
            },
            tooltip: 'Save',
            child: const Icon(Icons.save_rounded),
          )
        ],
      ),
    );
  }
}
