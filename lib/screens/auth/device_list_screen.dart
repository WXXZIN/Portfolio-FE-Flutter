import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:client_flutter/models/device.dart';
import 'package:client_flutter/services/device/device_service.dart';
import 'package:client_flutter/widgets/device_icon.dart';

class DeviceListScreen extends StatefulWidget {
  final Map<String, List<Device>> deviceList;

  const DeviceListScreen({
    super.key, 
    required this.deviceList
  });

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  late DeviceService _deviceService;
  final storage = FlutterSecureStorage();
  String currentDeviceId = '';

  @override
  void initState() {
    super.initState();
    _getCurrentDeviceId();

    _deviceService = DeviceService();
  }

  @override
  Widget build(BuildContext context) {
    final deviceMap = widget.deviceList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 기기', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            try {
              final deviceList = await _deviceService.getDeviceList();
              setState(() {
                widget.deviceList.clear();
                widget.deviceList.addAll(deviceList);
              });
            } on DioException catch (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error.message!)),
              );
            }
          },
          child: deviceMap.isNotEmpty
            ? ListView(
                padding: const EdgeInsets.all(16.0),
                children: deviceMap.entries.map((entry) {
                  final currentSessionDevices = entry.value.where((device) => device.deviceId == currentDeviceId).toList();
                  final otherDevices = entry.value.where((device) => device.deviceId != currentDeviceId).toList();

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DeviceIcon(osType: entry.key, iconWidth: 72, iconHeight: 72),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  '${entry.key} 여러 대의 세션 ${entry.value.length}개',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Column(
                                  children: [
                                    ...currentSessionDevices.map((device) => buildDeviceRow(context, device, isCurrentSession: true)),
                                    ...otherDevices.map((device) => buildDeviceRow(context, device, isCurrentSession: false)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              )
            : const Center(child: Text('디바이스 목록이 없습니다.')),
        )
      ),
    );
  }

  Future<void> _getCurrentDeviceId() async {
    final deviceId = await storage.read(key: 'deviceId');

    if (deviceId != null) {
      setState(() {
        currentDeviceId = deviceId;
      });
    }
  }

  String formatDateTime(String dateTime) {
    final date = DateTime.parse(dateTime);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return DateFormat('MM월 dd일').format(date);
    }
  }

  Widget buildDeviceRow(BuildContext context, Device device, {required bool isCurrentSession}) {
    return InkWell(
      onTap: () async {
        try {
          final deviceDetail = await _deviceService.getDeviceDetail(device.deviceId);

          context.push(
            '/auth/account/deviceDetail',
            extra: {
              'deviceDetail': deviceDetail,
              'isCurrentSession': isCurrentSession.toString(),
            },
          );     
        } on DioException catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message!)),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.deviceName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  if (isCurrentSession)
                    Row(
                      children: const [
                        Icon(
                          Icons.check_circle,
                          color: Colors.blue,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text('현재 세션'),
                      ],
                    )
                  else
                    Text(
                      '최근 활동: ${formatDateTime(device.lastLoginAt)}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
