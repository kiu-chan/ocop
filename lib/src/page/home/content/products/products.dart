import 'package:flutter/material.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:ocop/mainData/offline/offline_storage_service.dart';
import 'package:ocop/src/data/home/productHomeData.dart';
import 'package:ocop/src/page/home/content/products/elements/productCard.dart';
import 'package:ocop/src/page/home/content/products/elements/productsList.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  ProductListState createState() => ProductListState();
}

class ProductListState extends State<ProductList> {
  List<ProductHome> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void loadProducts() {
    // Call your existing method to load products
    _loadProducts();
  }
  Future<void> _loadProducts() async {
    setState(() {
      isLoading = true;
    });

    List<ProductHome> onlineProducts = [];
    List<ProductHome> offlineProducts = [];

    offlineProducts = await OfflineStorageService.getOfflineProducts();

    bool result = await InternetConnectionChecker().hasConnection;
    if (result) {
      final DefaultDatabaseOptions db = DefaultDatabaseOptions();
      try {
        await db.connect();
        final randomProducts = await db.getRandomProducts();
        onlineProducts = randomProducts.map((product) => ProductHome(
          id: product['id'],
          name: product['name'],
          star: product['rating'],
          category: product['category'] ?? 'Unknown',
          img: product['img'],
        )).toList();
      } catch (e) {
        print('Lỗi khi tải dữ liệu online: $e');
      } finally {
        await db.close();
      }
    }

    // Kết hợp dữ liệu online và offline, ưu tiên dữ liệu offline
    Map<int, ProductHome> productMap = {};
    for (var product in offlineProducts) {
      productMap[product.id] = product;
    }
    for (var product in onlineProducts) {
      if (!productMap.containsKey(product.id)) {
        productMap[product.id] = product;
      }
    }

    setState(() {
      products = productMap.values.toList();
      isLoading = false;
    });
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
                  "Xem tất cả",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        isLoading
            ? const CircularProgressIndicator()
            : SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        width: 180,
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