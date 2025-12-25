import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Feature discovery widget for showcasing features
class FeatureDiscovery {
  static Future<void> discoverFeature({
    required BuildContext context,
    required String featureId,
    required GlobalKey targetKey,
    required String title,
    required String description,
    Color? backgroundColor,
    VoidCallback? onComplete,
  }) async {
    final box = await Hive.openBox('feature_discovery');
    final hasShown = box.get(featureId, defaultValue: false) as bool;

    if (hasShown) return;

    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _FeatureSpotlight(
        targetKey: targetKey,
        title: title,
        description: description,
        backgroundColor: backgroundColor ?? AppColors.primary,
        onComplete: () async {
          await box.put(featureId, true);
          onComplete?.call();
        },
      ),
    );
  }

  static Future<void> resetDiscovery() async {
    final box = await Hive.openBox('feature_discovery');
    await box.clear();
  }
}

class _FeatureSpotlight extends StatelessWidget {
  final GlobalKey targetKey;
  final String title;
  final String description;
  final Color backgroundColor;
  final VoidCallback onComplete;

  const _FeatureSpotlight({
    required this.targetKey,
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final RenderBox? renderBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      return const SizedBox.shrink();
    }

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return Stack(
      children: [
        // Dark overlay
        Container(
          color: Colors.black.withOpacity(0.7),
          child: GestureDetector(
            onTap: () {
              onComplete();
              Navigator.pop(context);
            },
          ),
        ),

        // Spotlight circle
        Positioned(
          left: position.dx - 20,
          top: position.dy - 20,
          child: Container(
            width: size.width + 40,
            height: size.height + 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: Border.all(
                color: backgroundColor,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        ),

        // Description card
        Positioned(
          left: 24,
          right: 24,
          top: position.dy + size.height + 60,
          child: Card(
            color: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTheme.h3.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        onComplete();
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                      child: const Text('Anladım'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Tooltip widget for hints
class HintTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  final TooltipPosition position;

  const HintTooltip({
    super.key,
    required this.message,
    required this.child,
    this.position = TooltipPosition.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: AppTheme.bodySmall.copyWith(color: Colors.white),
      preferBelow: position == TooltipPosition.bottom,
      child: child,
    );
  }
}

enum TooltipPosition { top, bottom, left, right }

/// Coach mark for guided tutorial
class CoachMark {
  static Future<void> show({
    required BuildContext context,
    required List<CoachMarkStep> steps,
  }) async {
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _CoachMarkDialog(
          step: step,
          currentStep: i + 1,
          totalSteps: steps.length,
        ),
      );
    }
  }
}

class CoachMarkStep {
  final GlobalKey targetKey;
  final String title;
  final String description;
  final IconData? icon;

  CoachMarkStep({
    required this.targetKey,
    required this.title,
    required this.description,
    this.icon,
  });
}

class _CoachMarkDialog extends StatelessWidget {
  final CoachMarkStep step;
  final int currentStep;
  final int totalSteps;

  const _CoachMarkDialog({
    required this.step,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final RenderBox? renderBox =
        step.targetKey.currentContext?.findRenderObject() as RenderBox?;

    return Stack(
      children: [
        // Semi-transparent overlay
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),

        // Highlight target area
        if (renderBox != null)
          Positioned(
            left: renderBox.localToGlobal(Offset.zero).dx - 8,
            top: renderBox.localToGlobal(Offset.zero).dy - 8,
            child: Container(
              width: renderBox.size.width + 16,
              height: renderBox.size.height + 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
            ),
          ),

        // Instruction card
        Positioned(
          left: 24,
          right: 24,
          bottom: 100,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (step.icon != null) ...[
                        Icon(step.icon, color: AppColors.primary),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          step.title,
                          style: AppTheme.h4,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$currentStep/$totalSteps',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    step.description,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (currentStep < totalSteps)
                        TextButton(
                          onPressed: () {
                            // Skip all
                            Navigator.pop(context);
                          },
                          child: const Text('Atla'),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          currentStep == totalSteps ? 'Bitir' : 'Devam',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Info badge for new features
class InfoBadge extends StatelessWidget {
  final Widget child;
  final String label;
  final bool show;

  const InfoBadge({
    super.key,
    required this.child,
    required this.label,
    this.show = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!show) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -8,
          right: -8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
