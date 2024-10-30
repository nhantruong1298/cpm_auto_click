import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? label;
  const AppButton({super.key, this.onPressed, this.label});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: const Color(0xfffdc35a),
      child: Text(label ?? ''),
    );
  }
}
