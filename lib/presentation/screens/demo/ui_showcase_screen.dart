import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../widgets/loading/skeleton_loader.dart';
import '../../widgets/loading/lottie_loading.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/modals/custom_bottom_sheet.dart';
import '../../widgets/modals/custom_dialog.dart';
import '../../widgets/common/swipeable_item.dart';
import '../../widgets/animations/micro_interactions.dart';

/// UI Showcase screen demonstrating all new components
class UIShowcaseScreen extends StatefulWidget {
  const UIShowcaseScreen({super.key});

  @override
  State<UIShowcaseScreen> createState() => _UIShowcaseScreenState();
}

class _UIShowcaseScreenState extends State<UIShowcaseScreen> {
  bool _isLiked = false;
  bool _isLoading = false;
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎨 UI Showcase'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Loading States',
            [
              _buildCard(
                'Skeleton Loaders',
                Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: SkeletonLoader(
                        type: SkeletonType.foodCard,
                        itemCount: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildCard(
                'Loading Button',
                LoadingButton(
                  text: 'Save',
                  icon: Icons.save,
                  isLoading: _isLoading,
                  onPressed: () {
                    setState(() => _isLoading = true);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _isLoading = false);
                    });
                  },
                ),
              ),
            ],
          ),

          _buildSection(
            'Empty States',
            [
              _buildCard(
                'No Foods',
                SizedBox(
                  height: 300,
                  child: EmptyState(
                    type: EmptyStateType.noFoods,
                    actionText: 'Add Food',
                    onAction: () {},
                  ),
                ),
              ),
            ],
          ),

          _buildSection(
            'Modals & Dialogs',
            [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        CustomBottomSheet.showQuickAdd(
                          context: context,
                          onMealTypeSelected: (type) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Selected: $type')),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Bottom Sheet'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        CustomDialog.showSuccess(
                          context: context,
                          title: 'Başarılı!',
                          message: 'İşlem tamamlandı.',
                          autoDismiss: const Duration(seconds: 2),
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Success Dialog'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        CustomDialog.showError(
                          context: context,
                          title: 'Hata!',
                          message: 'Bir şeyler yanlış gitti.',
                        );
                      },
                      icon: const Icon(Icons.error_outline),
                      label: const Text('Error Dialog'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        CustomDialog.showConfirmation(
                          context: context,
                          title: 'Emin misiniz?',
                          message: 'Bu işlem geri alınamaz.',
                        );
                      },
                      icon: const Icon(Icons.warning_outlined),
                      label: const Text('Confirm Dialog'),
                    ),
                  ),
                ],
              ),
            ],
          ),

          _buildSection(
            'Swipe Gestures',
            [
              _buildCard(
                'Swipe to Delete',
                Column(
                  children: List.generate(3, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SwipeableItem(
                        onDelete: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Deleted item $index')),
                          );
                        },
                        onEdit: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Edit item $index')),
                          );
                        },
                        deleteConfirmMessage: 'Bu öğeyi silmek istediğinize emin misiniz?',
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.restaurant, color: AppColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Swipe Food Item ${index + 1}',
                                  style: AppTheme.bodyMedium,
                                ),
                              ),
                              const Icon(Icons.arrow_back, size: 16, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),

          _buildSection(
            'Micro Interactions',
            [
              _buildCard(
                'Animated Buttons',
                Column(
                  children: [
                    BouncyButton(
                      onPressed: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Bouncy Button',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        LikeButton(
                          isLiked: _isLiked,
                          size: 32,
                          onChanged: (liked) {
                            setState(() => _isLiked = liked);
                          },
                        ),
                        Column(
                          children: [
                            const Text('Counter:'),
                            AnimatedCounter(
                              value: _counter,
                              style: AppTheme.h2.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() => _counter += 10);
                              },
                              child: const Text('+10'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildCard(
                'Animated Progress',
                Column(
                  children: [
                    AnimatedProgressBar(
                      progress: 0.7,
                      color: AppColors.primary,
                      height: 12,
                    ),
                    const SizedBox(height: 12),
                    AnimatedProgressBar(
                      progress: 0.5,
                      color: AppColors.accent,
                      height: 8,
                    ),
                    const SizedBox(height: 12),
                    AnimatedProgressBar(
                      progress: 0.3,
                      color: AppColors.info,
                      height: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),

          _buildSection(
            'Animations',
            [
              _buildCard(
                'Fade In',
                FadeInWidget(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'This faded in!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildCard(
                'Slide In',
                SlideInWidget(
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'This slid in from bottom!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: AppTheme.h3.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildCard(String title, Widget content) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.h4.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }
}
