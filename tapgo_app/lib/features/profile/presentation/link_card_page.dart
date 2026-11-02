import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../src/network/api_client.dart';
import '../../../src/network/api_endpoints.dart';
import '../../../src/network/api_exception.dart';
import '../navigation/profile_navigation.dart';

/// Link a printed 16-digit card number to the signed-in account.
class LinkCardPage extends ConsumerStatefulWidget {
  const LinkCardPage({super.key});

  @override
  ConsumerState<LinkCardPage> createState() => _LinkCardPageState();
}

class _LinkCardPageState extends ConsumerState<LinkCardPage> {
  final _controller = TextEditingController();
  String? _linkedNumber;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await ref.read(apiClientProvider).get<Map<String, dynamic>>(
            ApiEndpoints.userCard,
            parser: (raw) =>
                raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{},
          );
      if (!mounted) return;
      setState(() => _linkedNumber = data['card_number']?.toString());
    } catch (_) {}
  }

  Future<void> _submit() async {
    final digits = _controller.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 16) {
      setState(() => _error = 'Masukkan 16 digit nomor kartu.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final data = await ref.read(apiClientProvider).post<Map<String, dynamic>>(
            ApiEndpoints.userCard,
            data: {'card_number': digits},
            parser: (raw) =>
                raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{},
          );
      if (!mounted) return;
      setState(() {
        _linkedNumber = data['card_number']?.toString() ?? digits;
        _controller.clear();
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.displayMessage);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final linked = _linkedNumber != null && _linkedNumber!.isNotEmpty;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => ProfileNavigation.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text('Hubungkan kartu', style: AppTextStyles.titleMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          Text(
            'Ketik nomor 16 digit yang tercetak di kartu. UID chip dibaca mesin, tidak perlu diketik.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (linked) ...[
            Text('Kartu terhubung', style: AppTextStyles.labelMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(_linkedNumber!, style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppSpacing.xxl),
          ],
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 16,
            decoration: const InputDecoration(
              labelText: 'Nomor kartu',
              counterText: '',
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(_error!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.danger)),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: _busy ? 'Menghubungkan...' : 'Hubungkan',
            onPressed: _busy ? null : _submit,
          ),
        ],
      ),
    );
  }
}
