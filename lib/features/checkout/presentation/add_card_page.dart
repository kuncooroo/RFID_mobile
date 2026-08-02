import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../navigation/checkout_navigation.dart';
import '../providers/checkout_providers.dart';
import '../state/checkout_state.dart';
import '../widgets/add_card_form.dart';

class AddCardPage extends ConsumerStatefulWidget {
  const AddCardPage({super.key});

  @override
  ConsumerState<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends ConsumerState<AddCardPage> {
  final _formKey = GlobalKey<AddCardFormState>();
  var _isSaving = false;

  Future<void> _onSave(NewCardInput input) async {
    setState(() => _isSaving = true);
    final method =
        await ref.read(checkoutControllerProvider.notifier).addCard(input);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (method != null) {
      CheckoutNavigation.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Add New Card', style: AppTextStyles.headlineSmall),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.md,
          AppSpacing.screenHorizontal,
          AppSpacing.xxxl,
        ),
        children: [
          AddCardForm(
            key: _formKey,
            isLoading: _isSaving,
            onSubmit: _onSave,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.lg,
          AppSpacing.screenHorizontal,
          AppSpacing.lg,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: AppButton(
            label: 'Save',
            isLoading: _isSaving,
            onPressed: _isSaving ? null : () => _formKey.currentState?.submit(),
          ),
        ),
      ),
    );
  }
}
