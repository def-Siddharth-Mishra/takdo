import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom button widget for authentication screens
class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AuthButtonVariant.primary,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AuthButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(),
          foregroundColor: _getForegroundColor(),
          disabledBackgroundColor: const Color(0xFFE5E7EB),
          disabledForegroundColor: const Color(0xFF9CA3AF),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: variant == AuthButtonVariant.outline
                ? const BorderSide(
                    color: Color(0xFF6366F1),
                    width: 1,
                  )
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case AuthButtonVariant.primary:
        return const Color(0xFF6366F1);
      case AuthButtonVariant.outline:
        return Colors.transparent;
      case AuthButtonVariant.secondary:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getForegroundColor() {
    switch (variant) {
      case AuthButtonVariant.primary:
        return Colors.white;
      case AuthButtonVariant.outline:
        return const Color(0xFF6366F1);
      case AuthButtonVariant.secondary:
        return const Color(0xFF374151);
    }
  }
}

/// Button variant types
enum AuthButtonVariant {
  primary,
  outline,
  secondary,
}