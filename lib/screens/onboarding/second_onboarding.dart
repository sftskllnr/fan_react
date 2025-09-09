import 'package:fan_react/const/const.dart';
import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/screens/guide/guide_screen.dart';
import 'package:fan_react/screens/onboarding/medium_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SecondOnboarding extends StatelessWidget {
  const SecondOnboarding({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height; // 890 A 850 I

    void goToGuide() {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (builder) => const GuideScreen()));
    }

    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(padding),
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: padding),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(padding)),
                  child: SvgPicture.asset(arrowLeftBlack))),
          backgroundColor: G_100),
      body: Container(
        color: G_100,
        child: Column(
          children: [
            screenHeight > 855 ? const Spacer() : Container(),
            Container(color: G_100, child: Image.asset(secondOnboard)),
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
                    Text(relive,
                        textAlign: TextAlign.center, style: size28bold),
                    const SizedBox(height: padding / 2),
                    Text(checkMatch,
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
                                  color: G_600, shape: BoxShape.circle)),
                          const SizedBox(width: padding / 2),
                          Container(
                              width: padding / 2,
                              height: padding / 2,
                              decoration: BoxDecoration(
                                  color: ACCENT_PRIMARY,
                                  shape: BoxShape.circle))
                        ]),
                        MediumButton(onTap: goToGuide, text: start)
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
