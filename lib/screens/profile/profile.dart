import 'dart:async';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:fan_react/const/const.dart';
import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/main.dart';
import 'package:fan_react/models/user/user_profile.dart';
import 'package:fan_react/screens/home/home_screen.dart';
import 'package:fan_react/screens/onboarding/first_onboarding.dart';
import 'package:fan_react/screens/profile/edit_profile_screen.dart';
import 'package:fan_react/screens/profile/muted_users_screen.dart';
import 'package:fan_react/singleton/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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
  String? _avatarPath;

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
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final directory = await getApplicationDocumentsDirectory();
    final user = FirebaseAuth.instance.currentUser;
    final avatarFile = File('${directory.path}/${user?.uid}_avatar.png');
    if (await avatarFile.exists()) {
      setState(() {
        _avatarPath = avatarFile.path;
      });
    }
  }

  Future<void> getUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final usrPrfl = await firestoreService.getUserProfile(user?.uid ?? '');
    setState(() {
      userProfile = usrPrfl;
    });
  }

  void share() {
    Share.share(pickEmtion);
  }

  void deleteAccount() async {
    var prefs = await SharedPrefsSingleton.getInstance();
    await prefs.setBool('isFirstLaunch', true);
    firestoreService.deleteUserAccount();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const FirstOnboarding()),
          (Route<dynamic> route) => false);
    }
  }

  Future<void> initNotifications() async {
    await AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  void goToMutedUsersScreen() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (builder) => const MutedUsersScreen()));
  }

  void goToEditProfileScreen() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
          builder: (builder) =>
              EditProfileScreen(userName: userProfile?.name ?? '')),
    );
    if (mounted) {
      setState(() {
        if (result != null && result.isNotEmpty) {
          userProfile = userProfile?.copyWith(name: result) ??
              UserProfile(
                  id: userProfile?.id ?? '', name: result, avatar: ellipse);
        }
      });
      if (result == null || result.isEmpty) {
        await getUserProfile();
      }
      await _loadAvatar();
    }
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
            Container(
              height: padding * 7,
              width: padding * 7,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, border: Border.all(color: G_400)),
              child: ClipOval(
                  child: _avatarPath != null
                      ? Image.file(File(_avatarPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(ellipse, fit: BoxFit.cover))
                      : Image.asset(ellipse, fit: BoxFit.cover)),
            ),
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
        child: Column(children: [
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
          settingsItem(shareApp, share),
          const SizedBox(height: padding / 2),
          Divider(color: G_300, indent: padding * 4, endIndent: padding * 4),
          const SizedBox(height: padding / 2),
          settingsItem(
              deleteProfile, () => showDeleteAccountAlert(context, userProfile))
        ]),
      ),
    );
  }

  void showDeleteAccountAlert(
      BuildContext context, UserProfile? userProfile) async {
    return await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title: Text(deleteYour, style: size18semibold),
              content: Text(thisWill, style: size14medium),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(cancel,
                        style: size15medium.copyWith(
                            color: ACCENT_PRIMARY, fontSize: 17))),
                TextButton(
                    onPressed: () {
                      deleteAccount();
                      Navigator.of(context).pop();
                    },
                    child: Text(delete,
                        style: size15medium.copyWith(
                            color: SYSTEM_ONE, fontSize: 17)))
              ]);
        });
  }
}
