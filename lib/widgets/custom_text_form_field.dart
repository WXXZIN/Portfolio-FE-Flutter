import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final TextInputType textInputType;
  final TextInputAction textInputAction;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    required this.controller,
    this.onChanged,
    this.obscureText = false,
    this.textInputType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  final FocusNode _focusNode = FocusNode();
  bool _showClearIcon = false;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    widget.controller.addListener(_updateClearIconVisibility);
    _focusNode.addListener(_updateClearIconVisibility);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateClearIconVisibility);
    _focusNode.removeListener(_updateClearIconVisibility);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      obscureText: _obscureText,
      focusNode: _focusNode,
      decoration: _buildInputDecoration(),
      keyboardType: widget.textInputType,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: (value) {
        if (widget.textInputAction == TextInputAction.next) {
          FocusScope.of(context).nextFocus();
        }
      },
    );
  }

  void _updateClearIconVisibility() {
    final shouldShowClearIcon = widget.controller.text.isNotEmpty && _focusNode.hasFocus;
    if (_showClearIcon != shouldShowClearIcon) {
      setState(() {
        _showClearIcon = shouldShowClearIcon;
      });
    }
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      isDense: true,
      hintText: widget.hintText,
      suffixIcon: _showClearIcon
          ? widget.obscureText
              ? IconButton(
                  icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    widget.controller.clear();
                  },
                )
          : null,
      border: const OutlineInputBorder(),
    );
  }
}