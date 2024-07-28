class Product {
  final int id;
  final String name;
  final int star;
  final String category;
  String? img = "";
  String? describe = "";

  Product({
    required this.id,
    required this.name,
    required this.star,
    required this.category,
    this.img,
    this.describe,
  });
}