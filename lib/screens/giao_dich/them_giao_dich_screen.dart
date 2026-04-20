import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/transaction.dart';

// ============================================================
// Màn hình Thêm giao dịch mới
// Người dùng chọn: Thu/Chi, số tiền, danh mục, ví, ngày, ghi chú
// ============================================================
class ThemGiaoDichScreen extends StatefulWidget {
  const ThemGiaoDichScreen({super.key});

  @override
  State<ThemGiaoDichScreen> createState() => _ThemGiaoDichScreenState();
}

class _ThemGiaoDichScreenState extends State<ThemGiaoDichScreen>
    with SingleTickerProviderStateMixin {
  // Controller cho ô nhập số tiền và ghi chú
  final _soTienCtrl = TextEditingController();
  final _ghiChuCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Dữ liệu từ database
  List<DanhMuc> _danhSachDanhMuc = [];
  List<Vi> _danhSachVi = [];

  // Giá trị người dùng đã chọn
  String _loai = 'expense'; // 'income' = thu, 'expense' = chi
  DanhMuc? _danhMucDaChon;
  Vi? _viDaChon;
  DateTime _ngayDaChon = DateTime.now();
  bool _dangLuu = false;

  // Tab controller để chuyển giữa Thu và Chi
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _tabController.addListener(() {
      // Khi chuyển tab, cập nhật loại giao dịch và reset danh mục
      setState(() {
        _loai = _tabController.index == 0 ? 'income' : 'expense';
        _danhMucDaChon = null; // Reset danh mục khi đổi loại
      });
      _taiDanhMuc();
    });
    _taiDuLieu();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _soTienCtrl.dispose();
    _ghiChuCtrl.dispose();
    super.dispose();
  }

  // Tải danh mục và ví từ database
  Future<void> _taiDuLieu() async {
    await _taiDanhMuc();
    final danhSachVi = await DBHelper.getWallets();
    setState(() {
      _danhSachVi = danhSachVi;
      if (_danhSachVi.isNotEmpty) _viDaChon = _danhSachVi.first;
    });
  }

  // Tải danh mục theo loại (thu hoặc chi)
  Future<void> _taiDanhMuc() async {
    final danhSachDanhMuc = await DBHelper.getCategories(type: _loai);
    setState(() {
      _danhSachDanhMuc = danhSachDanhMuc;
    });
  }

  // Mở hộp thoại chọn ngày
  Future<void> _chonNgay() async {
    final ngay = await showDatePicker(
      context: context,
      initialDate: _ngayDaChon,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (ngay != null) setState(() => _ngayDaChon = ngay);
  }

  // Lưu giao dịch vào database
  Future<void> _luuGiaoDich() async {
    if (!_formKey.currentState!.validate()) return;
    if (_danhMucDaChon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn danh mục!')),
      );
      return;
    }
    if (_viDaChon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ví!')),
      );
      return;
    }

    setState(() => _dangLuu = true);

    // Tạo đối tượng giao dịch mới
    final giaoDichMoi = GiaoDich(
      amount: double.parse(_soTienCtrl.text.replaceAll('.', '')),
      type: _loai,
      categoryId: _danhMucDaChon!.id,
      walletId: _viDaChon!.id,
      note: _ghiChuCtrl.text.trim(),
      date: _ngayDaChon.toIso8601String(),
    );

    await DBHelper.insertTransaction(giaoDichMoi);
    setState(() => _dangLuu = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Đã thêm giao dịch thành công!'),
        backgroundColor: Colors.green,
      ),
    );

    // Xóa form sau khi lưu
    _soTienCtrl.clear();
    _ghiChuCtrl.clear();
    setState(() {
      _danhMucDaChon = null;
      _ngayDaChon = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Thêm giao dịch'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        elevation: 0,
        // Tab chuyển giữa Thu và Chi
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '💰 Thu nhập'),
            Tab(text: '💸 Chi tiêu'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---- Ô nhập số tiền ----
            _buildKhungInput(
              child: TextFormField(
                controller: _soTienCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'Số tiền (đ)',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.attach_money, color: Color(0xFF1A73E8)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập số tiền';
                  final soTien = double.tryParse(v.replaceAll('.', ''));
                  if (soTien == null || soTien <= 0) return 'Số tiền không hợp lệ';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 12),

            // ---- Chọn danh mục ----
            _buildKhungInput(
              child: DropdownButtonFormField<DanhMuc>(
                value: _danhMucDaChon,
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.category, color: Color(0xFF1A73E8)),
                ),
                items: _danhSachDanhMuc
                    .map((dm) => DropdownMenuItem(
                          value: dm,
                          child: Text(dm.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _danhMucDaChon = v),
                hint: const Text('Chọn danh mục'),
              ),
            ),
            const SizedBox(height: 12),

            // ---- Chọn ví ----
            _buildKhungInput(
              child: DropdownButtonFormField<Vi>(
                value: _viDaChon,
                decoration: const InputDecoration(
                  labelText: 'Ví tiền',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.account_balance_wallet, color: Color(0xFF1A73E8)),
                ),
                items: _danhSachVi
                    .map((vi) => DropdownMenuItem(
                          value: vi,
                          child: Text(vi.name ?? 'Ví không tên'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _viDaChon = v),
                hint: const Text('Chọn ví'),
              ),
            ),
            const SizedBox(height: 12),

            // ---- Chọn ngày ----
            _buildKhungInput(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: const Icon(Icons.calendar_today, color: Color(0xFF1A73E8)),
                title: const Text('Ngày giao dịch'),
                subtitle: Text(
                  '${_ngayDaChon.day}/${_ngayDaChon.month}/${_ngayDaChon.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                onTap: _chonNgay,
              ),
            ),
            const SizedBox(height: 12),

            // ---- Ghi chú ----
            _buildKhungInput(
              child: TextFormField(
                controller: _ghiChuCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú (tùy chọn)',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.note, color: Color(0xFF1A73E8)),
                ),
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 24),

            // ---- Nút Lưu ----
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _dangLuu ? null : _luuGiaoDich,
                icon: _dangLuu
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_dangLuu ? 'Đang lưu...' : 'Lưu giao dịch'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget bọc các ô nhập liệu với bo góc và nền trắng
  Widget _buildKhungInput({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
