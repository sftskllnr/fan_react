import 'dart:io';
import 'package:fan_react/const/const.dart';
import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  String? _avatarPath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameTextController = TextEditingController(text: widget.userName);
    focusNode = FocusNode();
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

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied || status.isPermanentlyDenied) {
      final newStatus = await permission.request();
      if (newStatus.isGranted) {
        return true;
      } else if (newStatus.isPermanentlyDenied && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Permission permanently denied. Please enable it in app settings.'),
            backgroundColor: SYSTEM_ONE,
            action: SnackBarAction(
              label: 'Settings',
              textColor: ACCENT_PRIMARY,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
        return false;
      }
      // If denied (not permanently), prompt again
      if (mounted && newStatus.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Permission required to access ${permission == Permission.camera ? "camera" : "gallery"}. Please grant permission.'),
            backgroundColor: SYSTEM_ONE,
            action: SnackBarAction(
              label: 'Retry',
              textColor: ACCENT_PRIMARY,
              onPressed: () => permission.request(),
            ),
          ),
        );
      }
      return false;
    }
    return false;
  }

  Future<void> _pickImage(ImageSource source) async {
    bool hasPermission = false;
    if (source == ImageSource.camera) {
      hasPermission = await _requestPermission(Permission.camera);
    } else {
      hasPermission = await _requestPermission(Permission.photos);
    }

    if (!hasPermission) return;

    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 200,
        maxHeight: 200,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        final directory = await getApplicationDocumentsDirectory();
        final user = FirebaseAuth.instance.currentUser;
        final avatarFile = File('${directory.path}/${user?.uid}_avatar.png');
        await pickedFile.saveTo(avatarFile.path);

        setState(() {
          _avatarPath = avatarFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: SYSTEM_ONE,
          ),
        );
      }
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: ACCENT_PRIMARY),
              title: Text('Choose from Gallery', style: size15semibold),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: ACCENT_PRIMARY),
              title: Text('Take a Photo', style: size15semibold),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
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
            InkWell(
              onTap: _showImageSourceOptions,
              child: Text(
                setNewPhoto,
                style: size18semibold.copyWith(color: ACCENT_PRIMARY),
              ),
            ),
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
