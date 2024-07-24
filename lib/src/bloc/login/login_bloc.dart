import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';
import 'package:ocop/authService.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginState()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<RememberMeChanged>(_onRememberMeChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<CheckLoginStatus>(_onCheckLoginStatus);
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

    try {
      // TODO: Replace with actual login logic
      if (state.email == 'user@example.com' && state.password == 'password') {
        await AuthService.setLoggedIn(true, state.email);
        emit(state.copyWith(status: LoginStatus.success));
      } else {
        emit(state.copyWith(status: LoginStatus.failure, error: 'Invalid email or password'));
      }
    } catch (error) {
      emit(state.copyWith(status: LoginStatus.failure, error: error.toString()));
    }
  }

  Future<void> _onCheckLoginStatus(CheckLoginStatus event, Emitter<LoginState> emit) async {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (isLoggedIn) {
      emit(state.copyWith(status: LoginStatus.success));
    }
  }
}