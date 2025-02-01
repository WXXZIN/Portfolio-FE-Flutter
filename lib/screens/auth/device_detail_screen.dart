import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:client_flutter/models/device.dart';
import 'package:client_flutter/providers/auth_provider.dart';
import 'package:client_flutter/widgets/custom_dialog.dart';
import 'package:client_flutter/widgets/device_icon.dart';

class DeviceDetailScreen extends StatelessWidget {
  final Device deviceDetail;
  final bool isCurrentSession;

  const DeviceDetailScreen({
    super.key,
    required this.deviceDetail,
    this.isCurrentSession = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DeviceIcon(osType: deviceDetail.os, iconWidth: 72, iconHeight: 72),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deviceDetail.deviceName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (isCurrentSession)
                            Row(
                              children: const [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.blue,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '이 기기',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 8),
                          if (!isCurrentSession) ...[
                            Text(
                              '마지막 로그인: ${formatDateTime(deviceDetail.lastLoginAt)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            '최초 로그인: ${formatDateTime(deviceDetail.firstLoginAt)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCurrentSession)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout, size: 18),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => logoutTargetDevice(context),
                    label: const Text('로그아웃', style: TextStyle(fontSize: 16)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void logoutTargetDevice(BuildContext context) async {
    final shouldLogout = await showCustomDialog(
      context,
      '해당 기기에서 로그아웃하시겠습니까?',
      () => Navigator.of(context).pop(false),
      () => Navigator.of(context).pop(true),
    );

    if (shouldLogout == true) {
      final authProvider = context.read<AuthProvider>();

      try {
        await authProvider.logoutTargetDevice(targetDeviceId: deviceDetail.deviceId);
        Navigator.of(context).pop();
      } on DioException catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message!)),
        );
      }
    }
  }

  String formatDateTime(String dateTime) {
    final date = DateTime.parse(dateTime);
    return DateFormat('MM월 dd일').format(date);
  }
}
