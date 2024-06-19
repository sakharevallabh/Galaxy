import 'dart:io';
import 'package:galaxy/model/person_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  final String tablePerson = 'person';

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'person_data.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE person (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        middleName TEXT,
        lastName TEXT,
        gender TEXT,
        dob TEXT,
        birthPlace TEXT,
        country TEXT,
        pincode TEXT,
        nationality TEXT,
        maritalStatus TEXT,
        photo BLOB,
        profession TEXT,
        addresses TEXT,
        phone_numbers TEXT,
        email_addresses TEXT,
        social_media_profiles TEXT,
        additional_fields TEXT
      )
    ''');
  }

  Future<int> insertPerson(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(tablePerson, row);
  }

  Future<int> insertAddress(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('address', row);
  }

  Future<int> insertPhoneNumber(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('phone_number', row);
  }

  Future<int> insertEmailAddress(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('email_address', row);
  }

  Future<int> insertSocialMediaProfile(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('social_media_profile', row);
  }

  Future<int> insertAdditionalField(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('additional_field', row);
  }

  Future<List<Map<String, dynamic>>> getPerson() async {
    Database db = await database;
    return await db.query(tablePerson);
  }

  // Future<int> updatePerson(PersonModel person) async {
  Future<int> updatePerson(int id, Map<String, dynamic> row) async {
    Database db = await database;
    return await db.update(tablePerson, row, where: 'id = ?', whereArgs: [id]);
    // return await db.update(tablePerson, person.toMap(), where: "id = ?", whereArgs: [person.id]);
  }
}
