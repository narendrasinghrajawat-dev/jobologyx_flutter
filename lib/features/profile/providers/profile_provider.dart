import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/api_exception.dart';
import '../../auth/providers/auth_provider.dart';
import '../repositories/profile_repository.dart';

class ProfileActionState {
  const ProfileActionState({
    this.isSaving = false,
    this.isUploadingImage = false,
    this.isUploadingResume = false,
    this.isUploadingLogo = false,
    this.errorMessage,
    this.successMessage,
  });

  final bool isSaving;
  final bool isUploadingImage;
  final bool isUploadingResume;
  final bool isUploadingLogo;
  final String? errorMessage;
  final String? successMessage;

  ProfileActionState copyWith({
    bool? isSaving,
    bool? isUploadingImage,
    bool? isUploadingResume,
    bool? isUploadingLogo,
    String? errorMessage,
    String? successMessage,
  }) {
    return ProfileActionState(
      isSaving: isSaving ?? false,
      isUploadingImage: isUploadingImage ?? false,
      isUploadingResume: isUploadingResume ?? false,
      isUploadingLogo: isUploadingLogo ?? false,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

/// Orchestrates profile saves and image/resume/logo uploads. Deliberately
/// does NOT cache its own copy of `UserModel` — `AuthNotifier` stays the one
/// source of truth for "who is the current user"; this notifier calls
/// `authProvider.notifier.updateUser(...)` after each successful mutation
/// so the rest of the app (bottom nav avatar, dashboards, etc.) sees the
/// change immediately without a second, possibly-stale copy of the user.
class ProfileNotifier extends Notifier<ProfileActionState> {
  @override
  ProfileActionState build() => const ProfileActionState();

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    state = state.copyWith(isSaving: true);
    try {
      final user = await ref.read(profileRepositoryProvider).updateMe(updates);
      ref.read(authProvider.notifier).updateUser(user);
      state = state.copyWith(successMessage: "Profile updated");
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    }
  }

  Future<bool> uploadProfileImage({required List<int> bytes, required String filename}) async {
    state = state.copyWith(isUploadingImage: true);
    try {
      final user = await ref.read(profileRepositoryProvider).uploadProfileImage(bytes: bytes, filename: filename);
      ref.read(authProvider.notifier).updateUser(user);
      state = state.copyWith(successMessage: "Profile image updated");
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    }
  }

  Future<bool> uploadResume({required List<int> bytes, required String filename}) async {
    state = state.copyWith(isUploadingResume: true);
    try {
      final user = await ref.read(profileRepositoryProvider).uploadResume(bytes: bytes, filename: filename);
      ref.read(authProvider.notifier).updateUser(user);
      state = state.copyWith(successMessage: "Resume uploaded");
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    }
  }

  Future<bool> uploadCompanyLogo({required List<int> bytes, required String filename}) async {
    state = state.copyWith(isUploadingLogo: true);
    try {
      final user = await ref.read(profileRepositoryProvider).uploadCompanyLogo(bytes: bytes, filename: filename);
      ref.read(authProvider.notifier).updateUser(user);
      state = state.copyWith(successMessage: "Company logo updated");
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    }
  }
}

final profileActionProvider = NotifierProvider<ProfileNotifier, ProfileActionState>(ProfileNotifier.new);
