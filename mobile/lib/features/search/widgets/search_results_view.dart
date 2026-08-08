import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../product/models/product.dart';
import '../models/search_filter.dart';
import '../navigation/search_navigation.dart';
import '../state/search_state.dart';
import 'search_results_grid.dart';
import 'search_sort_chips.dart';

/// Search Result body — sort chips, result count, product grid.
class SearchResultsView extends StatelessWidget {
  const SearchResultsView({
    super.key,
    required this.state,
    required this.onSortSelected,
    required this.onRetry,
    required this.onFavoriteTap,
    required this.onResetFilter,
  });

  final SearchState state;
  final ValueChanged<SearchSort> onSortSelected;
  final VoidCallback onRetry;
  final ValueChanged<Product> onFavoriteTap;
  final VoidCallback onResetFilter;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.results.isEmpty) {
      return const AppLoading.page(message: 'Searching…');
    }

    if (state.hasFailed && state.results.isEmpty) {
      return AppErrorState(
        title: 'Could not load results',
        message: state.errorMessage ?? 'Please try again.',
        onRetry: onRetry,
      );
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SearchSortChips(
                selected: state.filter.sort,
                onSelected: onSortSelected,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (!state.isEmptyResults)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Text(
                    '${state.results.length} result${state.results.length == 1 ? '' : 's'} found',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
        if (state.isEmptyResults)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
              child: AppEmptyStates.search(
                onAction: state.filter.hasSheetFilters ? onResetFilter : null,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
            sliver: SliverToBoxAdapter(
              child: SearchResultsGrid(
                products: state.results,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onProductTap: (product) =>
                    SearchNavigation.openProduct(context, product),
                onFavoriteTap: onFavoriteTap,
              ),
            ),
          ),
      ],
    );
  }
}
