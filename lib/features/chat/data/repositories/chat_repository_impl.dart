import '../entities/chat_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/chat_firestore_datasource.dart';

/// Chat repository implementation - implements abstract repository from domain
class ChatRepositoryImpl implements ChatRepository {
  final ChatFirestoreDataSource _dataSource;

  ChatRepositoryImpl(this._dataSource);

  @override
  Future<({Chat?, Failure?}) getChat(String chatId) {
    return _dataSource.getChat(chatId);
  }

  @override
  Future<({String? chatId, Failure?}) getOrCreateChat({
    required String otherUserId,
    String? listingId,
  }) {
    return _dataSource.getOrCreateChat(
      otherUserId: otherUserId,
      listingId: listingId,
    );
  }

  @override
  Stream<List<Chat>> getMyChats({int limit = 20}) {
    return _dataSource.getMyChats(limit: limit);
  }

  @override
  Stream<List<Message>> getMessages(String chatId, {int limit = 50}) {
    return _dataSource.getMessages(chatId, limit: limit);
  }

  @override
  Future<({String? messageId, Failure?}) sendMessage({
    required String chatId,
    required String content,
    MessageType type,
  }) {
    return _dataSource.sendMessage(
      chatId: chatId,
      senderId: _dataSource.currentUserId ?? '',
      content: content,
      type: type,
    );
  }

  @override
  Future<Failure?> deleteChat(String chatId) {
    return _dataSource.deleteChat(chatId);
  }

  @override
  Future<Failure?> markMessagesAsSeen(String chatId, List<String> messageIds) {
    return _dataSource.markMessagesAsSeen(chatId, messageIds);
  }

  @override
  Future<Failure?> resetUnreadCount(String chatId) {
    return _dataSource.resetUnreadCount(chatId);
  }

  @override
  Stream<int> getUnreadCountStream() {
    return _dataSource.getUnreadCountStream();
  }

  @override
  Stream<int> getUnreadChatsCountStream() {
    return _dataSource.getUnreadCountStream();
  }
}