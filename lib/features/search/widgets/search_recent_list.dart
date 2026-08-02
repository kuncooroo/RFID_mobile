import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_section_header.dart';

class SearchRecentList extends StatelessWidget {
  const SearchRecentList({
    super.key,
    required this.recentQueries,
    required this.suggestions,
    required this.onQueryTap,
    required this.onRemoveRecent,
    required this.onClearAll,
    this.showSuggestions = false,
  });

  final List<String> recentQueries;
  final List<String> suggestions;
  final ValueChanged<String> onQueryTap;
  final ValueChanged<String> onRemoveRecent;
  final VoidCallback onClearAll;
  final bool showSuggestions;

  @override
  Widget build(BuildContext context) {
    final items = showSuggestions && suggestions.isNotEmpty
        ? suggestions
        : recentQueries;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final title = showSuggestions && suggestions.isNotEmpty
        ? 'Suggestions'
        : 'Recent Searches';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(
          title: title,
          actionLabel: !showSuggestions && recentQueries.isNotEmpty
              ? 'Clear'
              : null,
          onAction: !showSuggestions && recentQueries.isNotEmpty
              ? onClearAll
              : null,
        ),
        const SizedBox(height: AppSpacing.sm),
        ...items.map(
          (query) => _SearchQueryTile(
            query: query,
            showRemove: !showSuggestions,
            onTap: () => onQueryTap(query),
            onRemove: () => onRemoveRecent(query),
          ),
        ),
      ],
    );
  }
}

class _SearchQueryTile extends StatelessWidget {
  const _SearchQueryTile({
    required this.query,
    required this.showRemove,
    required this.onTap,
    required this.onRemove,
  });

  final String query;
  final bool showRemove;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(query, style: AppTextStyles.bodyMedium),
              ),
              if (showRemove)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
