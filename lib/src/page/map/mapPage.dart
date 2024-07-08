import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geojson/geojson.dart';
import 'dart:math' as math;

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();
  double currentZoom = 10.0;

  List<List<LatLng>> polygonData = [];
  List<String> listPaths = ['lib/src/assets/geodata/vungDem.geojson', 'lib/src/assets/geodata/vungLoi.geojson'];
  final List<Color> orderedColors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.purple,
  Colors.teal,
  Colors.pink,
  // Thêm màu khác nếu cần
];
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < listPaths.length; i++) {
    _loadGeoJsonData(listPaths[i]);
    }
  }

  Future<void> _loadGeoJsonData(String path) async {
  try {
    // Đọc tệp GeoJSON từ assets
    final contents = await rootBundle.loadString(path);

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
  // print(tempPolygonData.length);
    // Cập nhật trạng thái với dữ liệu đa giác
    setState(() {
      for(final point in tempPolygonData)
      polygonData.add(point);
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
                polygons: polygonData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final polygonPoints = entry.value;
                  
                  // Sử dụng màu theo đúng thứ tự
                  final color = orderedColors[index % orderedColors.length];
                  
                  return Polygon(
                    points: polygonPoints,
                    color: color.withOpacity(0.3),
                    borderColor: Colors.black,
                    borderStrokeWidth: 2,
                    isFilled: true,
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
