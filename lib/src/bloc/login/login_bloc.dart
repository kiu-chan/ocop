import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';
import 'package:ocop/authService.dart';
import 'package:ocop/databases.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final DefaultDatabaseOptions _databaseOptions = DefaultDatabaseOptions();

  LoginBloc() : super(LoginState()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<RememberMeChanged>(_onRememberMeChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<CheckLoginStatus>(_onCheckLoginStatus);
    on<LogoutRequested>(_onLogoutRequested);

    // Kết nối đến cơ sở dữ liệu khi khởi tạo Bloc
    _databaseOptions.connect().catchError((error) {
      print('Lỗi khi kết nối đến cơ sở dữ liệu: $error');
    });
  }

  void _onEmailChanged(EmailChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(email: event.email));
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(password: event.password));
  }

  void _onRememberMeChanged(RememberMeChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(rememberMe: event.rememberMe));
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.loading));
    await Future.delayed(const Duration(seconds: 1));
    try {
      final userInfo = await _databaseOptions.checkUserCredentials(state.email, state.password);
      if (userInfo != null) {
        await AuthService.setLoggedIn(true, state.email);
        await AuthService.setUserInfo(userInfo);
        emit(state.copyWith(
          status: LoginStatus.success,
          userInfo: userInfo,
          // isLoggedIn: true
        ));
      } else {
        emit(state.copyWith(status: LoginStatus.failure, error: 'Invalid email or password'));
      }
    } catch (error) {
      emit(state.copyWith(status: LoginStatus.failure, error: 'Login failed: ${error.toString()}'));
    }
  }

  Future<void> _onCheckLoginStatus(CheckLoginStatus event, Emitter<LoginState> emit) async {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (isLoggedIn) {
      final userInfo = await AuthService.getUserInfo();
      if (userInfo != null) {
        emit(state.copyWith(
          status: LoginStatus.success,
          userInfo: userInfo,
          // isLoggedIn: true
        ));
      } else {
        // User is logged in but we don't have their info, treat as logged out
        await AuthService.logout();
        emit(LoginState());
      }
    } else {
      emit(LoginState());
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<LoginState> emit) async {
    await AuthService.logout();
    emit(LoginState());
  }

  @override
  Future<void> close() async {
    await _databaseOptions.close();
    return super.close();
  }
}