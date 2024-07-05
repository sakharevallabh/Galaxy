import 'package:flutter/material.dart';
import 'package:galaxy/helpers/people_database_helper.dart';
import 'package:galaxy/model/person_model.dart';

class PersonProvider with ChangeNotifier {
  List<PersonModel> _personList = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<PersonModel> get personList => _personList;

  PersonProvider() {
    _fetchPeople();
  }

  Future<void> _fetchPeople() async {
    _personList = await _databaseHelper.getRelevantPersonDetails();
    notifyListeners();
  }

  Future<void> deletePerson(int personId) async {
    await _databaseHelper.deletePerson(personId);
    await _fetchPeople();
  }
}
