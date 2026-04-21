import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../database/db_helper.dart';
import '../../models/user.dart';

// ============================================================
// Màn hình Chỉnh sửa hồ sơ cá nhân
// Cho phép sửa tên, mật khẩu và ảnh đại diện
// (Tách ra để profile_screen.dart làm trang danh mục chính)
// ============================================================
class ChinhSuaHoSoScreen extends StatefulWidget {
  final User user; // Thông tin người dùng hiện tại

  const ChinhSuaHoSoScreen({super.key, required this.user});

  @override
  State<ChinhSuaHoSoScreen> createState() => _ChinhSuaHoSoScreenState();
}

class _ChinhSuaHoSoScreenState extends State<ChinhSuaHoSoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller để quản lý nội dung ô nhập liệu
  late final _tenCtrl = TextEditingController(text: widget.user.name);
  final _matKhauCtrl = TextEditingController();

  bool _anMatKhau = true; // Ẩn/hiện mật khẩu
  bool _dangLuu = false;  // Trạng thái đang lưu
  String? _duongDanAnh;   // Đường dẫn ảnh đại diện mới

  @override
  void initState() {
    super.initState();
    _duongDanAnh = widget.user.avatar; // Lấy ảnh hiện tại
  }

  @override
  void dispose() {
    _tenCtrl.dispose();
    _matKhauCtrl.dispose();
    super.dispose();
  }

  // Mở thư viện ảnh để chọn ảnh đại diện mới
  Future<void> _chonAnh() async {
    final picker = ImagePicker();
    final anhDaChon = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (anhDaChon != null) {
      setState(() => _duongDanAnh = anhDaChon.path);
    }
  }

  // Lưu thông tin đã chỉnh sửa vào database
  Future<void> _luu() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _dangLuu = true);

    // Tạo object user mới với thông tin đã sửa
    final userCapNhat = widget.user.copyWith(
      name: _tenCtrl.text.trim(),
      password: _matKhauCtrl.text.isNotEmpty ? _matKhauCtrl.text : null,
      avatar: _duongDanAnh,
    );

    await DBHelper.updateUser(userCapNhat);
    setState(() => _dangLuu = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Cập nhật thông tin thành công!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context, userCapNhat); // Trả User mới về ProfileScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ---- Ảnh đại diện ----
            Center(
              child: GestureDetector(
                onTap: _chonAnh,
                child: Stack(
                  children: [
                    // Ảnh đại diện hiện tại
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: const Color(0xFF1A73E8).withValues(alpha: 0.1),
                      backgroundImage: _duongDanAnh != null
                          ? FileImage(File(_duongDanAnh!))
                          : null,
                      child: _duongDanAnh == null
                          ? const Icon(Icons.person, size: 55, color: Color(0xFF1A73E8))
                          : null,
                    ),
                    // Nút camera nhỏ ở góc
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF1A73E8),
                        child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Nhấn vào ảnh để thay đổi',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 28),

            // ---- Ô Email (chỉ đọc, không sửa được) ----
            _buildKhungInput(
              child: TextFormField(
                initialValue: widget.user.email,
                readOnly: true, // Email không cho sửa
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF1A73E8)),
                  suffixIcon: Icon(Icons.lock_outline, color: Colors.grey, size: 18),
                ),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 12),

            // ---- Ô Họ tên ----
            _buildKhungInput(
              child: TextFormField(
                controller: _tenCtrl,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.person_outline, color: Color(0xFF1A73E8)),
                ),
                validator: (v) => v!.isNotEmpty ? null : 'Vui lòng nhập tên',
              ),
            ),
            const SizedBox(height: 12),

            // ---- Ô Mật khẩu mới ----
            _buildKhungInput(
              child: TextFormField(
                controller: _matKhauCtrl,
                obscureText: _anMatKhau,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu mới (bỏ trống nếu không đổi)',
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1A73E8)),
                  // Nút ẩn/hiện mật khẩu
                  suffixIcon: IconButton(
                    icon: Icon(_anMatKhau ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _anMatKhau = !_anMatKhau),
                  ),
                ),
                validator: (v) =>
                    v!.isEmpty || v.length >= 6 ? null : 'Mật khẩu tối thiểu 6 ký tự',
              ),
            ),
            const SizedBox(height: 28),

            // ---- Nút Lưu ----
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _dangLuu ? null : _luu,
                icon: _dangLuu
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_dangLuu ? 'Đang lưu...' : 'Lưu thay đổi'),
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

  // Widget bọc ô nhập liệu với nền trắng và bo góc
  Widget _buildKhungInput({required Widget child}) {
    return Container(
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
      child: child,
    );
  }
}
