import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ocop/src/page/map/elements/menu.dart';
import 'package:ocop/src/data/map/ImageData.dart';
import 'package:ocop/src/data/map/MapData.dart';
import 'package:ocop/src/page/map/elements/MarkerMap.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:ocop/src/data/map/productMapData.dart';
import 'package:ocop/src/data/map/companiesData.dart';
import 'package:ocop/src/page/map/elements/areaPolygonLayer.dart';
import 'package:ocop/src/data/map/areaData.dart';
import 'mapControllers.dart';
import 'mapDataLoaders.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();
  final MapDataLoader dataLoader = MapDataLoader();
  final MapControllers mapControllers = MapControllers();

  late DefaultDatabaseOptions databaseData;
  List<ProductData> products = [];
  List<CompanyData> companies = [];
  List<CompanyData> filteredCompanies = [];
  Set<String> selectedProductTypes = <String>{};
  List<AreaData> communes = [];
  List<AreaData> districts = [];
  List<AreaData> borders = [];

  double currentZoom = 10.38;

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
  bool showCommunes = false;
  bool showDistricts = true;
  bool showBorders = false;
  Set<int> selectedCommuneIds = {};
  Set<int> selectedDistrictIds = {};

  final TextEditingController _searchController = TextEditingController();
  List<ProductData> _searchProductResults = [];
  List<CompanyData> _searchCompanyResults = [];
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    databaseData = DefaultDatabaseOptions();
    _loadData();
  }

  Future<void> _loadData() async {
    await dataLoader.loadData();
    setState(() {
      products = dataLoader.products;
      companies = dataLoader.companies;
      communes = dataLoader.communes;
      districts = dataLoader.districts;
      borders = dataLoader.borders;
      selectedCommuneIds = Set<int>.from(communes.map((c) => c.id));
      selectedDistrictIds = Set<int>.from(districts.map((d) => d.id));
      imageDataList = dataLoader.imageDataList;
    });
  }

  void _changeMapSource(int mapValue) {
    setState(() {
      mapUrl = listMapUrl[mapValue];
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
    var communeDetails = await dataLoader.getCommuneDetails(commune.id);
    
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

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchProductResults = [];
        _searchCompanyResults = [];
        _showSearchResults = false;
      } else {
        _searchProductResults = products
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
        _searchCompanyResults = companies
            .where((company) =>
                company.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
        _showSearchResults = true;
      }
    });
  }

  void _moveToProduct(ProductData product) {
    mapController.move(product.location, 15); // Zoom level 15
    setState(() {
      _showSearchResults = false;
      _searchController.clear();
    });
  }

  void _moveToCompany(CompanyData company) {
    mapController.move(company.location, 15); // Zoom level 15
    setState(() {
      _showSearchResults = false;
      _searchController.clear();
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
                mapControllers.handleMapTap(latlng, communes, _showCommuneInfo);
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
            top: 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm sản phẩm hoặc công ty...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _search,
                  ),
                ),
                if (_showSearchResults)
                  Container(
                    color: Colors.white,
                    height: 200, // Điều chỉnh theo nhu cầu
                    child: ListView(
                      children: [
                        ..._searchProductResults.map((product) => ListTile(
                              title: Text(product.name),
                              subtitle: Text('Sản phẩm - ${product.categoryName}'),
                              onTap: () => _moveToProduct(product),
                            )),
                        ..._searchCompanyResults.map((company) => ListTile(
                              title: Text(company.name),
                              subtitle: Text('Công ty - ${company.productTypeName}'),
                              onTap: () => _moveToCompany(company),
                            )),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () => mapControllers.location(mapController, mapLat),
                  heroTag: "location",
                  child: const Icon(Icons.location_on),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () => mapControllers.zoomIn(mapController),
                  heroTag: "zoomIn",
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () => mapControllers.zoomOut(mapController),
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