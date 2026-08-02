import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../product/models/product.dart';
import '../models/home_feed.dart';
import '../repository/home_repository.dart';
import '../repository/local_home_repository.dart';
import '../repository/mock_home_repository.dart';
import '../state/home_state.dart';

/// Pass `--dart-define=USE_MOCK_HOME=true` to force the mock repository.
const bool kUseMockHomeRepository = bool.fromEnvironment(
  'USE_MOCK_HOME',
  defaultValue: false,
);

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  if (kUseMockHomeRepository) {
    return MockHomeRepository();
  }
  return LocalHomeRepository();
});

final homeControllerProvider = NotifierProvider<HomeController, HomeState>(
  HomeController.new,
);

class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState.initial();

  Future<void> load() async {
    if (state.status == HomeStatus.loading) return;
    state = state.copyWith(status: HomeStatus.loading, clearError: true);
    await _fetch(status: HomeStatus.ready);
  }

  Future<void> refresh() async {
    state = state.copyWith(status: HomeStatus.refreshing, clearError: true);
    await _fetch(status: HomeStatus.ready);
  }

  Future<void> _fetch({required HomeStatus status}) async {
    try {
      final feed = await ref.read(homeRepositoryProvider).fetchHomeFeed();
      state = state.copyWith(
        status: status,
        feed: feed,
        selectedCategoryId:
            state.selectedCategoryId ?? _defaultCategoryId(feed),
      );
    } catch (error) {
      state = state.copyWith(
        status: HomeStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  void setSegment(HomeSegment segment) {
    if (state.segment == segment) return;
    state = state.copyWith(segment: segment);
  }

  void selectCategory(String? categoryId) {
    if (categoryId == null || categoryId == 'cat-all') {
      state = state.copyWith(clearCategory: true);
      return;
    }
    state = state.copyWith(selectedCategoryId: categoryId);
  }

  Future<void> toggleFavorite(Product product) async {
    await ref.read(homeRepositoryProvider).toggleFavorite(product.id);
    final feed = state.feed;
    List<Product> mapList(List<Product> items) {
      return items
          .map(
            (p) =>
                p.id == product.id ? p.copyWith(isFavorite: !p.isFavorite) : p,
          )
          .toList();
    }

    state = state.copyWith(
      feed: feed.copyWith(
        newArrivals: mapList(feed.newArrivals),
        categoryProducts: mapList(feed.categoryProducts),
      ),
    );
  }

  String? _defaultCategoryId(HomeFeed feed) {
    if (feed.categories.isEmpty) return null;
    final all = feed.categories.where((c) => c.id == 'cat-all');
    if (all.isNotEmpty) return all.first.id;
    return feed.categories.first.id;
  }
}
