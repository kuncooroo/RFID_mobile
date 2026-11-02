import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/system_strings.dart';
import '../models/system_member.dart';
import '../theme/app_colors.dart';
import '../widgets/system_app_header.dart';
import '../widgets/system_scaffold.dart';
import '../widgets/primary_button.dart';

/// Self-link screen: name and phone only. Email and password are not collected.
class RegisterProfilePage extends StatefulWidget {
  const RegisterProfilePage({
    super.key,
    required this.strings,
    required this.lang,
    required this.onLangChanged,
    this.initialName = '',
    this.initialPhone,
    this.initialEmail,
    this.initialAge,
    this.initialOrigin,
    this.initialGender,
    this.requirePhone = true,
    required this.onContinue,
    required this.onCancel,
  });

  final SystemStrings strings;
  final SystemLang lang;
  final ValueChanged<SystemLang> onLangChanged;
  final String initialName;
  final String? initialPhone;
  final String? initialEmail;
  final int? initialAge;
  final String? initialOrigin;
  final String? initialGender;
  final bool requirePhone;
  final ValueChanged<RegisterDraft> onContinue;
  final VoidCallback onCancel;

  @override
  State<RegisterProfilePage> createState() => _RegisterProfilePageState();
}

class _RegisterProfilePageState extends State<RegisterProfilePage> {
  late final TextEditingController _name = TextEditingController(
    text: widget.initialName,
  );
  late final TextEditingController _phone = TextEditingController(
    text: widget.initialPhone ?? '',
  );
  late final TextEditingController _email = TextEditingController(
    text: widget.initialEmail ?? '',
  );
  late final TextEditingController _age = TextEditingController(
    text: widget.initialAge?.toString() ?? '',
  );
  late final TextEditingController _origin = TextEditingController(
    text: widget.initialOrigin ?? '',
  );
  late String? _gender = widget.initialGender;
  String? _error;
  bool _nameInvalid = false;
  bool _contactInvalid = false;
  bool _ageInvalid = false;
  bool _originInvalid = false;
  bool _genderInvalid = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _age.dispose();
    _origin.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    final email = _email.text.trim();
    final origin = _origin.text.trim();
    final age = int.tryParse(_age.text.trim());
    final s = widget.strings;

    if (name.isEmpty) {
      setState(() {
        _error = s.nameRequired;
        _nameInvalid = true;
        _contactInvalid = false;
      });
      return;
    }
    if (widget.requirePhone && phone.isEmpty) {
      setState(() {
        _error = s.phoneRequired;
        _nameInvalid = false;
        _contactInvalid = true;
      });
      return;
    }
    if (phone.isNotEmpty && phone.replaceAll(RegExp(r'\D'), '').length < 8) {
      setState(() {
        _error = s.phoneShort;
        _nameInvalid = false;
        _contactInvalid = true;
      });
      return;
    }
    if (email.isNotEmpty && (!email.contains('@') || !email.contains('.'))) {
      setState(() {
        _error = s.emailInvalid;
        _nameInvalid = false;
        _contactInvalid = true;
      });
      return;
    }
    if (age == null || age < 1 || age > 120) {
      setState(() {
        _error = s.ageRequired;
        _ageInvalid = true;
      });
      return;
    }
    if (origin.isEmpty) {
      setState(() {
        _error = s.originRequired;
        _originInvalid = true;
      });
      return;
    }
    if (_gender != 'male' && _gender != 'female') {
      setState(() {
        _error = s.genderRequired;
        _genderInvalid = true;
      });
      return;
    }

    setState(() {
      _error = null;
      _nameInvalid = false;
      _contactInvalid = false;
      _ageInvalid = false;
      _originInvalid = false;
      _genderInvalid = false;
    });
    widget.onContinue(
      RegisterDraft(
        name: name,
        email: email.isEmpty ? null : email,
        phone: phone.isEmpty ? null : phone,
        age: age,
        origin: origin,
        gender: _gender,
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required bool invalid,
  }) {
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1.6),
    );
    return InputDecoration(
      hintText: hint,
      enabledBorder: invalid ? errorBorder : null,
      focusedBorder: invalid ? errorBorder : null,
      border: invalid ? errorBorder : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SystemAppHeader(
              title: s.createProfile,
              lang: widget.lang,
              onLangChanged: widget.onLangChanged,
              onBack: widget.onCancel,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_error != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.error.withValues(
                                      alpha: 0.45,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: AppColors.error,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _error!,
                                        style: const TextStyle(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            TextField(
                              controller: _name,
                              autofocus: true,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: _fieldDecoration(
                                hint: s.fullName,
                                invalid: _nameInvalid,
                              ),
                              onChanged: (_) {
                                if (_error != null) {
                                  setState(() {
                                    _error = null;
                                    _nameInvalid = false;
                                  });
                                }
                              },
                            ),
                            if (widget.requirePhone) ...[
                            const SizedBox(height: 16),
                            TextField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9+\- ]'),
                                ),
                              ],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: _fieldDecoration(
                                hint: s.phone,
                                invalid: _contactInvalid,
                              ),
                              onSubmitted: (_) => _submit(),
                              onChanged: (_) {
                                if (_error != null) {
                                  setState(() {
                                    _error = null;
                                    _contactInvalid = false;
                                  });
                                }
                              },
                            ),
                            ],
                            const SizedBox(height: 16),
                            TextField(
                              controller: _age,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: _fieldDecoration(
                                hint: s.ageLabel,
                                invalid: _ageInvalid,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _origin,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: _fieldDecoration(
                                hint: s.originLabel,
                                invalid: _originInvalid,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: _gender,
                              decoration: _fieldDecoration(
                                hint: s.genderLabel,
                                invalid: _genderInvalid,
                              ),
                              items: [
                                DropdownMenuItem(value: 'male', child: Text(s.male)),
                                DropdownMenuItem(
                                  value: 'female',
                                  child: Text(s.female),
                                ),
                              ],
                              onChanged: (value) => setState(() => _gender = value),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SystemActionArea(
                      primary: PrimaryButton(
                        label: s.continueCta,
                        onPressed: _submit,
                      ),
                      secondary: SecondaryButton(
                        label: s.cancel,
                        onPressed: widget.onCancel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
