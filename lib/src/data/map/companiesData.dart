import 'package:latlong2/latlong.dart';

class CompanyData {
  final LatLng location;
  final int typeId;
  final String name;
  final String productTypeName;

  CompanyData({
    required this.location,
    required this.typeId,
    required this.name,
    required this.productTypeName,
  });

  factory CompanyData.fromJson(Map<String, dynamic> json) {
    return CompanyData(
      location: LatLng(json['latitude'], json['longitude']),
      typeId: json['type_id'],
      name: json['name'],
      productTypeName: json['product_type_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': location.latitude,
      'longitude': location.longitude,
      'type_id': typeId,
      'name': name,
      'product_type_name': productTypeName,
    };
  }

  @override
  String toString() {
    return 'CompanyData(location: $location, typeId: $typeId, name: $name, productTypeName: $productTypeName)';
  }
}