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
import 'package:ocop/src/page/map/elements/areaPolygonLayer.dart';
import 'package:ocop/src/data/map/areaData.dart';

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
  List<AreaData> communes = [];
  List<AreaData> districts = [];
  List<AreaData> borders = [];

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
  bool showCommunes = true;
  bool showDistricts = true;
  bool showBorders = false;
  Set<int> selectedCommuneIds = {};
  Set<int> selectedDistrictIds = {};

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
      await _loadAllAreasData();
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

  Future<void> _loadAllAreasData() async {
    var communesData = await databaseData.getAllCommunes();
    var districtsData = await databaseData.getAllDistricts();
    var bordersData = await databaseData.getBorders();
    setState(() {
      communes = communesData.map((json) {
        try {
          return AreaData.fromJson(json);
        } catch (e) {
          print('Error creating AreaData for commune: $e');
          return null;
        }
      }).where((area) => area != null).cast<AreaData>().toList();

      districts = districtsData.map((json) {
        try {
          return AreaData.fromJson(json);
        } catch (e) {
          print('Error creating AreaData for district: $e');
          return null;
        }
      }).where((area) => area != null).cast<AreaData>().toList();

      borders = bordersData.map((json) {
        try {
          return AreaData.fromJson(json);
        } catch (e) {
          print('Error creating AreaData for border: $e');
          return null;
        }
      }).where((area) => area != null).cast<AreaData>().toList();

      selectedCommuneIds = Set<int>.from(communes.map((c) => c.id));
      selectedDistrictIds = Set<int>.from(districts.map((d) => d.id));
    });
    print("Loaded ${communes.length} communes, ${districts.length} districts, and ${borders.length} borders");
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
          'lib/src/assets/img/settings/ic_launcher.png',
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
      selectedCommuneIds = Set<int>.from(selectedIds);
      for (var commune in communes) {
        commune.isVisible = showCommunes && selectedCommuneIds.contains(commune.id);
      }
    });
  }

  void _filterDistricts(List<int> selectedIds) {
    setState(() {
      selectedDistrictIds = Set<int>.from(selectedIds);
      for (var district in districts) {
        district.isVisible = showDistricts && selectedDistrictIds.contains(district.id);
      }
    });
  }

  void _toggleCommunes(bool value) {
    setState(() {
      showCommunes = value;
      for (var commune in communes) {
        commune.isVisible = value && selectedCommuneIds.contains(commune.id);
      }
    });
  }

  void _toggleDistricts(bool value) {
    setState(() {
      showDistricts = value;
      for (var district in districts) {
        district.isVisible = value && selectedDistrictIds.contains(district.id);
      }
    });
  }

  void _toggleBorders(bool value) {
    setState(() {
      showBorders = value;
    });
  }

  void _showCommuneInfo(AreaData commune) async {
    print("Showing info for commune with ID: ${commune.id}");
    var communeDetails = await databaseData.getCommune(commune.id);
    
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
                child: const Text('Đóng'),
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
      if (commune.isVisible) {
        for (var polygon in commune.polygons) {
          if (_isPointInPolygon(tappedPoint, polygon)) {
            print("Found commune: ${commune.id}");
            _showCommuneInfo(commune);
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
        districts: districts,
        onFilterCommunes: _filterCommunes,
        onFilterDistricts: _filterDistricts,
        onToggleCommunes: _toggleCommunes,
        onToggleDistricts: _toggleDistricts,
        onToggleBorders: _toggleBorders,
        showCommunes: showCommunes,
        showDistricts: showDistricts,
        showBorders: showBorders,
        selectedCommuneIds: selectedCommuneIds,
        selectedDistrictIds: selectedDistrictIds,
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
              AreaPolygonLayer(
                communes: communes,
                districts: districts,
                borders: borders,
                orderedColors: orderedColors,
                showBorders: showBorders,
                showDistricts: showDistricts,
                showCommunes: showCommunes,
              ),
              MarkerMap(
                imageDataList: imageDataList,
                companies: filteredCompanies,
                products: products,
                selectedProductTypes: selectedProductTypes,
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