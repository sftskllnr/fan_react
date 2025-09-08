import 'package:fan_react/const/const.dart';
import 'package:fan_react/const/theme.dart';
import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final Color color;
  const DefaultButton(
      {super.key,
      required this.onTap,
      required this.text,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Container(
            width: Size.infinite.width,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
                horizontal: padding, vertical: padding),
            decoration: BoxDecoration(
                color: color,
                borderRadius:
                    const BorderRadius.all(Radius.circular(buttonsRadius))),
            child: Text(text, style: size15semibold.copyWith(color: G_100))));
  }
}
