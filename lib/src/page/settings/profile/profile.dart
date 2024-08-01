import 'package:flutter/material.dart';
import 'package:ocop/src/page/settings/profile/userInformation.dart';
import 'package:ocop/mainData/user/authService.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? profile;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    profile = await getProfile();
    setState(() {}); // Cập nhật UI sau khi có dữ liệu
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final isLogIn = await AuthService.isLoggedIn();
    if (isLogIn) {
      return await AuthService.getUserInfo();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 161, 212, 254),
        padding: const EdgeInsets.only(top: 20, left: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 90.0,
                    height: 90.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 70, 162, 236),
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
                  Expanded(
                    child: SizedBox(
                      height: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile != null ? profile!['name'] ?? 'Chưa có tên' : 'Chưa có thông tin người dùng',
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            profile != null ? profile!['commune'] ?? 'Chưa có xã' : 'Đăng nhập để xem thông tin',
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserInformation(),
                  ),
                );
              },
              icon: const Icon(
                Icons.edit_document,
              ),
            )
          ],
        ),
      ),
    );
  }
}