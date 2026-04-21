import 'package:flutter/material.dart';
import '../../database/co_so_du_lieu.dart';
import '../../models/transaction.dart';

// ================================================================
// Màn hình Thêm / Sửa Danh mục
// Cho phép chọn tên, loại, icon, màu sắc
// ================================================================
class ThemSuaDanhMucScreen extends StatefulWidget {
  final DanhMuc? danhMuc;       // null → thêm mới, khác null → sửa
  final String? loaiMacDinh;    // 'thu' | 'chi'

  const ThemSuaDanhMucScreen({
    super.key,
    this.danhMuc,
    this.loaiMacDinh,
  });

  @override
  State<ThemSuaDanhMucScreen> createState() => _ThemSuaDanhMucScreenState();
}

class _ThemSuaDanhMucScreenState extends State<ThemSuaDanhMucScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tenController = TextEditingController();

  String _loai = 'chi';
  String _iconDangChon = 'category';
  String _mauDangChon = '#1A73E8';
  bool _dangLuu = false;
  bool get _laSua => widget.danhMuc != null;

  // Danh sách màu sắc có thể chọn
  static const List<Map<String, String>> _danhSachMau = [
    {'ten': 'Xanh dương', 'hex': '#1A73E8'},
    {'ten': 'Xanh lá', 'hex': '#34A853'},
    {'ten': 'Đỏ', 'hex': '#EA4335'},
    {'ten': 'Cam', 'hex': '#FF9800'},
    {'ten': 'Tím', 'hex': '#9C27B0'},
    {'ten': 'Hồng', 'hex': '#E91E63'},
    {'ten': 'Xanh ngọc', 'hex': '#00BCD4'},
    {'ten': 'Vàng', 'hex': '#FBBC05'},
    {'ten': 'Nâu', 'hex': '#795548'},
    {'ten': 'Xám xanh', 'hex': '#607D8B'},
    {'ten': 'Xanh navy', 'hex': '#3F51B5'},
    {'ten': 'Xanh ngọc lá', 'hex': '#009688'},
    {'ten': 'Hổ phách', 'hex': '#FF6F00'},
    {'ten': 'Hồng tím', 'hex': '#AD1457'},
    {'ten': 'Olive', 'hex': '#558B2F'},
    {'ten': 'Xanh trời', 'hex': '#0288D1'},
  ];

  // Danh sách icon có thể chọn
  static const List<Map<String, dynamic>> _danhSachIcon = [
    // Chi tiêu
    {'ten': 'Ăn uống', 'icon': 'restaurant', 'data': Icons.restaurant},
    {'ten': 'Di chuyển', 'icon': 'directions_car', 'data': Icons.directions_car},
    {'ten': 'Mua sắm', 'icon': 'shopping_cart', 'data': Icons.shopping_cart},
    {'ten': 'Nhà cửa', 'icon': 'home', 'data': Icons.home},
    {'ten': 'Y tế', 'icon': 'local_hospital', 'data': Icons.local_hospital},
    {'ten': 'Học tập', 'icon': 'school', 'data': Icons.school},
    {'ten': 'Giải trí', 'icon': 'sports_esports', 'data': Icons.sports_esports},
    {'ten': 'Du lịch', 'icon': 'flight', 'data': Icons.flight},
    {'ten': 'Thể thao', 'icon': 'fitness_center', 'data': Icons.fitness_center},
    {'ten': 'Cà phê', 'icon': 'local_cafe', 'data': Icons.local_cafe},
    {'ten': 'Điện thoại', 'icon': 'phone', 'data': Icons.phone},
    {'ten': 'Internet', 'icon': 'wifi', 'data': Icons.wifi},
    {'ten': 'Điện', 'icon': 'electric_bolt', 'data': Icons.electric_bolt},
    {'ten': 'Nước', 'icon': 'water_drop', 'data': Icons.water_drop},
    {'ten': 'Thú cưng', 'icon': 'pets', 'data': Icons.pets},
    {'ten': 'Phim ảnh', 'icon': 'movie', 'data': Icons.movie},
    {'ten': 'Âm nhạc', 'icon': 'music_note', 'data': Icons.music_note},
    {'ten': 'Thể dục', 'icon': 'sports', 'data': Icons.sports},
    {'ten': 'Thực phẩm', 'icon': 'local_grocery_store', 'data': Icons.local_grocery_store},
    // Thu nhập
    {'ten': 'Tiền mặt', 'icon': 'attach_money', 'data': Icons.attach_money},
    {'ten': 'Công việc', 'icon': 'work', 'data': Icons.work},
    {'ten': 'Kinh doanh', 'icon': 'business', 'data': Icons.business},
    {'ten': 'Quà tặng', 'icon': 'card_giftcard', 'data': Icons.card_giftcard},
    {'ten': 'Tiết kiệm', 'icon': 'savings', 'data': Icons.savings},
    {'ten': 'Đầu tư', 'icon': 'trending_up', 'data': Icons.trending_up},
    {'ten': 'Ngân hàng', 'icon': 'account_balance', 'data': Icons.account_balance},
  ];

  @override
  void initState() {
    super.initState();
    if (_laSua) {
      final dm = widget.danhMuc!;
      _tenController.text = dm.name;
      _loai = dm.type ?? 'chi';
      _iconDangChon = dm.icon ?? 'category';
      _mauDangChon = dm.color ?? '#1A73E8';
    } else {
      _loai = widget.loaiMacDinh ?? 'chi';
    }
  }

  @override
  void dispose() {
    _tenController.dispose();
    super.dispose();
  }

  Color get _mauHienTai {
    try {
      return Color(int.parse(_mauDangChon.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF1A73E8);
    }
  }

  IconData get _iconHienTai {
    final found = _danhSachIcon.firstWhere(
      (i) => i['icon'] == _iconDangChon,
      orElse: () => {'data': Icons.category},
    );
    return found['data'] as IconData;
  }

  Future<void> _luu() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _dangLuu = true);

    final dm = DanhMuc(
      id: widget.danhMuc?.id,
      name: _tenController.text.trim(),
      type: _loai,
      icon: _iconDangChon,
      color: _mauDangChon,
    );

    if (_laSua) {
      await CoSoDuLieu.capNhatDanhMuc(dm);
    } else {
      await CoSoDuLieu.themDanhMuc(dm);
    }

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(_laSua ? 'Đã cập nhật danh mục!' : 'Đã thêm danh mục mới!'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E), size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _laSua ? 'Chỉnh sửa danh mục' : 'Thêm danh mục',
          style: const TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Xem trước danh mục
              _buildXemTruoc(),
              const SizedBox(height: 24),

              // Tên danh mục
              _buildNhanSection('Tên danh mục'),
              const SizedBox(height: 8),
              _buildONhapTen(),
              const SizedBox(height: 24),

              // Loại
              _buildNhanSection('Loại danh mục'),
              const SizedBox(height: 8),
              _buildChonLoai(),
              const SizedBox(height: 24),

              // Chọn màu sắc
              _buildNhanSection('Màu sắc'),
              const SizedBox(height: 8),
              _buildChonMau(),
              const SizedBox(height: 24),

              // Chọn icon
              _buildNhanSection('Biểu tượng'),
              const SizedBox(height: 8),
              _buildChonIcon(),
              const SizedBox(height: 32),

              // Nút Lưu
              _buildNutLuu(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Phần xem trước danh mục
  Widget _buildXemTruoc() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _mauHienTai,
            _mauHienTai.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _mauHienTai.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(_iconHienTai, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tenController.text.isEmpty
                      ? 'Tên danh mục'
                      : _tenController.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _loai == 'thu' ? '↑ Thu nhập' : '↓ Chi tiêu',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNhanSection(String ten) {
    return Text(
      ten,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildONhapTen() {
    return TextFormField(
      controller: _tenController,
      decoration: InputDecoration(
        hintText: 'Nhập tên danh mục...',
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _mauHienTai.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.drive_file_rename_outline,
              color: _mauHienTai, size: 18),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _mauHienTai, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      onChanged: (_) => setState(() {}),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Vui lòng nhập tên danh mục';
        if (v.trim().length < 2) return 'Tên phải có ít nhất 2 ký tự';
        return null;
      },
    );
  }

  Widget _buildChonLoai() {
    return Row(
      children: [
        Expanded(child: _buildNutLoai('thu', 'Thu nhập', Icons.arrow_upward, Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildNutLoai('chi', 'Chi tiêu', Icons.arrow_downward, Colors.red)),
      ],
    );
  }

  Widget _buildNutLoai(String loai, String nhan, IconData icon, Color mau) {
    final laDangChon = _loai == loai;
    return GestureDetector(
      onTap: () => setState(() => _loai = loai),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: laDangChon ? mau : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: laDangChon ? mau : Colors.grey.shade200,
            width: laDangChon ? 2 : 1,
          ),
          boxShadow: laDangChon
              ? [
                  BoxShadow(
                    color: mau.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: laDangChon ? Colors.white : mau,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              nhan,
              style: TextStyle(
                color: laDangChon ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChonMau() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Màu đang chọn
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _mauHienTai,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _mauHienTai.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _danhSachMau.firstWhere(
                      (m) => m['hex'] == _mauDangChon,
                      orElse: () => {'ten': 'Tùy chỉnh'},
                    )['ten']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _mauDangChon.toUpperCase(),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Lưới màu
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: _danhSachMau.map((mau) {
              final hex = mau['hex']!;
              final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
              final laDangChon = _mauDangChon == hex;
              return GestureDetector(
                onTap: () => setState(() => _mauDangChon = hex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: laDangChon
                        ? Border.all(color: Colors.white, width: 2.5)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: laDangChon ? 0.6 : 0.3),
                        blurRadius: laDangChon ? 8 : 4,
                      ),
                    ],
                  ),
                  child: laDangChon
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChonIcon() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: _danhSachIcon.map((iconData) {
          final tenIcon = iconData['icon'] as String;
          final iconWidget = iconData['data'] as IconData;
          final laDangChon = _iconDangChon == tenIcon;

          return GestureDetector(
            onTap: () => setState(() => _iconDangChon = tenIcon),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: laDangChon
                    ? LinearGradient(
                        colors: [_mauHienTai, _mauHienTai.withValues(alpha: 0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: laDangChon ? null : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                boxShadow: laDangChon
                    ? [
                        BoxShadow(
                          color: _mauHienTai.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconWidget,
                    color: laDangChon ? Colors.white : Colors.grey.shade600,
                    size: 22,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    iconData['ten'] as String,
                    style: TextStyle(
                      fontSize: 8,
                      color: laDangChon ? Colors.white : Colors.grey.shade500,
                      fontWeight: laDangChon ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNutLuu() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _dangLuu ? null : _luu,
        style: ElevatedButton.styleFrom(
          backgroundColor: _mauHienTai,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: _mauHienTai.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _dangLuu
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_laSua ? Icons.save_outlined : Icons.add_circle_outline,
                      size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _laSua ? 'Lưu thay đổi' : 'Thêm danh mục',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
