import 'dart:convert';
import 'package:ocop/src/data/home/productHomeData.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:ocop/src/data/home/companyData.dart';

class CompanyOfflineStorage {
  static const String _companiesKey = 'offline_companies';

  static Future<void> saveCompany(Company company) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedCompanies = prefs.getStringList(_companiesKey) ?? [];

    // Download and encode logo
    String? encodedLogo;
    if (company.logoUrl != null) {
      try {
        final response = await http.get(Uri.parse(company.logoUrl!));
        if (response.statusCode == 200) {
          encodedLogo = base64Encode(response.bodyBytes);
        }
      } catch (e) {
        print('Error downloading logo: $e');
      }
    }

    // Convert Company to JSON string
    String companyJson = jsonEncode({
      'id': company.id,
      'name': company.name,
      'typeName': company.typeName,
      'communeName': company.communeName,
      'districtName': company.districtName,
      'encodedLogo': encodedLogo,
      'introduction': company.introduction,
      'address': company.address,
      'phoneNumber': company.phoneNumber,
      'representative': company.representative,
      'website': company.website,
      'email': company.email,
      'latitude': company.latitude,
      'longitude': company.longitude,
      'products': company.products.map((p) => p.toJson()).toList(),
    });

    savedCompanies.add(companyJson);
    await prefs.setStringList(_companiesKey, savedCompanies);
  }

  static Future<List<Company>> getOfflineCompanies() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedCompanies = prefs.getStringList(_companiesKey) ?? [];

    return savedCompanies.map((companyJson) {
      Map<String, dynamic> companyMap = jsonDecode(companyJson);
      return Company(
        id: companyMap['id'],
        name: companyMap['name'],
        typeName: companyMap['typeName'],
        communeName: companyMap['communeName'],
        districtName: companyMap['districtName'],
        logoUrl: companyMap['encodedLogo'] != null
            ? 'data:image/jpeg;base64,${companyMap['encodedLogo']}'
            : null,
        introduction: companyMap['introduction'],
        address: companyMap['address'],
        phoneNumber: companyMap['phoneNumber'],
        representative: companyMap['representative'],
        website: companyMap['website'],
        email: companyMap['email'],
        latitude: companyMap['latitude'],
        longitude: companyMap['longitude'],
        products: (companyMap['products'] as List<dynamic>)
            .map((p) => ProductHome.fromJson(p))
            .toList(),
      );
    }).toList();
  }

  static Future<void> removeCompany(int companyId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedCompanies = prefs.getStringList(_companiesKey) ?? [];

    savedCompanies.removeWhere((companyJson) {
      Map<String, dynamic> companyMap = jsonDecode(companyJson);
      return companyMap['id'] == companyId;
    });

    await prefs.setStringList(_companiesKey, savedCompanies);
  }

  static Future<bool> isCompanySaved(int companyId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedCompanies = prefs.getStringList(_companiesKey) ?? [];

    return savedCompanies.any((companyJson) {
      Map<String, dynamic> companyMap = jsonDecode(companyJson);
      return companyMap['id'] == companyId;
    });
  }
}