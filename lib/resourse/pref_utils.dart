import 'package:linphonesdk_example/resourse/shared_preferences.dart';


class PrefUtils {

  static String? setLoggedIn(bool isTrue) {
    Prefs.prefs!.setBool('isLogin', isTrue);
  }

  static bool isLoggedIn() {
    bool? isLogin = Prefs.prefs?.getBool('isLogin');
    return isLogin ?? false;
  }

  static String? setRebember(bool isTrue) {
    Prefs.prefs!.setBool('isRebember', isTrue);
  }

  static bool isRebember() {
    bool? isRebember = Prefs.prefs?.getBool('isRebember');
    return isRebember ?? false;
  }

  static void setFcmTokenRegistered(bool isRegistered) {
    Prefs.prefs!.setBool("is_fcm_token_registered", isRegistered);
  }

  static bool? getFcmTokenRegistered() {
    final bool value =
        Prefs.prefs!.getBool("is_fcm_token_registered") ?? false;
    return value;
  }

  static String? setEmail(String emailId) {
    Prefs.prefs!.setString("emailId", emailId);
  }

  static String getEmail() {
    final String? value = Prefs.prefs!.getString("emailId");
    return value ?? '';
  }


  static String? setProfileImage(String profileImage) {
    Prefs.prefs!.setString("profileImage", profileImage);
    return null;
  }

  static String getProfileImage() {
    final String? value = Prefs.prefs!.getString("profileImage");
    return value ?? '';
  }


  static String? setUserId(String userId) {
    Prefs.prefs!.setString("userId", userId);
    return null;
  }

  static String getUserId() {
    final String? value = Prefs.prefs!.getString("userId");
    return value ?? '';
  }

  static String? setPassword(String password) {
    Prefs.prefs!.setString("password", password);
  }

  static String getPassword() {
    final String? value = Prefs.prefs!.getString("password");
    return value ?? '';
  }


  static bool? setTheme(bool theme) {
    Prefs.prefs!.setBool("theme", theme);
  }

  static bool? getTheme() {
    final bool? value = Prefs.prefs!.getBool("theme");
    return value;
  }


  static Future<void> clearPreferences() async {
    if (Prefs.prefs != null) {
      await Prefs.prefs!.clear();  // Clear preferences
      print("Preferences cleared successfully.");
    } else {
      print("Error: SharedPreferences instance is null.");
    }
  }
}
