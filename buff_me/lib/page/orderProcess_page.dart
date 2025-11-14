import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderprocessPage extends StatefulWidget {
  const OrderprocessPage({super.key});

  @override
  State<OrderprocessPage> createState() => _OrderprocessPageState();
}

class _OrderprocessPageState extends State<OrderprocessPage> {
  final CollectionReference ordersRef =
      FirebaseFirestore.instance.collection('orders');

  final List<String> statusOptions = ['pending', 'processing', 'served', 'cancelled'];

  String statusText(String status) {
    switch (status) {
      case 'processing':
        return 'กำลังทำ';
      case 'served':
        return 'เสิร์ฟแล้ว';
      case 'cancelled':
        return 'ยกเลิก';
      case 'pending':
      default:
        return 'รอดำเนินการ';
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'processing':
        return Colors.orange;
      case 'served':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.grey;
    }
  }

  // เก็บสถานะแต่ละ doc ไว้ใน map เพื่อรีเฟรช UI
  Map<String, String> statusMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รับออเดอร์(สำหรับพนักงาน)')),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersRef.orderBy('order_time', descending: false).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) return const Center(child: Text('ยังไม่มีออเดอร์'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final List items = data['items'] ?? [];
              final Timestamp? orderTime = data['order_time'];

              // ใช้ statusMap เก็บสถานะปัจจุบัน
              String status = statusMap[doc.id] ?? data['status'] ?? 'pending';

              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [ 
                      if (data['table_name'] != null)
                        Text(
                          '${data['table_name']}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Column(
                        children: items.map<Widget>((item) {
                          final qty = (item['quantity'] is int)
                              ? item['quantity']
                              : (item['quantity'] is String)
                                  ? int.tryParse(item['quantity']) ?? 0
                                  : 0;
                          final name = item['name']?.toString() ?? "ไม่มีชื่อ";

                          return ListTile(
                            leading: const Icon(Icons.fastfood),
                            title: Text(name),
                            subtitle: Text('จำนวน $qty ชิ้น'),
                          );
                        }).toList(),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'สถานะ: ${statusText(status)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: statusColor(status),
                            ),
                          ),
                          DropdownButton<String>(
                            value: status,
                            items: statusOptions.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(statusText(s)),
                              );
                            }).toList(),
                            onChanged: (val) async {
                              if (val != null) {
                                // อัปเดต Firestore
                                await ordersRef.doc(doc.id).update({'status': val});
                                // อัปเดต state map
                                setState(() {
                                  statusMap[doc.id] = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (orderTime != null)
                        Text(
                          'เวลาสั่ง: ${orderTime.toDate()}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
