import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import 'package:client_flutter/providers/auth_provider.dart';
import 'package:client_flutter/widgets/custom_dialog.dart';
import 'package:client_flutter/widgets/custom_submit_button.dart';
import 'package:client_flutter/widgets/custom_text_form_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_checkPasswordsMatch);
    _confirmPasswordController.addListener(_checkPasswordsMatch);
    _currentPasswordController.addListener(_checkPasswordsMatch);
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_checkPasswordsMatch);
    _confirmPasswordController.removeListener(_checkPasswordsMatch);
    _currentPasswordController.removeListener(_checkPasswordsMatch);
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordsMatch() {
    setState(() {
      _isButtonEnabled = _newPasswordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _newPasswordController.text == _confirmPasswordController.text &&
          _currentPasswordController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비밀번호 변경', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextFormField(
                hintText: '새 비밀번호', 
                controller: _newPasswordController,
                obscureText: true,
                textInputAction: TextInputAction.next,
                onChanged: (value) => _checkPasswordsMatch(),
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                hintText: '새 비밀번호 확인', 
                controller: _confirmPasswordController,
                obscureText: true,
                textInputAction: TextInputAction.next,
                onChanged: (value) => _checkPasswordsMatch(),
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                hintText: '현재 비밀번호', 
                controller: _currentPasswordController,
                obscureText: true,
                onChanged: (value) => _checkPasswordsMatch(),
              ),
              Spacer(),
              CustomSubmitButton(
                text: '비밀번호 변경',
                isButtonEnabled: _isButtonEnabled,
                onPressed: _handleChangePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleChangePassword() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
 
    final authProvider = context.read<AuthProvider>();
    final userAuthService = authProvider.userAuthService;

    final shouldChangePassword = await showCustomDialog(
      context,
      '비밀번호를 변경하시면 현재 로그인된 기기에서 로그아웃됩니다. 계속하시겠습니까?',
      () => Navigator.of(context).pop(false),
      () => Navigator.of(context).pop(true),
    );

    if (shouldChangePassword == true) {
      try {
        await userAuthService.changePassword(currentPassword: currentPassword, newPassword: newPassword);
        
        authProvider.logoutCurrentDevice();
      } on DioException catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message!)),
        );
      }
    }
  }   
}