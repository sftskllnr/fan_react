import 'package:fan_react/const/const.dart';
import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class EditProfileScreen extends StatefulWidget {
  final String userName;
  const EditProfileScreen({super.key, required this.userName});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameTextController;
  late FocusNode focusNode;
  bool editSuccess = true;

  @override
  void initState() {
    super.initState();
    nameTextController = TextEditingController(text: widget.userName);
    focusNode = FocusNode();
  }

  Future<void> _saveChanges() async {
    try {
      focusNode.unfocus();
      bool isEditSuccess =
          await firestoreService.editUserName(nameTextController.text.trim());
      if (mounted && isEditSuccess) {
        Navigator.of(context).pop(isEditSuccess);
      } else {
        setState(() {
          editSuccess = isEditSuccess;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update name: $e'),
            backgroundColor: SYSTEM_ONE,
          ),
        );
      }
    }
  }

  Future<void> getUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final usrPrfl = await firestoreService.getUserProfile(user?.uid ?? '');
    setState(() {
      nameTextController.text = usrPrfl?.name ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;
    double textFieldWidth = screenWidth - padding * 2;
    double inputContainerHeight = padding * 7;

    Widget avaWidget() {
      return SizedBox(
        width: screenWidth,
        child: Column(
          children: [
            SizedBox(
                height: padding * 7,
                width: padding * 7,
                child: Image.asset(ellipse)),
            const SizedBox(height: padding / 2),
            InkWell(
              onTap: () {},
              child: Text(setNewPhoto,
                  style: size18semibold.copyWith(color: ACCENT_PRIMARY)),
            )
          ],
        ),
      );
    }

    Widget nameInput() {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: padding),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(userName, style: size12semibold),
            Text('${nameTextController.text.length} / 18',
                style: size12semibold)
          ]),
          const SizedBox(height: padding / 4),
          TextField(
              controller: nameTextController,
              style: size15semibold,
              keyboardType: TextInputType.name,
              focusNode: focusNode,
              maxLength: 18,
              showCursor: true,
              onTap: () => focusNode.requestFocus(),
              onChanged: (value) => setState(() {}),
              cursorColor: ACCENT_PRIMARY,
              decoration: InputDecoration(
                  counter: Container(),
                  hintStyle: size15medium.copyWith(color: G_600),
                  contentPadding: const EdgeInsets.all(padding * 0.8),
                  fillColor: G_100,
                  filled: true,
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide(color: G_400)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: G_400)))),
          const SizedBox(height: padding / 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: padding),
              Text(enterYourName, style: size12semibold.copyWith(color: G_700)),
            ],
          ),
          const SizedBox(height: padding / 4),
          Offstage(
              offstage: editSuccess,
              child: Text(thisNickname,
                  style: size14semibold.copyWith(color: SYSTEM_ONE)))
        ]),
      );
    }

    Widget saveButton(double textFieldWidth, double inputContainerHeight) {
      return Container(
          height: inputContainerHeight,
          width: screenWidth,
          padding: const EdgeInsets.symmetric(
              horizontal: padding, vertical: padding),
          decoration: BoxDecoration(
              color: G_100, border: Border(top: BorderSide(color: G_200))),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            const SizedBox(width: padding / 2),
            InkWell(
                onTap: () => _saveChanges(),
                child: Container(
                    width: screenWidth,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: padding),
                    decoration: BoxDecoration(
                        color: nameTextController.text.isNotEmpty &&
                                focusNode.hasFocus
                            ? ACCENT_PRIMARY
                            : G_600,
                        borderRadius: BorderRadius.circular(buttonsRadius)),
                    child: Text(saveChanges,
                        style: size15semibold.copyWith(color: G_100))))
          ]));
    }

    return InkWell(
      onTap: () => focusNode.unfocus(),
      child: Scaffold(
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
            title: Text(editProfile, style: size24bold)),
        body: Center(
          child: Container(
            decoration: BoxDecoration(color: G_200),
            child: Column(
              children: [
                const SizedBox(height: padding * 2),
                avaWidget(),
                const SizedBox(height: padding),
                nameInput(),
                const Spacer(),
                saveButton(textFieldWidth, inputContainerHeight)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
