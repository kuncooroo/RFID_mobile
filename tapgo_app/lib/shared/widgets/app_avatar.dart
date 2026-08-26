import 'package:flutter/material.dart';

import '../design_system/app_assets.dart';
import '../design_system/colors.dart';
import '../design_system/radius.dart';
import '../design_system/sizes.dart';
import '../design_system/text_styles.dart';
import 'app_image.dart';

enum AppAvatarSize { sm, md, lg, xl, store }

/// Circular user / store avatar used across Home, Store, Messages, Settings.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.name,
    this.size = AppAvatarSize.md,
    this.showVerifiedBadge = false,
    this.onTap,
  });

  final String? imageUrl;
  final String? assetPath;
  final String? name;
  final AppAvatarSize size;
  final bool showVerifiedBadge;
  final VoidCallback? onTap;

  double get _dimension => switch (size) {
    AppAvatarSize.sm => AppSizes.avatarSm,
    AppAvatarSize.md => AppSizes.avatarMd,
    AppAvatarSize.lg => AppSizes.avatarLg,
    AppAvatarSize.xl => AppSizes.avatarXl,
    AppAvatarSize.store => AppSizes.storeAvatar,
  };

  @override
  Widget build(BuildContext context) {
    final hasImage =
        (imageUrl != null && imageUrl!.isNotEmpty) || assetPath != null;

    final avatar = Container(
      width: _dimension,
      height: _dimension,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceMuted,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? AppImage(
              imageUrl: imageUrl,
              assetPath: assetPath ?? AppAssets.placeholderAvatar,
              width: _dimension,
              height: _dimension,
              borderRadius: AppRadius.avatar,
              fit: BoxFit.cover,
            )
          : Center(
              child: Text(
                _initials,
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.primary,
                  fontSize: _dimension * 0.35,
                ),
              ),
            ),
    );

    final content = showVerifiedBadge
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              avatar,
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: _dimension * 0.32,
                  height: _dimension * 0.32,
                  decoration: const BoxDecoration(
                    color: AppColors.verified,
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: AppColors.white, width: 1.5),
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    size: _dimension * 0.2,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          )
        : avatar;

    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }

  String get _initials {
    final value = (name ?? '').trim();
    if (value.isEmpty) return '?';
    final parts = value.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}
