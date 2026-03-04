import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../services/recipe_service.dart';
import '../../services/storage_service.dart';
import '../../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _picker = ImagePicker();
  final _storageService = StorageService();
  final _userService = UserService();

  File? _imageFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().userModel;
    if (user != null) {
      _fullNameController.text = user.fullName;
      _bioController.text = user.bio ?? '';
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.userModel!;

    String? photoUrl = user.photoUrl;
    if (_imageFile != null) {
      photoUrl = await _storageService.uploadUserAvatar(_imageFile!);
    }

    final newName = _fullNameController.text.trim();

    await _userService.updateUser(user.uid, {
      'fullName': newName,
      'bio': _bioController.text.trim(),
      if (photoUrl != user.photoUrl) 'photoUrl': photoUrl,
    });

    if (newName != user.fullName) {
      await RecipeService().updateAuthorName(user.uid, newName);
      if (mounted) {
        context.read<RecipeProvider>().updateAuthorName(user.uid, newName);
      }
    }

    await authProvider.refreshUser();

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.read<AuthProvider>().userModel;
    final currentPhotoUrl = user?.photoUrl;

    return Scaffold(
      body: Column(
        children: [
          // Custom header
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade100),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                      color: AppTheme.textPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.editProfile,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    // Save button
                    TextButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              l10n.save,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Body
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Avatar
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primaryColor
                                    .withValues(alpha: 0.2),
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: _imageFile != null
                                  ? Image.file(_imageFile!, fit: BoxFit.cover)
                                  : (currentPhotoUrl != null &&
                                          currentPhotoUrl.isNotEmpty
                                      ? Image.network(currentPhotoUrl,
                                          fit: BoxFit.cover)
                                      : Container(
                                          color: AppTheme.primaryColor
                                              .withValues(alpha: 0.1),
                                          child: const Icon(
                                            Icons.person,
                                            size: 44,
                                            color: AppTheme.primaryColor,
                                          ),
                                        )),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Full Name field
                  Text(
                    l10n.fullName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      hintText: l10n.fullName,
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? l10n.nameRequired : null,
                  ),
                  const SizedBox(height: 20),
                  // Bio field
                  Text(
                    l10n.bio.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _bioController,
                    decoration: InputDecoration(
                      hintText: l10n.bio,
                      prefixIcon: Icon(
                        Icons.info_outline,
                        color: Colors.grey.shade400,
                      ),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
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
