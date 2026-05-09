import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _picker = ImagePicker();
  final _storageService = StorageService();
  final _userService = UserService();

  File? _imageFile;
  bool _isSaving = false;
  DateTime? _birthDate;
  String? _gender;
  String? _activityLevel;
  String? _cookingSkillLevel;

  static const _genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];
  static const _activityOptions = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
    'Extra Active',
  ];
  static const _skillOptions = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().userModel;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _phoneController.text = user.phoneNumber ?? '';
      _bioController.text = user.bio ?? '';
      _birthDate = user.birthDate;
      _gender = user.gender;
      _heightController.text =
          user.heightCm != null ? user.heightCm.toString() : '';
      _weightController.text =
          user.weightKg != null ? user.weightKg.toString() : '';
      _activityLevel = user.activityLevel;
      _cookingSkillLevel = user.cookingSkillLevel;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 10, now.month, now.day),
      helpText: AppLocalizations.of(context)!.selectDateOfBirth,
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.userModel!;

      String? photoUrl = user.photoUrl;
      if (_imageFile != null) {
        photoUrl = await _storageService.uploadUserAvatar(_imageFile!, user.uid);
      }

      final newFirstName = _firstNameController.text.trim();
      final newLastName = _lastNameController.text.trim();
      final newFullName = '$newFirstName $newLastName'.trim();

      final updates = <String, dynamic>{
        'firstName': newFirstName,
        'lastName': newLastName,
        'fullName': newFullName,
        'fullNameLowercase': newFullName.toLowerCase(),
        'firstNameLowercase': newFirstName.toLowerCase(),
        'lastNameLowercase': newLastName.toLowerCase(),
        'phoneNumber': _phoneController.text.trim(),
        'bio': _bioController.text.trim(),
        'birthDate': _birthDate?.toIso8601String(),
        'gender': _gender,
        'heightCm': double.tryParse(_heightController.text),
        'weightKg': double.tryParse(_weightController.text),
        'activityLevel': _activityLevel,
        'cookingSkillLevel': _cookingSkillLevel,
        'photoUrl': photoUrl,
      };

      await _userService.updateUser(user.uid, updates);

      await RecipeService().updateAuthorName(user.uid, newFullName);
      if (mounted) {
        context.read<RecipeProvider>().updateAuthorName(user.uid, newFullName);
      }

      await authProvider.refreshUser();

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.error)),
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
    final l10n = AppLocalizations.of(context)!;
    final user = context.read<AuthProvider>().userModel;
    final currentPhotoUrl = user?.photoUrl;

    return Scaffold(
      body: Column(
        children: [
          // Custom header
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceOf(context),
              border: Border(
                bottom:
                    BorderSide(color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
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
                      color: AppTheme.textPrimaryOf(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.editProfile,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
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
                            width: 104,
                            height: 104,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(3),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceOf(context),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(2),
                              child: ClipOval(
                                child: _imageFile != null
                                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                                    : (currentPhotoUrl != null &&
                                            currentPhotoUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: currentPhotoUrl,
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
                                  color: AppTheme.surfaceOf(context),
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

                  // ── Personal Info Section ──
                  _sectionLabel(l10n.personalInfo.toUpperCase(), context),
                  const SizedBox(height: 12),

                  // Username (read-only)
                  if (user?.username != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextFormField(
                        initialValue: '@${user!.username}',
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: l10n.username,
                          prefixIcon: const Icon(Icons.alternate_email),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.neutralLightOf(context),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // First & Last Name
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: l10n.firstName,
                            prefixIcon: const Icon(Icons.person_outlined),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: l10n.lastName,
                            prefixIcon: const Icon(Icons.person_outlined),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]')),
                    ],
                    decoration: InputDecoration(
                      labelText: l10n.phoneNumber,
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Birth Date
                  GestureDetector(
                    onTap: _pickBirthDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.dateOfBirth,
                        prefixIcon: const Icon(Icons.cake_outlined),
                        suffixIcon: const Icon(Icons.calendar_today_outlined,
                            size: 20),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _birthDate == null
                                ? AppTheme.neutralLightOf(context)
                                : AppTheme.primaryColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppTheme.primaryColor, width: 2),
                        ),
                      ),
                      child: Text(
                        _birthDate != null
                            ? '${_birthDate!.day.toString().padLeft(2, '0')}/'
                                '${_birthDate!.month.toString().padLeft(2, '0')}/'
                                '${_birthDate!.year}'
                            : l10n.selectDateOfBirth,
                        style: TextStyle(
                          color:
                              _birthDate != null ? null : AppTheme.textTertiaryOf(context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bio
                  TextFormField(
                    controller: _bioController,
                    decoration: InputDecoration(
                      labelText: l10n.bio,
                      prefixIcon: const Icon(Icons.info_outline),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 24),
                  Divider(color: AppTheme.neutralLightOf(context)),
                  const SizedBox(height: 24),

                  // ── Physical Info Section ──
                  _sectionLabel(l10n.physicalInfo.toUpperCase(), context),
                  const SizedBox(height: 12),

                  // Gender
                  DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: InputDecoration(
                      labelText: l10n.gender,
                      prefixIcon: const Icon(Icons.wc_outlined),
                    ),
                    items: _genderOptions
                        .map((g) => DropdownMenuItem(value: g, child: Text(_localizeGender(g, l10n))))
                        .toList(),
                    onChanged: (v) => setState(() => _gender = v),
                  ),
                  const SizedBox(height: 16),

                  // Height & Weight
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _heightController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d{0,3}\.?\d{0,1}')),
                          ],
                          decoration: InputDecoration(
                            labelText: l10n.height,
                            prefixIcon: const Icon(Icons.height),
                            suffixText: 'cm',
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final v = double.tryParse(value);
                              if (v == null || v < 50 || v > 300) {
                                return l10n.invalid;
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d{0,3}\.?\d{0,1}')),
                          ],
                          decoration: InputDecoration(
                            labelText: l10n.weight,
                            prefixIcon: const Icon(Icons.monitor_weight_outlined),
                            suffixText: 'kg',
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final v = double.tryParse(value);
                              if (v == null || v < 20 || v > 500) {
                                return l10n.invalid;
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Activity Level
                  DropdownButtonFormField<String>(
                    initialValue: _activityLevel,
                    decoration: InputDecoration(
                      labelText: l10n.activityLevel,
                      prefixIcon: const Icon(Icons.directions_run_outlined),
                    ),
                    items: _activityOptions
                        .map(
                            (a) => DropdownMenuItem(value: a, child: Text(_localizeActivity(a, l10n))))
                        .toList(),
                    onChanged: (v) => setState(() => _activityLevel = v),
                  ),
                  const SizedBox(height: 16),

                  // Cooking Skill Level
                  DropdownButtonFormField<String>(
                    initialValue: _cookingSkillLevel,
                    decoration: InputDecoration(
                      labelText: l10n.cookingSkillLevel,
                      prefixIcon: const Icon(Icons.restaurant_outlined),
                    ),
                    items: _skillOptions
                        .map(
                            (s) => DropdownMenuItem(value: s, child: Text(_localizeSkill(s, l10n))))
                        .toList(),
                    onChanged: (v) => setState(() => _cookingSkillLevel = v),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _localizeGender(String gender, AppLocalizations l10n) {
    switch (gender) {
      case 'Male': return l10n.genderMale;
      case 'Female': return l10n.genderFemale;
      case 'Other': return l10n.genderOther;
      case 'Prefer not to say': return l10n.genderPreferNotToSay;
      default: return gender;
    }
  }

  String _localizeActivity(String activity, AppLocalizations l10n) {
    switch (activity) {
      case 'Sedentary': return l10n.activitySedentary;
      case 'Lightly Active': return l10n.activityLightlyActive;
      case 'Moderately Active': return l10n.activityModeratelyActive;
      case 'Very Active': return l10n.activityVeryActive;
      case 'Extra Active': return l10n.activityExtraActive;
      default: return activity;
    }
  }

  String _localizeSkill(String skill, AppLocalizations l10n) {
    switch (skill) {
      case 'Beginner': return l10n.skillBeginner;
      case 'Intermediate': return l10n.skillIntermediate;
      case 'Advanced': return l10n.skillAdvanced;
      default: return skill;
    }
  }

  Widget _sectionLabel(String text, BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppTheme.textTertiaryOf(context),
        letterSpacing: 0.8,
      ),
    );
  }
}
