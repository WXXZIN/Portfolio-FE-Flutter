import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:client_flutter/providers/auth_provider.dart';
import 'package:client_flutter/widgets/custom_submit_button.dart';
import 'package:client_flutter/widgets/custom_text_form_field.dart';

class FindIdScreen extends StatefulWidget {
  const FindIdScreen({super.key});

  @override
  State<FindIdScreen> createState() => _FindIdScreenState();
}

class _FindIdScreenState extends State<FindIdScreen> {
  bool _isButtonEnabled = false;

  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('아이디 찾기', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '가입 시 등록한 이메일 주소로\n아이디를 확인하세요',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                hintText: '이메일', 
                controller: _emailController,
                onChanged: (_) => _checkEmail(),
              ),
              Spacer(),
              CustomSubmitButton(
                text: '아이디 찾기',
                isButtonEnabled: _isButtonEnabled,
                onPressed: _handleFindUsername,
              ),
            ],
          ),
        ),
      )
    );
  }

  Future<void> _handleFindUsername() async {
    final authProvider = context.read<AuthProvider>();
    final email = _emailController.text;

    try {
      final userAuthService = authProvider.userAuthService;
      final username = await userAuthService.findUsername(email: email);

      context.push(
        '/auth/account/findIdResult',
        extra: {'username': username},
      );
    } on DioException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message!)),
      );
    }
  }

  void _checkEmail() {
    setState(() {
      _isButtonEnabled = _emailController.text.isNotEmpty;
    });
  }
}
