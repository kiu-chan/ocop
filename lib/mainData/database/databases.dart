import 'package:postgres/postgres.dart';
import 'package:ocop/src/data/map/productMapData.dart';
import 'package:ocop/mainData/database/product.dart';
import 'package:ocop/src/data/map/companiesData.dart';
import 'package:ocop/mainData/database/media.dart';
import 'package:ocop/mainData/database/account.dart';
import 'package:ocop/mainData/database/area.dart';
import 'package:ocop/mainData/database/news.dart';
import 'package:ocop/mainData/database/company.dart';
import 'package:ocop/mainData/database/videos.dart';
import 'package:ocop/src/data/home/videosData.dart';

class DefaultDatabaseOptions {
  bool _connectionFailed = false;
  PostgreSQLConnection? connection;
  late ProductDatabase productDatabase;
  late MediaDatabase mediaDatabase;
  late AccountDatabase accountDatabase;
  late AreaDatabase areaDatabase;
  late NewsDatabase newsDatabase;
  late CompanyDatabase companyDatabase;
  late VideosDatabase videosDatabase;

  Future<void> connect() async {
    try {
      connection = PostgreSQLConnection(
        '163.44.193.74',
        5432,
        'bentre_ocop',
        username: 'postgres',
        password: 'yfti*m0xZYtRy3QfF)tV',
      );
      
      await connection!.open();
      print('Connected to PostgreSQL database.');
      _connectionFailed = false;

      productDatabase = ProductDatabase(connection!);
      newsDatabase = NewsDatabase(connection!);
      mediaDatabase = MediaDatabase(connection!);
      accountDatabase = AccountDatabase(connection!);
      areaDatabase = AreaDatabase(connection!);
      areaDatabase = AreaDatabase(connection!);
      companyDatabase = CompanyDatabase(connection!);
      videosDatabase = VideosDatabase(connection!);
    } catch (e) {
      print('Failed to connect to database: $e');
      _connectionFailed = true;
    }
  }
  bool get connectionFailed => _connectionFailed;

  // Tách tọa độ từ chuỗi
  // RegExp regex = RegExp(r'POINT\(([^ ]+) ([^ ]+)\)');
  // Match match = regex.firstMatch();

  Future<List<ProductData>> getProducts() async {
    return await productDatabase.getProducts();
  }
  
  Future<Map<String, int>> getProductRatingCounts() async  {
    return await productDatabase.getProductRatingCounts();
  }

  Future<Map<String, int>> getProductCategoryCounts() async {
    return await productDatabase.getProductCategoryCounts();
  }

  Future<Map<String, int>> getProductGroupCounts() async {
    return await productDatabase.getProductGroupCounts();
  }

  Future<List<Map<String, dynamic>>> getProductProcesses() async {
    return await productDatabase.getProductProcesses();
  }
  
  Future<List<Map<String, dynamic>>> getRandomProducts() async {
    return await productDatabase.getRandomProducts();
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    return await productDatabase.getAllProducts();
  }

  Future<String?> getProductContent(int productId) async {
    return await productDatabase.getProductContent(productId);
  }

  Future<List<String>> getProductImages(int productId) async {
    return await productDatabase.getProductImages(productId);
  }

  Future<String?> getProductAddress(int productId) async {
  return await productDatabase.getProductAddress(productId);
  }

  Future<Map<String, dynamic>> getProductDetails(int productId) async {
    return await productDatabase.getProductDetails(productId);
  }
Future<Map<String, dynamic>> getProductCommuneCounts() async {
    return await productDatabase.getProductCommuneCounts();
  }

  Future<List<Map<String, dynamic>>> getRandomNews({int limit = 10}) async {
    return await newsDatabase.getRandomNews(limit: limit);
  }

  Future<String?> getFullNewsContent(String newsTitle) async {
    return await newsDatabase.getFullNewsContent(newsTitle);
  }

  Future<String?> getNewsContent(int newsId) async {
    return await newsDatabase.getNewsContent(newsId);
  }

  Future<List<Map<String, dynamic>>> getAllNews({int page = 1, int perPage = 10}) async {
    return await newsDatabase.getAllNews(page: page, perPage: perPage);
  }

  Future<String?> getNewsImage(int newsId) async {
    return await newsDatabase.getNewsImage(newsId);
  }

  Future<List<Map<String, dynamic>>> getMedia() async {
    return await mediaDatabase.getMedia();
  }

  Future<Map<String, dynamic>?> checkUserCredentials(String email, String password) async {
    return await accountDatabase.checkUserCredentials(email, password);
  }

  Future<bool> checkUserExists(String email) async {
    return await accountDatabase.checkUserExists(email);
  }

  Future<bool> createUser(String name, String email, String password, int communeId) async {
    return await accountDatabase.createUser(name, email, password, communeId);
  }

  Future<List<Map<String, dynamic>>> getApprovedCommunes() async {
    return await areaDatabase.getApprovedCommunes();
  }

  Future<List<CompanyData>> getCompanies() async {
    return await companyDatabase.getCompanies();
  }

  Future<List<VideoData>> getAllVideo() async {
    return await videosDatabase.getAllVideo();
  }

  Future<void> close() async {
    await connection!.close();
    print('Connection closed.');
  }
}
