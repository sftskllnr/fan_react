import 'package:fan_react/const/const.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/screens/home/bottom_nav_bar/bottom_nav_bar_item.dart';
import 'package:flutter/material.dart';

class NavBarItem extends StatelessWidget {
  final BottomNavBarItem item;
  bool selected;
  final Function onTap;
  NavBarItem({
    super.key,
    required this.item,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          const SizedBox(height: padding / 2),
          item.svgIcon,
          const SizedBox(height: padding / 2),
          Text(item.title,
              style: selected
                  ? size12semibold.copyWith(color: ACCENT_PRIMARY)
                  : size12semibold.copyWith(color: G_700))
        ]));
  }
}
