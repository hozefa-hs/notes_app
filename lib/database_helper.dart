import 'package:sqflite/sqflite.dart' as sql;

class DatabaseHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute('''CREATE TABLE notes(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT,
      desc TEXT,
      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )''');
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase('myDatabase.db', version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  static Future<int> createData(String title, String? desc) async {
    final db = await DatabaseHelper.db();
    final data = {'title': title, 'desc': desc};
    final id = await db.insert('notes', data);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await DatabaseHelper.db();
    return db.query('notes', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getSingleData(int id) async {
    final db = await DatabaseHelper.db();
    return db.query('notes', where: 'id = ?', whereArgs: [id], limit: 1);
  }

  static Future<int> updateData(int id, String title, String? desc) async {
    final db = await DatabaseHelper.db();
    final data = {
      'title': title,
      'desc': desc,
      'createdAt': DateTime.now().toString()
    };
    final result = await db.update('notes', data, where: 'id = ?', whereArgs: [id]);
    return result;
  }

  static Future<void> deleteData(int id) async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete('notes', where: 'id = ?', whereArgs: [id]);
    } catch (e) {}
  }
}
