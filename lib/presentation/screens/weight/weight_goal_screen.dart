import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../config/supabase_config.dart';
import '../../../services/weight_tracking_service.dart';
import '../../widgets/modals/custom_dialog.dart';
import '../../widgets/animations/micro_interactions.dart';

class WeightGoalScreen extends ConsumerStatefulWidget {
  const WeightGoalScreen({super.key});

  @override
  ConsumerState<WeightGoalScreen> createState() => _WeightGoalScreenState();
}

class _WeightGoalScreenState extends ConsumerState<WeightGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _startWeightController = TextEditingController();
  final _targetWeightController = TextEditingController();

  String _goalType = 'lose'; // lose, maintain, gain
  DateTime? _targetDate;
  bool _isLoading = false;
  double? _currentWeight;
  double? _predictedDate;

  @override
  void initState() {
    super.initState();
    _loadCurrentWeight();
  }

  Future<void> _loadCurrentWeight() async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return;

    try {
      final latestEntry = await WeightTrackingService.getLatestWeightEntry(userId);
      if (latestEntry != null && mounted) {
        setState(() {
          _currentWeight = latestEntry.weight;
          _startWeightController.text = latestEntry.weight.toStringAsFixed(1);
        });
      }
    } catch (e) {
      print('Error loading current weight: $e');
    }
  }

  @override
  void dispose() {
    _startWeightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _selectTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
    );

    if (picked != null) {
      setState(() {
        _targetDate = picked;
        _calculatePrediction();
      });
    }
  }

  void _calculatePrediction() {
    if (_startWeightController.text.isEmpty ||
        _targetWeightController.text.isEmpty ||
        _targetDate == null) {
      return;
    }

    final startWeight = double.tryParse(_startWeightController.text);
    final targetWeight = double.tryParse(_targetWeightController.text);

    if (startWeight == null || targetWeight == null) return;

    final daysToTarget = _targetDate!.difference(DateTime.now()).inDays;
    if (daysToTarget <= 0) return;

    final totalChange = (targetWeight - startWeight).abs();
    final weeklyChange = totalChange / (daysToTarget / 7);

    setState(() {
      _predictedDate = weeklyChange;
    });
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = SupabaseConfig.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı bulunamadı');

      final startWeight = double.parse(_startWeightController.text.trim());
      final targetWeight = double.parse(_targetWeightController.text.trim());

      await WeightTrackingService.createWeightGoal(
        userId: userId,
        startWeight: startWeight,
        targetWeight: targetWeight,
        goalType: _goalType,
        targetDate: _targetDate,
      );

      if (mounted) {
        await CustomDialog.showSuccess(
          context: context,
          title: 'Başarılı!',
          message: 'Kilo hedefi belirlendi',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Hata',
          message: 'Hedef kaydedilemedi: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kilo Hedefi Belirle'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Goal type selection
            const Text(
              'Hedefiniz Nedir?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildGoalTypeButton(
                    'lose',
                    'Kilo Ver',
                    Icons.trending_down,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGoalTypeButton(
                    'maintain',
                    'Koru',
                    Icons.remove,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGoalTypeButton(
                    'gain',
                    'Kilo Al',
                    Icons.trending_up,
                    AppColors.error,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Start weight
            const Text(
              'Başlangıç Kilosu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _startWeightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Başlangıç kilosu (kg)',
                hintText: 'Örn: 75.5',
                prefixIcon: const Icon(Icons.start),
                suffixText: 'kg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => _calculatePrediction(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Başlangıç kilosu gerekli';
                }
                final weight = double.tryParse(value.trim());
                if (weight == null || weight < 30 || weight > 300) {
                  return 'Geçerli bir kilo girin (30-300 kg)';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Target weight
            const Text(
              'Hedef Kilo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _targetWeightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Hedef kilo (kg)',
                hintText: 'Örn: 70.0',
                prefixIcon: const Icon(Icons.flag),
                suffixText: 'kg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => _calculatePrediction(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Hedef kilo gerekli';
                }
                final weight = double.tryParse(value.trim());
                if (weight == null || weight < 30 || weight > 300) {
                  return 'Geçerli bir kilo girin (30-300 kg)';
                }
                if (_startWeightController.text.isNotEmpty) {
                  final startWeight = double.parse(_startWeightController.text);
                  if (_goalType == 'lose' && weight >= startWeight) {
                    return 'Hedef kilo başlangıçtan düşük olmalı';
                  }
                  if (_goalType == 'gain' && weight <= startWeight) {
                    return 'Hedef kilo başlangıçtan yüksek olmalı';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Target date
            const Text(
              'Hedef Tarih (İsteğe Bağlı)',
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
              child: InkWell(
                onTap: _selectTargetDate,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hedef Tarihi',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _targetDate != null
                                  ? DateFormat('d MMMM yyyy, EEEE', 'tr').format(_targetDate!)
                                  : 'Seçilmedi',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
            ),

            // Prediction info
            if (_predictedDate != null && _targetDate != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: WeightTrackingService.isHealthyWeightChange(_predictedDate!)
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      WeightTrackingService.isHealthyWeightChange(_predictedDate!)
                          ? Icons.check_circle_outline
                          : Icons.warning_amber,
                      color: WeightTrackingService.isHealthyWeightChange(_predictedDate!)
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Haftalık Değişim: ${_predictedDate!.toStringAsFixed(2)} kg',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: WeightTrackingService.isHealthyWeightChange(_predictedDate!)
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            WeightTrackingService.isHealthyWeightChange(_predictedDate!)
                                ? 'Sağlıklı değişim hızı (0.5-1 kg/hafta)'
                                : 'Önerilen: 0.5-1 kg/hafta',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Save button
            BouncyButton(
              onPressed: _isLoading ? null : _saveGoal,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isLoading
                    ? const Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      )
                    : const Text(
                        'Hedef Belirle',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalTypeButton(String type, String label, IconData icon, Color color) {
    final isSelected = _goalType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _goalType = type;
        });
        _calculatePrediction();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
