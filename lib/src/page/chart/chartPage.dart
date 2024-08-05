// chartPage.dart
import 'package:flutter/material.dart';
import 'package:ocop/mainData/user/authService.dart';
import 'package:ocop/src/page/chart/elements/pieChart.dart';
import 'package:ocop/src/data/chart/chartData.dart';
import 'package:ocop/src/page/chart/elements/barChart.dart';
import 'chartMenu.dart';
import 'chartDataLoader.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({Key? key}) : super(key: key);

  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  int? selectedChart = 1;
  int? selectedLoadData = 1;
  int? selectedCompanyData = 1;
  int? selectedOcopData = 1;
  int? checkSelected = 1;
  bool checkData = false;
  bool isAdmin = false;

  ChartData chartData = ChartData(
    data: {'data': 0},
    title: "Chưa có dữ liệu",
    x_title: "Chưa có dữ liệu",
    y_title: "Chưa có dữ liệu",
    name: "Chưa có dữ liệu"
  );

  late ChartDataLoader dataLoader;

  @override
  void initState() {
    super.initState();
    dataLoader = ChartDataLoader();
    _loadProductRating();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    String? userRole = await AuthService.getUserRole();
    setState(() {
      isAdmin = userRole == 'admin';
    });
  }

  void setCheckData() {
    setState(() {
      checkData = !checkData;
    });
  }

  Future<void> _loadData(Future<ChartData> Function() loadFunction) async {
    await dataLoader.connect();
    var newChartData = await loadFunction();
    setState(() {
      chartData = newChartData;
      setCheckData();
    });
  }

  Future<void> _loadProductRating() => _loadData(dataLoader.loadProductRating);
  Future<void> _loadProductCategory() => _loadData(dataLoader.loadProductCategory);
  Future<void> _loadProductCommune() => _loadData(dataLoader.loadProductCommune);
  Future<void> _loadProductYear() => _loadData(dataLoader.loadProductYear);
  Future<void> _loadCompanyTypes() => _loadData(dataLoader.loadCompanyTypes);
  Future<void> _loadCompanyDistricts() => _loadData(dataLoader.loadCompanyDistricts);
  Future<void> _loadProductDistrict() => _loadData(dataLoader.loadProductDistrict);
  Future<void> _loadCompanyStatus() => _loadData(dataLoader.loadCompanyStatus);
  Future<void> _loadTotalProductCount() => _loadData(dataLoader.loadTotalProductCount);
  Future<void> _loadProductStatusCounts() => _loadData(dataLoader.loadProductStatusCounts);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biểu đồ'),
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
      endDrawer: ChartMenu(
        isAdmin: isAdmin,
        selectedChart: selectedChart,
        checkSelected: checkSelected,
        selectedLoadData: selectedLoadData,
        selectedCompanyData: selectedCompanyData,
        selectedOcopData: selectedOcopData,
        onChartTypeChanged: (value) {
          setState(() {
            selectedChart = value;
          });
        },
        onCheckSelectedChanged: (value) {
          setState(() {
            checkSelected = value;
            setCheckData();
            if (value == 1) {
              _loadProductRating();
            } else if (value == 2) {
              _loadCompanyTypes();
            } else if (value == 3 && isAdmin) {
              _loadTotalProductCount();
            }
          });
        },
        onLoadDataChanged: (value) {
          setState(() {
            selectedLoadData = value;
            setCheckData();
            switch (value) {
              case 1:
                _loadProductRating();
                break;
              case 2:
                _loadProductCategory();
                break;
              case 3:
                _loadProductCommune();
                break;
              case 4:
                _loadProductDistrict();
                break;
              case 5:
                _loadProductYear();
                break;
            }
          });
        },
        onCompanyDataChanged: (value) {
          setState(() {
            selectedCompanyData = value;
            setCheckData();
            switch (value) {
              case 1:
                _loadCompanyTypes();
                break;
              case 2:
                _loadCompanyDistricts();
                break;
              case 3:
                _loadCompanyStatus();
                break;
            }
          });
        },
        onOcopDataChanged: (value) {
          setState(() {
            selectedOcopData = value;
            setCheckData();
            switch (value) {
              case 1:
                _loadTotalProductCount();
                break;
              case 2:
                _loadProductStatusCounts();
                break;
            }
          });
        },
      ),
      body: checkData
          ? (selectedChart == 1
              ? PieChartSample(chartData: chartData,)
              : BarChartSample(chartData: chartData))
          : const Center(child: CircularProgressIndicator()),
    );
  }
}