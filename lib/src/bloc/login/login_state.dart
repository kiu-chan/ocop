enum LoginStatus { initial, loading, success, failure }

class LoginState {
  final String email;
  final String password;
  final bool rememberMe;
  final LoginStatus status;
  final List<String> errors;
  final Map<String, dynamic>? userInfo;
  final String? role;

  LoginState({
    this.email = '',
    this.password = '',
    this.rememberMe = false,
    this.status = LoginStatus.initial,
    this.errors = const [],
    this.userInfo,
    this.role,
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? rememberMe,
    LoginStatus? status,
    List<String>? errors,
    Map<String, dynamic>? userInfo,
    String? role,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      status: status ?? this.status,
      errors: errors ?? this.errors,
      userInfo: userInfo ?? this.userInfo,
      role: role ?? this.role,
    );
  }
}