import 'category.dart';

/// Catalog browse payload for the Homescreen Category tab.
class CatalogFeed {
  const CatalogFeed({this.categories = const []});

  final List<Category> categories;

  bool get isEmpty => categories.isEmpty;

  CatalogFeed copyWith({List<Category>? categories}) {
    return CatalogFeed(categories: categories ?? this.categories);
  }
}
