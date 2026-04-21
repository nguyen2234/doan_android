import 'package:sqflite/sqflite.dart';
import '../../models/user.dart';

// ================================================================
// BangNguoiDung – Quản lý bảng "nguoi_dung" trong SQLite
//
// Cấu trúc bảng:
//   id           INTEGER PRIMARY KEY AUTOINCREMENT
//   ten          TEXT    NOT NULL
//   email        TEXT    NOT NULL UNIQUE
//   mat_khau     TEXT    NOT NULL
//   anh_dai_dien TEXT
//   ngay_tao     TEXT
// ================================================================
class BangNguoiDung {
  static const tenBang = 'nguoi_dung';

  // ── SQL tạo bảng ─────────────────────────────────────────────
  static const sqlTaoBang = '''
    CREATE TABLE nguoi_dung (
      id           INTEGER PRIMARY KEY AUTOINCREMENT,
      ten          TEXT    NOT NULL,
      email        TEXT    NOT NULL UNIQUE,
      mat_khau     TEXT    NOT NULL,
      anh_dai_dien TEXT,
      ngay_tao     TEXT
    )
  ''';

  // ── Thêm người dùng mới, trả về ID vừa tạo ──────────────────
  static Future<int> themNguoiDung(Database db, User user) {
    return db.insert(tenBang, {
      'ten': user.name,
      'email': user.email,
      'mat_khau': user.password,
      'anh_dai_dien': user.avatar,
      'ngay_tao': user.createdAt ?? DateTime.now().toIso8601String(),
    });
  }

  // ── Lấy người dùng theo email ────────────────────────────────
  static Future<User?> layTheoEmail(Database db, String email) async {
    final rows = await db.query(
      tenBang,
      where: 'email = ?',
      whereArgs: [email],
    );
    if (rows.isEmpty) return null;
    return _dongThanhUser(rows.first);
  }

  // ── Lấy người dùng theo ID ───────────────────────────────────
  static Future<User?> layTheoId(Database db, int id) async {
    final rows = await db.query(
      tenBang,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return _dongThanhUser(rows.first);
  }

  // ── Đăng nhập: xác thực email + mật khẩu ────────────────────
  static Future<User?> dangNhap(
      Database db, String email, String matKhau) async {
    final rows = await db.query(
      tenBang,
      where: 'email = ? AND mat_khau = ?',
      whereArgs: [email, matKhau],
    );
    if (rows.isEmpty) return null;
    return _dongThanhUser(rows.first);
  }

  // ── Cập nhật thông tin người dùng ───────────────────────────
  static Future<int> capNhat(Database db, User user) {
    return db.update(
      tenBang,
      {
        'ten': user.name,
        'mat_khau': user.password,
        'anh_dai_dien': user.avatar,
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // ── Chuyển Map → User ────────────────────────────────────────
  static User _dongThanhUser(Map<String, dynamic> r) => User(
        id: r['id'] as int?,
        name: r['ten'] as String,
        email: r['email'] as String,
        password: r['mat_khau'] as String,
        avatar: r['anh_dai_dien'] as String?,
        createdAt: r['ngay_tao'] as String?,
      );
}
