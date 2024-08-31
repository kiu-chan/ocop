import 'package:ocop/mainData/database/councils.dart';
import 'package:ocop/mainData/user/authService.dart';
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
import 'package:ocop/src/data/home/companyData.dart';

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
  late CouncilsDatabase councilsDatabase;

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
      accountDatabase = AccountDatabase(connection!); // Đảm bảo dòng này có mặt
      areaDatabase = AreaDatabase(connection!);
      companyDatabase = CompanyDatabase(connection!);
      videosDatabase = VideosDatabase(connection!);
      councilsDatabase = CouncilsDatabase(connection!);
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

  Future<Map<String, int>> getProductRatingCounts() async {
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

  Future<Map<String, dynamic>> getProductDistrictCounts() async {
    return await productDatabase.getProductDistrictCounts();
  }

  Future<Map<String, int>> getProductYearCounts() async {
    return await productDatabase.getProductYearCounts();
  }

  Future<int> getTotalProductCount() async {
    return await productDatabase.getTotalProductCount();
  }

  Future<Map<String, int>> getProductStatusCounts() async {
    return await productDatabase.getProductStatusCounts();
  }

  Future<Map<String, dynamic>> getOcopFileDistrictCounts() async {
    return await productDatabase.getOcopFileDistrictCounts();
  }

  Future<Map<String, int>> getOcopFileYearCounts() async {
    return await productDatabase.getOcopFileYearCounts();
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

  Future<List<Map<String, dynamic>>> getAllNews(
      {int page = 1, int perPage = 10}) async {
    return await newsDatabase.getAllNews(page: page, perPage: perPage);
  }

  Future<String?> getNewsImage(int newsId) async {
    return await newsDatabase.getNewsImage(newsId);
  }

  Future<Map<String, dynamic>?> getAboutsContent(int aboutsId) async {
    return await newsDatabase.getAboutsContent(aboutsId);
  }

  Future<List<Map<String, dynamic>>> getMedia() async {
    return await mediaDatabase.getMedia();
  }

  Future<Map<String, dynamic>?> checkUserCredentials(
      String email, String password) async {
    return await accountDatabase.checkUserCredentials(email, password);
  }

  Future<bool> checkUserExists(String email) async {
    return await accountDatabase.checkUserExists(email);
  }

  Future<bool> createUser(
      String name, String email, String password, int communeId) async {
    return await accountDatabase.createUser(name, email, password, communeId);
  }

  Future<bool> updateUserInfo(int userId, Map<String, dynamic> newInfo) async {
    final userRole = await AuthService.getUserRole(); // Assume this method exists
    return await accountDatabase.updateUserInfo(userId, newInfo, userRole ?? 'unknown');
  }

  Future<bool> verifyUserPassword(int userId, String password, String userRole) async {
    return await accountDatabase.verifyUserPassword(userId, password, userRole);
  }

  Future<Map<String, dynamic>?> getCommuneInfo(int communeId) async {
    return await accountDatabase.getCommuneInfo(communeId);
  }

  Future<String> createPasswordResetToken(String email) async {
    return await accountDatabase.createPasswordResetToken(email);
  }

  Future<bool> verifyPasswordResetToken(String email, String code) async {
    return await accountDatabase.verifyPasswordResetToken(email, code);
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    return await accountDatabase.resetPassword(email, newPassword);
  }

  Future<int> getRemainingTimeForResetCode(String email) async {
    return await accountDatabase.getRemainingTimeForResetCode(email);
  }

  Future<bool> checkEmailExists(String email) async {
    return await accountDatabase.checkEmailExists(email);
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

  Future<List<Map<String, dynamic>>> getAllCommunes() async {
    return await areaDatabase.getAllCommunes();
  }

  Future<Map<String, dynamic>?> getCommune(int id) async {
    return await areaDatabase.getCommune(id);
  }

  Future<List<Map<String, dynamic>>> getAllDistricts() async {
    return await areaDatabase.getAllDistricts();
  }

  Future<Map<String, dynamic>?> getDistrict(int id) async {
    return await areaDatabase.getDistrict(id);
  }

  Future<List<Map<String, dynamic>>> getBorders() async {
    return await areaDatabase.getBorders();
  }

  Future<int> getProductCountForCommune(int communeId) async {
    return await areaDatabase.getProductCountForCommune(communeId);
  }

  Future<List<Company>> getRandomCompanies({int limit = 10}) async {
    return await companyDatabase.getRandomCompanies(limit: limit);
  }

  Future<Company?> getCompanyDetails(int id) async {
    return await companyDatabase.getCompanyDetails(id);
  }

  Future<List<Company>> getAllCompanies() async {
    return await companyDatabase.getAllCompanies();
  }

  Future<Map<String, int>> getCompanyTypeCounts() async {
    return await companyDatabase.getCompanyTypeCounts();
  }

  Future<Map<String, dynamic>> getCompanyDistrictCounts() async {
    return await companyDatabase.getCompanyDistrictCounts();
  }

  Future<Map<String, int>> getCompanyStatusCounts() async {
    return await companyDatabase.getCompanyStatusCounts();
  }

  Future<List<Map<String, dynamic>>> getCouncilList() async {
    return await councilsDatabase.getCouncilList();
  }

  Future<List<Map<String, dynamic>>> getCouncilProducts(int councilId) async {
    return await councilsDatabase.getCouncilProducts(councilId);
  }

  Future<Map<String, dynamic>> getProductEvaluationDetails(
      int productId, int councilId) async {
    return await councilsDatabase.getProductEvaluationDetails(
        productId, councilId);
  }

  Future<List<Map<String, dynamic>>> getEvaluationPoints(
      int evaluationId) async {
    return await councilsDatabase.getEvaluationPoints(evaluationId);
  }

  Future<int?> getProductEvaluationId(int productId) async {
    return await councilsDatabase.getProductEvaluationId(productId);
  }

  Future<List<int>> getCouncilUserIds(int councilGroupId) async {
    return await councilsDatabase.getCouncilUserIds(councilGroupId);
  }

  Future<void> close() async {
    await connection!.close();
    print('Connection closed.');
  }
}
