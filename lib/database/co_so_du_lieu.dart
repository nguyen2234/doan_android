import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/transaction.dart';
import '../models/user.dart';
import 'bang/bang_nguoi_dung.dart';
import 'bang/bang_vi_tien.dart';
import 'bang/bang_danh_muc.dart';
import 'bang/bang_giao_dich.dart';
import 'bang/bang_ngan_sach.dart';
import 'bang/bang_thong_bao.dart';

// ================================================================
// CoSoDuLieu – Lớp quản lý CSDL SQLite duy nhất (Singleton)
//
// Mỗi bảng được định nghĩa SQL + CRUD trong file riêng:
//   bang/bang_nguoi_dung.dart  → bảng nguoi_dung
//   bang/bang_vi_tien.dart     → bảng vi_tien
//   bang/bang_danh_muc.dart    → bảng danh_muc
//   bang/bang_giao_dich.dart   → bảng giao_dich
//   bang/bang_ngan_sach.dart   → bảng ngan_sach
//   bang/bang_thong_bao.dart   → bảng thong_bao
// ================================================================
class CoSoDuLieu {
  static Database? _db;

  // ── Singleton accessor ───────────────────────────────────────
  static Future<Database> get coSoDuLieu async {
    _db ??= await _khoiTao();
    return _db!;
  }

  static Future<Database> _khoiTao() async {
    final duongDan =
        join(await getDatabasesPath(), 'quan_ly_tai_chinh.db');
    return openDatabase(
      duongDan,
      version: 1,
      onCreate: _taoCacBang,
    );
  }

  // ── Tạo tất cả bảng khi khởi tạo CSDL lần đầu ──────────────
  static Future<void> _taoCacBang(Database db, int version) async {
    await db.execute(BangNguoiDung.sqlTaoBang);
    await db.execute(BangDanhMuc.sqlTaoBang);   // danh_muc trước giao_dich (FK)
    await db.execute(BangViTien.sqlTaoBang);    // vi_tien  trước giao_dich (FK)
    await db.execute(BangGiaoDich.sqlTaoBang);
    await db.execute(BangNganSach.sqlTaoBang);
    await db.execute(BangThongBao.sqlTaoBang);
  }

  // ── Đóng kết nối ─────────────────────────────────────────────
  static Future<void> dong() async => (await coSoDuLieu).close();

  // ════════════════════════════════════════════════════════════
  // NGƯỜI DÙNG
  // ════════════════════════════════════════════════════════════

  static Future<int> themNguoiDung(User user) async =>
      BangNguoiDung.themNguoiDung(await coSoDuLieu, user);

  static Future<User?> layNguoiDungTheoEmail(String email) async =>
      BangNguoiDung.layTheoEmail(await coSoDuLieu, email);

  static Future<User?> layNguoiDungTheoId(int id) async =>
      BangNguoiDung.layTheoId(await coSoDuLieu, id);

  static Future<User?> dangNhap(String email, String matKhau) async =>
      BangNguoiDung.dangNhap(await coSoDuLieu, email, matKhau);

  static Future<int> capNhatNguoiDung(User user) async =>
      BangNguoiDung.capNhat(await coSoDuLieu, user);

  // ════════════════════════════════════════════════════════════
  // VÍ TIỀN
  // ════════════════════════════════════════════════════════════

  static Future<List<Vi>> layDanhSachVi() async =>
      BangViTien.layTatCa(await coSoDuLieu);

  static Future<int> themVi(Vi vi) async =>
      BangViTien.them(await coSoDuLieu, vi);

  static Future<int> capNhatVi(Vi vi) async =>
      BangViTien.capNhat(await coSoDuLieu, vi);

  static Future<int> xoaVi(int id) async =>
      BangViTien.xoa(await coSoDuLieu, id);

  // ════════════════════════════════════════════════════════════
  // DANH MỤC
  // ════════════════════════════════════════════════════════════

  /// [loai] = 'thu' | 'chi' | null (lấy tất cả)
  static Future<List<DanhMuc>> layDanhMuc({String? loai}) async =>
      BangDanhMuc.layDanhSach(await coSoDuLieu, loai: loai);

