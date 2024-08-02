import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class AreaData {
  final int id;
  final String name;
  final List<List<LatLng>> polygons;
  final String color;  // Thêm trường color
  bool isVisible;

  AreaData({
    required this.id,
    required this.name,
    required this.polygons,
    required this.color,  // Thêm tham số color
    this.isVisible = true,
  });

  factory AreaData.fromJson(Map<String, dynamic> json) {
    return AreaData(
      id: json['id'],
      name: json['name'],
      polygons: (json['polygons'] as List<dynamic>)
          .map((polygonJson) => (polygonJson as List<dynamic>)
              .map((pointJson) => LatLng(pointJson.latitude, pointJson.longitude))
              .toList())
          .toList(),
      color: json['color'] ?? '#333333',  // Sử dụng giá trị mặc định nếu không có color
      isVisible: json['isVisible'] ?? true,
    );
  }

  void toggleVisibility() {
    isVisible = !isVisible;
  }
}