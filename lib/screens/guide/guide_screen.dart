import 'package:fan_react/const/const.dart';
import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/main.dart';
import 'package:fan_react/screens/guide/default_button.dart';
import 'package:fan_react/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  bool? _isAgree = false;

  @override
  void initState() {
    super.initState();
  }

  void goToHomeScreen() async {
    _isAgree ?? false
        ? {
            await FirebaseAuth.instance.signInAnonymously(),
            firestoreService.createUserProfile(),
            mounted
                ? Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (builder) => const HomeScreen()),
                    (Route<dynamic> route) => false)
                : null
          }
        : null;
  }

  Widget guideItem(String text, double width) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(width: padding / 2),
      Container(
          width: padding / 4,
          height: padding / 4,
          margin: const EdgeInsets.only(top: padding / 2),
          decoration: BoxDecoration(shape: BoxShape.circle, color: G_700)),
      const SizedBox(width: padding / 2),
      SizedBox(
          width: width - padding * 3 - padding / 4,
          child: Text(text,
              maxLines: 2, style: size15medium.copyWith(color: G_700)))
    ]);
  }

  Widget agreement(double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
          horizontal: padding / 2, vertical: padding / 2),
      decoration: BoxDecoration(
          color: G_400,
          borderRadius: const BorderRadius.all(Radius.circular(buttonsRadius))),
      child: Row(
        children: [
          Checkbox(
              value: _isAgree,
              onChanged: (agree) {
                setState(() => _isAgree = agree);
              },
              activeColor: ACCENT_PRIMARY,
              checkColor: G_100),
          Text(iAgree, style: size15medium),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;

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
          title: Text(communityGuidelines, style: size18semibold),
          backgroundColor: G_100),
      body: Column(
        children: [
          SvgPicture.asset(chatConversation, width: 100, height: 100),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: padding),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [Text(letsKeep, style: size15bold)]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: padding),
            child: SizedBox(
                height: guideList.length * padding * 2.2,
                child: ListView.builder(
                    itemCount: guideList.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return guideItem(guideList[index], screenWidth);
                    })),
          ),
          const SizedBox(height: padding / 2),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: padding),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [Text(moderation, style: size15bold)])),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: padding),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                SizedBox(
                    width: screenWidth - padding * 2,
                    child: Text(weReview,
                        style: size15medium.copyWith(color: G_700)))
              ])),
          const SizedBox(height: padding),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: padding),
              child: agreement(screenWidth)),
          const Spacer(),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: padding),
              decoration: BoxDecoration(
                color: G_100,
                border: Border(top: BorderSide(color: G_300)),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(buttonsRadius + 2),
                    topRight: Radius.circular(buttonsRadius + 2)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: padding),
                  DefaultButton(
                      onTap: goToHomeScreen,
                      text: acceptContinue,
                      color: _isAgree ?? false ? ACCENT_PRIMARY : G_600),
                  const SizedBox(height: padding / 2),
                  Text(byContinuing,
                      textAlign: TextAlign.center,
                      style: size14medium.copyWith(color: G_700)),
                  const SizedBox(height: padding * 3)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
