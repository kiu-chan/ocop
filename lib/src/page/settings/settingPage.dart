import 'package:flutter/material.dart';
import 'package:ocop/src/page/settings/profile/profile.dart';
import 'package:ocop/src/page/settings/elements/options.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 200, 
              child: Profile()
              ),
            FractionallySizedBox(
              widthFactor: 0.8,
              child: SizedBox(
                height: 300,
                child: Options(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
