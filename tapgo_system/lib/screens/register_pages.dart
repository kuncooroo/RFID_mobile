import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/system_strings.dart';
import '../theme/app_colors.dart';
import '../widgets/system_app_header.dart';
import '../widgets/system_scaffold.dart';
import '../widgets/primary_button.dart';

/// Single registration screen: name + phone + email.
class RegisterProfilePage extends StatefulWidget {
  const RegisterProfilePage({
    super.key,
    required this.strings,
    required this.lang,
    required this.onLangChanged,
    this.initialName = '',
    this.initialPhone,
    this.initialEmail,
    required this.onContinue,
    required this.onCancel,
  });

  final SystemStrings strings;
  final SystemLang lang;
  final ValueChanged<SystemLang> onLangChanged;
  final String initialName;
  final String? initialPhone;
  final String? initialEmail;
  final void Function(String name, String? email, String? phone) onContinue;
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
  String? _error;
  bool _nameInvalid = false;
  bool _contactInvalid = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    final email = _email.text.trim();
    final s = widget.strings;

    if (name.isEmpty) {
      setState(() {
        _error = s.nameRequired;
        _nameInvalid = true;
        _contactInvalid = false;
      });
      return;
    }
    if (phone.isEmpty && email.isEmpty) {
      setState(() {
        _error = s.contactRequired;
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

    setState(() {
      _error = null;
      _nameInvalid = false;
      _contactInvalid = false;
    });
    widget.onContinue(
      name,
      email.isEmpty ? null : email,
      phone.isEmpty ? null : phone,
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
                            const SizedBox(height: 16),
                            TextField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
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
                              onChanged: (_) {
                                if (_error != null) {
                                  setState(() {
                                    _error = null;
                                    _contactInvalid = false;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              style: const TextStyle(fontSize: 18),
                              decoration: _fieldDecoration(
                                hint: s.email,
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
