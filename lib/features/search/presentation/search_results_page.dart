import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_search_bar.dart';
import '../navigation/search_navigation.dart';
import '../providers/search_providers.dart';
import '../widgets/search_results_view.dart';

/// Search results screen with sort chips and filter bottom sheet.
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
    await ref.read(searchControllerProvider.notifier).submitQuery(trimmed);
  }

  Future<void> _openFilter() async {
    final controller = ref.read(searchControllerProvider.notifier);
    final currentFilter = ref.read(searchControllerProvider).filter;
    controller.setFilterOpen(true);

    final result = await SearchNavigation.openFilterSheet(
      context,
      initialFilter: currentFilter,
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
              onFilterTap: _openFilter,
              onSubmitted: _submit,
              onChanged: controller.setQuery,
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
