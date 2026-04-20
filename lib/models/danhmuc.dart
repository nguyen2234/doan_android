import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CategoryService {
  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'quanly.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE danh_muc(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          ten TEXT,
          loai TEXT,
          so_tien REAL,
          mau TEXT,
          icon TEXT
        )
        ''');
      },
    );
  }

  // THÊM
  Future<void> them(
      String ten, String loai, double soTien, String mau, String icon) async {
    final db = await initDB();

    await db.insert('danh_muc', {
      'ten': ten,
      'loai': loai,
      'so_tien': soTien,
      'mau': mau,
      'icon': icon,
    });
  }

  // LẤY DANH SÁCH
  Future<List<Map>> layTatCa() async {
    final db = await initDB();
    return await db.query('danh_muc');
  }

  // XOÁ
  Future<void> xoa(int id) async {
    final db = await initDB();
    await db.delete('danh_muc', where: 'id=?', whereArgs: [id]);
  }
}