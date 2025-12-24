import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İstatistikler'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder for charts
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'İstatistikler ve Grafikler',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Grafikler yakında eklenecek!',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Upcoming features
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
                    const Text(
                      'Yakında Eklenecek:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem('📊 Haftalık kalori grafikleri'),
                    _buildFeatureItem('📈 Makro besin dağılımı'),
                    _buildFeatureItem('🔥 Seri (streak) geçmişi'),
                    _buildFeatureItem('🏆 Başarılar ve rozetler'),
                    _buildFeatureItem('📅 Aylık raporlar'),
                    _buildFeatureItem('⚖️ Kilo takibi'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
