import '../models/favorite.dart';

enum FavoritesStatus { initial, loading, refreshing, ready, failure }

class FavoritesState {
  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  const FavoritesState.initial() : this();

  final FavoritesStatus status;
  final List<Favorite> items;
  final String? errorMessage;

  bool get isLoading =>
      status == FavoritesStatus.initial || status == FavoritesStatus.loading;

  bool get isRefreshing => status == FavoritesStatus.refreshing;

  bool get hasFailed => status == FavoritesStatus.failure;

  bool get isEmpty => items.isEmpty;

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<Favorite>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
