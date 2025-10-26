import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  const LoadingView({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: const Color(0x88000000),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
