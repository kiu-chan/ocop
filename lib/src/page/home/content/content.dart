import 'package:flutter/material.dart';
import 'package:ocop/src/page/home/content/products/products.dart';

class Content extends StatefulWidget {
  const Content({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("data"),
          ProductList(),
          // Thêm các thành phần khác vào sau ListView nằm ngang
          Container(
            height: 100.0,
            color: Colors.orange,
            child: Center(child: Text('Thành phần khác 1')),
          ),
          Container(
            height: 100.0,
            color: Colors.purple,
            child: Center(child: Text('Thành phần khác 2')),
          ),
        ],
      ),
    );
  }
}
