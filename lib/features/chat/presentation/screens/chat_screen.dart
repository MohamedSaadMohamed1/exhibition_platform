import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../shared/models/chat_model.dart';
import '../../../../shared/providers/providers.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  /// Cached user ID — used in dispose() where ref is no longer safe to call.
  String? _userId;

  /// Older messages loaded via pagination (prepended to the real-time stream).
  List<MessageModel> _olderMessages = [];
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _markAsRead();
    _scrollController.addListener(_onScroll);
    // Track active chat for notification suppression.
    // Must run post-frame so ref is fully available.
    Future.microtask(() {
      if (!mounted) return;
      _userId = ref.read(currentUserIdProvider);
      ref.read(activeChatIdProvider.notifier).state = widget.chatId;
      if (_userId != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .update({'activeChat': widget.chatId}).catchError((_) {});
      }
    });
  }

  @override
  void dispose() {
    // Do NOT use ref here — Riverpod may have already invalidated it.
    // Use the cached _userId to clear the Firestore field directly.
    if (_userId != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .update({'activeChat': FieldValue.delete()}).catchError((_) {});
    }
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // reversed list: maxScrollExtent = oldest messages end
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadOlderMessages();
    }
  }

  Future<void> _loadOlderMessages() async {
    if (_isLoadingMore) return;
    final notifier = ref.read(chatMessagesProvider(widget.chatId).notifier);
    final before = ref.read(chatMessagesProvider(widget.chatId));
    if (!before.hasMore) return;

    setState(() => _isLoadingMore = true);
    await notifier.loadMore();

    if (mounted) {
      final after = ref.read(chatMessagesProvider(widget.chatId));
      setState(() {
        _olderMessages = after.messages;
        _isLoadingMore = false;
      });
    }
  }

  void _markAsRead() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    await ref.read(chatRepositoryProvider).markMessagesAsRead(
          chatId: widget.chatId,
          userId: userId,
        );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    setState(() => _isSending = true);
    _messageController.clear();

    final result = await ref.read(chatRepositoryProvider).sendMessage(
          chatId: widget.chatId,
          senderId: userId,
          text: text,
        );

    setState(() => _isSending = false);

    result.fold(
      (failure) {
        _messageController.text = text;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send message: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    // Real-time stream for the newest messages
    final messagesAsync = ref.watch(chatMessagesStreamProvider(widget.chatId));
    final chatAsync = ref.watch(chatStreamProvider(widget.chatId));
    final currentUserId = ref.watch(currentUserIdProvider);

    // Auto mark-as-read whenever new messages arrive while screen is open
    ref.listen(chatMessagesStreamProvider(widget.chatId), (_, next) {
      next.whenData((_) => _markAsRead());
    });

    return Scaffold(
      appBar: AppBar(
        title: chatAsync.when(
          data: (chat) => Text(
            chat?.getOtherParticipantName(currentUserId ?? '') ?? 'Chat',
          ),
          loading: () => const Text('Chat'),
          error: (_, __) => const Text('Chat'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const LoadingWidget(),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (streamMessages) {
                // Merge: real-time (newest) + older paginated messages (deduplicated)
                final streamIds = streamMessages.map((m) => m.id).toSet();
                final uniqueOlder = _olderMessages
                    .where((m) => !streamIds.contains(m.id))
                    .toList();
                final allMessages = [...streamMessages, ...uniqueOlder];

                if (allMessages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Start the conversation!'),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: allMessages.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Pagination spinner at the top (oldest end)
                    if (_isLoadingMore && index == allMessages.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    final message = allMessages[index];
                    final isMe = message.senderId == currentUserId;
                    return _MessageBubble(message: message, isMe: isMe);
                  },
                );
              },
            ),
          ),
          // Input
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: AppColors.grey800,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.grey800,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.createdAt.toChatTime(),
              style: TextStyle(
                color: isMe ? Colors.white70 : AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
