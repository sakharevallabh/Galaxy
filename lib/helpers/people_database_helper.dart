import 'dart:io';
import 'package:galaxy/model/person_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  final String tablePerson = 'person';

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();
  Database? _database;

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
        name TEXT NOT NULL,
        gender TEXT,
        dob TEXT,
        birthPlace TEXT,
        country TEXT,
        pincode TEXT,
        nationality TEXT,
        maritalStatus TEXT,
        photo BLOB,
        profession TEXT
      )
    ''');
  }

  Future<int> insertPerson(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(tablePerson, row);
  }

  Future<List<PersonModel>> getPerson() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tablePerson);
    return List.generate(maps.length, (i) {
      return PersonModel.fromMap(maps[i]);
    });
  }

  Future<void> updatePerson(PersonModel person) async {
    final db = await database;
    await db.update(
      tablePerson,
      person.toMap(),
      where: 'id = ?',
      whereArgs: [person.id],
    );
  }

  Future<void> deletePerson(int id) async {
    final db = await database;

    await db.delete(
      tablePerson,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
