import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_event.dart';
import 'register_state.dart';
import 'package:ocop/mainData/database/databases.dart';


class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final DefaultDatabaseOptions _databaseOptions = DefaultDatabaseOptions();

  RegisterBloc() : super(RegisterInitial()) {
    on<RegisterButtonPressed>(_onRegisterButtonPressed);
  }

  bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 8; // Minimum 8 characters
  }

  Future<void> _onRegisterButtonPressed(
    RegisterButtonPressed event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());
    await Future.delayed(const Duration(seconds: 1));

    // Validation
    if (event.name.isEmpty) {
      emit(RegisterValidationFailure(error: 'Vui lòng nhập họ tên'));
      return;
    }
    if (!isValidEmail(event.email)) {
      emit(RegisterValidationFailure(error: 'Địa chỉ email không hợp lệ'));
      return;
    }
    if (!isValidPassword(event.password)) {
      emit(RegisterValidationFailure(error: 'Mật khẩu phải có ít nhất 8 ký tự'));
      return;
    }
    if (event.password != event.confirmPassword) {
      emit(RegisterValidationFailure(error: 'Mật khẩu xác nhận không khớp'));
      return;
    }

    try {
      await _databaseOptions.connect();

      bool userExists = await _databaseOptions.checkUserExists(event.email);

      if (userExists) {
        emit(RegisterFailure(error: 'Email đã tồn tại'));
      } else {
        bool created = await _databaseOptions.createUser(
          event.name,
          event.email,
          event.password,
          event.communeId
        );
        if (created) {
          emit(RegisterSuccess());
        } else {
          emit(RegisterFailure(error: 'Đăng ký thất bại'));
        }
      }
    } catch (e) {
      emit(RegisterFailure(error: 'Đã xảy ra lỗi: $e'));
    } finally {
      await _databaseOptions.close();
    }
  }
}