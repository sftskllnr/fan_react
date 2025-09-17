import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fan_react/models/comment/comment.dart';
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

  // Future<void> addMatchesList(List<Match> matches) async {
  //   final batch = _firestore.batch();

  //   for (final match in matches) {
  //     final docRef = matchesCollection.doc(match.id.toString());
  //     final docSnapshot = await docRef.get();
  //     if (!docSnapshot.exists) {
  //       batch.set(docRef, match);
  //     }
  //   }
  //   batch.commit();
  // }

  Future<void> addMatchesList(List<Match> matches) async {
    final existingIds = (await matchesCollection.limit(1).get())
        .docs
        .map((doc) => doc.id)
        .toSet();

    WriteBatch batch = _firestore.batch();
    int operationCount = 0;

    for (final match in matches) {
      if (!existingIds.contains(match.id.toString())) {
        final docRef = matchesCollection.doc(match.id.toString());
        batch.set(docRef, match);
        operationCount++;

        if (operationCount == 500) {
          await batch.commit();
          batch = _firestore.batch();
          operationCount = 0;
        }
      }
    }

    if (operationCount > 0) {
      await batch.commit();
    }
  }

  Future<void> updateReaction(int matchId, String reactionType) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated to add a reaction.');
    }

    final docRef = matchesCollection.doc(matchId.toString());
    final userReactionsCollection = docRef.collection('userReactions');

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception('Match does not exist!');
      }

      final reactions = Map<String, int>.from(snapshot.data()!.reactions);

      final currentReactionQuery = await userReactionsCollection
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get(const GetOptions(source: Source.server));
      final currentReactionDoc = currentReactionQuery.docs.isNotEmpty
          ? currentReactionQuery.docs.first
          : null;
      final currentReactionType =
          currentReactionDoc?.data()['reactionType'] as String?;

      if (currentReactionDoc != null && currentReactionType != null) {
        transaction.delete(currentReactionDoc.reference);
        reactions[currentReactionType] =
            (reactions[currentReactionType] ?? 0) - 1;
      }

      final newReactionRef = userReactionsCollection.doc();
      transaction.set(newReactionRef, {
        'userId': user.uid,
        'reactionType': reactionType,
        'timestamp': FieldValue.serverTimestamp(),
      });
      reactions[reactionType] = (reactions[reactionType] ?? 0) + 1;

      transaction.update(docRef, {'reactions': reactions});
    });
  }

  Future<bool> hasUserReacted(int matchId, String reactionType) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final userReactionsCollection =
        matchesCollection.doc(matchId.toString()).collection('userReactions');
    final querySnapshot = await userReactionsCollection
        .where('userId', isEqualTo: user.uid)
        .where('reactionType', isEqualTo: reactionType)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> addComment(
      int matchId, String userId, String commentText) async {
    final userProfile = await getUserProfile(userId);
    if (userProfile == null) {
      throw Exception('User profile not found for userId: $userId');
    }

    final commentsCollection =
        matchesCollection.doc(matchId.toString()).collection('comments').doc();
    final comment = Comment(
      userId: userId,
      userName: userProfile.name,
      commentText: commentText,
      timestamp: DateTime.now(),
    );
    await commentsCollection.set(comment.toJson()
      ..['timestamp'] =
          FieldValue.serverTimestamp()); // Override with server timestamp
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

  Stream<Match> getMatchStream(int matchId) {
    return matchesCollection
        .doc(matchId.toString())
        .snapshots()
        .map((snapshot) {
      final matchData = snapshot.data();
      if (matchData == null) {
        throw Exception('Match data is null for matchId: $matchId');
      }
      return matchData;
    });
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
