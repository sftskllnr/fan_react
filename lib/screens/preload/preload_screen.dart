import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/screens/home/home_screen.dart';
import 'package:fan_react/screens/onboarding/first_onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreloadScreen extends StatefulWidget {
  const PreloadScreen({super.key});

  @override
  State<StatefulWidget> createState() => _PreloadScreen();
}

class _PreloadScreen extends State<PreloadScreen> {
  bool? _isFirstLaunch;

  @override
  void initState() {
    _getIsFirstLaunch();
    startAnimation();
    super.initState();
  }

  void startAnimation() async {
    Future.delayed(
        const Duration(seconds: 3),
        () => mounted
            // change before release
            ? _isFirstLaunch == null
                ? Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const FirstOnboarding()),
                    (Route<dynamic> route) => false)
                : Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (Route<dynamic> route) => false)
            : null);
  }

  Future<void> _getIsFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isFirstLaunch = prefs.getBool('isFirstLaunch');

    if (isFirstLaunch != null) {
      setState(() {
        _isFirstLaunch == false;
      });
    } else {
      setState(() {
        _isFirstLaunch == true;
      });
      await prefs.setBool('isFirstLaunch', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: BACKGROUND),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          SvgPicture.asset(preloaderBack),
          Center(
              child: Container(
                  width: 125,
                  height: 125,
                  decoration: BoxDecoration(
                      color: G_100,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(30))))),
          Positioned(
              bottom: 100,
              child: LottieBuilder.asset(preloader, width: 100, height: 100))
        ],
      ),
    );
  }
}
