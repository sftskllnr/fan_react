import 'package:fan_react/const/const.dart';
import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/screens/home/home_screen.dart';
import 'package:fan_react/screens/onboarding/medium_button.dart';
import 'package:fan_react/screens/onboarding/second_onboarding.dart';
import 'package:flutter/material.dart';

class FirstOnboarding extends StatelessWidget {
  const FirstOnboarding({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height; // 890 A 850 I

    void goToHomeScreen() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (builder) => const HomeScreen()),
          (Route<dynamic> route) => false);
    }

    void goToSecondOnboarding() {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (builder) => const SecondOnboarding()));
    }

    return Scaffold(
      appBar: AppBar(backgroundColor: G_100, actions: [
        InkWell(
            onTap: goToHomeScreen,
            borderRadius: BorderRadius.circular(buttonsRadius),
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: padding),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(buttonsRadius)),
                child: Text(skip, style: size15semibold)))
      ]),
      body: Container(
        color: G_100,
        child: Column(
          children: [
            screenHeight > 855 ? const Spacer() : Container(),
            Container(color: G_100, child: Image.asset(firstOnboard)),
            Container(
              width: Size.infinite.width,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: G_300)),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(buttonsRadius + 2),
                    topRight: Radius.circular(buttonsRadius + 2)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: padding),
                child: Column(
                  children: [
                    const SizedBox(height: padding / 2),
                    Text(shareFeelings,
                        textAlign: TextAlign.center, style: size28bold),
                    const SizedBox(height: padding / 2),
                    Text(pickEmtion,
                        textAlign: TextAlign.center, style: size15medium),
                    const SizedBox(height: padding / 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Container(
                              width: padding / 2,
                              height: padding / 2,
                              decoration: BoxDecoration(
                                  color: ACCENT_PRIMARY,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: padding / 2),
                          Container(
                              width: padding / 2,
                              height: padding / 2,
                              decoration: BoxDecoration(
                                  color: G_600, shape: BoxShape.circle))
                        ]),
                        MediumButton(onTap: goToSecondOnboarding, text: next)
                      ],
                    )
                  ],
                ),
              ),
            ),
            const Spacer()
          ],
        ),
      ),
    );
  }
}
