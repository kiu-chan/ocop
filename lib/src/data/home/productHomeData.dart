class ProductHome {
  final int id;
  final String name;
  final int star;
  final String category;
  String? img;
  String? describe;
  List<String> imageUrls = [];
  String? address;
  String? companyName;
  String? phoneNumber;
  String? representative;
  String? email;
  String? website;
  double? latitude;
  double? longitude;
  String? district; // Thêm trường này

  ProductHome({
    required this.id,
    required this.name,
    required this.star,
    required this.category,
    this.img,
    this.describe,
    this.address,
    this.companyName,
    this.phoneNumber,
    this.representative,
    this.email,
    this.website,
    this.latitude,
    this.longitude,
    this.district, // Thêm trường này
  });
}