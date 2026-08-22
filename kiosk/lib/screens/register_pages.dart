import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/kiosk_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
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
  late final TextEditingController _name =
      TextEditingController(text: widget.initial);
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
    return KioskPageShell(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.createProfile,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: AppSpacing.vGap(context, 12, min: 8, max: 12)),
          Text(
            s.createProfileBody,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppSpacing.vGap(context, 32, min: 20, max: 32)),
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            style: TextStyle(
              fontSize: AppSpacing.scale(context, 22).clamp(18.0, 22.0),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: s.fullName,
              errorText: _error,
            ),
            onSubmitted: (_) => _next(),
          ),
        ],
      ),
      footer: KioskActionArea(
        leading: Text(
          s.stepOf(1, 2),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted),
        ),
        primary: PrimaryButton(label: s.continueCta, onPressed: _next),
        secondary: GhostButton(label: s.cancel, onPressed: widget.onCancel),
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
    widget.onContinue(
      email.isEmpty ? null : email,
      phone.isEmpty ? null : phone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    return KioskPageShell(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.createProfile,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: AppSpacing.vGap(context, 12, min: 8, max: 12)),
          Text(
            s.contactHint,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppSpacing.vGap(context, 32, min: 20, max: 32)),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]')),
            ],
            style: TextStyle(
              fontSize: AppSpacing.scale(context, 22).clamp(18.0, 22.0),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(hintText: s.phone, errorText: _error),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            style: TextStyle(
              fontSize: AppSpacing.scale(context, 20).clamp(16.0, 20.0),
            ),
            decoration: InputDecoration(hintText: s.email),
            onSubmitted: (_) => _next(),
          ),
        ],
      ),
      footer: KioskActionArea(
        leading: Text(
          s.stepOf(2, 2),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted),
        ),
        primary: PrimaryButton(label: s.continueCta, onPressed: _next),
        secondary: GhostButton(label: s.back, onPressed: widget.onBack),
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
    return KioskPageShell(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.reviewInfo,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: AppSpacing.vGap(context, 28, min: 16, max: 28)),
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
        ],
      ),
      footer: KioskActionArea(
        leading: Text(
          s.stepOf(2, 2),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted),
        ),
        primary: PrimaryButton(label: s.continueCta, onPressed: onCreate),
        secondary: GhostButton(label: s.back, onPressed: onBack),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
