import 'package:flutter/material.dart';
import 'package:ocop/src/page/map/mapPage.dart';
import 'package:ocop/src/page/home/homePage.dart';
import 'package:ocop/src/page/settings/settingPage.dart';
import 'package:ocop/src/page/chart/chartPage.dart';
import 'package:ocop/src/page/council/councilListPage.dart';
import 'package:ocop/config/home.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;
  final HomeConfig _homeConfig = HomeConfig();

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
  }

  Future<void> _checkAdminRole() async {
    await _homeConfig.getCheckItem();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      const HomePage(),
      const MapPage(),
      const ChartPage(),
      if (_homeConfig.checkIcon) const CouncilListPage(),
      const SettingPage(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Container(
          key: ValueKey<int>(currentIndex),
          child: pages[currentIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: "Map",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.ssid_chart),
            label: "Chart",
          ),
          if (_homeConfig.checkIcon)
            const BottomNavigationBarItem(
              icon: Icon(Icons.groups),
              label: "Council",
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
