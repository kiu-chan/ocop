import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 161, 212, 254),
            padding: const EdgeInsets.only(top: 20, left: 20),
        child: Row(
          children: [
            Container(
              width: 90.0,
              height: 90.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 70, 162, 236), // Màu nền của khung ảnh
              ),
              child: Center(
                child: ClipOval(
                  child: Image.network(
                    'https://i.pinimg.com/736x/11/e4/4d/11e44d85743b28fa62121b5ae71a914b.jpg',
                    width: 88.0,
                    height: 88.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Container(
              height: 100,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "name",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    'email',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
