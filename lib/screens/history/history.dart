import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:flutter/material.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          history,
          style: size24bold,
        ),
      ),
    );
  }
}
