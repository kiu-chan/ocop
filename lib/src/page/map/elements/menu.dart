import 'package:flutter/material.dart';
import 'package:ocop/src/page/map/data/ImageData.dart';
import 'package:ocop/src/page/map/data/MapData.dart';

class Menu extends StatefulWidget {
  final ValueChanged<int> onClickMap;
  final ValueChanged<ImageData> onClickImgData;
  final ValueChanged<MapData> onClickMapData;
  final List<ImageData> imageDataList;
  final List<MapData> polygonData;
  @override
  _MenuState createState() => _MenuState();
  Menu({
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
                      // _changeMapSource(0);
                      widget.onClickMap(0);
                      // Navigator.pop(context);
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
                      widget.onClickMap(1);
                      // _changeMapSource(1);
                      // Navigator.pop(context);
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
                    // _changeMapSource(0);
                    Navigator.pop(context);
                  },
                ),
                CheckboxListTile(
                  title: Text('Ranh giới huyện'),
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
              leading: Icon(Icons.workspaces_outline),
              title: Text('Lớp sản phẩm'),
              subtitle: Text('Mô tả'),
              children: widget.imageDataList.map((imageData) {
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
                    widget.onClickImgData(imageData);
                    });
                  },
                );
              }).toList(),
            ),
            ExpansionTile(
              leading: Icon(Icons.auto_awesome_motion),
              title: Text('Khu vực'),
              subtitle: Text('Mô tả'),
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
                    // _changeMapSource(0);
                  },
                ),
                CheckboxListTile(
                  title: Text('Bản đồ vệ tinh'),
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

