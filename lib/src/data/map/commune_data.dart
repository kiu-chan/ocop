import 'package:latlong2/latlong.dart';

class CommuneData {
  final int id;
  final String name;
  final List<List<LatLng>> polygons;
  bool isVisible;

  CommuneData({
    required this.id,
    required this.name,
    required this.polygons,
    this.isVisible = true,
  });

factory CommuneData.fromJson(Map<String, dynamic> json) {
  return CommuneData(
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