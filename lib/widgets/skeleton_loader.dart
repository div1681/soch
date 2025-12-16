import 'package:flutter/material.dart';

class Skeleton extends StatefulWidget {
  final double height;
  final double width;
  final double cornerRadius;

  const Skeleton({
    Key? key,
    this.height = 20,
    this.width = 200,
    this.cornerRadius = 4,
  }) : super(key: key);

  const Skeleton.circle({
    Key? key,
    required double size,
  }) : height = size, width = size, cornerRadius = size / 2, super(key: key);

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 1500)
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.cornerRadius),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).cardColor,
                Theme.of(context).scaffoldBackgroundColor, // Lighter/Contrast
                Theme.of(context).cardColor,
              ],
              stops: const [0.1, 0.5, 0.9],
              begin: Alignment(-1.0 + (_controller.value * 2), -0.3),
              end: Alignment(1.0 + (_controller.value * 2), 0.3),
            ),
          ),
        );
      },
    );
  }
}
