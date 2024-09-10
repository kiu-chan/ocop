import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ocop/src/data/councils/councilData.dart';

class CouncilOfflineStorage {
  static const String _councilListKey = 'offline_council_list';
  static const String _councilProductsKey = 'offline_council_products';
  static const String _productEvaluationKey = 'offline_product_evaluation';

  static Future<void> saveCouncilList(List<Council> councils) async {
    final prefs = await SharedPreferences.getInstance();
    final councilsJson = councils.map((council) => council.toJson()).toList();
    await prefs.setString(_councilListKey, json.encode(councilsJson));
  }

  static Future<List<Council>> getCouncilList() async {
    final prefs = await SharedPreferences.getInstance();
    final councilsJson = prefs.getString(_councilListKey);
    if (councilsJson != null) {
      final List<dynamic> decoded = json.decode(councilsJson);
      return decoded.map((item) => Council.fromJson(item)).toList();
    }
    return [];
  }

  static Future<void> saveCouncilProducts(int councilId, List<Map<String, dynamic>> products) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_councilProductsKey}_$councilId';
    await prefs.setString(key, json.encode(products));
  }

  static Future<List<Map<String, dynamic>>> getCouncilProducts(int councilId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_councilProductsKey}_$councilId';
    final productsJson = prefs.getString(key);
    if (productsJson != null) {
      final List<dynamic> decoded = json.decode(productsJson);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<void> saveProductEvaluation(int productId, Map<String, dynamic> evaluation) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_productEvaluationKey}_$productId';
    await prefs.setString(key, json.encode(evaluation));
  }

  static Future<Map<String, dynamic>?> getProductEvaluation(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_productEvaluationKey}_$productId';
    final evaluationJson = prefs.getString(key);
    if (evaluationJson != null) {
      return json.decode(evaluationJson);
    }
    return null;
  }

  static Future<bool> hasOfflineData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

    static Future<void> saveProductList(int councilId, List<Map<String, dynamic>> products) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'products_$councilId';
    await prefs.setString(key, jsonEncode(products));
  }

  static Future<List<Map<String, dynamic>>> getProductList(int councilId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'products_$councilId';
    final productsJson = prefs.getString(key);
    if (productsJson != null) {
      final List<dynamic> decodedList = jsonDecode(productsJson);
      return decodedList.cast<Map<String, dynamic>>();
    }
    return [];
  }
}