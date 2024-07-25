import 'package:flutter/material.dart';
import 'package:ocop/databases.dart';
import 'package:ocop/src/data/home/productData.dart';
import 'package:ocop/src/page/home/content/products/elements/productCard.dart';import 'package:latlong2/latlong.dart';


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
  int selectedStars = 0; // 0 means no star filter
  Set<String> selectedCategories = {};
  List<String> allCategories = [];

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
  id: product['id'],  // Thêm id
  name: product['name'],
  star: product['rating'],
  category: product['category'] ?? 'Unknown',
  // location: LatLng(0, 0),  // Giả sử là một vị trí mặc định
)).toList();
      displayedProducts = List.from(allProducts);
      allCategories = allProducts.map((p) => p.category).toSet().toList();
      isLoading = false;
    });
    await db.close();
  }

  void filterProducts() {
    setState(() {
      displayedProducts = allProducts.where((product) {
        bool nameMatch = product.name.toLowerCase().contains(searchController.text.toLowerCase());
        bool starMatch = selectedStars == 0 || product.star == selectedStars;
        bool categoryMatch = selectedCategories.isEmpty || selectedCategories.contains(product.category);
        return nameMatch && starMatch && categoryMatch;
      }).toList();
    });
  }

  Widget buildStarFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < selectedStars ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () {
            setState(() {
              selectedStars = index + 1;
              filterProducts();
            });
          },
        );
      }),
    );
  }

  Widget buildCategoryFilter() {
    return Column(
      children: allCategories.map((category) {
        return CheckboxListTile(
          title: Text(category),
          value: selectedCategories.contains(category),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                selectedCategories.add(category);
              } else {
                selectedCategories.remove(category);
              }
              filterProducts();
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả sản phẩm'),
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Tìm kiếm sản phẩm',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) => filterProducts(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Lọc theo số sao:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              buildStarFilter(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Lọc theo danh mục:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              buildCategoryFilter(),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedStars = 0;
                    selectedCategories.clear();
                    searchController.clear();
                    filterProducts();
                  });
                },
                child: Text('Xóa bộ lọc'),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Hiển thị ${displayedProducts.length} sản phẩm',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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