import 'package:flutter/material.dart';

class ProductList extends StatelessWidget {
  final List<Product> products = [
    Product(name: 'Sản phẩm 1', price: 100),
    Product(name: 'Sản phẩm 2', price: 200),
    Product(name: 'Sản phẩm 3', price: 300),
    // Thêm các sản phẩm khác vào đây
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
              "Danh sách sản phẩm",
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
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
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
            Text('${product.price} đ'),
          ],
        ),
      ),
    );
  }
}

class Product {
  final String name;
  final int price;

  Product({required this.name, required this.price});
}
