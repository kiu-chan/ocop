import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geojson/geojson.dart';
import 'package:ocop/src/page/map/elements/menu.dart';
import 'package:ocop/src/data/map/ImageData.dart';
import 'package:ocop/src/data/map/MapData.dart';
import 'package:ocop/src/page/map/elements/MarkerMap.dart';
import 'package:ocop/databases.dart';


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

  final LatLng mapLat = LatLng(10.2417, 106.3748);  //Tọa độ mặc định
  // final LatLng mapLat = LatLng(22.406276, 105.624405);  //Tọa độ mặc định

  List<ImageData> imageDataList = [
    // ImageData(
    //   'lib/src/assets/img/settings/images.png',
    //   'Ảnh 1',
    //   [
    //     LatLng(22.406276, 105.634405),
    //     LatLng(22.406276, 105.624405),
    //   ],
    // ),
    // ImageData(
    //   'lib/src/assets/img/map/image.png',
    //   'Ảnh 2',
    //   [
    //     LatLng(22.406276, 105.644405),
    //     LatLng(22.416276, 105.644405),
    //   ],
    // ),
    // ImageData(
    //   'lib/src/assets/img/map/img.png',
    //   'Ảnh 3',
    //   [
    //     LatLng(22.426276, 105.644405),
    //   ],
    // ),
    // Thêm các ảnh khác vào đây
  ];

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
  // Thêm màu khác nếu cần
];
  @override
  void initState() {
    super.initState();

    databaseData = DefaultDatabaseOptions();
    _loadProducts();

    // for (int i = 0; i < listPaths.length; i++) {
    // _loadGeoJsonData(listPaths[i]);
    // }
  }

Future<void> _loadProducts() async {
  await databaseData.connect();
  var products = await databaseData.getProducts();

  setState(() {
    Map<String, List<LatLng>> groupedLatLngs = {};
    
    // Phân loại các sản phẩm theo tên nhóm sản phẩm
    for (var product in products) {
      if (!groupedLatLngs.containsKey(product.categoryName)) {
        groupedLatLngs[product.categoryName] = [];
      }
      groupedLatLngs[product.categoryName]!.add(product.location);
    }
    
    // Tạo imageDataList từ groupedLatLngs
    imageDataList = groupedLatLngs.entries.map((entry) {
      return ImageData(
        'lib/src/assets/img/settings/images.png',
        entry.key,  // Sử dụng tên nhóm làm tiêu đề
        entry.value,  // Danh sách các LatLng
      );
    }).toList();
  });

  await databaseData.close();
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
      List<LatLng> data = [];
      for(final listData in tempPolygonData)
        // ignore: curly_braces_in_flow_control_structures
        for(final point in listData) {
          data.add(point);
        }
      polygonData.add(MapData(path, data));
    });

    // Đóng GeoJSON để giải phóng bộ nhớ
    geoJson.dispose();
  } catch (e) {
    // ignore: avoid_print
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

                    // Sử dụng màu theo đúng thứ tự, không lặp lại
                    final color = index < orderedColors.length 
                        ? orderedColors[index] 
                        : Colors.grey; // Màu mặc định nếu hết màu trong danh sách
                    
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