import 'package:flutter/material.dart';
import 'package:galaxy/helpers/people_database_helper.dart';
import 'package:galaxy/model/person_model.dart';

class PeopleProvider with ChangeNotifier {
  List<PersonModel> _personList = [];
  List<PersonModel> get personList => _personList;

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  PeopleProvider() {
    _fetchPeople();
  }

  Future<void> _fetchPeople() async {
    try {
      _personList = await _databaseHelper.getRelevantPersonDetails();
      notifyListeners();
    } catch (error) {
      debugPrint('Error fetching people: $error');
    }
  }

  Future<void> loadPeople() async {
    _personList = await _databaseHelper.getAllPersons();
    notifyListeners();
  }

  Future<bool> addPerson(Map<String, dynamic> newPersonData) async {
    try {
      await _databaseHelper.insertPerson(newPersonData);
      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<void> refreshPeople() async {
    await _fetchPeople();
  }

  Future<PersonModel?> getPersonById(int personId) async {
    return await _databaseHelper.getPersonById(personId);
  }

  Future<bool> updatePerson(int personId, Map<String, dynamic> updatedData) async {
    try {
      await _databaseHelper.updatePerson(personId, updatedData);
      return true;
    } catch (error) {
      return false;
    }
  }


  Future<bool> deletePerson(int personId) async {
    try {
      await _databaseHelper.deletePerson(personId);
      return true;
    } catch (error) {
      return false;
    }
  }

  void filterList(String query) {
    if (query.isEmpty) {
      _fetchPeople();
      notifyListeners();
      return;
    }

    final lowerCaseQuery = query.toLowerCase();
    _personList = _personList.where((person) {
      return (person.name?.toLowerCase().contains(lowerCaseQuery) ?? false) ||
          (person.relation?.toLowerCase().contains(lowerCaseQuery) ?? false) ||
          (person.profession?.toLowerCase().contains(lowerCaseQuery) ?? false);
    }).toList();

    notifyListeners();
  }
}
