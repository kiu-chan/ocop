class ProductHome {
  final int id;
  final String name;
  final int star;
  final String category;
  final String? img;
  String? describe;
  List<String> imageUrls = [];
  String? address;
  String? companyName;
  int? companyId;  // Đảm bảo rằng đây là kiểu int?
  String? phoneNumber;
  String? representative;
  String? email;
  String? website;
  double? latitude;
  double? longitude;
  String? district;
  bool isOfflineAvailable = false;

  ProductHome({
    required this.id,
    required this.name,
    required this.star,
    required this.category,
    this.img,
    this.describe,
    this.address,
    this.companyName,
    this.companyId,
    this.phoneNumber,
    this.representative,
    this.email,
    this.website,
    this.latitude,
    this.longitude,
    this.district,
    this.isOfflineAvailable = false,
  });
}