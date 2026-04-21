import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/transaction.dart';

class BaoCaoScreen extends StatefulWidget {
  const BaoCaoScreen({super.key});

  @override
  State<BaoCaoScreen> createState() => _BaoCaoScreenState();
}

class _BaoCaoScreenState extends State<BaoCaoScreen>
    with SingleTickerProviderStateMixin {
  List<GiaoDich> _tatCaGiaoDich = [];
  List<DanhMuc> _danhSachDanhMuc = [];
  bool _dangTai = true;

  // Tháng/năm
  int _thang = DateTime.now().month;
  int _nam = DateTime.now().year;

  // Bộ lọc
  final _searchCtrl = TextEditingController();
  String _keyword = '';
  String _loaiLoc = 'Tất cả'; // 'Tất cả' | 'Thu' | 'Chi'
  int? _danhMucLoc;
  DateTimeRange? _dateRange;

  // Tab Thu / Chi
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _taiDuLieu();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _taiDuLieu() async {
    final gd = await DBHelper.getTransactions();
    final dm = await DBHelper.getCategories();
    setState(() {
      _tatCaGiaoDich = gd;
      _danhSachDanhMuc = dm;
      _dangTai = false;
    });
  }

  // Lọc theo tháng
  List<GiaoDich> get _gdTheoThang => _tatCaGiaoDich.where((g) {
        if (g.date == null) return false;
        final d = DateTime.parse(g.date!);
        return d.month == _thang && d.year == _nam;
      }).toList();

  // Lọc nâng cao
  List<GiaoDich> get _gdDaLoc {
    return _gdTheoThang.where((g) {
      final matchKeyword = _keyword.isEmpty ||
          (g.note?.toLowerCase().contains(_keyword.toLowerCase()) ?? false) ||
          (g.categoryName?.toLowerCase().contains(_keyword.toLowerCase()) ?? false);
      final matchLoai = _loaiLoc == 'Tất cả' ||
          (_loaiLoc == 'Thu' && g.isIncome) ||
          (_loaiLoc == 'Chi' && !g.isIncome);
      final matchDanhMuc = _danhMucLoc == null || g.categoryId == _danhMucLoc;
      final matchDate = _dateRange == null ||
          (g.date != null &&
              !DateTime.parse(g.date!).isBefore(_dateRange!.start) &&
              !DateTime.parse(g.date!).isAfter(_dateRange!.end));
      return matchKeyword && matchLoai && matchDanhMuc && matchDate;
    }).toList();
  }

  double get _tongThu => _gdTheoThang
      .where((g) => g.isIncome)
      .fold(0, (t, g) => t + g.amount);

  double get _tongChi => _gdTheoThang
      .where((g) => !g.isIncome)
      .fold(0, (t, g) => t + g.amount);

  Map<String, double> get _chiTieuTheoNhom {
    final map = <String, double>{};
    for (final g in _gdTheoThang.where((g) => !g.isIncome)) {
      final ten = g.categoryName ?? 'Khác';
      map[ten] = (map[ten] ?? 0) + g.amount;
    }
    final sorted = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }

  void _thangTruoc() => setState(() {
        if (_thang == 1) { _thang = 12; _nam--; } else { _thang--; }
      });

  void _thangSau() {
    final next = DateTime(_nam, _thang + 1);
    if (next.isAfter(DateTime(DateTime.now().year, DateTime.now().month))) return;
    setState(() {
      if (_thang == 12) { _thang = 1; _nam++; } else { _thang++; }
    });
  }

  Future<void> _chonNgay() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _dateRange,
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  void _xoaLoc() => setState(() {
        _keyword = '';
        _searchCtrl.clear();
        _loaiLoc = 'Tất cả';
        _danhMucLoc = null;
        _dateRange = null;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Báo cáo'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _taiDuLieu,
          ),
        ],
      ),
      body: _dangTai
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _taiDuLieu,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                children: [
                  // Điều hướng tháng
                  _buildDieuHuongThang(),
                  const SizedBox(height: 16),

                  // Tóm tắt thu/chi
                  _buildTheTomTat(),
                  const SizedBox(height: 16),

                  // Số dư
                  _buildSoDu(),
                  const SizedBox(height: 20),

                  // Tìm kiếm
                  _buildTimKiem(),
                  const SizedBox(height: 12),

                  // Lọc nâng cao
                  _buildLocNangCao(),
                  const SizedBox(height: 20),

                  // Tab Chi tiết Thu / Chi
                  _buildTabChiTiet(),
                  const SizedBox(height: 20),

                  // Biểu đồ danh mục chi tiêu
                  _buildBieuDoDanhMuc(),
                ],
              ),
            ),
    );
  }

  Widget _buildDieuHuongThang() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: _thangTruoc, icon: const Icon(Icons.chevron_left)),
          Text('Tháng $_thang/$_nam', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          IconButton(onPressed: _thangSau, icon: const Icon(Icons.chevron_right)),
        ],
      ),
    );
  }

  Widget _buildTheTomTat() {
    return Row(
      children: [
        Expanded(child: _buildOThuChi('Tổng thu', _tongThu, Colors.green, Icons.arrow_downward)),
        const SizedBox(width: 12),
        Expanded(child: _buildOThuChi('Tổng chi', _tongChi, Colors.red, Icons.arrow_upward)),
      ],
    );
  }

  Widget _buildOThuChi(String tieu, double soTien, Color mau, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mau.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mau.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(radius: 14, backgroundColor: mau.withValues(alpha: 0.15),
                child: Icon(icon, color: mau, size: 14)),
            const SizedBox(width: 8),
            Text(tieu, style: TextStyle(color: mau, fontSize: 13)),
          ]),
          const SizedBox(height: 8),
          Text('${_fmt(soTien)}đ',
              style: TextStyle(color: mau, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildSoDu() {
    final soDu = _tongThu - _tongChi;
    final duong = soDu >= 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
  children: [
    Expanded(
      child: const Text(
        '📊 Số dư cuối tháng',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    ),
    Text(
      '${duong ? '+' : ''}${_fmt(soDu)}đ',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: duong ? Colors.green : Colors.red,
      ),
    ),
  ],
),
    );
  }

  Widget _buildTimKiem() {
    return TextField(
      controller: _searchCtrl,
      decoration: InputDecoration(
        hintText: 'Tìm kiếm theo ghi chú, danh mục...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _keyword.isNotEmpty
            ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() { _keyword = ''; _searchCtrl.clear(); }))
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
      onChanged: (v) => setState(() => _keyword = v),
    );
  }

  Widget _buildLocNangCao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_loaiLoc != 'Tất cả' || _danhMucLoc != null || _dateRange != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _xoaLoc,
              icon: const Icon(Icons.filter_list_off, size: 16),
              label: const Text('Xóa lọc', style: TextStyle(fontSize: 12)),
            ),
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Lọc loại
              ...['Tất cả', 'Thu', 'Chi'].map((o) {
                final colors = {'Thu': Colors.green, 'Chi': Colors.red};
                final isSelected = o == _loaiLoc;
                final color = colors[o] ?? const Color(0xFF1A73E8);
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(o),
                    selected: isSelected,
                    selectedColor: color.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: isSelected ? color : null,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                    onSelected: (_) => setState(() => _loaiLoc = o),
                  ),
                );
              }),
              const SizedBox(width: 8),

              // Lọc danh mục
              DropdownButton<int?>(
                value: _danhMucLoc,
                hint: const Text('Danh mục'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Tất cả DM')),
                  ..._danhSachDanhMuc.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                ],
                onChanged: (v) => setState(() => _danhMucLoc = v),
                underline: const SizedBox(),
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 8),

              // Lọc ngày
              ActionChip(
                avatar: const Icon(Icons.date_range, size: 16),
                label: Text(_dateRange == null
                    ? 'Chọn ngày'
                    : '${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}'),
                onPressed: _chonNgay,
              ),
              if (_dateRange != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => setState(() => _dateRange = null),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabChiTiet() {
    final gdLoc = _gdDaLoc;
    final gdThu = gdLoc.where((g) => g.isIncome).toList();
    final gdChi = gdLoc.where((g) => !g.isIncome).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chi tiết giao dịch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF1A73E8),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF1A73E8),
                tabs: [
                  Tab(text: 'Thu (${gdThu.length})'),
                  Tab(text: 'Chi (${gdChi.length})'),
                ],
              ),
              SizedBox(
                height: 300,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDanhSachGD(gdThu, Colors.green),
                    _buildDanhSachGD(gdChi, Colors.red),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDanhSachGD(List<GiaoDich> list, Color mau) {
    if (list.isEmpty) {
      return const Center(child: Text('Không có giao dịch', style: TextStyle(color: Colors.grey)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: list.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final g = list[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: mau.withValues(alpha: 0.12),
            child: Icon(g.isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: mau, size: 18),
          ),
          title: Text(g.note ?? '(Không có ghi chú)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          subtitle: Text('${g.categoryName ?? 'Chưa phân loại'} • ${_fmtDate(g.date)}',
              style: const TextStyle(fontSize: 11)),
          trailing: Text('${g.isIncome ? '+' : '-'}${_fmt(g.amount)}đ',
              style: TextStyle(color: mau, fontWeight: FontWeight.bold, fontSize: 13)),
        );
      },
    );
  }

  Widget _buildBieuDoDanhMuc() {
    final nhom = _chiTieuTheoNhom;
    if (nhom.isEmpty) return const SizedBox();
    final tong = nhom.values.fold(0.0, (t, v) => t + v);
    const mauSac = [
      Color(0xFF1A73E8), Color(0xFFEA4335), Color(0xFF34A853),
      Color(0xFFFBBC05), Color(0xFF9C27B0), Color(0xFF00BCD4),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chi tiêu theo danh mục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...nhom.entries.toList().asMap().entries.map((entry) {
          final mau = mauSac[entry.key % mauSac.length];
          final ten = entry.value.key;
          final soTien = entry.value.value;
          final phanTram = tong > 0 ? soTien / tong : 0.0;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: mau, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(ten, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    ]),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('${_fmt(soTien)}đ', style: TextStyle(color: mau, fontWeight: FontWeight.bold)),
                      Text('${(phanTram * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ]),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: phanTram.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade200,
                  color: mau,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _fmt(double v) => v.toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  String _fmtDate(String? d) {
    if (d == null) return '';
    final dt = DateTime.parse(d);
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
