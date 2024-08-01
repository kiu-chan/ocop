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
import 'package:ocop/src/data/map/productMapData.dart';
import 'package:ocop/src/data/map/companiesData.dart';
import 'package:ocop/src/page/map/elements/commune_polygon_layer.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();

  late DefaultDatabaseOptions databaseData;
  List<ProductData> products = [];
  List<CompanyData> companies = [];
  List<CompanyData> filteredCompanies = [];
  Set<String> selectedProductTypes = <String>{};
  List<Map<String, dynamic>> communes = [];
  List<int> visibleCommuneIds = [];

  double currentZoom = 9.0;

  int? selectedMap = 1;
  
  String mapName = "Bản đồ";
  List<String> listMapUrl = [
    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
    "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
  ];
  String mapUrl = "https://tile.openstreetmap.org/{z}/{x}/{y}.png";
  final String namePackage = "com.example.app";

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
    Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.orange,
    Colors.purple, Colors.teal, Colors.pink, Colors.cyan, Colors.brown,
    Colors.indigo, Colors.lime, Colors.deepOrange, Colors.lightBlue, Colors.pinkAccent,
  ];

  bool isOfflineMode = false;

  @override
  void initState() {
    super.initState();
    databaseData = DefaultDatabaseOptions();
    _loadData();
  }

  Future<void> _loadData() async {
    await databaseData.connect();
    if (databaseData.connectionFailed) {
      _showConnectionFailedDialog();
    } else {
      await _loadOnlineData();
      await _loadAllCommunesData();
    }
  }

  Future<void> _loadOnlineData() async {
    var productsData = await databaseData.getProducts();
    var companiesData = await databaseData.getCompanies();
    _updateProductList(productsData);
    _updateCompanyList(companiesData);
  }

  Future<void> _loadOfflineData() async {
    String jsonString = await rootBundle.loadString('lib/src/assets/offline_products.json');
    List<dynamic> jsonList = json.decode(jsonString);
    var productsData = jsonList.map((json) => ProductData.fromJson(json)).toList();
    _updateProductList(productsData);
  }

  Future<void> _loadAllCommunesData() async {
    var communesData = await databaseData.getAllCommunes();
    setState(() {
      communes = communesData;
      visibleCommuneIds = communes.map((c) => c['id'] as int).toList();
    });
    print("Loaded ${communes.length} communes");
  }

  void _updateProductList(List<ProductData> productsData) {
    setState(() {
      products = productsData;
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

  void _updateCompanyList(List<CompanyData> companiesData) {
    setState(() {
      companies = companiesData;
      filteredCompanies = [];
    });
  }

  Future<void> _showConnectionFailedDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kết nối thất bại'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Không thể kết nối đến cơ sở dữ liệu.'),
                Text('Bạn có muốn sử dụng dữ liệu offline không?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Có'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isOfflineMode = true;
                });
                _loadOfflineData();
              },
            ),
            TextButton(
              child: const Text('Không'),
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

  void _filterCompanies(List<String> selectedTypes) {
    setState(() {
      selectedProductTypes = Set<String>.from(selectedTypes);
      if (selectedTypes.isEmpty) {
        filteredCompanies = [];
      } else {
        filteredCompanies = companies.where((company) => 
          selectedTypes.contains(company.productTypeName)).toList();
      }
    });
  }

  void _filterCommunes(List<int> selectedIds) {
    setState(() {
      visibleCommuneIds = selectedIds;
    });
  }

  void _showCommuneInfo(Map<String, dynamic> commune) async {
    print("Showing info for commune with ID: ${commune['id']}");
    var communeDetails = await databaseData.getCommune(commune['id']);
    
    print("Commune details: $communeDetails");
    
    if (communeDetails != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(communeDetails['name'] ?? 'Không có tên'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ID: ${communeDetails['id'] ?? 'N/A'}'),
                Text('Diện tích: ${communeDetails['area'] != null ? communeDetails['area'].toStringAsFixed(2) : 'N/A'} km²'),
                Text('Dân số: ${communeDetails['population'] ?? 'N/A'}'),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Đóng'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      print('Không tìm thấy thông tin chi tiết cho commune.');
    }
  }

  void _handleMapTap(LatLng tappedPoint) {
    print("Tapped point: $tappedPoint");
    for (var commune in communes) {
      if (visibleCommuneIds.contains(commune['id'])) {
        for (var polygon in commune['polygons'] as List<List<LatLng>>) {
          if (_isPointInPolygon(tappedPoint, polygon)) {
            print("Found commune: ${commune['id']}");
            _showCommuneInfo({'id': commune['id']});
            return;
          }
        }
      }
    }
    print("No commune found at tapped point");
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    var isInside = false;
    var j = polygon.length - 1;
    for (var i = 0; i < polygon.length; i++) {
      if (((polygon[i].latitude > point.latitude) != (polygon[j].latitude > point.latitude)) &&
          (point.longitude < (polygon[j].longitude - polygon[i].longitude) * (point.latitude - polygon[i].latitude) /
                  (polygon[j].latitude - polygon[i].latitude) +
              polygon[i].longitude)) {
        isInside = !isInside;
      }
      j = i;
    }
    return isInside;
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
        companyDataList: companies,
        polygonData: polygonData,
        onClickMapData: _setPolygonData,
        onFilterCompanies: _filterCompanies,
        selectedProductTypes: selectedProductTypes,
        communes: communes,
        onFilterCommunes: _filterCommunes,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: mapLat,
              zoom: currentZoom,
              interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              onTap: (_, latlng) {
                print("Map tapped at $latlng");
                _handleMapTap(latlng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: mapUrl,
                userAgentPackageName: namePackage,
              ),
              CommunePolygonLayer(
                communes: communes.where((c) => visibleCommuneIds.contains(c['id'])).toList(),
                orderedColors: orderedColors,
              ),
              MarkerMap(
                imageDataList: imageDataList,
                companies: filteredCompanies,
                products: products,
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