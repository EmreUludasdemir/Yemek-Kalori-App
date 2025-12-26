import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_colors.dart';
import '../../../config/supabase_config.dart';
import '../../../data/models/notification_model.dart';
import '../../../services/social_service.dart';
import 'user_profile_screen.dart';

// Providers
final notificationsProvider = FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  final userId = SupabaseConfig.currentUser?.id;
  if (userId == null) return [];
  return await SocialService.getNotifications(userId: userId);
});

final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final userId = SupabaseConfig.currentUser?.id;
  if (userId == null) return 0;
  return await SocialService.getUnreadNotificationCount(userId);
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          TextButton(
            onPressed: () async {
              final userId = SupabaseConfig.currentUser?.id;
              if (userId != null) {
                await SocialService.markAllNotificationsAsRead(userId);
                ref.invalidate(notificationsProvider);
                ref.invalidate(unreadCountProvider);
              }
            },
            child: const Text('Tümünü Okundu İşaretle'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz bildirim yok',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _NotificationTile(notification: notifications[index]);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Hata: $error'),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final AppNotification notification;

  const _NotificationTile({required this.notification});

  IconData _getIconForType(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.chat_bubble;
      case 'follow':
        return Icons.person_add;
      case 'mention':
        return Icons.alternate_email;
      case 'achievement':
        return Icons.emoji_events;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'like':
        return Colors.red;
      case 'comment':
        return AppColors.primary;
      case 'follow':
        return Colors.green;
      case 'mention':
        return Colors.orange;
      case 'achievement':
        return Colors.amber;
      default:
        return AppColors.primary;
    }
  }

  String _getMessageForNotification() {
    final actorName = notification.actor?.fullName ??
        notification.actor?.username ??
        'Birisi';

    switch (notification.type) {
      case 'like':
        return '$actorName gönderinizi beğendi';
      case 'comment':
        return '$actorName gönderinize yorum yaptı';
      case 'follow':
        return '$actorName seni takip etmeye başladı';
      case 'mention':
        return '$actorName senden bahsetti';
      case 'achievement':
        return notification.message ?? 'Yeni bir başarım kazandın!';
      default:
        return notification.message ?? 'Bildirim';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actor = notification.actor;

    // Setup Turkish locale for timeago
    timeago.setLocaleMessages('tr', timeago.TrMessages());

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: actor?.avatarUrl != null
                ? CachedNetworkImageProvider(actor!.avatarUrl!)
                : null,
            child: actor?.avatarUrl == null
                ? Icon(
                    _getIconForType(notification.type),
                    color: _getColorForType(notification.type),
                  )
                : null,
          ),
          if (!notification.isRead)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        _getMessageForNotification(),
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
        ),
      ),
      subtitle: Text(
        timeago.format(notification.createdAt, locale: 'tr'),
        style: TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
      tileColor: notification.isRead ? null : AppColors.primary.withOpacity(0.05),
      onTap: () async {
        // Mark as read
        if (!notification.isRead) {
          await SocialService.markNotificationAsRead(notification.id);
          ref.invalidate(notificationsProvider);
          ref.invalidate(unreadCountProvider);
        }

        // Navigate based on type
        if (!context.mounted) return;

        if (notification.type == 'follow' && actor != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserProfileScreen(userId: actor.id),
            ),
          );
        } else if (notification.targetType == 'post' &&
            notification.targetId != null) {
          // TODO: Navigate to post detail
        }
      },
    );
  }
}
