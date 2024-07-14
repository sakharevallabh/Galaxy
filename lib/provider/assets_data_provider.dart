import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DataProvider with ChangeNotifier {
  List<String> _countries = [];
  List<String> _professions = [];
  List<String> _relations = [];
  List<String> _interests = [];
  List<String> _maritalStatuses = [];
  List<String> _qualifications = [];
  List<String> _genders = [];

  List<String> get countries => _countries;
  List<String> get professions => _professions;
  List<String> get relations => _relations;
  List<String> get interests => _interests;
  List<String> get maritalStatuses => _maritalStatuses;
  List<String> get qualifications => _qualifications;
  List<String> get genders => _genders;

  Future<void> fetchData() async {
    await Future.wait([
      _fetchData('assets/data/countries.json', _setCountries),
      _fetchData('assets/data/professions.json', _setProfessions),
      _fetchData('assets/data/person_relations.json', _setRelations),
      _fetchData('assets/data/person_interests.json', _setInterests),
      _fetchData('assets/data/marital_statuses.json', _setMaritalStatuses),
      _fetchData('assets/data/qualifications.json', _setQualifications),
      _fetchData('assets/data/genders.json', _setGenders),
    ]);
  }

  Future<void> _fetchData(String path, Function(List<String>) setter) async {
    final String response = await rootBundle.loadString(path);
    final List<dynamic> data = jsonDecode(response);
    setter(data.map((item) => item.toString()).toList());
  }

  void _setCountries(List<String> countries) {
    _countries = countries;
    notifyListeners();
  }

  void _setProfessions(List<String> professions) {
    _professions = professions;
    notifyListeners();
  }

  void _setRelations(List<String> relations) {
    _relations = relations;
    notifyListeners();
  }

  void _setInterests(List<String> interests) {
    _interests = interests;
    notifyListeners();
  }

  void _setMaritalStatuses(List<String> maritalStatuses) {
    _maritalStatuses = maritalStatuses;
    notifyListeners();
  }

  void _setQualifications(List<String> qualifications) {
    _qualifications = qualifications;
    notifyListeners();
  }

  void _setGenders(List<String> genders) {
    _genders = genders;
    notifyListeners();
  }
}
