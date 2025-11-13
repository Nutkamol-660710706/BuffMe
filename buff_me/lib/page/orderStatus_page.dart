import 'package:flutter/material.dart';
import '../model/menu_item_model.dart';

// ย้าย enum และ class ออกมาด้านบน
enum OrderStatus { processing, served, cancelled }

class Order {
  final MenuItem item;
  final int quantity;
  final OrderStatus status;

  Order({required this.item, required this.quantity, required this.status});
}

class OrderStatusPage extends StatelessWidget {
  final Map<String, int> cart;
  final List<MenuItem> menuItems;

  OrderStatusPage({super.key, required this.cart, required this.menuItems});

  // ฟังก์ชันจำลองสถานะออเดอร์
  List<Order> get orders {
    List<Order> list = [];
    cart.forEach((id, qty) {
      final item = menuItems.firstWhere((i) => i.id == id);
      // ตัวอย่าง: สุ่มสถานะ
      final status = (id.hashCode % 3 == 0)
          ? OrderStatus.served
          : (id.hashCode % 3 == 1)
              ? OrderStatus.processing
              : OrderStatus.cancelled;

      list.add(Order(item: item, quantity: qty, status: status));
    });
    return list;
  }

  String statusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
        return 'กำลังทำ';
      case OrderStatus.served:
        return 'เสิร์ฟแล้ว';
      case OrderStatus.cancelled:
        return 'ยกเลิก';
    }
  }

  Color statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
        return Colors.orange;
      case OrderStatus.served:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderList = orders;
    return Scaffold(
      appBar: AppBar(title: const Text('ติดตามสถานะออเดอร์')),
      body: orderList.isEmpty
          ? const Center(child: Text('ยังไม่มีออเดอร์'))
          : ListView.builder(
              itemCount: orderList.length,
              itemBuilder: (context, index) {
                final order = orderList[index];
                return ListTile(
                  leading: Image.network(order.item.image,
                      width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(order.item.name),
                  subtitle: Text('จำนวน ${order.quantity} ชิ้น'),
                  trailing: Text(
                    statusText(order.status),
                    style: TextStyle(
                        color: statusColor(order.status),
                        fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
    );
  }
}
