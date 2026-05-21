import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Real-time chat service for in-game messaging between matched players.
class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const int _maxMessageLength = 500;

  /// Send a message in a match chat room
  Future<void> sendMessage(String matchId, String userId, String text) async {
    if (text.isEmpty || text.length > _maxMessageLength) return;

    await _db.collection('matches').doc(matchId).collection('messages').add({
      'senderId': userId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });

    // Update last message preview on match document
    await _db.collection('matches').doc(matchId).update({
      'lastMessage': text.substring(0, 50),
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get message stream for a match
  Stream<QuerySnapshot> getMessages(String matchId) {
    return _db
        .collection('matches')
        .doc(matchId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  /// Mark all messages as read for a user
  Future<void> markAsRead(String matchId, String userId) async {
    final unread = await _db
        .collection('matches')
        .doc(matchId)
        .collection('messages')
        .where('read', isEqualTo: false)
        .where('senderId', isNotEqualTo: userId)
        .get();

    for (final doc in unread.docs) {
      await doc.reference.update({'read': true});
    }
  }

  /// Delete a message (soft delete)
  Future<void> deleteMessage(String matchId, String messageId, String userId) async {
    final msgRef = _db
        .collection('matches')
        .doc(matchId)
        .collection('messages')
        .doc(messageId);

    final msg = await msgRef.get();
    if (msg.exists && msg.data()?['senderId'] == userId) {
      await msgRef.update({
        'deleted': true,
        'text': '[Message deleted]',
      });
    }
  }
}
