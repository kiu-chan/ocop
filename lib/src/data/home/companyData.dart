import 'package:ocop/src/data/home/productHomeData.dart';

class Company {
  final int id;
  final String name;
  final String? logoUrl;
  final String? introduction;
  final String? address;
  final String? phoneNumber;
  final String? representative;
  final String? website;
  final String? email;
  final String? typeName;
  final String? communeName;
  final String? districtName;
  final double? latitude;
  final double? longitude;
  final List<ProductHome> products;

  Company({
    required this.id,
    required this.name,
    this.logoUrl,
    this.introduction,
    this.address,
    this.phoneNumber,
    this.representative,
    this.website,
    this.email,
    this.typeName,
    this.communeName,
    this.districtName,
    this.latitude,
    this.longitude,
    this.products = const [],
  });
}