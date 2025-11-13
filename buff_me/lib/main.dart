import 'package:flutter/material.dart';
import 'page/menu_page.dart';

void main() => runApp(BuffetApp());

class BuffetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buffet Menu',
      theme: ThemeData(primarySwatch: Colors.red),
      debugShowCheckedModeBanner: false,
      home: MenuPage(),
    );
  }
}
