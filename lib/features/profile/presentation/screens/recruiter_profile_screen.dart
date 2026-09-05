import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/models/user_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

const int _maxImageBytes = 2 * 1024 * 1024;

class RecruiterProfileScreen extends ConsumerStatefulWidget {
  const RecruiterProfileScreen({super.key});

  @override
  ConsumerState<RecruiterProfileScreen> createState() => _RecruiterProfileScreenState();
}

class _RecruiterProfileScreenState extends ConsumerState<RecruiterProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: _user.name);
  late final _phoneController = TextEditingController(text: _user.phone ?? "");
  late final _locationController = TextEditingController(text: _user.location);
  late final _bioController = TextEditingController(text: _user.bio);
  late final _companyNameController = TextEditingController(text: _user.companyName);
  late final _companyWebsiteController = TextEditingController(text: _user.companyWebsite);

  UserModel get _user => ref.read(authProvider).user!;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _companyNameController.dispose();
    _companyWebsiteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(profileActionProvider.notifier).updateProfile({
      "name": _nameController.text.trim(),
      "phone": _phoneController.text.trim(),
      "location": _locationController.text.trim(),
      "bio": _bioController.text.trim(),
      "companyName": _companyNameController.text.trim(),
      "companyWebsite": _companyWebsiteController.text.trim(),
    });
  }

  Future<void> _pickProfileImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (bytes.length > _maxImageBytes) {
      _showMessage("Image must be under 2MB");
      return;
    }
    await ref.read(profileActionProvider.notifier).uploadProfileImage(bytes: bytes, filename: file.name);
  }

  Future<void> _pickCompanyLogo() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (bytes.length > _maxImageBytes) {
      _showMessage("Logo must be under 2MB");
      return;
    }
    await ref.read(profileActionProvider.notifier).uploadCompanyLogo(bytes: bytes, filename: file.name);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log out?"),
        content: const Text("You'll need to log in again to continue."),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("Log out")),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).user!;
    final actionState = ref.watch(profileActionProvider);

    ref.listen(profileActionProvider, (previous, next) {
      if (next.successMessage != null && next.successMessage != previous?.successMessage) {
        _showMessage(next.successMessage!);
      }
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        _showMessage(next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3, items: RecruiterNavItems.items),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Center(
            child: Stack(
              children: [
                AppAvatar(imageUrl: user.profileImage, fallbackText: user.name, radius: 48),
                if (actionState.isUploadingImage)
                  const Positioned.fill(child: Center(child: AppLoader()))
                else
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickProfileImage,
                      borderRadius: BorderRadius.circular(16),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: theme.colorScheme.primary,
                        child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(child: Text(user.email, style: theme.textTheme.bodyMedium)),
          const SizedBox(height: AppSpacing.lg),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(label: "Full Name", controller: _nameController, validator: Validators.name),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: "Phone",
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(label: "Location", controller: _locationController, prefixIcon: Icons.location_on_outlined),
                const SizedBox(height: AppSpacing.md),
                AppTextField(label: "Bio", controller: _bioController, maxLines: 4),
                const SizedBox(height: AppSpacing.lg),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),
                Text("Company", style: theme.textTheme.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        AppAvatar(
                          imageUrl: user.companyLogo,
                          fallbackText: user.companyName,
                          radius: 28,
                          icon: Icons.business_rounded,
                        ),
                        if (actionState.isUploadingLogo)
                          const Positioned.fill(child: Center(child: AppLoader()))
                        else
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _pickCompanyLogo,
                              borderRadius: BorderRadius.circular(12),
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: theme.colorScheme.primary,
                                child: const Icon(Icons.camera_alt_rounded, size: 12, color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(label: "Company Name", controller: _companyNameController),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: "Company Website",
                            controller: _companyWebsiteController,
                            keyboardType: TextInputType.url,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(label: "Save Changes", isLoading: actionState.isSaving, onPressed: _save),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
            title: Text("Log Out", style: TextStyle(color: theme.colorScheme.error)),
            onTap: _confirmLogout,
          ),
        ],
      ),
    );
  }
}
