import '../models/conversation.dart';
import '../models/message.dart';
import 'messaging_repository.dart';

/// Seeded messaging repository for tests and UI demos.
class MockMessagingRepository implements MessagingRepository {
  MockMessagingRepository({
    this.delay = const Duration(milliseconds: 350),
    this.shouldFail = false,
    this.currentMemberId = 'member-1',
  })  : _conversations = List<Conversation>.from(_seedConversations),
        _messages = Map<String, List<Message>>.from(
          _seedMessages.map(
            (key, value) => MapEntry(key, List<Message>.from(value)),
          ),
        );

  final Duration delay;
  final bool shouldFail;
  final String currentMemberId;

  final List<Conversation> _conversations;
  final Map<String, List<Message>> _messages;
  int _messageCounter = 100;

  @override
  Future<List<Conversation>> fetchConversations() async {
    await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Unable to load conversations');
    final sorted = List<Conversation>.from(_conversations)
      ..sort((a, b) {
        final aTime = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
    return List<Conversation>.unmodifiable(sorted);
  }

  @override
  Future<List<Message>> fetchMessages(String threadId) async {
    await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Unable to load messages');

    final index = _conversations.indexWhere((c) => c.id == threadId);
    if (index != -1 && _conversations[index].unreadCount > 0) {
      _conversations[index] = _conversations[index].copyWith(unreadCount: 0);
    }

    final items = _messages[threadId] ?? const <Message>[];
    return List<Message>.unmodifiable(items);
  }

  @override
  Future<Message> sendMessage({
    required String threadId,
    required String body,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (shouldFail) throw StateError('Unable to send message');

    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Message body cannot be empty');
    }

    final now = DateTime.now();
    final message = Message(
      id: 'msg-${++_messageCounter}',
      conversationId: threadId,
      body: trimmed,
      senderId: currentMemberId,
      senderType: MessageSenderType.member,
      sentAt: now,
      isRead: true,
    );

    final threadMessages = _messages.putIfAbsent(threadId, () => <Message>[]);
    threadMessages.add(message);

    final conversationIndex = _conversations.indexWhere((c) => c.id == threadId);
    if (conversationIndex != -1) {
      _conversations[conversationIndex] = _conversations[conversationIndex]
          .copyWith(
            lastMessage: trimmed,
            lastMessageAt: now,
            unreadCount: 0,
          );
    }

    return message;
  }
}

const _currentMemberId = 'member-1';

final _seedConversations = <Conversation>[
  Conversation(
    id: 'thread-1',
    title: 'Maison Noir',
    avatarUrl: 'https://picsum.photos/seed/kutuku-store-1/200/200',
    lastMessage: 'Your order has been shipped!',
    lastMessageAt: DateTime.now().subtract(const Duration(minutes: 12)),
    unreadCount: 2,
    storeId: 'store-1',
    isOnline: true,
  ),
  Conversation(
    id: 'thread-2',
    title: 'Tempo Official',
    avatarUrl: 'https://picsum.photos/seed/kutuku-store-2/200/200',
    lastMessage: 'Thanks for your purchase. Enjoy your new watch!',
    lastMessageAt: DateTime.now().subtract(const Duration(hours: 3)),
    unreadCount: 0,
    storeId: 'store-2',
  ),
  Conversation(
    id: 'thread-3',
    title: 'Bloom Beauty',
    avatarUrl: 'https://picsum.photos/seed/kutuku-store-3/200/200',
    lastMessage: 'Hi! Is the lipstick set still available?',
    lastMessageAt: DateTime.now().subtract(const Duration(hours: 5)),
    unreadCount: 1,
    storeId: 'store-3',
    isOnline: true,
  ),
  Conversation(
    id: 'thread-4',
    title: 'Stride Athletics',
    avatarUrl: 'https://picsum.photos/seed/kutuku-store-4/200/200',
    lastMessage: 'We have your size in stock now.',
    lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
    unreadCount: 0,
    storeId: 'store-4',
  ),
  Conversation(
    id: 'thread-5',
    title: 'Kutuku Support',
    avatarUrl: 'https://picsum.photos/seed/kutuku-support/200/200',
    lastMessage: 'How can we help you today?',
    lastMessageAt: DateTime.now().subtract(const Duration(days: 2)),
    unreadCount: 0,
    memberId: 'support-1',
  ),
];

final _seedMessages = <String, List<Message>>{
  'thread-1': [
    Message(
      id: 'msg-1',
      conversationId: 'thread-1',
      body: 'Hi! I placed order #KTK-1042 yesterday.',
      senderId: _currentMemberId,
      senderType: MessageSenderType.member,
      sentAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    Message(
      id: 'msg-2',
      conversationId: 'thread-1',
      body: 'Hello! Thanks for shopping with Maison Noir.',
      senderId: 'store-1',
      senderType: MessageSenderType.store,
      sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
      isRead: true,
    ),
    Message(
      id: 'msg-3',
      conversationId: 'thread-1',
      body: 'Your order has been packed and will ship today.',
      senderId: 'store-1',
      senderType: MessageSenderType.store,
      sentAt: DateTime.now().subtract(const Duration(minutes: 45)),
      isRead: false,
    ),
    Message(
      id: 'msg-4',
      conversationId: 'thread-1',
      body: 'Your order has been shipped!',
      senderId: 'store-1',
      senderType: MessageSenderType.store,
      sentAt: DateTime.now().subtract(const Duration(minutes: 12)),
      isRead: false,
    ),
  ],
  'thread-2': [
    Message(
      id: 'msg-5',
      conversationId: 'thread-2',
      body: 'Does the Classic Leather Watch come with a warranty?',
      senderId: _currentMemberId,
      senderType: MessageSenderType.member,
      sentAt: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
    ),
    Message(
      id: 'msg-6',
      conversationId: 'thread-2',
      body: 'Yes — all Tempo watches include a 2-year warranty.',
      senderId: 'store-2',
      senderType: MessageSenderType.store,
      sentAt: DateTime.now().subtract(const Duration(hours: 4, minutes: 30)),
      isRead: true,
    ),
    Message(
      id: 'msg-7',
      conversationId: 'thread-2',
      body: 'Thanks for your purchase. Enjoy your new watch!',
      senderId: 'store-2',
      senderType: MessageSenderType.store,
      sentAt: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
    ),
  ],
  'thread-3': [
    Message(
      id: 'msg-8',
      conversationId: 'thread-3',
      body: 'Hi! Is the lipstick set still available?',
      senderId: 'store-3',
      senderType: MessageSenderType.store,
      sentAt: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
    ),
  ],
  'thread-4': [
    Message(
      id: 'msg-9',
      conversationId: 'thread-4',
      body: 'Do you have size 42 in the City Runner?',
      senderId: _currentMemberId,
      senderType: MessageSenderType.member,
      sentAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      isRead: true,
    ),
    Message(
      id: 'msg-10',
      conversationId: 'thread-4',
      body: 'We have your size in stock now.',
      senderId: 'store-4',
      senderType: MessageSenderType.store,
      sentAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ],
  'thread-5': [
    Message(
      id: 'msg-11',
      conversationId: 'thread-5',
      body: 'How can we help you today?',
      senderId: 'support-1',
      senderType: MessageSenderType.system,
      sentAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ],
};
