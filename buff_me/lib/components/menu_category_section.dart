import 'package:flutter/material.dart';
import 'menu_item_card.dart';
import '../model/menu_item_model.dart';

class MenuCategorySection extends StatelessWidget {
  final String categoryName;
  final List<MenuItem> items;
  final Function(MenuItem) addToCart;

  MenuCategorySection({
    required this.categoryName,
    required this.items,
    required this.addToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            categoryName,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ...items.map((item) => MenuItemCard(item: item, addToCart: addToCart)),
      ],
    );
  }
}
