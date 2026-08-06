import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../product/models/product.dart';
import '../repository/local_store_repository.dart';
import '../repository/mock_store_repository.dart';
import '../repository/store_repository.dart';
import '../state/store_state.dart';

/// Pass `--dart-define=USE_MOCK_STORE=true` to force the mock repository.
const bool kUseMockStoreRepository = bool.fromEnvironment(
  'USE_MOCK_STORE',
  defaultValue: false,
);

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  if (kUseMockStoreRepository) {
    return MockStoreRepository();
  }
  return LocalStoreRepository();
});

final storeDetailControllerProvider =
    NotifierProvider.family<StoreDetailController, StoreDetailState, String>(
      StoreDetailController.new,
    );

class StoreDetailController extends Notifier<StoreDetailState> {
  StoreDetailController(this.storeId);

  final String storeId;

  @override
  StoreDetailState build() => const StoreDetailState.initial();

  Future<void> load() async {
    if (state.status == StoreDetailStatus.loading) return;
    state = state.copyWith(
      status: StoreDetailStatus.loading,
      clearError: true,
    );
    await _fetch(status: StoreDetailStatus.ready);
  }

  Future<void> refresh() async {
    state = state.copyWith(
      status: StoreDetailStatus.refreshing,
      clearError: true,
    );
    await _fetch(status: StoreDetailStatus.ready);
  }

  Future<void> _fetch({required StoreDetailStatus status}) async {
    try {
      final repo = ref.read(storeRepositoryProvider);
      final store = await repo.fetchStore(storeId);
      final products = await repo.fetchStoreProducts(storeId);
      final isFollowing = await repo.isFollowing(storeId);
      state = state.copyWith(
        status: status,
        store: store.copyWith(productCount: products.length),
        products: products,
        isFollowing: isFollowing,
      );
    } catch (error) {
      state = state.copyWith(
        status: StoreDetailStatus.failure,
        errorMessage: error.toString(),
        clearStore: state.store == null,
      );
    }
  }

  Future<void> toggleFollow() async {
    final wasFollowing = state.isFollowing;
    final store = state.store;
    state = state.copyWith(
      isFollowing: !wasFollowing,
      store: store?.copyWith(
        followersCount: wasFollowing
            ? (store.followersCount - 1).clamp(0, 1 << 30)
            : store.followersCount + 1,
      ),
    );

    try {
      await ref.read(storeRepositoryProvider).toggleFollow(storeId);
    } catch (error) {
      state = state.copyWith(
        isFollowing: wasFollowing,
        store: store,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> toggleFavorite(Product product) async {
    await ref.read(storeRepositoryProvider).toggleFavorite(product.id);
    state = state.copyWith(
      products: state.products
          .map(
            (p) =>
                p.id == product.id ? p.copyWith(isFavorite: !p.isFavorite) : p,
          )
          .toList(),
    );
  }
}
