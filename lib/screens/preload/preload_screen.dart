import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/screens/onboarding_1/first_onboarding.dart';
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
    startAnimation();
    super.initState();
  }

  void startAnimation() async {
    Future.delayed(
        const Duration(seconds: 3),
        () => mounted
            ? Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const FirstOnboarding()),
                (Route<dynamic> route) => false)
            : null);
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
