import 'package:flutter/material.dart';
import 'package:ocop/src/data/home/productData.dart';
import 'package:ocop/src/page/home/content/products/elements/productCard.dart';
import 'package:ocop/src/page/home/content/products/elements/productInformation.dart';

class ProductList extends StatelessWidget {
  final List<Product> products = [
    Product(name: 'Sản phẩm 1', star: 5, category: 'Thực phẩm'),
    Product(name: 'Sản phẩm 2', star: 1, category: 'Thực phẩm'),
    Product(name: 'Sản phẩm 3', star: 3, category: 'Thực phẩm'),
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
          // GestureDetector(
          //             onTap: () {
          //               Navigator.push(
          //                 context,
          //                 MaterialPageRoute(builder: (context) => ProductInformation()),
          //               );
          //             },
          //             child: const Text(
          //               'Đăng ký',
          //               style: TextStyle(
          //                 fontSize: 16,
          //                 decoration: TextDecoration.underline, // Hiển thị chữ dưới gạch chân
          //                 color: Colors.blue, // Màu chữ xanh
          //               ),
          //             ),
          //           ),
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
