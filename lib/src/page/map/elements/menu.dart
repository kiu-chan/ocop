import 'package:flutter/material.dart';
import 'package:ocop/src/data/map/ImageData.dart';
import 'package:ocop/src/data/map/MapData.dart';
import 'package:ocop/src/data/map/companiesData.dart';

class Menu extends StatefulWidget {
  final ValueChanged<int> onClickMap;
  final ValueChanged<ImageData> onClickImgData;
  final ValueChanged<MapData> onClickMapData;
  final List<ImageData> imageDataList;
  final List<CompanyData> companyDataList;
  final List<MapData> polygonData;
  final Function(List<String>) onFilterCompanies;
  final Set<String> selectedProductTypes;

  const Menu({
    Key? key,
    required this.onClickMap,
    required this.onClickImgData,
    required this.imageDataList,
    required this.companyDataList,
    required this.polygonData,
    required this.onClickMapData,
    required this.onFilterCompanies,
    required this.selectedProductTypes,
  }) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int? selectedMap = 1;
  late Set<String> localSelectedProductTypes;

  @override
  void initState() {
    super.initState();
    localSelectedProductTypes = Set<String>.from(widget.selectedProductTypes);
  }

  @override
  Widget build(BuildContext context) {
    Set<String> productTypes = widget.companyDataList.map((company) => company.productTypeName).toSet();

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
                      Navigator.pop(context);
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
                    widget.onClickMap(0);
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
                  Navigator.pop(context);
                },
              ),
              CheckboxListTile(
                title: const Text('Ranh giới huyện'),
                value: true,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.blue,
                onChanged: (bool? value) {
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
                title: Text(mapData.mapPath),
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
          title: const Text('Lớp chủ thể OCOP'),
          subtitle: const Text('Lọc theo chủ thể'),
          children: [
            ...productTypes.map((type) {
              int count = widget.companyDataList.where((company) => company.productTypeName == type).length;
              return CheckboxListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        type,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Text(
                      " ($count)",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                value: localSelectedProductTypes.contains(type),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      localSelectedProductTypes.add(type);
                    } else {
                      localSelectedProductTypes.remove(type);
                    }
                    widget.onFilterCompanies(localSelectedProductTypes.toList());
                  });
                },
              );
            }),
          ],
        ),
        ],
      ),
    );
  }
}