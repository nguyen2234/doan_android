import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/transaction.dart';

// ============================================================
// Màn hình Quản lý Ví tiền
// Hiển thị danh sách các ví và số dư của từng ví
// ============================================================
class ViTienScreen extends StatefulWidget {
  const ViTienScreen({super.key});

  @override
  State<ViTienScreen> createState() => _ViTienScreenState();
}

class _ViTienScreenState extends State<ViTienScreen> {
  List<Vi> _danhSachVi = []; // Danh sách ví
  bool _dangTai = true;

  // Màu sắc và icon cho từng ví (theo thứ tự)
  final List<Color> _danhSachMau = [
    const Color(0xFF1A73E8),
    const Color(0xFF34A853),
    const Color(0xFFEA4335),
    const Color(0xFFFBBC05),
    const Color(0xFF9C27B0),
  ];

  final List<IconData> _danhSachIcon = [
    Icons.account_balance_wallet,
    Icons.account_balance,
    Icons.credit_card,
    Icons.savings,
    Icons.monetization_on,
  ];

  @override
  void initState() {
    super.initState();
    _taiDuLieu();
  }

  Future<void> _taiDuLieu() async {
    final danhSachVi = await DBHelper.getWallets();
    setState(() {
      _danhSachVi = danhSachVi;
      _dangTai = false;
    });
  }

  // Tính tổng số dư của tất cả ví
  double get _tongSoDu {
    return _danhSachVi.fold(0, (tong, vi) => tong + (vi.balance ?? 0));
  }

  // Mở hộp thoại thêm ví mới
  void _moHopThoaiThemVi() {
    final tenCtrl = TextEditingController();
    final soDuCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm ví mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tenCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên ví',
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: soDuCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số dư ban đầu (đ)',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (tenCtrl.text.trim().isEmpty) return;
              // TODO: Thêm hàm insertWallet vào DBHelper để lưu ví mới
              // Hiện tại chỉ thông báo thành công (chưa lưu vào DB)
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Đã thêm ví thành công!')),
              );
              _taiDuLieu();
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Ví tiền'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // Nút thêm ví mới
      floatingActionButton: FloatingActionButton(
        onPressed: _moHopThoaiThemVi,
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: _dangTai
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _taiDuLieu,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ---- Thẻ tổng số dư tất cả ví ----
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Tổng tài sản',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_dinhDangSoTien(_tongSoDu)} đ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_danhSachVi.length} ví tiền',
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  // ---- Tiêu đề danh sách ----
                  const Text(
                    'Danh sách ví',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ---- Danh sách từng ví ----
                  if (_danhSachVi.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Chưa có ví nào.\nNhấn + để thêm ví mới!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...(_danhSachVi.asMap().entries.map((entry) {
                      final viTri = entry.key;
                      final vi = entry.value;
                      // Chọn màu và icon theo vị trí (vòng lặp nếu có nhiều ví)
                      final mau = _danhSachMau[viTri % _danhSachMau.length];
                      final icon = _danhSachIcon[viTri % _danhSachIcon.length];
                      return _buildTheDongVi(vi, mau, icon);
                    })),
                ],
              ),
            ),
    );
  }

  // Widget hiển thị một ví trong danh sách
  Widget _buildTheDongVi(Vi vi, Color mau, IconData icon) {
    // Tính phần trăm của ví này so với tổng
    final phanTram = _tongSoDu > 0 ? (vi.balance ?? 0) / _tongSoDu : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Icon ví
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: mau.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: mau, size: 26),
          ),
          const SizedBox(width: 14),

          // Tên ví và thanh progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vi.name ?? 'Ví không tên',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                // Thanh hiển thị % số dư so với tổng
                LinearProgressIndicator(
                  value: phanTram.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade200,
                  color: mau,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(phanTram * 100).toStringAsFixed(1)}% tổng tài sản',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Số dư
          Text(
            '${_dinhDangSoTien(vi.balance ?? 0)}đ',
            style: TextStyle(
              color: mau,
              fontWeight: FontWeight.bold,
              fontSize: 15,
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
