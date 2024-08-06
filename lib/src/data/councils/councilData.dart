// councilData.dart
class Council {
  final int id;
  final String title;
  final String level;
  final DateTime createdAt;
  final bool isArchived;
  final String districtName;

  Council({
    required this.id,
    required this.title,
    required this.level,
    required this.createdAt,
    required this.isArchived,
    required this.districtName,
  });

  factory Council.fromJson(Map<String, dynamic> json) {
    return Council(
      id: json['id'],
      title: json['title'],
      level: json['level'],
      createdAt: DateTime.parse(json['created_at'].toString()),
      isArchived: json['is_archived'],
      districtName: json['district_name'],
    );
  }
}