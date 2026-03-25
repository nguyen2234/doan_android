// ============================================================
// File: models/giao_dich.dart
// Đây là file định nghĩa "Model" (mô hình dữ liệu) cho Giao Dịch.
// Model là lớp đại diện cho một đối tượng dữ liệu trong ứng dụng.
// Trong tương lai, dữ liệu này sẽ lấy từ cơ sở dữ liệu SQLite.
// ============================================================

import 'package:flutter/material.dart';

// ============================================================
// Lớp GiaoDich: Đại diện cho một giao dịch tài chính
// ============================================================
class GiaoDich {
  // Tên của giao dịch (ví dụ: "Upwork", "Ăn sáng", "Sách vở")
  final String tenGiaoDich;

  // Số tiền của giao dịch (dương = thu nhập, âm = chi tiêu)
  final double soTien;

  // Ngày thực hiện giao dịch
  final String ngayGiaoDich;

  // Danh mục: ví dụ "Thu nhập", "Ăn uống", "Học tập"
  final String danhMuc;

  // Icon đại diện cho danh mục của giao dịch
  final IconData iconDanhMuc;

  // Màu nền của icon
  final Color mauNen;

  // Constructor: Hàm khởi tạo đối tượng GiaoDich
  // required: Các tham số bắt buộc phải truyền vào
  const GiaoDich({
    required this.tenGiaoDich,
    required this.soTien,
    required this.ngayGiaoDich,
    required this.danhMuc,
    required this.iconDanhMuc,
    required this.mauNen,
  });

  // Thuộc tính kiểm tra xem đây là thu nhập hay chi tiêu
  // Nếu soTien > 0 thì là thu nhập, ngược lại là chi tiêu
  bool get laThuNhap => soTien > 0;
}

// ============================================================
// DuLieuMau: Lớp chứa dữ liệu mẫu (sample data) để hiển thị giao diện
// Khi chưa có database, chúng ta dùng dữ liệu mẫu này để test giao diện
// ============================================================
class DuLieuMau {
  // Danh sách các giao dịch mẫu
  static const List<GiaoDich> danhSachGiaoDich = [
    GiaoDich(
      tenGiaoDich: 'Làm thêm Upwork',
      soTien: 850000,          // Dương = Thu nhập
      ngayGiaoDich: 'Hôm nay',
      danhMuc: 'Thu nhập',
      iconDanhMuc: Icons.work_outline,
      mauNen: Color(0xFFE8F5E9), // Màu xanh lá nhạt
    ),
    GiaoDich(
      tenGiaoDich: 'Trả tiền vay',
      soTien: -850000,          // Âm = Chi tiêu
      ngayGiaoDich: 'Hôm qua',
      danhMuc: 'Chuyển khoản',
      iconDanhMuc: Icons.swap_horiz,
      mauNen: Color(0xFFFFEBEE), // Màu đỏ nhạt
    ),
    GiaoDich(
      tenGiaoDich: 'Nhận lương tháng 3',
      soTien: 14060000,
      ngayGiaoDich: '20/03/2025',
      danhMuc: 'Thu nhập',
      iconDanhMuc: Icons.payments_outlined,
      mauNen: Color(0xFFE8F5E9),
    ),
    GiaoDich(
      tenGiaoDich: 'Đăng ký YouTube Premium',
      soTien: -59000,
      ngayGiaoDich: '16/03/2025',
      danhMuc: 'Giải trí',
      iconDanhMuc: Icons.play_circle_outline,
      mauNen: Color(0xFFFFEBEE),
    ),
    GiaoDich(
      tenGiaoDich: 'Mua sách lập trình',
      soTien: -220000,
      ngayGiaoDich: '12/03/2025',
      danhMuc: 'Học tập',
      iconDanhMuc: Icons.menu_book_outlined,
      mauNen: Color(0xFFE3F2FD), // Màu xanh dương nhạt
    ),
    GiaoDich(
      tenGiaoDich: 'Ăn sáng cà phê',
      soTien: -45000,
      ngayGiaoDich: '10/03/2025',
      danhMuc: 'Ăn uống',
      iconDanhMuc: Icons.coffee_outlined,
      mauNen: Color(0xFFFFF3E0), // Màu cam nhạt
    ),
  ];

  // Tổng thu nhập: Lọc các giao dịch có soTien > 0 và cộng lại
  static double get tongThuNhap {
    // where: Lọc phần tử thỏa điều kiện
    // fold: Tính tổng từ giá trị ban đầu là 0
    return danhSachGiaoDich
        .where((giaoDich) => giaoDich.soTien > 0)
        .fold(0.0, (tongCong, giaoDich) => tongCong + giaoDich.soTien);
  }

  // Tổng chi tiêu: Lọc các giao dịch có soTien < 0 và tính giá trị tuyệt đối
  static double get tongChiTieu {
    return danhSachGiaoDich
        .where((giaoDich) => giaoDich.soTien < 0)
        .fold(0.0, (tongCong, giaoDich) => tongCong + giaoDich.soTien.abs());
  }

  // Số dư hiện tại = Tổng thu nhập - Tổng chi tiêu
  static double get soDuHienTai => tongThuNhap - tongChiTieu;

  // ============================================================
  // Dữ liệu mẫu cho biểu đồ thống kê (chi tiêu theo tháng)
  // Mỗi phần tử gồm: tên tháng và số tiền chi tiêu trong tháng đó
  // ============================================================
  static const List<Map<String, dynamic>> duLieuBieuDo = [
    {'thang': 'T10', 'soTien': 3200000.0},
    {'thang': 'T11', 'soTien': 4100000.0},
    {'thang': 'T12', 'soTien': 5800000.0},
    {'thang': 'T1',  'soTien': 3900000.0},
    {'thang': 'T2',  'soTien': 4700000.0},
    {'thang': 'T3',  'soTien': 2840000.0}, // Tháng hiện tại
  ];

  // Danh sách các danh mục chi tiêu nhiều nhất (dùng cho màn hình Thống Kê)
  static const List<Map<String, dynamic>> topDanhMuc = [
    {
      'tenDanhMuc': 'Ăn uống',
      'soTien': 1200000.0,
      'phanTram': 0.42,  // 42% tổng chi tiêu
      'mau': Color(0xFFFF7043),
      'icon': Icons.restaurant_outlined,
    },
    {
      'tenDanhMuc': 'Học tập',
      'soTien': 880000.0,
      'phanTram': 0.31,
      'mau': Color(0xFF42A5F5),
      'icon': Icons.school_outlined,
    },
    {
      'tenDanhMuc': 'Giải trí',
      'soTien': 450000.0,
      'phanTram': 0.16,
      'mau': Color(0xFFAB47BC),
      'icon': Icons.sports_esports_outlined,
    },
    {
      'tenDanhMuc': 'Đi lại',
      'soTien': 310000.0,
      'phanTram': 0.11,
      'mau': Color(0xFF26A69A),
      'icon': Icons.directions_bus_outlined,
    },
  ];
}
