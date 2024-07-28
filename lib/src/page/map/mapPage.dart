import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geojson/geojson.dart';
import 'package:ocop/src/page/map/elements/menu.dart';
import 'package:ocop/src/data/map/ImageData.dart';
import 'package:ocop/src/data/map/MapData.dart';
import 'package:ocop/src/page/map/elements/MarkerMap.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:ocop/src/data/map/productData.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();

  late DefaultDatabaseOptions databaseData;
  List<Map<String, dynamic>> products = [];

  LatLng parseLatLng(String input) {
    final pointStart = input.indexOf('POINT(') + 'POINT('.length;
    final pointEnd = input.indexOf(')', pointStart);
    final coordinateString = input.substring(pointStart, pointEnd);
    final coordinates = coordinateString.split(' ');
    final longitude = double.parse(coordinates[0]);
    final latitude = double.parse(coordinates[1]);
    return LatLng(latitude, longitude);
  }

  double currentZoom = 9.0;

  int? selectedMap = 1;
  
  String mapName = "Bản đồ";
  List<String> listMapUrl = [
    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
    "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
  ];
  String mapUrl = "https://tile.openstreetmap.org/{z}/{x}/{y}.png";
  final String namePackage = "com.example.app";

  // final LatLng mapLat = LatLng(22.406276, 105.624405);  //Tọa độ Ba bể
  final LatLng mapLat = LatLng(10.2417, 106.3748);  //Tọa độ mặc định

  final LatLng mapLatFinal = LatLng(10.2417, 106.3748);  //Tọa độ mặc định

  List<ImageData> imageDataList = [];

  List<ImageData> listImgRender = [];
  List<MapData> polygonData = [];
  List<String> listPaths = [
    'lib/src/assets/geodata/vungDem.geojson',
    'lib/src/assets/geodata/vungLoi.geojson',
  ];
  final List<Color> orderedColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
  ];

  bool isOfflineMode = false;

  @override
  void initState() {
    super.initState();
    databaseData = DefaultDatabaseOptions();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    await databaseData.connect();
    if (databaseData.connectionFailed) {
      _showConnectionFailedDialog();
    } else {
      await _loadOnlineProducts();
    }
  }

  Future<void> _loadOnlineProducts() async {
    var products = await databaseData.getProducts();
    _updateProductList(products);
    await databaseData.close();
  }

  Future<void> _loadOfflineProducts() async {
    String jsonString = await rootBundle.loadString('lib/src/assets/offline_products.json');
    List<dynamic> jsonList = json.decode(jsonString);
    var products = jsonList.map((json) => ProductData.fromJson(json)).toList();
    _updateProductList(products);
  }

  void _updateProductList(List<ProductData> products) {
    setState(() {
      Map<String, List<LatLng>> groupedLatLngs = {};
      for (var product in products) {
        if (!groupedLatLngs.containsKey(product.categoryName)) {
          groupedLatLngs[product.categoryName] = [];
        }
        groupedLatLngs[product.categoryName]!.add(product.location);
      }
      imageDataList = groupedLatLngs.entries.map((entry) {
        return ImageData(
          'lib/src/assets/img/settings/images.png',
          entry.key,
          entry.value,
        );
      }).toList();
    });
  }

  Future<void> _showConnectionFailedDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Kết nối thất bại'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Không thể kết nối đến cơ sở dữ liệu.'),
                Text('Bạn có muốn sử dụng dữ liệu offline không?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Có'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isOfflineMode = true;
                });
                _loadOfflineProducts();
              },
            ),
            TextButton(
              child: Text('Không'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadGeoJsonData(String path) async {
    try {
      final contents = await rootBundle.loadString(path);
      final geoJson = GeoJson();
      await geoJson.parse(contents, verbose: true);
      List<List<LatLng>> tempPolygonData = [];

      for (final feature in geoJson.features) {
        if (feature.geometry is GeoJsonPolygon) {
          final polygon = feature.geometry as GeoJsonPolygon;
          List<LatLng> polygonPoints = [];
          for (final geoSeries in polygon.geoSeries) {
            for (final point in geoSeries.geoPoints) {
              polygonPoints.add(LatLng(point.latitude, point.longitude));
            }
          }
          tempPolygonData.add(polygonPoints);
        } else if (feature.geometry is GeoJsonMultiPolygon) {
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

      setState(() {
        List<LatLng> data = [];
        for(final listData in tempPolygonData) {
          for(final point in listData) {
            data.add(point);
          }
        }
        polygonData.add(MapData(path, data));
      });

      geoJson.dispose();
    } catch (e) {
      print('Error loading GeoJSON data: $e');
    }
  }

  void _location() {
    setState(() {
      currentZoom = 9.0;
      mapController.move(mapLat, currentZoom);
    });
  }

  void _zoomIn() {
    double zoomFactor = 1.1;
    currentZoom = (mapController.zoom * zoomFactor).clamp(1.0, 18.0);
    mapController.move(mapController.center, currentZoom);
  }

  void _zoomOut() {
    double zoomFactor = 0.9;
    currentZoom = (mapController.zoom * zoomFactor).clamp(1.0, 18.0);
    mapController.move(mapController.center, currentZoom);
  }

  void _changeMapSource(int mapValue) {
    setState(() {
      mapUrl = listMapUrl[mapValue];
      print(mapUrl);
    });
  }

  void _setStateProduct(ImageData imageData) {
    setState(() {
      imageData.setCheck();
    });
  }
  
  void _setPolygonData(MapData mapData) {
    setState(() {
      mapData.setCheck();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mapName),
        automaticallyImplyLeading: false,
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      endDrawer: Menu(
        onClickMap: _changeMapSource,
        onClickImgData: _setStateProduct,
        imageDataList: imageDataList,
        polygonData: polygonData,
        onClickMapData: _setPolygonData,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: mapLat,
              zoom: currentZoom,
              interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            nonRotatedChildren: [
              TileLayer(
                urlTemplate: mapUrl,
                userAgentPackageName: namePackage,
              ),
              PolygonLayer(
                polygons: List.generate(polygonData.length, (index) {
                  if (polygonData[index].getCheck()) {
                    final polygonPoints = polygonData[index].getMapData();
                    final color = index < orderedColors.length 
                        ? orderedColors[index] 
                        : Colors.grey;
                    return Polygon(
                      points: polygonPoints,
                      color: color.withOpacity(0.3),
                      borderColor: Colors.black,
                      borderStrokeWidth: 2,
                      isFilled: true,
                    );
                  }
                  return Polygon(
                    points: [],
                    color: Colors.transparent,
                    borderColor: Colors.transparent,
                    borderStrokeWidth: 0,
                    isFilled: false,
                  );
                }),
              ),
              MarkerMap(
                imageDataList: imageDataList,
              ),
            ],
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _location,
                  heroTag: "location",
                  child: const Icon(Icons.location_on),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _zoomIn,
                  heroTag: "zoomIn",
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _zoomOut,
                  heroTag: "zoomOut",
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}