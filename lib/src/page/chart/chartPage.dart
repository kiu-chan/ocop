import 'package:flutter/material.dart';
import 'package:ocop/src/page/chart/elements/pieChart.dart';
import 'package:ocop/databases.dart';
import 'package:ocop/src/data/chart/chartData.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  int? selectedChart = 1;

  bool checkData = false;

  ChartData chartData = ChartData(
    data: {
      'data': 0
    },
    title: "Chưa có dữ liệu"
    );


  late DefaultDatabaseOptions databaseData;

  @override
  void initState() {
    super.initState();
    databaseData = DefaultDatabaseOptions();
    _loadProduct();
  }

  void setCheckData() {
    setState(() {
      checkData = !checkData;
    });
  }
  Future<void> _loadProduct() async {
    await databaseData.connect();
    var groupedRating = await databaseData.getProductRatingCounts();
    
    setState(() {
      chartData = ChartData(
        title: "Sao",
        data: groupedRating,
      );
      checkData = true;
      // print(ListRating);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Biểu đồ'
        ),
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
                  color: Colors.blue
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
              leading: const Icon(Icons.auto_graph),
              title: const Text(
                "Biểu đồ"
              ),
              subtitle: const Text("Lựa chọn dạng biểu đồ"),
              children: <Widget> [
                RadioListTile<int>(
                  title: const Text('Biểu đồ hình tròn'),
                  value: 1,
                  groupValue: selectedChart,
                  onChanged: (value) {
                    setState(() {
                      selectedChart = value;
                      // _changeMapSource(0);
                      // widget.onClickMap(0);
                      // Navigator.pop(context);
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
                      // widget.onClickMap(1);
                      // _changeMapSource(1);
                      // Navigator.pop(context);
                    });
                  },
                ),
              ]
            ),
            ExpansionTile(
              leading: const Icon(Icons.wysiwyg),
              title: const Text(
                "Thống kê sản phẩm"
              ),
              subtitle: const Text("Lựa chọn đối tượng thống kê"),
              children: <Widget> [
                RadioListTile<int>(
                  title: const Text('Theo số sao'),
                  value: 1,
                  groupValue: selectedChart,
                  onChanged: (value) {
                    setState(() {
                      selectedChart = value;
                      // _changeMapSource(0);
                      // widget.onClickMap(0);
                      // Navigator.pop(context);
                    });
                  },
                ),
                RadioListTile<int>(
                  title: const Text('Theo nhóm ngành'),
                  value: 2,
                  groupValue: selectedChart,
                  onChanged: (value) {
                    setState(() {
                      selectedChart = value;
                      // widget.onClickMap(1);
                      // _changeMapSource(1);
                      // Navigator.pop(context);
                    });
                  },
                ),
                RadioListTile<int>(
                  title: const Text('Theo đơn vị hành chính'),
                  value: 3,
                  groupValue: selectedChart,
                  onChanged: (value) {
                    setState(() {
                      selectedChart = value;
                      // widget.onClickMap(1);
                      // _changeMapSource(1);
                      // Navigator.pop(context);
                    });
                  },
                ),
                RadioListTile<int>(
                  title: const Text('Theo năm'),
                  value: 4,
                  groupValue: selectedChart,
                  onChanged: (value) {
                    setState(() {
                      selectedChart = value;
                      // widget.onClickMap(1);
                      // _changeMapSource(1);
                      // Navigator.pop(context);
                    });
                  },
                ),
              ]
            )
          ],
        )
      ),
      // endDrawer: Menu(
      //   onClickMap: _changeMapSource,
      //   onClickImgData: _setStateProduct,
      //   imageDataList: imageDataList,
      //   polygonData: polygonData,
      //   onClickMapData: _setPolygonData,
      // ),
      
    body: checkData ? Row(
      children: [
        Expanded(
          child: PieChartSample1(
            chartData: chartData)
            
        ),
      ],
    ): const Center(child: CircularProgressIndicator(),),
    );
  }
}