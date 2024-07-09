import 'package:flutter/material.dart';
import 'package:ocop/src/page/home/content/products/products.dart';
import 'package:ocop/src/page/home/content/news/news.dart';

class homePage extends StatefulWidget {
  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Container(
          //   child: ProductList(),
          // ),
          SizedBox(
            height: 10,
          ),
          ProductList(),
          NewsList(),
        ],
      ),
    );
  }
}