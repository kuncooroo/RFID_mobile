import '../../settings/models/settings.dart';
import '../models/profile_snapshot.dart';

enum ProfileStatus { initial, loading, refreshing, ready, failure }

class ProfileState {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.snapshot,
    this.errorMessage,
  });

  const ProfileState.initial() : this();

  final ProfileStatus status;
  final ProfileSnapshot? snapshot;
  final String? errorMessage;

  bool get isLoading =>
      status == ProfileStatus.initial || status == ProfileStatus.loading;

  bool get hasFailed => status == ProfileStatus.failure;

  bool get isReady =>
      status == ProfileStatus.ready || status == ProfileStatus.refreshing;

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileSnapshot? snapshot,
    String? errorMessage,
    bool clearError = false,
    bool clearSnapshot = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      snapshot: clearSnapshot ? null : (snapshot ?? this.snapshot),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

enum ProfileFormStatus { idle, submitting, success, failure }

class EditProfileState {
  const EditProfileState({
    this.status = ProfileFormStatus.idle,
    this.errorMessage,
  });

  final ProfileFormStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == ProfileFormStatus.submitting;

  EditProfileState copyWith({
    ProfileFormStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ChangePasswordState {
  const ChangePasswordState({
    this.status = ProfileFormStatus.idle,
    this.errorMessage,
  });

  final ProfileFormStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == ProfileFormStatus.submitting;

  ChangePasswordState copyWith({
    ProfileFormStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChangePasswordState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SettingsUiState {
  const SettingsUiState({
    this.status = ProfileStatus.initial,
    this.settings = const Settings(),
    this.languages = const [],
    this.errorMessage,
  });

  final ProfileStatus status;
  final Settings settings;
  final List<LanguageOption> languages;
  final String? errorMessage;

  bool get isLoading =>
      status == ProfileStatus.initial || status == ProfileStatus.loading;

  SettingsUiState copyWith({
    ProfileStatus? status,
    Settings? settings,
    List<LanguageOption>? languages,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SettingsUiState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      languages: languages ?? this.languages,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
