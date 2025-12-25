import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../services/social_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  late TextEditingController _bioController;
  late bool _isPublic;

  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _fullNameController = TextEditingController(text: widget.user.fullName ?? '');
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _isPublic = widget.user.isPublic;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final success = await SocialService.updateUserProfile(
      userId: widget.user.id,
      username: _usernameController.text.trim(),
      fullName: _fullNameController.text.trim().isEmpty
          ? null
          : _fullNameController.text.trim(),
      bio: _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim(),
      isPublic: _isPublic,
    );

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil güncellendi'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil güncellenemedi'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _changeAvatar() async {
    // TODO: Implement image picker and upload
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fotoğraf değiştirme yakında eklenecek'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Kaydet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: widget.user.avatarUrl != null
                        ? CachedNetworkImageProvider(widget.user.avatarUrl!)
                        : null,
                    child: widget.user.avatarUrl == null
                        ? Text(
                            widget.user.username[0].toUpperCase(),
                            style: const TextStyle(
                                fontSize: 48, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt,
                            size: 18, color: Colors.white),
                        padding: EdgeInsets.zero,
                        onPressed: _changeAvatar,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Username
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Kullanıcı Adı',
                prefixIcon: Icon(Icons.alternate_email),
                border: OutlineInputBorder(),
                helperText: 'Sadece harf, rakam ve alt çizgi kullanabilirsiniz',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Kullanıcı adı gerekli';
                }
                if (value.trim().length < 3) {
                  return 'En az 3 karakter olmalı';
                }
                if (value.trim().length > 30) {
                  return 'En fazla 30 karakter olabilir';
                }
                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                  return 'Geçersiz karakterler';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Full Name
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null &&
                    value.trim().isNotEmpty &&
                    value.trim().length > 100) {
                  return 'En fazla 100 karakter olabilir';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Bio
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Biyografi',
                prefixIcon: Icon(Icons.info_outline),
                border: OutlineInputBorder(),
                hintText: 'Kendinizi tanıtın...',
              ),
              maxLines: 4,
              maxLength: 300,
              validator: (value) {
                if (value != null && value.trim().length > 300) {
                  return 'En fazla 300 karakter olabilir';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Privacy Setting
            Card(
              child: SwitchListTile(
                title: const Text('Hesabımı Herkese Açık Yap'),
                subtitle: const Text(
                  'Kapalı hesaplar sadece takipçileri tarafından görülebilir',
                ),
                value: _isPublic,
                onChanged: (value) {
                  setState(() => _isPublic = value);
                },
                activeColor: AppColors.primary,
              ),
            ),

            const SizedBox(height: 32),

            // Info Cards
            Card(
              color: AppColors.info.withOpacity(0.1),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Profil değişiklikleri birkaç dakika içinde yansır',
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
    );
  }
}
