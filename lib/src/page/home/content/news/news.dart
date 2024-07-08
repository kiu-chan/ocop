import 'package:flutter/material.dart';

class NewsList extends StatelessWidget {
  final List<Product> products = [
    Product(name: 'Tin tức 1', news: "fwkfwifwifkbwifwibfwifbwofbwofnwdknqwidqkdsfnwkfnqofnwo"),
    Product(name: 'Tin tức 2', news: "fwkfwifwifkbwifwibfwifbwofbwofnwdknqwidqkdsfnwkfnqofnwo"),
    Product(name: 'Tin tức 3', news: "fwkfwifwifkbwifwibfwifbwofbwofnwdknqwidqkdsfnwkfnqofnwo"),
    Product(name: 'Tin tức 3', news: "fwkfwifwifkbwifwibfwifbwofbwofnwdknqwidqkdsfnwkfnqofnwo"),
    Product(name: 'Tin tức 3', news: "fwkfwifwifkbwifwibfwifbwofbwofnwdknqwidqkdsfnwkfnqofnwo"),
    Product(name: 'Tin tức 3', news: "fwkfwifwifkbwifwibfwifbwofbwofnwdknqwidqkdsfnwkfnqofnwo"),
    Product(name: 'Tin tức 3', news: "fwkfwifwifkbwifwibfwifbwofbwofnwdknqwidqkdsfnwkfnqofnwo"),
    // Thêm các tin tức khác vào đây
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
            padding: EdgeInsets.only(left: 10.0), 
            child: Text(
              "Tin tức",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
                ), // Văn bản in đậm
            ),
          ),
            Container(
            padding: EdgeInsets.only(right: 10.0), 
            child: Text(
              "All",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
                ), // Văn bản in đậm
            ),
          ),
          ],
        ),
        Container(
            height: 400,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductCard(product: products[index]);
              },
            )),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: EdgeInsets.all(8),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('${product.news} đ'),
          ],
        ),
      ),
    );
  }
}

class Product {
  final String name;
  final String news;

  Product({required this.name, required this.news});
}
