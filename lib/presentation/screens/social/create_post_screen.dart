import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../config/supabase_config.dart';
import '../../../services/social_service.dart';
import '../../../services/image_picker_service.dart';
import '../../../services/analytics_service.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final String? foodLogId; // Optional: link to a food log
  final String? initialContent;

  const CreatePostScreen({
    super.key,
    this.foodLogId,
    this.initialContent,
  });

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  late TextEditingController _contentController;
  bool _isPublic = true;
  bool _isPosting = false;
  File? _selectedImage;

  final int _maxLength = 2000;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.initialContent ?? '');
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImagePickerService.showImageSourcePicker(
      context: context,
      enableCrop: false,
      quality: 85,
    );

    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _createPost() async {
    final content = _contentController.text.trim();

    if (content.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gönderi içeriği veya fotoğraf ekleyin'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oturum açmanız gerekiyor'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      // Upload image if selected
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await SocialService.uploadPostImage(
          userId: userId,
          filePath: _selectedImage!.path,
        );
      }

      // Create post
      final post = await SocialService.createPost(
        userId: userId,
        content: content.isEmpty ? null : content,
        imageUrl: imageUrl,
        foodLogId: widget.foodLogId,
        isPublic: _isPublic,
      );

      setState(() => _isPosting = false);

      if (!mounted) return;

      if (post != null) {
        // Log analytics
        await AnalyticsService.logPostCreated(
          hasImage: imageUrl != null,
          contentLength: content.length,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gönderi paylaşıldı'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gönderi paylaşılamadı'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() => _isPosting = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Gönderi'),
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _createPost,
            child: _isPosting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Paylaş',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content TextField
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'Bugün ne yedin? Paylaş...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    minLines: 5,
                    maxLength: _maxLength,
                    autofocus: true,
                  ),

                  const SizedBox(height: 16),

                  // Image Preview (if selected)
                  if (_selectedImage != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(Icons.close,
                                  size: 16, color: Colors.white),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() => _selectedImage = null);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Info Card (if linked to food log)
                  if (widget.foodLogId != null)
                    Card(
                      color: AppColors.primary.withOpacity(0.1),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.restaurant, color: AppColors.primary),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Bu gönderi yemek kaydınıza bağlı',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Toolbar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SafeArea(
              child: Row(
                children: [
                  // Add Photo Button
                  IconButton(
                    icon: const Icon(Icons.photo_library_outlined),
                    onPressed: _pickImage,
                    color: AppColors.primary,
                    tooltip: 'Fotoğraf Ekle',
                  ),

                  const SizedBox(width: 8),

                  // Add Camera Button
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    onPressed: () {
                      // TODO: Open camera
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kamera yakında gelecek'),
                        ),
                      );
                    },
                    color: AppColors.primary,
                    tooltip: 'Fotoğraf Çek',
                  ),

                  const Spacer(),

                  // Public/Private Toggle
                  Row(
                    children: [
                      Icon(
                        _isPublic ? Icons.public : Icons.lock,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<bool>(
                          value: _isPublic,
                          items: const [
                            DropdownMenuItem(
                              value: true,
                              child: Text('Herkese Açık'),
                            ),
                            DropdownMenuItem(
                              value: false,
                              child: Text('Sadece Takipçiler'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _isPublic = value);
                            }
                          },
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
