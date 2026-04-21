import 'package:sqflite/sqflite.dart';
import '../../models/transaction.dart';

// ================================================================
// BangViTien – Quản lý bảng "vi_tien" trong SQLite
//
// Cấu trúc bảng:
//   id       INTEGER PRIMARY KEY AUTOINCREMENT
//   ten      TEXT    NOT NULL
//   so_du    REAL    DEFAULT 0
//   ngay_tao TEXT
// ================================================================
class BangViTien {
  static const tenBang = 'vi_tien';

  // ── SQL tạo bảng ─────────────────────────────────────────────
  static const sqlTaoBang = '''
    CREATE TABLE vi_tien (
      id       INTEGER PRIMARY KEY AUTOINCREMENT,
      ten      TEXT    NOT NULL,
      so_du    REAL    DEFAULT 0,
      ngay_tao TEXT
    )
  ''';

  // ── Lấy danh sách tất cả ví ─────────────────────────────────
  static Future<List<Vi>> layTatCa(Database db) async {
    final rows = await db.query(tenBang, orderBy: 'ngay_tao ASC');
    return rows.map(_dongThanhVi).toList();
  }

  // ── Thêm ví mới, trả về ID vừa tạo ──────────────────────────
  static Future<int> them(Database db, Vi vi) {
    return db.insert(tenBang, {
      'ten': vi.name,
      'so_du': vi.balance ?? 0,
      'ngay_tao': vi.createdAt ?? DateTime.now().toIso8601String(),
    });
  }

  // ── Cập nhật ví ─────────────────────────────────────────────
  static Future<int> capNhat(Database db, Vi vi) {
    return db.update(
      tenBang,
      {'ten': vi.name, 'so_du': vi.balance ?? 0},
      where: 'id = ?',
      whereArgs: [vi.id],
    );
  }

  // ── Xoá ví theo ID ───────────────────────────────────────────
  static Future<int> xoa(Database db, int id) {
    return db.delete(tenBang, where: 'id = ?', whereArgs: [id]);
  }

  // ── Chuyển Map → Vi ─────────────────────────────────────────
  static Vi _dongThanhVi(Map<String, dynamic> r) => Vi(
        id: r['id'] as int?,
        name: r['ten'] as String?,
        balance: (r['so_du'] as num?)?.toDouble(),
        createdAt: r['ngay_tao'] as String?,
      );
}
