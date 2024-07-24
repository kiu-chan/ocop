abstract class LoginEvent {}

class EmailChanged extends LoginEvent {
  final String email;
  EmailChanged(this.email);
}

class PasswordChanged extends LoginEvent {
  final String password;
  PasswordChanged(this.password);
}

class RememberMeChanged extends LoginEvent {
  final bool rememberMe;
  RememberMeChanged(this.rememberMe);
}

class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;
  LoginSubmitted({required this.email, required this.password});
}

class CheckLoginStatus extends LoginEvent {}

class LogoutRequested extends LoginEvent {}