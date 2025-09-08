import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BottomNavBarItem {
  final String title;
  final SvgPicture svgIcon;
  BottomNavBarItem({
    required this.title,
    required this.svgIcon,
  });
}
