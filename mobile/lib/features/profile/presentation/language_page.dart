import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../settings/models/settings.dart';
import '../navigation/profile_navigation.dart';
import '../providers/profile_providers.dart';
import '../widgets/language_view.dart';

/// Language settings screen.
class LanguagePage extends ConsumerStatefulWidget {
  const LanguagePage({super.key});

  @override
  ConsumerState<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends ConsumerState<LanguagePage> {
  String? _pendingCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(settingsControllerProvider.notifier).load();
    });
  }

  Future<void> _onSelect(LanguageOption option) async {
    final state = ref.read(settingsControllerProvider);
    if (option.code == state.settings.languageCode || _pendingCode != null) {
      return;
    }

    setState(() => _pendingCode = option.code);
    final ok = await ref
        .read(settingsControllerProvider.notifier)
        .selectLanguage(option);
    if (!mounted) return;
    setState(() => _pendingCode = null);

    if (!ok) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Language set to ${option.label}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => ProfileNavigation.pop(context),
        ),
        title: Text('Language', style: AppTextStyles.headlineSmall),
        centerTitle: false,
      ),
      body: LanguageView(
        languages: state.languages,
        selectedCode: state.settings.languageCode,
        isLoading: state.isLoading,
        isSaving: _pendingCode != null,
        pendingCode: _pendingCode,
        errorMessage: state.errorMessage,
        onRetry: () => ref.read(settingsControllerProvider.notifier).load(),
        onSelect: _onSelect,
      ),
    );
  }
}
