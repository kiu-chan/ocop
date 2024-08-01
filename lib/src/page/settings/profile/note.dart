import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocop/mainData/database/databases.dart';
import '../../../bloc/resetProfile/user_information_bloc.dart';
import '../../../bloc/resetProfile/user_information_event.dart';
import '../../../bloc/resetProfile/user_information_state.dart';

class UserInformation extends StatelessWidget {
  const UserInformation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserInformationBloc(
        DefaultDatabaseOptions(),
      )..add(LoadUserInformation()),
      child: const UserInformationView(),
    );
  }
}

class UserInformationView extends StatelessWidget {
  const UserInformationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin người dùng"),
      ),
      body: BlocConsumer<UserInformationBloc, UserInformationState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cập nhật thông tin thành công')),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: state.name,
                  decoration: const InputDecoration(labelText: 'Tên'),
                  onChanged: (value) {
                    context.read<UserInformationBloc>().add(UpdateUserName(value));
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: state.commune,
                  decoration: const InputDecoration(labelText: 'Xã'),
                  items: state.communes.map((commune) {
                    return DropdownMenuItem<String>(
                      value: commune,
                      child: Text(commune),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      context.read<UserInformationBloc>().add(UpdateUserCommune(newValue));
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Mật khẩu hiện tại'),
                  obscureText: true,
                  onChanged: (value) {
                    context.read<UserInformationBloc>().add(UpdateUserPassword(currentPassword: value));
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                  obscureText: true,
                  onChanged: (value) {
                    context.read<UserInformationBloc>().add(UpdateUserPassword(newPassword: value));
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu mới'),
                  obscureText: true,
                  onChanged: (value) {
                    context.read<UserInformationBloc>().add(UpdateUserPassword(confirmNewPassword: value));
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.read<UserInformationBloc>().add(SubmitUserInformation());
                  },
                  child: const Text('Cập nhật thông tin'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}