import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Models
import '../model/menu_item_model.dart';

// Components
import '../components/cart_sheet.dart';
import '../components/menu_category_section.dart';

// Page
import 'orderStatus_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Map<String, int> cart = {};

  void addToCart(MenuItem item) {
    setState(() {
      cart[item.id] = (cart[item.id] ?? 0) + 1;
    });
  }

  void removeFromCart(MenuItem item) {
    setState(() {
      if (cart.containsKey(item.id)) {
        if (cart[item.id]! > 1) {
          cart[item.id] = cart[item.id]! - 1;
        } else {
          cart.remove(item.id);
        }
      }
    });
  }

  Map<String, List<MenuItem>> groupMenuByCategory(List<MenuItem> menuItems) {
    Map<String, List<MenuItem>> map = {};
    for (var item in menuItems) {
      map.putIfAbsent(item.category, () => []);
      map[item.category]!.add(item);
    }
    return map;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buffet Menu'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (cart.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: Colors.red,
                      // child: Text(
                      //   cart.length.toString(),
                      //   style: const TextStyle(fontSize: 12, color: Colors.white),
                      // ),
                    ),
                  ),
              ],
            ),
            onPressed: () async {
              // โหลดเมนูก่อนเปิด cart sheet
              final snapshot = await _db.collection('menu').get();
              final menuItems = snapshot.docs.map((doc) {
                final data = doc.data();
                return MenuItem(
                  id: doc.id,
                  name: data['name'] ?? '',
                  category: data['category'] ?? '',
                  image: data['image'] ?? '',
                );
              }).toList();

              showModalBottomSheet(
                context: context,
                builder: (_) => CartSheet(
                  cart: cart,
                  menuItems: menuItems,
                  add: addToCart,
                  remove: removeFromCart,
                  //totalPrice: 0,
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('menu').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final menuItems = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return MenuItem(
              id: doc.id,
              name: data['name'] ?? '',
              category: data['category'] ?? '',
              image: data['image'] ?? '',
            );
          }).toList();

          final menuByCategory = groupMenuByCategory(menuItems);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderStatusPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.track_changes),
                  label: const Text('ติดตามสถานะออเดอร์'),
                ),
              ),
              Expanded(
                child: ListView(
                  children: menuByCategory.entries.map((entry) {
                    return MenuCategorySection(
                      categoryName: entry.key,
                      items: entry.value,
                      addToCart: addToCart,
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
