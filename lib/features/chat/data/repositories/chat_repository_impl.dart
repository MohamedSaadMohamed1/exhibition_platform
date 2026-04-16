import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../shared/models/chat_model.dart';
import '../../domain/repositories/chat_repository.dart';

/// Implementation of ChatRepository
class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  ChatRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _chatsCollection =>
      _firestore.collection(FirestoreCollections.chats);

  CollectionReference<Map<String, dynamic>> _messagesCollection(String chatId) =>
      _chatsCollection.doc(chatId).collection(FirestoreCollections.messages);

  @override
  Future<Either<Failure, ChatModel>> getOrCreateChat({
    required String currentUserId,
    required String otherUserId,
    required String currentUserName,
    required String otherUserName,
    String? currentUserImage,
    String? otherUserImage,
  }) async {
    try {
      final chatId = ChatModel.generateChatId(currentUserId, otherUserId);
      final chatDoc = await _chatsCollection.doc(chatId).get();

      if (chatDoc.exists) {
        return Right(ChatModel.fromFirestore(chatDoc));
      }

      // Create new chat
      final chat = ChatModel(
        id: chatId,
        participants: [currentUserId, otherUserId],
        participantNames: {
          currentUserId: currentUserName,
          otherUserId: otherUserName,
        },
        participantImages: {
          if (currentUserImage != null) currentUserId: currentUserImage,
          if (otherUserImage != null) otherUserId: otherUserImage,
        },
        unreadCount: {
          currentUserId: 0,
          otherUserId: 0,
        },
        createdAt: DateTime.now(),
      );

      await _chatsCollection.doc(chatId).set(chat.toFirestore());

      return Right(chat);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<ChatModel>>> getUserChats(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _chatsCollection
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageAt', descending: true)
          .limit(limit)
          .get();

      return Right(snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList());
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<MessageModel>>> getMessages(
    String chatId, {
    int limit = 50,
    String? lastMessageId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _messagesCollection(chatId)
          .orderBy('createdAt', descending: true);

      if (lastMessageId != null) {
        final lastDoc = await _messagesCollection(chatId).doc(lastMessageId).get();
        query = query.startAfterDocument(lastDoc);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      final messages = snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc, chatId))
          .toList();

      return Right(messages);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, MessageModel>> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    MessageType type = MessageType.text,
    String? mediaUrl,
  }) async {
    try {
      final messageId = _uuid.v4();

      final message = MessageModel(
        id: messageId,
        chatId: chatId,
        senderId: senderId,
        text: text,
        type: type,
        mediaUrl: mediaUrl,
        readBy: [senderId],
        createdAt: DateTime.now(),
      );

      // Fetch chat participants first (regular get, outside batch)
      final chatDoc = await _chatsCollection.doc(chatId).get();
      final participants = List<String>.from(chatDoc.data()!['participants']);
      final otherUserId = participants.firstWhere((id) => id != senderId);

      // Use batch write (atomic, no read needed inside)
      final batch = _firestore.batch();

      batch.set(
        _messagesCollection(chatId).doc(messageId),
        message.toFirestore(),
      );

      batch.update(_chatsCollection.doc(chatId), {
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessageBy': senderId,
        'unreadCount.$otherUserId': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      return Right(message);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead({
    required String chatId,
    required String userId,
  }) async {
    try {
      // Update chat unread count
      await _chatsCollection.doc(chatId).update({
        'unreadCount.$userId': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mark messages as read
      final unreadMessages = await _messagesCollection(chatId)
          .where('senderId', isNotEqualTo: userId)
          .limit(100)
          .get();

      final batch = _firestore.batch();

      for (final doc in unreadMessages.docs) {
        final readBy = List<String>.from(doc.data()['readBy'] ?? []);
        if (!readBy.contains(userId)) {
          batch.update(doc.reference, {
            'readBy': FieldValue.arrayUnion([userId]),
            'readAt.$userId': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();

      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, int>> getTotalUnreadCount(String userId) async {
    try {
      final snapshot = await _chatsCollection
          .where('participants', arrayContains: userId)
          .get();

      int totalUnread = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final unreadCount = data['unreadCount'] as Map<String, dynamic>?;
        if (unreadCount != null) {
          totalUnread += (unreadCount[userId] ?? 0) as int;
        }
      }

      return Right(totalUnread);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Stream<List<ChatModel>> watchUserChats(String userId) {
    return _chatsCollection
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<ChatModel?> watchChat(String chatId) {
    return _chatsCollection.doc(chatId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ChatModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<MessageModel>> watchMessages(String chatId) {
    return _messagesCollection(chatId)
        .orderBy('createdAt', descending: true)
        .limit(AppConstants.chatPageSize)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc, chatId))
          .toList();
    });
  }

  @override
  Stream<int> watchUnreadCount(String userId) {
    return _chatsCollection
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      int totalUnread = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final unreadCount = data['unreadCount'] as Map<String, dynamic>?;
        if (unreadCount != null) {
          totalUnread += (unreadCount[userId] ?? 0) as int;
        }
      }
      return totalUnread;
    });
  }
}
