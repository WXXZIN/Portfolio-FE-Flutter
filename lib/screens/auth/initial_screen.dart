import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:client_flutter/providers/auth_provider.dart';
import 'package:client_flutter/providers/network_status_provider.dart';
import 'package:client_flutter/services/social/kakao_service.dart';
import 'package:client_flutter/widgets/custom_dialog.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    initializeApp();
    initializeKakaoSdk();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.shrink()
    );
  }

  Future<void> initializeApp() async {
    bool isConnected = await _checkinitializeNetworkStatus();

    if (isConnected) {
      await _checkinitializeAuthStatus();
    } else {
      FlutterNativeSplash.remove();
    }
  }

  Future<bool> _checkinitializeNetworkStatus() async {
    final networkStatusProvider = Provider.of<NetworkStatusProvider>(context, listen: false);
    bool isConnected = await networkStatusProvider.checkConnectionStatus();
    bool isApiReachable = await networkStatusProvider.checkApiReachable();

    if (isConnected) {
      if (!isApiReachable) {
        FlutterNativeSplash.remove();
        showCustomDialog(
          context,
          '서버와 연결할 수 없습니다.\n잠시 후 다시 시도해주세요.',
          () => exit(0),
          () {
            Navigator.of(context).pop();
            initializeApp();
          }
        );
      }
    } else {
      FlutterNativeSplash.remove();
      showCustomDialog(
        context,
        '네트워크 연결 상태가 좋지 않습니다.\n연결 상태 확인 후 다시 시도해주세요.',
        () => exit(0),
        () {
          Navigator.of(context).pop();
          initializeApp();
        }
      );
    }

    return isConnected && isApiReachable;
  }

  Future<void> _checkinitializeAuthStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initializeAuthProvider();

    if (authProvider.isAuthenticated) {
      context.pushReplacement('/');
    } else {
      context.pushReplacement('/');
      context.push('/auth/social/login');
    }

    FlutterNativeSplash.remove();
  }
}
