import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/text_styles.dart';
import '../navigation/messaging_navigation.dart';
import '../providers/messaging_providers.dart';
import '../widgets/messages_view.dart';

/// Message list screen (Figma `1:57`).
class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(messagingControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagingControllerProvider);
    final controller = ref.read(messagingControllerProvider.notifier);

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
        title: Text('Message', style: AppTextStyles.headlineSmall),
        centerTitle: false,
      ),
      body: MessagesView(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.load,
        onConversationTap: (conversation) =>
            MessagingNavigation.openThread(context, conversation),
      ),
    );
  }
}
