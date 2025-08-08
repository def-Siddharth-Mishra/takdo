import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class CustomAppIcon extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  
  const CustomAppIcon({
    super.key,
    this.size = 80,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? AppColors.primary).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.check,
        color: iconColor ?? AppColors.onPrimary,
        size: size * 0.5,
      ),
    );
  }
}