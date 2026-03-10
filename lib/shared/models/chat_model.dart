import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/enums.dart';

/// Chat model representing a conversation between users
class ChatModel {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final Map<String, String> participantImages;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageBy;
  final Map<String, int> unreadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ChatModel({
    required this.id,
    required this.participants,
    this.participantNames = const {},
    this.participantImages = const {},
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageBy,
    this.unreadCount = const {},
    required this.createdAt,
    this.updatedAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String? ?? '',
      participants: (json['participants'] as List<dynamic>?)?.cast<String>() ?? [],
      participantNames: (json['participantNames'] as Map<String, dynamic>?)?.cast<String, String>() ?? {},
      participantImages: (json['participantImages'] as Map<String, dynamic>?)?.cast<String, String>() ?? {},
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: json['lastMessageAt'] != null ? _parseDateTime(json['lastMessageAt']) : null,
      lastMessageBy: json['lastMessageBy'] as String?,
      unreadCount: (json['unreadCount'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as int),
          ) ?? {},
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? _parseDateTime(json['updatedAt']) : null,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    } else if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
      'participantNames': participantNames,
      'participantImages': participantImages,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'lastMessageBy': lastMessageBy,
      'unreadCount': unreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json['createdAt'] = FieldValue.serverTimestamp();
    json['updatedAt'] = FieldValue.serverTimestamp();
    return json;
  }

  String getOtherParticipantId(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => participants.first,
    );
  }

  String getOtherParticipantName(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantNames[otherId] ?? 'Unknown';
  }

  String? getOtherParticipantImage(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantImages[otherId];
  }

  int getUnreadCount(String userId) => unreadCount[userId] ?? 0;

  bool hasUnread(String userId) => getUnreadCount(userId) > 0;

  static String generateChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  ChatModel copyWith({
    String? id,
    List<String>? participants,
    Map<String, String>? participantNames,
    Map<String, String>? participantImages,
    String? lastMessage,
    DateTime? lastMessageAt,
    String? lastMessageBy,
    Map<String, int>? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      participantNames: participantNames ?? this.participantNames,
      participantImages: participantImages ?? this.participantImages,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageBy: lastMessageBy ?? this.lastMessageBy,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Message model
class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final MessageType type;
  final String? mediaUrl;
  final List<String> readBy;
  final Map<String, DateTime> readAt;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    this.type = MessageType.text,
    this.mediaUrl,
    this.readBy = const [],
    this.readAt = const {},
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? '',
      chatId: json['chatId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      type: _parseMessageType(json['type']),
      mediaUrl: json['mediaUrl'] as String?,
      readBy: (json['readBy'] as List<dynamic>?)?.cast<String>() ?? [],
      readAt: (json['readAt'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, _parseDateTime(v)),
          ) ?? {},
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    } else if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }

  static MessageType _parseMessageType(dynamic value) {
    if (value is String) {
      return MessageType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => MessageType.text,
      );
    }
    return MessageType.text;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'type': type.name,
      'mediaUrl': mediaUrl,
      'readBy': readBy,
      'readAt': readAt.map((k, v) => MapEntry(k, Timestamp.fromDate(v))),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MessageModel.fromFirestore(DocumentSnapshot doc, String chatId) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel.fromJson({
      'id': doc.id,
      'chatId': chatId,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json.remove('chatId');
    json['createdAt'] = FieldValue.serverTimestamp();
    return json;
  }

  bool isReadBy(String userId) => readBy.contains(userId);
  bool isFromUser(String userId) => senderId == userId;
  bool get isText => type == MessageType.text;
  bool get isImage => type == MessageType.image;
  bool get isFile => type == MessageType.file;

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? text,
    MessageType? type,
    String? mediaUrl,
    List<String>? readBy,
    Map<String, DateTime>? readAt,
    DateTime? createdAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      readBy: readBy ?? this.readBy,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Typing status model
class TypingStatus {
  final String chatId;
  final String userId;
  final bool isTyping;
  final DateTime timestamp;

  const TypingStatus({
    required this.chatId,
    required this.userId,
    required this.isTyping,
    required this.timestamp,
  });

  factory TypingStatus.fromJson(Map<String, dynamic> json) {
    return TypingStatus(
      chatId: json['chatId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      isTyping: json['isTyping'] as bool? ?? false,
      timestamp: _parseDateTime(json['timestamp']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    } else if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'userId': userId,
      'isTyping': isTyping,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
