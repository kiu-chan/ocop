import 'package:flutter/material.dart';
import 'package:ocop/databases.dart'; // Đảm bảo đường dẫn đúng đến lớp DatabaseHelper

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProductsScreen(),
    );
  }
}

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late DefaultDatabaseOptions _databaseHelper;
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _databaseHelper = DefaultDatabaseOptions();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    await _databaseHelper.connect();
    var products = await _databaseHelper.getProducts();
    setState(() {
      _products = products;
    });
    await _databaseHelper.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ListTile(
            title: Text(product['name'] ?? 'No Name'),
            subtitle: Text(product['address'] ?? 'No Address'),
          );
        },
      ),
    );
  }
}
