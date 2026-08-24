import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/kiosk_strings.dart';
import '../theme/app_colors.dart';
import '../widgets/kiosk_app_header.dart';
import '../widgets/kiosk_scaffold.dart';
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

  final KioskStrings strings;
  final KioskLang lang;
  final ValueChanged<KioskLang> onLangChanged;
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
      setState(() => _error = s.nameRequired);
      return;
    }
    if (phone.isEmpty && email.isEmpty) {
      setState(() => _error = s.contactRequired);
      return;
    }
    if (phone.isNotEmpty && phone.replaceAll(RegExp(r'\D'), '').length < 8) {
      setState(() => _error = s.phoneShort);
      return;
    }
    if (email.isNotEmpty && (!email.contains('@') || !email.contains('.'))) {
      setState(() => _error = s.emailInvalid);
      return;
    }

    setState(() => _error = null);
    widget.onContinue(
      name,
      email.isEmpty ? null : email,
      phone.isEmpty ? null : phone,
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
            KioskAppHeader(
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
                            Text(
                              s.createProfileBody,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 28),
                            TextField(
                              controller: _name,
                              autofocus: true,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: s.fullName,
                                errorText: _error,
                              ),
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
                              decoration: InputDecoration(hintText: s.phone),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              style: const TextStyle(fontSize: 18),
                              decoration: InputDecoration(hintText: s.email),
                              onSubmitted: (_) => _submit(),
                            ),
                            if (_error == null) ...[
                              const SizedBox(height: 12),
                              Text(
                                s.contactHint,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    KioskActionArea(
                      primary: PrimaryButton(
                        label: s.continueCta,
                        onPressed: _submit,
                      ),
                      secondary: GhostButton(
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
