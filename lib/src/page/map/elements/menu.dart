import 'package:flutter/material.dart';
import 'package:ocop/src/data/map/ImageData.dart';
import 'package:ocop/src/data/map/MapData.dart';
import 'package:ocop/src/data/map/companiesData.dart';
import 'package:ocop/src/data/map/areaData.dart';

class Menu extends StatefulWidget {
  final ValueChanged<int> onClickMap;
  final ValueChanged<ImageData> onClickImgData;
  final ValueChanged<MapData> onClickMapData;
  final List<ImageData> imageDataList;
  final List<CompanyData> companyDataList;
  final List<MapData> polygonData;
  final Function(List<String>) onFilterCompanies;
  final Set<String> selectedProductTypes;
  final List<AreaData> communes;
  final List<AreaData> districts;
  final Function(List<int>) onFilterCommunes;
  final Function(List<int>) onFilterDistricts;
  final Function(bool) onToggleCommunes;
  final Function(bool) onToggleDistricts;
  final Function(bool) onToggleBorders;
  final bool showCommunes;
  final bool showDistricts;
  final bool showBorders;
  final Set<int> selectedCommuneIds;
  final Set<int> selectedDistrictIds;
  final int selectedMapType;

  const Menu({
    super.key,
    required this.onClickMap,
    required this.onClickImgData,
    required this.imageDataList,
    required this.companyDataList,
    required this.polygonData,
    required this.onClickMapData,
    required this.onFilterCompanies,
    required this.selectedProductTypes,
    required this.communes,
    required this.districts,
    required this.onFilterCommunes,
    required this.onFilterDistricts,
    required this.onToggleCommunes,
    required this.onToggleDistricts,
    required this.showCommunes,
    required this.showDistricts,
    required this.selectedCommuneIds,
    required this.selectedDistrictIds,
    required this.showBorders,
    required this.onToggleBorders,
    required this.selectedMapType,
  });

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late int selectedMapType;
  late Set<String> localSelectedProductTypes;
  late Set<int> localSelectedCommuneIds;
  late Set<int> localSelectedDistrictIds;
  late bool localShowCommunes;
  late bool localShowDistricts;
  bool _allCommunesSelected = false;

  @override
  void initState() {
    super.initState();
    selectedMapType = widget.selectedMapType;
    localSelectedProductTypes = Set<String>.from(widget.selectedProductTypes);
    localSelectedCommuneIds = Set<int>.from(widget.selectedCommuneIds);
    localSelectedDistrictIds = Set<int>.from(widget.selectedDistrictIds);
    localShowCommunes = widget.showCommunes;
    localShowDistricts = widget.showDistricts;
    _allCommunesSelected =
        localSelectedCommuneIds.length == widget.communes.length;
  }

  void _toggleAllCommunes(bool? value) {
    setState(() {
      _allCommunesSelected = value ?? false;
      if (_allCommunesSelected) {
        localSelectedCommuneIds =
            Set<int>.from(widget.communes.map((c) => c.id));
      } else {
        localSelectedCommuneIds.clear();
      }
      widget.onFilterCommunes(localSelectedCommuneIds.toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    Set<String> productTypes = widget.companyDataList
        .map((company) => company.productTypeName)
        .toSet();

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
                value: 0,
                groupValue: selectedMapType,
                onChanged: (value) {
                  setState(() {
                    selectedMapType = value!;
                    widget.onClickMap(value);
                  });
                },
              ),
              RadioListTile<int>(
                title: const Text('Bản đồ vệ tinh'),
                value: 1,
                groupValue: selectedMapType,
                onChanged: (value) {
                  setState(() {
                    selectedMapType = value!;
                    widget.onClickMap(value);
                  });
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
            children: [
              CheckboxListTile(
                title: const Text('Ranh giới'),
                value: widget.showBorders,
                onChanged: (bool? value) {
                  widget.onToggleBorders(value ?? false);
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.blue,
              ),
              CheckboxListTile(
                title: const Text('Ranh giới huyện'),
                value: localShowDistricts,
                onChanged: (bool? value) {
                  setState(() {
                    localShowDistricts = value ?? false;
                    widget.onToggleDistricts(localShowDistricts);
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.blue,
              ),
              CheckboxListTile(
                title: const Text('Ranh giới xã'),
                value: localShowCommunes,
                onChanged: (bool? value) {
                  setState(() {
                    localShowCommunes = value ?? false;
                    widget.onToggleCommunes(localShowCommunes);
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.blue,
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.home),
            title: const Text('Lớp chủ thể OCOP'),
            subtitle: const Text('Lọc theo chủ thể'),
            children: [
              ...productTypes.map((type) {
                int count = widget.companyDataList
                    .where((company) => company.productTypeName == type)
                    .length;
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
                  activeColor: Colors.blue,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        localSelectedProductTypes.add(type);
                      } else {
                        localSelectedProductTypes.remove(type);
                      }
                      widget.onFilterCompanies(
                          localSelectedProductTypes.toList());
                    });
                  },
                );
              }),
            ],
          ),
          if (localShowDistricts)
            ExpansionTile(
              leading: const Icon(Icons.location_city),
              title: const Text('Lọc huyện'),
              children: widget.districts.map((district) {
                return CheckboxListTile(
                  title: Text(district.name),
                  value: localSelectedDistrictIds.contains(district.id),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.blue,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        localSelectedDistrictIds.add(district.id);
                      } else {
                        localSelectedDistrictIds.remove(district.id);
                      }
                      widget
                          .onFilterDistricts(localSelectedDistrictIds.toList());
                    });
                  },
                );
              }).toList(),
            ),
          if (localShowCommunes)
            ExpansionTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Lọc xã'),
              children: [
                CheckboxListTile(
                  title: const Text('Chọn tất cả'),
                  value: _allCommunesSelected,
                  onChanged: _toggleAllCommunes,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const Divider(),
                ...widget.communes.map((commune) {
                  return CheckboxListTile(
                    title: Text(commune.name),
                    value: localSelectedCommuneIds.contains(commune.id),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Colors.blue,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          localSelectedCommuneIds.add(commune.id);
                        } else {
                          localSelectedCommuneIds.remove(commune.id);
                        }
                        _allCommunesSelected = localSelectedCommuneIds.length ==
                            widget.communes.length;
                        widget
                            .onFilterCommunes(localSelectedCommuneIds.toList());
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
