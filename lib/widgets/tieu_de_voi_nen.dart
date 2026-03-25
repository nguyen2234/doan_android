// ============================================================
// File: widgets/tieu_de_voi_nen.dart
// Widget tiêu đề với nền màu teal (xanh ngọc) và thông tin chào hỏi
// Được sử dụng lại ở màn hình Trang Chủ
// ============================================================

import 'package:flutter/material.dart';

// TieuDeVoiNen: Widget hiển thị phần header có nền màu teal
// Đây là StatelessWidget vì nó không có trạng thái thay đổi
class TieuDeVoiNen extends StatelessWidget {
  // tenNguoiDung: Tên của người dùng để hiển thị lời chào
  final String tenNguoiDung;

  // loiChao: Lời chào tùy theo thời điểm trong ngày
  final String loiChao;

  const TieuDeVoiNen({
    super.key,
    required this.tenNguoiDung,
    required this.loiChao,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Chiều rộng: Chiếm toàn bộ chiều ngang màn hình
      width: double.infinity,

      // Padding: Khoảng cách bên trong container
      // EdgeInsets.only: Chỉ đặt padding cho các cạnh chỉ định
      padding: const EdgeInsets.only(
        top: 50,     // Khoảng cách từ trên (tránh bị che bởi thanh trạng thái)
        left: 20,
        right: 20,
        bottom: 30,
      ),

      // decoration: Trang trí cho container (màu nền gradient)
      decoration: const BoxDecoration(
        // gradient: Màu nền chuyển sắc từ trên xuống dưới
        gradient: LinearGradient(
          // begin, end: Hướng của gradient (từ trên xuống dưới)
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2D7A6B), // Màu teal đậm ở trên
            Color(0xFF3A9B8A), // Màu teal nhạt hơn ở dưới
          ],
        ),
      ),

      // child: Nội dung bên trong container
      child: Row(
        // Row: Sắp xếp các widget theo chiều ngang
        // mainAxisAlignment: Căn chỉnh theo trục chính (ngang)
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Cột bên trái: Hiển thị lời chào và tên người dùng
          Column(
            // crossAxisAlignment: Căn chỉnh theo trục phụ (dọc) của Column
            // start: Căn về bên trái
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lời chào (ví dụ: "Chào buổi chiều,")
              Text(
                loiChao,
                style: const TextStyle(
                  color: Colors.white70, // Màu trắng hơi trong suốt
                  fontSize: 14,
                ),
              ),

              // Khoảng cách nhỏ giữa lời chào và tên
              const SizedBox(height: 4),

              // Tên người dùng (in đậm, chữ to)
              Text(
                tenNguoiDung,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold, // In đậm
                ),
              ),
            ],
          ),

          // Nút chuông thông báo ở bên phải
          Stack(
            // Stack: Xếp các widget chồng lên nhau
            children: [
              // Nút thông báo dạng tròn
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  // Nền trắng mờ (opacity thấp)
                  color: Colors.white.withOpacity(0.2),
                  // Hình dạng: Tròn
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              // Chấm đỏ nhỏ báo có thông báo mới (được đặt ở góc trên bên phải)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5252), // Màu đỏ
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
