import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_search_bar.dart';
import '../navigation/search_navigation.dart';
import '../providers/search_providers.dart';
import '../widgets/search_view.dart';

/// Search entry screen with recent searches and suggestions.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _queryController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(searchControllerProvider.notifier).loadIdle();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    await ref.read(searchControllerProvider.notifier).submitQuery(trimmed);
    if (!mounted) return;
    SearchNavigation.openResults(context, query: trimmed);
  }

  void _onQueryChanged(String value) {
    ref.read(searchControllerProvider.notifier).setQuery(value);
    ref.read(searchControllerProvider.notifier).loadSuggestions(value);
  }

  Future<void> _onQueryTap(String query) async {
    _queryController.text = query;
    await _submit(query);
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
        title: Text('Search', style: AppTextStyles.headlineSmall),
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
              focusNode: _focusNode,
              hintText: 'Search clothes, shoes, accessories…',
              autofocus: true,
              onChanged: _onQueryChanged,
              onSubmitted: _submit,
            ),
          ),
          Expanded(
            child: SearchView(
              state: state,
              onQueryTap: _onQueryTap,
              onRemoveRecent: controller.removeRecent,
              onClearRecent: controller.clearRecent,
              onRetry: controller.loadIdle,
            ),
          ),
        ],
      ),
    );
  }
}
