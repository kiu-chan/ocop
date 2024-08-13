import 'package:flutter/material.dart';
import 'package:ocop/mainData/user/authService.dart';
import 'package:ocop/mainData/database/databases.dart';
import 'package:ocop/src/page/home/home.dart';

class UserInformation extends StatefulWidget {
  const UserInformation({Key? key}) : super(key: key);

  @override
  _UserInformationState createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmNewPasswordController;
  String? _selectedCommune;
  Map<String, dynamic>? _userInfo;
  List<Map<String, dynamic>> _communes = [];
  bool _isLoading = false;
  String? _userRole;

  final DefaultDatabaseOptions _databaseOptions = DefaultDatabaseOptions();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmNewPasswordController = TextEditingController();
    _loadUserInfo();
    _loadCommunes();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await AuthService.getUserInfo();
    final userRole = await AuthService.getUserRole();
    setState(() {
      _userInfo = userInfo;
      _userRole = userRole;
      _nameController.text = userInfo?['name'] ?? '';
      _selectedCommune = userInfo?['commune'];
    });
  }

  Future<void> _loadCommunes() async {
    await _databaseOptions.connect();
    final communes = await _databaseOptions.getApprovedCommunes();
    setState(() {
      _communes = communes;
    });
  }

  Future<void> _updateUserInfo() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final newInfo = {
        'name': _nameController.text,
      };

      if (_userRole != 'admin' && _userRole != 'district' && _userRole != 'province') {
        final selectedCommuneData = _communes.firstWhere(
          (c) => c['name'] == _selectedCommune,
          orElse: () => {'id': null},
        );
        if (selectedCommuneData['id'] != null) {
          newInfo['commune_id'] = selectedCommuneData['id'].toString();
        }
      }

      if (_newPasswordController.text.isNotEmpty) {
        final isPasswordCorrect = await _databaseOptions.accountDatabase.verifyUserPassword(
          _userInfo!['id'],
          _currentPasswordController.text,
        );
        if (!isPasswordCorrect) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mật khẩu hiện tại không đúng')),
          );
          return;
        }
        newInfo['password'] = _newPasswordController.text;
      }

      final success = await _databaseOptions.accountDatabase.updateUserInfo(_userInfo!['id'], newInfo, _userRole ?? 'unknown');
      if (success) {
        final updatedUserInfo = Map<String, dynamic>.from(_userInfo!);
        updatedUserInfo.addAll(newInfo);
        updatedUserInfo['commune'] = _selectedCommune;
        await AuthService.updateUserInfo(updatedUserInfo);
        
        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          _userInfo = updatedUserInfo;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thông tin người dùng đã được cập nhật thành công')),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể cập nhật thông tin người dùng')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin người dùng"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Tên người dùng'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên của bạn';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_userRole != 'admin' && _userRole != 'district' && _userRole != 'province')
                    DropdownButtonFormField<String>(
                      value: _selectedCommune,
                      decoration: const InputDecoration(labelText: 'Xã'),
                      items: _communes.map((commune) {
                        return DropdownMenuItem<String>(
                          value: commune['name'] as String,
                          child: Text(commune['name'] as String),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCommune = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng chọn xã';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _currentPasswordController,
                    decoration: const InputDecoration(labelText: 'Mật khẩu hiện tại'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmNewPasswordController,
                    decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu mới'),
                    obscureText: true,
                    validator: (value) {
                      if (_newPasswordController.text.isNotEmpty && value != _newPasswordController.text) {
                        return 'Mật khẩu không khớp';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateUserInfo,
                      child: const Text('Cập nhật thông tin'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _databaseOptions.close();
    super.dispose();
  }
}