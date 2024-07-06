import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class mapPage extends StatefulWidget {
  @override
  _mapPageState createState() => _mapPageState();
}

class _mapPageState extends State<mapPage> {
  final MapController mapController = MapController();
  double currentZoom = 10.0;

  void _zoomIn() {
    currentZoom = currentZoom + 1;
    mapController.move(mapController.center, currentZoom);
  }

  void _zoomOut() {
    currentZoom = currentZoom - 1;
    mapController.move(mapController.center, currentZoom);
  }

   List<List<LatLng>> polygonData = [
    [
      LatLng(21.0285, 105.8542), // Góc Tây Bắc
      LatLng(21.030, 105.855),  // Góc Đông Bắc
      LatLng(21.031, 105.856),  // Góc Đông Nam
      LatLng(21.030, 105.857),  // Góc Tây Nam
    ],
    [
      LatLng(21.03, 105.85),   // Góc Tây Bắc
      LatLng(21.03, 105.855),  // Góc Đông Bắc
      LatLng(21.025, 105.855), // Góc Đông Nam
      LatLng(21.025, 105.85),  // Góc Tây Nam
    ],
    [
      LatLng(21.032, 105.852), // Góc Tây Bắc
      LatLng(21.032, 105.857), // Góc Đông Bắc
      LatLng(21.027, 105.857), // Góc Đông Nam
      LatLng(21.027, 105.852), // Góc Tây Nam
    ],
  ];

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
              center: LatLng(21.0285, 105.8542), // Tọa độ của Hà Nội
              zoom: currentZoom,
            ),
            nonRotatedChildren: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              for (var polygonPoints in polygonData)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: polygonPoints,
                      color: Colors.blue.withOpacity(0.3),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 2,
                    ),
                  ],
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