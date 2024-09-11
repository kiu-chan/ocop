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

  // Chuyển đổi Company thành Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'introduction': introduction,
      'address': address,
      'phoneNumber': phoneNumber,
      'representative': representative,
      'website': website,
      'email': email,
      'typeName': typeName,
      'communeName': communeName,
      'districtName': districtName,
      'latitude': latitude,
      'longitude': longitude,
      'products': products.map((product) => product.toJson()).toList(),
    };
  }

  // Tạo Company từ Map
  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logoUrl'],
      introduction: json['introduction'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      representative: json['representative'],
      website: json['website'],
      email: json['email'],
      typeName: json['typeName'],
      communeName: json['communeName'],
      districtName: json['districtName'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      products: (json['products'] as List<dynamic>?)
          ?.map((productJson) => ProductHome.fromJson(productJson))
          .toList() ?? [],
    );
  }

  // Tạo bản sao của Company với khả năng thay đổi một số trường
  Company copyWith({
    int? id,
    String? name,
    String? logoUrl,
    String? introduction,
    String? address,
    String? phoneNumber,
    String? representative,
    String? website,
    String? email,
    String? typeName,
    String? communeName,
    String? districtName,
    double? latitude,
    double? longitude,
    List<ProductHome>? products,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      introduction: introduction ?? this.introduction,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      representative: representative ?? this.representative,
      website: website ?? this.website,
      email: email ?? this.email,
      typeName: typeName ?? this.typeName,
      communeName: communeName ?? this.communeName,
      districtName: districtName ?? this.districtName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      products: products ?? this.products,
    );
  }
}