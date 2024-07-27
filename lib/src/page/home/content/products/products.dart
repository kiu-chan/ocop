import 'package:flutter/material.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:ocop/src/data/home/productData.dart';
import 'package:ocop/src/page/home/content/products/elements/productCard.dart';
import 'package:ocop/src/page/home/content/products/elements/productsList.dart'; // Thêm import này
import 'package:latlong2/latlong.dart';


class ProductList extends StatefulWidget {
  const ProductList({Key? key}) : super(key: key);

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<Product> products = [];
  final DefaultDatabaseOptions db = DefaultDatabaseOptions();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    await db.connect();
    final randomProducts = await db.getRandomProducts();
    setState(() {
      products = randomProducts.map((product) => Product(
        id: product['id'],  // Thêm id
        name: product['name'],
        star: product['rating'],
        category: product['category'] ?? 'Unknown',
        // location: LatLng(0, 0),  // Giả sử là một vị trí mặc định
      )).toList();
    });
    await db.close();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 10.0),
              child: const Text(
                "Danh sách sản phẩm",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: 10.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProductsList()),
                  );
                },
                child: const Text(
                  "All",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
  height: 250,  // Điều chỉnh chiều cao nếu cần
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: products.length,
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          width: 180,  // Điều chỉnh chiều rộng nếu cần
          child: ProductCard(product: products[index]),
        ),
      );
    },
  ),
),
      ],
    );
  }
}