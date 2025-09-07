import 'package:fan_react/services/notification_service.dart';
import 'package:flutter/material.dart';

class FirstOnboarding extends StatelessWidget {
  const FirstOnboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
          child: InkWell(
              onTap: () async => await NotificationService().showNotification(),
              child: Text('ON_B_!')),
        ));
  }
}
