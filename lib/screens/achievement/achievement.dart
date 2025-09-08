import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:flutter/material.dart';

class Achievement extends StatelessWidget {
  const Achievement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          achievement,
          style: size24bold,
        ),
      ),
    );
  }
}
