import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../config/supabase_config.dart';
import '../../../services/weight_tracking_service.dart';
import '../../widgets/modals/custom_dialog.dart';
import '../../widgets/animations/micro_interactions.dart';

class AddWeightEntryScreen extends ConsumerStatefulWidget {
  const AddWeightEntryScreen({super.key});

  @override
  ConsumerState<AddWeightEntryScreen> createState() => _AddWeightEntryScreenState();
}

class _AddWeightEntryScreenState extends ConsumerState<AddWeightEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // Optional body measurements
  final _neckController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _chestController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    _neckController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _chestController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = SupabaseConfig.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı bulunamadı');

      final weight = double.parse(_weightController.text.trim());

      // Build measurements map if any entered
      Map<String, double>? measurements;
      if (_neckController.text.isNotEmpty ||
          _waistController.text.isNotEmpty ||
          _hipsController.text.isNotEmpty ||
          _chestController.text.isNotEmpty) {
        measurements = {};
        if (_neckController.text.isNotEmpty) {
          measurements['neck'] = double.parse(_neckController.text);
        }
        if (_waistController.text.isNotEmpty) {
          measurements['waist'] = double.parse(_waistController.text);
        }
        if (_hipsController.text.isNotEmpty) {
          measurements['hips'] = double.parse(_hipsController.text);
        }
        if (_chestController.text.isNotEmpty) {
          measurements['chest'] = double.parse(_chestController.text);
        }
      }

      await WeightTrackingService.addWeightEntry(
        userId: userId,
        weight: weight,
        loggedAt: _selectedDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        measurements: measurements,
      );

      if (mounted) {
        await CustomDialog.showSuccess(
          context: context,
          title: 'Başarılı!',
          message: 'Kilo kaydı eklendi',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Hata',
          message: 'Kayıt eklenemedi: $e',
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
        title: const Text('Kilo Kaydı Ekle'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date selector
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.divider),
              ),
              child: InkWell(
                onTap: _selectDate,
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
                              'Tarih',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('d MMMM yyyy, EEEE', 'tr').format(_selectedDate),
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

            const SizedBox(height: 24),

            // Weight input
            const Text(
              'Kilo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Kilonuz (kg)',
                hintText: 'Örn: 75.5',
                prefixIcon: const Icon(Icons.monitor_weight_outlined),
                suffixText: 'kg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Kilo gerekli';
                }
                final weight = double.tryParse(value.trim());
                if (weight == null) {
                  return 'Geçerli bir sayı girin';
                }
                if (weight < 30 || weight > 300) {
                  return 'Kilo 30-300 kg arasında olmalı';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Notes
            const Text(
              'Notlar (İsteğe Bağlı)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notlar',
                hintText: 'Örn: Sabah aç karnına',
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Body measurements (expandable)
            ExpansionTile(
              title: const Text(
                'Vücut Ölçüleri (Opsiyonel)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: const Icon(Icons.straighten),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Neck
                      TextFormField(
                        controller: _neckController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Boyun',
                          hintText: 'cm',
                          suffixText: 'cm',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Waist
                      TextFormField(
                        controller: _waistController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Bel',
                          hintText: 'cm',
                          suffixText: 'cm',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Hips
                      TextFormField(
                        controller: _hipsController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Kalça',
                          hintText: 'cm',
                          suffixText: 'cm',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Chest
                      TextFormField(
                        controller: _chestController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Göğüs',
                          hintText: 'cm',
                          suffixText: 'cm',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Save button
            BouncyButton(
              onPressed: _isLoading ? null : _saveEntry,
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
                        'Kaydet',
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
}
