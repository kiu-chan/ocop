import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocop/src/page/account/login/loginPage.dart';
import 'package:ocop/src/page/settings/elements/introduce.dart';
import 'package:ocop/src/page/settings/profile/userInformation.dart';
import 'package:ocop/src/bloc/login/login_bloc.dart';
import 'package:ocop/src/bloc/login/login_event.dart';
import 'package:ocop/src/bloc/login/login_state.dart';
import 'package:ocop/src/page/home/home.dart';
import 'package:ocop/mainData/user/authService.dart';

class Options extends StatefulWidget {
  const Options({super.key});

  @override
  _OptionsState createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  bool _isLoading = false;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
  }

  Future<void> _checkAdminRole() async {
    final userRole = await AuthService.getUserRole();
    setState(() {
      isAdmin = userRole == 'admin';
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc()..add(CheckLoginStatus()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            final bool isLoggedIn = state.status == LoginStatus.success;
            return Container(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: <Widget>[
                  if (isLoggedIn && !isAdmin) _buildProfileOption(context),
                  _buildIntroduceOption(context),
                  _buildLoginLogoutButton(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      height: 60.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserInformation()),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 35.0,
                  height: 35.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: const Color.fromRGBO(77, 210, 255, 0.3),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 20.0,
                    color: Color.fromRGBO(77, 210, 255, 1),
                  ),
                ),
                const SizedBox(width: 20.0),
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                )
              ],
            ),
            Container(
              width: 25.0,
              height: 25.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: const Icon(Icons.arrow_forward_ios,
                  size: 12.0, color: Color.fromRGBO(77, 210, 255, 1)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIntroduceOption(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      height: 60.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Introduce()),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 35.0,
                  height: 35.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: const Color.fromRGBO(0, 230, 142, 0.3),
                  ),
                  child: const Icon(
                    Icons.add_circle_outline,
                    size: 20.0,
                    color: Color.fromRGBO(0, 230, 142, 1),
                  ),
                ),
                const SizedBox(width: 20.0),
                const Text(
                  'Introduce',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                )
              ],
            ),
            Container(
              width: 25.0,
              height: 25.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 12.0,
                color: Color.fromRGBO(0, 230, 142, 1),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLogoutButton(BuildContext context, LoginState state) {
    final bool isLoggedIn = state.status == LoginStatus.success;
    return Container(
      margin: const EdgeInsets.all(10.0),
      height: 60.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: InkWell(
        onTap: _isLoading
            ? null
            : () async {
                if (isLoggedIn) {
                  setState(() {
                    _isLoading = true;
                  });
                  context.read<LoginBloc>().add(LogoutRequested());
                  await Future.delayed(const Duration(seconds: 1));
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const Home()),
                      (Route<dynamic> route) => false,
                    );
                  }
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 35.0,
                        height: 35.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          color: const Color.fromARGB(75, 120, 22, 233),
                        ),
                        child: Icon(
                          isLoggedIn ? Icons.logout : Icons.login,
                          size: 20.0,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      Text(
                        isLoggedIn ? 'Log Out' : 'Log In',
                        style: const TextStyle(
                          fontSize: 20.0,
                        ),
                      )
                    ],
                  ),
                  Container(
                    width: 25.0,
                    height: 25.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: const Icon(Icons.arrow_forward_ios,
                        size: 12.0, color: Colors.blue),
                  )
                ],
              ),
      ),
    );
  }
}
