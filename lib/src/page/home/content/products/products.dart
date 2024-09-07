import 'package:flutter/material.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:ocop/mainData/offline/offline_storage_service.dart';
import 'package:ocop/src/data/home/productHomeData.dart';
import 'package:ocop/src/page/home/content/products/elements/productCard.dart';
import 'package:ocop/src/page/home/content/products/elements/productsList.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ProductList extends StatefulWidget {
  const ProductList({Key? key}) : super(key: key);

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<ProductHome> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      isLoading = true;
    });

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // Không có kết nối mạng, tải dữ liệu offline
      final offlineProducts = await OfflineStorageService.getOfflineProducts();
      setState(() {
        products = offlineProducts;
        isLoading = false;
      });
    } else {
      // Có kết nối mạng, tải dữ liệu online
      final DefaultDatabaseOptions db = DefaultDatabaseOptions();
      try {
        await db.connect();
        final randomProducts = await db.getRandomProducts();
        setState(() {
          products = randomProducts.map((product) => ProductHome(
            id: product['id'],
            name: product['name'],
            star: product['rating'],
            category: product['category'] ?? 'Unknown',
            img: product['img'],
          )).toList();
        });

        // Lưu dữ liệu để sử dụng offline
        for (var product in products) {
          await OfflineStorageService.saveProduct(product);
        }
      } catch (e) {
        print('Lỗi khi tải dữ liệu online: $e');
        // Nếu có lỗi khi tải dữ liệu online, thử tải dữ liệu offline
        final offlineProducts = await OfflineStorageService.getOfflineProducts();
        setState(() {
          products = offlineProducts;
        });
      } finally {
        await db.close();
        setState(() {
          isLoading = false;
        });
      }
    }
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