import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../services/water_reminder_service.dart';
import '../../widgets/modals/custom_dialog.dart';

// Provider for reminder settings
final reminderSettingsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return await WaterReminderService.getStatistics();
});

class WaterReminderSettingsScreen extends ConsumerStatefulWidget {
  const WaterReminderSettingsScreen({super.key});

  @override
  ConsumerState<WaterReminderSettingsScreen> createState() =>
      _WaterReminderSettingsScreenState();
}

class _WaterReminderSettingsScreenState
    extends ConsumerState<WaterReminderSettingsScreen> {
  bool _isLoading = false;

  void _refresh() {
    ref.invalidate(reminderSettingsProvider);
  }

  Future<void> _toggleReminders(bool enabled) async {
    setState(() => _isLoading = true);

    try {
      await WaterReminderService.setRemindersEnabled(enabled);
      _refresh();

      if (mounted) {
        CustomDialog.showSuccess(
          context: context,
          title: enabled ? 'Hatırlatıcılar Açıldı' : 'Hatırlatıcılar Kapatıldı',
          message: enabled
              ? 'Su içme hatırlatıcıları aktif'
              : 'Hatırlatıcılar devre dışı',
        );
      }
    } catch (e) {
      if (mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Hata',
          message: 'Ayar kaydedilemedi: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _setInterval(int minutes) async {
    setState(() => _isLoading = true);

    try {
      await WaterReminderService.setReminderInterval(minutes);
      _refresh();

      if (mounted) {
        CustomDialog.showSuccess(
          context: context,
          title: 'Güncellendi',
          message: 'Hatırlatma aralığı: $minutes dakika',
        );
      }
    } catch (e) {
      if (mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Hata',
          message: 'Ayar kaydedilemedi: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _setHours(int start, int end) async {
    setState(() => _isLoading = true);

    try {
      await WaterReminderService.setReminderHours(start, end);
      _refresh();

      if (mounted) {
        CustomDialog.showSuccess(
          context: context,
          title: 'Güncellendi',
          message: 'Hatırlatma saatleri: $start:00 - $end:00',
        );
      }
    } catch (e) {
      if (mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Hata',
          message: 'Ayar kaydedilemedi: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _applyPreset(String presetKey) async {
    setState(() => _isLoading = true);

    try {
      await WaterReminderService.applyPreset(presetKey);
      _refresh();

      final presetName = WaterReminderService.presets[presetKey]!['name'];
      if (mounted) {
        CustomDialog.showSuccess(
          context: context,
          title: 'Ön Ayar Uygulandı',
          message: '$presetName ayarları aktif',
        );
      }
    } catch (e) {
      if (mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Hata',
          message: 'Ön ayar uygulanamadı: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _testNotification() async {
    await WaterReminderService.showImmediateNotification(
      title: '💧 Test Bildirimi',
      body: 'Su hatırlatıcıları çalışıyor!',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test bildirimi gönderildi'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(reminderSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Su Hatırlatıcı Ayarları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: settingsAsync.when(
        data: (settings) => _buildContent(settings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Hata: $error')),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> settings) {
    final enabled = settings['enabled'] as bool;
    final interval = settings['interval'] as int;
    final startHour = settings['startHour'] as int;
    final endHour = settings['endHour'] as int;
    final remindersPerDay = settings['remindersPerDay'] as int;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Enable/Disable switch
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: enabled ? AppColors.primary.withOpacity(0.3) : AppColors.divider,
            ),
          ),
          child: SwitchListTile(
            value: enabled,
            onChanged: _isLoading ? null : _toggleReminders,
            title: const Text(
              'Su Hatırlatıcıları',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              enabled ? 'Aktif' : 'Kapalı',
              style: TextStyle(
                color: enabled ? AppColors.success : AppColors.textSecondary,
              ),
            ),
            secondary: Icon(
              Icons.water_drop,
              color: enabled ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Statistics
        if (enabled) ...[
          const Text(
            'Günlük Özet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Hatırlatma Sayısı',
                  '$remindersPerDay',
                  Icons.notifications_active,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Aralık',
                  '$interval dk',
                  Icons.timer,
                  AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Preset buttons
          const Text(
            'Hızlı Ayarlar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: WaterReminderService.presets.entries.map((entry) {
              return ActionChip(
                label: Text(entry.value['name']),
                onPressed: _isLoading ? null : () => _applyPreset(entry.key),
                avatar: const Icon(Icons.flash_on, size: 18),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Interval slider
          const Text(
            'Hatırlatma Aralığı',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.divider),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Her',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '$interval dakika',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: interval.toDouble(),
                    min: 15,
                    max: 240,
                    divisions: 15,
                    label: '$interval dk',
                    onChanged: _isLoading
                        ? null
                        : (value) => _setInterval(value.toInt()),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('15dk', style: TextStyle(fontSize: 12)),
                      Text('240dk (4sa)', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Time range
          const Text(
            'Hatırlatma Saatleri',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.divider),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Başlangıç', style: TextStyle(fontSize: 16)),
                      Text(
                        '${startHour.toString().padLeft(2, '0')}:00',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: startHour.toDouble(),
                    min: 0,
                    max: 23,
                    divisions: 23,
                    label: '${startHour.toString().padLeft(2, '0')}:00',
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            if (value.toInt() < endHour) {
                              _setHours(value.toInt(), endHour);
                            }
                          },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Bitiş', style: TextStyle(fontSize: 16)),
                      Text(
                        '${endHour.toString().padLeft(2, '0')}:00',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: endHour.toDouble(),
                    min: 0,
                    max: 23,
                    divisions: 23,
                    label: '${endHour.toString().padLeft(2, '0')}:00',
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            if (value.toInt() > startHour) {
                              _setHours(startHour, value.toInt());
                            }
                          },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Test button
          OutlinedButton.icon(
            onPressed: _testNotification,
            icon: const Icon(Icons.notification_add),
            label: const Text('Test Bildirimi Gönder'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Info card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Hatırlatıcılar ${startHour.toString().padLeft(2, '0')}:00 - ${endHour.toString().padLeft(2, '0')}:00 arasında her $interval dakikada bir gelecek.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
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
