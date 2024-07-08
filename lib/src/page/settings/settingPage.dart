import 'package:flutter/material.dart';
import 'package:ocop/src/page/settings/profile/profile.dart';
import 'package:ocop/src/page/settings/elements/options.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 200, 
            child: Profile()
            ),
          FractionallySizedBox(
            widthFactor: 0.8,
            child: Container(
              height: 300,
              child: Options(),
            ),
          )
        ],
      ),
    );
  }
}
