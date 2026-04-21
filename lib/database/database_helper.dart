import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expense_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        avatar TEXT,
        created_at TEXT
      )
    ''');

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

    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        amount REAL,
        start_date TEXT,
        end_date TEXT,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        time TEXT,
        is_repeat INTEGER
      )
    ''');

    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
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

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
