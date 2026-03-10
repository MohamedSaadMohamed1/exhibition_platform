import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../shared/models/chat_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../data/repositories/chat_repository_impl.dart';

/// Chats state
class ChatsState {
  final List<ChatModel> chats;
  final bool isLoading;
  final String? errorMessage;

  const ChatsState({
    this.chats = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ChatsState copyWith({
    List<ChatModel>? chats,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ChatsState(
      chats: chats ?? this.chats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// User chats notifier
class UserChatsNotifier extends FamilyNotifier<ChatsState, String> {
  late final ChatRepository _chatRepository;

  @override
  ChatsState build(String userId) {
    _chatRepository = ref.watch(chatRepositoryProvider);
    _loadChats(userId);
    return const ChatsState(isLoading: true);
  }

  Future<void> _loadChats(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _chatRepository.getUserChats(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (chats) {
        state = state.copyWith(
          chats: chats,
          isLoading: false,
        );
      },
    );
  }

  Future<void> refresh() async {
    await _loadChats(arg);
  }
}

/// User chats provider
final userChatsProvider =
    NotifierProvider.family<UserChatsNotifier, ChatsState, String>(() {
  return UserChatsNotifier();
});

/// Messages state
class MessagesState {
  final List<MessageModel> messages;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final bool isSending;

  const MessagesState({
    this.messages = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.errorMessage,
    this.isSending = false,
  });

  MessagesState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    bool? isSending,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      isSending: isSending ?? this.isSending,
    );
  }
}

/// Chat messages notifier
class ChatMessagesNotifier extends FamilyNotifier<MessagesState, String> {
  late final ChatRepository _chatRepository;

  @override
  MessagesState build(String chatId) {
    _chatRepository = ref.watch(chatRepositoryProvider);
    _loadMessages(chatId);
    return const MessagesState(isLoading: true);
  }

  Future<void> _loadMessages(String chatId, {bool loadMore = false}) async {
    if (state.isLoading && !loadMore) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    final lastMessageId = loadMore && state.messages.isNotEmpty
        ? state.messages.last.id
        : null;

    final result = await _chatRepository.getMessages(
      chatId,
      lastMessageId: lastMessageId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (messages) {
        state = state.copyWith(
          messages: loadMore ? [...state.messages, ...messages] : messages,
          isLoading: false,
          hasMore: messages.length >= 50,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    await _loadMessages(arg, loadMore: true);
  }

  Future<bool> sendMessage({
    required String senderId,
    required String text,
    MessageType type = MessageType.text,
    String? mediaUrl,
  }) async {
    state = state.copyWith(isSending: true);

    final result = await _chatRepository.sendMessage(
      chatId: arg,
      senderId: senderId,
      text: text,
      type: type,
      mediaUrl: mediaUrl,
    );

    state = state.copyWith(isSending: false);

    if (result.isRight()) {
      // Add message to state
      final message = result.getOrElse(() => throw Exception());
      state = state.copyWith(
        messages: [message, ...state.messages],
      );
      return true;
    }
    return false;
  }

  Future<void> markAsRead(String userId) async {
    await _chatRepository.markMessagesAsRead(
      chatId: arg,
      userId: userId,
    );
  }
}

/// Chat messages provider
final chatMessagesProvider =
    NotifierProvider.family<ChatMessagesNotifier, MessagesState, String>(() {
  return ChatMessagesNotifier();
});

/// User chats stream provider
final userChatsStreamProvider =
    StreamProvider.family<List<ChatModel>, String>((ref, userId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchUserChats(userId);
});

/// Chat messages stream provider
final chatMessagesStreamProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, chatId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchMessages(chatId);
});

/// Total unread count provider
final totalUnreadCountProvider =
    FutureProvider.family<int, String>((ref, userId) async {
  final repository = ref.watch(chatRepositoryProvider);
  final result = await repository.getTotalUnreadCount(userId);
  return result.fold((l) => 0, (r) => r);
});

/// Unread count stream provider
final unreadCountStreamProvider =
    StreamProvider.family<int, String>((ref, userId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchUnreadCount(userId);
});

/// Get or create chat provider
final getOrCreateChatProvider = FutureProvider.family<ChatModel?, ({
  String currentUserId,
  String otherUserId,
  String currentUserName,
  String otherUserName,
  String? currentUserImage,
  String? otherUserImage,
})>((ref, params) async {
  final repository = ref.watch(chatRepositoryProvider);
  final result = await repository.getOrCreateChat(
    currentUserId: params.currentUserId,
    otherUserId: params.otherUserId,
    currentUserName: params.currentUserName,
    otherUserName: params.otherUserName,
    currentUserImage: params.currentUserImage,
    otherUserImage: params.otherUserImage,
  );
  return result.fold((l) => null, (r) => r);
});
