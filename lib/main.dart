import 'package:fan_react/api/api_client.dart';
import 'package:fan_react/const/theme.dart';
import 'package:fan_react/firebase_options.dart';
import 'package:fan_react/screens/preload/preload_screen.dart';
import 'package:fan_react/services/firestore_service.dart';
import 'package:fan_react/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fan_react/models/match/match.dart';

//guide dialog
late BuildContext aContext;
late BuildContext bContext;

final FirestoreService firestoreService = FirestoreService();
final ApiClient apiClient = ApiClient();

final ValueNotifier selectedIndexGlobal = ValueNotifier(0);
final ValueNotifier isLeagueSelected = ValueNotifier(false);
final ValueNotifier selectedLeagueId = ValueNotifier(0);
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

List<Match> allMatches = List<Match>.empty(growable: true);
List<Match> selectedLeagueMatches = List.empty(growable: true);
final ValueNotifier matchesWithActivities =
    ValueNotifier(List<Match>.empty(growable: true));
Map<int, String> selectedReactions = {};
bool isLoadingMatches = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: ACCENT_PRIMARY),
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: const PreloadScreen(),
    );
  }
}
