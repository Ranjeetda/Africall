import 'package:flutter/material.dart';
import 'package:linphonesdk_example/auth/login_choice_screen.dart';
import 'package:linphonesdk_example/dashboardScreen/dashboard_screen.dart';
import 'package:linphonesdk_example/resourse/image_paths.dart';

import '../auth/continue_screen.dart';
import '../dashboardScreen/home_screen.dart';
import '../dashboardScreen/view_pager_with_selected_button.dart';
import '../resourse/pref_utils.dart';

class SplashScreen extends StatefulWidget {
  final String? userId;
  const SplashScreen({super.key, this.userId});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const int splashTimer = 3000; // 3 seconds

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: splashTimer), () {
      if (PrefUtils.isLoggedIn()) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => ViewPagerWithSelectedButton()),
              (Route<dynamic> route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginChoiceScreen()),
              (Route<dynamic> route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset(
          ImagePaths.splash,
          fit: BoxFit.cover, // or BoxFit.fill depending on your need
        ),
      ),
    );
  }
}
