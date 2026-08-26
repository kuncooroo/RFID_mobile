import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_section_header.dart';

/// Recent searches, suggestions, and popular queries for the Search screen.
class SearchRecentList extends StatelessWidget {
  const SearchRecentList({
    super.key,
    required this.recentQueries,
    required this.popularQueries,
    required this.suggestions,
    required this.onQueryTap,
    required this.onRemoveRecent,
    required this.onClearAll,
    this.showSuggestions = false,
  });

  final List<String> recentQueries;
  final List<String> popularQueries;
  final List<String> suggestions;
  final ValueChanged<String> onQueryTap;
  final ValueChanged<String> onRemoveRecent;
  final VoidCallback onClearAll;
  final bool showSuggestions;

  @override
  Widget build(BuildContext context) {
    if (showSuggestions && suggestions.isNotEmpty) {
      return _QuerySection(
        title: 'Suggestions',
        items: suggestions,
        leadingIcon: Icons.search_rounded,
        onQueryTap: onQueryTap,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (recentQueries.isNotEmpty) ...[
          AppSectionHeader(
            title: 'Recent Searches',
            actionLabel: 'Clear',
            onAction: onClearAll,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...recentQueries.map(
            (query) => _SearchQueryTile(
              query: query,
              leadingIcon: Icons.history_rounded,
              showRemove: true,
              onTap: () => onQueryTap(query),
              onRemove: () => onRemoveRecent(query),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        if (popularQueries.isNotEmpty) ...[
          const AppSectionHeader(title: 'Popular Searches'),
          const SizedBox(height: AppSpacing.sm),
          ...popularQueries.map(
            (query) => _SearchQueryTile(
              query: query,
              leadingIcon: Icons.trending_up_rounded,
              showRemove: false,
              onTap: () => onQueryTap(query),
              onRemove: () {},
            ),
          ),
        ],
      ],
    );
  }
}

class _QuerySection extends StatelessWidget {
  const _QuerySection({
    required this.title,
    required this.items,
    required this.leadingIcon,
    required this.onQueryTap,
  });

  final String title;
  final List<String> items;
  final IconData leadingIcon;
  final ValueChanged<String> onQueryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(title: title),
        const SizedBox(height: AppSpacing.sm),
        ...items.map(
          (query) => _SearchQueryTile(
            query: query,
            leadingIcon: leadingIcon,
            showRemove: false,
            onTap: () => onQueryTap(query),
            onRemove: () {},
          ),
        ),
      ],
    );
  }
}

class _SearchQueryTile extends StatelessWidget {
  const _SearchQueryTile({
    required this.query,
    required this.leadingIcon,
    required this.showRemove,
    required this.onTap,
    required this.onRemove,
  });

  final String query;
  final IconData leadingIcon;
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
              Icon(
                leadingIcon,
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
                )
              else
                const Icon(
                  Icons.north_west_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
