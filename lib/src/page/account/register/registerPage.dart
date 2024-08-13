import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocop/src/page/elements/background.dart';
import 'package:ocop/src/page/elements/logo.dart';
import 'package:ocop/src/page/home/home.dart';
import 'package:ocop/src/page/account/login/loginPage.dart';
import '../../../bloc/register/register_bloc.dart';
import '../../../bloc/register/register_event.dart';
import '../../../bloc/register/register_state.dart';
import 'package:ocop/mainData/database/databases.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  List<Map<String, dynamic>> _communes = [];
  int? _selectedCommuneId;

  @override
  void initState() {
    super.initState();
    _loadCommunes();
  }

  Future<void> _loadCommunes() async {
    final databaseOptions = DefaultDatabaseOptions();
    await databaseOptions.connect();
    final communes = await databaseOptions.getApprovedCommunes();
    await databaseOptions.close();

    setState(() {
      _communes = communes;
    });
  }

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
        body: BlocConsumer<RegisterBloc, RegisterState>(
          listener: (context, state) {
            if (state.status == RegisterStatus.success) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              );
            } else if (state.status == RegisterStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errors.join(', '))),
              );
            }
          },
          builder: (context, state) {
            return Center(
              child: Stack(
                children: [
                  const BackGround(),
                  Center(
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Logo(),
                            const SizedBox(height: 20),
                            _buildTextField(
                                _nameController,
                                'Họ tên',
                                (value) => context
                                    .read<RegisterBloc>()
                                    .add(NameChanged(value))),
                            const SizedBox(height: 20),
                            _buildTextField(
                                _emailController,
                                'Địa chỉ email',
                                (value) => context
                                    .read<RegisterBloc>()
                                    .add(EmailChanged(value))),
                            const SizedBox(height: 20),
                            _buildTextField(
                                _passwordController,
                                'Mật khẩu',
                                (value) => context
                                    .read<RegisterBloc>()
                                    .add(PasswordChanged(value)),
                                isPassword: true),
                            const SizedBox(height: 20),
                            _buildTextField(
                                _confirmPasswordController,
                                'Xác nhận mật khẩu',
                                (value) => context
                                    .read<RegisterBloc>()
                                    .add(ConfirmPasswordChanged(value)),
                                isPassword: true),
                            const SizedBox(height: 20),
                            _buildCommuneDropdown(context),
                            const SizedBox(height: 40),
                            _buildRegisterButton(context, state),
                            const SizedBox(height: 10),
                            _buildLoginLink(context),
                            const SizedBox(height: 20),
                            _buildErrorMessages(context, state),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      Function(String) onChanged,
      {bool isPassword = false}) {
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
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCommuneDropdown(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.9,
      child: DropdownButtonFormField<int>(
        value: _selectedCommuneId,
        items: _communes.map((commune) {
          return DropdownMenuItem<int>(
            value: commune['id'],
            child: Text(commune['name']),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCommuneId = value;
          });
          if (value != null) {
            context.read<RegisterBloc>().add(CommuneChanged(value));
          }
        },
        decoration: const InputDecoration(
          labelText: 'Chọn xã',
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context, RegisterState state) {
    return ElevatedButton(
      onPressed: state.status == RegisterStatus.loading
          ? null
          : () {
              context.read<RegisterBloc>().add(ClearErrors());
              context.read<RegisterBloc>().add(RegisterSubmitted());
            },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
      ),
      child: state.status == RegisterStatus.loading
          ? const CircularProgressIndicator()
          : const Text('Register'),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
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

  Widget _buildErrorMessages(BuildContext context, RegisterState state) {
    return Column(
      children: state.errors
          .map((error) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                ),
              ))
          .toList(),
    );
  }
}
