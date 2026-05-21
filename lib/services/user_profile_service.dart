import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for managing user profiles with Firestore.
/// Handles CRUD operations, avatar uploads, and display name changes.
class UserProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user's profile data
  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.exists ? doc.data() : null;
  }

  /// Update display name
  Future<void> updateDisplayName(String newName) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    if (newName.trim().isEmpty || newName.length > 30) {
      throw Exception('Name must be 1-30 characters');
    }

    await user.updateDisplayName(newName);
    await _db.collection('users').doc(user.uid).update({
      'displayName': newName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update avatar URL
  Future<void> updateAvatar(String avatarUrl) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _db.collection('users').doc(user.uid).update({
      'avatarUrl': avatarUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete user account and all associated data
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Delete user data from Firestore
    await _db.collection('users').doc(user.uid).delete();

    // Delete auth account
    await user.delete();
  }

  /// Get another user's public profile
  Future<Map<String, dynamic>?> getPublicProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    // Only return public fields
    return {
      'displayName': data['displayName'],
      'avatarUrl': data['avatarUrl'],
      'rating': data['rating'],
      'gamesPlayed': data['gamesPlayed'],
    };
  }
}
