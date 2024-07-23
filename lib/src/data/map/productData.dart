import 'package:latlong2/latlong.dart';

class ProductData {
  final int id;
  final LatLng location;
  final String name;
  final String? address;
  final String categoryName;
  final int rating;

  ProductData({
    required this.id,
    required this.location,
    required this.name,
    this.address,
    required this.categoryName,
    required this.rating,
  });
}