import 'package:sqflite/sqflite.dart';

// ================================================================
// BangNganSach – Quản lý bảng "ngan_sach" trong SQLite
//
// Cấu trúc bảng:
//   id            INTEGER PRIMARY KEY AUTOINCREMENT
//   ma_danh_muc   INTEGER  → FK → danh_muc(id)
//   so_tien       REAL
//   ngay_bat_dau  TEXT
//   ngay_ket_thuc TEXT
// ================================================================
class NganSach {
  final int? id;
  final int? maDanhMuc;
  final double? soTien;
  final String? ngayBatDau;
  final String? ngayKetThuc;

  NganSach({
    this.id,
    this.maDanhMuc,
    this.soTien,
    this.ngayBatDau,
    this.ngayKetThuc,
  });
}

class BangNganSach {
  static const tenBang = 'ngan_sach';

  // ── SQL tạo bảng ─────────────────────────────────────────────
  static const sqlTaoBang = '''
    CREATE TABLE ngan_sach (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      ma_danh_muc   INTEGER,
      so_tien       REAL,
      ngay_bat_dau  TEXT,
      ngay_ket_thuc TEXT,
      FOREIGN KEY (ma_danh_muc) REFERENCES danh_muc(id)
    )
  ''';

  // ── Lấy tất cả ngân sách ────────────────────────────────────
  static Future<List<NganSach>> layTatCa(Database db) async {
    final rows = await db.query(tenBang, orderBy: 'ngay_bat_dau ASC');
    return rows.map(_dongThanhNganSach).toList();
  }

  // ── Lấy ngân sách theo danh mục ─────────────────────────────
  static Future<List<NganSach>> layTheoDanhMuc(
      Database db, int maDanhMuc) async {
    final rows = await db.query(
      tenBang,
      where: 'ma_danh_muc = ?',
      whereArgs: [maDanhMuc],
    );
    return rows.map(_dongThanhNganSach).toList();
  }

  // ── Thêm ngân sách mới ───────────────────────────────────────
  static Future<int> them(Database db, NganSach ns) {
    return db.insert(tenBang, {
      'ma_danh_muc': ns.maDanhMuc,
      'so_tien': ns.soTien,
      'ngay_bat_dau': ns.ngayBatDau,
      'ngay_ket_thuc': ns.ngayKetThuc,
    });
  }

  // ── Cập nhật ngân sách ───────────────────────────────────────
  static Future<int> capNhat(Database db, NganSach ns) {
    return db.update(
      tenBang,
      {
        'ma_danh_muc': ns.maDanhMuc,
        'so_tien': ns.soTien,
        'ngay_bat_dau': ns.ngayBatDau,
        'ngay_ket_thuc': ns.ngayKetThuc,
      },
      where: 'id = ?',
      whereArgs: [ns.id],
    );
  }

  // ── Xoá ngân sách theo ID ────────────────────────────────────
  static Future<int> xoa(Database db, int id) {
    return db.delete(tenBang, where: 'id = ?', whereArgs: [id]);
  }

  // ── Chuyển Map → NganSach ───────────────────────────────────
  static NganSach _dongThanhNganSach(Map<String, dynamic> r) => NganSach(
        id: r['id'] as int?,
        maDanhMuc: r['ma_danh_muc'] as int?,
        soTien: (r['so_tien'] as num?)?.toDouble(),
        ngayBatDau: r['ngay_bat_dau'] as String?,
        ngayKetThuc: r['ngay_ket_thuc'] as String?,
      );
}
