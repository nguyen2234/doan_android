import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/transaction.dart';

// ============================================================
// Màn hình Quản lý Ví tiền – CRUD đầy đủ
//   • Thêm ví: nhấn nút FAB (+)
//   • Sửa / Xóa ví: nhấn đè (long press) vào thẻ ví
// ============================================================
class ViTienScreen extends StatefulWidget {
  const ViTienScreen({super.key});

  @override
  State<ViTienScreen> createState() => _ViTienScreenState();
}

class _ViTienScreenState extends State<ViTienScreen> {
  List<Vi> _danhSachVi = [];
  bool _dangTai = true;

  // Màu sắc xoay vòng cho từng ví
  final List<Color> _danhSachMau = [
    const Color(0xFF1A73E8),
    const Color(0xFF34A853),
    const Color(0xFFEA4335),
    const Color(0xFFFBBC05),
    const Color(0xFF9C27B0),
    const Color(0xFF00ACC1),
  ];

  // Icon xoay vòng cho từng ví
  final List<IconData> _danhSachIcon = [
    Icons.account_balance_wallet,
    Icons.account_balance,
    Icons.credit_card,
    Icons.savings,
    Icons.monetization_on,
    Icons.wallet,
  ];

  @override
  void initState() {
    super.initState();
    _taiDuLieu();
  }

  Future<void> _taiDuLieu() async {
    setState(() => _dangTai = true);
    final ds = await DBHelper.getWallets();
    setState(() {
      _danhSachVi = ds;
      _dangTai = false;
    });
  }

  // Tổng số dư tất cả ví
  double get _tongSoDu =>
      _danhSachVi.fold(0, (tong, vi) => tong + (vi.balance ?? 0));

  // ─────────────────────────────────────────────
  // THÊM VÍ
  // ─────────────────────────────────────────────
  void _moHopThoaiThemVi() {
    _hienHopThoaiVi(viHienTai: null);
  }

  // ─────────────────────────────────────────────
  // SỬA VÍ
  // ─────────────────────────────────────────────
  void _moHopThoaiSuaVi(Vi vi) {
    _hienHopThoaiVi(viHienTai: vi);
  }

  // ─────────────────────────────────────────────
  // HỘP THOẠI THÊM / SỬA (dùng chung)
  // ─────────────────────────────────────────────
  void _hienHopThoaiVi({Vi? viHienTai}) {
    final laSua = viHienTai != null;
    final tenCtrl = TextEditingController(text: viHienTai?.name ?? '');
    final soDuCtrl = TextEditingController(
        text: viHienTai != null
            ? (viHienTai.balance ?? 0).toStringAsFixed(0)
            : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              laSua ? Icons.edit_rounded : Icons.add_circle_rounded,
              color: const Color(0xFF1A73E8),
            ),
            const SizedBox(width: 8),
            Text(
              laSua ? 'Chỉnh sửa ví' : 'Thêm ví mới',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tenCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Tên ví',
                prefixIcon:
                    const Icon(Icons.account_balance_wallet_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF1A73E8), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: soDuCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: laSua ? 'Số dư hiện tại (đ)' : 'Số dư ban đầu (đ)',
                prefixIcon: const Icon(Icons.attach_money_rounded),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF1A73E8), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            icon: Icon(laSua ? Icons.save_rounded : Icons.add_rounded,
                size: 18),
            label: Text(laSua ? 'Lưu' : 'Thêm'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final ten = tenCtrl.text.trim();
              if (ten.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('⚠️ Vui lòng nhập tên ví!')),
                );
                return;
              }
              final soDu =
                  double.tryParse(soDuCtrl.text.replaceAll(',', '')) ?? 0;

