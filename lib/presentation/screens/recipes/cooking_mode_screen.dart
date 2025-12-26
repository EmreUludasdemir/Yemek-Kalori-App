import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/recipe_model.dart';
import '../../../services/recipe_service.dart';
import '../../../config/supabase_config.dart';

class CookingModeScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const CookingModeScreen({super.key, required this.recipe});

  @override
  ConsumerState<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends ConsumerState<CookingModeScreen> {
  int _currentStep = 0;
  String? _sessionId;
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _startCookingSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startCookingSession() async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return;

    final sessionId = await RecipeService.startCookingSession(
      userId: userId,
      recipeId: widget.recipe.id,
    );

    if (mounted) {
      setState(() => _sessionId = sessionId);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = true;
      _secondsElapsed = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _secondsElapsed++);
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isTimerRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _secondsElapsed = 0;
      _isTimerRunning = false;
    });
  }

  void _nextStep() {
    if (_currentStep < widget.recipe.steps.length - 1) {
      setState(() {
        _currentStep++;
        _resetTimer();
      });

      if (_sessionId != null) {
        RecipeService.updateCookingStep(
          sessionId: _sessionId!,
          stepNumber: _currentStep + 1,
        );
      }
    } else {
      _completeRecipe();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _resetTimer();
      });

      if (_sessionId != null) {
        RecipeService.updateCookingStep(
          sessionId: _sessionId!,
          stepNumber: _currentStep + 1,
        );
      }
    }
  }

  Future<void> _completeRecipe() async {
    if (_sessionId != null) {
      await RecipeService.completeCookingSession(_sessionId!);
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: AppColors.success),
            SizedBox(width: 12),
            Text('Tebrikler!'),
          ],
        ),
        content: Text('${widget.recipe.name} tarifini tamamladınız!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close cooking mode
              Navigator.pop(context); // Close recipe detail
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentRecipeStep = widget.recipe.steps[_currentStep];
    final progress = (_currentStep + 1) / widget.recipe.steps.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.recipe.name} - Pişirme Modu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showExitDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
            minHeight: 8,
          ),

          // Step Counter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Adım ${_currentStep + 1} / ${widget.recipe.steps.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (currentRecipeStep.durationMinutes != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule, size: 16, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          '${currentRecipeStep.durationMinutes} dk önerilir',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const Divider(),

          // Current Step
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step Number Circle
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        '${currentRecipeStep.stepNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Instruction
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        currentRecipeStep.instruction,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tip
                  if (currentRecipeStep.tip != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb, color: AppColors.warning),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'İpucu',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warning,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentRecipeStep.tip!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Timer
                  Card(
                    color: AppColors.primary.withOpacity(0.05),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'Zamanlayıcı',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatTime(_secondsElapsed),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  _isTimerRunning ? Icons.pause : Icons.play_arrow,
                                ),
                                onPressed: _isTimerRunning ? _pauseTimer : _startTimer,
                                iconSize: 32,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.restart_alt),
                                onPressed: _resetTimer,
                                iconSize: 32,
                                color: AppColors.secondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Previous Button
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _previousStep,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Önceki'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                  if (_currentStep > 0) const SizedBox(width: 12),

                  // Next/Complete Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _nextStep,
                      icon: Icon(
                        _currentStep == widget.recipe.steps.length - 1
                            ? Icons.check
                            : Icons.arrow_forward,
                      ),
                      label: Text(
                        _currentStep == widget.recipe.steps.length - 1
                            ? 'Tamamla'
                            : 'Sonraki',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: _currentStep == widget.recipe.steps.length - 1
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pişirme Modundan Çık'),
        content: const Text('İlerlemeniz kaydedilecek. Çıkmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close cooking mode
            },
            child: const Text('Çık'),
          ),
        ],
      ),
    );
  }
}
