import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocop/src/page/elements/background.dart';
import 'package:ocop/src/page/elements/logo.dart';
import 'package:ocop/src/page/home/home.dart';
import 'package:ocop/src/page/account/login/loginPage.dart';
import 'register_bloc.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({Key? key}) : super(key: key);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Register"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              ),
            ),
          ],
        ),
        body: BlocListener<RegisterBloc, RegisterState>(
          listener: (context, state) {
            if (state is RegisterSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              );
            } else if (state is RegisterFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          child: BlocBuilder<RegisterBloc, RegisterState>(
            builder: (context, state) {
              return Center(
                child: Stack(
                  children: [
                    const BackGround(),
                    Center(
                      child: Container(
                        width: double.infinity,
                        height: 600,
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Logo(),
                            const SizedBox(height: 20),
                            _buildTextField(_nameController, 'Họ tên'),
                            const SizedBox(height: 20),
                            _buildTextField(_emailController, 'Địa chỉ email'),
                            const SizedBox(height: 20),
                            _buildTextField(_passwordController, 'Mật khẩu', isPassword: true),
                            const SizedBox(height: 20),
                            _buildTextField(_confirmPasswordController, 'Xác nhận mật khẩu', isPassword: true),
                            const SizedBox(height: 40),
                            _buildRegisterButton(context, state),
                            const SizedBox(height: 10),
                            _buildLoginLink(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isPassword = false}) {
    return FractionallySizedBox(
      widthFactor: 0.9,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
        obscureText: isPassword,
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context, RegisterState state) {
    return ElevatedButton(
      onPressed: state is RegisterLoading
          ? null
          : () {
              BlocProvider.of<RegisterBloc>(context).add(
                RegisterButtonPressed(
                  name: _nameController.text,
                  email: _emailController.text,
                  password: _passwordController.text,
                  confirmPassword: _confirmPasswordController.text,
                ),
              );
            },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
      ),
      child: state is RegisterLoading
          ? const CircularProgressIndicator()
          : const Text('Register'),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      },
      child: const Text(
        'Đăng nhập',
        style: TextStyle(
          fontSize: 16,
          decoration: TextDecoration.underline,
          color: Colors.blue,
        ),
      ),
    );
  }
}