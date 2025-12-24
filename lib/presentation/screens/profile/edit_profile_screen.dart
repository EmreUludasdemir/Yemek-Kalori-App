import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../config/supabase_config.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _bioController;
  late TextEditingController _calorieGoalController;
  late TextEditingController _proteinGoalController;
  late TextEditingController _carbsGoalController;
  late TextEditingController _fatGoalController;
  late TextEditingController _waterGoalController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _bioController = TextEditingController(text: widget.profile.bio);
    _calorieGoalController = TextEditingController(
      text: widget.profile.dailyCalorieGoal.toString(),
    );
    _proteinGoalController = TextEditingController(
      text: widget.profile.dailyProteinGoal.toString(),
    );
    _carbsGoalController = TextEditingController(
      text: widget.profile.dailyCarbsGoal.toString(),
    );
    _fatGoalController = TextEditingController(
      text: widget.profile.dailyFatGoal.toString(),
    );
    _waterGoalController = TextEditingController(
      text: widget.profile.dailyWaterGoal.toString(),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _calorieGoalController.dispose();
    _proteinGoalController.dispose();
    _carbsGoalController.dispose();
    _fatGoalController.dispose();
    _waterGoalController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await SupabaseConfig.client.from('profiles').update({
        'full_name': _fullNameController.text.trim(),
        'bio': _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        'daily_calorie_goal': int.parse(_calorieGoalController.text),
        'daily_protein_goal': int.parse(_proteinGoalController.text),
        'daily_carbs_goal': int.parse(_carbsGoalController.text),
        'daily_fat_goal': int.parse(_fatGoalController.text),
        'daily_water_goal': int.parse(_waterGoalController.text),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', widget.profile.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profil güncellendi'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile picture placeholder
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      backgroundImage: widget.profile.avatarUrl != null
                          ? NetworkImage(widget.profile.avatarUrl!)
                          : null,
                      child: widget.profile.avatarUrl == null
                          ? Text(
                              widget.profile.username[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Implement photo picker
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fotoğraf seçimi yakında gelecek!'),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Personal Info Section
              const Text(
                'Kişisel Bilgiler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _fullNameController,
                label: 'Ad Soyad',
                hint: 'Ad Soyad',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ad soyad gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _bioController,
                label: 'Biyografi (Opsiyonel)',
                hint: 'Kendinden bahset...',
                prefixIcon: Icons.info_outline,
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Daily Goals Section
              const Text(
                'Günlük Hedefler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _calorieGoalController,
                label: 'Kalori Hedefi (kcal)',
                hint: '2000',
                prefixIcon: Icons.local_fire_department,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kalori hedefi gerekli';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number < 1000 || number > 5000) {
                    return 'Geçerli bir kalori değeri girin (1000-5000)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _proteinGoalController,
                      label: 'Protein (g)',
                      hint: '50',
                      prefixIcon: Icons.fitness_center,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Gerekli';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number < 0 || number > 500) {
                          return 'Geçersiz';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _carbsGoalController,
                      label: 'Karbonhidrat (g)',
                      hint: '250',
                      prefixIcon: Icons.grain,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Gerekli';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number < 0 || number > 1000) {
                          return 'Geçersiz';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _fatGoalController,
                      label: 'Yağ (g)',
                      hint: '65',
                      prefixIcon: Icons.water_drop,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Gerekli';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number < 0 || number > 300) {
                          return 'Geçersiz';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _waterGoalController,
                      label: 'Su (bardak)',
                      hint: '8',
                      prefixIcon: Icons.local_drink,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Gerekli';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number < 1 || number > 20) {
                          return 'Geçersiz';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Hedeflerinizi aktivite seviyenize ve kilo hedeflerinize göre ayarlayın.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save button
              AppButton(
                text: 'Kaydet',
                onPressed: _isSaving ? null : _saveProfile,
                isLoading: _isSaving,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
