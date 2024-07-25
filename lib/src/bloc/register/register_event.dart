abstract class RegisterEvent {}

class RegisterButtonPressed extends RegisterEvent {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final int communeId;

  RegisterButtonPressed({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.communeId,
  });
}