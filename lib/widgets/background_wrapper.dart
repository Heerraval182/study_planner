import 'package:flutter/material.dart';
import 'dart:ui';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;
  const BackgroundWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Deep Space Background
        Container(color: const Color(0xFF090E17)),
        // Glowing Orbs
        Positioned(
          top: -150,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF6366F1), // Neon Indigo
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF14B8A6), // Cyan/Teal
            ),
          ),
        ),
        Positioned(
          top: 300,
          right: -150,
          child: Container(
            width: 250,
            height: 250,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFD946EF), // Fuchsia
            ),
          ),
        ),
        // Heavy Blur Filter
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
          child: Container(color: Colors.transparent),
        ),
        // Main Content
        child,
      ],
    );
  }
}
