class ProductHome {
  final int id;
  final String name;
  final int star;
  final String category;
  final String? img;
  String? describe;
  List<String> imageUrls;
  String? address;
  String? companyName;
  int? companyId;
  String? phoneNumber;
  String? representative;
  String? email;
  String? website;
  double? latitude;
  double? longitude;
  String? district;
  bool isOfflineAvailable;

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
    this.imageUrls = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'star': star,
      'category': category,
      'img': img,
      'describe': describe,
      'imageUrls': imageUrls,
      'address': address,
      'companyName': companyName,
      'companyId': companyId,
      'phoneNumber': phoneNumber,
      'representative': representative,
      'email': email,
      'website': website,
      'latitude': latitude,
      'longitude': longitude,
      'district': district,
      'isOfflineAvailable': isOfflineAvailable,
    };
  }

  factory ProductHome.fromJson(Map<String, dynamic> json) {
    return ProductHome(
      id: json['id'],
      name: json['name'],
      star: json['star'],
      category: json['category'],
      img: json['img'],
      describe: json['describe'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      address: json['address'],
      companyName: json['companyName'],
      companyId: json['companyId'],
      phoneNumber: json['phoneNumber'],
      representative: json['representative'],
      email: json['email'],
      website: json['website'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      district: json['district'],
      isOfflineAvailable: json['isOfflineAvailable'] ?? false,
    );
  }

  ProductHome copyWith({
    int? id,
    String? name,
    int? star,
    String? category,
    String? img,
    String? describe,
    List<String>? imageUrls,
    String? address,
    String? companyName,
    int? companyId,
    String? phoneNumber,
    String? representative,
    String? email,
    String? website,
    double? latitude,
    double? longitude,
    String? district,
    bool? isOfflineAvailable,
  }) {
    return ProductHome(
      id: id ?? this.id,
      name: name ?? this.name,
      star: star ?? this.star,
      category: category ?? this.category,
      img: img ?? this.img,
      describe: describe ?? this.describe,
      imageUrls: imageUrls ?? this.imageUrls,
      address: address ?? this.address,
      companyName: companyName ?? this.companyName,
      companyId: companyId ?? this.companyId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      representative: representative ?? this.representative,
      email: email ?? this.email,
      website: website ?? this.website,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      district: district ?? this.district,
      isOfflineAvailable: isOfflineAvailable ?? this.isOfflineAvailable,
    );
  }
}