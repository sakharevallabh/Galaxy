import 'package:flutter/material.dart';
import 'package:galaxy/helpers/people_database_helper.dart';
import 'package:galaxy/model/person_model.dart';

class PersonDetailsPage extends StatefulWidget {
  final PersonModel person;
  final String heroTag;

  const PersonDetailsPage(
      {super.key, required this.person, required this.heroTag});

  @override
  PersonDetailsPageState createState() => PersonDetailsPageState();
}

class PersonDetailsPageState extends State<PersonDetailsPage> {
  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _genderController;
  late TextEditingController _dobController;
  late TextEditingController _birthPlaceController;
  late TextEditingController _countryController;
  late TextEditingController _pincodeController;
  late TextEditingController _nationalityController;
  late TextEditingController _mariatalStatusController;
  late TextEditingController _professionController;
  // Uint8List? _photo;
  // List<String>? _addresses;
  // List<String>? _phoneNumbers;
  // List<String>? _emailAddresses;
  // List<String>? _socialMediaProfiles;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _middleNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _genderController = TextEditingController();
    _dobController = TextEditingController();
    _birthPlaceController = TextEditingController();
    _countryController = TextEditingController();
    _pincodeController = TextEditingController();
    _nationalityController = TextEditingController();
    _mariatalStatusController = TextEditingController();
    _professionController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    _birthPlaceController.dispose();
    _countryController.dispose();
    _pincodeController.dispose();
    _nationalityController.dispose();
    _mariatalStatusController.dispose();
    _professionController.dispose();
    // _photo = null;
    // _addresses = null;
    // _emailAddresses = null;
    // _socialMediaProfiles = null;
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = true;
    });
  }

  void _saveChanges() async {
    // Save changes to database or perform necessary actions
    // For demo, let's update the PersonModel directly (not recommended in production)
    setState(() {
      // widget.person.firstName = _firstNameController.text;
      // widget.person.middleName = _middleNameController.text;
      // widget.person.lastName = _lastNameController.text;
      // widget.person.gender = _genderController.text;
      // widget.person.dob = _dobController.text;
      // widget.person.birthPlace = _birthPlaceController.text;
      // widget.person.country = _countryController.text;
      // widget.person.pincode = _pincodeController.text;
      // widget.person.nationality = _nationalityController.text;
      // widget.person.maritalStatus = _mariatalStatusController.text;
      // widget.person.photoPath = _photoPathController.text;
      // widget.person.profession = _professionController.text;
      // widget.person.photo = _photo;
      // widget.person.addresses = _addresses;
      // widget.person.phoneNumbers = _phoneNumbers;
      // widget.person.emailAddresses = _emailAddresses;
      // widget.person.socialMediaProfiles = _socialMediaProfiles;

      _isEditing = false;
    });

    final updatedPerson = PersonModel(
      id: widget.person.id,
      firstName: widget.person.firstName,
      middleName: widget.person.middleName,
      lastName: widget.person.lastName,
      gender: widget.person.gender,
      dob: widget.person.dob,
      birthPlace: widget.person.birthPlace,
      country: widget.person.country,
      pincode:  widget.person.pincode,
      nationality: widget.person.nationality,
      maritalStatus: widget.person.maritalStatus,
      profession: widget.person.profession
    );

    // Instantiate DatabaseHelper
    DatabaseHelper databaseHelper = DatabaseHelper();

    // Call your database update method here
    int rowsAffected = await databaseHelper.updatePerson(updatedPerson);

    if (mounted) {
      if (rowsAffected > 0) {
        // Show feedback to the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully')),
        );
      } else {
        // Handle error saving
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save changes')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEdit,
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChanges,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.person.photo != null)
              CircleAvatar(
                backgroundImage: MemoryImage(widget.person.photo!),
                radius: 50,
              ),
            const SizedBox(height: 20),
            Hero(
              tag: widget.heroTag,
              child: Material(
                color: Colors.transparent,
                child: Text(
                  'Name: ${widget.person.firstName}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (_isEditing)
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              )
            else
              Text('Last Name: ${widget.person.lastName}'),
            if (!_isEditing) const SizedBox(height: 8),
            if (_isEditing)
              TextFormField(
                controller: _genderController,
                decoration: const InputDecoration(labelText: 'Gender'),
              )
            else
              Text('Gender: ${widget.person.gender}'),
            Text('Date of Birth: ${widget.person.dob ?? 'Unknown'}'),
            Text('Birth Place: ${widget.person.birthPlace ?? 'Unknown'}'),
            Text('Country: ${widget.person.country ?? 'Unknown'}'),
            Text('Pincode: ${widget.person.pincode ?? 'Unknown'}'),
            Text('Nationality: ${widget.person.nationality ?? 'Unknown'}'),
            Text('Marital Status: ${widget.person.maritalStatus ?? 'Unknown'}'),
            Text('Profession: ${widget.person.profession ?? 'Unknown'}'),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
