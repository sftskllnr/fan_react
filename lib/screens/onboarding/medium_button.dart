import 'package:fan_react/const/const.dart';
import 'package:fan_react/const/theme.dart';
import 'package:flutter/material.dart';

class MediumButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  const MediumButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: padding * 2, vertical: padding),
          decoration: BoxDecoration(
              color: ACCENT_PRIMARY,
              borderRadius:
                  const BorderRadius.all(Radius.circular(buttonsRadius))),
          child: Text(text, style: size15semibold.copyWith(color: G_100))),
    );
  }
}
