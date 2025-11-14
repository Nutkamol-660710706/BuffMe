import 'package:flutter/material.dart';
import '../model/menu_item_model.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final Function(MenuItem) addToCart;

  const MenuItemCard({super.key, required this.item, required this.addToCart});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Image.network(item.image, width: 50, height: 50, fit: BoxFit.cover),
        title: Text(item.name),
        trailing: IconButton(
          icon: Icon(Icons.add),
          onPressed: () => addToCart(item),
        ),
      ),
    );
  }
}
