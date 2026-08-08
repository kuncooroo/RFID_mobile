import 'package:flutter/material.dart';

import '../design_system/colors.dart';
import '../design_system/sizes.dart';
import 'app_text_field.dart';

/// Password field with visibility toggle for Auth and Change Password.
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    this.controller,
    this.focusNode,
    this.label = 'Password',
    this.hintText = 'Enter your password',
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.textInputAction,
    this.autofillHints = const [AutofillHints.password],
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      label: widget.label,
      hintText: widget.hintText,
      obscureText: _obscure,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      keyboardType: TextInputType.visiblePassword,
      prefixIcon: const Icon(
        Icons.lock_outline_rounded,
        color: AppColors.textSecondary,
        size: AppSizes.iconMd,
      ),
      suffixIcon: IconButton(
        tooltip: _obscure ? 'Show password' : 'Hide password',
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(
          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.textSecondary,
          size: AppSizes.iconMd,
        ),
      ),
    );
  }
}
