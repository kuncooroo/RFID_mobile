import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/favorite.dart';
import '../repository/favorites_repository.dart';
import '../repository/local_favorites_repository.dart';
import '../repository/mock_favorites_repository.dart';
import '../state/favorites_state.dart';

/// Pass `--dart-define=USE_MOCK_FAVORITES=true` to force the mock repository.
const bool kUseMockFavoritesRepository = bool.fromEnvironment(
  'USE_MOCK_FAVORITES',
  defaultValue: false,
);

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  if (kUseMockFavoritesRepository) {
    return MockFavoritesRepository();
  }
  return LocalFavoritesRepository();
});

final favoritesControllerProvider =
    NotifierProvider<FavoritesController, FavoritesState>(
      FavoritesController.new,
    );

class FavoritesController extends Notifier<FavoritesState> {
  @override
  FavoritesState build() => const FavoritesState.initial();

  Future<void> load() async {
    if (state.status == FavoritesStatus.loading) return;
    state = state.copyWith(status: FavoritesStatus.loading, clearError: true);
    await _fetch(status: FavoritesStatus.ready);
  }

  Future<void> refresh() async {
    state = state.copyWith(
      status: FavoritesStatus.refreshing,
      clearError: true,
    );
    await _fetch(status: FavoritesStatus.ready);
  }

  Future<void> _fetch({required FavoritesStatus status}) async {
    try {
      final items = await ref
          .read(favoritesRepositoryProvider)
          .fetchFavorites();
      state = state.copyWith(status: status, items: items);
    } catch (error) {
      state = state.copyWith(
        status: FavoritesStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> remove(Favorite favorite) async {
    final previous = state.items;
    state = state.copyWith(
      items: previous
          .where((item) => item.productId != favorite.productId)
          .toList(),
    );

    try {
      await ref
          .read(favoritesRepositoryProvider)
          .removeFavorite(favorite.productId);
    } catch (error) {
      state = state.copyWith(
        items: previous,
        status: FavoritesStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> clearAll() async {
    final previous = state.items;
    state = state.copyWith(items: const []);
    try {
      await ref.read(favoritesRepositoryProvider).clearFavorites();
    } catch (error) {
      state = state.copyWith(
        items: previous,
        status: FavoritesStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }
}
