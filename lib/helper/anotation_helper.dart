import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:minhas_anotacoes/model/notes.dart';

class AnotationHelper {
  static final AnotationHelper _anotationHelper = AnotationHelper._internal();
  Database? _db;
  static const tableName = 'notes';

  factory AnotationHelper() {
    return _anotationHelper;
  }

  AnotationHelper._internal();

  get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await _initializeDatabase();
      return _db;
    }
  }

  _onCreate(Database db, int version) async {
    var sql = 'CREATE TABLE $tableName ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'title VARCHAR, '
        'description TEXT, '
        'date DATETIME)';
    await db.execute(sql);
  }

  _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final databaseLocation = join(databasePath, 'myDatabase.db');

    final db =
        await openDatabase(databaseLocation, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<int> saveAnotation(Notes notes) async {
    Database dataBase = await db;
    int result = await dataBase.insert(tableName, notes.toMap());
    return result;
  }

  Future<int> updateAnotation(Notes notes) async {
    Database database = await db;
    int result = await database.update(tableName, notes.toMap(),
        where: 'id = ?', whereArgs: [notes.id]);

    return result;
  }

  Future<int> removeAnotation(int id) async {
    Database database = await db;
    return await database.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  getNotes() async {
    Database database = await db;
    var sql = 'SELECT * FROM $tableName ORDER BY date DESC';
    List notes = await database.rawQuery(sql);
    return notes;
  }
}
