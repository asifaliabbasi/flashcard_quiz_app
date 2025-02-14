import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'flashcard_database.db');

    return await openDatabase(
      path,
      version: 2, // Increment version for schema update
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE flashcards(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            question TEXT NOT NULL, 
            answer TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE scores(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            score INTEGER NOT NULL,
            total INTEGER NOT NULL,
            date TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE scores(
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              score INTEGER NOT NULL,
              total INTEGER NOT NULL,
              date TEXT NOT NULL
            )
          ''');
        }
      },
      onOpen: (db) async {
        await db.rawQuery("PRAGMA journal_mode = WAL;"); // Enable write mode
      },
    );
  }

  Future<List<Map<String, dynamic>>> getFlashcards() async {
    final db = await database;
    return await db.query('flashcards', orderBy: 'id DESC');
  }

  Future<int> addFlashcard(String question, String answer) async {
    final db = await database;
    return await db.insert(
      'flashcards',
      {'question': question, 'answer': answer},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteFlashcard(int id) async {
    final db = await database;
    return await db.delete('flashcards', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getRandomFlashcards(int limit) async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM flashcards ORDER BY RANDOM() LIMIT ?', [limit]);
  }

  Future<int> saveScore(int score, int total) async {
    final db = await database;
    return await db.insert(
      'scores',
      {
        'score': score,
        'total': total,
        'date': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> getScores() async {
    final db = await database;
    return await db.query('scores', orderBy: 'id DESC');
  }

  Future<void> closeDB() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<void> clearScores() async {
    final db = await database;
    await db.delete('scores'); // Assuming your table is named 'scores'
  }

}