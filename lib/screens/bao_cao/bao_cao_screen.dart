import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/transaction.dart';

// ============================================================
// Màn hình Báo cáo thống kê
// Hiển thị: Tổng thu/chi theo tháng, Top danh mục chi tiêu
// ============================================================
class BaoCaoScreen extends StatefulWidget {
  const BaoCaoScreen({super.key});

  @override
  State<BaoCaoScreen> createState() => _BaoCaoScreenState();
}

class _BaoCaoScreenState extends State<BaoCaoScreen> {
  List<GiaoDich> _danhSachGiaoDich = [];
  bool _dangTai = true;

  // Tháng/năm đang xem báo cáo
  int _thangDangXem = DateTime.now().month;
  int _namDangXem = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _taiDuLieu();
  }

  Future<void> _taiDuLieu() async {
    final danhSach = await DBHelper.getTransactions();
    setState(() {
      _danhSachGiaoDich = danhSach;
      _dangTai = false;
    });
  }

  // Lọc giao dịch theo tháng/năm đang xem
  List<GiaoDich> get _giaoDichTheoThang {
    return _danhSachGiaoDich.where((gd) {
      if (gd.date == null) return false;
      final ngay = DateTime.parse(gd.date!);
      return ngay.month == _thangDangXem && ngay.year == _namDangXem;
    }).toList();
  }

  // Tính tổng thu trong tháng
  double get _tongThu {
    return _giaoDichTheoThang
        .where((gd) => gd.isIncome)
        .fold(0, (tong, gd) => tong + gd.amount);
  }

  // Tính tổng chi trong tháng
  double get _tongChi {
    return _giaoDichTheoThang
        .where((gd) => !gd.isIncome)
        .fold(0, (tong, gd) => tong + gd.amount);
  }

  // Nhóm giao dịch theo danh mục và tính tổng tiền mỗi danh mục
  Map<String, double> get _chiTieuTheoNhom {
    final Map<String, double> nhom = {};
    for (final gd in _giaoDichTheoThang.where((gd) => !gd.isIncome)) {
      final tenDanhMuc = gd.categoryName ?? 'Khác';
      nhom[tenDanhMuc] = (nhom[tenDanhMuc] ?? 0) + gd.amount;
    }
    // Sắp xếp từ cao đến thấp
    final danhSachSapXep = nhom.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(danhSachSapXep);
  }

  // Chuyển sang tháng trước
  void _thangTruoc() {
    setState(() {
      if (_thangDangXem == 1) {
        _thangDangXem = 12;
        _namDangXem--;
      } else {
        _thangDangXem--;
      }
    });
  }

  // Chuyển sang tháng sau
  void _thangSau() {
    final thangSauDate = DateTime(_namDangXem, _thangDangXem + 1);
    final hienTai = DateTime.now();
    // Không cho xem tháng tương lai
    if (thangSauDate.isAfter(DateTime(hienTai.year, hienTai.month))) return;

    setState(() {
      if (_thangDangXem == 12) {
        _thangDangXem = 1;
        _namDangXem++;
      } else {
        _thangDangXem++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chiTieuNhom = _chiTieuTheoNhom;
    final tongChiTiet = chiTieuNhom.values.fold(0.0, (t, v) => t + v);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Báo cáo'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _dangTai
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _taiDuLieu,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                children: [
                  // ---- Điều hướng tháng ----
                  _buildDieuHuongThang(),
                  const SizedBox(height: 16),

                  // ---- Thẻ tóm tắt Thu/Chi ----
                  _buildTheTomTat(),
                  const SizedBox(height: 20),

                  // ---- Số dư cuối tháng ----
                  _buildSoDuCuoiThang(),
                  const SizedBox(height: 20),

                  // ---- Chi tiết theo danh mục ----
                  const Text(
                    'Chi tiêu theo danh mục',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (chiTieuNhom.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Không có chi tiêu trong tháng này.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...(chiTieuNhom.entries.toList().asMap().entries.map((entry) {
                      final viTri = entry.key;
                      final dongDuLieu = entry.value;
                      return _buildDongDanhMuc(
                        viTri: viTri,
                        tenDanhMuc: dongDuLieu.key,
                        soTien: dongDuLieu.value,
                        tongSoTien: tongChiTiet,
                      );
                    })),
                ],
              ),
            ),
    );
  }

  // Widget điều hướng chọn tháng (trái/phải)
  Widget _buildDieuHuongThang() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _thangTruoc,
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            'Tháng $_thangDangXem/$_namDangXem',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: _thangSau,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  // Widget thẻ tóm tắt Thu và Chi
  Widget _buildTheTomTat() {
    return Row(
      children: [
        // Ô thu
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(Icons.arrow_downward, color: Colors.green, size: 14),
                    ),
                    const SizedBox(width: 8),
                    const Text('Tổng thu', style: TextStyle(color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${_dinhDangSoTien(_tongThu)}đ',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Ô chi
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.red.shade100,
                      child: const Icon(Icons.arrow_upward, color: Colors.red, size: 14),
                    ),
                    const SizedBox(width: 8),
                    const Text('Tổng chi', style: TextStyle(color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${_dinhDangSoTien(_tongChi)}đ',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget hiển thị số dư cuối tháng (thu - chi)
  Widget _buildSoDuCuoiThang() {
    final soDuCuoiThang = _tongThu - _tongChi;
    final laDuong = soDuCuoiThang >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '📊 Số dư cuối tháng',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Text(
            '${laDuong ? '+' : ''}${_dinhDangSoTien(soDuCuoiThang)}đ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: laDuong ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // Màu sắc cho từng danh mục
  static const List<Color> _danhSachMau = [
    Color(0xFF1A73E8),
    Color(0xFFEA4335),
    Color(0xFF34A853),
    Color(0xFFFBBC05),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
  ];

  // Widget hiển thị một danh mục trong báo cáo
  Widget _buildDongDanhMuc({
    required int viTri,
    required String tenDanhMuc,
    required double soTien,
    required double tongSoTien,
  }) {
    final mau = _danhSachMau[viTri % _danhSachMau.length];
    // Tính phần trăm của danh mục này
    final phanTram = tongSoTien > 0 ? soTien / tongSoTien : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Chấm màu + tên danh mục
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: mau, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tenDanhMuc,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
              // Số tiền và phần trăm
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_dinhDangSoTien(soTien)}đ',
                    style: TextStyle(color: mau, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${(phanTram * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Thanh progress
          LinearProgressIndicator(
            value: phanTram.clamp(0.0, 1.0),
            backgroundColor: Colors.grey.shade200,
            color: mau,
            borderRadius: BorderRadius.circular(4),
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
