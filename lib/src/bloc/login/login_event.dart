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

class LoginSubmitted extends LoginEvent {}

class CheckLoginStatus extends LoginEvent {}