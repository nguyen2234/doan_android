import 'package:sqflite/sqflite.dart';
import '../../models/transaction.dart';

// ================================================================
// BangDanhMuc – Quản lý bảng "danh_muc" trong SQLite
//
// Cấu trúc bảng:
//   id         INTEGER PRIMARY KEY AUTOINCREMENT
//   ten        TEXT    NOT NULL
//   loai       TEXT    CHECK(loai IN ('thu', 'chi'))
//   bieu_tuong TEXT
//   mau_sac    TEXT
// ================================================================
class BangDanhMuc {
  static const tenBang = 'danh_muc';

  // ── SQL tạo bảng ─────────────────────────────────────────────
  static const sqlTaoBang = '''
    CREATE TABLE danh_muc (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      ten        TEXT    NOT NULL,
      loai       TEXT    CHECK(loai IN ('thu', 'chi')),
      bieu_tuong TEXT,
      mau_sac    TEXT
    )
  ''';

  // ── Lấy danh mục (tuỳ chọn lọc theo loại: 'thu' | 'chi') ───
  static Future<List<DanhMuc>> layDanhSach(Database db, {String? loai}) async {
    final rows = loai != null
        ? await db.query(tenBang, where: 'loai = ?', whereArgs: [loai])
        : await db.query(tenBang);
    return rows.map(_dongThanhDanhMuc).toList();
  }

  // ── Thêm danh mục mới ────────────────────────────────────────
  static Future<int> them(Database db, DanhMuc dm) {
    return db.insert(tenBang, {
      'ten': dm.name,
      'loai': dm.type,
      'bieu_tuong': dm.icon,
      'mau_sac': dm.color,
    });
  }

  // ── Cập nhật danh mục ────────────────────────────────────────
  static Future<int> capNhat(Database db, DanhMuc dm) {
    return db.update(
      tenBang,
      {
        'ten': dm.name,
        'loai': dm.type,
        'bieu_tuong': dm.icon,
        'mau_sac': dm.color,
      },
      where: 'id = ?',
      whereArgs: [dm.id],
    );
  }

  // ── Xoá danh mục theo ID ─────────────────────────────────────
  static Future<int> xoa(Database db, int id) {
    return db.delete(tenBang, where: 'id = ?', whereArgs: [id]);
  }

  // ── Chuyển Map → DanhMuc ────────────────────────────────────
  static DanhMuc _dongThanhDanhMuc(Map<String, dynamic> r) => DanhMuc(
        id: r['id'] as int?,
        name: r['ten'] as String,
        type: r['loai'] as String?,
        icon: r['bieu_tuong'] as String?,
        color: r['mau_sac'] as String?,
      );
}
