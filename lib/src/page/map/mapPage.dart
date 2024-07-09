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

  int? selectedMap = 1;

  bool _showSelectionBar = false;

  String mapName = "Bản đồ";
  List<String> listMapUrl = [
    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
    "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
  ];
  String mapUrl = "https://tile.openstreetmap.org/{z}/{x}/{y}.png";
  final String namePackage = "com.example.app";

  final LatLng mapLat = new LatLng(22.406276, 105.624405);  //Tọa độ mặc định

  List<ImageData> imageDataList = [
    ImageData(
      'lib/src/assets/img/settings/images.png',
      'Ảnh 1',
      [
        LatLng(22.406276, 105.634405),
        LatLng(22.406276, 105.624405),
      ],
    ),
    ImageData(
      'lib/src/assets/img/settings/images.png',
      'Ảnh 2',
      [
        LatLng(22.406276, 105.644405),
        LatLng(22.416276, 105.644405),
      ],
    ),
    ImageData(
      'lib/src/assets/img/settings/images.png',
      'Ảnh 3',
      [
        LatLng(22.426276, 105.644405),
      ],
    ),
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
      List<LatLng> data = [];
      for(final listData in tempPolygonData)
        for(final point in listData)
          data.add(point);
      polygonData.add(new MapData(path, data));
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
        title: Text(mapName),
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 80,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context); // Đóng Drawer
                      },
                    ),
                    Text(
                      'Tùy chỉnh',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ExpansionTile(
              leading: Icon(Icons.api),
              title: Text('Bản đồ nền'),
              subtitle: Text('Bản đồ mặc định'),
              children: <Widget>[
                RadioListTile<int>(
                  title: Text('Bản đồ địa lý'),
                  value: 1,
                  groupValue: selectedMap,
                  onChanged: (value) {
                    setState(() {
                      selectedMap = value;
                      _changeMapSource(0);
                      Navigator.pop(context);
                    });
                  },
                ),
                RadioListTile<int>(
                  title: Text('Bản đồ vệ tinh'),
                  value: 2,
                  groupValue: selectedMap,
                  onChanged: (value) {
                    setState(() {
                      selectedMap = value;
                      _changeMapSource(1);
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: Icon(Icons.show_chart),
              title: Text('Lớp hành chính'),
              subtitle: Text('Mô tả'),
              children: <Widget>[
                CheckboxListTile(
                  title: Text('Ranh giới'),
                  value: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.blue,
                  onChanged: (bool? value) {
                    _changeMapSource(0);
                    Navigator.pop(context);
                  },
                ),
                CheckboxListTile(
                  title: Text('Ranh giới huyện'),
                  value: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.blue,
                  onChanged: (bool? value) {
                    _changeMapSource(1);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: Icon(Icons.workspaces_outline),
              title: Text('Lớp sản phẩm'),
              subtitle: Text('Mô tả'),
              children: imageDataList.map((imageData) {
                return CheckboxListTile(
                  title: Row(
                    children: [
                      Text(imageData.title),
                      Text(
                        " (" + imageData.locations.length.toString() + ")",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                    ],
                  ),
                  value: imageData.checkRender,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.blue,
                  onChanged: (bool? value) {
                    setState(() {
                    imageData.setCheck();
                    });
                  },
                );
              }).toList(),
            ),
            ExpansionTile(
              leading: Icon(Icons.auto_awesome_motion),
              title: Text('Khu vực'),
              subtitle: Text('Mô tả'),
              children: polygonData.map((mapData) {
                return CheckboxListTile(
                  title: 
                      Text(mapData.mapPath),
                  value: mapData.checkRender,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.blue,
                  onChanged: (bool? value) {
                    setState(() {
                    mapData.setCheck();
                    });
                  },
                );
              }).toList(),
            ),
            ExpansionTile(
              leading: Icon(Icons.home),
              title: Text('Chủ thể OCOP'),
              subtitle: Text('Mô tả'),
              children: <Widget>[
                CheckboxListTile(
                  title: Text('Bản đồ địa lý'),
                  value: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.blue,
                  onChanged: (bool? value) {
                    _changeMapSource(0);
                  },
                ),
                CheckboxListTile(
                  title: Text('Bản đồ vệ tinh'),
                  value: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.blue,
                  onChanged: (bool? value) {
                    _changeMapSource(1);
                  },
                ),
              ],
            ),
          ],
        ),
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
                    points: [], // Hoặc các giá trị mặc định tương ứng với Polygon
                    color: Colors.transparent,
                    borderColor: Colors.transparent,
                    borderStrokeWidth: 0,
                    isFilled: false,
                  );
                }),
              ),

              MarkerLayer(
            markers: _buildMarkers(),
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

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];
    for (var imageData in imageDataList) {
      if(imageData.getCheck())
      for (var location in imageData.locations) {
        markers.add(
          Marker(
            width: 50.0,
            height: 50.0,
            point: location,
            builder: (ctx) => GestureDetector(
              onTap: () {
                showDialog(
                  context: ctx,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(imageData.title),
                      content: Image.asset(imageData.imagePath),
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,  // Màu viền
                    width: 1.0,  // Độ dày viền
                  ),
                  image: DecorationImage(
                    image: AssetImage(imageData.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return markers;
  }

  void _changeMapSource(int mapValue) {
    setState(() {
      mapUrl = listMapUrl[mapValue];
      print(mapUrl);
    });
  }
}



class MapData {
  final String mapPath;
  final List<LatLng> mapData;
  bool checkRender = true;

  MapData(this.mapPath, this.mapData);

  String getPath() {
    return mapPath;
  }

  // void setMapData(List<LatLng> mapData) {
  //   this.mapData = mapData;
  // }

  List<LatLng>  getMapData() {
    return this.mapData;
  }

  void setCheck() {
    checkRender =!checkRender;
  }

  bool getCheck() {
    return checkRender;
  }
}

class ImageData {
  final String imagePath;
  final String title;
  final List<LatLng> locations;
  bool checkRender = true;

  ImageData(this.imagePath, this.title, this.locations);

  void setCheck() {
    checkRender =!checkRender;
    print(checkRender);
  }

  bool getCheck() {
    return checkRender;
  }
}