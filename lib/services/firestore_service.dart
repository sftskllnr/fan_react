import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fan_react/models/match/match.dart';
import 'package:fan_react/models/user/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Match> get matchesCollection =>
      _firestore.collection('matches').withConverter<Match>(
            fromFirestore: (snapshot, _) => Match.fromMap(snapshot.data()!),
            toFirestore: (match, _) => match.toMap(),
          );

  CollectionReference<UserProfile> get usersCollection =>
      _firestore.collection('users').withConverter<UserProfile>(
          fromFirestore: (snapshot, _) => UserProfile.fromMap(snapshot.data()!),
          toFirestore: (user, _) => user.toMap());

  Future<void> addMatch(Match match) async {
    await matchesCollection.doc(match.id.toString()).set(match);
  }

  Future<void> initializeMatch(int matchId) async {
    final docRef = FirebaseFirestore.instance
        .collection('matches')
        .doc(matchId.toString());
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'reactions': {
          'loved': Random().nextInt(100),
          'angry': Random().nextInt(100),
          'disappointed': Random().nextInt(100),
          'cool': Random().nextInt(100),
          'shocked': Random().nextInt(100),
        },
      });
    }
  }

  Future<void> updateReaction(int matchId, String reactionType) async {
    final docRef = matchesCollection.doc(matchId.toString());

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception('Match does not exist!');
      }

      Map<String, int> reactions =
          Map<String, int>.from(snapshot.data()?.reactions ??
              {
                'loved': Random().nextInt(100),
                'angry': Random().nextInt(100),
                'disappointed': Random().nextInt(100),
                'cool': Random().nextInt(100),
                'shocked': Random().nextInt(100),
              });

      reactions[reactionType] = (reactions[reactionType] ?? 0) + 1;
      transaction.update(docRef, {'reactions': reactions});
    });
  }

  Future<void> addComment(
      int matchId, String userId, String commentText) async {
    final userProfile = await getUserProfile(userId);
    if (userProfile == null) {
      throw Exception('User profile not found for userId: $userId');
    }

    final commentsCollection =
        matchesCollection.doc(matchId.toString()).collection('comments').doc();
    await commentsCollection.set({
      'userId': userId,
      'userName': userProfile.name,
      'commentText': commentText,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteComment(
      int matchId, String commentId, String currentUserId) async {
    final commentRef = matchesCollection
        .doc(matchId.toString())
        .collection('comments')
        .doc(commentId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(commentRef);
      if (!snapshot.exists) {
        throw Exception('Comment does not exist!');
      }

      final commentData = snapshot.data() as Map<String, dynamic>;
      if (commentData['userId'] != currentUserId) {
        throw Exception('Only the author can delete this comment!');
      }
      transaction.delete(commentRef);
    });
  }

  Future<List<Map<String, dynamic>>> getComments(int matchId) async {
    final querySnapshot = await matchesCollection
        .doc(matchId.toString())
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['commentId'] = doc.id;
      return data;
    }).toList();
  }

  Future<Match?> getMatch(int matchId) async {
    final docSnapshot = await matchesCollection.doc(matchId.toString()).get();
    return docSnapshot.data();
  }

  Stream<List<Match>> getMatches() {
    return matchesCollection
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<UserProfile> createUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated to create a profile.');
    }

    final random = Random();
    final userId = user.uid;
    final randomNumber = random.nextInt(100000);
    final name = 'user#$randomNumber';
    final avatar = 'https://i.pravatar.cc/150?img=${random.nextInt(70) + 1}';

    final userProfile = UserProfile(id: userId, name: name, avatar: avatar);
    await usersCollection.doc(userId).set(userProfile);
    return userProfile;
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    final docSnapshot = await usersCollection.doc(userId).get();
    return docSnapshot.data();
  }
}
