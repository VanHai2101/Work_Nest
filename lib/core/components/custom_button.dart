import 'package:flutter/material.dart';
import '../theme/index.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutline;
  final IconData? icon;
  final IconData? suffixIcon;
  final double? width;
  final double height;
  final List<Color>? gradientColors;

  const CustomButton({
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutline = false,
    this.icon,
    this.suffixIcon,
    this.width,
    this.height = 55,
    this.gradientColors,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient =
        gradientColors ?? [AppColors.accent, AppColors.accentDark];

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          gradient: (onPressed != null && !isOutline && !isLoading)
              ? LinearGradient(
                  colors: effectiveGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: (onPressed == null || isOutline || isLoading)
              ? (isOutline ? Colors.transparent : AppColors.disabledBackground)
              : null,
          border: isOutline
              ? Border.all(
                  color: onPressed != null
                      ? AppColors.accent
                      : AppColors.disabled,
                  width: 2,
                )
              : null,
          boxShadow: (onPressed != null && !isOutline && !isLoading)
              ? [
                  BoxShadow(
                    color: effectiveGradient.first.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(height / 2),
            ),
            padding: EdgeInsets.symmetric(horizontal: icon != null ? 20 : 30),
          ),
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOutline ? AppColors.accent : Colors.white,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        color: isOutline ? AppColors.accent : Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isOutline
                            ? (onPressed != null
                                ? AppColors.accent
                                : AppColors.disabled)
                            : Colors.white,
                        letterSpacing: 1.1,
                      ),
                    ),
                    if (suffixIcon != null) ...[
                      const SizedBox(width: 10),
                      Icon(
                        suffixIcon,
                        color: isOutline ? AppColors.accent : Colors.white,
                        size: 20,
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
