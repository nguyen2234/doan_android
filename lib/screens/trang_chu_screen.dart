// ============================================================
// File: screens/trang_chu_screen.dart
// Màn hình Trang Chủ - Màn hình đầu tiên người dùng thấy khi mở app
// Gồm: Header chào hỏi, Thẻ số dư, Danh sách lịch sử giao dịch
// ============================================================

import 'package:flutter/material.dart';

// Import các model và widget cần dùng
import '../models/giao_dich.dart';
import '../widgets/tieu_de_voi_nen.dart';
import '../widgets/the_so_du.dart';
import '../widgets/dong_giao_dich.dart';

// ============================================================
// TrangChuScreen: Màn hình Trang Chủ
// StatelessWidget vì toàn bộ nội dung là dữ liệu mẫu (không thay đổi)
// ============================================================
class TrangChuScreen extends StatelessWidget {
  const TrangChuScreen({super.key});

  // Hàm xác định lời chào theo thời gian trong ngày
  String _layLoiChao() {
    // DateTime.now().hour: Lấy giờ hiện tại (0-23)
    int gioHienTai = DateTime.now().hour;

    if (gioHienTai < 12) {
      return 'Chào buổi sáng,';
    } else if (gioHienTai < 18) {
      return 'Chào buổi chiều,';
    } else {
      return 'Chào buổi tối,';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Màu nền của màn hình
      backgroundColor: const Color(0xFFF5F5F5), // Màu xám rất nhạt
      // body: Nội dung chính của màn hình
      // SingleChildScrollView: Cho phép cuộn khi nội dung dài hơn màn hình
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================================================
            // PHẦN 1: Header với nền màu teal
            // ================================================
            TieuDeVoiNen(tenNguoiDung: 'Nguyễn Văn An', loiChao: _layLoiChao()),

            // ================================================
            // PHẦN 2: Thẻ số dư tổng quan
            // Được đặt giữa header và body chính
            // ================================================
            TheSoDu(
              tongSoDu: DuLieuMau.soDuHienTai,
              tongThuNhap: DuLieuMau.tongThuNhap,
              tongChiTieu: DuLieuMau.tongChiTieu,
            ),

            // ================================================
            // PHẦN 3: Các nút tắt nhanh (Chuyển tiền, Nạp tiền, v.v.)
            // ================================================
            _XayDungPhimTatNhanh(),

            const SizedBox(height: 16),

            // ================================================
            // PHẦN 4: Tiêu đề "Lịch Sử Giao Dịch" + nút "Xem Tất Cả"
            // ================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tiêu đề phần
                  const Text(
                    'Lịch Sử Giao Dịch',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),

                  // Nút "Xem Tất Cả" (chưa xử lý logic điều hướng)
                  TextButton(
                    onPressed: () {
                      // TODO: Điều hướng đến màn hình xem tất cả giao dịch
                    },
                    child: const Text(
                      'Xem Tất Cả',
                      style: TextStyle(
                        color: Color(0xFF2D7A6B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================================================
            // PHẦN 5: Danh sách lịch sử giao dịch
            // ListView.builder: Tạo danh sách cuộn hiệu quả
            // ================================================
            // Chúng ta dùng ListView với shrinkWrap thay vì ListView trực tiếp
            // vì màn hình này đã nằm trong SingleChildScrollView
            ListView.builder(
              // shrinkWrap: true => ListView co lại vừa đủ với nội dung
              shrinkWrap: true,

              // physics: NeverScrollableScrollPhysics() => Tắt cuộn của ListView
              // vì parent (SingleChildScrollView) đã xử lý cuộn rồi
              physics: const NeverScrollableScrollPhysics(),

              // itemCount: Số lượng phần tử trong danh sách
              itemCount: DuLieuMau.danhSachGiaoDich.length,

              // itemBuilder: Hàm tạo mỗi phần tử trong danh sách
              // context: Ngữ cảnh của widget
              // index: Chỉ số của phần tử hiện tại (0, 1, 2, ...)
              itemBuilder: (BuildContext context, int index) {
                // Lấy giao dịch tại vị trí index
                final GiaoDich giaoDich = DuLieuMau.danhSachGiaoDich[index];

                // Trả về widget DongGiaoDich cho mỗi phần tử
                return DongGiaoDich(giaoDich: giaoDich);
              },
            ),

            // Khoảng cách dưới cùng (tránh bị che bởi bottom navigation bar)
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Widget nội bộ: Hàng các nút tắt nhanh (Chuyển tiền, Nạp tiền, v.v.)
// Đặt tên bắt đầu bằng _ vì chỉ dùng trong file này
// ============================================================
class _XayDungPhimTatNhanh extends StatelessWidget {
  // Danh sách các phím tắt nhanh
  final List<Map<String, dynamic>> _danhSachPhimTat = const [
    {
      'nhan': 'Chuyển Tiền',
      'icon': Icons.swap_horiz_rounded,
      'mau': Color(0xFF2D7A6B),
    },
    {
      'nhan': 'Nạp Điện Thoại',
      'icon': Icons.phone_android,
      'mau': Color(0xFF1565C0), // Màu xanh dương
    },
    {
      'nhan': 'Thanh Toán',
      'icon': Icons.payment,
      'mau': Color(0xFF6A1B9A), // Màu tím
    },
    {
      'nhan': 'Thống Kê',
      'icon': Icons.bar_chart,
      'mau': Color(0xFFE65100), // Màu cam đất
    },
  ];

  const _XayDungPhimTatNhanh();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        // mainAxisAlignment.spaceBetween: Chia đều khoảng cách giữa các nút
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _danhSachPhimTat.map((phimTat) {
          // map(): Duyệt qua từng phần tử và tạo widget tương ứng
          return Column(
            children: [
              // Nút hình tròn
              GestureDetector(
                // onTap: Xử lý sự kiện khi người dùng chạm vào
                onTap: () {
                  // TODO: Xử lý từng chức năng tương ứng
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    // Màu nền nhạt hơn màu chính
                    color: (phimTat['mau'] as Color).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    phimTat['icon'] as IconData,
                    color: phimTat['mau'] as Color,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Nhãn bên dưới nút
              Text(
                phimTat['nhan'] as String,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF555555),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }).toList(), // .toList(): Chuyển kết quả map() thành danh sách List
      ),
    );
  }
}
