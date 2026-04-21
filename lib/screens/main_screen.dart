import 'package:flutter/material.dart';
import '../models/user.dart';

// Import các màn hình con
import 'home/home_screen.dart';
import 'giao_dich/them_giao_dich_screen.dart';
import 'vi_tien/vi_tien_screen.dart';
import 'bao_cao/bao_cao_screen.dart';
import 'profile/profile_screen.dart';

// ============================================================
// Màn hình chính - chứa thanh điều hướng dưới cùng (Bottom Navigation)
// Đây là màn hình bọc ngoài, quản lý việc chuyển đổi giữa các tab
// ============================================================
class MainScreen extends StatefulWidget {
  final User user; // Người dùng đang đăng nhập

  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Tab đang được chọn (bắt đầu từ tab Trang chủ = 0)
  int _tabDangChon = 0;

  // Hàm điều hướng sang màn hình Thêm giao dịch (nút + ở giữa)
  void _moThemGiaoDich() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ThemGiaoDichScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Danh sách các màn hình tương ứng với từng tab
    // Chú ý: tab index 2 (Thêm) không có màn hình vì sẽ mở như dialog
    final List<Widget> cacManHinh = [
      HomeScreen(user: widget.user),
      const ViTienScreen(),
      const BaoCaoScreen(),
      ProfileScreen(user: widget.user),
    ];

    int indexManHinh = _tabDangChon < 2 ? _tabDangChon : _tabDangChon - 1;

    return Scaffold(
      // Hiển thị màn hình tương ứng với tab đang chọn
      body: cacManHinh[indexManHinh],

      // ---- Thanh điều hướng dưới cùng ----
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        height: 64,
        padding: EdgeInsets.zero,
        shape: const CircularNotchedRectangle(), // Tạo khoảng lõm cho nút +
        notchMargin: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tab 0: Trang chủ
              _buildNutTab(
                icon: Icons.home_outlined,
                iconDaChon: Icons.home,
                nhanVien: 'Trang chủ',
                tabIndex: 0,
              ),
              // Tab 1: Ví tiền
              _buildNutTab(
                icon: Icons.account_balance_wallet_outlined,
                iconDaChon: Icons.account_balance_wallet,
                nhanVien: 'Ví tiền',
                tabIndex: 1,
              ),

              // Khoảng trống cho nút FAB (+) ở giữa
              const SizedBox(width: 56),

              _buildNutTab(
                icon: Icons.bar_chart_outlined,
                iconDaChon: Icons.bar_chart,
                nhanVien: 'Báo cáo',
                tabIndex: 3,
              ),
              _buildNutTab(
                icon: Icons.person_outline,
                iconDaChon: Icons.person,
                nhanVien: 'Hồ sơ',
                tabIndex: 4,
              ),
            ],
          ),
        ),
      ),

      // ---- Nút thêm giao dịch (+) nổi ở giữa ----
      floatingActionButton: FloatingActionButton(
        onPressed: _moThemGiaoDich,
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // Widget một nút tab trong thanh điều hướng
  Widget _buildNutTab({
    required IconData icon,
    required IconData iconDaChon,
    required String nhanVien,
    required int tabIndex,
  }) {
    final laDaChon = _tabDangChon == tabIndex;

    return InkWell(
      onTap: () => setState(() => _tabDangChon = tabIndex),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              laDaChon ? iconDaChon : icon,
              color: laDaChon ? const Color(0xFF1A73E8) : Colors.grey,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              nhanVien,
              style: TextStyle(
                fontSize: 10,
                color: laDaChon ? const Color(0xFF1A73E8) : Colors.grey,
                fontWeight: laDaChon ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
