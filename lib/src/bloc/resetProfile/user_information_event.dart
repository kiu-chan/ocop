import 'package:equatable/equatable.dart';

abstract class UserInformationEvent extends Equatable {
  const UserInformationEvent();

  @override
  List<Object> get props => [];
}

class LoadUserInformation extends UserInformationEvent {}

class UpdateUserName extends UserInformationEvent {
  final String name;

  const UpdateUserName(this.name);

  @override
  List<Object> get props => [name];
}

class UpdateUserCommune extends UserInformationEvent {
  final String commune;

  const UpdateUserCommune(this.commune);

  @override
  List<Object> get props => [commune];
}

class UpdateUserPassword extends UserInformationEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;

  const UpdateUserPassword({
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmNewPassword = '',
  });

  @override
  List<Object> get props => [currentPassword, newPassword, confirmNewPassword];
}

class SubmitUserInformation extends UserInformationEvent {}