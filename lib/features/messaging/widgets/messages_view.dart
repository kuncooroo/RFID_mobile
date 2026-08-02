import 'package:flutter/material.dart';

import '../../../shared/design_system/app_assets.dart';
import '../../../shared/design_system/colors.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../models/conversation.dart';
import '../navigation/messaging_navigation.dart';
import '../state/messaging_state.dart';
import 'conversation_tile.dart';

class MessagesView extends StatelessWidget {
  const MessagesView({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onRetry,
    required this.onConversationTap,
  });

  final MessagingState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final ValueChanged<Conversation> onConversationTap;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.isEmpty) {
      return const AppLoading.page(message: 'Loading messages…');
    }

    if (state.hasFailed && state.isEmpty) {
      return AppErrorState(
        title: 'Could not load messages',
        message: state.errorMessage ?? 'Please try again.',
        onRetry: onRetry,
      );
    }

    if (state.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: AppEmptyState(
                title: 'No messages yet',
                message:
                    'Start a conversation with a store to ask about products or orders.',
                illustrationAsset: AppAssets.emptyMessages,
                icon: Icons.chat_bubble_outline_rounded,
                actionLabel: 'Browse Home',
                onAction: () => MessagingNavigation.openHome(context),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.conversations.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.divider),
        itemBuilder: (context, index) {
          final conversation = state.conversations[index];
          return ConversationTile(
            conversation: conversation,
            onTap: () => onConversationTap(conversation),
          );
        },
      ),
    );
  }
}
