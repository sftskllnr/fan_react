import 'dart:io';
import 'package:fan_react/const/const.dart';
import 'package:fan_react/const/strings.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
  late ImagePicker _picker;
  bool showSuccessMessage = false;
  late String savedUserName;
  XFile? pickedAvaFile;
  bool _isAvatarLoading = false;

  @override
  void initState() {
    super.initState();
    nameTextController = TextEditingController(text: widget.userName);
    focusNode = FocusNode();
    _picker = ImagePicker();
    savedUserName = widget.userName;
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final directory = await getApplicationDocumentsDirectory();
    final user = FirebaseAuth.instance.currentUser;
    final avatarFile = File('${directory.path}/${user?.uid}_avatar.png');
    if (await avatarFile.exists()) {
      setState(() {
        pickedAvaFile = XFile('${directory.path}/${user?.uid}_avatar.png');
      });
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (Platform.isIOS && permission == Permission.photos) {
      final status = await Permission.photos.status;

      if (status.isGranted || status.isLimited) {
        return true;
      }

      final newStatus = await Permission.photos.request();

      if (newStatus.isGranted || newStatus.isLimited) {
        return true;
      }

      if (newStatus.isPermanentlyDenied && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Photo library access permanently denied. Please enable it in Settings.'),
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

      if (newStatus.isDenied && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Permission required to access gallery. Please grant permission.'),
            backgroundColor: SYSTEM_ONE,
            action: SnackBarAction(
              label: 'Retry',
              textColor: ACCENT_PRIMARY,
              onPressed: () => _requestPermission(Permission.photos),
            ),
          ),
        );
      }
      return false;
    }

    // Handle camera or Android permissions
    final status = await permission.status;
    if (status.isGranted) {
      return true;
    }

    final newStatus = await permission.request();

    if (newStatus.isGranted) {
      return true;
    }

    if (newStatus.isPermanentlyDenied && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${permission == Permission.camera ? "Camera" : "Gallery"} access permanently denied. Please enable it in Settings.'),
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

    if (newStatus.isDenied && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Permission required to access ${permission == Permission.camera ? "camera" : "gallery"}. Please grant permission.'),
          backgroundColor: SYSTEM_ONE,
          action: SnackBarAction(
            label: 'Retry',
            textColor: ACCENT_PRIMARY,
            onPressed: () => _requestPermission(permission),
          ),
        ),
      );
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

    if (!hasPermission) {
      print(
          'No permission to access ${source == ImageSource.camera ? "camera" : "gallery"}');
      return;
    }

    try {
      print('Attempting to pick image from $source');
      setState(() {
        _isAvatarLoading = true;
      });
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 200,
        maxHeight: 200,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        print('Image picked: ${pickedFile.path}');
        final directory = await getApplicationDocumentsDirectory();
        final user = FirebaseAuth.instance.currentUser;
        final avatarFile = File('${directory.path}/${user?.uid}_avatar.png');
        await File(pickedFile.path).copy(avatarFile.path);
        if (await avatarFile.exists()) {
          print('Image saved to: ${avatarFile.path}');
          // Clear image cache to ensure new image loads
          PaintingBinding.instance.imageCache.clear();
          PaintingBinding.instance.imageCache.clearLiveImages();
          imageCache.evict(FileImage(File(avatarFile.path)));
          setState(() {
            pickedAvaFile = XFile(
                '${avatarFile.path}?t=${DateTime.now().millisecondsSinceEpoch}');
            _isAvatarLoading = false;
          });
        } else {
          print('Failed to save image to: ${avatarFile.path}');
          setState(() {
            _isAvatarLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Failed to save image.'),
                backgroundColor: SYSTEM_ONE,
              ),
            );
          }
        }
      } else {
        print('No image picked');
        setState(() {
          _isAvatarLoading = false;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      setState(() {
        _isAvatarLoading = false;
      });
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
      if (mounted) {
        setState(() {
          editSuccess = isEditSuccess;
          if (isEditSuccess) {
            savedUserName = nameTextController.text.trim();
            showSuccessMessage = true;
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  showSuccessMessage = false;
                });
              }
            });
          }
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

  bool _hasUnsavedChanges() {
    return nameTextController.text.trim() != savedUserName;
  }

  Future<bool> _onBackPressed() async {
    if (_hasUnsavedChanges()) {
      final result = await showDiscardAlert(context);
      if (result && mounted) {
        Navigator.of(context).pop(savedUserName);
      }
      return result;
    }
    Navigator.of(context).pop(savedUserName);
    return true;
  }

  Future<bool> showDiscardAlert(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(discardChanges, style: size18semibold),
              content: Text(youMade, style: size14medium),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    keepEditing,
                    style: size15medium.copyWith(
                        color: ACCENT_PRIMARY, fontSize: 17),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    discard,
                    style:
                        size15medium.copyWith(color: SYSTEM_ONE, fontSize: 17),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
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
                child: _isAvatarLoading
                    ? const Center(child: CircularProgressIndicator())
                    : pickedAvaFile != null
                        ? Image.file(File(pickedAvaFile!.path.split('?t=')[0]),
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                            key: ValueKey(pickedAvaFile!.path),
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(ellipse, fit: BoxFit.cover))
                        : Image.asset(ellipse, fit: BoxFit.cover),
              ),
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
          horizontal: padding,
          vertical: padding,
        ),
        decoration: BoxDecoration(
          color: G_100,
          border: Border(top: BorderSide(color: G_200)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: padding / 2),
            InkWell(
              onTap: showSuccessMessage ? null : () => _saveChanges(),
              child: showSuccessMessage
                  ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SvgPicture.asset(tickCircle),
                      const SizedBox(width: padding),
                      Text(changesSaved,
                          style: size15semibold.copyWith(color: ACCENT_PRIMARY))
                    ])
                  : Container(
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
                          style: size15semibold.copyWith(color: G_100)),
                    ),
            ),
          ],
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: InkWell(
        onTap: () => focusNode.unfocus(),
        child: Scaffold(
          appBar: AppBar(
              backgroundColor: G_100,
              automaticallyImplyLeading: false,
              leading: InkWell(
                  onTap: () async {
                    if (_hasUnsavedChanges()) {
                      final result = await showDiscardAlert(context);
                      if (result && context.mounted) {
                        Navigator.of(context).pop(result);
                      }
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
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
      ),
    );
  }

  @override
  void dispose() {
    nameTextController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
