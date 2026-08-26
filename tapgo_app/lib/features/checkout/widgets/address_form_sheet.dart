import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../models/address.dart';
import '../providers/checkout_providers.dart';

/// Bottom sheet to create or edit a shipping address.
Future<Address?> showAddressFormSheet(
  BuildContext context, {
  Address? initial,
}) {
  return showModalBottomSheet<Address>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => AddressFormSheet(initial: initial),
  );
}

class AddressFormSheet extends ConsumerStatefulWidget {
  const AddressFormSheet({super.key, this.initial});

  final Address? initial;

  @override
  ConsumerState<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends ConsumerState<AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _streetController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _postalController;
  late final TextEditingController _countryController;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _labelController = TextEditingController(text: initial?.label ?? 'Home');
    _nameController = TextEditingController(text: initial?.recipientName ?? '');
    _phoneController = TextEditingController(text: initial?.phone ?? '');
    _streetController = TextEditingController(text: initial?.street ?? '');
    _cityController = TextEditingController(text: initial?.city ?? '');
    _stateController = TextEditingController(text: initial?.state ?? '');
    _postalController = TextEditingController(text: initial?.postalCode ?? '');
    _countryController = TextEditingController(text: initial?.country ?? 'US');
    _isDefault = initial?.isDefault ?? true;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final saved = await ref.read(checkoutControllerProvider.notifier).saveAddress(
          AddressInput(
            label: _labelController.text,
            recipientName: _nameController.text,
            phone: _phoneController.text,
            street: _streetController.text,
            city: _cityController.text,
            state: _stateController.text.trim().isEmpty
                ? null
                : _stateController.text,
            postalCode: _postalController.text.trim().isEmpty
                ? null
                : _postalController.text,
            country: _countryController.text.trim().isEmpty
                ? 'US'
                : _countryController.text,
            isDefault: _isDefault,
          ),
          addressId: widget.initial?.id,
        );

    if (!mounted) return;
    if (saved == null) {
      final error = ref.read(checkoutControllerProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Could not save address')),
      );
      return;
    }
    Navigator.of(context).pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(
      checkoutControllerProvider.select((s) => s.savingAddress),
    );
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.lg,
            AppSpacing.screenHorizontal,
            AppSpacing.xxl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderStrong,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  widget.initial == null ? 'Add Address' : 'Edit Address',
                  style: AppTextStyles.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  controller: _labelController,
                  label: 'Label',
                  hintText: 'Home, Office…',
                  textInputAction: TextInputAction.next,
                  enabled: !saving,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _nameController,
                  label: 'Recipient name',
                  hintText: 'Full name',
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  enabled: !saving,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _phoneController,
                  label: 'Phone',
                  hintText: '+62…',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  enabled: !saving,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _streetController,
                  label: 'Street address',
                  hintText: 'Street, building, unit',
                  textInputAction: TextInputAction.next,
                  enabled: !saving,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _cityController,
                  label: 'City',
                  textInputAction: TextInputAction.next,
                  enabled: !saving,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _stateController,
                        label: 'State',
                        textInputAction: TextInputAction.next,
                        enabled: !saving,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppTextField(
                        controller: _postalController,
                        label: 'Postal code',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        enabled: !saving,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _countryController,
                  label: 'Country code',
                  hintText: 'US / ID',
                  textInputAction: TextInputAction.done,
                  enabled: !saving,
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Set as default', style: AppTextStyles.bodyMedium),
                  value: _isDefault,
                  activeThumbColor: AppColors.primary,
                  onChanged: saving
                      ? null
                      : (value) => setState(() => _isDefault = value),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: widget.initial == null ? 'Save Address' : 'Update Address',
                  onPressed: saving ? null : _submit,
                  isLoading: saving,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
