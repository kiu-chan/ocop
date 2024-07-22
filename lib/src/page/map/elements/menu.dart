import 'package:flutter/material.dart';
import 'package:ocop/src/data/map/ImageData.dart';
import 'package:ocop/src/data/map/MapData.dart';

class Menu extends StatefulWidget {
  final ValueChanged<int> onClickMap;
  final ValueChanged<ImageData> onClickImgData;
  final ValueChanged<MapData> onClickMapData;
  final List<ImageData> imageDataList;
  final List<MapData> polygonData;
  @override
  _MenuState createState() => _MenuState();
  const Menu({super.key, 
    required this.onClickMap,
    required this.onClickImgData,
    required this.imageDataList,
    required this.polygonData,
    required this.onClickMapData,
    });
}

class _MenuState extends State<Menu> {
  int? selectedMap = 1;
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 80,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context); // Đóng Drawer
                      },
                    ),
                    const Text(
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
              leading: const Icon(Icons.api),
              title: const Text('Bản đồ nền'),
              subtitle: const Text('Bản đồ mặc định'),
              children: <Widget>[
                RadioListTile<int>(
                  title: const Text('Bản đồ địa lý'),
                  value: 1,
                  groupValue: selectedMap,
                  onChanged: (value) {
                    setState(() {
                      selectedMap = value;
                      // _changeMapSource(0);
                      widget.onClickMap(0);
                      // Navigator.pop(context);
                    });
                  },
                ),
                RadioListTile<int>(
                  title: const Text('Bản đồ vệ tinh'),
                  value: 2,
                  groupValue: selectedMap,
                  onChanged: (value) {
                    setState(() {
                      selectedMap = value;
                      widget.onClickMap(1);
                      // _changeMapSource(1);
                      // Navigator.pop(context);
                    });
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.show_chart),
              title: const Text('Lớp hành chính'),
              subtitle: const Text('Mô tả'),
              children: <Widget>[
                CheckboxListTile(
                  title: const Text('Ranh giới'),
                  value: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.blue,
                  onChanged: (bool? value) {
                    // _changeMapSource(0);
                    Navigator.pop(context);
                  },
                ),
                CheckboxListTile(
                  title: const Text('Ranh giới huyện'),
                  value: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.blue,
                  onChanged: (bool? value) {
                    // _changeMapSource(1);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.workspaces_outline),
              title: const Text('Lớp sản phẩm'),
              subtitle: const Text('Mô tả'),
              children: widget.imageDataList.map((imageData) {
                return CheckboxListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          imageData.title,
                          style: const TextStyle(
                            fontSize: 16,
                            // fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Text(
                        " (${imageData.locations.length})",
                        style: const TextStyle(
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
                    widget.onClickImgData(imageData);
                    });
                  },
                );
              }).toList(),
            ),
            ExpansionTile(
              leading: const Icon(Icons.auto_awesome_motion),
              title: const Text('Khu vực'),
              subtitle: const Text('Mô tả'),
              children: widget.polygonData.map((mapData) {
                return CheckboxListTile(
                  title: 
                      Text(mapData.mapPath),
                  value: mapData.checkRender,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.blue,
                  onChanged: (bool? value) {
                    setState(() {
                      widget.onClickMapData(mapData);
                    });
                  },
                );
              }).toList(),
            ),
            ExpansionTile(
              leading: const Icon(Icons.home),
              title: const Text('Chủ thể OCOP'),
              subtitle: const Text('Mô tả'),
              children: <Widget>[
                CheckboxListTile(
                  title: const Text('Bản đồ địa lý'),
                  value: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.blue,
                  onChanged: (bool? value) {
                    // _changeMapSource(0);
                  },
                ),
                CheckboxListTile(
                  title: const Text('Bản đồ vệ tinh'),
                  value: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.blue,
                  onChanged: (bool? value) {
                    // _changeMapSource(1);
                  },
                ),
              ],
            ),
          ],
        ),
      );
  }
}

