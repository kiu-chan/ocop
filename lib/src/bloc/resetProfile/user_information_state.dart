import 'package:equatable/equatable.dart';

class UserInformationState extends Equatable {
  final String name;
  final String commune;
  final List<String> communes;
  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const UserInformationState({
    required this.name,
    required this.commune,
    required this.communes,
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmNewPassword = '',
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  UserInformationState copyWith({
    String? name,
    String? commune,
    List<String>? communes,
    String? currentPassword,
    String? newPassword,
    String? confirmNewPassword,
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return UserInformationState(
      name: name ?? this.name,
      commune: commune ?? this.commune,
      communes: communes ?? this.communes,
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmNewPassword: confirmNewPassword ?? this.confirmNewPassword,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        name,
        commune,
        communes,
        currentPassword,
        newPassword,
        confirmNewPassword,
        isLoading,
        isSuccess,
        error
      ];
}
