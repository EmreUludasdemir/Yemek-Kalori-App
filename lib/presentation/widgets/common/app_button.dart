import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum AppButtonType { primary, secondary, outlined, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    Widget buttonChild = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          );

    Widget button;

    switch (type) {
      case AppButtonType.primary:
        button = ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
            foregroundColor: Colors.white,
            minimumSize: Size(width ?? double.infinity, height ?? 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: buttonChild,
        );
        break;

      case AppButtonType.secondary:
        button = ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            disabledBackgroundColor: AppColors.accent.withOpacity(0.5),
            foregroundColor: Colors.white,
            minimumSize: Size(width ?? double.infinity, height ?? 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: buttonChild,
        );
        break;

      case AppButtonType.outlined:
        button = OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(
              color: isDisabled
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.primary,
              width: 1.5,
            ),
            minimumSize: Size(width ?? double.infinity, height ?? 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: buttonChild,
        );
        break;

      case AppButtonType.text:
        button = TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: Size(width ?? 0, height ?? 40),
          ),
          child: buttonChild,
        );
        break;
    }

    if (!isFullWidth) {
      return button;
    }

    return SizedBox(
      width: width ?? double.infinity,
      child: button,
    );
  }
}
