import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../shared/models/chat_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../../../router/routes.dart';
import '../providers/chat_provider.dart';

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserIdProvider);

    if (currentUserId == null) return const SizedBox.shrink();

    final chatsAsync = ref.watch(userChatsStreamProvider(currentUserId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return const EmptyStateWidget(
              title: 'No messages yet',
              subtitle: 'Start a conversation with an organizer',
              icon: Icons.chat_bubble_outline,
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return _ChatListItem(
                chat: chat,
                currentUserId: currentUserId,
                onTap: () => context.push(
                  AppRoutes.chat.replaceFirst(':chatId', chat.id),
                ),
              );
            },
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, _) => AppErrorWidget(message: error.toString()),
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final ChatModel chat;
  final String currentUserId;
  final VoidCallback onTap;

  const _ChatListItem({
    required this.chat,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final otherName = chat.getOtherParticipantName(currentUserId);
    final otherImage = chat.getOtherParticipantImage(currentUserId);
    final unreadCount = chat.getUnreadCount(currentUserId);
    final hasUnread = unreadCount > 0;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        backgroundImage: otherImage != null ? NetworkImage(otherImage) : null,
        child: otherImage == null
            ? Text(
                otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              otherName,
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (chat.lastMessageAt != null)
            Text(
              chat.lastMessageAt!.toChatTime(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: hasUnread ? AppColors.primary : AppColors.textSecondary,
                  ),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              chat.lastMessage ?? 'No messages',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: hasUnread ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          if (hasUnread)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
