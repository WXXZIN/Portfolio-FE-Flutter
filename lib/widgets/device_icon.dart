import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class DeviceIcon extends StatelessWidget {
  final String osType;
  final double iconWidth;
  final double iconHeight;
  static const spriteUrl =
      'https://www.gstatic.com/identity/boq/accountsettingssecuritycommon/images/sprites/devices_realistic_72-b9bd1ca60228ef0457a37afb84e72bdd.png';

  const DeviceIcon({
    super.key,
    required this.osType,
    required this.iconWidth,
    required this.iconHeight,
  });

  @override
  Widget build(BuildContext context) {
    final deviceIndex = _getDeviceIndex();
    return FutureBuilder<ui.Image>(
      future: _loadImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CustomPaint(
            size: Size(iconWidth, iconHeight),
            painter: SpritePainter(
              deviceIndex: deviceIndex,
              image: snapshot.data!,
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  int _getDeviceIndex() {
    switch (osType) {
      case 'iPhone':
        return 0;
      case 'mac':
        return 7;
      case 'Android':
        return 9;
      case 'windows':
        return 20;
      default:
        return 0;
    }
  }

  Future<ui.Image> _loadImage() async {
    final image = NetworkImage(spriteUrl);
    final completer = Completer<ui.Image>();
    final stream = image.resolve(const ImageConfiguration());
    stream.addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) {
          final ui.Image img = info.image;
          completer.complete(img);
        },
      ),
    );
    return completer.future;
  }
}

class SpritePainter extends CustomPainter {
  final int deviceIndex;
  final ui.Image image;

  SpritePainter({
    required this.deviceIndex,
    required this.image,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final iconWidth = 144.0;
    final iconHeight = 146.0;

    final topOffset = deviceIndex * iconHeight;

    final srcRect = Rect.fromLTWH(0, topOffset.toDouble(), iconWidth, iconHeight);
    final destRect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawImageRect(image, srcRect, destRect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
