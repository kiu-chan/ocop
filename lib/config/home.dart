import 'package:ocop/mainData/user/authService.dart';

class HomeConfig {
  bool isAdmin = false;
  bool isCouncil = false;
  bool checkIcon = false;

  Future<void> getCheckItem() async {
    final userRole = await AuthService.getUserRole();
    isAdmin = userRole == 'admin';
    // isCouncil = userRole == 'council'; //tạm thời tắt
    checkIcon = isAdmin || isCouncil;    
  }
}