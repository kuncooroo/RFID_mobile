import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../src/network/api_exception.dart';
import '../../auth/models/member.dart';
import '../../profile/providers/profile_providers.dart';
import '../models/experience.dart';
import '../providers/experience_providers.dart';

/// Visitor journal of granted gate taps, plus saldo and point redemption.
class ExperiencesPage extends ConsumerStatefulWidget {
  const ExperiencesPage({super.key});

  @override
  ConsumerState<ExperiencesPage> createState() => _ExperiencesPageState();
}

class _ExperiencesPageState extends ConsumerState<ExperiencesPage> {
  static const _redeemChunk = 100;

  List<GateExperience> _items = const [];
  bool _loading = true;
  bool _redeeming = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).load();
      _load();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await ref.read(experienceRepositoryProvider).list();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _redeem(Member member) async {
    if (member.points < _redeemChunk || _redeeming) return;
    setState(() => _redeeming = true);
    try {
      await ref.read(experienceRepositoryProvider).redeemPoints(_redeemChunk);
      await ref.read(profileControllerProvider.notifier).refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('100 points converted to discount.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.displayMessage)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _redeeming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final member = ref.watch(profileControllerProvider).snapshot?.member;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Experiences')),
      body: _loading
          ? const AppLoading.page(message: 'Loading experiences…')
          : _error != null
          ? AppErrorState(
              title: 'Could not load experiences',
              message: _error!,
              onRetry: _load,
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                  AppSpacing.screenHorizontal,
                  AppSpacing.xxxl,
                ),
                children: [
                  if (member != null) _WalletCard(
                    member: member,
                    redeeming: _redeeming,
                    onRedeem: () => _redeem(member),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('VISITS', style: _sectionLabel),
                  const SizedBox(height: AppSpacing.sm),
                  if (_items.isEmpty)
                    const AppEmptyState(
                      title: 'No visits yet',
                      message:
                          'A successful gate tap with your card and balance shows up here.',
                      icon: Icons.photo_camera_outlined,
                    )
                  else
                    for (final item in _items) ...[
                      _ExperienceTile(item: item),
                      const SizedBox(height: AppSpacing.md),
                    ],
                ],
              ),
            ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({
    required this.member,
    required this.redeeming,
    required this.onRedeem,
  });

  final Member member;
  final bool redeeming;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    final canRedeem = member.points >= 100 && !redeeming;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saldo ${_money(member.balance)}', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${member.points} points · discount ${_money(member.discountCredit)}',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '100 points = 1 discount, applied on your next checkout.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: canRedeem ? onRedeem : null,
            child: Text(redeeming ? 'Redeeming…' : 'Redeem 100 points'),
          ),
        ],
      ),
    );
  }
}

class _ExperienceTile extends ConsumerWidget {
  const _ExperienceTile({required this.item});

  final GateExperience item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final when = item.checkedInAt?.toLocal();
    final stamp = when == null
        ? ''
        : '${when.year}-${_two(when.month)}-${_two(when.day)} ${_two(when.hour)}:${_two(when.minute)}';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.hasPhoto) _ExperiencePhoto(id: item.id),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.locationName, style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  stamp,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Saldo -${_money(item.amountCharged)} · +${item.pointsAwarded} points',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperiencePhoto extends ConsumerStatefulWidget {
  const _ExperiencePhoto({required this.id});

  final int id;

  @override
  ConsumerState<_ExperiencePhoto> createState() => _ExperiencePhotoState();
}

class _ExperiencePhotoState extends ConsumerState<_ExperiencePhoto> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final bytes = await ref.read(experienceRepositoryProvider).photo(widget.id);
      if (!mounted) return;
      setState(() => _bytes = bytes);
    } catch (_) {
      // A missing photo still leaves the visit text visible.
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    if (bytes == null) {
      return const SizedBox(
        height: 180,
        child: ColoredBox(
          color: AppColors.divider,
          child: Center(child: Icon(Icons.image_outlined)),
        ),
      );
    }
    return Image.memory(
      bytes,
      width: double.infinity,
      fit: BoxFit.fitWidth,
    );
  }
}

TextStyle get _sectionLabel => AppTextStyles.labelSmall.copyWith(
  color: AppColors.textTertiary,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.6,
);

String _money(double value) {
  final digits = value.round().abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final fromEnd = digits.length - i;
    if (i != 0 && fromEnd % 3 == 0) buf.write('.');
    buf.write(digits[i]);
  }
  return buf.toString();
}

String _two(int value) => value.toString().padLeft(2, '0');
