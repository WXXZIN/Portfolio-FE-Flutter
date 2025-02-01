import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String hintText;
  final VoidCallback? onButtonPressed;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.keyboardType,
    required this.textInputAction,
    required this.hintText,
    this.onButtonPressed,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      focusNode: _focusNode,
      decoration: _buildInputDecoration(),
      textInputAction: widget.textInputAction,
    );
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      hintText: widget.hintText,
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      suffixIcon: TextButton(
        onPressed: widget.onButtonPressed,
        child: const Text(
          '증복확인',
          style: TextStyle(color: Colors.blue)),
      )
    );
  }
}