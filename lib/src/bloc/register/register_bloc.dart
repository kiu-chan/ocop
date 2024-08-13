import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_event.dart';
import 'register_state.dart';
import 'package:ocop/mainData/database/databases.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final DefaultDatabaseOptions _databaseOptions = DefaultDatabaseOptions();

  RegisterBloc() : super(RegisterState()) {
    on<NameChanged>(_onNameChanged);
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<ConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<CommuneChanged>(_onCommuneChanged);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<ClearErrors>(_onClearErrors);
  }

  void _onNameChanged(NameChanged event, Emitter<RegisterState> emit) {
    emit(state.copyWith(name: event.name));
  }

  void _onEmailChanged(EmailChanged event, Emitter<RegisterState> emit) {
    emit(state.copyWith(email: event.email));
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<RegisterState> emit) {
    emit(state.copyWith(password: event.password));
  }

  void _onConfirmPasswordChanged(ConfirmPasswordChanged event, Emitter<RegisterState> emit) {
    emit(state.copyWith(confirmPassword: event.confirmPassword));
  }

  void _onCommuneChanged(CommuneChanged event, Emitter<RegisterState> emit) {
    emit(state.copyWith(communeId: event.communeId));
  }

  void _onClearErrors(ClearErrors event, Emitter<RegisterState> emit) {
    emit(state.copyWith(errors: []));
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(status: RegisterStatus.loading, errors: []));
    await Future.delayed(const Duration(seconds: 1));

    List<String> errors = [];

    if (state.name.isEmpty) {
      errors.add('Vui lòng nhập họ tên');
    }
    if (!_isValidEmail(state.email)) {
      errors.add('Địa chỉ email không hợp lệ');
    }
    if (!_isValidPassword(state.password)) {
      errors.add('Mật khẩu phải có ít nhất 8 ký tự');
    }
    if (state.password != state.confirmPassword) {
      errors.add('Mật khẩu xác nhận không khớp');
    }
    if (state.communeId == null) {
      errors.add('Vui lòng chọn xã');
    }

    if (errors.isNotEmpty) {
      emit(state.copyWith(status: RegisterStatus.failure, errors: errors));
      return;
    }

    try {
      await _databaseOptions.connect();

      bool userExists = await _databaseOptions.checkUserExists(state.email);

      if (userExists) {
        emit(state.copyWith(
          status: RegisterStatus.failure,
          errors: ['Email đã tồn tại'],
        ));
      } else {
        bool created = await _databaseOptions.createUser(
          state.name,
          state.email,
          state.password,
          state.communeId!,
        );
        if (created) {
          emit(state.copyWith(status: RegisterStatus.success, errors: []));
        } else {
          emit(state.copyWith(
            status: RegisterStatus.failure,
            errors: ['Đăng ký thất bại'],
          ));
        }
      }
    } catch (e) {
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errors: ['Đã xảy ra lỗi: $e'],
      ));
    } finally {
      await _databaseOptions.close();
    }
  }

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 8;
  }
}