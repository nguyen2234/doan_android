import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'finance.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT CHECK(type IN ('income', 'expense')),
            icon TEXT,
            color TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE wallets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            balance REAL,
            created_at TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL,
            type TEXT CHECK(type IN ('income', 'expense')),
            category_id INTEGER,
            wallet_id INTEGER,
            note TEXT,
            date TEXT,
            created_at TEXT,
            FOREIGN KEY (category_id) REFERENCES categories(id),
            FOREIGN KEY (wallet_id) REFERENCES wallets(id)
          )
        ''');
        await _insertSampleData(db);
      },
    );
  }

  static Future<void> _insertSampleData(Database db) async {
    // Danh mục mẫu
    await db.insert('categories', {'name': 'Lương', 'type': 'income', 'icon': 'attach_money', 'color': '#4CAF50'});
    await db.insert('categories', {'name': 'Thưởng', 'type': 'income', 'icon': 'card_giftcard', 'color': '#8BC34A'});
    await db.insert('categories', {'name': 'Ăn uống', 'type': 'expense', 'icon': 'restaurant', 'color': '#FF5722'});
    await db.insert('categories', {'name': 'Di chuyển', 'type': 'expense', 'icon': 'directions_car', 'color': '#FF9800'});
    await db.insert('categories', {'name': 'Hóa đơn', 'type': 'expense', 'icon': 'receipt', 'color': '#F44336'});
    await db.insert('categories', {'name': 'Mua sắm', 'type': 'expense', 'icon': 'shopping_bag', 'color': '#9C27B0'});

    // Ví mẫu
    await db.insert('wallets', {'name': 'Tiền mặt', 'balance': 5000000, 'created_at': DateTime.now().toIso8601String()});
    await db.insert('wallets', {'name': 'Ngân hàng', 'balance': 20000000, 'created_at': DateTime.now().toIso8601String()});

    // Giao dịch mẫu
    final now = DateTime.now();
    await db.insert('transactions', {'amount': 15000000, 'type': 'income', 'category_id': 1, 'wallet_id': 2, 'note': 'Lương tháng 6', 'date': DateTime(now.year, now.month, 1).toIso8601String(), 'created_at': DateTime.now().toIso8601String()});
    await db.insert('transactions', {'amount': 350000, 'type': 'expense', 'category_id': 5, 'wallet_id': 1, 'note': 'Tiền điện', 'date': DateTime(now.year, now.month, 3).toIso8601String(), 'created_at': DateTime.now().toIso8601String()});
    await db.insert('transactions', {'amount': 120000, 'type': 'expense', 'category_id': 3, 'wallet_id': 1, 'note': 'Ăn trưa', 'date': DateTime(now.year, now.month, 5).toIso8601String(), 'created_at': DateTime.now().toIso8601String()});
    await db.insert('transactions', {'amount': 2000000, 'type': 'income', 'category_id': 2, 'wallet_id': 2, 'note': 'Thưởng dự án', 'date': DateTime(now.year, now.month, 10).toIso8601String(), 'created_at': DateTime.now().toIso8601String()});
    await db.insert('transactions', {'amount': 80000, 'type': 'expense', 'category_id': 4, 'wallet_id': 1, 'note': 'Xăng xe', 'date': DateTime(now.year, now.month, 12).toIso8601String(), 'created_at': DateTime.now().toIso8601String()});
  }

  // TRANSACTIONS
  static Future<int> insertTransaction(GiaoDich t) async {
    final db = await database;
    return db.insert('transactions', t.toMap());
  }

  static Future<List<GiaoDich>> getTransactions() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT t.*, 
             c.name as category_name, c.icon as category_icon, c.color as category_color,
             w.name as wallet_name
      FROM transactions t
      LEFT JOIN categories c ON t.category_id = c.id
      LEFT JOIN wallets w ON t.wallet_id = w.id
      ORDER BY t.date DESC
    ''');
    return maps.map((m) => GiaoDich.fromMap(m)).toList();
  }

  static Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // CATEGORIES
  static Future<List<DanhMuc>> getCategories({String? type}) async {
    final db = await database;
    final maps = type != null
        ? await db.query('categories', where: 'type = ?', whereArgs: [type])
        : await db.query('categories');
    return maps.map((m) => DanhMuc.fromMap(m)).toList();
  }

  // WALLETS
  static Future<List<Vi>> getWallets() async {
    final db = await database;
    final maps = await db.query('wallets', orderBy: 'created_at ASC');
    return maps.map((m) => Vi.fromMap(m)).toList();
  }

  static Future<int> insertWallet(Vi vi) async {
    final db = await database;
    return db.insert('wallets', vi.toMap());
  }

  static Future<int> updateWallet(Vi vi) async {
    final db = await database;
    return db.update(
      'wallets',
      vi.toMap(),
      where: 'id = ?',
      whereArgs: [vi.id],
    );
  }

  static Future<int> deleteWallet(int id) async {
    final db = await database;
    return db.delete('wallets', where: 'id = ?', whereArgs: [id]);
  }
}
