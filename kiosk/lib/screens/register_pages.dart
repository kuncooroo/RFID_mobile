import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/kiosk_strings.dart';
import '../theme/app_colors.dart';
import '../widgets/kiosk_card.dart';
import '../widgets/kiosk_scaffold.dart';
import '../widgets/primary_button.dart';

class RegisterNamePage extends StatefulWidget {
  const RegisterNamePage({
    super.key,
    required this.strings,
    required this.initial,
    required this.onContinue,
    required this.onCancel,
  });

  final KioskStrings strings;
  final String initial;
  final ValueChanged<String> onContinue;
  final VoidCallback onCancel;

  @override
  State<RegisterNamePage> createState() => _RegisterNamePageState();
}

class _RegisterNamePageState extends State<RegisterNamePage> {
  late final TextEditingController _name = TextEditingController(text: widget.initial);
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _next() {
    final value = _name.text.trim();
    if (value.isEmpty) {
      setState(() => _error = widget.strings.nameRequired);
      return;
    }
    widget.onContinue(value);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    return KioskScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(s.createAccount, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 12),
          Text(s.whatName, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 32),
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: s.fullName,
              errorText: _error,
            ),
            onSubmitted: (_) => _next(),
          ),
          const Spacer(),
          Text(
            s.stepOf(1, 3),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          PrimaryButton(label: s.continueLabel, onPressed: _next),
          GhostButton(label: s.cancel, onPressed: widget.onCancel),
        ],
      ),
    );
  }
}

class RegisterContactPage extends StatefulWidget {
  const RegisterContactPage({
    super.key,
    required this.strings,
    this.initialPhone,
    this.initialEmail,
    required this.onContinue,
    required this.onBack,
  });

  final KioskStrings strings;
  final String? initialPhone;
  final String? initialEmail;
  final void Function(String? email, String? phone) onContinue;
  final VoidCallback onBack;

  @override
  State<RegisterContactPage> createState() => _RegisterContactPageState();
}

class _RegisterContactPageState extends State<RegisterContactPage> {
  late final TextEditingController _phone =
      TextEditingController(text: widget.initialPhone ?? '');
  late final TextEditingController _email =
      TextEditingController(text: widget.initialEmail ?? '');
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  void _next() {
    final phone = _phone.text.trim();
    final email = _email.text.trim();
    if (phone.isEmpty && email.isEmpty) {
      setState(() => _error = widget.strings.contactRequired);
      return;
    }
    if (phone.isNotEmpty && phone.replaceAll(RegExp(r'\D'), '').length < 8) {
      setState(() => _error = widget.strings.phoneShort);
      return;
    }
    if (email.isNotEmpty && (!email.contains('@') || !email.contains('.'))) {
      setState(() => _error = widget.strings.emailInvalid);
      return;
    }
    widget.onContinue(email.isEmpty ? null : email, phone.isEmpty ? null : phone);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    return KioskScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(s.contactInfo, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 12),
          Text(s.whatPhone, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 32),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]')),
            ],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            decoration: InputDecoration(hintText: s.phone, errorText: _error),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 20),
            decoration: InputDecoration(hintText: s.email),
          ),
          const Spacer(),
          Text(
            s.stepOf(2, 3),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          PrimaryButton(label: s.continueLabel, onPressed: _next),
          GhostButton(label: s.back, onPressed: widget.onBack),
        ],
      ),
    );
  }
}

class RegisterConfirmPage extends StatelessWidget {
  const RegisterConfirmPage({
    super.key,
    required this.strings,
    required this.name,
    this.email,
    this.phone,
    required this.rfidUid,
    required this.onCreate,
    required this.onBack,
  });

  final KioskStrings strings;
  final String name;
  final String? email;
  final String? phone;
  final String rfidUid;
  final VoidCallback onCreate;
  final VoidCallback onBack;

  String get _maskedRfid {
    if (rfidUid.length <= 4) return rfidUid;
    return '•••• ${rfidUid.substring(rfidUid.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final s = strings;
    return KioskScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(s.reviewInfo, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 28),
          KioskCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row(s.fullName, name),
                const SizedBox(height: 16),
                _row(s.phone, phone ?? '—'),
                const SizedBox(height: 16),
                _row(s.email, email ?? '—'),
                const SizedBox(height: 16),
                _row('RFID', _maskedRfid),
              ],
            ),
          ),
          const Spacer(),
          Text(
            s.stepOf(3, 3),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          PrimaryButton(label: s.createAccountCta, onPressed: onCreate),
          GhostButton(label: s.back, onPressed: onBack),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
