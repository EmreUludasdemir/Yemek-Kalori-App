import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';

/// Modern dialogs with animations
class CustomDialog {
  /// Confirmation dialog
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Onayla',
    String cancelText = 'İptal',
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(title, style: AppTheme.h3),
        content: Text(message, style: AppTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDangerous ? AppColors.error : null,
            ),
            child: Text(confirmText),
          ),
        ],
      ).animate().fadeIn(duration: 200.ms).scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
          ),
    );
  }

  /// Success dialog
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    String? message,
    Duration? autoDismiss,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: autoDismiss != null,
      builder: (context) => _AnimatedDialog(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 64,
                ),
              )
                  .animate()
                  .scale(
                    duration: 400.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(),
              const SizedBox(height: 24),
              Text(
                title,
                style: AppTheme.h3,
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: 12),
                Text(
                  message,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tamam'),
            ),
          ],
        ),
      ),
    );

    if (autoDismiss != null) {
      await Future.delayed(autoDismiss);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  /// Error dialog
  static Future<void> showError({
    required BuildContext context,
    required String title,
    String? message,
    String? errorDetails,
  }) {
    return showDialog(
      context: context,
      builder: (context) => _AnimatedDialog(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 64,
                ),
              ).animate().shake(duration: 400.ms).fadeIn(),
              const SizedBox(height: 24),
              Text(
                title,
                style: AppTheme.h3,
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: 12),
                Text(
                  message,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (errorDetails != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    errorDetails,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.error,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tamam'),
            ),
          ],
        ),
      ),
    );
  }

  /// Info dialog
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    IconData icon = Icons.info_outline,
  }) {
    return showDialog(
      context: context,
      builder: (context) => _AnimatedDialog(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.info,
                  size: 64,
                ),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 24),
              Text(
                title,
                style: AppTheme.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anladım'),
            ),
          ],
        ),
      ),
    );
  }

  /// Loading dialog
  static void showLoading({
    required BuildContext context,
    String message = 'Yükleniyor...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: AppTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Custom dialog with widget
  static Future<T?> showCustom<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _AnimatedDialog(child: child),
    );
  }
}

/// Animated dialog wrapper
class _AnimatedDialog extends StatelessWidget {
  final Widget child;

  const _AnimatedDialog({required this.child});

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(duration: 200.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 200.ms,
          curve: Curves.easeOut,
        );
  }
}

/// Action sheet dialog
class ActionSheetDialog extends StatelessWidget {
  final String? title;
  final List<ActionSheetOption> options;

  const ActionSheetDialog({
    super.key,
    this.title,
    required this.options,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required List<ActionSheetOption> options,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => ActionSheetDialog(
        title: title,
        options: options,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title!,
                style: AppTheme.h4,
              ),
            ),
          ...options.map((option) => _buildOption(context, option)),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildOption(BuildContext context, ActionSheetOption option) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        option.onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (option.icon != null) ...[
              Icon(
                option.icon,
                color: option.isDestructive ? AppColors.error : null,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                option.label,
                style: AppTheme.bodyMedium.copyWith(
                  color: option.isDestructive ? AppColors.error : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionSheetOption {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isDestructive;

  ActionSheetOption({
    required this.label,
    this.icon,
    required this.onTap,
    this.isDestructive = false,
  });
}
