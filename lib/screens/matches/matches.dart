import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:flutter/material.dart';

class Matches extends StatelessWidget {
  const Matches({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          matches,
          style: size24bold,
        ),
      ),
    );
  }
}
