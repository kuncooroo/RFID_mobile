import 'package:flutter/material.dart';

import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../state/search_state.dart';
import 'search_recent_list.dart';

class SearchView extends StatelessWidget {
  const SearchView({
    super.key,
    required this.state,
    required this.onQueryTap,
    required this.onRemoveRecent,
    required this.onClearRecent,
    required this.onRetry,
  });

  final SearchState state;
  final ValueChanged<String> onQueryTap;
  final ValueChanged<String> onRemoveRecent;
  final VoidCallback onClearRecent;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.recentQueries.isEmpty) {
      return const AppLoading.page(message: 'Loading search…');
    }

    if (state.hasFailed && state.recentQueries.isEmpty) {
      return AppErrorState(
        title: 'Could not load search',
        message: state.errorMessage ?? 'Please try again.',
        onRetry: onRetry,
      );
    }

    final showSuggestions =
        state.query.trim().isNotEmpty && state.suggestions.isNotEmpty;

    if (!showSuggestions && state.recentQueries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
        child: AppEmptyState(
          title: 'Start searching',
          message: 'Find clothes, shoes, bags, and more across Kutuku.',
          icon: Icons.search_rounded,
        ),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      children: [
        SearchRecentList(
          recentQueries: state.recentQueries,
          suggestions: state.suggestions,
          showSuggestions: showSuggestions,
          onQueryTap: onQueryTap,
          onRemoveRecent: onRemoveRecent,
          onClearAll: onClearRecent,
        ),
      ],
    );
  }
}
