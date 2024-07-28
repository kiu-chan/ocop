import 'dart:async';
import 'package:ocop/src/validations/validations.dart';

class LoginBloc {
  final StreamController _userController = StreamController();
  final StreamController _passController = StreamController();
  final StreamController _passController2 = StreamController();

  Stream get userStream => _userController.stream;
  Stream get passStream => _passController.stream;
  Stream get passStream2 => _passController2.stream;

  bool isValidInfo(String username, String password) {
    if (!Validations.isValidUser(username)) {
      _userController.sink.addError("Tài khoản không hợp lệ");
      return false;
    }
    _userController.sink.add("ok");

    if (!Validations.isValidPassword(password)) {
      _passController.sink.addError("Mật khẩu không đúng định dạng");
      return false;
    }
    _passController.sink.add("ok");

    return true;
  }

  bool isValidNewInfo(String username, String password, String checkPass) {
    if (!Validations.isValidUser(username)) {
      _userController.sink.addError("Tài khoản không hợp lệ");
      return false;
    }
    _userController.sink.add("ok");

    if (!Validations.isValidPassword(password)) {
      _passController.sink.addError("Mật khẩu không đúng định dạng");
      return false;
    }
    _passController.sink.add("ok");

    if (!Validations.isValidPassword2(password, checkPass)) {
      _passController2.sink.addError("Mật khẩu không đúng");
      return false;
    }
    _passController2.sink.add("ok");
    return true;
  }

  void dispose() {
    _userController.close();
    _passController.close();
    _passController2.close();
  }
}
