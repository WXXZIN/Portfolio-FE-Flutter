import 'dart:io';

import 'package:client_flutter/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:client_flutter/custom_router.dart';
import 'package:client_flutter/providers/network_status_provider.dart';

class NetworkStatusOverlay extends StatefulWidget {
  const NetworkStatusOverlay({super.key});

  @override
  State<NetworkStatusOverlay> createState() => _NetworkStatusOverlayState();
}

class _NetworkStatusOverlayState extends State<NetworkStatusOverlay> {
  OverlayEntry? _overlayEntry;
  String? _lastPath;
  bool _dialogOpened = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOverlay();
    });
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void showDialog() {
    if (!_dialogOpened) {
      _dialogOpened = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCustomDialog(
          context,
          '서버와 연결할 수 없습니다.\n잠시 후 다시 시도해주세요.',
          () => exit(0),
          () {
            Navigator.of(context).pop();
            _dialogOpened = false;
            Provider.of<NetworkStatusProvider>(context, listen: false).checkApiReachable();
          }
        );
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Consumer<NetworkStatusProvider>(
          builder: (context, networkStatusProvider, child) {
            final router = CustomRouter.router;

            final matchList = router.routerDelegate.currentConfiguration;
            String path = matchList.isNotEmpty ? matchList.uri.toString() : '';

            if (_lastPath != path) {
              _lastPath = path;
            }

            bool showOverlay = !networkStatusProvider.isConnected
              && path != '/auth/social/login'
              && path != '/auth/local/login';
            
            if (showOverlay) {
              return Container(
                color: Colors.grey,
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 10),
                child: const Text(
                  '네트워크 연결을 확인해주세요',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            bool showDialog = !networkStatusProvider.isApiReachable
              && path != '/initial';

            if (showDialog && !_dialogOpened) {
              _dialogOpened = true;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                showCustomDialog(
                  context,
                  '서버와 연결할 수 없습니다.\n잠시 후 다시 시도해주세요.',
                  () => exit(0),
                  () {
                    Navigator.of(context).pop();
                    _dialogOpened = false;
                    networkStatusProvider.checkApiReachable();
                  }
                );
              });
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}