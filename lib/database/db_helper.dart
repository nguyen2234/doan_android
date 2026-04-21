import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';
import '../models/user.dart';

// ================================================================
// DBHelper – Lớp quản lý CSDL SQLite duy nhất của ứng dụng
//
// Tên bảng (tiếng Việt):
//   nguoi_dung      – Người dùng
//   vi_tien         – Ví tiền
//   danh_muc        – Danh mục thu/chi
//   giao_dich       – Giao dịch tài chính
//   ngan_sach       – Ngân sách theo danh mục
//   thong_bao       – Thông báo nhắc nhở
// ================================================================
class DBHelper {
  static Database? _db;

  // ── Singleton accessor ──────────────────────────────────────
  static Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'quan_ly_tai_chinh.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _taoBang,
    );
  }

  // ── Tạo các bảng khi khởi tạo CSDL lần đầu ─────────────────
  static Future<void> _taoBang(Database db, int version) async {
    // Bảng: nguoi_dung
    await db.execute('''
      CREATE TABLE nguoi_dung (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        ten         TEXT    NOT NULL,
        email       TEXT    NOT NULL UNIQUE,
        mat_khau    TEXT    NOT NULL,
        anh_dai_dien TEXT,
        ngay_tao    TEXT
      )
    ''');

    // Bảng: danh_muc
    await db.execute('''
      CREATE TABLE danh_muc (
        id      INTEGER PRIMARY KEY AUTOINCREMENT,
        ten     TEXT    NOT NULL,
        loai    TEXT    CHECK(loai IN ('thu', 'chi')),
        bieu_tuong TEXT,
        mau_sac TEXT
      )
    ''');

    // Bảng: vi_tien
    await db.execute('''
      CREATE TABLE vi_tien (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        ten      TEXT    NOT NULL,
        so_du    REAL    DEFAULT 0,
        ngay_tao TEXT
      )
    ''');

    // Bảng: giao_dich
    await db.execute('''
      CREATE TABLE giao_dich (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        so_tien     REAL    NOT NULL,
        loai        TEXT    CHECK(loai IN ('thu', 'chi')),
        ma_danh_muc INTEGER,
        ma_vi       INTEGER,
        ghi_chu     TEXT,
        ngay        TEXT,
        ngay_tao    TEXT,
        FOREIGN KEY (ma_danh_muc) REFERENCES danh_muc(id),
        FOREIGN KEY (ma_vi)       REFERENCES vi_tien(id)
      )
    ''');

    // Bảng: ngan_sach
    await db.execute('''
      CREATE TABLE ngan_sach (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        ma_danh_muc INTEGER,
        so_tien     REAL,
        ngay_bat_dau TEXT,
        ngay_ket_thuc TEXT,
        FOREIGN KEY (ma_danh_muc) REFERENCES danh_muc(id)
      )
    ''');

    // Bảng: thong_bao
    await db.execute('''
      CREATE TABLE thong_bao (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        tieu_de   TEXT,
        noi_dung  TEXT,
        thoi_gian TEXT,
        lap_lai   INTEGER DEFAULT 0
      )
    ''');
  }

  // ════════════════════════════════════════════════════════════
  // NGƯỜI DÙNG (nguoi_dung)
  // ════════════════════════════════════════════════════════════

  /// Đăng ký người dùng mới, trả về ID vừa tạo.
  static Future<int> themNguoiDung(User user) async {
    final db = await database;
    return db.insert('nguoi_dung', {
      'ten': user.name,
      'email': user.email,
      'mat_khau': user.password,
      'anh_dai_dien': user.avatar,
      'ngay_tao': user.createdAt ?? DateTime.now().toIso8601String(),
    });
  }

  /// Lấy người dùng theo email.
  static Future<User?> layNguoiDungTheoEmail(String email) async {
    final db = await database;
    final rows = await db.query(
      'nguoi_dung',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (rows.isEmpty) return null;
    return _rowToUser(rows.first);
  }

  /// Lấy người dùng theo ID.
  static Future<User?> layNguoiDungTheoId(int id) async {
    final db = await database;
    final rows = await db.query(
      'nguoi_dung',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return _rowToUser(rows.first);
  }

  /// Đăng nhập – trả về User nếu đúng email & mật khẩu, null nếu sai.
  static Future<User?> dangNhap(String email, String matKhau) async {
    final db = await database;
    final rows = await db.query(
      'nguoi_dung',
      where: 'email = ? AND mat_khau = ?',
      whereArgs: [email, matKhau],
    );
    if (rows.isEmpty) return null;
    return _rowToUser(rows.first);
  }

  /// Cập nhật thông tin người dùng.
  static Future<int> capNhatNguoiDung(User user) async {
    final db = await database;
    return db.update(
      'nguoi_dung',
      {
        'ten': user.name,
        'mat_khau': user.password,
        'anh_dai_dien': user.avatar,
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  static User _rowToUser(Map<String, dynamic> r) => User(
        id: r['id'] as int?,
        name: r['ten'] as String,
        email: r['email'] as String,
        password: r['mat_khau'] as String,
        avatar: r['anh_dai_dien'] as String?,
        createdAt: r['ngay_tao'] as String?,
      );

  // ════════════════════════════════════════════════════════════
  // VÍ TIỀN (vi_tien)
  // ════════════════════════════════════════════════════════════

  static Future<List<Vi>> layDanhSachVi() async {
    final db = await database;
    final rows = await db.query('vi_tien', orderBy: 'ngay_tao ASC');
    return rows.map(_rowToVi).toList();
  }

  static Future<int> themVi(Vi vi) async {
    final db = await database;
    return db.insert('vi_tien', {
      'ten': vi.name,
      'so_du': vi.balance ?? 0,
      'ngay_tao': vi.createdAt ?? DateTime.now().toIso8601String(),
    });
  }

  static Future<int> capNhatVi(Vi vi) async {
    final db = await database;
    return db.update(
      'vi_tien',
      {'ten': vi.name, 'so_du': vi.balance ?? 0},
      where: 'id = ?',
      whereArgs: [vi.id],
    );
  }

  static Future<int> xoaVi(int id) async {
    final db = await database;
    return db.delete('vi_tien', where: 'id = ?', whereArgs: [id]);
  }

  static Vi _rowToVi(Map<String, dynamic> r) => Vi(
        id: r['id'] as int?,
        name: r['ten'] as String?,
        balance: (r['so_du'] as num?)?.toDouble(),
        createdAt: r['ngay_tao'] as String?,
      );

  // ════════════════════════════════════════════════════════════
  // DANH MỤC (danh_muc)
  // ════════════════════════════════════════════════════════════

  /// [loai] = 'thu' | 'chi' | null (lấy tất cả)
  static Future<List<DanhMuc>> layDanhMuc({String? loai}) async {
    final db = await database;
    final rows = loai != null
        ? await db.query('danh_muc', where: 'loai = ?', whereArgs: [loai])
        : await db.query('danh_muc');
    return rows.map(_rowToDanhMuc).toList();
  }

  static Future<int> themDanhMuc(DanhMuc dm) async {
    final db = await database;
    return db.insert('danh_muc', {
      'ten': dm.name,
      'loai': dm.type,
      'bieu_tuong': dm.icon,
      'mau_sac': dm.color,
    });
  }

  static Future<int> capNhatDanhMuc(DanhMuc dm) async {
    final db = await database;
    return db.update(
      'danh_muc',
      {'ten': dm.name, 'loai': dm.type, 'bieu_tuong': dm.icon, 'mau_sac': dm.color},
      where: 'id = ?',
      whereArgs: [dm.id],
    );
  }

  static Future<int> xoaDanhMuc(int id) async {
    final db = await database;
    return db.delete('danh_muc', where: 'id = ?', whereArgs: [id]);
  }

  static DanhMuc _rowToDanhMuc(Map<String, dynamic> r) => DanhMuc(
        id: r['id'] as int?,
        name: r['ten'] as String,
        type: r['loai'] as String?,
        icon: r['bieu_tuong'] as String?,
        color: r['mau_sac'] as String?,
      );

  // ════════════════════════════════════════════════════════════
  // GIAO DỊCH (giao_dich)
  // ════════════════════════════════════════════════════════════

  static Future<List<GiaoDich>> layGiaoDich() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT
        g.id,
        g.so_tien       AS amount,
        g.loai          AS type,
        g.ma_danh_muc   AS category_id,
        g.ma_vi         AS wallet_id,
        g.ghi_chu       AS note,
        g.ngay          AS date,
        g.ngay_tao      AS created_at,
        d.ten           AS category_name,
        d.bieu_tuong    AS category_icon,
        d.mau_sac       AS category_color,
        v.ten           AS wallet_name
      FROM giao_dich g
      LEFT JOIN danh_muc d ON g.ma_danh_muc = d.id
      LEFT JOIN vi_tien  v ON g.ma_vi       = v.id
      ORDER BY g.ngay DESC
    ''');
    return rows.map(_rowToGiaoDich).toList();
  }

  static Future<int> themGiaoDich(GiaoDich gd) async {
    final db = await database;
    return db.insert('giao_dich', {
      'so_tien': gd.amount,
      'loai': gd.type,
      'ma_danh_muc': gd.categoryId,
      'ma_vi': gd.walletId,
      'ghi_chu': gd.note,
      'ngay': gd.date,
      'ngay_tao': gd.createdAt ?? DateTime.now().toIso8601String(),
    });
  }

  static Future<int> capNhatGiaoDich(GiaoDich gd) async {
    final db = await database;
    return db.update(
      'giao_dich',
      {
        'so_tien': gd.amount,
        'loai': gd.type,
        'ma_danh_muc': gd.categoryId,
        'ma_vi': gd.walletId,
        'ghi_chu': gd.note,
        'ngay': gd.date,
      },
      where: 'id = ?',
      whereArgs: [gd.id],
    );
  }

  static Future<int> xoaGiaoDich(int id) async {
    final db = await database;
    return db.delete('giao_dich', where: 'id = ?', whereArgs: [id]);
  }

  static GiaoDich _rowToGiaoDich(Map<String, dynamic> r) {
    final loai = r['type'] as String? ?? 'chi';
    // Ánh xạ 'thu'→'income', 'chi'→'expense' để tương thích model cũ
    final typeEn = loai == 'thu' ? 'income' : 'expense';
    return GiaoDich(
      id: r['id'] as int?,
      amount: (r['amount'] as num).toDouble(),
      type: typeEn,
      categoryId: r['category_id'] as int?,
      walletId: r['wallet_id'] as int?,
      note: r['note'] as String?,
      date: r['date'] as String?,
      createdAt: r['created_at'] as String?,
      categoryName: r['category_name'] as String?,
      categoryIcon: r['category_icon'] as String?,
      categoryColor: r['category_color'] as String?,
      walletName: r['wallet_name'] as String?,
    );
  }

  // ════════════════════════════════════════════════════════════
  // ALIAS – giữ tương thích với code màn hình hiện tại
  // ════════════════════════════════════════════════════════════

  /// Alias cho [layDanhSachVi] – dùng ở vi_tien_screen
  static Future<List<Vi>> getWallets() => layDanhSachVi();
  static Future<int> insertWallet(Vi vi) => themVi(vi);
  static Future<int> updateWallet(Vi vi) => capNhatVi(vi);
  static Future<int> deleteWallet(int id) => xoaVi(id);

  /// Alias cho [layGiaoDich] – dùng ở home_screen, bao_cao_screen …
  static Future<List<GiaoDich>> getTransactions() => layGiaoDich();
  static Future<int> insertTransaction(GiaoDich gd) => themGiaoDich(gd);
  static Future<int> deleteTransaction(int id) => xoaGiaoDich(id);

  /// Alias cho [layDanhMuc] – dùng ở them_giao_dich_screen
  static Future<List<DanhMuc>> getCategories({String? type}) {
    // Chuyển 'income'→'thu', 'expense'→'chi'
    String? loai;
    if (type == 'income') loai = 'thu';
    if (type == 'expense') loai = 'chi';
    return layDanhMuc(loai: loai);
  }

  // ════════════════════════════════════════════════════════════
  // ALIAS NGƯỜI DÙNG – tương thích với UserDao cũ
  // ════════════════════════════════════════════════════════════
  static Future<int> insertUser(User user) => themNguoiDung(user);
  static Future<User?> getUserByEmail(String email) =>
      layNguoiDungTheoEmail(email);
  static Future<User?> getUserById(int id) => layNguoiDungTheoId(id);
  static Future<User?> login(String email, String matKhau) =>
      dangNhap(email, matKhau);
  static Future<int> updateUser(User user) => capNhatNguoiDung(user);

  // ── Đóng kết nối ────────────────────────────────────────────
  static Future<void> close() async => (await database).close();
}
