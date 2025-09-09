import 'package:fan_react/const/const.dart';
import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/screens/achievement/achievement.dart';
import 'package:fan_react/screens/history/history.dart';
import 'package:fan_react/screens/home/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:fan_react/screens/home/bottom_nav_bar/bottom_nav_bar_item.dart';
import 'package:fan_react/screens/matches/matches.dart';
import 'package:fan_react/screens/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

//guide dialog
late BuildContext _aContext;
late BuildContext _bContext;

class HomeScreen extends StatefulWidget {
  final String? payload;
  const HomeScreen({super.key, this.payload});

  @override
  State<StatefulWidget> createState() => _HomeScreen();
}

final ValueNotifier selectedIndexGlobal = ValueNotifier(0);

class _HomeScreen extends State<HomeScreen> {
  List<Widget> _listWidgets = [];
  bool? _isFirstLaunch;
  double topPadding = 150;

  @override
  void initState() {
    super.initState();

    _listWidgets = [
      const Matches(),
      const History(),
      const Achievement(),
      const Profile()
    ];

    _getIsFirstLaunch();
  }

  Future<void> _getIsFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isFirstLaunch = prefs.getBool('isFirstLaunch');

    if (isFirstLaunch != null) {
      _show(); // delete before release
      setState(() {
        _isFirstLaunch == false;
      });
    } else {
      await prefs.setBool('isFirstLaunch', false);
      // _show(); // uncomment before release
      setState(() {
        _isFirstLaunch == true;
      });
    }
  }

  void showGuide() {
    _show();
  }

  void _show() async {
    SmartDialog.show(builder: (_) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: HINT_COLOR),
        child: Stack(
            alignment: Alignment.topCenter, children: [_pointA(), _pointB()]),
      );
    });
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Widget _pointA() {
    return Positioned(
      left: padding,
      top: topPadding,
      child: Builder(builder: (context) {
        _aContext = context;
        return matchItem(context);
      }),
    );
  }

  Widget _pointB() {
    return Positioned(
      left: padding,
      right: padding,
      top: topPadding * 2 + padding,
      child: Builder(builder: (context) {
        _bContext = context;
        return reactDescription();
      }),
    );
  }

  Widget matchItem(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width - padding * 2,
      child: Image.asset('assets/png/match.png'),
    );
  }

  Widget reactDescription() {
    return Container(
        padding: const EdgeInsets.all(padding),
        decoration: BoxDecoration(
            color: G_100,
            borderRadius:
                const BorderRadius.all(Radius.circular(buttonsRadius))),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reactToMatches, style: size15bold),
                    Text(selectReaction,
                        style: size14medium.copyWith(color: G_700)),
                  ],
                ),
              ),
              Column(children: [
                InkWell(
                    onTap: () async => await SmartDialog.dismiss(),
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: padding * 1.5, vertical: padding / 2),
                        decoration: BoxDecoration(
                            color: BACKGROUND_PRIMARY,
                            borderRadius: BorderRadius.circular(buttonsRadius)),
                        child: Text(ok,
                            style: size14semibold.copyWith(
                                color: ACCENT_SECONDARY))))
              ])
            ]));
  }

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    DateFormat dateFormatBack = DateFormat('yyyy-MM-dd');
    debugPrint(dateFormatBack.format(now));

    return ValueListenableBuilder(
        valueListenable: selectedIndexGlobal,
        builder: (context, value, child) {
          return Scaffold(
            backgroundColor: G_200,
            body: InkWell(
              onTap: () => showGuide(),
              child: IndexedStack(
                  index: selectedIndexGlobal.value, children: _listWidgets),
            ),
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
