enum LoginStatus { initial, loading, success, failure }

class LoginState {
  final String email;
  final String password;
  final bool rememberMe;
  final LoginStatus status;
  final String? error;

  LoginState({
    this.email = '',
    this.password = '',
    this.rememberMe = false,
    this.status = LoginStatus.initial,
    this.error,
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? rememberMe,
    LoginStatus? status,
    String? error,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}