import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_event.dart';
import 'register_state.dart';
import 'package:ocop/databases.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final DefaultDatabaseOptions _databaseOptions = DefaultDatabaseOptions();

  RegisterBloc() : super(RegisterInitial()) {
    on<RegisterButtonPressed>(_onRegisterButtonPressed);
  }

  Future<void> _onRegisterButtonPressed(
    RegisterButtonPressed event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());

    try {
      await _databaseOptions.connect();

      bool userExists = await _databaseOptions.checkUserExists(event.email);

      if (userExists) {
        emit(RegisterFailure(error: 'User with this email already exists'));
      } else if (event.password != event.confirmPassword) {
        emit(RegisterFailure(error: 'Passwords do not match'));
      } else if (event.email.isEmpty || event.password.isEmpty || event.name.isEmpty) {
        emit(RegisterFailure(error: 'Please fill all fields'));
      } else {
        // Mật khẩu sẽ được mã hóa trong phương thức createUser
        bool created = await _databaseOptions.createUser(event.name, event.email, event.password);
        if (created) {
          emit(RegisterSuccess());
        } else {
          emit(RegisterFailure(error: 'Failed to create user'));
        }
      }
    } catch (e) {
      emit(RegisterFailure(error: 'An error occurred: $e'));
    } finally {
      await _databaseOptions.close();
    }
  }
}