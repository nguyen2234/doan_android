// ============================================================
// File: main.dart
// Đây là file khởi động chính của ứng dụng Flutter.
// Mọi ứng dụng Flutter đều bắt đầu từ hàm main().
// ============================================================

import 'package:flutter/material.dart';

// Import các màn hình (screens) mà chúng ta sẽ tạo
import 'screens/trang_chu_screen.dart';
import 'screens/thong_ke_screen.dart';

// Hàm main() là điểm khởi đầu của ứng dụng Dart/Flutter
void main() {
  // runApp() khởi chạy ứng dụng với widget gốc là MyApp
  runApp(const MyApp());
}

// MyApp là widget gốc của toàn bộ ứng dụng.
// StatelessWidget: Widget không có trạng thái thay đổi (không cần setState)
class MyApp extends StatelessWidget {
  // Constructor với key - Flutter dùng key để nhận diện widget
  const MyApp({super.key});

  // Phương thức build() mô tả giao diện của widget này
  @override
  Widget build(BuildContext context) {
    // MaterialApp là widget khung ứng dụng theo phong cách Material Design
    return MaterialApp(
      // Tiêu đề ứng dụng (hiển thị trên task switcher của điện thoại)
      title: 'Expense Wise - Quản Lý Chi Tiêu',

      // debugShowCheckedModeBanner: false => Ẩn dải băng "DEBUG" ở góc màn hình
      debugShowCheckedModeBanner: false,

      // theme: Định nghĩa màu sắc và kiểu chữ chung cho toàn ứng dụng
      theme: ThemeData(
        // useMaterial3: true => Sử dụng phiên bản Material Design 3 (mới nhất)
        useMaterial3: true,

        // colorScheme: Bảng màu chính của ứng dụng
        // Tông màu teal (xanh ngọc) theo thiết kế Figma
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D7A6B), // Màu teal chủ đạo
        ),

        // fontFamily: Font chữ mặc định cho toàn ứng dụng
        fontFamily: 'Roboto',
      ),

      // home: Màn hình đầu tiên hiển thị khi mở ứng dụng
      // Chúng ta dùng widget KhungChinh để quản lý điều hướng bằng bottom nav
      home: const KhungChinh(),
    );
  }
}

// ============================================================
// KhungChinh: Widget quản lý điều hướng (Navigation) chính
// Đây là StatefulWidget vì nó có trạng thái thay đổi:
//   - Người dùng bấm vào tab nào thì hiển thị màn hình đó
// ============================================================
class KhungChinh extends StatefulWidget {
  const KhungChinh({super.key});

  @override
  State<KhungChinh> createState() => _KhungChinhState();
}

class _KhungChinhState extends State<KhungChinh> {
  // Biến lưu chỉ số của tab đang được chọn (0 = Trang Chủ, 1 = Thống Kê)
  // Ban đầu ứng dụng mở vào tab 0 (Trang Chủ)
  int _tabDangChon = 0;

  // Danh sách các màn hình tương ứng với từng tab
  // Import thêm StatisticsScreen ở đây khi cần
  final List<Widget> _danhSachManHinh = [
    // Tab 0: Màn hình Trang Chủ
    const TrangChuScreen(),
    // Tab 1: Màn hình Thống Kê
    const ThongKeScreen(),
    // Tab 2: Placeholder cho nút thêm giao dịch (hiện chưa làm)
    const Scaffold(body: Center(child: Text('Thêm giao dịch'))),
    // Tab 3: Placeholder cho màn hình Ví
    const Scaffold(body: Center(child: Text('Ví của tôi'))),
    // Tab 4: Placeholder cho màn hình Hồ sơ
    const Scaffold(body: Center(child: Text('Hồ sơ cá nhân'))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: Hiển thị màn hình tương ứng với tab đang chọn
      body: _danhSachManHinh[_tabDangChon],

      // bottomNavigationBar: Thanh điều hướng phía dưới màn hình
      bottomNavigationBar: BottomNavigationBar(
        // currentIndex: Tab nào đang được chọn
        currentIndex: _tabDangChon,

        // onTap: Gọi hàm này khi người dùng bấm vào một tab
        onTap: (int chiSoTab) {
          // setState() báo cho Flutter biết cần vẽ lại giao diện
          setState(() {
            _tabDangChon = chiSoTab;
          });
        },

        // Màu của item khi được chọn
        selectedItemColor: const Color(0xFF2D7A6B),

        // Màu của item khi không được chọn
        unselectedItemColor: Colors.grey,

        // Kiểu hiển thị: Luôn hiển thị label cho tất cả item
        type: BottomNavigationBarType.fixed,

        // Danh sách các item trong thanh điều hướng
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),       // Icon chưa chọn
            activeIcon: Icon(Icons.home),           // Icon khi đang chọn
            label: 'Trang Chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Thống Kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Thêm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Ví',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Hồ Sơ',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ThongKeScreen được import từ file khác nhưng placeholder ở đây
// để main.dart có thể biết về nó ngay từ đầu.
// Sẽ được thay thế bằng file thực tế.
// ============================================================
// (Import sẽ được thêm bên dưới khi chạy app)
