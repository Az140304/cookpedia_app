import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cookpedia_app/models/user_model.dart';
import 'package:cookpedia_app/models/notes_model.dart';

class DatabaseHelper {
  static const _databaseName = "grocery_notes_db.sql";
  static const _databaseVersion = 1;

  static const tableUsers = 'users';
  static const columnUserId = 'id';
  static const columnUsername = 'username';
  static const columnPassword = 'password'; // In a real app, store hashed passwords

  static const tableNotes = 'notes';
  static const columnNoteId = 'id';
  static const columnNoteUserId = 'user_id'; // Foreign key
  static const columnFoodName = 'food_name';
  static const columnMeasure = 'measure';
  static const columnCreatedAt = 'createdAt';
  static const columnUpdatedAt = 'updatedAt';

  // Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Open the database and create it if it doesn't exist
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate, onConfigure: _onConfigure);
  }

  // Enable foreign key support
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<bool> isDatabaseConnected() async {
    try {
      final db = await database; // This ensures an attempt to open/initialize is made
      print(await db.query("notes"));
      return db.isOpen;
    } catch (e) {
      // This catch block will handle errors during database initialization/opening
      print("Database connection check failed: $e");
      return false;
    }
  }
  // SQL code to create the database tables
  Future _onCreate(Database db, int version) async {
    // Users Table
    await db.execute('''
    CREATE TABLE $tableUsers (
      $columnUserId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnUsername TEXT NOT NULL UNIQUE,
      $columnPassword TEXT NOT NULL,
      $columnCreatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP 
    )
  ''');
    print("Users table created successfully.");

    // Notes Table
    await db.execute('''
    CREATE TABLE $tableNotes (
      $columnNoteId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnNoteUserId INTEGER NOT NULL,
      $columnFoodName TEXT NOT NULL, 
      $columnMeasure TEXT NOT NULL,  
      $columnCreatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
      $columnUpdatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY ($columnNoteUserId) REFERENCES $tableUsers ($columnUserId) ON DELETE CASCADE
    )
  ''');
    print("Notes table created successfully.");
  }

  // Helper methods for Users

  Future<int> createUser(User user) async {
    Database db = await instance.database;
    // WARNING: HASH PASSWORD BEFORE SAVING IN A REAL APP
    return await db.insert(tableUsers, user.toMap());
  }

  Future<User?> getUserByUsername(String username) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(tableUsers,
        where: '$columnUsername = ?',
        whereArgs: [username]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    Database db = await instance.database;
    List<Map<String,dynamic>> maps = await db.query(tableUsers,
        where: '$columnUserId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }


  // Helper methods for Notes

  Future<int> createNote(NoteModel note) async {
    Database db = await instance.database;
    return await db.insert(tableNotes, note.toMap());
  }

  Future<List<NoteModel>> getNotesForUser(int userId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableNotes,
        where: '$columnNoteUserId = ?',
        whereArgs: [userId],
        orderBy: '$columnCreatedAt DESC');

    print(maps);

    return List.generate(maps.length, (i) {
      return NoteModel.fromMap(maps[i]);
    });
  }

  Future<int> updateNote(NoteModel note) async {
    Database db = await instance.database;
    return await db.update(tableNotes, note.toMap(),
        where: '$columnNoteId = ?', whereArgs: [note.id]);
  }

  Future<int> deleteNote(int id) async {
    Database db = await instance.database;
    return await db.delete(tableNotes, where: '$columnNoteId = ?', whereArgs: [id]);
  }

  Future<List<NoteModel>> getAllNotes() async {
    Database db = await instance.database;
    // Query the table for all notes, ordering by creation date or ID
    final List<Map<String, dynamic>> maps = await db.query(
      tableNotes,
      orderBy: '$columnCreatedAt DESC', // Optional: order them
    );

    // Convert the List<Map<String, dynamic>> into a List<Note>.
    return List.generate(maps.length, (i) {
      return NoteModel.fromMap(maps[i]);
    });
  }

// Close the database (optional, usually managed by sqflite itself)
Future close() async {
  final db = await instance.database;
  db.close();
}
}