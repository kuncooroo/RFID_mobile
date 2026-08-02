import 'package:flutter/material.dart';

import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../state/message_detail_state.dart';
import 'message_bubble.dart';
import 'message_composer.dart';

class MessageDetailView extends StatefulWidget {
  const MessageDetailView({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onSend,
  });

  final MessageDetailState state;
  final VoidCallback onRetry;
  final ValueChanged<String> onSend;

  @override
  State<MessageDetailView> createState() => _MessageDetailViewState();
}

class _MessageDetailViewState extends State<MessageDetailView> {
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant MessageDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.messages.length != oldWidget.state.messages.length) {
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state.isLoading && widget.state.isEmpty) {
      return const AppLoading.page(message: 'Loading conversation…');
    }

    if (widget.state.hasFailed && widget.state.isEmpty) {
      return AppErrorState(
        title: 'Could not load conversation',
        message: widget.state.errorMessage ?? 'Please try again.',
        onRetry: widget.onRetry,
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.lg,
              AppSpacing.screenHorizontal,
              AppSpacing.lg,
            ),
            itemCount: widget.state.messages.length,
            itemBuilder: (context, index) {
              final message = widget.state.messages[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: MessageBubble(message: message),
              );
            },
          ),
        ),
        MessageComposer(
          onSend: widget.onSend,
          isSending: widget.state.isSending,
        ),
      ],
    );
  }
}
