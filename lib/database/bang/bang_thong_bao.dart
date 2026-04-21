import 'package:sqflite/sqflite.dart';

// ================================================================
// BangThongBao – Quản lý bảng "thong_bao" trong SQLite
//
// Cấu trúc bảng:
//   id        INTEGER PRIMARY KEY AUTOINCREMENT
//   tieu_de   TEXT
//   noi_dung  TEXT
//   thoi_gian TEXT
//   lap_lai   INTEGER DEFAULT 0
// ================================================================
class ThongBao {
  final int? id;
  final String? tieuDe;
  final String? noiDung;
  final String? thoiGian;
  final bool lapLai;

  ThongBao({
    this.id,
    this.tieuDe,
    this.noiDung,
    this.thoiGian,
    this.lapLai = false,
  });
}

class BangThongBao {
  static const tenBang = 'thong_bao';

  // ── SQL tạo bảng ─────────────────────────────────────────────
  static const sqlTaoBang = '''
    CREATE TABLE thong_bao (
      id        INTEGER PRIMARY KEY AUTOINCREMENT,
      tieu_de   TEXT,
      noi_dung  TEXT,
      thoi_gian TEXT,
      lap_lai   INTEGER DEFAULT 0
    )
  ''';

  // ── Lấy tất cả thông báo ────────────────────────────────────
  static Future<List<ThongBao>> layTatCa(Database db) async {
    final rows = await db.query(tenBang, orderBy: 'thoi_gian ASC');
    return rows.map(_dongThanhThongBao).toList();
  }

  // ── Thêm thông báo mới ───────────────────────────────────────
  static Future<int> them(Database db, ThongBao tb) {
    return db.insert(tenBang, {
      'tieu_de': tb.tieuDe,
      'noi_dung': tb.noiDung,
      'thoi_gian': tb.thoiGian,
      'lap_lai': tb.lapLai ? 1 : 0,
    });
  }

  // ── Cập nhật thông báo ───────────────────────────────────────
  static Future<int> capNhat(Database db, ThongBao tb) {
    return db.update(
      tenBang,
      {
        'tieu_de': tb.tieuDe,
        'noi_dung': tb.noiDung,
        'thoi_gian': tb.thoiGian,
        'lap_lai': tb.lapLai ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [tb.id],
    );
  }

  // ── Xoá thông báo theo ID ────────────────────────────────────
  static Future<int> xoa(Database db, int id) {
    return db.delete(tenBang, where: 'id = ?', whereArgs: [id]);
  }

  // ── Chuyển Map → ThongBao ───────────────────────────────────
  static ThongBao _dongThanhThongBao(Map<String, dynamic> r) => ThongBao(
        id: r['id'] as int?,
        tieuDe: r['tieu_de'] as String?,
        noiDung: r['noi_dung'] as String?,
        thoiGian: r['thoi_gian'] as String?,
        lapLai: (r['lap_lai'] as int? ?? 0) == 1,
      );
}
