import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:client_flutter/services/email/email_service.dart';
import 'package:client_flutter/widgets/custom_bottom_sheet.dart';
import 'package:client_flutter/widgets/custom_text_form_field.dart';
import 'package:client_flutter/widgets/custom_submit_button.dart';

class TempPasswordScreen extends StatefulWidget {
  const TempPasswordScreen({super.key});

  @override
  State<TempPasswordScreen> createState() => _TempPasswordScreenState();
}

class _TempPasswordScreenState extends State<TempPasswordScreen> {
  bool _isButtonEnabled = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '임시 비밀번호로 로그인 후\n비밀번호를 변경하세요',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              CustomTextFormField(
                hintText: '아이디', 
                controller: _usernameController,
                onChanged: (_) => _checkEmail(),
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                hintText: '이메일', 
                controller: _emailController,
                onChanged: (_) => _checkEmail(),
              ),
              Spacer(),
              CustomSubmitButton(
                text: '임시 비밀번호 발송',
                isButtonEnabled: _isButtonEnabled,
                onPressed: _handleSendTempPassword,
              ),
              const SizedBox(height: 8),
              CustomSubmitButton(
                text: '로그인 하러 가기',
                isButtonEnabled: true,
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.settings.name == '/auth/local/login');
                },
              ),
            ],
          ),
        ),
      )
    );
  }

  Future<void> _handleSendTempPassword() async {
    final username = _usernameController.text;
    final email = _emailController.text;

    try {
      final emailService = EmailService();
      await emailService.sendTemporayPasswordEmail(
        username: username,
        email: email,
      );

      showCustomBottomSheet(
        context,
        false,
        '임시 비밀번호 발송 완료',
        '새로운 비밀번호로 로그인 후 이용해주세요.',
      );
    } on DioException {
      showCustomBottomSheet(
        context,
        true,
        '임시 비밀번호 발송 실패',
        '아이디와 이메일을 확인해주세요.',
      );
    }
  }

  void _checkEmail() {
    setState(() {
      _isButtonEnabled = _usernameController.text.isNotEmpty && _emailController.text.isNotEmpty;
    });
  }
}
