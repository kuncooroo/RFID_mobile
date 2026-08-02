import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../product/models/product.dart';
import '../models/search_filter.dart';
import '../repository/local_search_repository.dart';
import '../repository/mock_search_repository.dart';
import '../repository/search_repository.dart';
import '../state/search_state.dart';

/// Pass `--dart-define=USE_MOCK_SEARCH=true` to force the mock repository.
const bool kUseMockSearchRepository = bool.fromEnvironment(
  'USE_MOCK_SEARCH',
  defaultValue: true,
);

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  if (kUseMockSearchRepository) {
    return MockSearchRepository();
  }
  return LocalSearchRepository();
});

final searchControllerProvider =
    NotifierProvider<SearchController, SearchState>(SearchController.new);

class SearchController extends Notifier<SearchState> {
  @override
  SearchState build() => const SearchState.initial();

  Future<void> loadIdle() async {
    if (state.status == SearchStatus.loading) return;
    state = state.copyWith(status: SearchStatus.loading, clearError: true);
    try {
      final recent = await ref.read(searchRepositoryProvider).fetchRecent();
      state = state.copyWith(
        status: SearchStatus.ready,
        recentQueries: recent,
      );
    } catch (error) {
      state = state.copyWith(
        status: SearchStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> loadSuggestions(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(suggestions: const []);
      return;
    }

    try {
      final suggestions = await ref
          .read(searchRepositoryProvider)
          .fetchSuggestions(trimmed);
      state = state.copyWith(suggestions: suggestions);
    } catch (_) {
      state = state.copyWith(suggestions: const []);
    }
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  Future<void> submitQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    state = state.copyWith(
      query: trimmed,
      filter: state.filter.copyWith(query: trimmed),
      clearError: true,
    );

    await ref.read(searchRepositoryProvider).saveRecentQuery(trimmed);
    final recent = await ref.read(searchRepositoryProvider).fetchRecent();
    state = state.copyWith(recentQueries: recent);
    await search();
  }

  Future<void> search() async {
    state = state.copyWith(status: SearchStatus.searching, clearError: true);
    try {
      final filter = state.filter.copyWith(query: state.query);
      final results = await ref.read(searchRepositoryProvider).search(filter);
      state = state.copyWith(
        status: SearchStatus.ready,
        filter: filter,
        results: results,
      );
    } catch (error) {
      state = state.copyWith(
        status: SearchStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  void setSort(SearchSort sort) {
    if (state.filter.sort == sort) return;
    state = state.copyWith(filter: state.filter.copyWith(sort: sort));
    search();
  }

  void setFilterOpen(bool open) {
    state = state.copyWith(isFilterOpen: open);
  }

  Future<void> applyFilter(SearchFilter filter) async {
    state = state.copyWith(
      filter: filter.copyWith(query: state.query),
      isFilterOpen: false,
    );
    await search();
  }

  Future<void> resetFilter() async {
    state = state.copyWith(
      filter: SearchFilter(query: state.query),
      isFilterOpen: false,
    );
    await search();
  }

  Future<void> clearRecent() async {
    try {
      await ref.read(searchRepositoryProvider).clearRecent();
      state = state.copyWith(recentQueries: const []);
    } catch (error) {
      state = state.copyWith(
        status: SearchStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> removeRecent(String query) async {
    try {
      await ref.read(searchRepositoryProvider).removeRecentQuery(query);
      final recent = await ref.read(searchRepositoryProvider).fetchRecent();
      state = state.copyWith(recentQueries: recent);
    } catch (error) {
      state = state.copyWith(
        status: SearchStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  void initializeResults({required String query, SearchFilter? filter}) {
    state = state.copyWith(
      query: query,
      filter: (filter ?? state.filter).copyWith(query: query),
    );
  }

  Future<void> toggleFavorite(Product product) async {
    final results = state.results
        .map(
          (p) =>
              p.id == product.id ? p.copyWith(isFavorite: !p.isFavorite) : p,
        )
        .toList();
    state = state.copyWith(results: results);
  }
}
