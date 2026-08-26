import '../../product/models/product.dart';
import '../models/search_filter.dart';

enum SearchStatus { initial, loading, ready, searching, failure }

class SearchState {
  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.filter = const SearchFilter(),
    this.recentQueries = const [],
    this.popularQueries = const [],
    this.suggestions = const [],
    this.results = const [],
    this.filterOptions = const SearchFilterOptions(),
    this.isFilterOpen = false,
    this.errorMessage,
  });

  const SearchState.initial() : this();

  final SearchStatus status;
  final String query;
  final SearchFilter filter;
  final List<String> recentQueries;
  final List<String> popularQueries;
  final List<String> suggestions;
  final List<Product> results;
  final SearchFilterOptions filterOptions;
  final bool isFilterOpen;
  final String? errorMessage;

  bool get isLoading =>
      status == SearchStatus.initial ||
      status == SearchStatus.loading ||
      status == SearchStatus.searching;

  bool get hasFailed => status == SearchStatus.failure;

  bool get hasResults => results.isNotEmpty;

  bool get isEmptyResults => status == SearchStatus.ready && results.isEmpty;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    SearchFilter? filter,
    List<String>? recentQueries,
    List<String>? popularQueries,
    List<String>? suggestions,
    List<Product>? results,
    SearchFilterOptions? filterOptions,
    bool? isFilterOpen,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      recentQueries: recentQueries ?? this.recentQueries,
      popularQueries: popularQueries ?? this.popularQueries,
      suggestions: suggestions ?? this.suggestions,
      results: results ?? this.results,
      filterOptions: filterOptions ?? this.filterOptions,
      isFilterOpen: isFilterOpen ?? this.isFilterOpen,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
