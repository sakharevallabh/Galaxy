import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:galaxy/model/person_model.dart';
import 'package:galaxy/provider/people_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:searchfield/searchfield.dart';
import 'package:share/share.dart';

class PersonDetailsPage extends StatefulWidget {
  final int personId;
  final String heroTag;

  const PersonDetailsPage({
    super.key,
    required this.personId,
    required this.heroTag,
  });

  @override
  PersonDetailsPageState createState() => PersonDetailsPageState();
}

class PersonDetailsPageState extends State<PersonDetailsPage> {
  late Future<PersonModel?> _personDetailsFuture;
  final Map<String, String> _selectedFields = {};
  final Map<String, TextEditingController> _controllers = {};
  final List<String> _genders = ['Male', 'Female'];
  final List<String> _maritalStatuses = ['Married', 'Unmarried', 'Divorced'];
  bool _isInitialized = false;
  Uint8List? _photo;
  DateTime? _dob;
  List<String> _countries = [];
  List<String> _professions = [];
  List<String> _interests = [];
  List<String> _relations = [];

  @override
  void initState() {
    super.initState();
    _personDetailsFuture = _fetchPersonDetails();
    _fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<PersonModel?> _fetchPersonDetails() async {
    return await Provider.of<PeopleProvider>(context, listen: false)
        .getPersonById(widget.personId);
  }

  Future<void> _fetchData() async {
    await _fetchCountries();
    await _fetchProfessions();
    await _fetchInterests();
    await _fetchRelations();
  }

  void _initializePersonDetails(PersonModel person) {
    _initializeControllers(person);
    if (_isInitialized == false) {
      if (person.photo != null && person.photo!.isNotEmpty) {
        _photo = person.photo!;
      }
      if (person.dob != null && person.dob!.isNotEmpty) {
        _dob = DateFormat('yyyy-MM-dd').parse(person.dob!);
        _controllers['Age']?.text = _calculateAge(_dob!).toString();
      }
      _isInitialized = true;
    }
  }

  void _initializeControllers(PersonModel person) {
    _addController('Name', person.name);
    _addController('Relation', person.relation ?? '');
    _addController('Gender', person.gender ?? '');
    _addController('Date of Birth', person.dob ?? '');
    _addController('Age');
    _addController('Place of Birth', person.birthPlace ?? '');
    _addController('Present Address', person.presentAddress ?? '');
    _addController('Present Country', person.presentCountry ?? '');
    _addController('Present Pincode', person.presentPincode ?? '');
    _addController('Permanent Address', person.permanentAddress ?? '');
    _addController('Marital Status', person.maritalStatus ?? '');
    _addController('Profession', person.profession ?? '');

    // Initialize controllers for dynamic fields based on lists
    _initializeListControllers('Phone Number', person.phoneNumbers);
    _initializeListControllers('Email Address', person.emailAddresses);
    _initializeListControllers('Link', person.links);
    _initializeEducationControllers(person.educationDetails);

    // Initialize Interests controller
    _controllers['Interests'] =
        TextEditingController(text: person.interests?.join(', ') ?? '');
  }

  void _addController(String key, [String? value]) {
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(text: value);
    }
  }

  void _initializeListControllers(String labelPrefix, List<String>? items) {
    if (items != null) {
      for (int i = 0; i < items.length; i++) {
        _addController('$labelPrefix ${i + 1}', items[i]);
      }
    }
  }

  void _initializeEducationControllers(
      List<Map<String, dynamic>>? educationDetails) {
    if (educationDetails != null) {
      for (int i = 0; i < educationDetails.length; i++) {
        var educationDetail = educationDetails[i];
        _addController(educationDetail['type'], educationDetail['value']);
      }
    }
  }

