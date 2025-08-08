import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';

class SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: iconColor,
          size: AppConstants.iconMedium,
        ),
      ),
    );
  }
}

class SocialLoginRow extends StatelessWidget {
  final VoidCallback onFacebookPressed;
  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;

  const SocialLoginRow({
    super.key,
    required this.onFacebookPressed,
    required this.onGooglePressed,
    required this.onApplePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SocialLoginButton(
          icon: Icons.facebook,
          backgroundColor: AppColors.facebook,
          iconColor: Colors.white,
          onPressed: onFacebookPressed,
        ),
        const SizedBox(width: AppConstants.spacing24),
        SocialLoginButton(
          icon: Icons.g_mobiledata,
          backgroundColor: AppColors.google,
          iconColor: Colors.white,
          onPressed: onGooglePressed,
        ),
        const SizedBox(width: AppConstants.spacing24),
        SocialLoginButton(
          icon: Icons.apple,
          backgroundColor: AppColors.apple,
          iconColor: Colors.white,
          onPressed: onApplePressed,
        ),
      ],
    );
  }
}