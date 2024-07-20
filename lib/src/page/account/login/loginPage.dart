import 'package:flutter/material.dart';
import 'package:ocop/src/page/elements/background.dart';
import 'package:ocop/src/page/elements/logo.dart';
import 'package:ocop/src/page/account/register/registerPage.dart';
import 'package:ocop/src/page/home/home.dart';
import 'package:ocop/src/bloc/loginBloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginBloc bloc = LoginBloc();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {  
    void login() {
    final email = _emailController.text;
    final password = _passwordController.text;

    // Kiểm tra thông tin đăng nhập
    if (email == 'user@example.com' && password == 'password') {
      // Điều hướng tới trang khác nếu đăng nhập thành công
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } else {
      // Hiển thị thông báo lỗi nếu đăng nhập thất bại
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Failed'),
          content: const Text('Incorrect email or password.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Quay lại trang trước đó
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              );
            }
          ),
          ]
      ),
      body: Center(
          child: Stack(
            children: [
              const BackGround(),
              Center(
                child: Container(
                height: 400,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Logo(),
                    const SizedBox(height: 20),
                    FractionallySizedBox(
                      widthFactor: 0.9,
                      child: Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',

                              border: OutlineInputBorder(),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              // border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              // border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Ghi nhớ đăng nhập'),
                            value: true,
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: Colors.blue,
                            onChanged: (bool? value) {
                              // _changeMapSource(0);
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 150,
                          child: Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                            ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, 
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
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
                          decoration: TextDecoration.underline, // Hiển thị chữ dưới gạch chân
                          color: Colors.blue, // Màu chữ xanh
                        ),
                      ),
                    ),
                  ],
                  ),
                ),
              ),
            ]
          ),
      ),
    );

    
  }
}