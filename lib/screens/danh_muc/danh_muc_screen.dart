import 'package:flutter/material.dart';
import '../../database/co_so_du_lieu.dart';
import '../../models/transaction.dart';
import 'them_sua_danh_muc_screen.dart';

// ================================================================
// Màn hình Quản lý Danh mục
// Hiển thị 2 tab: Danh mục Thu & Danh mục Chi
// Hỗ trợ đầy đủ CRUD (thêm, sửa, xóa)
// ================================================================
class DanhMucScreen extends StatefulWidget {
  const DanhMucScreen({super.key});

  @override
  State<DanhMucScreen> createState() => _DanhMucScreenState();
}

class _DanhMucScreenState extends State<DanhMucScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<DanhMuc> _danhMucThu = [];
  List<DanhMuc> _danhMucChi = [];
  bool _dangTai = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _taiDanhMuc();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _taiDanhMuc() async {
    setState(() => _dangTai = true);
    final thu = await CoSoDuLieu.layDanhMuc(loai: 'thu');
    final chi = await CoSoDuLieu.layDanhMuc(loai: 'chi');
    if (mounted) {
      setState(() {
        _danhMucThu = thu;
        _danhMucChi = chi;
        _dangTai = false;
      });
    }
  }

  Future<void> _moThemSuaDanhMuc({DanhMuc? danhMuc, String? loaiMacDinh}) async {
    final ketQua = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ThemSuaDanhMucScreen(
          danhMuc: danhMuc,
          loaiMacDinh: loaiMacDinh,
        ),
      ),
    );
    if (ketQua == true) await _taiDanhMuc();
  }

  Future<void> _xoaDanhMuc(DanhMuc dm) async {
    final xacNhan = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.delete_outline, color: Colors.red.shade600, size: 22),
            ),
            const SizedBox(width: 12),
            const Text('Xóa danh mục', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.5),
            children: [
              const TextSpan(text: 'Bạn có chắc muốn xóa danh mục\n'),
              TextSpan(
                text: '"${dm.name}"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' không?\nHành động này không thể hoàn tác.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (xacNhan == true && dm.id != null) {
      await CoSoDuLieu.xoaDanhMuc(dm.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Đã xóa "${dm.name}"'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      await _taiDanhMuc();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(),
              collapseMode: CollapseMode.pin,
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade600,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_upward, size: 16),
                          const SizedBox(width: 6),
                          Text('Thu nhập (${_danhMucThu.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_downward, size: 16),
                          const SizedBox(width: 6),
                          Text('Chi tiêu (${_danhMucChi.length})'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: _dangTai
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildDanhSachDanhMuc(_danhMucThu, 'thu'),
                  _buildDanhSachDanhMuc(_danhMucChi, 'chi'),
                ],
              ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Quản lý Danh mục',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.category, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${_danhMucThu.length + _danhMucChi.length} danh mục',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  'Quản lý phân loại thu nhập và chi tiêu',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDanhSachDanhMuc(List<DanhMuc> danhSach, String loai) {
    if (danhSach.isEmpty) {
      return _buildTrangRong(loai);
    }

    return RefreshIndicator(
      onRefresh: _taiDanhMuc,
      color: const Color(0xFF1A73E8),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: danhSach.length,
        itemBuilder: (_, i) => _buildTheDanhMuc(danhSach[i]),
      ),
    );
  }

  Widget _buildTheDanhMuc(DanhMuc dm) {
    final mauSac = _layMauSac(dm.color);
    final icon = _layIcon(dm.icon);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: mauSac.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _moThemSuaDanhMuc(danhMuc: dm),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon bo tròn gradient
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      mauSac,
                      mauSac.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: mauSac.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),

              // Tên và loại
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dm.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: dm.type == 'thu'
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        dm.type == 'thu' ? '↑ Thu nhập' : '↓ Chi tiêu',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: dm.type == 'thu'
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Nút chỉnh sửa và xóa
              Row(
                children: [
                  _buildNutHanhDong(
                    icon: Icons.edit_outlined,
                    color: const Color(0xFF1A73E8),
                    onTap: () => _moThemSuaDanhMuc(danhMuc: dm),
                  ),
                  const SizedBox(width: 8),
                  _buildNutHanhDong(
                    icon: Icons.delete_outline,
                    color: Colors.red,
                    onTap: () => _xoaDanhMuc(dm),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutHanhDong({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildTrangRong(String loai) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.category_outlined,
              size: 50,
              color: Color(0xFF1A73E8),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            loai == 'thu'
                ? 'Chưa có danh mục thu nhập'
                : 'Chưa có danh mục chi tiêu',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút + để thêm danh mục mới',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _moThemSuaDanhMuc(loaiMacDinh: loai),
            icon: const Icon(Icons.add),
            label: const Text('Thêm danh mục'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        final loai = _tabController.index == 0 ? 'thu' : 'chi';
        _moThemSuaDanhMuc(loaiMacDinh: loai);
      },
      backgroundColor: const Color(0xFF1A73E8),
      foregroundColor: Colors.white,
      elevation: 6,
      icon: const Icon(Icons.add),
      label: const Text(
        'Thêm danh mục',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Chuyển chuỗi màu hex → Color
  Color _layMauSac(String? mauSac) {
    if (mauSac == null) return const Color(0xFF1A73E8);
    try {
      return Color(int.parse(mauSac.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF1A73E8);
    }
  }

  // Chuyển tên icon → IconData
  IconData _layIcon(String? tenIcon) {
    const bangIcon = <String, IconData>{
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'shopping_cart': Icons.shopping_cart,
      'home': Icons.home,
      'local_hospital': Icons.local_hospital,
      'school': Icons.school,
      'sports_esports': Icons.sports_esports,
      'flight': Icons.flight,
      'fitness_center': Icons.fitness_center,
      'local_cafe': Icons.local_cafe,
      'attach_money': Icons.attach_money,
      'work': Icons.work,
      'business': Icons.business,
      'card_giftcard': Icons.card_giftcard,
      'phone': Icons.phone,
      'wifi': Icons.wifi,
      'electric_bolt': Icons.electric_bolt,
      'water_drop': Icons.water_drop,
      'pets': Icons.pets,
      'movie': Icons.movie,
      'music_note': Icons.music_note,
      'sports': Icons.sports,
      'local_grocery_store': Icons.local_grocery_store,
      'savings': Icons.savings,
      'trending_up': Icons.trending_up,
      'account_balance': Icons.account_balance,
    };
    return bangIcon[tenIcon] ?? Icons.category;
  }
}
