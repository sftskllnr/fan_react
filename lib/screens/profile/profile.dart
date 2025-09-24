import 'dart:async';
import 'package:fan_react/const/const.dart';
import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/main.dart';
import 'package:fan_react/models/user/user_profile.dart';
import 'package:fan_react/screens/home/home_screen.dart';
import 'package:fan_react/screens/profile/edit_profile_screen.dart';
import 'package:fan_react/screens/profile/muted_users_screen.dart';
import 'package:fan_react/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  UserProfile? userProfile;
  late StreamSubscription<InternetStatus> _subscription;
  InternetStatus? _connectionStatus;
  final Uri _url = Uri.parse(googleUrl);

  @override
  void initState() {
    super.initState();

    _subscription = InternetConnection().onStatusChange.listen((status) {
      setState(() {
        _connectionStatus = status;
      });
      if (_connectionStatus == InternetStatus.disconnected) {
        if (mounted) showNoInternetSnackbar(context, getUserProfile);
      }
    });

    getUserProfile();
  }

  Future<void> getUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final usrPrfl = await firestoreService.getUserProfile(user?.uid ?? '');
    setState(() {
      userProfile = usrPrfl;
    });
  }

  Future<void> initNotifications() async {
    await NotificationService().init();
  }

  void goToMutedUsersScreen() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (builder) => const MutedUsersScreen()));
  }

  void goToEditProfileScreen() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (builder) => const EditProfileScreen()));
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url, mode: LaunchMode.platformDefault)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    Widget settingsItem(String label, void Function() onTap) {
      return InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: padding),
          padding: const EdgeInsets.all(padding),
          decoration: BoxDecoration(
              color: G_100, borderRadius: BorderRadius.circular(buttonsRadius)),
          child: Row(children: [
            Text(label,
                style: label == deleteProfile
                    ? size15semibold.copyWith(color: SYSTEM_ONE)
                    : size15semibold),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_outlined, color: G_900, size: padding)
          ]),
        ),
      );
    }

    Widget avaWidget() {
      return SizedBox(
        width: screenWidth,
        child: Column(
          children: [
            const CircleAvatar(radius: padding * 3.5),
            const SizedBox(height: padding / 2),
            Text(userProfile?.name ?? '', style: size24bold),
            const SizedBox(height: padding),
            InkWell(
              onTap: goToEditProfileScreen,
              child: Text(editProfile,
                  style: size18semibold.copyWith(color: ACCENT_PRIMARY)),
            )
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
          backgroundColor: G_100,
          centerTitle: false,
          title: Text(profile, style: size24bold)),
      body: Container(
        decoration: BoxDecoration(color: G_200),
        child: Column(
          children: [
            const SizedBox(height: padding * 2),
            avaWidget(),
            const SizedBox(height: padding * 2),
            settingsItem(mutedUsers, goToMutedUsersScreen),
            const SizedBox(height: padding / 2),
            Divider(color: G_300, indent: padding * 4, endIndent: padding * 4),
            const SizedBox(height: padding / 2),
            settingsItem(notifications, initNotifications),
            const SizedBox(height: padding / 2),
            settingsItem(privacyPolicy, _launchUrl),
            const SizedBox(height: padding / 2),
            settingsItem(shareApp, () {}),
            const SizedBox(height: padding / 2),
            Divider(color: G_300, indent: padding * 4, endIndent: padding * 4),
            const SizedBox(height: padding / 2),
            settingsItem(deleteProfile, () {}),
          ],
        ),
      ),
    );
  }
}
