import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../navigation/messaging_navigation.dart';
import '../providers/messaging_providers.dart';
import '../widgets/message_detail_view.dart';

/// Message Detail / chat thread (Figma `1:58`).
class MessageDetailPage extends ConsumerStatefulWidget {
  const MessageDetailPage({super.key, required this.threadId});

  final String threadId;

  @override
  ConsumerState<MessageDetailPage> createState() => _MessageDetailPageState();
}

class _MessageDetailPageState extends ConsumerState<MessageDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(messageDetailControllerProvider(widget.threadId).notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messageDetailControllerProvider(widget.threadId));
    final controller =
        ref.read(messageDetailControllerProvider(widget.threadId).notifier);
    final title = state.conversation?.title ?? 'Message';
    final isOnline = state.conversation?.isOnline ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => MessagingNavigation.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AppAvatar(
                  imageUrl: state.conversation?.avatarUrl,
                  name: title,
                  size: AppAvatarSize.sm,
                ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headlineSmall,
                  ),
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isOnline
                          ? AppColors.success
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: MessageDetailView(
        state: state,
        onRetry: controller.load,
        onSend: controller.send,
      ),
    );
  }
}
