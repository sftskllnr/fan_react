import 'package:fan_react/const/const.dart';
import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/main.dart';
import 'package:fan_react/models/user/user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

class MutedUsersScreen extends StatefulWidget {
  const MutedUsersScreen({super.key});

  @override
  State<MutedUsersScreen> createState() => _MutedUsersScreenState();
}

class _MutedUsersScreenState extends State<MutedUsersScreen> {
  late Future<List<UserProfile>> blockedUsers;

  @override
  void initState() {
    super.initState();
    getMutedUsers();
  }

  Future<void> getMutedUsers() async {
    blockedUsers = firestoreService.getBlockedUsers();
  }

  void unblockUser(String blockedUserId) async {
    await firestoreService.unblockUser(blockedUserId);
    await getMutedUsers();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    Widget blockedUserItem(
        UserProfile? user, int index, void Function(String) unblockUser) {
      return Container(
        margin: const EdgeInsets.symmetric(
            horizontal: padding, vertical: padding / 2),
        padding: const EdgeInsets.all(padding),
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(buttonsRadius)),
        child: Row(
          children: [
            CircleAvatar(
                radius: 20,
                backgroundImage:
                    NetworkImage('https://i.pravatar.cc/150?img=$index')),
            const SizedBox(width: padding / 2),
            SizedBox(
                width: screenWidth * 0.45,
                child: Text(user?.name ?? '', style: size15semibold)),
            const Spacer(),
            InkWell(
              onTap: () => showUnblockAlert(context, user),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: padding / 2, horizontal: padding),
                decoration: BoxDecoration(
                    color: BACKGROUND_PRIMARY,
                    borderRadius: BorderRadius.circular(buttonsRadius)),
                child: Text(unblock,
                    style: size14semibold.copyWith(color: ACCENT_PRIMARY)),
              ),
            )
          ],
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
            backgroundColor: G_100,
            automaticallyImplyLeading: false,
            leading: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(padding),
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: padding),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(padding)),
                    child: SvgPicture.asset(arrowLeftBlack))),
            centerTitle: true,
            title: Text(mutedUsers, style: size24bold)),
        body: Center(
          child: FutureBuilder(
              future: blockedUsers,
              builder: (context, usersData) {
                if (usersData.connectionState == ConnectionState.waiting) {
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        LottieBuilder.asset(preloader, width: 100, height: 100),
                        Text(loading, style: size15semibold)
                      ]);
                } else if (usersData.data?.isEmpty ?? true) {
                  return Text(noMutedUsers, style: size15semibold);
                } else {
                  return ListView.builder(
                      itemCount:
                          usersData.data != null ? usersData.data!.length : 0,
                      itemBuilder: (context, index) {
                        final user = usersData.data?[index];
                        return blockedUserItem(user, index, unblockUser);
                      });
                }
              }),
        ));
  }

  void showUnblockAlert(BuildContext context, UserProfile? userProfile) async {
    return await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title:
                  Text('$unblock ${userProfile?.name}?', style: size18semibold),
              content: Text(youWillStart, style: size14medium),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(cancel,
                        style: size15medium.copyWith(
                            color: ACCENT_PRIMARY, fontSize: 17))),
                TextButton(
                    onPressed: () {
                      unblockUser(userProfile?.id ?? '');
                      Navigator.of(context).pop();
                    },
                    child: Text(unblock,
                        style: size15medium.copyWith(
                            color: ACCENT_PRIMARY, fontSize: 17)))
              ]);
        });
  }
}
