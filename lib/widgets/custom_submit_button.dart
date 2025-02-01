import 'package:flutter/material.dart';

class CustomSubmitButton extends StatefulWidget {
  final String text;
  final bool isButtonEnabled;
  final VoidCallback onPressed;

  const CustomSubmitButton({
    super.key,
    required this.text,
    required this.isButtonEnabled,
    required this.onPressed,
  });

  @override
  State<CustomSubmitButton> createState() => _CustomSubmitButtonState();
}

class _CustomSubmitButtonState extends State<CustomSubmitButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.black,
        ),
        onPressed: widget.isButtonEnabled ? widget.onPressed : null,
        child: Text(
          widget.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
    );
  }
}
