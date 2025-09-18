import 'dart:async';
import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/models/achievement/achievement.dart';
import 'package:fan_react/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Achievements extends StatefulWidget {
  const Achievements({super.key});

  @override
  State<Achievements> createState() => _AchievementsState();
}

class _AchievementsState extends State<Achievements> {
  late FirestoreService _firestoreService;
  late StreamSubscription<List<Achievement>> _achievementSubscription;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _initializeAchievementListening();
    _checkLoginStreak();
  }

  Future<void> _initializeAchievementListening() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestoreService.initializeAchievements(user.uid);

    _achievementSubscription =
        _firestoreService.getUserAchievementsStream(user.uid).listen(
      (achievements) {
        for (var achievement in achievements) {
          if (achievement.isUnlocked) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Achievement Unlocked: ${achievement.name} - ${achievement.percentage.toStringAsFixed(0)}%')),
              );
            }
          }
          // You can use achievement.percentage here to update UI
        }
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading achievements: $error')),
          );
        }
      },
    );
  }

  Future<void> _checkLoginStreak() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestoreService.checkAchievements(user.uid, 'login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          achievement,
          style: size24bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _achievementSubscription.cancel();
    super.dispose();
  }
}
