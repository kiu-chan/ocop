import 'package:flutter/material.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:intl/intl.dart';
import 'package:ocop/src/data/councils/councilData.dart';
import 'councilProductsPage.dart';
import 'package:ocop/mainData/offline/council_offline_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class CouncilListPage extends StatefulWidget {
  const CouncilListPage({super.key});

  @override
  _CouncilListPageState createState() => _CouncilListPageState();
}

class _CouncilListPageState extends State<CouncilListPage> {
  List<Council> _councils = [];
  List<Council> _filteredCouncils = [];
  Set<String> _years = {};
  Set<String> _districts = {};
  final Set<String> _selectedYears = {};
  final Set<String> _selectedDistricts = {};
  bool _isOffline = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivityAndLoadData();
  }

  Future<void> _checkConnectivityAndLoadData() async {
    bool result = await InternetConnectionChecker().hasConnection;
    setState(() {
      _isOffline = !result;
      _isLoading = true;
    });
    await _loadCouncils();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadCouncils() async {
    if (_isOffline) {
      await _loadOfflineCouncils();
    } else {
      await _loadOnlineCouncils();
    }
  }

  Future<void> _loadOfflineCouncils() async {
    final offlineCouncils = await CouncilOfflineStorage.getCouncilList();
    setState(() {
      _councils = offlineCouncils;
      _filteredCouncils = List.from(_councils);
      _updateFilters();
    });
  }

  Future<void> _loadOnlineCouncils() async {
    final DefaultDatabaseOptions databaseOptions = DefaultDatabaseOptions();
    await databaseOptions.connect();
    final councilsData =
        await databaseOptions.councilsDatabase.getCouncilList();
    final councils =
        councilsData.map((data) => Council.fromJson(data)).toList();
    await CouncilOfflineStorage.saveCouncilList(councils);
    setState(() {
      _councils = councils;
      _filteredCouncils = List.from(_councils);
      _updateFilters();
    });
  }

  void _updateFilters() {
    _years =
        _councils.map((c) => DateFormat('yyyy').format(c.createdAt)).toSet();
    _districts = _councils
        .map((c) =>
            c.level.toLowerCase() == 'province' ? 'Tỉnh' : c.districtName)
        .toSet();
  }

  void _filterCouncils() {
    setState(() {
      _filteredCouncils = _councils.where((council) {
        bool yearMatch = _selectedYears.isEmpty ||
            _selectedYears
                .contains(DateFormat('yyyy').format(council.createdAt));
        bool districtMatch = _selectedDistricts.isEmpty ||
            (_selectedDistricts.contains('Tỉnh') &&
                council.level.toLowerCase() == 'province') ||
            _selectedDistricts.contains(council.districtName);
        return yearMatch && districtMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isOffline
            ? 'Danh sách hội đồng chấm (Offline)'
            : 'Danh sách hội đồng chấm'),
        actions: [
          if (_isOffline)
            IconButton(
              icon: const Icon(Icons.cloud_off),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang ở chế độ offline')),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkConnectivityAndLoadData,
          ),
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
      backgroundColor: Colors.white,
      endDrawer: Drawer(
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
                      'Bộ lọc',
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
              leading: const Icon(Icons.calendar_today),
              title: const Text('Năm'),
              children: _years
                  .map((year) => CheckboxListTile(
                        title: Text(year),
                        value: _selectedYears.contains(year),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedYears.add(year);
                            } else {
                              _selectedYears.remove(year);
                            }
                            _filterCouncils();
                          });
                        },
                      ))
                  .toList(),
            ),
            ExpansionTile(
              leading: const Icon(Icons.location_city),
              title: const Text('Huyện/Tỉnh'),
              children: _districts
                  .map((district) => CheckboxListTile(
                        title: Text(district),
                        value: _selectedDistricts.contains(district),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedDistricts.add(district);
                            } else {
                              _selectedDistricts.remove(district);
                            }
                            _filterCouncils();
                          });
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _filteredCouncils.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: Colors.grey[300]),
              itemBuilder: (context, index) {
                final council = _filteredCouncils[index];
                return ListTile(
                  title: Text(
                    council.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cấp: ${council.level}'),
                      Text(
                          'Ngày tạo: ${DateFormat('dd/MM/yyyy').format(council.createdAt)}'),
                      if (council.level.toLowerCase() != 'province')
                        Text('Huyện: ${council.districtName}'),
                    ],
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: council.isArchived
                          ? Colors.grey[300]
                          : Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      council.isArchived ? 'Đã lưu trữ' : 'Đang hoạt động',
                      style: TextStyle(
                        color: council.isArchived
                            ? Colors.black54
                            : Colors.green[800],
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CouncilProductsPage(
                          councilId: council.id,
                          councilTitle: council.title,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
