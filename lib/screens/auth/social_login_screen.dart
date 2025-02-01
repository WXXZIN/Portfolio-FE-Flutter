import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:client_flutter/providers/auth_provider.dart';
import 'package:client_flutter/widgets/login_button.dart';

class SocialLoginScreen extends StatelessWidget {
  const SocialLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {Navigator.of(context).pop();},
            icon: const Icon(Icons.close),
          )
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoginButton(
                  logoPath: 'images/google_logo.png', 
                  buttonText: 'Google로 계속하기', 
                  backgroundColor: Colors.white, 
                  textColor: Colors.black, 
                  onPressed: () async {
                    await _performLogin(context, authProvider, 'google');
                  },
                ),
                const SizedBox(height: 16),
                LoginButton(
                  logoPath: 'images/kakao_logo.png', 
                  buttonText: '카카오로 계속하기', 
                  backgroundColor: Color(0xFFFEE500), 
                  textColor: Colors.black, 
                  onPressed: () async {
                    await _performLogin(context, authProvider, 'kakao');
                  },
                ),
                const SizedBox(height: 16),
                LoginButton(
                  logoPath: 'images/naver_logo.png', 
                  buttonText: '네이버로 계속하기', 
                  backgroundColor: Color(0xFF03C75A), 
                  textColor: Colors.white, 
                  onPressed: () async {
                    await _performLogin(context, authProvider, 'naver');
                  },
                ),
                const SizedBox(height: 32),
                LoginButton(
                  logoPath: '',
                  buttonText: '아이디로 계속하기', 
                  backgroundColor: Colors.white, 
                  textColor: Colors.black, 
                  onPressed: () {
                    context.push('/auth/local/login');
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _performLogin(
    BuildContext context, 
    AuthProvider authProvider,
    String provider,
  ) async {
    try {
      await authProvider.socialLogin(provider: provider);
      
      if (authProvider.isAuthenticated) {
        Navigator.of(context).pop();
      }
    } on DioException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message!)),
      );
    }
  }
}
