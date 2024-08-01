import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocop/mainData/user/authService.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'user_information_event.dart';
import 'user_information_state.dart';

class UserInformationBloc extends Bloc<UserInformationEvent, UserInformationState> {
  final DefaultDatabaseOptions _databaseOptions;

  UserInformationBloc(this._databaseOptions)
      : super(const UserInformationState(name: '', commune: '', communes: [])) {
    on<LoadUserInformation>(_onLoadUserInformation);
    on<UpdateUserName>(_onUpdateUserName);
    on<UpdateUserCommune>(_onUpdateUserCommune);
    on<UpdateUserPassword>(_onUpdateUserPassword);
    on<SubmitUserInformation>(_onSubmitUserInformation);
  }

  Future<void> _onLoadUserInformation(
    LoadUserInformation event,
    Emitter<UserInformationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final userInfo = await AuthService.getUserInfo();
      final communes = await _databaseOptions.getApprovedCommunes();
      
      // Lấy tên xã từ commune_id
      final userCommune = communes.firstWhere(
        (commune) => commune['id'].toString() == userInfo?['commune_id'].toString(),
        orElse: () => {'name': ''},
      );

      emit(state.copyWith(
        name: userInfo?['name'] ?? '',
        commune: userCommune['name'] as String,
        communes: communes.map((c) => c['name'] as String).toList(),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onUpdateUserName(
    UpdateUserName event,
    Emitter<UserInformationState> emit,
  ) {
    emit(state.copyWith(name: event.name));
  }

  void _onUpdateUserCommune(
    UpdateUserCommune event,
    Emitter<UserInformationState> emit,
  ) {
    emit(state.copyWith(commune: event.commune));
  }

  void _onUpdateUserPassword(
    UpdateUserPassword event,
    Emitter<UserInformationState> emit,
  ) {
    emit(state.copyWith(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
      confirmNewPassword: event.confirmNewPassword,
    ));
  }

  Future<void> _onSubmitUserInformation(
    SubmitUserInformation event,
    Emitter<UserInformationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final userInfo = await AuthService.getUserInfo();
      final newInfo = {
        'name': state.name,
        'commune_id': state.communes.indexOf(state.commune) + 1, // Assuming commune IDs start from 1
      };

      if (state.currentPassword.isNotEmpty && state.newPassword.isNotEmpty) {
        if (state.newPassword != state.confirmNewPassword) {
          emit(state.copyWith(isLoading: false, error: 'Mật khẩu mới không khớp'));
          return;
        }

        final isPasswordCorrect = await _databaseOptions.accountDatabase.verifyUserPassword(
          userInfo!['id'],
          state.currentPassword,
        );
        if (!isPasswordCorrect) {
          emit(state.copyWith(isLoading: false, error: 'Mật khẩu hiện tại không đúng'));
          return;
        }
        newInfo['password'] = state.newPassword;
      }

      final success = await _databaseOptions.accountDatabase.updateUserInfo(userInfo!['id'], newInfo);
      if (success) {
        await AuthService.updateUserInfo({...userInfo, ...newInfo, 'commune': state.commune});
        emit(state.copyWith(isLoading: false, isSuccess: true));
      } else {
        emit(state.copyWith(isLoading: false, error: 'Không thể cập nhật thông tin người dùng'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}