enum RegisterStatus { initial, loading, success, failure }

class RegisterState {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final int? communeId;
  final RegisterStatus status;
  final List<String> errors;

  RegisterState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.communeId,
    this.status = RegisterStatus.initial,
    this.errors = const [],
  });

  RegisterState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    int? communeId,
    RegisterStatus? status,
    List<String>? errors,
  }) {
    return RegisterState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      communeId: communeId ?? this.communeId,
      status: status ?? this.status,
      errors: errors ?? this.errors,
    );
  }
}