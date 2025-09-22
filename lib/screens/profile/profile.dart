import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(centerTitle: false, title: Text(profile, style: size24bold)),
    );
  }
}
