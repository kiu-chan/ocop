import 'package:latlong2/latlong.dart';

class AreaData {
  final int id;
  final String name;
  final List<List<LatLng>> polygons;
  bool isVisible;

  AreaData({
    required this.id,
    required this.name,
    required this.polygons,
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
    isVisible: json['isVisible'] ?? true,
  );
}

  void toggleVisibility() {
    isVisible = !isVisible;
  }
}