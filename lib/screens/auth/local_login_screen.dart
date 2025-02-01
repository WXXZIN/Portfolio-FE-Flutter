import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:client_flutter/providers/auth_provider.dart';
import 'package:client_flutter/widgets/custom_text_form_field.dart';

class LocalLoginScreen extends StatefulWidget {
  const LocalLoginScreen({super.key});

  @override
  State<LocalLoginScreen> createState() => _LocalLoginScreenState();
}

class _LocalLoginScreenState extends State<LocalLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isAutoLogin = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("아이디로 계속", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FocusTraversalGroup(
            policy: WidgetOrderTraversalPolicy(),
            child: Column(
              children: [
                CustomTextFormField(
                  hintText: '아이디', 
                  controller: _usernameController
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  hintText: '비밀번호', 
                  controller: _passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      activeColor: Colors.blue,
                      value: isAutoLogin,
                      onChanged: (value) {
                        setState(() {
                          isAutoLogin = value!;
                        });
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isAutoLogin = !isAutoLogin;
                        });
                      },
                      child: const Text('자동 로그인'),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        context.push('/auth/account/findId');
                      },
                      child: const Text('아이디 찾기'),
                    ),
                    SizedBox(
                      height: 16,
                      child: const VerticalDivider(
                        color: Colors.grey,
                        thickness: 1,
                        width: 20,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/auth/account/tempPassword');
                      },
                      child: const Text('비밀번호 찾기'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    onPressed: _handleLogin,
                    icon: const Icon(Icons.arrow_forward),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    context.push('/auth/local/register');
                  },
                  child: const Text('아직 계정이 없으신가요?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final authProvider = context.read<AuthProvider>();
    final username = _usernameController.text;
    final password = _passwordController.text;
    
    try {
      await authProvider.localLogin(
        username: username, 
        password: password, 
        isAutoLogin: isAutoLogin
      );
    
      if (!mounted) return;

      context.go('/');
    }  on DioException catch (error) {
      if (!mounted) return;
        
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message!),
        ),
      );
    }
  }
}
