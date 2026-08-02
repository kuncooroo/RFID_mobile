import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../providers/messaging_providers.dart';
import '../widgets/message_detail_view.dart';

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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            AppAvatar(
              imageUrl: state.conversation?.avatarUrl,
              name: title,
              size: AppAvatarSize.sm,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineSmall,
              ),
            ),
          ],
        ),
      ),
      body: MessageDetailView(
        state: state,
        onRetry: controller.load,
        onSend: controller.send,
      ),
    );
  }
}
