import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:galaxy/helpers/people_database_helper.dart';
import 'package:galaxy/provider/people_provider.dart';
import 'package:galaxy/widget/searchfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

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
  Uint8List? _photo;
  final Map<String, TextEditingController> _controllers = {
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
  final List<Map<String, String>> _educationDetails = [
    {'degree': '', 'institution': '', 'year': ''}
  ];

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
    // Clear form fields and dispose controllers
    _clearForm(dispose: true);

    // Dispose controllers
    _controllers.forEach((key, controller) {
      controller.dispose();
    });

    // Clear lists
    _countries = [];
    _professions = [];
    _interests = [];
    _relations = [];

    super.dispose();
  }

  void _clearForm({bool dispose = false}) {
    if (!dispose) {
      _formKey.currentState!.reset();
    }

    _controllers.forEach((key, controller) {
      controller.clear();
    });

    if (!dispose) {
      setState(() {
        if (_photo != null && _photo!.isNotEmpty) {
          _photo = null;
        }
      });
    } else {
      // Directly set _photo to null without setState in dispose case
      _photo = null;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      pickedFile.readAsBytes().then((value) {
        setState(() {
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

      if (mounted) {
        Provider.of<PeopleProvider>(context, listen: false).refreshPeople();
      }
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
    Icon suffixIcon;
    if (key == "Name") {
      suffixIcon = const Icon(Icons.person);
    } else {
      suffixIcon = const Icon(null);
    }

    if (key == "Present Pincode") {
      inputType = TextInputType.number;
    }

    return Column(
      children: [
        TextFormField(
          key: Key(key),
          controller: _controllers[key],
          decoration: InputDecoration(
            suffixIcon: suffixIcon,
            labelText: key,
            hintText: key,
          ),
          keyboardType: inputType,
          validator: (value) =>
              key == "Name" && (value == null || value.isEmpty)
                  ? 'Please enter $key'
                  : null,
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildPhoneNumberFields() {
    return Column(
      children: [
        for (int i = 0; i < _phoneNumbers.length; i++)
          TextFormField(
            initialValue: _phoneNumbers[i],
            decoration: InputDecoration(
              labelText: 'Phone Number',
              suffixIcon: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _phoneNumbers.removeAt(i);
                  });
                },
              ),
            ),
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              _phoneNumbers[i] = value;
            },
          ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _phoneNumbers.add('');
            });
          },
          child: const Text('Add Phone Number'),
        ),
      ],
    );
  }

  Widget _buildEmailFields() {
    return Column(
      children: [
        for (int i = 0; i < _emailAddresses.length; i++)
          TextFormField(
            initialValue: _emailAddresses[i],
            decoration: InputDecoration(
              labelText: 'Email Address',
              suffixIcon: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _emailAddresses.removeAt(i);
                  });
                },
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              _emailAddresses[i] = value;
            },
          ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _emailAddresses.add('');
            });
          },
          child: const Text('Add Email Address'),
        ),
      ],
    );
  }

  Widget _buildLinkFields() {
    return Column(
      children: [
        for (int i = 0; i < _links.length; i++)
          TextFormField(
            initialValue: _links[i],
            decoration: InputDecoration(
              labelText: 'Link',
              suffixIcon: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _links.removeAt(i);
                  });
                },
              ),
            ),
            keyboardType: TextInputType.url,
            onChanged: (value) {
              _links[i] = value;
            },
          ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _links.add('');
            });
          },
          child: const Text('Add Link'),
        ),
      ],
    );
  }

  Widget _buildInterests() {
    return Wrap(
      spacing: 8,
      children: _interests.map((interest) {
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

  Widget _buildEducationFields() {
    return Column(
      children: [
        for (int i = 1; i <= _educationDetails.length; i++)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _educationDetails[i - 1]['degree']!.isNotEmpty &&
                        _degrees.contains(_educationDetails[i - 1]['degree'])
                    ? _educationDetails[i - 1]['degree']
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Degree',
                ),
                items: _degrees.toSet().map((degree) {
                  return DropdownMenuItem(
                    value: degree,
                    child: Text(degree),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _educationDetails[i - 1]['degree'] = value ?? '';
                  });
                },
              ),
              TextFormField(
                initialValue: _educationDetails[i - 1]['institution'],
                decoration: InputDecoration(
                  labelText: 'Institution',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _educationDetails.removeAt(i - 1);
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  _educationDetails[i - 1]['institution'] = value;
                },
              ),
              TextFormField(
                initialValue: _educationDetails[i - 1]['year'],
                decoration: const InputDecoration(
                  labelText: 'Year',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _educationDetails[i - 1]['year'] = value;
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _educationDetails.add({
                'degree': '',
                'institution': '',
                'year': '',
              });
            });
          },
          child: const Text('Add Education'),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(),
        child: Form(
          key: _formKey,
          child: ListView(padding: const EdgeInsets.all(16.0), children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 90,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: _photo != null ? MemoryImage(_photo!) : null,
                child: _photo == null
                    ? const Icon(Icons.add_a_photo,
                        size: 50, color: Colors.white)
                    : null,
              ),
            ),
            _buildTextFields(key: 'Name'),
            _buildSearchFields(key: 'Relation', suggestions: _relations),
            _buildSearchFields(key: 'Gender', suggestions: _gender),
            TextFormField(
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
            ),
            const SizedBox(height: 16.0),
            _buildTextFields(key: 'Place of Birth'),
            _buildTextFields(key: 'Present Address'),
            _buildTextFields(key: 'Present Pincode'),
            _buildSearchFields(key: 'Present Country', suggestions: _countries),
            _buildSearchFields(
                key: 'Marital Status', suggestions: _maritalStatuses),
            _buildSearchFields(key: 'Profession', suggestions: _professions),
            _buildTextFields(key: 'Work Address'),
            _buildPhoneNumberFields(),
            _buildEmailFields(),
            _buildLinkFields(),
            _buildEducationFields(),
            const Text('Interests',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            _buildInterests(),
            const SizedBox(height: 100.0),
          ]),
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