  Future<void> _updatePerson() async {
    // Collect updated phone numbers from the controllers
    List<String> updatedPhoneNumbers = [];
    _controllers.forEach((key, value) {
      if (key.startsWith('Phone')) {
        _addController(key, value.text);
        updatedPhoneNumbers.add(value.text);
      }
    });

    // Similarly, collect updated email addresses
    List<String> updatedEmailAddresses = [];
    _controllers.forEach((key, value) {
      if (key.startsWith('Email')) {
        _addController(key, value.text);
        updatedEmailAddresses.add(value.text);
      }
    });

    // Similarly, collect updated links
    List<String> updatedLinks = [];
    _controllers.forEach((key, value) {
      if (key.startsWith('Link')) {
        _addController(key, value.text);
        updatedLinks.add(value.text);
      }
    });

    // Similarly, collect updated education details
    List<Map<String, String>> updatedEducationDetails = [];
    _controllers.forEach((key, controller) {
      if (key.startsWith('Education')) {
        updatedEducationDetails.add({
          'type': key.replaceFirst('Education ', ''),
          'value': controller.text,
        });
      }
    });

    final Map<String, dynamic> updatedData = {
      'name': _controllers['Name']!.text,
      'relation': _controllers['Relation']!.text,
      'gender': _controllers['Gender']!.text,
      'dob': _controllers['Date of Birth']!.text,
      'birthPlace': _controllers['Place of Birth']!.text,
      'presentAddress': _controllers['Present Address']!.text,
      'presentCountry': _controllers['Present Country']!.text,
      'presentPincode': _controllers['Present Pincode']!.text,
      'permanentAddress': _controllers['Permanent Address']!.text,
      'maritalStatus': _controllers['Marital Status']!.text,
      'profession': _controllers['Profession']!.text,
      'phoneNumbers': _toJsonList(updatedPhoneNumbers),
      'emailAddresses': _toJsonList(updatedEmailAddresses),
      'links': _toJsonList(updatedLinks),
      'educationDetails': _toJsonList(updatedEducationDetails),
      // 'interests': _toJsonList(_person!.interests),
      'photo': _photo,
    };

    bool success = await Provider.of<PeopleProvider>(context, listen: false)
        .updatePerson(widget.personId, updatedData);

    if (!mounted) return;

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Details updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating person details!')),
        );
      }
    }
  }

  String? _toJsonList(List<dynamic>? items) {
    if (items != null) {
      var jsonEncoder = const JsonEncoder();
      return jsonEncoder.convert(items);
    }
    return null;
  }

  void _toggleFieldSelection(String fieldName) {
    setState(() {
      _selectedFields.containsKey(fieldName)
          ? _selectedFields.remove(fieldName)
          : _selectedFields[fieldName] = _controllers[fieldName]?.text ?? '';
    });
  }

  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dob) {
      setState(() {
        _dob = picked;
        _controllers['Date of Birth']!.text =
            DateFormat('yyyy-MM-dd').format(picked);
        _controllers['Age']!.text = _calculateAge(picked).toString();
      });
    }
  }

  void _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _photo = bytes;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $error')),
        );
      }
    }
  }

  Future<bool> _deleteSelectedFields(int personId) async {
    try {
      for (String fieldName in _selectedFields.keys) {
        if (fieldName != "Name") {
          _controllers[fieldName]!.text = '';
        }
      }
      _updatePerson();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _deletePerson(int personId) async {
    try {
      bool success = await Provider.of<PeopleProvider>(context, listen: false)
          .deletePerson(widget.personId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Person deleted successfully!'
                  : 'Error deleting person!',
            ),
          ),
        );
      }
      await Future.delayed(const Duration(seconds: 1));
      return success;
    } catch (error) {
      return false;
    }
  }

  void _shareSelectedFields() {
    String details = generateShareableDetails(_selectedFields);
    Share.share(details);
  }

  String generateShareableDetails(Map<String, String> fields) {
    return fields.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PersonModel?>(
      future: _personDetailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('No data found')),
          );
        } else {
          PersonModel person = snapshot.data!;
          _initializePersonDetails(person); // Initialize data once fetched
          return Scaffold(
            appBar: AppBar(
              title: Text(person.name ?? 'Person Details'),
              actions: [
                IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final personId = person.id;
                      bool success;
                      success = await showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Confirm Delete'),
                          content:
                              const Text('Are you sure you want to delete?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                            ),
                            TextButton(
                              child: const Text('Delete'),
                              onPressed: () async {
                                bool result = true;
                                if (_selectedFields.isNotEmpty) {
                                  result =
                                      await _deleteSelectedFields(personId!);
                                } else {
                                  result = await _deletePerson(personId!);
                                }
                                Navigator.of(context).pop(result);
                              },
                            ),
                          ],
                        ),
                      );
                      if (success) {
                        Navigator.of(context).pop();
                      } else {
                        // Handle deletion failure
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Did not delete person.'),
                          ),
                        );
                      }
                    }),
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
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Hero(
                      tag: widget.heroTag,
                      child: Material(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 90,
                            backgroundColor: Colors.grey[300],
                            backgroundImage:
                                _photo != null ? MemoryImage(_photo!) : null,
                            child: _photo == null
                                ? const Icon(Icons.person, size: 90)
                                : null,
                          ),
                        ),
                      ),
                    ),
                    _buildEditableField('Name'),
                    _buildSearchableField('Relation', _relations),
                    _buildSearchableField('Gender', _genders),
                    _buildDatePickerField('Date of Birth'),
                    _buildEditableField('Age'),
                    _buildEditableField('Place of Birth'),
                    _buildEditableField('Present Address'),
                    _buildSearchableField('Present Country', _countries),
                    _buildEditableField(
                        'Present Pincode', TextInputType.number),
                    _buildEditableField('Permanent Address'),
                    _buildSearchableField('Marital Status', _maritalStatuses),
                    _buildSearchableField('Profession', _professions),
                    _buildNewFields('Phone Number', person.phoneNumbers!,
                        TextInputType.phone),
                    _buildNewFields('Email Address', person.emailAddresses!,
                        TextInputType.emailAddress),
                    _buildNewFields('Link', person.links!, TextInputType.url),
                    _buildDynamicEducationFields(person.educationDetails),
                    _buildMultiSelectField('Interests', person.interests!),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildEditableField(String fieldName,
      [TextInputType keyboardType = TextInputType.text]) {
    return GestureDetector(
      onTap: () => _toggleFieldSelection(fieldName),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedFields.containsKey(fieldName)
                ? Colors.blue
                : Colors.grey,
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
              controller: _controllers[fieldName],
              readOnly: fieldName == 'Age',
              decoration: InputDecoration(
                hintText: 'Enter $fieldName',
              ),
              keyboardType: keyboardType,
              onChanged: (value) {
                setState(() {
                  _controllers[fieldName]?.text = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerField(String fieldName) {
    return GestureDetector(
      onTap: () => _toggleFieldSelection(fieldName),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedFields.containsKey(fieldName)
                ? Colors.blue
                : Colors.grey,
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
              controller: _controllers[fieldName],
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Enter $fieldName',
              ),
              onTap: () => _selectDate(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchableField(String fieldName, List<String> suggestions) {
    return GestureDetector(
      onTap: () => _toggleFieldSelection(fieldName),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedFields.containsKey(fieldName)
                ? Colors.blue
                : Colors.grey,
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
            SearchField(
              controller: _controllers.putIfAbsent(
                  fieldName, () => TextEditingController()),
              suggestions: suggestions
                  .where((suggestion) => suggestion
                      .toLowerCase()
                      .contains(_controllers[fieldName]!.text.toLowerCase()))
                  .map((e) => SearchFieldListItem(e))
                  .toList(),
              searchInputDecoration: InputDecoration(
                hintText: 'Enter $fieldName',
              ),
              maxSuggestionsInViewPort: 5,
              onSearchTextChanged: (value) {
                setState(() {
                  _controllers[fieldName]!.text = value;
                });
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectField(String label, List<String> selectedItems) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16.0),
          ),
          Wrap(
            children: selectedItems.map((item) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Chip(
                  label: Text(item),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      selectedItems.remove(item);
                      _controllers[label]!.text = selectedItems.join(', ');
                    });
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _controllers[label],
            decoration: InputDecoration(
              labelText: 'Add $label',
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  selectedItems.add(value);
                  _controllers[label]!.text = selectedItems.join(', ');
                });
              }
            },
          ),
        ],
      ),
    );
  }

  void _addPhoneNumber(List<String> phoneNumbers) {
    setState(() {
      _addController('Phone Number ${phoneNumbers.length + 1}', '');
      phoneNumbers.add('');
    });
  }

  void _addEmail(List<String> emailAddresses) {
    setState(() {
      _addController('Email Address ${emailAddresses.length + 1}', '');
      emailAddresses.add('');
    });
  }

  void _addLink(List<String> links) {
    setState(() {
      _addController('Link ${links.length + 1}', '');
      links.add('');
    });
  }

  Widget _buildNewFields(
      String label, List<String> items, TextInputType keyboardType) {
    return Column(
      children: [
        if (items.isNotEmpty)
          _buildDynamicListFields(label, items, keyboardType),
        ElevatedButton(
          onPressed: () {
            switch (label) {
              case 'Phone Number':
                _addPhoneNumber(items);
                break;
              case 'Email Address':
                _addEmail(items);
                break;
              case 'Link':
                _addLink(items);
                break;
              default:
                break;
            }
          },
          child: Text('Add $label'),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDynamicListFields(
      String labelPrefix, List<String>? items, TextInputType keyboardType) {
    List<Widget> fields = [];
    if (items != null) {
      for (int i = 0; i < items.length; i++) {
        fields.add(_buildEditableField('$labelPrefix ${i + 1}', keyboardType));
      }
    }
    return Column(children: fields);
  }

  Widget _buildDynamicEducationFields(
      List<Map<String, dynamic>>? educationDetails) {
    List<Widget> fields = [];

    if (educationDetails != null) {
      for (int i = 0; i < educationDetails.length; i++) {
        var educationDetail = educationDetails[i];
        fields.add(_buildEditableField(educationDetail['type']));
      }
    }
    return Column(children: fields);
  }

  Future<void> _fetchCountries() async {
    final String responseCountries =
        await rootBundle.loadString('assets/data/countries.json');
    final List<dynamic> data = jsonDecode(responseCountries);
    setState(() {
      _countries = data.map((countries) => countries.toString()).toList();
    });
  }

  Future<void> _fetchProfessions() async {
    final String responseProfessions =
        await rootBundle.loadString('assets/data/professions.json');
    final List<dynamic> data = jsonDecode(responseProfessions);
    setState(() {
      _professions = data.map((professions) => professions.toString()).toList();
    });
  }

  Future<void> _fetchInterests() async {
    final String responseInterests =
        await rootBundle.loadString('assets/data/person_interests.json');
    final List<dynamic> data = jsonDecode(responseInterests);
    setState(() {
      _interests = data.map((interests) => interests.toString()).toList();
    });
  }

  Future<void> _fetchRelations() async {
    final String responseRelations =
        await rootBundle.loadString('assets/data/person_relations.json');
    final List<dynamic> data = jsonDecode(responseRelations);
    setState(() {
      _relations = data.map((relations) => relations.toString()).toList();
    });
  }
}
