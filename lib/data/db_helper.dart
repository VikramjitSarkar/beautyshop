import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'favorites.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites(
            vendorId TEXT PRIMARY KEY
          )
        ''');
      },
    );
  }

  static Future<void> insertFavorite(String vendorId) async {
    final db = await database;
    await db.insert('favorites', {'vendorId': vendorId},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> deleteFavorite(String vendorId) async {
    final db = await database;
    await db.delete('favorites', where: 'vendorId = ?', whereArgs: [vendorId]);
  }

  static Future<bool> isFavorite(String vendorId) async {
    final db = await database;
    final result = await db.query('favorites',
        where: 'vendorId = ?', whereArgs: [vendorId]);
    return result.isNotEmpty;
  }

  static Future<List<String>> getAllFavorites() async {
    final db = await database;
    final result = await db.query('favorites');
    return result.map((e) => e['vendorId'] as String).toList();
  }
}
