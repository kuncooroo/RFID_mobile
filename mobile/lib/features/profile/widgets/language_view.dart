import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../settings/models/settings.dart';

/// Language picker body (Figma Language settings).
class LanguageView extends StatelessWidget {
  const LanguageView({
    super.key,
    required this.languages,
    required this.selectedCode,
    required this.onSelect,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.onRetry,
    this.pendingCode,
  });

  final List<LanguageOption> languages;
  final String selectedCode;
  final ValueChanged<LanguageOption> onSelect;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String? pendingCode;

  @override
  Widget build(BuildContext context) {
    if (isLoading && languages.isEmpty) {
      return const AppLoading.page(message: 'Loading languages…');
    }

    if (errorMessage != null && languages.isEmpty) {
      return AppErrorState(
        title: 'Could not load languages',
        message: errorMessage!,
        onRetry: onRetry,
      );
    }

    if (languages.isEmpty) {
      return const AppEmptyState(
        title: 'No languages',
        message: 'Language options are not available right now.',
        icon: Icons.language_rounded,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.xl,
        AppSpacing.screenHorizontal,
        AppSpacing.xxxl,
      ),
      children: [
        Text(
          'Choose your preferred language for the Kutuku app.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('AVAILABLE LANGUAGES', style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppSpacing.md),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.settingsTile,
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              for (var i = 0; i < languages.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: AppSpacing.lg,
                    endIndent: AppSpacing.lg,
                    color: AppColors.divider,
                  ),
                _LanguageTile(
                  option: languages[i],
                  selected: languages[i].code == selectedCode,
                  busy: isSaving && pendingCode == languages[i].code,
                  enabled: !isSaving,
                  onTap: () {
                    if (languages[i].code == selectedCode) return;
                    onSelect(languages[i]);
                  },
                ),
              ],
            ],
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            errorMessage!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.option,
    required this.selected,
    required this.busy,
    required this.enabled,
    required this.onTap,
  });

  final LanguageOption option;
  final bool selected;
  final bool busy;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = _englishName(option.code);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            children: [
              _LanguageBadge(code: option.code, selected: selected),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: selected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null && subtitle != option.label) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (busy)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: selected ? AppColors.primary : AppColors.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String? _englishName(String code) {
    return switch (code) {
      'en' => 'English',
      'id' => 'Indonesian',
      'es' => 'Spanish',
      'fr' => 'French',
      'zh' => 'Chinese',
      'ar' => 'Arabic',
      _ => null,
    };
  }
}

class _LanguageBadge extends StatelessWidget {
  const _LanguageBadge({required this.code, required this.selected});

  final String code;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.primarySoft : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.primary.withValues(alpha: 0.35) : AppColors.divider,
        ),
      ),
      child: Text(
        code.toUpperCase(),
        style: AppTextStyles.labelMedium.copyWith(
          color: selected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
