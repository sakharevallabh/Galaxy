import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DataProvider with ChangeNotifier {
  List<String> _countries = [];
  List<String> _professions = [];
  List<String> _relations = [];

  List<String> get countries => _countries;
  List<String> get professions => _professions;
  List<String> get relations => _relations;

  Future<void> fetchData() async {
    await _fetchCountries();
    await _fetchProfessions();
    await _fetchRelations();
  }

  Future<void> _fetchCountries() async {
    final String responseCountries =
        await rootBundle.loadString('assets/data/countries.json');
    final List<dynamic> data = jsonDecode(responseCountries);
    _countries = data.map((country) => country.toString()).toList();
    notifyListeners();
  }

  Future<void> _fetchProfessions() async {
    final String responseProfessions =
        await rootBundle.loadString('assets/data/professions.json');
    final List<dynamic> data = jsonDecode(responseProfessions);
    _professions = data.map((profession) => profession.toString()).toList();
    notifyListeners();
  }

  Future<void> _fetchRelations() async {
    final String responseRelations =
        await rootBundle.loadString('assets/data/person_relations.json');
    final List<dynamic> data = jsonDecode(responseRelations);
    _relations = data.map((relation) => relation.toString()).toList();
    notifyListeners();
  }
}
