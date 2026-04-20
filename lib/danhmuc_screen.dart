import 'package:flutter/material.dart';
import 'danhmuc.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CategoryService service = CategoryService();

  List<Map> list = [];

  TextEditingController tenController = TextEditingController();
  TextEditingController tienController = TextEditingController();

  String loai = 'chi_tieu';
  String mau = '0xFF2196F3';
  String icon = 'category';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    list = await service.layTatCa();
    setState(() {});
  }

  themDanhMuc() async {
    if (tenController.text.isEmpty || tienController.text.isEmpty) return;

    double soTien = double.parse(tienController.text);

    await service.them(
      tenController.text,
      loai,
      soTien,
      mau,
      icon,
    );

    tenController.clear();
    tienController.clear();

    loadData();
  }

  xoaDanhMuc(int id) async {
    await service.xoa(id);
    loadData();
  }

  // chọn màu
  Widget chonMau(String colorCode, Color color) {
    bool isSelected = mau == colorCode;

    return GestureDetector(
      onTap: () {
        setState(() {
          mau = colorCode;
        });
      },
      child: Container(
        width: 35,
        height: 35,
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
        child: isSelected
            ? Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }

  // chọn icon
Widget chonIcon(IconData ic, String name) {
  bool isSelected = icon == name;

  return GestureDetector(
    onTap: () {
      setState(() {
        icon = name;
      });
    },
    child: Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey,
          width: 1.5,
        ),
      ),
      child: Icon(
        ic,
        size: 30,
        color: isSelected ? Colors.blue : Colors.black,
      ),
    ),
  );
}

  // map icon
  IconData getIcon(String name) {
    switch (name) {
      case 'fastfood':
        return Icons.fastfood;
      case 'car':
        return Icons.directions_car;
      case 'school':
        return Icons.school;
      case 'money':
        return Icons.attach_money;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh mục"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // FORM
          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                TextField(
                  controller: tenController,
                  decoration: InputDecoration(
                    labelText: "Tên danh mục",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: tienController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Số tiền",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),

                // loại
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: Text("Chi tiêu"),
                        value: 'chi_tieu',
                        groupValue: loai,
                        onChanged: (value) {
                          setState(() {
                            loai = value.toString();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile(
                        title: Text("Thu nhập"),
                        value: 'thu_nhap',
                        groupValue: loai,
                        onChanged: (value) {
                          setState(() {
                            loai = value.toString();
                          });
                        },
                      ),
                    ),
                  ],
                ),

                // chọn màu
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    chonMau('0xFFF44336', Colors.red),
                    chonMau('0xFF4CAF50', Colors.green),
                    chonMau('0xFF2196F3', Colors.blue),
                    chonMau('0xFFFF9800', Colors.orange),
                  ],
                ),

                // chọn icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    chonIcon(Icons.fastfood, 'fastfood'),
                    chonIcon(Icons.directions_car, 'car'),
                    chonIcon(Icons.school, 'school'),
                    chonIcon(Icons.attach_money, 'money'),
                  ],
                ),

                SizedBox(height: 10),

                ElevatedButton(
                  onPressed: themDanhMuc,
                  child: Text("Thêm danh mục"),
                ),
              ],
            ),
          ),

          // LIST
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                var item = list[index];

                Color color = Color(int.parse(item['mau']));

                return Card(
                  margin:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.2),
                      child: Icon(
                        getIcon(item['icon']),
                        color: color,
                      ),
                    ),
                    title: Text(
                      item['ten'],
                      style: TextStyle(
                          color: color, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                        "${item['loai']} - ${item['so_tien']} đ"),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          xoaDanhMuc(item['id']),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}