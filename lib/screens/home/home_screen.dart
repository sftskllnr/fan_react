import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/screens/achievement/achievement.dart';
import 'package:fan_react/screens/history/history.dart';
import 'package:fan_react/screens/home/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:fan_react/screens/home/bottom_nav_bar/bottom_nav_bar_item.dart';
import 'package:fan_react/screens/matches/matches.dart';
import 'package:fan_react/screens/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeScreen extends StatefulWidget {
  final String? payload;
  const HomeScreen({super.key, this.payload});

  @override
  State<StatefulWidget> createState() => _HomeScreen();
}

final ValueNotifier selectedIndexGlobal = ValueNotifier(0);

class _HomeScreen extends State<HomeScreen> {
  List<Widget> _listWidgets = [];

  @override
  void initState() {
    _listWidgets = [
      const Matches(),
      const History(),
      const Achievement(),
      const Profile()
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: selectedIndexGlobal,
        builder: (context, value, child) {
          return Scaffold(
            backgroundColor: G_200,
            body: IndexedStack(
                index: selectedIndexGlobal.value, children: _listWidgets),
            bottomNavigationBar: SizedBox(
              height: 100,
              child: BottomNavBar(
                  curentIndex: selectedIndexGlobal.value,
                  onTap: (index) => selectedIndexGlobal.value = index,
                  children: [
                    BottomNavBarItem(
                        title: matches,
                        svgIcon: selectedIndexGlobal.value == 0
                            ? SvgPicture.asset(matchesActive)
                            : SvgPicture.asset(matchesDefault)),
                    BottomNavBarItem(
                        title: history,
                        svgIcon: selectedIndexGlobal.value == 1
                            ? SvgPicture.asset(historyActive)
                            : SvgPicture.asset(historyDefault)),
                    BottomNavBarItem(
                        title: achievement,
                        svgIcon: selectedIndexGlobal.value == 2
                            ? SvgPicture.asset(missionsActive)
                            : SvgPicture.asset(missionsDefault)),
                    BottomNavBarItem(
                        title: profile,
                        svgIcon: selectedIndexGlobal.value == 3
                            ? SvgPicture.asset(profileActive)
                            : SvgPicture.asset(profileDefault)),
                  ]),
            ),
          );
        });
  }
}
