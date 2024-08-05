import 'package:latlong2/latlong.dart';

class CompanyData {
  final int id;
  final LatLng location;
  final int typeId;
  final String name;
  final String productTypeName;
  final String? logoUrl;
  final String? address;
  final String? phoneNumber;
  final String? representative;
  final String? email;
  final String? website;

  CompanyData({
    required this.id,
    required this.location,
    required this.typeId,
    required this.name,
    required this.productTypeName,
    this.logoUrl,
    this.address,
    this.phoneNumber,
    this.representative,
    this.email,
    this.website,
  });

  factory CompanyData.fromJson(Map<String, dynamic> json) {
    return CompanyData(
      id: json['id'],
      location: LatLng(json['latitude'], json['longitude']),
      typeId: json['type_id'],
      name: json['name'],
      productTypeName: json['product_type_name'],
      logoUrl: json['logo_url'],
      address: json['address'],
      phoneNumber: json['phone_number'],
      representative: json['representative'],
      email: json['email'],
      website: json['website'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'type_id': typeId,
      'name': name,
      'product_type_name': productTypeName,
      'logo_url': logoUrl,
      'address': address,
      'phone_number': phoneNumber,
      'representative': representative,
      'email': email,
      'website': website,
    };
  }

  @override
  String toString() {
    return 'CompanyData(id: $id, location: $location, typeId: $typeId, name: $name, productTypeName: $productTypeName, logoUrl: $logoUrl, address: $address, phoneNumber: $phoneNumber, representative: $representative, email: $email, website: $website)';
  }
}