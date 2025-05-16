import 'package:flutter/material.dart';
import 'package:linphonesdk_example/auth/login_screen.dart';
import 'package:linphonesdk_example/resourse/pref_utils.dart';

import '../auth/change_password_screen.dart';
import '../auth/login_choice_screen.dart';
import '../contactScreen/contact_us_screen.dart';
import '../contactScreen/support_screen.dart';
import '../contactScreen/term_condition.dart';
import '../contactScreen/whatsapp_screen.dart';
import '../paymentScreen/buy_credit_screen.dart';
import '../profile/update_account_page.dart';
import '../shareScreen/share_screen.dart';


class MoreScreen extends StatefulWidget {
  @override
  _MoreScreen createState() => _MoreScreen();
}


class _MoreScreen extends State<MoreScreen> {

  void showCustomExitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Do you really want to\nexit?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  // OK Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        PrefUtils.clearPreferences();
                        PrefUtils.setLoggedIn(false);
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => LoginChoiceScreen()),
                              (Route<dynamic> route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF2C94C), // Yellow
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "OK",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // CANCEL Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false); // return false
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1B1F3B), // Dark blue
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "CANCEL",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            leading: Icon(Icons.settings, color: Colors.amber),
            title: Text('My Profile', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateAccountPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.help, color: Colors.amber),
            title: Text('Change Password', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangePasswordScreen(),
                ),
              );
            },
          ), ListTile(
            leading: Icon(Icons.help, color: Colors.amber),
            title: Text('Buy Credit', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BuyCreditScreen(),
                ),
              );
            },
          ),ListTile(
            leading: Icon(Icons.help, color: Colors.amber),
            title: Text('Invite Friends', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShareScreen(),
                ),
              );
            },
          ),ListTile(
            leading: Icon(Icons.help, color: Colors.amber),
            title: Text('Support', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SupportScreen(),
                ),
              );
            },
          ),ListTile(
            leading: Icon(Icons.help, color: Colors.amber),
            title: Text('Contact Us', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactUsScreen(),
                ),
              );
            },
          ),ListTile(
            leading: Icon(Icons.help, color: Colors.amber),
            title: Text('Whatsapp Us', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WhatsappScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.help, color: Colors.amber),
            title: Text('Terms & Conditions', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TermCondition(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.amber),
            title: Text('Sign Out', style: TextStyle(color: Colors.black)),
            onTap: () {
              showCustomExitDialog(context);

            },
          ),
        ],
      ),
    );
  }
}
