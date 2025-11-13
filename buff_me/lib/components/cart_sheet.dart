import 'package:flutter/material.dart';
import '../model/menu_item_model.dart';

class CartSheet extends StatefulWidget {
  final Map<String, int> cart;
  final List<MenuItem> menuItems;
  final Function(MenuItem) add;     // แก้ให้รับจำนวน
  final Function(MenuItem) remove;  // แก้ให้รับจำนวน
  final double totalPrice;

  CartSheet({
    super.key,
    required this.cart,
    required this.menuItems,
    required this.add,
    required this.remove,
    required this.totalPrice,
  });

  @override
  _CartSheetState createState() => _CartSheetState();
}

class _CartSheetState extends State<CartSheet> {
  late Map<String, int> _cart;
  late double _totalPrice;

  @override
  void initState() {
    super.initState();
    _cart = Map.from(widget.cart); // copy เพื่อจัดการ state ภายใน
    _totalPrice = widget.totalPrice;
  }

  void _addItem(MenuItem item) {
    setState(() {
      _cart[item.id] = (_cart[item.id] ?? 0) + 1;
      _totalPrice += item.price;
    });
    widget.add(item);
  }

  void _removeItem(MenuItem item) {
    setState(() {
      if ((_cart[item.id] ?? 0) > 1) {
        _cart[item.id] = _cart[item.id]! - 1;
        _totalPrice -= item.price;
      } else {
        _cart.remove(item.id);
        _totalPrice -= item.price;
      }
    });
    widget.remove(item);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const Text('Cart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
          Text('Total: ${_totalPrice.toStringAsFixed(0)} ฿', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order confirmed!')));
              Navigator.pop(context);
            },
            child: const Text('ยืนยันสั่งอาหาร'),
          )
        ],
      ),
    );
  }
}
