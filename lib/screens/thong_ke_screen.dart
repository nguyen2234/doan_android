// ============================================================
// File: screens/thong_ke_screen.dart
// Màn hình Thống Kê - Hiển thị biểu đồ chi tiêu và top danh mục
// Gồm: Header, Bộ lọc thời gian, Biểu đồ đường, Danh sách Top chi tiêu
// ============================================================

import 'package:flutter/material.dart';
import '../models/giao_dich.dart';

// ThongKeScreen: Màn hình Thống Kê
// StatefulWidget vì có trạng thái thay đổi:
//   - Người dùng chọn tab thời gian (Ngày/Tuần/Tháng/Năm)
class ThongKeScreen extends StatefulWidget {
  const ThongKeScreen({super.key});

  @override
  State<ThongKeScreen> createState() => _ThongKeScreenState();
}

class _ThongKeScreenState extends State<ThongKeScreen> {
  // Chỉ số tab thời gian đang được chọn (0=Ngày, 1=Tuần, 2=Tháng, 3=Năm)
  int _tabThoiGianDangChon = 2; // Mặc định chọn "Tháng"

  // Danh sách các tab thời gian
  final List<String> _danhSachTabThoiGian = ['Ngày', 'Tuần', 'Tháng', 'Năm'];

  // Giá trị lớn nhất trong dữ liệu biểu đồ (để tính tỷ lệ)
  // reduce: Tìm phần tử thỏa mãn điều kiện trong danh sách
  double get _giaTriLonNhat {
    return DuLieuMau.duLieuBieuDo
        .map((item) => item['soTien'] as double)
        .reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // appBar: Thanh tiêu đề ở trên cùng
      appBar: AppBar(
        // Không có nút back vì màn hình này là tab, không phải push
        automaticallyImplyLeading: false,
        title: const Text(
          'Thống Kê Chi Tiêu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        // Màu nền trong suốt (dùng màu của Scaffold)
        backgroundColor: const Color(0xFFF5F5F5),
        // elevation: Độ nổi của AppBar (0 = không đổ bóng)
        elevation: 0,
        // Nút xuất báo cáo ở bên phải (chưa xử lý logic)
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Xử lý xuất báo cáo chi tiêu
            },
            icon: const Icon(
              Icons.file_download_outlined,
              color: Color(0xFF2D7A6B),
            ),
            tooltip: 'Xuất báo cáo',
          ),
        ],
      ),

      body: SingleChildScrollView(
        // padding: Khoảng cách xung quanh toàn bộ nội dung
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================================================
            // PHẦN 1: Tổng quan nhanh (3 con số thống kê)
            // ================================================
            _XayDungTongQuanNhanh(),

            const SizedBox(height: 20),

            // ================================================
            // PHẦN 2: Bộ lọc thời gian (Ngày / Tuần / Tháng / Năm)
            // ================================================
            _XayDungBoLocThoiGian(),

            const SizedBox(height: 20),

            // ================================================
            // PHẦN 3: Card biểu đồ chi tiêu
            // ================================================
            _XayDungCardBieuDo(),

            const SizedBox(height: 20),

            // ================================================
            // PHẦN 4: Tiêu đề "Top Danh Mục Chi Tiêu"
            // ================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Top Danh Mục Chi Tiêu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                // Nút sắp xếp (chưa xử lý logic)
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.sort,
                    color: Color(0xFF2D7A6B),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ================================================
            // PHẦN 5: Danh sách các danh mục chi tiêu nhiều nhất
            // ================================================
            ...DuLieuMau.topDanhMuc.asMap().entries.map((entry) {
              // asMap(): Chuyển list thành Map để có cả index và value
              // entries: Danh sách các cặp {index: value}
              int index = entry.key;       // Vị trí (0, 1, 2, 3)
              Map<String, dynamic> danhMuc = entry.value; // Dữ liệu danh mục

              return _XayDungDongDanhMuc(
                danhMuc: danhMuc,
                // Danh mục đầu tiên (index == 0) được highlight màu teal
                duocChon: index == 0,
              );
            }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Widget hiển thị bộ lọc thời gian (Tab bar tùy chỉnh)
  // ============================================================
  Widget _XayDungBoLocThoiGian() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // Row: Các tab xếp ngang
      child: Row(
        children: List.generate(_danhSachTabThoiGian.length, (int index) {
          // List.generate: Tạo danh sách với số lượng và hàm tạo phần tử
          bool dangDuocChon = index == _tabThoiGianDangChon;

          return Expanded(
            // Expanded: Mỗi tab chiếm phần bằng nhau trong Row
            child: GestureDetector(
              onTap: () {
                // Khi người dùng chạm vào tab, cập nhật state
                setState(() {
                  _tabThoiGianDangChon = index;
                });
              },
              child: AnimatedContainer(
                // AnimatedContainer: Container có hiệu ứng chuyển đổi mượt mà
                // duration: Thời gian của hiệu ứng (200 milliseconds)
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  // Nếu đang được chọn: Nền teal, ngược lại: Trong suốt
                  color: dangDuocChon
                      ? const Color(0xFF2D7A6B)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _danhSachTabThoiGian[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // Chữ trắng nếu được chọn, xám nếu không
                    color: dangDuocChon ? Colors.white : Colors.grey,
                    fontWeight: dangDuocChon
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ============================================================
  // Widget Biểu Đồ Cột đơn giản (không dùng thư viện bên ngoài)
  // Vẽ bằng Flutter thuần túy để dễ hiểu cho người mới học
  // ============================================================
  Widget _XayDungCardBieuDo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề biểu đồ + số tiền được chọn
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Chi Tiêu Theo Tháng',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '2.840.000 đ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D7A6B),
                    ),
                  ),
                ],
              ),
              // Chú thích màu
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2D7A6B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('Chi tiêu', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Biểu đồ cột tùy chỉnh
          SizedBox(
            height: 180,
            child: Row(
              // crossAxisAlignment: Căn chỉnh các cột theo chiều dọc
              // end: Các cột mọc từ dưới lên (như biểu đồ cột thực tế)
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: DuLieuMau.duLieuBieuDo.map((Map<String, dynamic> item) {
                double soTien = item['soTien'] as double;
                String tenThang = item['thang'] as String;

                // Tính chiều cao của cột theo tỷ lệ so với giá trị lớn nhất
                // Chiều cao tối đa là 140 pixel
                double chieuCaoCot = (soTien / _giaTriLonNhat) * 140;

                // Kiểm tra xem đây có phải tháng cuối cùng (tháng hiện tại) không
                bool laThangHienTai = tenThang == DuLieuMau.duLieuBieuDo.last['thang'];

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Số tiền hiển thị trên cột (chỉ hiện cho tháng hiện tại)
                    if (laThangHienTai)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D7A6B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${(soTien / 1000000).toStringAsFixed(1)}M',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    const SizedBox(height: 4),

                    // Cột biểu đồ
                    Container(
                      width: 36,
                      height: chieuCaoCot,
                      decoration: BoxDecoration(
                        // Tháng hiện tại: Màu teal đậm, các tháng khác: Xám nhạt
                        color: laThangHienTai
                            ? const Color(0xFF2D7A6B)
                            : const Color(0xFFE0E0E0),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Nhãn tháng bên dưới cột
                    Text(
                      tenThang,
                      style: TextStyle(
                        fontSize: 12,
                        color: laThangHienTai
                            ? const Color(0xFF2D7A6B)
                            : Colors.grey,
                        fontWeight: laThangHienTai
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Widget Tổng Quan Nhanh (3 thẻ số liệu nhỏ)
  // ============================================================
  Widget _XayDungTongQuanNhanh() {
    return Row(
      children: [
        // Thẻ 1: Tổng chi tiêu
        Expanded(
          child: _XayDungTheThongKe(
            tieu: 'Tổng Chi Tiêu',
            giaTriChu: '2.840.000',
            donVi: ' đ',
            mauChu: const Color(0xFFD32F2F),
            mauNen: const Color(0xFFFFEBEE),
            icon: Icons.trending_up,
          ),
        ),
        const SizedBox(width: 10),
        // Thẻ 2: Tổng thu nhập
        Expanded(
          child: _XayDungTheThongKe(
            tieu: 'Tổng Thu Nhập',
            giaTriChu: '14.910.000',
            donVi: ' đ',
            mauChu: const Color(0xFF2E7D32),
            mauNen: const Color(0xFFE8F5E9),
            icon: Icons.trending_down,
          ),
        ),
        const SizedBox(width: 10),
        // Thẻ 3: Số giao dịch
        Expanded(
          child: _XayDungTheThongKe(
            tieu: 'Giao Dịch',
            giaTriChu: '6',
            donVi: ' lần',
            mauChu: const Color(0xFF1565C0),
            mauNen: const Color(0xFFE3F2FD),
            icon: Icons.receipt_long_outlined,
          ),
        ),
      ],
    );
  }

  // Widget thẻ thống kê nhỏ (dùng lại 3 lần ở trên)
  Widget _XayDungTheThongKe({
    required String tieu,
    required String giaTriChu,
    required String donVi,
    required Color mauChu,
    required Color mauNen,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: mauNen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: mauChu, size: 20),
          const SizedBox(height: 8),
          Text(
            '$giaTriChu$donVi',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: mauChu,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tieu,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Widget hiển thị một dòng danh mục trong phần "Top Danh Mục Chi Tiêu"
// ============================================================
class _XayDungDongDanhMuc extends StatelessWidget {
  final Map<String, dynamic> danhMuc; // Dữ liệu danh mục
  final bool duocChon;                // Có đang được highlight không

  const _XayDungDongDanhMuc({
    required this.danhMuc,
    required this.duocChon,
  });

  @override
  Widget build(BuildContext context) {
    double soTien = danhMuc['soTien'] as double;
    double phanTram = danhMuc['phanTram'] as double;
    Color mau = danhMuc['mau'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        // Dòng được chọn: Nền teal, các dòng còn lại: Trắng
        color: duocChon ? const Color(0xFF2D7A6B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon của danh mục
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: duocChon
                  ? Colors.white.withOpacity(0.2)
                  : mau.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              danhMuc['icon'] as IconData,
              color: duocChon ? Colors.white : mau,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          // Tên danh mục và thanh tiến trình
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hàng tên và số tiền
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      danhMuc['tenDanhMuc'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: duocChon ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      // toStringAsFixed(0): Làm tròn số, không lấy chữ số thập phân
                      '${(soTien / 1000).toStringAsFixed(0)}K đ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        // Đỏ nếu bình thường, trắng nếu được chọn
                        color: duocChon
                            ? Colors.white
                            : const Color(0xFFD32F2F),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Thanh tiến trình (progress bar) hiển thị % chi tiêu
                Stack(
                  children: [
                    // Nền của thanh tiến trình
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: duocChon
                            ? Colors.white.withOpacity(0.3)
                            : const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    // Phần đã lấp đầy (theo tỷ lệ phanTram)
                    FractionallySizedBox(
                      // widthFactor: Chiều rộng theo tỷ lệ (0.0 - 1.0)
                      widthFactor: phanTram,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: duocChon ? Colors.white : mau,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Phần trăm
                Text(
                  '${(phanTram * 100).toStringAsFixed(0)}% tổng chi tiêu',
                  style: TextStyle(
                    fontSize: 11,
                    color: duocChon
                        ? Colors.white70
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
