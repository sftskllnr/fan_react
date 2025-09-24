import 'package:fan_react/const/const.dart';
import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: G_100,
          automaticallyImplyLeading: false,
          leading: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(padding),
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: padding),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(padding)),
                  child: SvgPicture.asset(arrowLeftBlack))),
          centerTitle: true,
          title: Text(editProfile, style: size24bold)),
    );
  }
}
