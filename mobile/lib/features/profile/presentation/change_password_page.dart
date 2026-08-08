import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/text_styles.dart';
import '../navigation/profile_navigation.dart';
import '../providers/profile_providers.dart';
import '../widgets/change_password_view.dart';

/// Change Password screen (Figma `1:23`).
class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  var _dirty = false;

  @override
  void initState() {
    super.initState();
    _currentController.addListener(_onAnyFieldChanged);
    _newController.addListener(_onAnyFieldChanged);
    _confirmController.addListener(_onAnyFieldChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(changePasswordControllerProvider.notifier).reset();
    });
  }

  void _onAnyFieldChanged() {
    if (_dirty) return;
    final hasText = _currentController.text.isNotEmpty ||
        _newController.text.isNotEmpty ||
        _confirmController.text.isNotEmpty;
    if (!hasText) return;
    setState(() => _dirty = true);
  }

  @override
  void dispose() {
    _currentController
      ..removeListener(_onAnyFieldChanged)
      ..dispose();
    _newController
      ..removeListener(_onAnyFieldChanged)
      ..dispose();
    _confirmController
      ..removeListener(_onAnyFieldChanged)
      ..dispose();
    super.dispose();
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Discard changes?', style: AppTextStyles.headlineSmall),
        content: Text(
          'You have unsaved password changes. Leave without saving?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Discard',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    return leave == true;
  }

  Future<void> _onBack() async {
    final ok = await _confirmDiscard();
    if (!ok || !mounted) return;
    ProfileNavigation.pop(context);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await ref.read(changePasswordControllerProvider.notifier).submit(
          currentPassword: _currentController.text,
          newPassword: _newController.text,
        );
    if (!mounted || !ok) return;

    setState(() => _dirty = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated')),
    );
    ProfileNavigation.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(changePasswordControllerProvider);

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final ok = await _confirmDiscard();
        if (!ok || !context.mounted) return;
        ProfileNavigation.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: _onBack,
          ),
          title: Text('Change Password', style: AppTextStyles.headlineSmall),
          centerTitle: false,
        ),
        body: ChangePasswordView(
          formKey: _formKey,
          currentController: _currentController,
          newController: _newController,
          confirmController: _confirmController,
          isSubmitting: state.isSubmitting,
          errorMessage: state.errorMessage,
          onSubmit: _submit,
        ),
      ),
    );
  }
}
