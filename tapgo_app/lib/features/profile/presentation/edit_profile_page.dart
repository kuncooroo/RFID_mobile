import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/text_styles.dart';
import '../navigation/profile_navigation.dart';
import '../providers/profile_providers.dart';
import '../widgets/edit_profile_view.dart';

/// Edit Profile screen (Figma `1:20`).
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _avatarUrl;
  var _hydrating = true;
  var _displayName = 'Member';
  var _dirty = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onAnyFieldChanged);
    _emailController.addListener(_onAnyFieldChanged);
    _phoneController.addListener(_onAnyFieldChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  void _onAnyFieldChanged() {
    if (_hydrating || _dirty) return;
    setState(() => _dirty = true);
  }

  Future<void> _hydrate() async {
    ref.read(editProfileControllerProvider.notifier).reset();

    var snapshot = ref.read(profileControllerProvider).snapshot;
    if (snapshot == null) {
      await ref.read(profileControllerProvider.notifier).load();
      if (!mounted) return;
      snapshot = ref.read(profileControllerProvider).snapshot;
    }

    final member = snapshot?.member;
    if (member != null) {
      _nameController.text = member.displayName;
      _emailController.text = member.email ?? '';
      _phoneController.text = member.phone ?? '';
      _avatarUrl = member.avatarUrl;
      _displayName = member.displayName.isEmpty ? 'Member' : member.displayName;
    }

    if (!mounted) return;
    setState(() {
      _hydrating = false;
      _dirty = false;
    });
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_onAnyFieldChanged)
      ..dispose();
    _emailController
      ..removeListener(_onAnyFieldChanged)
      ..dispose();
    _phoneController
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
          'You have unsaved changes. Leave without saving?',
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

    final ok = await ref.read(editProfileControllerProvider.notifier).submit(
          displayName: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          avatarUrl: _avatarUrl,
        );
    if (!mounted || !ok) return;

    setState(() => _dirty = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
    ProfileNavigation.pop(context);
  }

  void _onAvatarTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Photo picker will be available when media upload is wired',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProfileControllerProvider);

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
          title: Text('Edit Profile', style: AppTextStyles.headlineSmall),
          centerTitle: false,
        ),
        body: EditProfileView(
          formKey: _formKey,
          nameController: _nameController,
          emailController: _emailController,
          phoneController: _phoneController,
          avatarUrl: _avatarUrl,
          displayName: _displayName,
          isHydrating: _hydrating,
          isSubmitting: state.isSubmitting,
          errorMessage: state.errorMessage,
          onAvatarTap: _onAvatarTap,
          onSubmit: _submit,
          onNameChanged: (value) {
            final next = value.trim().isEmpty ? 'Member' : value.trim();
            if (next != _displayName) {
              setState(() => _displayName = next);
            }
          },
        ),
      ),
    );
  }
}
