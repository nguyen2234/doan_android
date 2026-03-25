// ============================================================
// File: widgets/dong_giao_dich.dart
// Widget hiển thị một dòng giao dịch trong danh sách lịch sử
// Gồm: Icon, Tên giao dịch, Ngày, và Số tiền (xanh/đỏ)
// ============================================================

import 'package:flutter/material.dart';
import '../models/giao_dich.dart'; // Import model GiaoDich

// DongGiaoDich: Widget một dòng giao dịch trong danh sách
class DongGiaoDich extends StatelessWidget {
  // giaoDich: Đối tượng GiaoDich chứa thông tin cần hiển thị
  final GiaoDich giaoDich;

  const DongGiaoDich({
    super.key,
    required this.giaoDich,
  });

  // Hàm định dạng số tiền thành chuỗi có dấu + hoặc -
  String _dinhDangSoTien(double soTien) {
    String dau = soTien > 0 ? '+' : '-';
    // abs(): Lấy giá trị tuyệt đối
    String soTienChuoi = soTien.abs().toStringAsFixed(0);

    // Thêm dấu chấm phân cách hàng nghìn
    String ketQua = '';
    int demSoChu = 0;
    for (int i = soTienChuoi.length - 1; i >= 0; i--) {
      if (demSoChu > 0 && demSoChu % 3 == 0) {
        ketQua = '.$ketQua';
      }
      ketQua = soTienChuoi[i] + ketQua;
      demSoChu++;
    }

    return '$dau $ketQua đ';
  }

  @override
  Widget build(BuildContext context) {
    // Màu của số tiền: Xanh lá = thu nhập, Đỏ = chi tiêu
    Color mauSoTien = giaoDich.laThuNhap
        ? const Color(0xFF388E3C) // Xanh lá đậm
        : const Color(0xFFD32F2F); // Đỏ đậm

    return Container(
      // margin: Khoảng cách giữa các dòng giao dịch
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

      // padding: Khoảng cách bên trong card
      padding: const EdgeInsets.all(12),

      // decoration: Card trắng có bo góc và đổ bóng nhẹ
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // boxShadow: Đổ bóng nhẹ tạo hiệu ứng nổi lên
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Bóng rất nhẹ
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      // Row: Sắp xếp các phần tử theo chiều ngang
      child: Row(
        children: [
          // ICON của danh mục giao dịch (hình tròn với màu nền)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: giaoDich.mauNen, // Màu nền được truyền từ model
              borderRadius: BorderRadius.circular(12),
            ),
            // child: Icon ở giữa container
            child: Icon(
              giaoDich.iconDanhMuc,
              size: 24,
              // Màu icon: Dựa theo màu nền (tối hơn màu nền một chút)
              color: giaoDich.laThuNhap
                  ? const Color(0xFF2E7D32) // Xanh lá đậm
                  : const Color(0xFFC62828), // Đỏ đậm
            ),
          ),

          const SizedBox(width: 12), // Khoảng cách ngang

          // Phần giữa: Tên giao dịch và ngày
          // Expanded: Chiếm hết không gian còn lại sau icon và số tiền
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên giao dịch
                Text(
                  giaoDich.tenGiaoDich,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A), // Màu chữ đen đậm
                  ),
                  // overflow: Nếu tên quá dài thì hiển thị "..."
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                // Ngày giao dịch
                Text(
                  giaoDich.ngayGiaoDich,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Số tiền (bên phải, màu xanh hoặc đỏ)
          Text(
            _dinhDangSoTien(giaoDich.soTien),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: mauSoTien,
            ),
          ),
        ],
      ),
    );
  }
}
