import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';

/// Legal & Policies body (Figma Legal / Policies).
class LegalPoliciesView extends StatelessWidget {
  const LegalPoliciesView({
    super.key,
    this.onContactSupport,
    this.lastUpdated = 'August 6, 2026',
  });

  final VoidCallback? onContactSupport;
  final String lastUpdated;

  static const policies = <({String title, String body, IconData icon})>[
    (
      title: 'Terms of Service',
      body:
          'By using Kutuku you agree to our marketplace rules, acceptable use policy, and seller/buyer obligations. Accounts may be suspended for fraud, abuse, or repeated policy violations. Kutuku may update these terms; continued use means you accept the latest version.',
      icon: Icons.gavel_outlined,
    ),
    (
      title: 'Privacy Policy',
      body:
          'We collect account, order, payment, and device data to operate the app and improve shopping experiences. Data is shared with payment processors and logistics partners only as needed to fulfill orders. You can manage notification preferences anytime and request account deletion from Support.',
      icon: Icons.privacy_tip_outlined,
    ),
    (
      title: 'Return Policy',
      body:
          'Eligible items may be returned within 7 days of delivery if unused and in original packaging. Some categories (perishables, personal care, digital goods) are final sale. Refunds are issued to the original payment method after the return is inspected.',
      icon: Icons.assignment_return_outlined,
    ),
    (
      title: 'Shipping Policy',
      body:
          'Delivery times depend on the seller and destination. Tracking updates appear in Order Track once a carrier label is created. Kutuku is not responsible for delays caused by customs, weather, or incorrect addresses provided at checkout.',
      icon: Icons.local_shipping_outlined,
    ),
    (
      title: 'Community Guidelines',
      body:
          'Be respectful in Messages and reviews. Do not post hate speech, spam, counterfeit listings, or illegal content. Violations may result in content removal, account limits, or permanent bans.',
      icon: Icons.groups_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.xl,
        AppSpacing.screenHorizontal,
        AppSpacing.xxxl,
      ),
      children: [
        Text(
          'Review how Kutuku handles your account, data, orders, and community standards.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Last updated $lastUpdated',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('DOCUMENTS', style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppSpacing.md),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.settingsTile,
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              for (var i = 0; i < policies.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: AppSpacing.lg,
                    endIndent: AppSpacing.lg,
                    color: AppColors.divider,
                  ),
                _PolicyTile(
                  icon: policies[i].icon,
                  title: policies[i].title,
                  body: policies[i].body,
                ),
              ],
            ],
          ),
        ),
        if (onContactSupport != null) ...[
          const SizedBox(height: AppSpacing.xxl),
          Text('QUESTIONS?', style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppSpacing.md),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.settingsTile,
              border: Border.all(color: AppColors.divider),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onContactSupport,
                borderRadius: AppRadius.settingsTile,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.help_outline_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contact Help & Support',
                              style: AppTextStyles.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ask about policies, privacy, or account requests',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PolicyTile extends StatelessWidget {
  const _PolicyTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.titleMedium),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textTertiary,
        children: [
          Text(
            body,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
