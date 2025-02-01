import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkStatusProvider with ChangeNotifier {
  bool _isConnected = true;
  bool _isApiReachable = true;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool get isConnected => _isConnected;
  bool get isApiReachable => _isApiReachable;

  NetworkStatusProvider() {
    _subscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
      _updateConnectionStatus(result);
    });

    checkConnectionStatus();
    checkApiReachable();
  }

  Future<bool> checkConnectionStatus() async {
    List<ConnectivityResult> result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
    
    return _isConnected;
  }

  Future<bool> checkApiReachable() async {
    try {
      await Dio().get('https://api.wxxzin.org/api/v1');
      
      _isApiReachable = true;
    } catch (e) {
      _isApiReachable = false;
    }

    return _isApiReachable;
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    _isConnected = result.isNotEmpty && result.any((r) => r != ConnectivityResult.none);
    notifyListeners();
  }

  void updateApiReachable(bool isReachable) {
    _isApiReachable = isReachable;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
