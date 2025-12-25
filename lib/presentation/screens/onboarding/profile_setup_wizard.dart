import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';

/// Profile setup wizard for new users
class ProfileSetupWizard extends StatefulWidget {
  const ProfileSetupWizard({super.key});

  @override
  State<ProfileSetupWizard> createState() => _ProfileSetupWizardState();
}

class _ProfileSetupWizardState extends State<ProfileSetupWizard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Profile data
  String? _selectedGender;
  double? _age;
  double? _height;
  double? _weight;
  String? _activityLevel;
  String? _goal;
  double? _targetCalories;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Oluştur'),
        actions: [
          if (_currentPage < 5)
            TextButton(
              onPressed: () => _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              child: const Text('İleri'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress Indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: 6,
              effect: const WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: AppColors.primary,
                dotColor: AppColors.divider,
              ),
              onDotClicked: (index) => _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
            ),
          ),

          // Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildGenderPage(),
                _buildAgePage(),
                _buildHeightPage(),
                _buildWeightPage(),
                _buildActivityPage(),
                _buildGoalPage(),
              ],
            ),
          ),

          // Navigation Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text('Geri'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _canProceed() ? _handleNext : null,
                    child: Text(_currentPage == 5 ? 'Tamamla' : 'Devam'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderPage() {
    return _WizardPage(
      title: 'Cinsiyetin nedir?',
      icon: Icons.person_outline,
      child: Column(
        children: [
          _buildGenderOption('Erkek', Icons.male, AppColors.info),
          const SizedBox(height: 16),
          _buildGenderOption('Kadın', Icons.female, AppColors.fat),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String gender, IconData icon, Color color) {
    final isSelected = _selectedGender == gender;
    return InkWell(
      onTap: () => setState(() => _selectedGender = gender),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 48, color: isSelected ? color : AppColors.textSecondary),
            const SizedBox(width: 16),
            Text(
              gender,
              style: AppTheme.h3.copyWith(
                color: isSelected ? color : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgePage() {
    return _WizardPage(
      title: 'Yaşın kaç?',
      icon: Icons.cake_outlined,
      child: Column(
        children: [
          Text(
            _age != null ? '${_age!.toInt()} yaş' : '25 yaş',
            style: AppTheme.h1.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Slider(
            value: _age ?? 25,
            min: 15,
            max: 80,
            divisions: 65,
            activeColor: AppColors.primary,
            onChanged: (value) => setState(() => _age = value),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('15', style: AppTheme.bodyMedium),
              Text('80', style: AppTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeightPage() {
    return _WizardPage(
      title: 'Boyun kaç cm?',
      icon: Icons.height,
      child: Column(
        children: [
          Text(
            _height != null ? '${_height!.toInt()} cm' : '170 cm',
            style: AppTheme.h1.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Slider(
            value: _height ?? 170,
            min: 140,
            max: 220,
            divisions: 80,
            activeColor: AppColors.primary,
            onChanged: (value) => setState(() => _height = value),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('140 cm', style: AppTheme.bodyMedium),
              Text('220 cm', style: AppTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightPage() {
    return _WizardPage(
      title: 'Kilon kaç kg?',
      icon: Icons.monitor_weight_outlined,
      child: Column(
        children: [
          Text(
            _weight != null ? '${_weight!.toInt()} kg' : '70 kg',
            style: AppTheme.h1.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Slider(
            value: _weight ?? 70,
            min: 40,
            max: 150,
            divisions: 110,
            activeColor: AppColors.primary,
            onChanged: (value) => setState(() => _weight = value),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('40 kg', style: AppTheme.bodyMedium),
              Text('150 kg', style: AppTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityPage() {
    return _WizardPage(
      title: 'Aktivite seviyen?',
      icon: Icons.directions_run,
      child: Column(
        children: [
          _buildActivityOption(
            'Hareketsiz',
            'Çok az veya hiç egzersiz',
            'sedentary',
          ),
          const SizedBox(height: 12),
          _buildActivityOption(
            'Az Aktif',
            'Haftada 1-3 gün hafif egzersiz',
            'light',
          ),
          const SizedBox(height: 12),
          _buildActivityOption(
            'Orta Aktif',
            'Haftada 3-5 gün orta egzersiz',
            'moderate',
          ),
          const SizedBox(height: 12),
          _buildActivityOption(
            'Çok Aktif',
            'Haftada 6-7 gün yoğun egzersiz',
            'very_active',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityOption(String title, String description, String level) {
    final isSelected = _activityLevel == level;
    return InkWell(
      onTap: () => setState(() => _activityLevel = level),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.h4.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: AppTheme.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalPage() {
    return _WizardPage(
      title: 'Hedefin ne?',
      icon: Icons.flag_outlined,
      child: Column(
        children: [
          _buildGoalOption(
            'Kilo Ver',
            '🔥',
            'lose_weight',
          ),
          const SizedBox(height: 12),
          _buildGoalOption(
            'Kilonu Koru',
            '⚖️',
            'maintain_weight',
          ),
          const SizedBox(height: 12),
          _buildGoalOption(
            'Kilo Al',
            '💪',
            'gain_weight',
          ),
          const SizedBox(height: 24),
          if (_goal != null) ...[
            Text(
              'Tahmini Günlük Kalori:',
              style: AppTheme.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_calculateCalories().toInt()} kcal',
              style: AppTheme.h1.copyWith(color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalOption(String title, String emoji, String goal) {
    final isSelected = _goal == goal;
    return InkWell(
      onTap: () => setState(() {
        _goal = goal;
        _targetCalories = _calculateCalories();
      }),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Text(
              title,
              style: AppTheme.h4.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _selectedGender != null;
      case 1:
        return _age != null;
      case 2:
        return _height != null;
      case 3:
        return _weight != null;
      case 4:
        return _activityLevel != null;
      case 5:
        return _goal != null;
      default:
        return false;
    }
  }

  void _handleNext() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeSetup();
    }
  }

  double _calculateCalories() {
    if (_weight == null || _height == null || _age == null) return 2000;

    // Mifflin-St Jeor Equation
    double bmr;
    if (_selectedGender == 'Erkek') {
      bmr = (10 * _weight!) + (6.25 * _height!) - (5 * _age!) + 5;
    } else {
      bmr = (10 * _weight!) + (6.25 * _height!) - (5 * _age!) - 161;
    }

    // Activity multiplier
    double multiplier = 1.2;
    switch (_activityLevel) {
      case 'sedentary':
        multiplier = 1.2;
        break;
      case 'light':
        multiplier = 1.375;
        break;
      case 'moderate':
        multiplier = 1.55;
        break;
      case 'very_active':
        multiplier = 1.725;
        break;
    }

    double tdee = bmr * multiplier;

    // Goal adjustment
    switch (_goal) {
      case 'lose_weight':
        return tdee - 500; // 500 calorie deficit
      case 'maintain_weight':
        return tdee;
      case 'gain_weight':
        return tdee + 500; // 500 calorie surplus
      default:
        return tdee;
    }
  }

  Future<void> _completeSetup() async {
    // Save profile data
    // TODO: Save to Supabase

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}

class _WizardPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _WizardPage({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(icon, size: 64, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTheme.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }
}
