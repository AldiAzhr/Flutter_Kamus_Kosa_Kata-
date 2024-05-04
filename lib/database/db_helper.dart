// db_helper.dart

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:kamus_app/word.dart';

class DatabaseHelper {
  static late Database _database;
  static final _tableName = 'words';
  static final _columnId = 'id';
  static final _columnOriginalWord = 'originalWord';
  static final _columnTranslatedWord = 'translatedWord';

  static Future<Database> get database async {
    _database = await _initDatabase();
    return _database;
  }

  static Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'words_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE $_tableName($_columnId INTEGER PRIMARY KEY, $_columnOriginalWord TEXT, $_columnTranslatedWord TEXT)",
        );
      },
      version: 1,
    );
  }

  static Future<void> insertWord(Word word) async {
    final db = await database;
    await db.insert(
      _tableName,
      word.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Word>> getAllWords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) {
      return Word(
        id: maps[i][_columnId],
        originalWord: maps[i][_columnOriginalWord],
        translatedWord: maps[i][_columnTranslatedWord],
      );
    });
  }

  static Future<List<Word>> searchWords(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: '$_columnOriginalWord LIKE ? OR $_columnTranslatedWord LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) {
      return Word(
        id: maps[i][_columnId],
        originalWord: maps[i][_columnOriginalWord],
        translatedWord: maps[i][_columnTranslatedWord],
      );
    });
  }

  static Future<void> updateWord(Word word) async {
    final db = await database;
    await db.update(
      _tableName,
      word.toMap(),
      where: '$_columnId = ?',
      whereArgs: [word.id],
    );
  }

  static Future<void> deleteWord(int id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: '$_columnId = ?',
      whereArgs: [id],
    );
  }
}
