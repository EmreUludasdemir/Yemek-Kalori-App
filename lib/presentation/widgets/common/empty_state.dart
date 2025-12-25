import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';

/// Beautiful empty state widget with Lottie animations
class EmptyState extends StatelessWidget {
  final EmptyStateType type;
  final String? title;
  final String? message;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? customIcon;

  const EmptyState({
    super.key,
    required this.type,
    this.title,
    this.message,
    this.actionText,
    this.onAction,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon or Animation
            if (customIcon != null)
              customIcon!
            else if (config.lottieAsset != null)
              Lottie.asset(
                config.lottieAsset!,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              )
            else
              Icon(
                config.icon,
                size: 120,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),

            const SizedBox(height: 32),

            // Title
            Text(
              title ?? config.defaultTitle,
              style: AppTheme.h3.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              message ?? config.defaultMessage,
              style: AppTheme.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 32),

              // Action Button
              ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(config.actionIcon ?? Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _EmptyStateConfig _getConfig() {
    switch (type) {
      case EmptyStateType.noFoods:
        return _EmptyStateConfig(
          icon: Icons.restaurant_outlined,
          defaultTitle: 'Henüz Yemek Yok',
          defaultMessage: 'Kalori takibine başlamak için ilk yemeğini ekle!',
          actionIcon: Icons.add_circle_outline,
        );

      case EmptyStateType.noMeals:
        return _EmptyStateConfig(
          icon: Icons.lunch_dining_outlined,
          defaultTitle: 'Bugün Öğün Yok',
          defaultMessage: 'Bugün için henüz öğün eklemedin. Hadi başlayalım!',
          actionIcon: Icons.add,
        );

      case EmptyStateType.noSearchResults:
        return _EmptyStateConfig(
          icon: Icons.search_off_outlined,
          defaultTitle: 'Sonuç Bulunamadı',
          defaultMessage: 'Aradığın yemek bulunamadı. Başka bir isim dene.',
          actionIcon: Icons.clear,
        );

      case EmptyStateType.noPosts:
        return _EmptyStateConfig(
          icon: Icons.post_add_outlined,
          defaultTitle: 'Henüz Paylaşım Yok',
          defaultMessage: 'İlk paylaşımını yap ve topluluğa katıl!',
          actionIcon: Icons.add_photo_alternate_outlined,
        );

      case EmptyStateType.noStats:
        return _EmptyStateConfig(
          icon: Icons.analytics_outlined,
          defaultTitle: 'İstatistik Yok',
          defaultMessage: 'Yeterli veri yok. Birkaç gün yemek kaydı yap!',
        );

      case EmptyStateType.noAchievements:
        return _EmptyStateConfig(
          icon: Icons.emoji_events_outlined,
          defaultTitle: 'Henüz Başarım Yok',
          defaultMessage: 'Başarımları kazanmaya başla! İlk yemeğini kaydet.',
          actionIcon: Icons.play_arrow,
        );

      case EmptyStateType.noNotifications:
        return _EmptyStateConfig(
          icon: Icons.notifications_none_outlined,
          defaultTitle: 'Bildirim Yok',
          defaultMessage: 'Şu an için yeni bildirim yok.',
        );

      case EmptyStateType.offline:
        return _EmptyStateConfig(
          icon: Icons.wifi_off_outlined,
          defaultTitle: 'İnternet Bağlantısı Yok',
          defaultMessage: 'Lütfen internet bağlantını kontrol et ve tekrar dene.',
          actionIcon: Icons.refresh,
        );

      case EmptyStateType.error:
        return _EmptyStateConfig(
          icon: Icons.error_outline,
          defaultTitle: 'Bir Hata Oluştu',
          defaultMessage: 'Üzgünüz, bir şeyler yanlış gitti. Lütfen tekrar dene.',
          actionIcon: Icons.refresh,
        );

      case EmptyStateType.comingSoon:
        return _EmptyStateConfig(
          icon: Icons.schedule_outlined,
          defaultTitle: 'Yakında!',
          defaultMessage: 'Bu özellik üzerinde çalışıyoruz. Çok yakında!',
        );

      case EmptyStateType.noFavorites:
        return _EmptyStateConfig(
          icon: Icons.favorite_border,
          defaultTitle: 'Favori Yemek Yok',
          defaultMessage: 'Favori yemeklerini ekleyerek hızlıca erişebilirsin.',
          actionIcon: Icons.search,
        );

      case EmptyStateType.noRecents:
        return _EmptyStateConfig(
          icon: Icons.history_outlined,
          defaultTitle: 'Son Aramalar Yok',
          defaultMessage: 'Arama geçmişin burada görünecek.',
        );
    }
  }
}

enum EmptyStateType {
  noFoods,
  noMeals,
  noSearchResults,
  noPosts,
  noStats,
  noAchievements,
  noNotifications,
  offline,
  error,
  comingSoon,
  noFavorites,
  noRecents,
}

class _EmptyStateConfig {
  final IconData icon;
  final String defaultTitle;
  final String defaultMessage;
  final String? lottieAsset;
  final IconData? actionIcon;

  _EmptyStateConfig({
    required this.icon,
    required this.defaultTitle,
    required this.defaultMessage,
    this.lottieAsset,
    this.actionIcon,
  });
}

/// Compact empty state for smaller areas
class CompactEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color? color;

  const CompactEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: color ?? AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTheme.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
