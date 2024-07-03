import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:galaxy/model/person_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  final String tablePeople = 'people';

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'people_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $tablePeople (
            id INTEGER PRIMARY KEY AUTOINCREMENT
          )
        ''');
      },
    );
  }

  Future<void> insertPerson(Map<String, dynamic> personData) async {
    final db = await database;

    final existingColumns = await _getColumns(db, tablePeople);
    final newColumns =
        personData.keys.where((key) => !existingColumns.contains(key)).toList();

    // Add new columns if they don't exist
    for (final column in newColumns) {
      await db.execute('ALTER TABLE $tablePeople ADD COLUMN $column TEXT');
    }

    // Convert the image to a base64 string if it exists
    if (personData.containsKey('photo')) {
      final Uint8List? photoBytes = personData['photo'];
      if (photoBytes != null) {
        personData['photo'] = base64Encode(photoBytes);
      }
    }

    await db.insert(tablePeople, personData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<String>> _getColumns(Database db, String tableName) async {
    final List<Map<String, dynamic>> result =
        await db.rawQuery('PRAGMA table_info($tableName)');
    return result.map((row) => row['name'] as String).toList();
  }

  Future<List<PersonModel>> getAllPersons() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tablePeople);

    return List.generate(maps.length, (i) {
      return PersonModel.fromJson(maps[i]);
    });
  }

  Future<List<PersonModel>> getRelevantPersonDetails() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tablePeople,
      columns: [
        'id', 'name', 'profession', 'relation', 'photo', 'emailAddresses', 'phoneNumbers'
      ],
    );

    return List.generate(maps.length, (i) {
      return PersonModel.fromJson(maps[i]);
    });
  }

  Future<PersonModel?> getPersonById(int personId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tablePeople,
      where: 'id = ?',
      whereArgs: [personId],
    );

    if (maps.isNotEmpty) {
      return PersonModel.fromJson(maps.first);
    }
    return null;
  }

  Future<void> updatePerson(int id, Map<String, dynamic> updatedData) async {
    final db = await database;

    final existingColumns = await _getColumns(db, tablePeople);
    final newColumns = updatedData.keys
        .where((key) => !existingColumns.contains(key))
        .toList();

    // Add new columns if they don't exist
    for (final column in newColumns) {
      await db.execute('ALTER TABLE $tablePeople ADD COLUMN $column TEXT');
    }

    // Convert the image to a base64 string if it exists
    if (updatedData.containsKey('photo')) {
      final Uint8List? photoBytes = updatedData['photo'];
      if (photoBytes != null) {
        updatedData['photo'] = base64Encode(photoBytes);
      }
    }

    await db.update(
      tablePeople,
      updatedData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> deletePerson(int id) async {
    try {
      Database db = await database;
      int count = await db.delete(
        tablePeople,
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteField(int personId, String fieldName) async {
    try {
      Database db = await database;
      int count = await db.rawDelete(
        'UPDATE $tablePeople SET $fieldName = null WHERE id = ?',
        [personId],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
