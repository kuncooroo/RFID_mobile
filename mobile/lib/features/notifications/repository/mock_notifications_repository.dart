import '../models/notification.dart';
import 'notifications_repository.dart';

/// Seeded notifications repository for tests and UI demos.
class MockNotificationsRepository implements NotificationsRepository {
  MockNotificationsRepository({
    this.delay = const Duration(milliseconds: 300),
    this.shouldFail = false,
    List<AppNotification>? seed,
  }) {
    _sharedItems ??= List<AppNotification>.from(seed ?? _defaults);
  }

  static final MockNotificationsRepository shared =
      MockNotificationsRepository();

  final Duration delay;
  final bool shouldFail;

  static List<AppNotification>? _sharedItems;

  List<AppNotification> get _items => _sharedItems!;

  static void resetShared({List<AppNotification>? seed}) {
    _sharedItems = List<AppNotification>.from(seed ?? _defaults);
  }

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Unable to load notifications');

    final sorted = List<AppNotification>.from(_items)
      ..sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
    return List<AppNotification>.unmodifiable(sorted);
  }

  @override
  Future<int> unreadCount() async {
    return _items.where((n) => !n.isRead).length;
  }

  @override
  Future<void> markRead(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final index = _items.indexWhere((n) => n.id == id);
    if (index < 0) return;
    _items[index] = _items[index].copyWith(isRead: true);
  }

  @override
  Future<void> markAllRead() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
  }
}

final _defaults = <AppNotification>[
  AppNotification(
    id: 'n1',
    title: 'Order shipped',
    body: 'Your order #KU-1042 is on the way with J&T Express.',
    type: NotificationType.order,
    createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
    referenceId: 'ord-1042',
    referenceType: 'order',
  ),
  AppNotification(
    id: 'n2',
    title: 'New message',
    body: 'Maison Noir: Your order has been shipped!',
    type: NotificationType.chat,
    createdAt: DateTime.now().subtract(const Duration(minutes: 14)),
    referenceId: 'thread-1',
    referenceType: 'chat',
  ),
  AppNotification(
    id: 'n3',
    title: 'Weekend promo',
    body: 'Get 20% off selected fashion items this weekend only.',
    type: NotificationType.promo,
    imageUrl: 'https://picsum.photos/seed/kutuku-promo/200/200',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    referenceType: 'promo',
  ),
  AppNotification(
    id: 'n4',
    title: 'Payment success',
    body: 'Payment for order #KU-1039 was successful.',
    type: NotificationType.payment,
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    referenceId: 'ord-1039',
    referenceType: 'order',
  ),
  AppNotification(
    id: 'n5',
    title: 'Order delivered',
    body: 'Your order #KU-1031 was delivered successfully.',
    type: NotificationType.order,
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 8)),
    referenceId: 'ord-1031',
    referenceType: 'order',
  ),
  AppNotification(
    id: 'n6',
    title: 'Security tip',
    body: 'Never share your OTP or password with anyone.',
    type: NotificationType.system,
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
];
