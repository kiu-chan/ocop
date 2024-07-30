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
    _loadData();
  }

  Future<void> _loadData() async {
    await databaseData.connect();
    if (databaseData.connectionFailed) {
      _showConnectionFailedDialog();
    } else {
      await _loadOnlineData();
    }
  }

  Future<void> _loadOnlineData() async {
    var productsData = await databaseData.getProducts();
    var companiesData = await databaseData.getCompanies();
    _updateProductList(productsData);
    _updateCompanyList(companiesData);
    await databaseData.close();
  }

  Future<void> _loadOfflineData() async {
    String jsonString = await rootBundle.loadString('lib/src/assets/offline_products.json');
    List<dynamic> jsonList = json.decode(jsonString);
    var productsData = jsonList.map((json) => ProductData.fromJson(json)).toList();
    _updateProductList(productsData);
    // Load offline company data if available
    // _updateCompanyList(offlineCompaniesData);
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
      filteredCompanies = []; // Initially, no companies are shown
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