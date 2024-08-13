import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocop/src/page/elements/background.dart';
import 'package:ocop/src/page/elements/logo.dart';
import 'package:ocop/src/page/account/register/registerPage.dart';
import 'package:ocop/src/page/home/home.dart';
import 'package:ocop/src/bloc/login/login_bloc.dart';
import 'package:ocop/src/bloc/login/login_event.dart';
import 'package:ocop/src/bloc/login/login_state.dart';
import 'package:ocop/src/page/account/forgotPassword/forgotPasswordPage.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = LoginBloc();
        bloc.add(CheckLoginStatus());
        return bloc;
      },
      child: const LoginPageContent(),
    );
  }
}

class LoginPageContent extends StatelessWidget {
  const LoginPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Home()),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Login"),
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
          body: Center(
            child: Stack(
              children: [
                const BackGround(),
                Center(
                  child: Container(
                    height: 450,
                    color: Colors.white,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Logo(),
                          const SizedBox(height: 20),
                          _buildEmailField(context),
                          const SizedBox(height: 20),
                          _buildPasswordField(context),
                          const SizedBox(height: 20),
                          _buildRememberMeAndForgotPassword(context),
                          const SizedBox(height: 20),
                          _buildLoginButton(context, state),
                          const SizedBox(height: 10),
                          _buildRegisterLink(context),
                          const SizedBox(height: 20),
                          _buildErrorMessages(context, state),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.9,
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: 'Email',
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
        onChanged: (value) =>
            context.read<LoginBloc>().add(EmailChanged(value)),
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.9,
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: 'Password',
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
        obscureText: true,
        onChanged: (value) =>
            context.read<LoginBloc>().add(PasswordChanged(value)),
      ),
    );
  }

  Widget _buildRememberMeAndForgotPassword(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: CheckboxListTile(
            title: const Text('Ghi nhớ đăng nhập'),
            value: context.watch<LoginBloc>().state.rememberMe,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: Colors.blue,
            onChanged: (value) => context
                .read<LoginBloc>()
                .add(RememberMeChanged(value ?? false)),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ForgotPasswordPage()),
            );
          },
          child: const SizedBox(
            width: 150,
            child: Text(
              'Quên mật khẩu?',
              style: TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.blue,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context, LoginState state) {
    return ElevatedButton(
      onPressed: state.status == LoginStatus.loading
          ? null
          : () {
              context.read<LoginBloc>().add(ClearErrors());
              context.read<LoginBloc>().add(LoginSubmitted(
                email: context.read<LoginBloc>().state.email,
                password: context.read<LoginBloc>().state.password,
              ));
            },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
      ),
      child: state.status == LoginStatus.loading
          ? const CircularProgressIndicator()
          : const Text('Login'),
    );
  }

  Widget _buildRegisterLink(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegisterPage()),
        );
      },
      child: const Text(
        'Đăng ký',
        style: TextStyle(
          fontSize: 16,
          decoration: TextDecoration.underline,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildErrorMessages(BuildContext context, LoginState state) {
    return Column(
      children: state.errors.map((error) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          error,
          style: const TextStyle(color: Colors.red),
        ),
      )).toList(),
    );
  }
}