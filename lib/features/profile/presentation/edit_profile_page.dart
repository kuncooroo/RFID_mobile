import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/profile_providers.dart';
import '../widgets/settings_views.dart';

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
  var _hydrated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  Future<void> _hydrate() async {
    if (_hydrated) return;
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
    }
    _hydrated = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await ref
        .read(editProfileControllerProvider.notifier)
        .submit(
          displayName: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
        );
    if (!mounted || !ok) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProfileControllerProvider);

    return ProfileFormScaffold(
      title: 'Edit Profile',
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          children: [
            if (state.errorMessage != null) ...[
              ProfileErrorText(message: state.errorMessage!),
              const SizedBox(height: AppSpacing.lg),
            ],
            AppTextField(
              controller: _nameController,
              label: 'Name',
              hintText: 'Enter your name',
              textCapitalization: TextCapitalization.words,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Name is required'
                  : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _emailController,
              label: 'Email',
              hintText: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                if (!value.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _phoneController,
              label: 'Phone',
              hintText: 'Enter your phone',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'Save Changes',
              onPressed: state.isSubmitting ? null : _submit,
              isLoading: state.isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}
