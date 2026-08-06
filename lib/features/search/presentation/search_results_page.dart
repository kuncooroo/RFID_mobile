import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_search_bar.dart';
import '../navigation/search_navigation.dart';
import '../providers/search_providers.dart';
import '../widgets/search_results_view.dart';

/// Search Result screen with sort chips and Filter By sheet.
class SearchResultsPage extends ConsumerStatefulWidget {
  const SearchResultsPage({super.key, required this.initialQuery});

  final String initialQuery;

  @override
  ConsumerState<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends ConsumerState<SearchResultsPage> {
  late final TextEditingController _queryController;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.initialQuery);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final controller = ref.read(searchControllerProvider.notifier);
      controller.initializeResults(query: widget.initialQuery);
      await controller.ensureFilterOptions();
      await controller.search();
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _submit(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    _queryController.text = trimmed;
    setState(() {});
    await ref.read(searchControllerProvider.notifier).submitQuery(trimmed);
  }

  void _onQueryChanged(String value) {
    ref.read(searchControllerProvider.notifier).setQuery(value);
    setState(() {});
  }

  void _clearQuery() {
    _queryController.clear();
    ref.read(searchControllerProvider.notifier).setQuery('');
    setState(() {});
  }

  Future<void> _openFilter() async {
    final controller = ref.read(searchControllerProvider.notifier);
    final state = ref.read(searchControllerProvider);
    controller.setFilterOpen(true);

    final result = await SearchNavigation.openFilterSheet(
      context,
      initialFilter: state.filter,
      options: state.filterOptions,
    );

    controller.setFilterOpen(false);
    if (!mounted || result == null) return;
    await controller.applyFilter(result);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);
    final controller = ref.read(searchControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => SearchNavigation.pop(context),
        ),
        title: Text('Search Result', style: AppTextStyles.headlineSmall),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Cart',
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => SearchNavigation.openCart(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.sm,
              AppSpacing.screenHorizontal,
              AppSpacing.md,
            ),
            child: AppSearchBar(
              controller: _queryController,
              hintText: 'Search clothes, shoes, accessories…',
              showFilter: true,
              filterActive: state.filter.hasSheetFilters,
              showClear: _queryController.text.isNotEmpty,
              onClear: _clearQuery,
              onFilterTap: _openFilter,
              onSubmitted: _submit,
              onChanged: _onQueryChanged,
            ),
          ),
          Expanded(
            child: SearchResultsView(
              state: state,
              onSortSelected: controller.setSort,
              onRetry: controller.search,
              onFavoriteTap: controller.toggleFavorite,
              onResetFilter: controller.resetFilter,
            ),
          ),
        ],
      ),
    );
  }
}
