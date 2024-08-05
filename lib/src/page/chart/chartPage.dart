import 'package:flutter/material.dart';
import 'package:ocop/src/page/chart/elements/pieChart.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:ocop/src/data/chart/chartData.dart';
import 'package:ocop/src/page/chart/elements/barChart.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  int? selectedChart = 1;
  int? selectedLoadData = 1;
  int? selectedCompanyData = 1;
  int? checkSelected = 1;
  bool checkData = false;

  ChartData chartData = ChartData(
    data: {'data': 0},
    title: "Chưa có dữ liệu",
    x_title: "Chưa có dữ liệu",
    y_title: "Chưa có dữ liệu",
    name: "Chưa có dữ liệu"
  );

  late DefaultDatabaseOptions databaseData;

  @override
  void initState() {
    super.initState();
    databaseData = DefaultDatabaseOptions();
    _loadProductRating();
  }

  void setCheckData() {
    setState(() {
      checkData = !checkData;
    });
  }

  Future<void> _loadProductRating() async {
    await databaseData.connect();
    var groupedRating = await databaseData.getProductRatingCounts();
    
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        chartData = ChartData(
          name: "Biểu đồ thống kê sản phẩm theo số sao",
          title: "sao",
          x_title: "Số sao",
          y_title: "Số lượng sản phẩm",
          data: groupedRating,
        );
        setCheckData();
      });
    });
  }

  Future<void> _loadProductCategory() async {
    await databaseData.connect();
    var groupedRating = await databaseData.getProductCategoryCounts();
    
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        chartData = ChartData(
          name: "Biểu đồ thống kê sản phẩm theo phân loại",
          title: "",
          x_title: "Phân loại",
          y_title: "Số lượng sản phẩm",
          data: groupedRating,
        );
        setCheckData();
      });
    });
  }

  Future<void> _loadProductCommune() async {
    await databaseData.connect();
    var communeData = await databaseData.getProductCommuneCounts();
    
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        chartData = ChartData(
          name: "Biểu đồ thống kê số lượng xã theo số lượng sản phẩm",
          title: "Sản phẩm",
          x_title: "Số lượng sản phẩm",
          y_title: "Số xã",
          data: communeData['grouped'] as Map<String, int>,
          detailedData: communeData['detailed'] as Map<String, int>,
          useDetailedDataForTable: true,
        );
        setCheckData();
      });
    });
  }

  Future<void> _loadProductYear() async {
    await databaseData.connect();
    var groupedYear = await databaseData.getProductYearCounts();
    
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        chartData = ChartData(
          name: "Biểu đồ thống kê sản phẩm theo năm",
          title: "",
          x_title: "Năm",
          y_title: "Số lượng",
          data: groupedYear,
        );
        setCheckData();
      });
    });
  }

  Future<void> _loadCompanyTypes() async {
    await databaseData.connect();
    var companyTypeCounts = await databaseData.getCompanyTypeCounts();
    
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        chartData = ChartData(
          name: "Biểu đồ thống kê số lượng chủ thể OCOP theo loại hình kinh doanh",
          title: "",
          x_title: "Loại hình",
          y_title: "Số lượng",
          data: companyTypeCounts,
        );
        setCheckData();
      });
    });
  }

  Future<void> _loadCompanyDistricts() async {
  await databaseData.connect();
  var districtData = await databaseData.getCompanyDistrictCounts();
  
  Future.delayed(const Duration(seconds: 1), () {
    setState(() {
      chartData = ChartData(
        name: "Biểu đồ thống kê số lượng chủ thể OCOP theo huyện",
        title: "Công ty",
        x_title: "Huyện",
        y_title: "Số lượng",
        data: districtData['detailed'] as Map<String, int>,
      );
      setCheckData();
    });
  });
}

  Future<void> _loadProductDistrict() async {
    await databaseData.connect();
    var districtData = await databaseData.getProductDistrictCounts();
    
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        chartData = ChartData(
          name: "Biểu đồ thống kê số lượng sản phẩm theo huyện",
          title: "Sản phẩm",
          x_title: "Huyện",
          y_title: "Số lượng",
          data: districtData['detailed'] as Map<String, int>,
        );
        setCheckData();
      });
    });
  }


  Future<void> _loadCompanyStatus() async {
    await databaseData.connect();
    var statusCounts = await databaseData.getCompanyStatusCounts();
    
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        chartData = ChartData(
          name: "Biểu đồ thống kê số lượng chủ thể OCOP theo trạng thái hoạt động",
          title: "",
          x_title: "Trạng thái",
          y_title: "Số lượng",
          data: statusCounts,
        );
        setCheckData();
      });
    });
  }

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
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
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
              leading: const Icon(Icons.auto_graph),
              title: const Text("Biểu đồ"),
              subtitle: const Text("Lựa chọn dạng biểu đồ"),
              children: <Widget>[
                RadioListTile<int>(
                  title: const Text('Biểu đồ hình tròn'),
                  value: 1,
                  groupValue: selectedChart,
                  onChanged: (value) {
                    setState(() {
                      selectedChart = value;
                    });
                  },
                ),
                RadioListTile<int>(
                  title: const Text('Biểu đồ cột'),
                  value: 2,
                  groupValue: selectedChart,
                  onChanged: (value) {
                    setState(() {
                      selectedChart = value;
                    });
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.wysiwyg),
              title: const Text("Đối tượng thống kê"),
              subtitle: const Text("Lựa chọn đối tượng thống kê"),
              children: <Widget>[
                RadioListTile<int>(
                  title: const Text('Sản phẩm'),
                  value: 1,
                  groupValue: checkSelected,
                  onChanged: (value) {
                    setState(() {
                      checkSelected = value;
                      setCheckData();
                      _loadProductRating();
                    });
                  },
                ),
                RadioListTile<int>(
                  title: const Text('Công ty'),
                  value: 2,
                  groupValue: checkSelected,
                  onChanged: (value) {
                    setState(() {
                      checkSelected = value;
                      setCheckData();
                      _loadCompanyTypes();
                    });
                  },
                ),
              ],
            ),
            if (checkSelected == 1)
              ExpansionTile(
                leading: const Icon(Icons.shopping_cart_outlined),
                title: const Text("Thống kê sản phẩm"),
                subtitle: const Text("Lựa chọn đối tượng thống kê"),
                children: <Widget>[
                  RadioListTile<int>(
                    title: const Text('Theo số sao'),
                    value: 1,
                    groupValue: selectedLoadData,
                    onChanged: (value) {
                      setState(() {
                        selectedLoadData = value;
                        setCheckData();
                        _loadProductRating();
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: const Text('Theo loại sản phẩm'),
                    value: 2,
                    groupValue: selectedLoadData,
                    onChanged: (value) {
                      setState(() {
                        selectedLoadData = value;
                        setCheckData();
                        _loadProductCategory();
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: const Text('Theo xã'),
                    value: 3,
                    groupValue: selectedLoadData,
                    onChanged: (value) {
                      setState(() {
                        selectedLoadData = value;
                        setCheckData();
                        _loadProductCommune();
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: const Text('Theo huyện'),
                    value: 4,
                    groupValue: selectedLoadData,
                    onChanged: (value) {
                      setState(() {
                        selectedLoadData = value;
                        setCheckData();
                        _loadProductDistrict();
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: const Text('Theo năm'),
                    value: 5,
                    groupValue: selectedLoadData,
                    onChanged: (value) {
                      setState(() {
                        selectedLoadData = value;
                        setCheckData();
                        _loadProductYear();
                      });
                    },
                  ),
                ],
              ),
            if (checkSelected == 2)
              ExpansionTile(
                leading: const Icon(Icons.business),
                title: const Text("Thống kê công ty"),
                subtitle: const Text("Lựa chọn đối tượng thống kê"),
                children: <Widget>[
                  RadioListTile<int>(
                    title: const Text('Theo loại hình công ty'),
                    value: 1,
                    groupValue: selectedCompanyData,
                    onChanged: (value) {
                      setState(() {
                        selectedCompanyData = value;
                        setCheckData();
                        _loadCompanyTypes();
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: const Text('Theo huyện'),
                    value: 2,
                    groupValue: selectedCompanyData,
                    onChanged: (value) {
                      setState(() {
                        selectedCompanyData = value;
                        setCheckData();
                        _loadCompanyDistricts();
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: const Text('Theo trạng thái hoạt động'),
                    value: 3,
                    groupValue: selectedCompanyData,
                    onChanged: (value) {
                      setState(() {
                        selectedCompanyData = value;
                        setCheckData();
                        _loadCompanyStatus();
                      });
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
      body: checkData
          ? (selectedChart == 1
              ? PieChartSample(chartData: chartData,)
              : BarChartSample(chartData: chartData))
          : const Center(child: CircularProgressIndicator()),
    );
  }
}