              if (laSua) {
                // CẬP NHẬT
                final viMoi = Vi(
                  id: viHienTai.id,
                  name: ten,
                  balance: soDu,
                  createdAt: viHienTai.createdAt,
                );
                await DBHelper.updateWallet(viMoi);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _taiDuLieu();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('✅ Đã cập nhật ví thành công!')),
                );
              } else {
                // THÊM MỚI
                final viMoi = Vi(
                  name: ten,
                  balance: soDu,
                  createdAt: DateTime.now().toIso8601String(),
                );
                await DBHelper.insertWallet(viMoi);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _taiDuLieu();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Đã thêm ví thành công!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // XÓA VÍ
  // ─────────────────────────────────────────────
  Future<void> _xoaVi(Vi vi) async {
    final xacNhan = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Xóa ví tiền',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 14),
            children: [
              const TextSpan(text: 'Bạn có chắc muốn xóa ví '),
              TextSpan(
                text: '"${vi.name}"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '?\n\nHành động này không thể hoàn tác.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_rounded, size: 18),
            label: const Text('Xóa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (xacNhan == true && vi.id != null) {
      await DBHelper.deleteWallet(vi.id!);
      _taiDuLieu();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🗑️ Đã xóa ví "${vi.name}"')),
      );
    }
  }

  // ─────────────────────────────────────────────
  // POPUP KHI NHẤN ĐÈ (long press)
  // ─────────────────────────────────────────────
  void _hienMenuNhanDe(BuildContext context, Vi vi, Offset viTri) async {
    final lua = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        viTri.dx,
        viTri.dy,
        viTri.dx + 1,
        viTri.dy + 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 8,
      items: [
        PopupMenuItem(
          value: 'sua',
          child: Row(
            children: const [
              Icon(Icons.edit_rounded, color: Color(0xFF1A73E8), size: 20),
              SizedBox(width: 10),
              Text('Chỉnh sửa ví',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'xoa',
          child: Row(
            children: const [
              Icon(Icons.delete_rounded, color: Colors.red, size: 20),
              SizedBox(width: 10),
              Text('Xóa ví',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );

    if (lua == 'sua') {
      _moHopThoaiSuaVi(vi);
    } else if (lua == 'xoa') {
      _xoaVi(vi);
    }
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Ví tiền',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _taiDuLieu,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _moHopThoaiThemVi,
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm ví'),
        elevation: 4,
      ),
      body: _dangTai
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _taiDuLieu,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  // ── Thẻ tổng số dư ──
                  _buildTheTongSoDu(),
                  const SizedBox(height: 20),

                  // ── Tiêu đề danh sách ──
                  Row(
                    children: [
                      const Text(
                        'Danh sách ví',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A73E8).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_danhSachVi.length}',
                          style: const TextStyle(
                            color: Color(0xFF1A73E8),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Gợi ý nhấn đè
                  const Text(
                    'Nhấn đè vào ví để sửa hoặc xóa',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 12),

                  // ── Danh sách ──
                  if (_danhSachVi.isEmpty)
                    _buildTrangRong()
                  else
                    ...(_danhSachVi.asMap().entries.map((entry) {
                      final mau = _danhSachMau[entry.key % _danhSachMau.length];
                      final icon =
                          _danhSachIcon[entry.key % _danhSachIcon.length];
                      return _buildTheDongVi(entry.value, mau, icon);
                    })),
                ],
              ),
            ),
    );
  }

  // ── Thẻ tổng số dư ──
  Widget _buildTheTongSoDu() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.account_balance_wallet_rounded,
              color: Colors.white54, size: 32),
          const SizedBox(height: 8),
          const Text('Tổng tài sản',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            '${_dinhDangSoTien(_tongSoDu)} đ',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            '${_danhSachVi.length} ví tiền',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Trang rỗng ──
  Widget _buildTrangRong() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Chưa có ví nào',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Nhấn nút "Thêm ví" để tạo ví mới!',
              style: TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Thẻ từng ví ──
  Widget _buildTheDongVi(Vi vi, Color mau, IconData icon) {
    final phanTram =
        _tongSoDu > 0 ? (vi.balance ?? 0) / _tongSoDu : 0.0;

    return GestureDetector(
      // Nhấn đè → hiện popup Sửa/Xóa
      onLongPressStart: (detail) =>
          _hienMenuNhanDe(context, vi, detail.globalPosition),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: mau.withValues(alpha: 0.15), width: 1.5),
        ),
        child: Row(
          children: [
            // Icon ví
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: mau.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: mau, size: 28),
            ),
            const SizedBox(width: 14),

            // Thông tin ví
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vi.name ?? 'Ví không tên',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: phanTram.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(mau),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(phanTram * 100).toStringAsFixed(1)}% tổng tài sản',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Số dư + gợi ý nhấn đè
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_dinhDangSoTien(vi.balance ?? 0)}đ',
                  style: TextStyle(
                    color: mau,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.touch_app_rounded,
                        size: 11, color: Colors.grey.shade400),
                    const SizedBox(width: 2),
                    Text(
                      'Nhấn đè',
                      style: TextStyle(
                          fontSize: 10, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
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
