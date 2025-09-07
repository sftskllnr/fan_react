import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String? payload;
  const HomeScreen({super.key, this.payload});

  @override
  State<StatefulWidget> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
          child: Text('HOME'),
        ));
  }
}
