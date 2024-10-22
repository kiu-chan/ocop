import 'package:flutter/material.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:ocop/src/data/home/productHomeData.dart';
import 'package:ocop/src/page/home/content/products/elements/productCard.dart';

class ProductsList extends StatefulWidget {
  const ProductsList({super.key});

  @override
  _ProductsListState createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  List<ProductHome> allProducts = [];
  List<ProductHome> displayedProducts = [];
  final DefaultDatabaseOptions db = DefaultDatabaseOptions();
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  int selectedStars = 0; // 0 means no star filter
  Set<String> selectedCategories = {};
  Set<String> selectedDistricts = {}; // New: for district filter
  List<String> allCategories = [];
  List<String> allDistricts = []; // New: for district filter

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
      allProducts = products
          .map((product) => ProductHome(
                id: product['id'],
                name: product['name'],
                star: product['rating'],
                category: product['category'] ?? 'Unknown',
                img: product['img'],
                district:
                    product['district'] ?? 'Unknown', // New: added district
              ))
          .toList();
      displayedProducts = List.from(allProducts);
      allCategories = allProducts.map((p) => p.category).toSet().toList();
      allDistricts = allProducts
          .map((p) => p.district!)
          .toSet()
          .toList(); // New: get all districts
      isLoading = false;
    });
    await db.close();
  }

  void filterProducts() {
    setState(() {
      displayedProducts = allProducts.where((product) {
        bool nameMatch = product.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
        bool starMatch = selectedStars == 0 || product.star == selectedStars;
        bool categoryMatch = selectedCategories.isEmpty ||
            selectedCategories.contains(product.category);
        bool districtMatch = selectedDistricts.isEmpty ||
            selectedDistricts
                .contains(product.district); // New: district filter
        return nameMatch && starMatch && categoryMatch && districtMatch;
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

  // New: District filter
  Widget buildDistrictFilter() {
    return Column(
      children: allDistricts.map((district) {
        return CheckboxListTile(
          title: Text(district),
          value: selectedDistricts.contains(district),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                selectedDistricts.add(district);
              } else {
                selectedDistricts.remove(district);
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
                icon: const Icon(Icons.search),
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
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) => filterProducts(),
                ),
              ),
              ExpansionTile(
                title: const Text('Lọc theo số sao'),
                children: [
                  buildStarFilter(),
                ],
              ),
              ExpansionTile(
                title: const Text('Lọc theo danh mục'),
                children: [
                  buildCategoryFilter(),
                ],
              ),
              ExpansionTile(
                title: const Text('Lọc theo huyện'),
                children: [
                  buildDistrictFilter(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedStars = 0;
                      selectedCategories.clear();
                      selectedDistricts.clear();
                      searchController.clear();
                      filterProducts();
                    });
                  },
                  child: const Text('Xóa bộ lọc'),
                ),
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
