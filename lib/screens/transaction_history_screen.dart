import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../database/db_helper.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<GiaoDich> _allTransactions = [];
  List<DanhMuc> _categories = [];

  String _keyword = '';
  String _selectedType = 'Tất cả';
  int? _selectedCategoryId;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final transactions = await DBHelper.getTransactions();
    final categories = await DBHelper.getCategories();
    setState(() {
      _allTransactions = transactions;
      _categories = categories;
    });
  }

  List<GiaoDich> get _filtered {
    return _allTransactions.where((t) {
      final matchKeyword = _keyword.isEmpty ||
          (t.note?.toLowerCase().contains(_keyword.toLowerCase()) ?? false) ||
          (t.categoryName?.toLowerCase().contains(_keyword.toLowerCase()) ?? false);
      final matchType = _selectedType == 'Tất cả' ||
          (_selectedType == 'Thu' && t.isIncome) ||
          (_selectedType == 'Chi' && !t.isIncome);
      final matchCategory =
          _selectedCategoryId == null || t.categoryId == _selectedCategoryId;
      final matchDate = _dateRange == null ||
          (t.date != null &&
              !DateTime.parse(t.date!).isBefore(_dateRange!.start) &&
              !DateTime.parse(t.date!).isAfter(_dateRange!.end));
      return matchKeyword && matchType && matchCategory && matchDate;
    }).toList();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _dateRange,
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  void _clearFilters() {
    setState(() {
      _keyword = '';
      _searchController.clear();
      _selectedType = 'Tất cả';
      _selectedCategoryId = null;
      _dateRange = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử giao dịch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_off),
            tooltip: 'Xóa bộ lọc',
            onPressed: _clearFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo ghi chú, danh mục...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (v) => setState(() => _keyword = v),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                ...['Tất cả', 'Thu', 'Chi'].map((o) {
                  final colors = {'Thu': Colors.green, 'Chi': Colors.red};
                  final isSelected = o == _selectedType;
                  final color = colors[o] ?? Theme.of(context).colorScheme.primary;
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: ChoiceChip(
                      label: Text(o),
                      selected: isSelected,
                      selectedColor: color.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? color : null,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                      onSelected: (_) => setState(() => _selectedType = o),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                DropdownButton<int?>(
                  value: _selectedCategoryId,
                  hint: const Text('Danh mục'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tất cả')),
                    ..._categories.map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.name))),
                  ],
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const Icon(Icons.date_range, size: 16),
                  label: Text(
                    _dateRange == null
                        ? 'Chọn ngày'
                        : '${_fmt(_dateRange!.start)} - ${_fmt(_dateRange!.end)}',
                  ),
                  onPressed: _pickDateRange,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${filtered.length} giao dịch',
                    style: const TextStyle(color: Colors.grey)),
                Row(children: [
                  Text(
                    '+${_fmtAmount(filtered.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount))}đ',
                    style: const TextStyle(color: Colors.green, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '-${_fmtAmount(filtered.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount))}đ',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ]),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Không có giao dịch nào'))
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, i) => _TransactionTile(
                      t: filtered[i],
                      onDelete: () async {
                        await DBHelper.deleteTransaction(filtered[i].id!);
                        _loadData();
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  String _fmtAmount(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}

class _TransactionTile extends StatelessWidget {
  final GiaoDich t;
  final VoidCallback onDelete;
  const _TransactionTile({required this.t, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = t.isIncome ? Colors.green : Colors.red;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(
          t.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        t.note ?? '(Không có ghi chú)',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${t.categoryName ?? 'Chưa phân loại'} • ${t.walletName ?? ''} • ${_fmtDate(t.date)}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${t.isIncome ? '+' : '-'}${_fmtAmount(t.amount)}đ',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  String _fmtDate(String? dateStr) {
    if (dateStr == null) return '';
    final d = DateTime.parse(dateStr);
    return '${d.day}/${d.month}/${d.year}';
  }

  String _fmtAmount(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
