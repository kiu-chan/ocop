import 'dart:convert';
import 'dart:io';
import 'package:geojson/geojson.dart';
import 'package:latlong2/latlong.dart';

Future<void> main() async {
  // Đọc tệp GeoJSON
  final file = File('lib/src/page/map/sinhcanh.geojson');
  final contents = await file.readAsString();

  // Phân tích nội dung GeoJSON
  final geoJson = GeoJson();
  await geoJson.parse(contents, verbose: true);

  // Khởi tạo danh sách để lưu dữ liệu đa giác
  List<List<LatLng>> polygonData = [];

  // Lặp qua các đối tượng GeoJSON đã phân tích
  for (final feature in geoJson.features) {
    if (feature.type == GeoJsonFeatureType.polygon) {
      final polygon = feature.geometry as GeoJsonPolygon;
      List<LatLng> polygonPoints = [];
      for (final geoSeries in polygon.geoSeries) {
        for (final point in geoSeries.geoPoints) {
          polygonPoints.add(LatLng(point.latitude, point.longitude));
        }
      }
      polygonData.add(polygonPoints);
    }
  }

  // In ra dữ liệu đa giác
  for (var i = 0; i < polygonData.length; i++) {
    print('Polygon ${i + 1}:');
    for (var point in polygonData[i]) {
      print('Lat: ${point.latitude}, Lng: ${point.longitude}');
    }
  }

  // Đóng GeoJSON để giải phóng bộ nhớ
  geoJson.dispose();
}
