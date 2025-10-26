import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  const LoadingView({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          child,
          if (isLoading) const Positioned.fill(child: _RotatingImageLoader())
        ],
      ),
    );
  }
}

class _RotatingImageLoader extends StatefulWidget {
  const _RotatingImageLoader();

  @override
  State<_RotatingImageLoader> createState() => _RotatingImageLoaderState();
}

class _RotatingImageLoaderState extends State<_RotatingImageLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.5),
      child: RotationTransition(
        turns: _controller,
        child: Center(
          child: SizedBox(
            width: screenWidth * 0.35,
            height: screenWidth * 0.35,
            child: Image.asset(
              'assets/kate.jpg',
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}
