import 'package:flutter/material.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'fngn'
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
      // endDrawer: Menu(
      //   onClickMap: _changeMapSource,
      //   onClickImgData: _setStateProduct,
      //   imageDataList: imageDataList,
      //   polygonData: polygonData,
      //   onClickMapData: _setPolygonData,
      // ),
      body: Row(
        children: [
          Text(
            "dfjegfi"
          )
        ]
      ),
    );
  }
}