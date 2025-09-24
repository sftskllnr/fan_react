import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/screens/home/home_screen.dart';
import 'package:fan_react/screens/onboarding/first_onboarding.dart';
import 'package:fan_react/singleton/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

class PreloadScreen extends StatefulWidget {
  const PreloadScreen({super.key});

  @override
  State<StatefulWidget> createState() => _PreloadScreen();
}

class _PreloadScreen extends State<PreloadScreen> {
  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  void startAnimation() async {
    var prefs = await SharedPrefsSingleton.getInstance();
    bool? isFirstLaunch = prefs.getBool('isFirstLaunch');

    await prefs.setBool('isFirstLaunch', false);

    Future.delayed(
        const Duration(seconds: 3),
        () => mounted
            ? isFirstLaunch == null || isFirstLaunch == true
                ? Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const FirstOnboarding()),
                    (Route<dynamic> route) => false)
                : Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (Route<dynamic> route) => false)
            : null);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    return Container(
      decoration: BoxDecoration(color: BACKGROUND),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          SizedBox(
              width: screenWidth,
              height: screenHeight,
              child: SvgPicture.asset(preloaderBack, fit: BoxFit.fitWidth)),
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
