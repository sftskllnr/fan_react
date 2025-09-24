import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fan_react/models/achievement/achievement.dart';
import 'package:fan_react/models/comment/comment.dart';
import 'package:fan_react/models/match/match.dart';
import 'package:fan_react/models/user/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  CollectionReference<Match> get matchesCollection =>
      _firestore.collection('matches').withConverter<Match>(
            fromFirestore: (snapshot, _) => Match.fromMap(snapshot.data()!),
            toFirestore: (match, _) => match.toMap(),
          );

  CollectionReference<UserProfile> get usersCollection =>
      _firestore.collection('users').withConverter<UserProfile>(
          fromFirestore: (snapshot, _) => UserProfile.fromMap(snapshot.data()!),
          toFirestore: (user, _) => user.toMap());

  CollectionReference get achievementsCollection =>
      _firestore.collection('achievements');

  CollectionReference get userAchievementsCollection =>
      _firestore.collection('users').doc(user?.uid).collection('achievements');

  CollectionReference get userLeagueInteractionsCollection => _firestore
      .collection('users')
      .doc(user?.uid)
      .collection('leagueInteractions');

  CollectionReference get userLoginHistoryCollection =>
      _firestore.collection('users').doc(user?.uid).collection('loginHistory');

  CollectionReference get userReportsCollection =>
      _firestore.collection('users').doc(user?.uid).collection('reportedUsers');

  CollectionReference get userReportedCommentsCollection => _firestore
      .collection('users')
      .doc(user?.uid)
      .collection('reportedComments');

  Future<List<UserProfile>> getBlockedUsers() async {
    if (user == null) {
      throw Exception('User must be authenticated to retrieve blocked users.');
    }

    try {
      final snapshot = await userReportsCollection.get();
      final blockedUserIds = snapshot.docs
          .map((doc) =>
              (doc.data() as Map<String, dynamic>)['reportedUserId'] as String)
          .toList();

      if (blockedUserIds.isEmpty) {
        return [];
      }

      final blockedUsers = await Future.wait(
        blockedUserIds.map((userId) async {
          final userProfile = await getUserProfile(userId);
          return userProfile;
        }),
      );

      return blockedUsers.whereType<UserProfile>().toList();
    } catch (e) {
      debugPrint('Error fetching blocked users: $e');
      return [];
    }
  }

  Future<void> unblockUser(String blockedUserId) async {
    if (user == null) {
      throw Exception('User must be authenticated to unblock a user.');
    }

    final reportRef = userReportsCollection.doc(blockedUserId);
    final snapshot = await reportRef.get();

    if (!snapshot.exists) {
      throw Exception(
          'User $blockedUserId is not blocked by the current user.');
    }

    await reportRef.delete();
  }

  Future<void> reportComment(
      String matchId, String commentId, String userId) async {
    if (user == null) {
      throw Exception('User must be authenticated to report a comment.');
    }

    final reportRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('reportedComments')
        .doc(commentId);
    await reportRef.set({
      'matchId': matchId,
      'commentId': commentId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<String>> getReportedCommentIds(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('reportedComments')
          .get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      debugPrint('Error fetching reported comments: $e');
      return [];
    }
  }

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
          .where('userId', isEqualTo: user?.uid)
          .limit(1)
          .get(const GetOptions(source: Source.server));
      final currentReactionDoc = currentReactionQuery.docs.isNotEmpty
          ? currentReactionQuery.docs.first
          : null;
      final currentReactionType =
          currentReactionDoc?.data()['reactionType'] as String?;

      bool isCancellation = false;
      if (currentReactionDoc != null && currentReactionType == reactionType) {
        transaction.delete(currentReactionDoc.reference);
        reactions[currentReactionType ?? ''] =
            (reactions[currentReactionType] ?? 0) - 1;
        transaction.update(docRef, {'reactions': reactions});
        isCancellation = true;
      } else {
        if (currentReactionDoc != null && currentReactionType != null) {
          debugPrint('Removing existing reaction: $currentReactionType');
          transaction.delete(currentReactionDoc.reference);
          reactions[currentReactionType] =
              (reactions[currentReactionType] ?? 0) - 1;
        }

        final newReactionRef = userReactionsCollection.doc();
        transaction.set(newReactionRef, {
          'userId': user?.uid,
          'reactionType': reactionType,
          'timestamp': FieldValue.serverTimestamp(),
        });
        reactions[reactionType] = (reactions[reactionType] ?? 0) + 1;

        transaction.update(docRef, {'reactions': reactions});
      }

      await checkAchievements(user!.uid, 'reaction',
          matchId: matchId,
          reactionType: reactionType,
          isCancellation: isCancellation);
    }).catchError((e) {
      debugPrint('Transaction failed: $e');
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
        matchesCollection.doc(matchId.toString()).collection('comments');
    final comment = Comment(
      userId: userId,
      userName: userProfile.name,
      commentText: commentText,
      timestamp: DateTime.now(),
    );

    // Fetch the "First Word" achievement document outside the transaction
    final firstWordAchievement =
        await achievementsCollection.doc('first_word').get();
    if (!firstWordAchievement.exists) {
      debugPrint('Warning: First Word achievement document does not exist.');
    }

    await _firestore.runTransaction((transaction) async {
      // Read: Check if this is the first comment
      final commentSnapshot = await commentsCollection.limit(1).get();
      final isFirstComment = commentSnapshot.docs.isEmpty;

      // Read: Fetch the user's achievement progress
      final userAchievementRef = userAchievementsCollection.doc('first_word');
      final userAchievementSnapshot = await transaction.get(userAchievementRef);

      // Write: Add the new comment
      final commentRef = commentsCollection.doc();
      transaction.set(commentRef, {
        ...comment.toMap(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Write: Update the "First Word" achievement if this is the first comment
      if (isFirstComment && firstWordAchievement.exists) {
        if (userAchievementSnapshot.exists) {
          final data = userAchievementSnapshot.data() as Map<String, dynamic>;
          final currentProgress = data['progress'] ?? 0;
          final targetValue = data['targetValue'] as int;
          final newProgress = (currentProgress + 1).clamp(0, targetValue);

          transaction.update(userAchievementRef, {
            'progress': newProgress,
            'isUnlocked': newProgress >= targetValue,
          });
        } else {
          // Initialize the achievement if it doesn't exist
          final achievementData =
              firstWordAchievement.data() as Map<String, dynamic>;
          transaction.set(userAchievementRef, {
            ...achievementData,
            'progress': 1,
            'streak': 0,
            'isUnlocked': 1 >= (achievementData['targetValue'] as int),
          });
        }
      }
    }).catchError((e) {
      debugPrint('Error adding comment: $e');
      throw e;
    });

    await checkAchievements(userId, 'comment', matchId: matchId);
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

  Future<void> reportUser(String reportedUserId) async {
    if (user == null) {
      throw Exception('User must be authenticated to report a user.');
    }

    final reportRef = userReportsCollection.doc(reportedUserId);
    await reportRef.set({
      'reportedUserId': reportedUserId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getCommentsMatch(int matchId) {
    if (user == null) {
      throw Exception('User must be authenticated to retrieve comments.');
    }

    return CombineLatestStream.combine2(
      matchesCollection
          .doc(matchId.toString())
          .collection('comments')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      userReportsCollection.snapshots(),
      (QuerySnapshot<Map<String, dynamic>> commentsSnapshot,
          QuerySnapshot<Object?> reportsSnapshot) {
        // Get list of reported user IDs
        final reportedUserIds = reportsSnapshot.docs
            .map((doc) => (doc.data() as Map<String, dynamic>)['reportedUserId']
                as String)
            .toSet();

        // Map comments and filter out those from reported users
        return commentsSnapshot.docs
            .map((doc) {
              final data = doc.data();
              data['commentId'] = doc.id;
              return data;
            })
            .where((data) => !reportedUserIds.contains(data['userId']))
            .toList();
      },
    );
  }

  Future<List<Match>> getMatchesWithUserActivity() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception(
          'User must be authenticated to retrieve matches with activity.');
    }

    final userId = user.uid;
    try {
      // Fetch all matches
      final matchSnapshot = await matchesCollection.get();
      final allMatches = matchSnapshot.docs.map((doc) => doc.data()).toList();

      // Filter matches where user has comments or reactions
      final matchesWithActivity =
          await Future.wait(allMatches.map((match) async {
        final hasComments = await _hasUserComments(match.id, userId);
        final hasReactions = await _hasUserReactions(match.id, userId);
        return hasComments || hasReactions ? match : null;
      }));

      // Remove null entries and sort by date in descending order
      return matchesWithActivity.whereType<Match>().toList()
        ..sort((a, b) => (b.date).compareTo(a.date));
    } catch (e) {
      if (e is FirebaseException && e.code == 'permission-denied') {
        throw Exception(
            'Permission denied. Ensure security rules allow read access to matches.');
      }
      rethrow;
    }
  }

  // Helper methods to check user activity
  Future<bool> _hasUserComments(int matchId, String userId) async {
    final commentsQuery = matchesCollection
        .doc(matchId.toString())
        .collection('comments')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    return (await commentsQuery).docs.isNotEmpty;
  }

  Future<bool> _hasUserReactions(int matchId, String userId) async {
    final reactionsQuery = matchesCollection
        .doc(matchId.toString())
        .collection('userReactions')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    return (await reactionsQuery).docs.isNotEmpty;
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

  Future<void> initializeAchievements(String userId) async {
    if (FirebaseAuth.instance.currentUser == null) {
      throw Exception('User must be authenticated to initialize achievements.');
    }

    try {
      final achievementsSnapshot = await achievementsCollection.get();
      var batch = _firestore.batch();
      int operationCount = 0;

      final userAchievementsSnapshot = await userAchievementsCollection.get();
      final existingAchievementIds =
          userAchievementsSnapshot.docs.map((doc) => doc.id).toSet();

      for (var doc in achievementsSnapshot.docs) {
        final achievementId = doc.id;
        if (!existingAchievementIds.contains(achievementId)) {
          final achievement = Achievement.fromMap(
              doc.data() as Map<String, dynamic>, achievementId);
          final userAchievementRef =
              userAchievementsCollection.doc(achievementId);
          batch.set(
            userAchievementRef,
            {
              ...achievement.toMap(),
              'progress': 0,
              'streak': 0,
            },
            SetOptions(merge: true),
          );
          operationCount++;
        }
        if (operationCount == 500) {
          await batch.commit();
          batch = _firestore.batch();
          operationCount = 0;
        }
      }

      if (operationCount > 0) {
        await batch.commit();
        debugPrint('Achievements initialized for user $userId.');
      } else {
        debugPrint('No new achievements to initialize for user $userId.');
      }
    } catch (e) {
      debugPrint('Error initializing achievements for user $userId: $e');
      rethrow;
    }
  }

  Future<void> updateAchievementProgress(
      String userId, String achievementId, int increment,
      {bool isSequential = false, String lastReaction = ''}) async {
    final userAchievementRef = userAchievementsCollection.doc(achievementId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userAchievementRef);
      if (!snapshot.exists) {
        throw Exception('Achievement not found for user');
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final currentProgress = data['progress'] ?? 0;
      final currentStreak = data['streak'] ?? 0;
      final targetValue = data['targetValue'] as int;
      final newProgress = (currentProgress + increment).clamp(0, targetValue);

      int newStreak = currentStreak;
      if (isSequential && lastReaction == 'shocked' && increment > 0) {
        newStreak = currentStreak + 1;
      } else if (isSequential && increment < 0) {
        newStreak = 0; // Reset streak on cancellation
      }

      transaction.update(userAchievementRef, {
        'progress': newProgress,
        'streak': newStreak,
        'isUnlocked': newProgress >= targetValue ||
            (isSequential && newStreak >= targetValue),
      });
    });
  }

  // Check and update achievements based on an event
  Future<void> checkAchievements(
    String userId,
    String eventType, {
    int matchId = 0,
    String reactionType = '',
    bool isCancellation = false,
  }) async {
    final achievementsSnapshot = await achievementsCollection.get();
    for (var doc in achievementsSnapshot.docs) {
      final achievement =
          Achievement.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      switch (achievement.type) {
        case 'reaction':
          if (eventType == 'reaction' &&
              achievement.name == 'Fan in Love' &&
              reactionType == 'loved') {
            await updateAchievementProgress(
                userId, achievement.id, isCancellation ? -1 : 1);
          } else if (eventType == 'reaction' &&
              achievement.name == 'Mind = Blown') {
            await updateAchievementProgress(
                userId, achievement.id, isCancellation ? -1 : 1,
                isSequential: true, lastReaction: reactionType);
          } else if (eventType == 'reaction' &&
              achievement.name == 'Mood Swing') {
            await updateAchievementProgress(
                userId, achievement.id, isCancellation ? -1 : 1);
          } else if (eventType == 'reaction' &&
              achievement.name == 'Cold Blooded' &&
              !isCancellation) {
            final matchDoc =
                await matchesCollection.doc(matchId.toString()).get();
            if (matchDoc.exists) {
              final matchData = matchDoc.data();
              final totalReactions =
                  matchData?.reactions.values.reduce((a, b) => a + b) ?? 0;
              if (totalReactions == 1) {
                await updateAchievementProgress(userId, achievement.id, 1);
              }
            }
          } else if (eventType == 'reaction' &&
              achievement.name == 'Reaction Master') {
            await updateAchievementProgress(
                userId, achievement.id, isCancellation ? -1 : 1);
          }
          break;
        case 'comment':
          if (eventType == 'comment' && achievement.name == 'Explorer') {
            await updateLeagueInteraction(userId, matchId);
          } else if (eventType == 'comment' &&
              achievement.name == 'Comment Veteran') {
            await updateAchievementProgress(userId, achievement.id, 1);
          }
          break;
        case 'login_streak':
          if (eventType == 'login' && achievement.name == '3-Day Streak') {
            await updateLoginStreak(userId);
          }
          break;
      }
    }
  }

  Future<void> updateLeagueInteraction(String userId, int matchId) async {
    final matchDoc = await matchesCollection.doc(matchId.toString()).get();
    if (matchDoc.exists) {
      final matchData = matchDoc.data();
      final leagueId = matchData?.league.id ?? 0;

      final interactionRef =
          userLeagueInteractionsCollection.doc('uniqueLeagues');
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(interactionRef);
        final data = snapshot.data() as Map<String, dynamic>?;
        final currentLeagues = (data?['leagues'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toSet() ??
            <int>{};
        if (!currentLeagues.contains(leagueId)) {
          currentLeagues.add(leagueId);
          transaction.set(
              interactionRef,
              {
                'leagues': currentLeagues.toList(),
                'updatedAt': FieldValue.serverTimestamp(),
              },
              SetOptions(merge: true));

          // Update Explorer achievement progress
          final explorerAchievement =
              await userAchievementsCollection.doc('explorer').get();
          if (explorerAchievement.exists) {
            final achievementData =
                explorerAchievement.data() as Map<String, dynamic>;
            final currentProgress = achievementData['progress'] ?? 0;
            final targetValue = achievementData['targetValue'] as int;
            final newProgress = currentLeagues.length.clamp(0, targetValue);

            transaction.update(userAchievementsCollection.doc('explorer'), {
              'progress': newProgress,
              'isUnlocked': newProgress >= targetValue,
            });
          }
        }
      });
    }
  }

  // Stream to listen for achievement updates
  Stream<List<Achievement>> getUserAchievementsStream(String userId) {
    return userAchievementsCollection.snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) =>
            Achievement.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
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

  // Update login history and calculate streak
  Future<void> updateLoginStreak(String userId) async {
    final loginRef =
        userLoginHistoryCollection.doc(DateTime.now().toIso8601String());
    await loginRef.set({
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _firestore.runTransaction((transaction) async {
      final loginSnapshots = await userLoginHistoryCollection
          .orderBy('timestamp', descending: true)
          .limit(4) // Fetch last 4 logins to check 3-day streak
          .get();
      final loginTimestamps = loginSnapshots.docs
          .map((doc) =>
              (doc.data() as Map<String, dynamic>)['timestamp']?.toDate() ??
              DateTime.now())
          .toList();

      if (loginTimestamps.length < 2) return; // Not enough logins for streak

      loginTimestamps.sort((a, b) => a.compareTo(b)); // Sort ascending
      int streak = 1;
      for (int i = 1; i < loginTimestamps.length; i++) {
        final diff =
            loginTimestamps[i].difference(loginTimestamps[i - 1]).inDays;
        if (diff == 1) {
          streak++;
        } else if (diff > 1) {
          break; // Reset streak if a day is missed
        }
      }

      // Update 3-Day Streak achievement
      final streakAchievement =
          await userAchievementsCollection.doc('3_day_streak').get();
      if (streakAchievement.exists) {
        final achievementData =
            streakAchievement.data() as Map<String, dynamic>;
        final targetValue = achievementData['targetValue'] as int;
        transaction.update(userAchievementsCollection.doc('3_day_streak'), {
          'streak': streak,
          'isUnlocked': streak >= targetValue,
        });
      }
    });
  }
}
