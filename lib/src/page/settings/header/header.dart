import 'package:flutter/material.dart';

class HeaderSettings extends StatefulWidget {
  @override
  _HeaderSettingsState createState() => _HeaderSettingsState();
}

class _HeaderSettingsState extends State<HeaderSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Expanded(
        child: ClipOval(
  child: Image.network(
    'lib/src/assets/img/settings/images.png',
    width: 100, // Chiều rộng của hình ảnh
    height: 100, // Chiều cao của hình ảnh
    fit: BoxFit.cover, // Cách điều chỉnh hình ảnh trong khung
  ),
)
      )
    );
  }
}
