import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/constants/app_colors.dart';

/// Swipeable item with delete and edit actions
class SwipeableItem extends StatelessWidget {
  final Widget child;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onFavorite;
  final String? deleteConfirmMessage;
  final bool enabled;

  const SwipeableItem({
    super.key,
    required this.child,
    this.onDelete,
    this.onEdit,
    this.onFavorite,
    this.deleteConfirmMessage,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled || (onDelete == null && onEdit == null && onFavorite == null)) {
      return child;
    }

    return Slidable(
      key: ValueKey(child.hashCode),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.4,
        children: [
          if (onEdit != null)
            SlidableAction(
              onPressed: (_) => onEdit!(),
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Düzenle',
              borderRadius: BorderRadius.circular(12),
            ),
          if (onDelete != null)
            SlidableAction(
              onPressed: (_) => _handleDelete(context),
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Sil',
              borderRadius: BorderRadius.circular(12),
            ),
        ],
      ),
      startActionPane: onFavorite != null
          ? ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (_) => onFavorite!(),
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  icon: Icons.star,
                  label: 'Favori',
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            )
          : null,
      child: child,
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    if (deleteConfirmMessage != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Emin misiniz?'),
          content: Text(deleteConfirmMessage!),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Sil'),
            ),
          ],
        ),
      );

      if (confirmed == true && onDelete != null) {
        onDelete!();
      }
    } else {
      onDelete?.call();
    }
  }
}

/// Dismissible item (simple swipe to delete)
class DismissibleItem extends StatelessWidget {
  final String itemKey;
  final Widget child;
  final VoidCallback? onDismissed;
  final String? confirmMessage;
  final DismissDirection direction;

  const DismissibleItem({
    super.key,
    required this.itemKey,
    required this.child,
    this.onDismissed,
    this.confirmMessage,
    this.direction = DismissDirection.endToStart,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(itemKey),
      direction: direction,
      confirmDismiss: confirmMessage != null
          ? (_) => _showConfirmDialog(context)
          : null,
      onDismissed: (_) => onDismissed?.call(),
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      child: child,
    );
  }

  Future<bool?> _showConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Emin misiniz?'),
        content: Text(confirmMessage!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

/// Long press menu
class LongPressMenu {
  static void show({
    required BuildContext context,
    required RelativeRect position,
    required List<LongPressMenuItem> items,
  }) {
    showMenu(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      items: items.map((item) {
        return PopupMenuItem(
          value: item.value,
          onTap: item.onTap,
          child: Row(
            children: [
              if (item.icon != null) ...[
                Icon(
                  item.icon,
                  size: 20,
                  color: item.isDestructive ? AppColors.error : null,
                ),
                const SizedBox(width: 12),
              ],
              Text(
                item.label,
                style: TextStyle(
                  color: item.isDestructive ? AppColors.error : null,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class LongPressMenuItem {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final String? value;
  final bool isDestructive;

  LongPressMenuItem({
    required this.label,
    this.icon,
    required this.onTap,
    this.value,
    this.isDestructive = false,
  });
}
