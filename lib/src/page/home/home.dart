import 'package:flutter/material.dart';
import 'package:ocop/src/page/map/mapPage.dart';
import 'package:ocop/src/page/home/homePage.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget currentWidget = SizedBox.shrink();
    switch(currentIndex) {
      case 0:
      {
        currentWidget = homePage();
        break;
      }
      
      case 1:
      {
        currentWidget = mapPage();
        break;
      }
    }
    return Scaffold(
      body: Container(
        // color: Colors.red,
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child:
              Container(key: ValueKey<int>(currentIndex), child: currentWidget),
        ),
      ),
      bottomNavigationBar: Container(
        child: BottomNavigationBar(
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
                  Icons.settings,
                  // color: Colors.black,
                ),
                label: "Settings"),
          ],
        ),
      ),
    );
  }
}
