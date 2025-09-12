import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsSingleton {
  static SharedPreferences? _instance;

  static Future<SharedPreferences> getInstance() async {
    _instance ??= await SharedPreferences.getInstance().timeout(
      const Duration(seconds: 5),
      onTimeout: () => throw TimeoutException('SharedPreferences timeout'),
    );
    return _instance!;
  }
}
