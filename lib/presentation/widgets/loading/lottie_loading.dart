import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';

/// Loading widget with Lottie animations
class LottieLoading extends StatelessWidget {
  final LottieLoadingType type;
  final String? message;
  final double size;

  const LottieLoading({
    super.key,
    this.type = LottieLoadingType.loading,
    this.message,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie Animation or Fallback
          SizedBox(
            width: size,
            height: size,
            child: _buildAnimation(),
          ),

          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTheme.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimation() {
    // For now, use CircularProgressIndicator as fallback
    // You can add Lottie files later: assets/lottie/loading.json
    switch (type) {
      case LottieLoadingType.loading:
        return const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        );

      case LottieLoadingType.uploading:
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
            SizedBox(height: 8),
            Icon(Icons.cloud_upload, color: AppColors.accent, size: 32),
          ],
        );

      case LottieLoadingType.searching:
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
            ),
            SizedBox(height: 8),
            Icon(Icons.search, color: AppColors.info, size: 32),
          ],
        );
    }
  }
}

enum LottieLoadingType {
  loading,
  uploading,
  searching,
}

/// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.child,
    this.isLoading = false,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: LottieLoading(
              message: message ?? 'Yükleniyor...',
            ),
          ),
      ],
    );
  }
}

/// Circular loading button
class LoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;

  const LoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon),
                  const SizedBox(width: 8),
                ],
                Text(text),
              ],
            ),
    );
  }
}

/// Shimmer loading indicator
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}
