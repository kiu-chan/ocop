import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:ocop/mainData/database/databases.dart';
import 'package:ocop/src/data/map/productMapData.dart';
import 'package:ocop/src/data/map/companiesData.dart';
import 'package:ocop/src/data/map/areaData.dart';
import 'package:ocop/src/data/map/ImageData.dart';
import 'package:latlong2/latlong.dart';

class MapDataLoader {
  late DefaultDatabaseOptions databaseData;
  List<ProductData> products = [];
  List<CompanyData> companies = [];
  List<AreaData> communes = [];
  List<AreaData> districts = [];
  List<AreaData> borders = [];
  List<ImageData> imageDataList = [];

  MapDataLoader() {
    databaseData = DefaultDatabaseOptions();
  }

  Future<void> loadData() async {
    await databaseData.connect();
    if (databaseData.connectionFailed) {
      await _loadOfflineData();
    } else {
      await _loadOnlineData();
      await _loadAllAreasData();
    }
    _updateImageDataList();
  }

  Future<void> _loadOnlineData() async {
    var productsData = await databaseData.getProducts();
    var companiesData = await databaseData.getCompanies();
    _updateProductList(productsData);
    _updateCompanyList(companiesData);
  }

  Future<void> _loadOfflineData() async {
    String jsonString = await rootBundle.loadString('lib/src/assets/offline_products.json');
    List<dynamic> jsonList = json.decode(jsonString);
    var productsData = jsonList.map((json) => ProductData.fromJson(json)).toList();
    _updateProductList(productsData);
  }

  Future<void> _loadAllAreasData() async {
    var communesData = await databaseData.getAllCommunes();
    var districtsData = await databaseData.getAllDistricts();
    var bordersData = await databaseData.getBorders();
    
    communes = communesData.map((json) {
      try {
        return AreaData.fromJson(json);
      } catch (e) {
        print('Error creating AreaData for commune: $e');
        return null;
      }
    }).where((area) => area != null).cast<AreaData>().toList();

    districts = districtsData.map((json) {
      try {
        return AreaData.fromJson(json);
      } catch (e) {
        print('Error creating AreaData for district: $e');
        return null;
      }
    }).where((area) => area != null).cast<AreaData>().toList();

    borders = bordersData.map((json) {
      try {
        return AreaData.fromJson(json);
      } catch (e) {
        print('Error creating AreaData for border: $e');
        return null;
      }
    }).where((area) => area != null).cast<AreaData>().toList();

    print("Loaded ${communes.length} communes, ${districts.length} districts, and ${borders.length} borders");
  }

  void _updateProductList(List<ProductData> productsData) {
    products = productsData;
  }

  void _updateCompanyList(List<CompanyData> companiesData) {
    companies = companiesData;
  }

  void _updateImageDataList() {
    Map<String, List<LatLng>> groupedLatLngs = {};
    for (var product in products) {
      if (!groupedLatLngs.containsKey(product.categoryName)) {
        groupedLatLngs[product.categoryName] = [];
      }
      groupedLatLngs[product.categoryName]!.add(product.location);
    }
    imageDataList = groupedLatLngs.entries.map((entry) {
      String imagePath;
      switch (entry.key) {
        case "Thực phẩm":
          imagePath = 'lib/src/assets/img/map/food.png';
          break;
        case "Đồ uống":
          imagePath = 'lib/src/assets/img/map/drink.png';
          break;
        case "Dược liệu và sản phẩm từ dược liệu":
          imagePath = 'lib/src/assets/img/map/herbal.png';
          break;
        case "Thủ công mỹ nghệ":
          imagePath = 'lib/src/assets/img/map/craft.png';
          break;
        case "Sinh vật cảnh":
          imagePath = 'lib/src/assets/img/map/pet.png';
          break;
        case "Dịch vụ du lịch cộng đồng, du lịch sinh thái và điểm du lịch":
          imagePath = 'lib/src/assets/img/map/tourism.png';
          break;
        default:
          imagePath = 'lib/src/assets/img/settings/ic_launcher.png';
      }
      return ImageData(
        imagePath,
        entry.key,
        entry.value,
      );
    }).toList();
  }

  Future<Map<String, dynamic>?> getCommuneDetails(int communeId) async {
    return await databaseData.getCommune(communeId);
  }

  Future<void> close() async {
    await databaseData.close();
  }

  Future<int> getProductCountForCommune(int communeId) async {
    return await databaseData.getProductCountForCommune(communeId);
  }
}