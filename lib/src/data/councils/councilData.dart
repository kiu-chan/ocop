import 'package:intl/intl.dart';

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
      districtName: json['district_name'] ?? 'Không xác định',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'level': level,
      'created_at': createdAt.toIso8601String(), // Chuyển đổi DateTime thành chuỗi
      'is_archived': isArchived,
      'district_name': districtName,
    };
  }

  String get formattedCreatedAt {
    return DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
  }

  String get status {
    return isArchived ? 'Đã lưu trữ' : 'Đang hoạt động';
  }

  @override
  String toString() {
    return 'Council{id: $id, title: $title, level: $level, createdAt: $formattedCreatedAt, isArchived: $isArchived, districtName: $districtName}';
  }

  Council copyWith({
    int? id,
    String? title,
    String? level,
    DateTime? createdAt,
    bool? isArchived,
    String? districtName,
  }) {
    return Council(
      id: id ?? this.id,
      title: title ?? this.title,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
      districtName: districtName ?? this.districtName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Council &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          level == other.level &&
          createdAt == other.createdAt &&
          isArchived == other.isArchived &&
          districtName == other.districtName;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      level.hashCode ^
      createdAt.hashCode ^
      isArchived.hashCode ^
      districtName.hashCode;
}