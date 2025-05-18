import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:linphonesdk_example/auth/login_choice_screen.dart';
import 'package:linphonesdk_example/dashboardScreen/dashboard_screen.dart';
import 'package:linphonesdk_example/resourse/image_paths.dart';
import 'package:provider/provider.dart';

import '../auth/continue_screen.dart';
import '../dashboardScreen/home_screen.dart';
import '../dashboardScreen/view_pager_with_selected_button.dart';
import '../provider/flash_message_provider.dart';
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
    _flashMessage();

   /* Future.delayed(Duration(milliseconds: splashTimer), () {
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
    });*/
  }

  Future<void> _flashMessage() async {
    try {
      final authProvider = Provider.of<FlashMessageProvider>(context, listen: false);

      final responseMessage = await authProvider.flashMessageRequest();
      if (responseMessage.isNotEmpty) {
        var isActive= responseMessage["active"];
        if (isActive == false) {
          showFlashMessageDialog(context, responseMessage['msg']);
        }else{
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
      } else {
        print("Get Flash Message failed: $responseMessage");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception =======$e");
      }
    }
  }

  void showFlashMessageDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Africall',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
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
