import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:linphonesdk_example/provider/balanceProvider.dart';
import 'package:linphonesdk_example/provider/call_rate_provider.dart';
import 'package:linphonesdk_example/provider/change_password.dart';
import 'package:linphonesdk_example/provider/delet_account_provider.dart';
import 'package:linphonesdk_example/provider/fetch_profile_provider.dart';
import 'package:linphonesdk_example/provider/flash_message_provider.dart';
import 'package:linphonesdk_example/provider/forgot_service_provider.dart';
import 'package:linphonesdk_example/provider/marqueeProvider.dart';
import 'package:linphonesdk_example/provider/registerProvider.dart';
import 'package:linphonesdk_example/provider/update_profile_provider.dart';
import 'package:linphonesdk_example/provider/verifyOtpProvider.dart';
import 'package:linphonesdk_example/resourse/Utils.dart';
import 'package:linphonesdk_example/resourse/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'provider/AuthProvider.dart';
import 'splashScreen/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => Balanceprovider()),
        ChangeNotifierProvider(create: (_) => Marqueeprovider()),
        ChangeNotifierProvider(create: (_) => ChangePassword()),
        ChangeNotifierProvider(create: (_) => Registerprovider()),
        ChangeNotifierProvider(create: (_) => Verifyotpprovider()),
        ChangeNotifierProvider(create: (_) => FetchProfileProvider()),
        ChangeNotifierProvider(create: (_) => UpdateProfileProvider()),
        ChangeNotifierProvider(create: (_) => DeletAccountProvider()),
        ChangeNotifierProvider(create: (_) => CallRateProvider()),
        ChangeNotifierProvider(create: (_) => ForgotServiceProvider()),
        ChangeNotifierProvider(create: (_) => FlashMessageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await Prefs.init();

  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          enableLog: true,
          title: 'Africall',
          home: SplashScreen(),
        );
      },
    );
  }
}
