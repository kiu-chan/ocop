import 'package:flutter/material.dart';
import 'package:ocop/src/page/map/mapPage.dart';
import 'package:ocop/src/page/home/homePage.dart';
import 'package:ocop/src/page/settings/settingPage.dart';
import 'package:ocop/src/page/chart/chartPage.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget currentWidget = const SizedBox.shrink();
    switch(currentIndex) {
      case 0:
      {
        currentWidget = const HomePage();
        break;
      }
      
      case 1:
      {
        currentWidget = const MapPage();
        break;
      }

      case 2:
      {
        currentWidget = const ChartPage();
        break;
      }

      case 3:
      {
        currentWidget = const SettingPage();
        break;
      }
    }
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child:
            Container(key: ValueKey<int>(currentIndex), child: currentWidget),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
          type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              // color: Colors.black,
            ),
            label: "Home",
            // backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.map_outlined,
            ),
            label: "Map",
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.ssid_chart,
                // color: Colors.black,
              ),
              label: "Chart"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.settings,
                // color: Colors.black,
              ),
              label: "Settings"),
        ],
      ),
    );
  }
}
