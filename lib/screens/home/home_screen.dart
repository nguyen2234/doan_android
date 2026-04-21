import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/transaction.dart';
import '../../models/user.dart';

// ============================================================
// Màn hình Trang chủ (Dashboard)
// Hiển thị: Tổng số dư, Thu/Chi tháng này, Giao dịch gần đây
// ============================================================
class HomeScreen extends StatefulWidget {
  final User user; // Người dùng đang đăng nhập

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<GiaoDich> _danhSachGiaoDich = []; // Danh sách toàn bộ giao dịch
  bool _dangTai = true; // Đang tải dữ liệu hay không

  @override
  void initState() {
    super.initState();
    _taiDuLieu(); // Tải dữ liệu khi mở màn hình
  }

  // Hàm tải dữ liệu từ database
  Future<void> _taiDuLieu() async {
    final danhSach = await DBHelper.getTransactions();
    setState(() {
      _danhSachGiaoDich = danhSach;
      _dangTai = false;
    });
  }

  // Tính tổng số dư = tổng thu - tổng chi
  double get _tongSoDu {
    return _danhSachGiaoDich.fold(0, (tong, gd) {
      return gd.isIncome ? tong + gd.amount : tong - gd.amount;
    });
  }

  // Tính tổng thu trong tháng hiện tại
  double get _tongThuThang {
    final thangNay = DateTime.now();
    return _danhSachGiaoDich
        .where(
          (gd) =>
              gd.isIncome &&
              gd.date != null &&
              DateTime.parse(gd.date!).month == thangNay.month &&
              DateTime.parse(gd.date!).year == thangNay.year,
        )
        .fold(0, (tong, gd) => tong + gd.amount);
  }

  // Tính tổng chi trong tháng hiện tại
  double get _tongChiThang {
    final thangNay = DateTime.now();
    return _danhSachGiaoDich
        .where(
          (gd) =>
              !gd.isIncome &&
              gd.date != null &&
              DateTime.parse(gd.date!).month == thangNay.month &&
              DateTime.parse(gd.date!).year == thangNay.year,
        )
        .fold(0, (tong, gd) => tong + gd.amount);
  }

  // Lấy 5 giao dịch gần nhất để hiển thị
  List<GiaoDich> get _giaoDichGanDay {
    return _danhSachGiaoDich.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _dangTai
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              // Kéo xuống để tải lại dữ liệu
              onRefresh: _taiDuLieu,
              child: CustomScrollView(
                slivers: [
                  // ---- Phần tiêu đề trên cùng ----
                  SliverToBoxAdapter(child: _buildPhanTieuDe()),
                  // ---- Danh sách giao dịch gần đây ----
                  SliverToBoxAdapter(child: _buildDanhSachGiaoDich()),
                  // Khoảng cách ở dưới cùng (đủ để không bị che bởi bottom nav bar)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 80 + MediaQuery.of(context).padding.bottom,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Widget phần tiêu đề: chào người dùng + thẻ tổng quan
  Widget _buildPhanTieuDe() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dòng chào hỏi
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào, ${widget.user.name} 👋',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const Text(
                          'Tổng quan tài chính',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Thẻ hiển thị tổng số dư
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Tổng số dư',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_dinhDangSoTien(_tongSoDu)} đ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Hai ô Thu và Chi trong tháng
              Row(
                children: [
                  // Ô Thu
                  Expanded(
                    child: _buildOThuChi(
                      tieuDe: 'Thu tháng này',
                      soTien: _tongThuThang,
                      icon: Icons.arrow_downward_rounded,
                      mauNen: Colors.green.shade400,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Ô Chi
                  Expanded(
                    child: _buildOThuChi(
                      tieuDe: 'Chi tháng này',
                      soTien: _tongChiThang,
                      icon: Icons.arrow_upward_rounded,
                      mauNen: Colors.red.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget ô hiển thị Thu hoặc Chi
  Widget _buildOThuChi({
    required String tieuDe,
    required double soTien,
    required IconData icon,
    required Color mauNen,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: mauNen,
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tieuDe,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                Text(
                  '${_dinhDangSoTien(soTien)}đ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget danh sách giao dịch gần đây
  Widget _buildDanhSachGiaoDich() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Giao dịch gần đây',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),

          // Nếu không có giao dịch
          if (_giaoDichGanDay.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Chưa có giao dịch nào.\nHãy thêm giao dịch đầu tiên!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            // Hiển thị danh sách giao dịch
            ...(_giaoDichGanDay.map((gd) => _buildDongGiaoDich(gd))),
        ],
      ),
    );
  }

  // Widget một dòng giao dịch trong danh sách
  Widget _buildDongGiaoDich(GiaoDich gd) {
    final laThu = gd.isIncome;
    final mau = laThu ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon loại giao dịch
          CircleAvatar(
            radius: 22,
            backgroundColor: mau.withOpacity(0.1),
            child: Icon(
              laThu ? Icons.arrow_downward : Icons.arrow_upward,
              color: mau,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Ghi chú và danh mục
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gd.note ?? '(Không có ghi chú)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  gd.categoryName ?? 'Chưa phân loại',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          // Số tiền
          Text(
            '${laThu ? '+' : '-'}${_dinhDangSoTien(gd.amount)}đ',
            style: TextStyle(
              color: mau,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Định dạng số tiền: 1000000 → "1.000.000"
  String _dinhDangSoTien(double soTien) {
    return soTien
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}
