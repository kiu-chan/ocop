class Product {
  final int id;
  final String name;
  final int star;
  final String category;
  String? img = "";
  String? describe = "";
  List<String> imageUrls = [];

  Product({
    required this.id,
    required this.name,
    required this.star,
    required this.category,
    this.img,
    this.describe,
    this.imageUrls = const [],
  });
}