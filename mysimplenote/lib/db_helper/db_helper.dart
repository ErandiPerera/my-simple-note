import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sql;

import '../model/note.dart';

class DBHelper {
  // Initialize the database and create the table
  static Future<sql.Database> db() async {
    final path = await sql.getDatabasesPath();
    return sql.openDatabase(
      join(path, "mynotes.db",),
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTable(database);
      },
    );
  }

  // Method to create the notes table
  static Future<void> createTable(sql.Database database) async {
    await database.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP 
      )
    ''');
  }

  // Insert data into the notes table
  static Future<int> insertData(Note note) async {
    final db = await DBHelper.db();
    final data = note.toMap();
    final id = await db.insert(
      'notes',
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );

    return id;
  }

  // Query all records from the notes table
  static Future<List<Map<String, dynamic>>> queryAll() async {
    final db = await DBHelper.db();
    return db.query('notes', orderBy: 'id');
  }


  // Query a single record from the notes table by ID
  static Future<List<Map<String, dynamic>>> querySingleData(int id) async {
    final db = await DBHelper.db();
    return db.query('notes', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Search notes by title
  static Future<List<Map<String, dynamic>>> searchByTitle(String title) async {
    final db = await DBHelper.db();
    return db.query('notes',
        where: "title LIKE ?",
        whereArgs: ['%$title%'],
        orderBy: 'id');
  }

  // Update a record in the notes table by ID
  static Future<int> updateData(Note note) async {
    final db = await DBHelper.db();

    final data = note.toMap();
    final output = await db.update(
      'notes',
      data,
      where: "id = ?",
      whereArgs: [note.id],
    );

    return output;
  }

  // Delete a record from the notes table by ID
  static Future<void> delete(int id) async {
    final db = await DBHelper.db();
    try {
      await db.delete('notes', where: "id = ?", whereArgs: [id]);
    } catch (e) {
      print("Error deleting record: $e");
    }
  }
}
