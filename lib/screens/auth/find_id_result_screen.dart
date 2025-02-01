import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:client_flutter/widgets/custom_submit_button.dart';

class FindIdResultScreen extends StatelessWidget {
  final String username;

  const FindIdResultScreen({
    super.key, 
    required this.username
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('아이디 찾기', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check, color: Colors.green, size: 80),
                const SizedBox(height: 24),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    children: [
                      TextSpan(
                        text: '회원님의 아이디는\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: username,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' 입니다.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                CustomSubmitButton(
                  text: '로그인 하러 가기',
                  isButtonEnabled: true,
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.settings.name == '/auth/local/login');
                  },
                ),
                const SizedBox(height: 16),
                CustomSubmitButton(
                  text: '비밀번호 찾기',
                  isButtonEnabled: true,
                  onPressed: () {
                    GoRouter.of(context).go('/auth/find-password');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
