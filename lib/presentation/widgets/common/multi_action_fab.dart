import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../../core/constants/app_colors.dart';

/// Multi-action Floating Action Button for quick actions
class MultiActionFAB extends StatelessWidget {
  final Function()? onAddFood;
  final Function()? onAddWater;
  final Function()? onOpenCamera;
  final Function()? onScanBarcode;

  const MultiActionFAB({
    super.key,
    this.onAddFood,
    this.onAddWater,
    this.onOpenCamera,
    this.onScanBarcode,
  });

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      activeBackgroundColor: AppColors.primaryDark,
      activeForegroundColor: Colors.white,
      buttonSize: const Size(56, 56),
      childrenButtonSize: const Size(56, 56),
      spacing: 12,
      spaceBetweenChildren: 12,
      dialRoot: (ctx, open, toggleChildren) {
        return FloatingActionButton(
          onPressed: toggleChildren,
          backgroundColor: AppColors.primary,
          child: Icon(
            open ? Icons.close : Icons.add,
            color: Colors.white,
          ),
        );
      },
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      tooltip: 'Hızlı Ekle',
      heroTag: 'multi-action-fab',
      elevation: 8,
      animationCurve: Curves.easeInOut,
      isOpenOnStart: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      children: [
        if (onAddFood != null)
          SpeedDialChild(
            child: const Icon(Icons.restaurant, color: Colors.white),
            backgroundColor: AppColors.primary,
            label: 'Yemek Ekle',
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            labelBackgroundColor: Colors.white,
            onTap: onAddFood,
          ),
        if (onAddWater != null)
          SpeedDialChild(
            child: const Icon(Icons.water_drop, color: Colors.white),
            backgroundColor: AppColors.info,
            label: 'Su Ekle',
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            labelBackgroundColor: Colors.white,
            onTap: onAddWater,
          ),
        if (onOpenCamera != null)
          SpeedDialChild(
            child: const Icon(Icons.camera_alt, color: Colors.white),
            backgroundColor: AppColors.accent,
            label: 'Fotoğraf Çek',
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            labelBackgroundColor: Colors.white,
            onTap: onOpenCamera,
          ),
        if (onScanBarcode != null)
          SpeedDialChild(
            child: const Icon(Icons.qr_code_scanner, color: Colors.white),
            backgroundColor: AppColors.warning,
            label: 'Barkod Tara',
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            labelBackgroundColor: Colors.white,
            onTap: onScanBarcode,
          ),
      ],
    );
  }
}

/// Simple FAB for single action
class SimpleFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;

  const SimpleFAB({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.tooltip,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? AppColors.primary,
      child: Icon(icon, color: Colors.white),
    );
  }
}

/// Extended FAB with label
class ExtendedFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color? backgroundColor;

  const ExtendedFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? AppColors.primary,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
