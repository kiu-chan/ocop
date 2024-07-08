import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geojson/geojson.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();
  double currentZoom = 10.0;

  List<List<LatLng>> polygonData = [];

  @override
  void initState() {
    super.initState();
    _loadGeoJsonData();
  }

  Future<void> _loadGeoJsonData() async {
  try {
    // Đọc tệp GeoJSON từ assets
    final contents = await rootBundle.loadString('lib/src/assets/geodata/sinhcanh.geojson');

    // Phân tích nội dung GeoJSON
    final geoJson = GeoJson();
    await geoJson.parse(contents, verbose: true);

    // Khởi tạo danh sách để lưu dữ liệu đa giác
    List<List<LatLng>> tempPolygonData = [];

    // Lặp qua các đối tượng GeoJSON đã phân tích
    for (final feature in geoJson.features) {
      if (feature.geometry is GeoJsonPolygon) {
        // Xử lý khi đối tượng là một đa giác
        final polygon = feature.geometry as GeoJsonPolygon;
        List<LatLng> polygonPoints = [];
        for (final geoSeries in polygon.geoSeries) {
          for (final point in geoSeries.geoPoints) {
            polygonPoints.add(LatLng(point.latitude, point.longitude));
          }
        }
        tempPolygonData.add(polygonPoints);
      } else if (feature.geometry is GeoJsonMultiPolygon) {
        // Xử lý khi đối tượng là một nhiều đa giác
        final multiPolygon = feature.geometry as GeoJsonMultiPolygon;
        for (final polygon in multiPolygon.polygons) {
          List<LatLng> polygonPoints = [];
          for (final geoSeries in polygon.geoSeries) {
            for (final point in geoSeries.geoPoints) {
              polygonPoints.add(LatLng(point.latitude, point.longitude));
            }
          }
          tempPolygonData.add(polygonPoints);
        }
      }
    }
  print(tempPolygonData.length);
    // Cập nhật trạng thái với dữ liệu đa giác
    setState(() {
      polygonData = tempPolygonData;
    });

    // Đóng GeoJSON để giải phóng bộ nhớ
    geoJson.dispose();
  } catch (e) {
    print('Error loading GeoJSON data: $e');
  }
}


  void _zoomIn() {
    currentZoom = currentZoom + 1;
    mapController.move(mapController.center, currentZoom);
  }

  void _zoomOut() {
    currentZoom = currentZoom - 1;
    mapController.move(mapController.center, currentZoom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bản đồ Việt Nam'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: LatLng(22.406276, 105.624405), // Tọa độ
              zoom: currentZoom,
            ),
            nonRotatedChildren: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              PolygonLayer(
                polygons: polygonData.map((polygonPoints) {
                  return Polygon(
                    points: polygonPoints,
                    color: Colors.blue.withOpacity(0.3),
                    borderColor: Colors.blue,
                    borderStrokeWidth: 2,
                  );
                }).toList(),
              ),
            ],
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: _zoomIn,
                  heroTag: "zoomIn",
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  child: Icon(Icons.remove),
                  onPressed: _zoomOut,
                  heroTag: "zoomOut",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
