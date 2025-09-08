import 'package:fan_react/const/theme.dart';
import 'package:fan_react/screens/home/bottom_nav_bar/bottom_nav_bar_item.dart';
import 'package:fan_react/screens/home/bottom_nav_bar/nav_bar_item.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final List<BottomNavBarItem> children;
  int curentIndex;
  final Color? backgroundColor;
  Function(int)? onTap;

  BottomNavBar(
      {super.key,
      required this.children,
      required this.curentIndex,
      this.backgroundColor,
      required this.onTap});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: G_100, border: Border(top: BorderSide(color: G_300))),
        width: double.infinity,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
                widget.children.length,
                (index) => NavBarItem(
                    item: widget.children[index],
                    selected: widget.curentIndex == index,
                    onTap: () {
                      setState(() {
                        widget.curentIndex = index;
                        widget.onTap!(widget.curentIndex);
                      });
                    }))));
  }
}
