import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterInitial()) {
    on<RegisterButtonPressed>(_onRegisterButtonPressed);
  }

  Future<void> _onRegisterButtonPressed(
    RegisterButtonPressed event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());

    // Giả lập quá trình đăng ký
    await Future.delayed(const Duration(seconds: 1));

    if (event.password != event.confirmPassword) {
      emit(RegisterFailure(error: 'Passwords do not match'));
    } else if (event.email.isEmpty || event.password.isEmpty || event.name.isEmpty) {
      emit(RegisterFailure(error: 'Please fill all fields'));
    } else {
      // Ở đây bạn sẽ thêm logic đăng ký thực tế
      emit(RegisterSuccess());
    }
  }
}