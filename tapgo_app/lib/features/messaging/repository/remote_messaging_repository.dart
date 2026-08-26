import '../../../src/network/api_client.dart';
import '../../../src/network/api_endpoints.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import 'messaging_repository.dart';

class RemoteMessagingRepository implements MessagingRepository {
  RemoteMessagingRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  @override
  Future<List<Conversation>> fetchConversations() async {
    final list = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.conversations,
      parser: _asList,
    );
    return list.map(Conversation.fromJson).toList();
  }

  @override
  Future<List<Message>> fetchMessages(String threadId) async {
    final list = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.conversationMessages(threadId),
      parser: _asList,
    );
    return list.map(Message.fromJson).toList();
  }

  @override
  Future<void> markConversationRead(String threadId) async {
    await _api.post<dynamic>(ApiEndpoints.conversationRead(threadId));
  }

  @override
  Future<Message> sendMessage({
    required String threadId,
    required String body,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.conversationMessages(threadId),
      data: {'body': body},
      parser: _asMap,
    );
    return Message.fromJson(data);
  }

  @override
  Future<Conversation> findOrCreateStoreConversation({
    required String storeId,
    required String storeName,
    String? avatarUrl,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.conversations,
      data: {'store_id': int.tryParse(storeId) ?? storeId},
      parser: _asMap,
    );
    final conversation = Conversation.fromJson(data);
    return conversation.copyWith(
      title: conversation.title.isEmpty ? storeName : conversation.title,
      avatarUrl: avatarUrl ?? conversation.avatarUrl,
    );
  }

  List<Map<String, dynamic>> _asList(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}
