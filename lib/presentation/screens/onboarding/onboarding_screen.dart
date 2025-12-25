import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Onboarding screen for first-time users
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _introKey = GlobalKey<IntroductionScreenState>();

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      key: _introKey,
      globalBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      pages: [
        _buildWelcomePage(),
        _buildTrackCaloriesPage(),
        _buildAIRecognitionPage(),
        _buildStatsPage(),
        _buildAchievementsPage(),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: Text(
        'Atla',
        style: AppTheme.button.copyWith(color: AppColors.textSecondary),
      ),
      next: const Icon(Icons.arrow_forward, color: AppColors.primary),
      done: Text(
        'Başla',
        style: AppTheme.button.copyWith(color: AppColors.primary),
      ),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: AppColors.primary,
        color: AppColors.divider,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
      animationDuration: 300,
      curve: Curves.easeInOut,
    );
  }

  PageViewModel _buildWelcomePage() {
    return PageViewModel(
      title: "TürkKalori'ye Hoş Geldin! 🎉",
      body:
          "Türk yemekleri için özel olarak tasarlanmış kalori takip uygulaması",
      image: _buildImage('assets/images/onboarding_welcome.png', fallbackIcon: Icons.waving_hand),
      decoration: _getPageDecoration(),
    );
  }

  PageViewModel _buildTrackCaloriesPage() {
    return PageViewModel(
      title: "Günlük Kalori Takibi 📊",
      body:
          "Yediğin her öğünü kaydet, kalori ve makro besinleri takip et, hedeflerine ulaş",
      image: _buildImage('assets/images/onboarding_track.png', fallbackIcon: Icons.restaurant),
      decoration: _getPageDecoration(),
    );
  }

  PageViewModel _buildAIRecognitionPage() {
    return PageViewModel(
      title: "AI ile Yemek Tanıma 📸",
      body:
          "Yemeğin fotoğrafını çek, yapay zeka otomatik kalori hesaplasın. Türk yemekleri için özel eğitilmiş!",
      image: _buildImage('assets/images/onboarding_ai.png', fallbackIcon: Icons.camera_alt),
      decoration: _getPageDecoration(),
    );
  }

  PageViewModel _buildStatsPage() {
    return PageViewModel(
      title: "Detaylı İstatistikler 📈",
      body:
          "Haftalık ve aylık ilerleme grafiklerini gör, gelişimini takip et",
      image: _buildImage('assets/images/onboarding_stats.png', fallbackIcon: Icons.analytics),
      decoration: _getPageDecoration(),
    );
  }

  PageViewModel _buildAchievementsPage() {
    return PageViewModel(
      title: "Başarımlar Kazan 🏆",
      body:
          "Hedeflerine ulaştıkça rozetler kazan, motivasyonunu yüksek tut!",
      image: _buildImage('assets/images/onboarding_achievements.png', fallbackIcon: Icons.emoji_events),
      decoration: _getPageDecoration(),
    );
  }

  Widget _buildImage(String assetPath, {required IconData fallbackIcon}) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          fallbackIcon,
          size: 120,
          color: AppColors.primary,
        ),
      ),
    );
  }

  PageDecoration _getPageDecoration() {
    return PageDecoration(
      titleTextStyle: AppTheme.h2.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      bodyTextStyle: AppTheme.bodyLarge.copyWith(
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      imagePadding: const EdgeInsets.only(top: 40, bottom: 40),
      pageColor: Theme.of(context).scaffoldBackgroundColor,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 24),
      titlePadding: const EdgeInsets.only(top: 16, bottom: 16),
      contentMargin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Future<void> _onIntroEnd(BuildContext context) async {
    // Mark onboarding as completed
    final box = await Hive.openBox('app_settings');
    await box.put('onboarding_completed', true);

    if (context.mounted) {
      // Navigate to profile setup or login
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}

/// Check if onboarding should be shown
class OnboardingHelper {
  static Future<bool> shouldShowOnboarding() async {
    final box = await Hive.openBox('app_settings');
    return !(box.get('onboarding_completed', defaultValue: false) as bool);
  }

  static Future<void> resetOnboarding() async {
    final box = await Hive.openBox('app_settings');
    await box.delete('onboarding_completed');
  }
}
