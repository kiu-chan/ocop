import 'package:flutter/material.dart';
import 'package:ocop/mainData/user/authService.dart';
import 'package:ocop/mainData/database/databases.dart';

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
    setState(() {
      _userInfo = userInfo;
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
      final selectedCommuneData = _communes.firstWhere(
        (c) => c['name'] == _selectedCommune,
        orElse: () => {'id': null},
      );

      final newInfo = {
        'name': _nameController.text,
        'commune_id': selectedCommuneData['id']?.toString(),
      };

      if (_newPasswordController.text.isNotEmpty) {
        final isPasswordCorrect = await _databaseOptions.accountDatabase.verifyUserPassword(
          _userInfo!['id'],
          _currentPasswordController.text,
        );
        if (!isPasswordCorrect) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mật khẩu hiện tại không đúng')),
          );
          return;
        }
        newInfo['password'] = _newPasswordController.text;
      }

      final success = await _databaseOptions.accountDatabase.updateUserInfo(_userInfo!['id'], newInfo);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thông tin người dùng đã được cập nhật thành công')),
        );
        final updatedUserInfo = Map<String, dynamic>.from(_userInfo!);
        updatedUserInfo.addAll(newInfo);
        updatedUserInfo['commune'] = _selectedCommune;
        await AuthService.updateUserInfo(updatedUserInfo);
        setState(() {
          _userInfo = updatedUserInfo;
        });
      } else {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên của bạn';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
              ElevatedButton(
                onPressed: _updateUserInfo,
                child: const Text('Cập nhật thông tin'),
              ),
            ],
          ),
        ),
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