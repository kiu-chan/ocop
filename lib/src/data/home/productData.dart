import 'package:latlong2/latlong.dart';

class Product {
  final int id;  // Thêm trường id
  final String name;
  final int star;
  final String category;
  String? img = "";
  String? describe = "";

  Product({
    required this.id,  // Thêm id vào constructor
    required this.name,
    required this.star,
    required this.category,
    this.img,
    this.describe,
  });
}