import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../../settings/models/settings.dart';
import '../repository/mock_profile_repository.dart';
import '../repository/profile_repository.dart';
import '../state/profile_state.dart';
import '../../../src/network/api_client.dart';
import '../repository/remote_profile_repository.dart';

/// Pass `--dart-define=USE_MOCK_PROFILE=true` to force the mock repository.
const bool kUseMockProfileRepository = bool.fromEnvironment(
  'USE_MOCK_PROFILE',
  defaultValue: false,
);

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  if (kUseMockProfileRepository) {
    return MockProfileRepository.shared;
  }

  return RemoteProfileRepository(
    api: ref.watch(apiClientProvider),
  );
});

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);

final editProfileControllerProvider =
    NotifierProvider<EditProfileController, EditProfileState>(
      EditProfileController.new,
    );

final changePasswordControllerProvider =
    NotifierProvider<ChangePasswordController, ChangePasswordState>(
      ChangePasswordController.new,
    );

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsUiState>(
      SettingsController.new,
    );

class ProfileController extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState.initial();

  Future<void> load() async {
    if (state.status == ProfileStatus.loading) return;
    state = state.copyWith(status: ProfileStatus.loading, clearError: true);
    await _fetch(status: ProfileStatus.ready);
  }

  Future<void> refresh() async {
    state = state.copyWith(status: ProfileStatus.refreshing, clearError: true);
    await _fetch(status: ProfileStatus.ready);
  }

  Future<void> _fetch({required ProfileStatus status}) async {
    try {
      final snapshot = await ref.read(profileRepositoryProvider).fetchProfile();
      state = state.copyWith(status: status, snapshot: snapshot);
    } catch (error) {
      state = state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }
}

class EditProfileController extends Notifier<EditProfileState> {
  @override
  EditProfileState build() => const EditProfileState();

  Future<bool> submit({
    required String displayName,
    required String email,
    String? phone,
    String? avatarUrl,
  }) async {
    state = state.copyWith(
      status: ProfileFormStatus.submitting,
      clearError: true,
    );
    try {
      await ref.read(profileRepositoryProvider).updateProfile(
            displayName: displayName,
            email: email,
            phone: phone,
            avatarUrl: avatarUrl,
          );
      await ref.read(profileControllerProvider.notifier).refresh();
      ref.invalidate(currentUserProvider);
      state = state.copyWith(status: ProfileFormStatus.success);
      return true;
    } catch (error) {
      state = state.copyWith(
        status: ProfileFormStatus.failure,
        errorMessage: error.toString(),
      );
      return false;
    }
  }

  void reset() {
    state = const EditProfileState();
  }
}

class ChangePasswordController extends Notifier<ChangePasswordState> {
  @override
  ChangePasswordState build() => const ChangePasswordState();

  Future<bool> submit({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(
      status: ProfileFormStatus.submitting,
      clearError: true,
    );
    try {
      await ref
          .read(profileRepositoryProvider)
          .changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
      state = state.copyWith(status: ProfileFormStatus.success);
      return true;
    } catch (error) {
      state = state.copyWith(
        status: ProfileFormStatus.failure,
        errorMessage: error.toString(),
      );
      return false;
    }
  }

  void reset() {
    state = const ChangePasswordState();
  }
}

class SettingsController extends Notifier<SettingsUiState> {
  @override
  SettingsUiState build() => const SettingsUiState();

  Future<void> load() async {
    state = state.copyWith(status: ProfileStatus.loading, clearError: true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      final settings = await repo.fetchSettings();
      final languages = await repo.fetchLanguages();
      state = state.copyWith(
        status: ProfileStatus.ready,
        settings: settings,
        languages: languages,
      );
    } catch (error) {
      state = state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<bool> updateSettings(Settings settings) async {
    final previous = state.settings;
    state = state.copyWith(settings: settings, clearError: true);
    try {
      final saved = await ref
          .read(profileRepositoryProvider)
          .updateSettings(settings);
      final languages = await ref
          .read(profileRepositoryProvider)
          .fetchLanguages();
      state = state.copyWith(
        status: ProfileStatus.ready,
        settings: saved,
        languages: languages,
        clearError: true,
      );
      await ref.read(profileControllerProvider.notifier).refresh();
      return true;
    } catch (error) {
      state = state.copyWith(
        settings: previous,
        status: ProfileStatus.failure,
        errorMessage: error.toString(),
      );
      return false;
    }
  }

  Future<bool> selectLanguage(LanguageOption option) async {
    final previous = state.settings;
    final previousLanguages = state.languages;
    final optimistic = state.settings.copyWith(
      languageCode: option.code,
      languageLabel: option.label,
    );
    state = state.copyWith(
      settings: optimistic,
      languages: state.languages
          .map(
            (item) => item.copyWith(isSelected: item.code == option.code),
          )
          .toList(),
      clearError: true,
    );
    try {
      final saved = await ref
          .read(profileRepositoryProvider)
          .updateSettings(optimistic);
      final languages = await ref
          .read(profileRepositoryProvider)
          .fetchLanguages();
      state = state.copyWith(
        status: ProfileStatus.ready,
        settings: saved,
        languages: languages,
        clearError: true,
      );
      await ref.read(profileControllerProvider.notifier).refresh();
      return true;
    } catch (error) {
      state = state.copyWith(
        settings: previous,
        languages: previousLanguages,
        status: ProfileStatus.failure,
        errorMessage: error.toString(),
      );
      return false;
    }
  }

  Future<void> togglePreference({
    required Settings Function(Settings current) updater,
  }) async {
    await updateSettings(updater(state.settings));
  }
}
