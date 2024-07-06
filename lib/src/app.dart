import 'package:flutter/material.dart';
import 'package:ocop/src/page/map/mapPage.dart';
import 'package:ocop/src/page/home/homePage.dart';
import 'package:ocop/src/page/home/home.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() {

    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Home(),
      )
    );
  }
}