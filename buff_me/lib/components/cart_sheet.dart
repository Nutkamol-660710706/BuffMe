import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/menu_item_model.dart';

class CartSheet extends StatefulWidget {
  final Map<String, int> cart;
  final List<MenuItem> menuItems;
  final Function(MenuItem) add;
  final Function(MenuItem) remove;

  const CartSheet({
    super.key,
    required this.cart,
    required this.menuItems,
    required this.add,
    required this.remove,
  });

  @override
  _CartSheetState createState() => _CartSheetState();
}

class _CartSheetState extends State<CartSheet> {
  late Map<String, int> _cart;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String tableName = 'โต๊ะ 1'; // ตั้งชื่อโต๊ะคงที่

  @override
  void initState() {
    super.initState();
    _cart = Map.from(widget.cart); // copy เพื่อจัดการ state ภายใน
  }

  void _addItem(MenuItem item) {
    setState(() {
      _cart[item.id] = (_cart[item.id] ?? 0) + 1;
    });
    widget.add(item);
  }

  void _removeItem(MenuItem item) {
    setState(() {
      if ((_cart[item.id] ?? 0) > 1) {
        _cart[item.id] = _cart[item.id]! - 1;
      } else {
        _cart.remove(item.id);
      }
    });
    widget.remove(item);
  }

Future<void> _confirmOrder() async {
  if (_cart.isEmpty) return;

  List<Map<String, dynamic>> items = _cart.entries.map((entry) {
    final item = widget.menuItems.firstWhere((i) => i.id == entry.key);
    return {
      "name": item.name,
      "quantity": entry.value,
    };
  }).toList();

  // บันทึกออเดอร์ลง Firestore
  await _db.collection('orders').add({
    "table_name": tableName,  // โต้ะคงที่
    "items": items,
    "order_time": Timestamp.now(),
    "status": "pending",
  });

  // เคลียร์ cart ทั้งใน state และ parent
  setState(() {
    _cart.clear();
  });
  widget.cart.clear();

  ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order confirmed!')));

  Navigator.pop(context); // ปิด cart sheet
}


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text('Cart - $tableName',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(),
          Expanded(
            child: ListView(
              children: _cart.entries.map((entry) {
                final item = widget.menuItems.firstWhere((i) => i.id == entry.key);
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('จำนวน ${entry.value}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () => _removeItem(item),
                          icon: const Icon(Icons.remove)),
                      IconButton(
                          onPressed: () => _addItem(item),
                          icon: const Icon(Icons.add)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _confirmOrder,
            child: const Text('ยืนยันสั่งอาหาร'),
          )
        ],
      ),
    );
  }
}
