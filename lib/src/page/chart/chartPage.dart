import 'package:flutter/material.dart';
import 'package:ocop/mainData/offline/chart_offline_storage.dart';
import 'package:ocop/mainData/user/authService.dart';
import 'package:ocop/src/page/chart/elements/pieChart.dart';
import 'package:ocop/src/data/chart/chartData.dart';
import 'package:ocop/src/page/chart/elements/barChart.dart';
import 'chartMenu.dart';
import 'chartDataLoader.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({Key? key}) : super(key: key);

  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  int selectedChart = 1;
  int selectedLoadData = 1;
  int selectedCompanyData = 1;
  int selectedOcopData = 1;
  int checkSelected = 1;
  bool checkData = false;
  bool isAdmin = false;
  bool isOffline = false;

  ChartData chartData = ChartData(
      data: {'data': 0},
      title: "Chưa có dữ liệu",
      x_title: "Chưa có dữ liệu",
      y_title: "Chưa có dữ liệu",
      name: "Chưa có dữ liệu");

  late ChartDataLoader dataLoader;

  @override
  void initState() {
    super.initState();
    dataLoader = ChartDataLoader();
    _initializeData();
    print(isOffline);
  }

  Future<void> _initializeData() async {
    await _checkConnectivity();
    await _checkUserRole();
    if (!isOffline) {
      await _loadAndSaveAllData();
    }
    await _loadInitialData();
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      isOffline = connectivityResult == ConnectivityResult.none;
    });
  }

  Future<void> _checkUserRole() async {
    String? userRole = await AuthService.getUserRole();
    setState(() {
      isAdmin = userRole == 'admin';
    });
  }

  Future<void> _loadAndSaveAllData() async {
    await dataLoader.connect();
    await _loadAndSaveData('product_1', dataLoader.loadProductRating);
    await _loadAndSaveData('product_2', dataLoader.loadProductCategory);
    await _loadAndSaveData('product_3', dataLoader.loadProductCommune);
    await _loadAndSaveData('product_4', dataLoader.loadProductDistrict);
    await _loadAndSaveData('product_5', dataLoader.loadProductYear);
    await _loadAndSaveData('company_1', dataLoader.loadCompanyTypes);
    await _loadAndSaveData('company_2', dataLoader.loadCompanyDistricts);
    await _loadAndSaveData('company_3', dataLoader.loadCompanyStatus);
    if (isAdmin) {
      await _loadAndSaveData('ocop_1', dataLoader.loadTotalProductCount);
      await _loadAndSaveData('ocop_2', dataLoader.loadProductStatusCounts);
      await _loadAndSaveData('ocop_3', dataLoader.loadOcopFileDistrict);
      await _loadAndSaveData('ocop_4', dataLoader.loadOcopFileYear);
    }
  }

  Future<void> _loadAndSaveData(
      String identifier, Future<ChartData> Function() loadFunction) async {
    try {
      var data = await loadFunction();
      await ChartOfflineStorage.saveChartData(identifier, data);
    } catch (e) {
      setState(() {
        isOffline = true;
      });
      print('Lỗi khi tải và lưu dữ liệu cho $identifier: $e');
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      checkData = false;
    });

    String identifier = _getCurrentIdentifier();
    if (isOffline) {
      await _loadOfflineData(identifier);
    } else {
      await _loadOnlineData(identifier);
    }
  }

  Future<void> _loadOnlineData(String identifier) async {
    try {
      await dataLoader.connect();
      var newChartData = await _getDataForIdentifier(identifier);
      setState(() {
        chartData = newChartData;
        checkData = true;
      });
      await ChartOfflineStorage.saveChartData(identifier, chartData);
    } catch (e) {
      print('Lỗi khi tải dữ liệu online: $e');
      await _loadOfflineData(identifier);
    }
  }

  Future<void> _loadOfflineData(String identifier) async {
    ChartData? offlineData = await ChartOfflineStorage.getChartData(identifier);
    setState(() {
      if (offlineData != null) {
        chartData = offlineData;
      } else {
        chartData = ChartData(
            data: {'data': 0},
            title: "Không có dữ liệu offline",
            x_title: "Không có dữ liệu",
            y_title: "Không có dữ liệu",
            name: "Không có dữ liệu offline");
      }
      checkData = true;
    });
  }

  Future<ChartData> _getDataForIdentifier(String identifier) async {
    switch (identifier) {
      case 'product_1':
        return await dataLoader.loadProductRating();
      case 'product_2':
        return await dataLoader.loadProductCategory();
      case 'product_3':
        return await dataLoader.loadProductCommune();
      case 'product_4':
        return await dataLoader.loadProductDistrict();
      case 'product_5':
        return await dataLoader.loadProductYear();
      case 'company_1':
        return await dataLoader.loadCompanyTypes();
      case 'company_2':
        return await dataLoader.loadCompanyDistricts();
      case 'company_3':
        return await dataLoader.loadCompanyStatus();
      case 'ocop_1':
        return await dataLoader.loadTotalProductCount();
      case 'ocop_2':
        return await dataLoader.loadProductStatusCounts();
      case 'ocop_3':
        return await dataLoader.loadOcopFileDistrict();
      case 'ocop_4':
        return await dataLoader.loadOcopFileYear();
      default:
        throw Exception('Không tìm thấy dữ liệu cho identifier: $identifier');
    }
  }

  String _getCurrentIdentifier() {
    switch (checkSelected) {
      case 1:
        return 'product_$selectedLoadData';
      case 2:
        return 'company_$selectedCompanyData';
      case 3:
        return 'ocop_$selectedOcopData';
      default:
        return 'unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            isOffline ? const Text('Biểu đồ(offline)') : const Text('Biểu đồ'),
        automaticallyImplyLeading: false,
        actions: [
          if (isOffline)
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
            onPressed: () async {
              await _checkConnectivity();
              if (!isOffline) {
                await _loadAndSaveAllData();
              }
              await _loadInitialData();
            },
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
      endDrawer: ChartMenu(
        isAdmin: isAdmin,
        selectedChart: selectedChart,
        checkSelected: checkSelected,
        selectedLoadData: selectedLoadData,
        selectedCompanyData: selectedCompanyData,
        selectedOcopData: selectedOcopData,
        onChartTypeChanged: (value) {
          setState(() {
            selectedChart = value ?? 1;
          });
        },
        onCheckSelectedChanged: (value) async {
          setState(() {
            checkSelected = value ?? 1;
          });
          await _loadInitialData();
        },
        onLoadDataChanged: (value) async {
          setState(() {
            selectedLoadData = value ?? 1;
          });
          await _loadInitialData();
        },
        onCompanyDataChanged: (value) async {
          setState(() {
            selectedCompanyData = value ?? 1;
          });
          await _loadInitialData();
        },
        onOcopDataChanged: (value) async {
          setState(() {
            selectedOcopData = value ?? 1;
          });
          await _loadInitialData();
        },
      ),
      body: Column(
        children: [
          if (isOffline)
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.orange[100],
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[800]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đây là dữ liệu offline. Vui lòng kết nối mạng để cập nhật dữ liệu mới nhất.',
                      style: TextStyle(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: checkData
                ? (selectedChart == 1
                    ? PieChartSample(chartData: chartData)
                    : BarChartSample(chartData: chartData))
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
