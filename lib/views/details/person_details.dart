import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:galaxy/model/person_model.dart';
import 'package:galaxy/provider/assets_data_provider.dart';
import 'package:galaxy/provider/people_provider.dart';
import 'package:galaxy/utils/age_calculator.dart';
import 'package:galaxy/utils/image_utils.dart';
import 'package:galaxy/utils/json_utils.dart';
import 'package:galaxy/utils/share_utils.dart';
import 'package:galaxy/widget/educationfield.dart';
import 'package:galaxy/widget/searchfield.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
  bool _isInitialized = false;
  Uint8List? _photo;
  DateTime? _dob;
  List<Map<String, String>> _educationDetails = [
    {'degree': '', 'institution': '', 'year': ''}
  ];
  final List<TextEditingController> _degreeControllers = [];
  final List<TextEditingController> _institutionControllers = [];
  final List<TextEditingController> _yearControllers = [];

  @override
  void initState() {
    super.initState();
    _personDetailsFuture = _fetchPersonDetails();
    Provider.of<DataProvider>(context, listen: false).fetchData();
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    for (var controller in _degreeControllers) {
      controller.dispose();
    }
    for (var controller in _institutionControllers) {
      controller.dispose();
    }
    for (var controller in _yearControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<PersonModel?> _fetchPersonDetails() async {
    return await Provider.of<PeopleProvider>(context, listen: false)
        .getPersonById(widget.personId);
  }

  void _initializePersonDetails(PersonModel person) {
    _initializeControllers(person);
    if (_isInitialized == false) {
      if (person.photo != null && person.photo!.isNotEmpty) {
        _photo = person.photo!;
      }
      if (person.dob != null && person.dob!.isNotEmpty) {
        _dob = DateFormat('yyyy-MM-dd').parse(person.dob!);
        _controllers['Age']?.text = AgeCalculator.calculateAge(_dob!).toString();
      }

      _educationDetails = person.educationDetails
              ?.map((e) => {
                    'degree': e['degree'] ?? '',
                    'institution': e['institution'] ?? '',
                    'year': e['year'] ?? '',
                  })
              .toList() ??
          [];

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
    _addController('Interests', person.interests?.join(', ') ?? '');

    // Initialize controllers for dynamic fields based on lis ts
    _initializeListControllers('Phone Number', person.phoneNumbers);
    _initializeListControllers('Email Address', person.emailAddresses);
    _initializeListControllers('Link', person.links);
    _initializeEducationControllers(person.educationDetails);
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
      for (var detail in educationDetails) {
        _addEducationController(
            detail['degree'], detail['institution'], detail['year']);
      }
    }
  }

  void _addEducationController(String degree, String institution, String year) {
    _degreeControllers.add(TextEditingController(text: degree));
    _institutionControllers.add(TextEditingController(text: institution));
    _yearControllers.add(TextEditingController(text: year));
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

    // Collecting updated education details
    List<Map<String, String>> updatedEducationDetails = _educationDetails
        .where((edu) =>
            edu['degree']!.isNotEmpty ||
            edu['institution']!.isNotEmpty ||
            edu['year']!.isNotEmpty)
        .toList();

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
      'phoneNumbers': JsonUtils.toJsonList(updatedPhoneNumbers),
      'emailAddresses': JsonUtils.toJsonList(updatedEmailAddresses),
      'links': JsonUtils.toJsonList(updatedLinks),
      'educationDetails': JsonUtils.toJsonList(updatedEducationDetails),
      'interests': JsonUtils.toJsonList(_controllers['Interests']!.text.split(",")),
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

  void _toggleFieldSelection(String fieldName) {
    setState(() {
      _selectedFields.containsKey(fieldName)
          ? _selectedFields.remove(fieldName)
          : _selectedFields[fieldName] = _controllers[fieldName]?.text ?? '';
    });
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
        _controllers['Age']!.text = AgeCalculator.calculateAge(picked).toString();
      });
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
    String details = ShareUtils.generateShareableDetails(_selectedFields);
    Share.share(details);
  }

  String generateShareableDetails(Map<String, String> fields) {
    return fields.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
  }

  Widget _buildGestureDetector(
      String fieldName, List<String>? suggestions, String type, int? index, [TextInputType keyboardType = TextInputType.text]) {
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
            _buildFieldByType(type, fieldName, suggestions, index, keyboardType),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldByType(
      String type, String fieldName, List<String>? suggestions, int? index, [TextInputType keyboardType = TextInputType.text]) {
    switch (type) {
      case 'searchfield':
        return SearchableField(
          fieldName: fieldName,
          suggestions: suggestions!,
          controller: _controllers.putIfAbsent(
          fieldName, () => TextEditingController()),
        );
      case 'datefield':
        return TextFormField(
              controller: _controllers[fieldName],
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Enter $fieldName',
              ),
              onTap: () => _selectDate(context),
            );
      case 'educationfield':
        return EducationField(
            index: index!,
            degreeControllers: _degreeControllers,
            institutionControllers: _institutionControllers,
            yearControllers: _yearControllers,
            educationDetails: _educationDetails,
          );
      case 'editablefield':
        return TextFormField(
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
         );          
      default:
        return const SizedBox.shrink();
    }
  }

void _addDynamicField(String label, List<String> items) {
  setState(() {
    _addController('$label ${items.length + 1}', '');
    items.add('');
  });
}

Widget _buildDynamicFields(String label, List<String> items, TextInputType keyboardType) {
  return Column(
    children: [
      if (items.isNotEmpty)
        _buildDynamicListFields(label, items, keyboardType),
      ElevatedButton(
        onPressed: () => _addDynamicField(label, items),
        child: Text('Add $label'),
      ),
      const SizedBox(height: 10),
    ],
  );
}

Widget _buildDynamicListFields(String labelPrefix, List<String>? items, TextInputType keyboardType) {
  return Column(
    children: List.generate(items!.length, (i) {
      return Row(
        children: [
          Expanded(
            child: _buildGestureDetector(
              '$labelPrefix ${i + 1}',
              null,
              'editablefield',
              null,
              keyboardType,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: () {
              setState(() {
                items.removeAt(i);
                _controllers.remove('$labelPrefix ${i + 1}');
              });
            },
          ),
        ],
      );
    }),
  );
}

  Widget _buildEducationFields() {
    return Column(
      children: [
        for (int i = 0; i < _educationDetails.length; i++)
        _buildGestureDetector('Education Details ${i + 1}', null, 'educationfield', i),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _educationDetails.add({'degree': '', 'institution': '', 'year': ''});
              _addEducationController('', '', '');
            });
          },
          child: const Text('Add Education'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

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
                            backgroundImage: _photo != null ? MemoryImage(_photo!) : null,
                            child: _photo == null ? const Icon(Icons.person, size: 90) : null,
                          ),
                        ),
                      ),
                    ),
                    _buildGestureDetector('Name', null, 'editablefield', null),
                    _buildGestureDetector('Relation', dataProvider.relations, 'searchfield', null),
                    _buildGestureDetector('Gender', dataProvider.genders, 'searchfield',null),
                    _buildGestureDetector('Date of Birth', null, 'datefield', null),
                    _buildGestureDetector('Age', null, 'editablefield', null),
                    _buildGestureDetector('Place of Birth', null, 'editablefield', null),
                    _buildGestureDetector('Present Address', null, 'editablefield', null),
                    _buildGestureDetector('Present Country', dataProvider.countries, 'searchfield', null),
                    _buildGestureDetector('Present Pincode', null, 'editablefield', null, TextInputType.number),
                    _buildGestureDetector('Permanent Address', null, 'editablefield', null),
                    _buildGestureDetector('Marital Status', dataProvider.maritalStatuses, 'searchfield', null),
                    _buildGestureDetector('Profession', dataProvider.professions, 'searchfield', null),
                    _buildDynamicFields('Phone Number', person.phoneNumbers!, TextInputType.phone),
                    _buildDynamicFields('Email Address', person.emailAddresses!, TextInputType.emailAddress),
                    _buildDynamicFields('Link', person.links!, TextInputType.url), 
                    _buildEducationFields(),
                    _buildGestureDetector('Interests', null, 'editablefield', null),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}