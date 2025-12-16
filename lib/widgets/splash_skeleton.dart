import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashSkeleton extends StatelessWidget {
  const SplashSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // Keep it clean: just a logo/title or a very subtle pulse
    // Apple doesn't show "loading spinners" on launch if possible, they show clarity.
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Creating a "breathing" logo effect
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.9, end: 1.0),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              builder: (context, val, child) {
                return Transform.scale(
                  scale: val,
                  child: child,
                );
              },
              onEnd: () {}, // Could loop if needed, but simple is better
              child: const Text(
                'SOCH.',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: Color(0xFF1E88E5), // Using primary color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
