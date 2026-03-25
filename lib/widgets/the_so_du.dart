// ============================================================
// File: widgets/the_so_du.dart
// Widget hiển thị "Thẻ số dư" - Card lớn ở giữa màn hình trang chủ
// Hiển thị: Tổng chi tiêu, Thu nhập, và Chi tiêu trong tháng
// ============================================================

import 'package:flutter/material.dart';

// TheSoDu: Widget hiển thị card số dư tổng quan
class TheSoDu extends StatelessWidget {
  // Các tham số nhận từ widget cha (parent widget)
  final double tongSoDu;     // Tổng số dư hiện tại
  final double tongThuNhap;  // Tổng thu nhập
  final double tongChiTieu;  // Tổng chi tiêu

  const TheSoDu({
    super.key,
    required this.tongSoDu,
    required this.tongThuNhap,
    required this.tongChiTieu,
  });

  // Hàm định dạng số tiền: Chuyển 1000000 thành "1.000.000 đ"
  String _dinhDangSoTien(double soTien) {
    // abs(): Lấy giá trị tuyệt đối (bỏ dấu âm nếu có)
    String chuoi = soTien.abs().toStringAsFixed(0);

    // Thêm dấu chấm phân cách hàng nghìn
    // Ví dụ: "1000000" -> "1.000.000"
    String ketQua = '';
    int demSoChu = 0;
    for (int i = chuoi.length - 1; i >= 0; i--) {
      if (demSoChu > 0 && demSoChu % 3 == 0) {
        ketQua = '.$ketQua';
      }
      ketQua = chuoi[i] + ketQua;
      demSoChu++;
    }

    return '$ketQua đ';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: Khoảng cách bên ngoài container so với các widget xung quanh
      margin: const EdgeInsets.all(16),

      // decoration: Trang trí cho container
      decoration: BoxDecoration(
        // Màu nền gradient (chuyển màu)
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D7A6B), // Teal đậm
            Color(0xFF1A5C53), // Teal rất đậm
          ],
        ),

        // Góc bo tròn
        borderRadius: BorderRadius.circular(20),

        // Đổ bóng cho card
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D7A6B).withOpacity(0.4),
            blurRadius: 15,   // Độ mờ của bóng
            offset: const Offset(0, 8), // Bóng dịch xuống 8 pixel
          ),
        ],
      ),

      // Padding bên trong card
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hàng tiêu đề với nhãn "Tổng Số Dư" và icon 3 chấm (tùy chọn)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Tổng Số Dư',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Icon mũi tên lên (toggle hiện/ẩn số tiền)
                  const Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.white70,
                    size: 18,
                  ),
                ],
              ),
              // Nút ba chấm (menu tùy chọn - chưa xử lý logic)
              const Icon(
                Icons.more_horiz,
                color: Colors.white70,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Số dư lớn ở giữa card
          Text(
            _dinhDangSoTien(tongSoDu),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // Đường kẻ ngang phân cách (màu trắng mờ)
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),

          const SizedBox(height: 16),

          // Hàng dưới: Thu nhập | Chi tiêu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Cột THU NHẬP (bên trái)
              _XayDungCotThongKe(
                nhan: 'Thu Nhập',
                soTien: _dinhDangSoTien(tongThuNhap),
                icon: Icons.arrow_downward, // Mũi tên xuống = tiền vào
                mauIcon: const Color(0xFF4CAF50), // Màu xanh lá
              ),

              // Đường kẻ dọc phân cách
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),

              // Cột CHI TIÊU (bên phải)
              _XayDungCotThongKe(
                nhan: 'Chi Tiêu',
                soTien: _dinhDangSoTien(tongChiTieu),
                icon: Icons.arrow_upward, // Mũi tên lên = tiền ra
                mauIcon: const Color(0xFFEF5350), // Màu đỏ
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Widget riêng cho mỗi cột thống kê (Thu nhập / Chi tiêu)
// Đây là widget "nội bộ" chỉ dùng trong file này nên đặt tên bắt đầu bằng _
// ============================================================
class _XayDungCotThongKe extends StatelessWidget {
  final String nhan;       // Nhãn: "Thu Nhập" hoặc "Chi Tiêu"
  final String soTien;     // Số tiền đã định dạng
  final IconData icon;     // Icon mũi tên
  final Color mauIcon;     // Màu của icon

  const _XayDungCotThongKe({
    required this.nhan,
    required this.soTien,
    required this.icon,
    required this.mauIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hàng icon + nhãn
        Row(
          children: [
            // Container hình tròn chứa icon mũi tên
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                // Màu nền: màu của icon nhưng rất mờ
                color: mauIcon.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: mauIcon, size: 14),
            ),
            const SizedBox(width: 6),
            Text(
              nhan,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Số tiền
        Text(
          soTien,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600, // Semi-bold
          ),
        ),
      ],
    );
  }
}
