import 'dart:async';
import 'package:fan_react/const/const.dart';
import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/main.dart';
import 'package:fan_react/models/achievement/achievement.dart';
import 'package:fan_react/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';
import 'package:smart_snackbars/enums/animate_from.dart';
import 'package:smart_snackbars/smart_snackbars.dart';

class Achievements extends StatefulWidget {
  const Achievements({super.key});

  @override
  State<Achievements> createState() => _AchievementsState();
}

class _AchievementsState extends State<Achievements> {
  late StreamSubscription<List<Achievement>> _achievementSubscription;
  List<Achievement> _achievements = [];

  @override
  void initState() {
    super.initState();

    _initializeAchievementListening();
    _checkLoginStreak();
  }

  Future<void> _initializeAchievementListening() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await firestoreService.initializeAchievements(user.uid);

    _achievementSubscription =
        firestoreService.getUserAchievementsStream(user.uid).listen(
      (achievements) {
        if (mounted) {
          setState(() => _achievements = achievements);
          for (var achievement in achievements) {
            if (achievement.isUnlocked) {
              // ScaffoldMessenger.of(context)
              //     .showSnackBar(_snackBar(context, achievement.name, tapView));
            }
          }
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
      await firestoreService.checkAchievements(user.uid, 'login');
    }
  }

  void tapView() {
    setState(() {
      selectedIndexGlobal.value = 2;
    });
    Navigator.of(context).push(
      MaterialPageRoute(builder: (builder) => const HomeScreen()),
    );
  }

  Widget achievItem(Achievement achievement, String svgPath, double textWidth) {
    return InkWell(
      onTap: () => showTemplatedSnackbar(context, achievement.name, tapView),
      child: Container(
        padding: const EdgeInsets.all(padding),
        margin: const EdgeInsets.only(top: padding / 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(buttonsRadius),
        ),
        child: Row(
          children: [
            SvgPicture.asset(svgPath, width: 50, height: 50),
            const SizedBox(width: padding / 2),
            SizedBox(
              width: textWidth,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(achievement.name, style: size15semibold),
                    Text(achievement.description,
                        style: size14medium.copyWith(color: G_700))
                  ]),
            ),
            const Spacer(),
            achievement.percentage / 100 == 1
                ? SizedBox(
                    width: 50, height: 50, child: SvgPicture.asset(tickCircle))
                : SizedBox(
                    child: CircularPercentIndicator(
                      radius: 25,
                      lineWidth: padding / 4,
                      backgroundColor: G_200,
                      progressColor: ACCENT_PRIMARY,
                      percent: achievement.percentage / 100 == 0
                          ? 0.02
                          : achievement.percentage / 100,
                      center: Text(
                          '${achievement.percentage.toStringAsFixed(0)}%',
                          style:
                              size12semibold.copyWith(color: ACCENT_PRIMARY)),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.sizeOf(context).height;
    double screenWidth = MediaQuery.sizeOf(context).width;
    double textWidth = screenWidth * 0.45;

    return Scaffold(
      appBar: AppBar(
          centerTitle: false, title: Text(achievement, style: size24bold)),
      body: Container(
        color: G_400,
        height: screenHeight,
        width: screenWidth,
        child: ListView.builder(
          itemCount: _achievements.length,
          padding: const EdgeInsets.symmetric(vertical: padding / 2),
          itemBuilder: (context, index) {
            String svgPath = achievementsListSvg[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: padding),
              child: achievItem(_achievements[index], svgPath, textWidth),
            );
          },
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

void showTemplatedSnackbar(
    BuildContext context, String achievementName, Function() onTap) {
  SmartSnackBars.showTemplatedSnackbar(
      context: context,
      backgroundColor: ACCENT_PRIMARY,
      persist: true,
      animationCurve: Curves.ease,
      animateFrom: AnimateFrom.fromBottom,
      outerPadding: const EdgeInsets.symmetric(
          vertical: padding * 6, horizontal: padding),
      titleWidget:
          Text(newAchievUnlock, style: size15bold.copyWith(color: G_100)),
      subTitleWidget: Text('$achievementName - well done!',
          style: size14medium.copyWith(color: G_100)),
      trailing: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.all(padding / 2),
            decoration: BoxDecoration(
                color: BACKGROUND_PRIMARY,
                borderRadius: BorderRadius.circular(buttonsRadius)),
            child: Text(view,
                style: size14semibold.copyWith(color: ACCENT_PRIMARY))),
      ));
}

SnackBar _snackBar(
    BuildContext context, String achievementName, Function() onTap) {
  return SnackBar(
    backgroundColor: ACCENT_PRIMARY,
    margin: const EdgeInsets.symmetric(horizontal: padding, vertical: padding),
    padding: const EdgeInsets.all(padding),
    content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(newAchievUnlock, style: size15bold.copyWith(color: G_100)),
      Text('$achievementName - well done!',
          style: size14medium.copyWith(color: G_100))
    ]),
    showCloseIcon: false,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonsRadius)),
    action: SnackBarAction(
        label: view,
        onPressed: onTap,
        backgroundColor: BACKGROUND_PRIMARY,
        textColor: ACCENT_PRIMARY),
    duration: const Duration(seconds: 3),
    actionOverflowThreshold: 0.4,
  );
}
