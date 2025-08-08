import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class FloatingElements extends StatelessWidget {
  const FloatingElements({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top left orange dot
        Positioned(
          top: 100,
          left: 50,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFF59E0B),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Top right yellow star
        Positioned(
          top: 80,
          right: 60,
          child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Color(0xFFFBBF24),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Middle right dark dot
        Positioned(
          top: 150,
          right: 40,
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Bottom right purple dot
        Positioned(
          bottom: 200,
          right: 80,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Left side gray dots
        Positioned(
          top: 200,
          left: 30,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: 300,
          left: 20,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}