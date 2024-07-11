import 'package:flutter/material.dart';
import 'package:ocop/src/data/home/productData.dart';
import 'package:ocop/src/page/home/content/products/elements/productInformation.dart';
import 'package:ocop/src/page/elements/star.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  
  ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductInformation(product: product),
            ),
          );
        },
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'lib/src/assets/img/map/img.png',
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 8),
              Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Star(value: 2),
            ],
          ),
        ),
      ),
    );
  }
}