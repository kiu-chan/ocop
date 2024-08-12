import 'package:flutter/material.dart';
import 'package:ocop/mainData/user/authService.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? profile;
  String? role;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    profile = await getProfile();
    role = await AuthService.getUserRole();
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
      backgroundColor: Colors.white,
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
                        child: Image.asset(
                          'lib/src/assets/img/settings/ic_launcher.png',
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
                          Expanded(
                            child: Text(
                              profile != null
                                  ? profile!['name'] ?? 'Chưa có tên'
                                  : 'Chưa có thông tin',
                              style: const TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          if (role != 'admin')
                            Text(
                              profile != null
                                  ? profile!['commune'] ?? 'Chưa có xã'
                                  : 'Đăng nhập để xem thông tin',
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),
                          const SizedBox(height: 5.0),
                          Text(
                            role ?? '',
                            // role != null ? (role == 'admin' ? 'Admin' : 'User') : '',
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
            // IconButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => const UserInformation(),
            //       ),
            //     ).then((_) => _initializeProfile()); // Refresh profile after returning from UserInformation
            //   },
            //   icon: const Icon(
            //     Icons.edit_document,
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
