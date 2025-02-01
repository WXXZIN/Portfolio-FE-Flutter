import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final String logoPath;
  final String buttonText;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;

  const LoginButton({
    super.key,
    required this.logoPath,
    required this.buttonText,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          minimumSize: const Size(200, 50)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (logoPath.isNotEmpty)
              Image.asset(
                logoPath,
                width: 24.0,
                height: 24.0,
              ),
            if (logoPath.isNotEmpty)
              const SizedBox(width: 12.0),
            Text(
              buttonText,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500
              ),
            ),
          ],
        ),
      )
    );
  }
}
