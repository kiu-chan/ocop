import 'package:flutter/material.dart';
import 'package:ocop/databases.dart';
import 'package:ocop/src/data/home/productData.dart';
import 'package:ocop/src/page/home/content/products/elements/productCard.dart';

class ProductsList extends StatefulWidget {
  const ProductsList({Key? key}) : super(key: key);

  @override
  _ProductsListState createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  List<Product> allProducts = [];
  List<Product> displayedProducts = [];
  final DefaultDatabaseOptions db = DefaultDatabaseOptions();
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllProducts();
  }

  Future<void> _loadAllProducts() async {
    setState(() {
      isLoading = true;
    });
    await db.connect();
    final products = await db.getAllProducts();
    setState(() {
      allProducts = products.map((product) => Product(
        name: product['name'],
        star: product['rating'],
        category: product['category'] ?? 'Unknown',
      )).toList();
      displayedProducts = List.from(allProducts);
      isLoading = false;
    });
    await db.close();
  }

  void filterProducts(String query) {
    setState(() {
      displayedProducts = allProducts
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả sản phẩm'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm sản phẩm',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: filterProducts,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: displayedProducts.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: displayedProducts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}