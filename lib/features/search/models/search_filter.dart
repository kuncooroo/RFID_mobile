/// Search / filter criteria from Search and Filter By bottom sheet.
class SearchFilter {
  const SearchFilter({
    this.query = '',
    this.categoryId,
    this.sort = SearchSort.all,
    this.minPrice,
    this.maxPrice,
    this.colorIds = const [],
    this.locations = const [],
    this.storeId,
  });

  final String query;
  final String? categoryId;
  final SearchSort sort;
  final double? minPrice;
  final double? maxPrice;
  final List<String> colorIds;
  final List<String> locations;
  final String? storeId;

  /// Filters applied from the Filter By sheet (excludes sort chips).
  bool get hasSheetFilters =>
      (minPrice != null && minPrice! > 0) ||
      maxPrice != null ||
      colorIds.isNotEmpty ||
      locations.isNotEmpty ||
      (categoryId != null && categoryId!.isNotEmpty) ||
      (storeId != null && storeId!.isNotEmpty);

  bool get hasActiveFilters => hasSheetFilters || sort != SearchSort.all;

  int get sheetFilterCount {
    var count = 0;
    if (minPrice != null && minPrice! > 0) count++;
    if (maxPrice != null) count++;
    if (colorIds.isNotEmpty) count++;
    if (locations.isNotEmpty) count++;
    if (categoryId != null && categoryId!.isNotEmpty) count++;
    return count;
  }

  SearchFilter copyWith({
    String? query,
    String? categoryId,
    SearchSort? sort,
    double? minPrice,
    double? maxPrice,
    List<String>? colorIds,
    List<String>? locations,
    String? storeId,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearCategoryId = false,
    bool clearStoreId = false,
  }) {
    return SearchFilter(
      query: query ?? this.query,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      sort: sort ?? this.sort,
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      colorIds: colorIds ?? this.colorIds,
      locations: locations ?? this.locations,
      storeId: clearStoreId ? null : (storeId ?? this.storeId),
    );
  }

  factory SearchFilter.fromJson(Map<String, dynamic> json) {
    return SearchFilter(
      query: json['query'] as String? ?? '',
      categoryId: json['category_id']?.toString(),
      sort: SearchSort.fromJson(json['sort'] as String?),
      minPrice: (json['min_price'] as num?)?.toDouble(),
      maxPrice: (json['max_price'] as num?)?.toDouble(),
      colorIds: json['color_ids'] is List
          ? (json['color_ids'] as List).map((e) => e.toString()).toList()
          : const [],
      locations: json['locations'] is List
          ? (json['locations'] as List).map((e) => e.toString()).toList()
          : const [],
      storeId: json['store_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'category_id': categoryId,
      'sort': sort.toJson(),
      'min_price': minPrice,
      'max_price': maxPrice,
      'color_ids': colorIds,
      'locations': locations,
      'store_id': storeId,
    };
  }
}

class SearchColorOption {
  const SearchColorOption({
    required this.id,
    required this.name,
    required this.hex,
  });

  final String id;
  final String name;
  final String hex;
}

class SearchFilterOptions {
  const SearchFilterOptions({
    this.colors = const [],
    this.locations = const [],
    this.minPrice = 0,
    this.maxPrice = 300,
  });

  final List<SearchColorOption> colors;
  final List<String> locations;
  final double minPrice;
  final double maxPrice;
}

enum SearchSort {
  all,
  latest,
  mostPopular,
  cheapest;

  static SearchSort fromJson(String? value) {
    return SearchSort.values.firstWhere(
      (e) => e.name == value || e.apiValue == value,
      orElse: () => SearchSort.all,
    );
  }

  String toJson() => apiValue;

  String get apiValue => switch (this) {
    SearchSort.all => 'all',
    SearchSort.latest => 'latest',
    SearchSort.mostPopular => 'most_popular',
    SearchSort.cheapest => 'cheapest',
  };

  String get label => switch (this) {
    SearchSort.all => 'All',
    SearchSort.latest => 'Latest',
    SearchSort.mostPopular => 'Most Popular',
    SearchSort.cheapest => 'Cheapest',
  };
}
