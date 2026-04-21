import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../utils/session.dart';
import '../auth/login_screen.dart';
import '../danh_muc/danh_muc_screen.dart';
import 'chinh_sua_ho_so_screen.dart';

// ============================================================
// Màn hình Hồ sơ & Cài đặt (Tab thứ 4)
// Gồm nhiều danh mục chức năng như app tài chính thực tế
// ============================================================
class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Biến giả lập trạng thái bật/tắt thông báo
  bool _batThongBao = true;
  bool _cheDoToi = false;
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  // Hàm đăng xuất và quay về màn hình đăng nhập
  Future<void> _dangXuat() async {
    // Hiện hộp thoại xác nhận trước khi đăng xuất
    final xacNhan = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (xacNhan == true) {
      await Session.clear(); // Xóa session
      if (!mounted) return;
      // Chuyển về màn hình đăng nhập, xóa toàn bộ stack điều hướng
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  // Mở màn hình Chỉnh sửa hồ sơ
  Future<void> _moChinhSuaHoSo() async {
    final userMoi = await Navigator.push<User>(
      context,
      MaterialPageRoute(
        builder: (_) => ChinhSuaHoSoScreen(user: _user),
      ),
    );
    if (userMoi != null) setState(() => _user = userMoi);
  }

  // Hiện thông báo "Đang phát triển"
  void _dangPhatTrien(String tenChucNang) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🚧 "$tenChucNang" đang được phát triển...'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // ---- Phần đầu trang: Thông tin người dùng ----
          SliverToBoxAdapter(child: _buildPhanThongTinNguoiDung()),

          // ---- Nhóm 1: Tài khoản ----
          SliverToBoxAdapter(
            child: _buildNhomDanhMuc(
              tieuDe: '👤 Tài khoản',
              cacMuc: [
                _ItemDanhMuc(
                  icon: Icons.edit_outlined,
                  mauIcon: const Color(0xFF1A73E8),
                  tieuDe: 'Chỉnh sửa hồ sơ',
                  moTa: 'Thay đổi tên, mật khẩu, ảnh đại diện',
                  onTap: _moChinhSuaHoSo,
                ),
                _ItemDanhMuc(
                  icon: Icons.security_outlined,
                  mauIcon: const Color(0xFF34A853),
                  tieuDe: 'Bảo mật tài khoản',
                  moTa: 'Xác thực 2 bước, đổi mật khẩu',
                  onTap: () => _dangPhatTrien('Bảo mật tài khoản'),
                ),
                _ItemDanhMuc(
                  icon: Icons.fingerprint,
                  mauIcon: const Color(0xFF9C27B0),
                  tieuDe: 'Đăng nhập sinh trắc học',
                  moTa: 'Vân tay, nhận diện khuôn mặt',
                  onTap: () => _dangPhatTrien('Sinh trắc học'),
                ),
              ],
            ),
          ),

          // ---- Nhóm 2: Quản lý tài chính ----
          SliverToBoxAdapter(
            child: _buildNhomDanhMuc(
              tieuDe: '💰 Quản lý tài chính',
              cacMuc: [
                _ItemDanhMuc(
                  icon: Icons.category_outlined,
                  mauIcon: const Color(0xFFFF9800),
                  tieuDe: 'Quản lý danh mục',
                  moTa: 'Thêm, sửa, xóa danh mục thu/chi',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DanhMucScreen(),
                    ),
                  ),
                ),
                _ItemDanhMuc(
                  icon: Icons.account_balance_wallet_outlined,
                  mauIcon: const Color(0xFF1A73E8),
                  tieuDe: 'Quản lý ví tiền',
                  moTa: 'Xem và chỉnh sửa các ví',
                  onTap: () => _dangPhatTrien('Quản lý ví tiền'),
                ),
                _ItemDanhMuc(
                  icon: Icons.savings_outlined,
                  mauIcon: const Color(0xFF34A853),
                  tieuDe: 'Mục tiêu tiết kiệm',
                  moTa: 'Đặt mục tiêu và theo dõi tiết kiệm',
                  onTap: () => _dangPhatTrien('Mục tiêu tiết kiệm'),
                ),
                _ItemDanhMuc(
                  icon: Icons.trending_up,
                  mauIcon: const Color(0xFFEA4335),
                  tieuDe: 'Ngân sách chi tiêu',
                  moTa: 'Giới hạn chi tiêu theo danh mục',
                  onTap: () => _dangPhatTrien('Ngân sách chi tiêu'),
                ),
              ],
            ),
          ),

          // ---- Nhóm 3: Báo cáo & Xuất dữ liệu ----
          SliverToBoxAdapter(
            child: _buildNhomDanhMuc(
              tieuDe: '📊 Báo cáo & Dữ liệu',
              cacMuc: [
                _ItemDanhMuc(
                  icon: Icons.download_outlined,
                  mauIcon: const Color(0xFF00BCD4),
                  tieuDe: 'Xuất báo cáo Excel',
                  moTa: 'Tải xuống file .xlsx tổng hợp',
                  onTap: () => _dangPhatTrien('Xuất Excel'),
                ),
                _ItemDanhMuc(
                  icon: Icons.picture_as_pdf_outlined,
                  mauIcon: const Color(0xFFEA4335),
                  tieuDe: 'Xuất báo cáo PDF',
                  moTa: 'In hoặc lưu dạng file PDF',
                  onTap: () => _dangPhatTrien('Xuất PDF'),
                ),
                _ItemDanhMuc(
                  icon: Icons.backup_outlined,
                  mauIcon: const Color(0xFF9C27B0),
                  tieuDe: 'Sao lưu dữ liệu',
                  moTa: 'Lưu trữ an toàn lên đám mây',
                  onTap: () => _dangPhatTrien('Sao lưu'),
                ),
              ],
            ),
          ),

          // ---- Nhóm 4: Cài đặt ứng dụng ----
          SliverToBoxAdapter(
            child: _buildNhomDanhMuc(
              tieuDe: '⚙️ Cài đặt',
              cacMuc: [
                // Mục Thông báo có switch bật/tắt
                _ItemDanhMuc(
                  icon: Icons.notifications_outlined,
                  mauIcon: const Color(0xFFFBBC05),
                  tieuDe: 'Thông báo',
                  moTa: _batThongBao ? 'Đang bật' : 'Đang tắt',
                  widget: Switch(
                    value: _batThongBao,
                    activeColor: const Color(0xFF1A73E8),
                    onChanged: (v) => setState(() => _batThongBao = v),
                  ),
                ),
                // Mục Giao diện tối có switch bật/tắt
                _ItemDanhMuc(
                  icon: Icons.dark_mode_outlined,
                  mauIcon: const Color(0xFF607D8B),
                  tieuDe: 'Giao diện tối',
                  moTa: _cheDoToi ? 'Đang bật' : 'Đang tắt',
                  widget: Switch(
                    value: _cheDoToi,
                    activeColor: const Color(0xFF1A73E8),
                    onChanged: (v) => setState(() => _cheDoToi = v),
                  ),
                ),
                _ItemDanhMuc(
                  icon: Icons.language_outlined,
                  mauIcon: const Color(0xFF34A853),
                  tieuDe: 'Ngôn ngữ',
                  moTa: 'Tiếng Việt',
                  onTap: () => _dangPhatTrien('Ngôn ngữ'),
                ),
                _ItemDanhMuc(
                  icon: Icons.palette_outlined,
                  mauIcon: const Color(0xFFEA4335),
                  tieuDe: 'Màu chủ đề',
                  moTa: 'Thay đổi màu sắc giao diện',
                  onTap: () => _dangPhatTrien('Màu chủ đề'),
                ),
              ],
            ),
          ),

          // ---- Nhóm 5: Hỗ trợ ----
          SliverToBoxAdapter(
            child: _buildNhomDanhMuc(
              tieuDe: '🆘 Hỗ trợ',
              cacMuc: [
                _ItemDanhMuc(
                  icon: Icons.help_outline,
                  mauIcon: const Color(0xFF1A73E8),
                  tieuDe: 'Trung tâm trợ giúp',
                  moTa: 'Hướng dẫn sử dụng, FAQ',
                  onTap: () => _dangPhatTrien('Trợ giúp'),
                ),
                _ItemDanhMuc(
                  icon: Icons.star_outline,
                  mauIcon: const Color(0xFFFBBC05),
                  tieuDe: 'Đánh giá ứng dụng',
                  moTa: 'Để lại đánh giá trên cửa hàng',
                  onTap: () => _dangPhatTrien('Đánh giá'),
                ),
                _ItemDanhMuc(
                  icon: Icons.bug_report_outlined,
                  mauIcon: const Color(0xFFEA4335),
                  tieuDe: 'Báo cáo lỗi',
                  moTa: 'Gửi phản hồi khi gặp sự cố',
                  onTap: () => _dangPhatTrien('Báo cáo lỗi'),
                ),
                _ItemDanhMuc(
                  icon: Icons.info_outline,
                  mauIcon: const Color(0xFF607D8B),
                  tieuDe: 'Về ứng dụng',
                  moTa: 'Phiên bản 1.0.0',
                  onTap: () => _hienThongTinUngDung(),
                ),
              ],
            ),
          ),

          // ---- Nút Đăng xuất ----
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _dangXuat,
                  icon: const Icon(Icons.logout),
                  label: const Text('Đăng xuất'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Khoảng cách cuối tránh bị che bởi bottom nav
          const SliverToBoxAdapter(child: SizedBox(height: 88)),
        ],
      ),
    );
  }

  // Widget phần đầu trang với avatar và tên người dùng
  Widget _buildPhanThongTinNguoiDung() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            children: [
              // Ảnh đại diện
              GestureDetector(
                onTap: _moChinhSuaHoSo,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white24,
                      backgroundImage: _user.avatar != null
                          ? FileImage(File(_user.avatar!))
                          : null,
                      child: _user.avatar == null
                          ? const Icon(Icons.person, size: 45, color: Colors.white)
                          : null,
                    ),
                    // Nút camera nhỏ
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.edit,
                          size: 14,
                          color: const Color(0xFF1A73E8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Tên người dùng
              Text(
                _user.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),

              // Email
              Text(
                _user.email,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Nút chỉnh sửa nhanh
              OutlinedButton.icon(
                onPressed: _moChinhSuaHoSo,
                icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.white),
                label: const Text('Chỉnh sửa hồ sơ', style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hiển thị một nhóm danh mục (có tiêu đề + danh sách mục)
  Widget _buildNhomDanhMuc({
    required String tieuDe,
    required List<_ItemDanhMuc> cacMuc,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề nhóm
          Text(
            tieuDe,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Khung chứa các mục
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: cacMuc.asMap().entries.map((entry) {
                final viTri = entry.key;
                final muc = entry.value;
                final laCuoiDanh = viTri == cacMuc.length - 1;

                return Column(
                  children: [
                    // Mỗi dòng trong nhóm
                    InkWell(
                      onTap: muc.widget != null ? null : muc.onTap,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            // Icon bo tròn
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: muc.mauIcon.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(muc.icon, color: muc.mauIcon, size: 22),
                            ),
                            const SizedBox(width: 14),

                            // Tên và mô tả
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    muc.tieuDe,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (muc.moTa != null)
                                    Text(
                                      muc.moTa!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Widget tùy chỉnh (switch) hoặc mũi tên
                            muc.widget ??
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                          ],
                        ),
                      ),
                    ),

                    // Đường kẻ phân cách (trừ mục cuối cùng)
                    if (!laCuoiDanh)
                      const Divider(height: 1, indent: 70),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Hộp thoại thông tin ứng dụng
  void _hienThongTinUngDung() {
    showAboutDialog(
      context: context,
      applicationName: 'Quản lý Chi tiêu',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.account_balance_wallet,
        size: 48,
        color: Color(0xFF1A73E8),
      ),
      children: [
        const Text('Ứng dụng quản lý chi tiêu cá nhân.\nGiúp bạn theo dõi thu nhập và chi tiêu hàng ngày.'),
      ],
    );
  }
}

// ============================================================
// Class nội bộ: Đại diện cho một mục trong danh sách
// ============================================================
class _ItemDanhMuc {
  final IconData icon;        // Icon hiển thị bên trái
  final Color mauIcon;        // Màu nền của icon
  final String tieuDe;        // Tên của mục
  final String? moTa;         // Mô tả nhỏ bên dưới tên
  final VoidCallback? onTap;  // Hàm xử lý khi nhấn
  final Widget? widget;       // Widget tùy chỉnh (VD: Switch)

  const _ItemDanhMuc({
    required this.icon,
    required this.mauIcon,
    required this.tieuDe,
    this.moTa,
    this.onTap,
    this.widget,
  });
}
