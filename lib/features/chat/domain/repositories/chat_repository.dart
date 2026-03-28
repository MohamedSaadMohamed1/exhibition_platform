import 'package:dartz/dartz.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../shared/models/chat_model.dart';

/// Chat repository interface
abstract class ChatRepository {
  Future<Either<Failure, ChatModel>> getOrCreateChat({
    required String currentUserId,
    required String otherUserId,
    required String currentUserName,
    required String otherUserName,
    String? currentUserImage,
    String? otherUserImage,
  });

  Future<Either<Failure, List<ChatModel>>> getUserChats(
    String userId, {
    int limit = 20,
  });

  Future<Either<Failure, List<MessageModel>>> getMessages(
    String chatId, {
    int limit = 50,
    String? lastMessageId,
  });

  Future<Either<Failure, MessageModel>> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    MessageType type = MessageType.text,
    String? mediaUrl,
  });

  Future<Either<Failure, void>> markMessagesAsRead({
    required String chatId,
    required String userId,
  });

  Future<Either<Failure, int>> getTotalUnreadCount(String userId);

  Stream<List<ChatModel>> watchUserChats(String userId);

  Stream<ChatModel?> watchChat(String chatId);

  Stream<List<MessageModel>> watchMessages(String chatId);

  Stream<int> watchUnreadCount(String userId);
}
