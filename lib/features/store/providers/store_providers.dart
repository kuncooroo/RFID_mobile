import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    try {
      final repo = ref.read(storeRepositoryProvider);
      final store = await repo.fetchStore(storeId);
      final products = await repo.fetchStoreProducts(storeId);
      final isFollowing = repo is MockStoreRepository
          ? repo.isFollowing(storeId)
          : false;
      state = state.copyWith(
        status: StoreDetailStatus.ready,
        store: store,
        products: products,
        isFollowing: isFollowing,
      );
    } catch (error) {
      state = state.copyWith(
        status: StoreDetailStatus.failure,
        errorMessage: error.toString(),
        clearStore: true,
      );
    }
  }

  Future<void> toggleFollow() async {
    final wasFollowing = state.isFollowing;
    state = state.copyWith(isFollowing: !wasFollowing);

    try {
      await ref.read(storeRepositoryProvider).toggleFollow(storeId);
    } catch (error) {
      state = state.copyWith(
        isFollowing: wasFollowing,
        errorMessage: error.toString(),
      );
    }
  }
}
