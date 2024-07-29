class ProductHome {
  final int id;
  final String name;
  final int star;
  final String category;
  String? img = "";
  String? describe = "";
  String? address = ""; // Thêm dòng này
  List<String> imageUrls = [];

  ProductHome({
    required this.id,
    required this.name,
    required this.star,
    required this.category,
    this.img,
    this.describe,
    this.address, // Thêm dòng này
    this.imageUrls = const [],
  });
}