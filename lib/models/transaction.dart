class GiaoDich {
  final int? id;
  final double amount;
  final String type; // 'income' | 'expense'
  final int? categoryId;
  final int? walletId;
  final String? note;
  final String? date;
  final String? createdAt;

  // Join fields (không lưu DB)
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final String? walletName;

  GiaoDich({
    this.id,
    required this.amount,
    required this.type,
    this.categoryId,
    this.walletId,
    this.note,
    this.date,
    this.createdAt,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.walletName,
  });

  bool get isIncome => type == 'income';

  Map<String, dynamic> toMap() => {
        'amount': amount,
        'type': type,
        'category_id': categoryId,
        'wallet_id': walletId,
        'note': note,
        'date': date,
        'created_at': createdAt ?? DateTime.now().toIso8601String(),
      };

  factory GiaoDich.fromMap(Map<String, dynamic> m) => GiaoDich(
        id: m['id'] as int?,
        amount: m['amount'] as double,
        type: m['type'] as String,
        categoryId: m['category_id'] as int?,
        walletId: m['wallet_id'] as int?,
        note: m['note'] as String?,
        date: m['date'] as String?,
        createdAt: m['created_at'] as String?,
        categoryName: m['category_name'] as String?,
        categoryIcon: m['category_icon'] as String?,
        categoryColor: m['category_color'] as String?,
        walletName: m['wallet_name'] as String?,
      );
}

class DanhMuc {
  final int? id;
  final String name;
  final String? type;
  final String? icon;
  final String? color;

  DanhMuc({this.id, required this.name, this.type, this.icon, this.color});

  Map<String, dynamic> toMap() => {
        'name': name,
        'type': type,
        'icon': icon,
        'color': color,
      };

  factory DanhMuc.fromMap(Map<String, dynamic> m) => DanhMuc(
        id: m['id'] as int?,
        name: m['name'] as String,
        type: m['type'] as String?,
        icon: m['icon'] as String?,
        color: m['color'] as String?,
      );
}

class Vi {
  final int? id;
  final String? name;
  final double? balance;
  final String? createdAt;

  Vi({this.id, this.name, this.balance, this.createdAt});

  Map<String, dynamic> toMap() => {
        'name': name,
        'balance': balance,
        'created_at': createdAt ?? DateTime.now().toIso8601String(),
      };

  factory Vi.fromMap(Map<String, dynamic> m) => Vi(
        id: m['id'] as int?,
        name: m['name'] as String?,
        balance: m['balance'] as double?,
        createdAt: m['created_at'] as String?,
      );
}