  static Future<int> themDanhMuc(DanhMuc dm) async =>
      BangDanhMuc.them(await coSoDuLieu, dm);

  static Future<int> capNhatDanhMuc(DanhMuc dm) async =>
      BangDanhMuc.capNhat(await coSoDuLieu, dm);

  static Future<int> xoaDanhMuc(int id) async =>
      BangDanhMuc.xoa(await coSoDuLieu, id);

  // ════════════════════════════════════════════════════════════
  // GIAO DỊCH
  // ════════════════════════════════════════════════════════════

  static Future<List<GiaoDich>> layGiaoDich() async =>
      BangGiaoDich.layTatCa(await coSoDuLieu);

  static Future<int> themGiaoDich(GiaoDich gd) async =>
      BangGiaoDich.them(await coSoDuLieu, gd);

  static Future<int> capNhatGiaoDich(GiaoDich gd) async =>
      BangGiaoDich.capNhat(await coSoDuLieu, gd);

  static Future<int> xoaGiaoDich(int id) async =>
      BangGiaoDich.xoa(await coSoDuLieu, id);

  // ════════════════════════════════════════════════════════════
  // NGÂN SÁCH
  // ════════════════════════════════════════════════════════════

  static Future<List<NganSach>> layNganSach() async =>
      BangNganSach.layTatCa(await coSoDuLieu);

  static Future<List<NganSach>> layNganSachTheoDanhMuc(int maDanhMuc) async =>
      BangNganSach.layTheoDanhMuc(await coSoDuLieu, maDanhMuc);

  static Future<int> themNganSach(NganSach ns) async =>
      BangNganSach.them(await coSoDuLieu, ns);

  static Future<int> capNhatNganSach(NganSach ns) async =>
      BangNganSach.capNhat(await coSoDuLieu, ns);

  static Future<int> xoaNganSach(int id) async =>
      BangNganSach.xoa(await coSoDuLieu, id);

  // ════════════════════════════════════════════════════════════
  // THÔNG BÁO
  // ════════════════════════════════════════════════════════════

  static Future<List<ThongBao>> layThongBao() async =>
      BangThongBao.layTatCa(await coSoDuLieu);

  static Future<int> themThongBao(ThongBao tb) async =>
      BangThongBao.them(await coSoDuLieu, tb);

  static Future<int> capNhatThongBao(ThongBao tb) async =>
      BangThongBao.capNhat(await coSoDuLieu, tb);

  static Future<int> xoaThongBao(int id) async =>
      BangThongBao.xoa(await coSoDuLieu, id);

  // ════════════════════════════════════════════════════════════
  // ALIAS – giữ tương thích với code màn hình hiện tại
  // ════════════════════════════════════════════════════════════

  // Ví tiền
  static Future<List<Vi>> getWallets() => layDanhSachVi();
  static Future<int> insertWallet(Vi vi) => themVi(vi);
  static Future<int> updateWallet(Vi vi) => capNhatVi(vi);
  static Future<int> deleteWallet(int id) => xoaVi(id);

  // Giao dịch
  static Future<List<GiaoDich>> getTransactions() => layGiaoDich();
  static Future<int> insertTransaction(GiaoDich gd) => themGiaoDich(gd);
  static Future<int> deleteTransaction(int id) => xoaGiaoDich(id);

  // Danh mục (chuyển 'income'→'thu', 'expense'→'chi')
  static Future<List<DanhMuc>> getCategories({String? type}) {
    String? loai;
    if (type == 'income') loai = 'thu';
    if (type == 'expense') loai = 'chi';
    return layDanhMuc(loai: loai);
  }

  // Người dùng
  static Future<int> insertUser(User user) => themNguoiDung(user);
  static Future<User?> getUserByEmail(String email) =>
      layNguoiDungTheoEmail(email);
  static Future<User?> getUserById(int id) => layNguoiDungTheoId(id);
  static Future<User?> login(String email, String matKhau) =>
      dangNhap(email, matKhau);
  static Future<int> updateUser(User user) => capNhatNguoiDung(user);
}

// ── Alias toàn cục để không cần sửa import ở các màn hình cũ ───
// Các file screen đang dùng DBHelper → trỏ sang CoSoDuLieu
typedef DBHelper = CoSoDuLieu;
