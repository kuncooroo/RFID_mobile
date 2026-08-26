import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../models/message.dart';
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

    final rows = _buildRows(widget.state.messages);

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
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final row = rows[index];
              if (row is _DateSeparatorRow) {
                return _DateSeparator(label: row.label);
              }
              final message = (row as _MessageRow).message;
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

  List<_ChatRow> _buildRows(List<Message> messages) {
    final rows = <_ChatRow>[];
    DateTime? lastDay;

    for (final message in messages) {
      final sentAt = message.sentAt?.toLocal();
      if (sentAt != null) {
        final day = DateTime(sentAt.year, sentAt.month, sentAt.day);
        if (lastDay == null || day != lastDay) {
          rows.add(_DateSeparatorRow(_formatDayLabel(day)));
          lastDay = day;
        }
      }
      rows.add(_MessageRow(message));
    }
    return rows;
  }

  String _formatDayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (day == today) return 'Today';
    if (day == yesterday) return 'Yesterday';
    return '${day.day.toString().padLeft(2, '0')}/'
        '${day.month.toString().padLeft(2, '0')}/'
        '${day.year}';
  }
}

sealed class _ChatRow {}

class _DateSeparatorRow extends _ChatRow {
  _DateSeparatorRow(this.label);
  final String label;
}

class _MessageRow extends _ChatRow {
  _MessageRow(this.message);
  final Message message;
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.divider)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.divider)),
        ],
      ),
    );
  }
}
