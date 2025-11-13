// Flutter package
import 'package:flutter/material.dart';

// Models
import '../model/menu_item_model.dart';

// Components
import '../components/menu_item_card.dart';
import '../components/cart_sheet.dart';
import '../components/menu_category_section.dart';

//page
import 'orderStatus_page.dart';



class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<MenuItem> menuItems = [
    MenuItem(id: 'm1', name: 'หมูสามชั้น', category: 'เนื้อสัตว์', price: 120, image: 'https://obs-ect.line-scdn.net/r/ect/ect/cj01YWszbTJicGFkYjFoJnM9anA2JnQ9bSZ1PTFmdjkzcWt0azR0ZzAmaT0w'),
    MenuItem(id: 'm2', name: 'เนื้อริบอาย', category: 'เนื้อสัตว์', price: 180, image: 'https://obs-ect.line-scdn.net/r/ect/ect/image_166885903983767806722dc7744t10b4eb8f'),
    MenuItem(id: 'v1', name: 'ผักกาดขาว', category: 'ผัก', price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ-VP6HtxHf37Godc1DLsS8_CR3BxklX0VPjQ&s'),
    MenuItem(id: 'v2', name: 'เห็ดเข็มทอง', category: 'ผัก', price: 30, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPyycrPLibxIryK7vt9DvErqAbvLI3Go6h7g&s'),
    MenuItem(id: 's1', name: 'เกี๊ยวกุ้งทอด', category: 'ของกินเล่น', price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSuzI_P6bVv097QJW4rt-iD9EjgJyiexLh-9Q&s'),
  ];

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

  Map<String, List<MenuItem>> get menuByCategory {
    Map<String, List<MenuItem>> map = {};
    for (var item in menuItems) {
      map.putIfAbsent(item.category, () => []);
      map[item.category]!.add(item);
    }
    return map;
  }

  double get totalPrice {
    double total = 0;
    cart.forEach((id, qty) {
      final item = menuItems.firstWhere((element) => element.id == id);
      total += item.price * qty;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buffet Menu'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
                if (cart.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        cart.length.toString(),
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => CartSheet(
                  cart: cart,
                  menuItems: menuItems,
                  add: addToCart,
                  remove: removeFromCart,
                  totalPrice: totalPrice,
                ),
              );
            },
          ),
        ],
      ),
body: Column(
  children: [
    Padding(
      padding: const EdgeInsets.all(12.0),
      child: ElevatedButton.icon(
        onPressed: () {
          // ไปหน้าติดตามสถานะออเดอร์
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderStatusPage(
            cart: cart,             // ส่ง map ของ cart
            menuItems: menuItems,   // ส่ง list ของ menuItems
          ),
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
),

    );
  }
}
