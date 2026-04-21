import 'package:sqflite/sqflite.dart';
import '../../models/transaction.dart';

// ================================================================
// BangGiaoDich – Quản lý bảng "giao_dich" trong SQLite
//
// Cấu trúc bảng:
//   id          INTEGER PRIMARY KEY AUTOINCREMENT
//   so_tien     REAL    NOT NULL
//   loai        TEXT    CHECK(loai IN ('thu', 'chi'))
//   ma_danh_muc INTEGER  → FK → danh_muc(id)
//   ma_vi       INTEGER  → FK → vi_tien(id)
//   ghi_chu     TEXT
//   ngay        TEXT
//   ngay_tao    TEXT
// ================================================================
class BangGiaoDich {
  static const tenBang = 'giao_dich';

  // ── SQL tạo bảng ─────────────────────────────────────────────
  static const sqlTaoBang = '''
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
  ''';

  // ── Lấy tất cả giao dịch (JOIN danh_muc + vi_tien) ──────────
  static Future<List<GiaoDich>> layTatCa(Database db) async {
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
    return rows.map(_dongThanhGiaoDich).toList();
  }

  // ── Thêm giao dịch mới, trả về ID ───────────────────────────
  static Future<int> them(Database db, GiaoDich gd) {
    // Chuyển 'income'→'thu', 'expense'→'chi' trước khi lưu
    final loai = gd.type == 'income' ? 'thu' : 'chi';
    return db.insert(tenBang, {
      'so_tien': gd.amount,
      'loai': loai,
      'ma_danh_muc': gd.categoryId,
      'ma_vi': gd.walletId,
      'ghi_chu': gd.note,
      'ngay': gd.date,
      'ngay_tao': gd.createdAt ?? DateTime.now().toIso8601String(),
    });
  }

  // ── Cập nhật giao dịch ───────────────────────────────────────
  static Future<int> capNhat(Database db, GiaoDich gd) {
    final loai = gd.type == 'income' ? 'thu' : 'chi';
    return db.update(
      tenBang,
      {
        'so_tien': gd.amount,
        'loai': loai,
        'ma_danh_muc': gd.categoryId,
        'ma_vi': gd.walletId,
        'ghi_chu': gd.note,
        'ngay': gd.date,
      },
      where: 'id = ?',
      whereArgs: [gd.id],
    );
  }

  // ── Xoá giao dịch theo ID ────────────────────────────────────
  static Future<int> xoa(Database db, int id) {
    return db.delete(tenBang, where: 'id = ?', whereArgs: [id]);
  }

  // ── Chuyển Map → GiaoDich ───────────────────────────────────
  static GiaoDich _dongThanhGiaoDich(Map<String, dynamic> r) {
    final loai = r['type'] as String? ?? 'chi';
    // Ánh xạ 'thu'→'income', 'chi'→'expense' để tương thích model
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
}
