import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ocop/src/data/home/productHomeData.dart';

class OfflineStorageService {
  static const String _productsKey = 'offline_products';

  static Future<void> saveProduct(ProductHome product) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> products = prefs.getStringList(_productsKey) ?? [];
    
    // Convert ProductHome to JSON string
    String productJson = jsonEncode({
      'id': product.id,
      'name': product.name,
      'star': product.star,
      'category': product.category,
      'img': product.img,
      'describe': product.describe,
      'address': product.address,
      'companyName': product.companyName,
      'companyId': product.companyId,
      'phoneNumber': product.phoneNumber,
      'representative': product.representative,
      'email': product.email,
      'website': product.website,
      'latitude': product.latitude,
      'longitude': product.longitude,
      'district': product.district,
    });
    
    products.add(productJson);
    await prefs.setStringList(_productsKey, products);
  }

  static Future<List<ProductHome>> getOfflineProducts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> products = prefs.getStringList(_productsKey) ?? [];
    
    return products.map((productJson) {
      Map<String, dynamic> productMap = jsonDecode(productJson);
      return ProductHome(
        id: productMap['id'],
        name: productMap['name'],
        star: productMap['star'],
        category: productMap['category'],
        img: productMap['img'],
        describe: productMap['describe'],
        address: productMap['address'],
        companyName: productMap['companyName'],
        companyId: productMap['companyId'],
        phoneNumber: productMap['phoneNumber'],
        representative: productMap['representative'],
        email: productMap['email'],
        website: productMap['website'],
        latitude: productMap['latitude'],
        longitude: productMap['longitude'],
        district: productMap['district'],
        isOfflineAvailable: true,
      );
    }).toList();
  }

  static Future<void> removeProduct(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> products = prefs.getStringList(_productsKey) ?? [];
    
    products.removeWhere((productJson) {
      Map<String, dynamic> productMap = jsonDecode(productJson);
      return productMap['id'] == productId;
    });
    
    await prefs.setStringList(_productsKey, products);
  }
}