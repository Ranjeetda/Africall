import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:linphonesdk_example/resourse/pref_utils.dart';
import 'package:provider/provider.dart';

import '../provider/change_password.dart';
import '../resourse/Utils.dart';
import 'login_choice_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreen createState() => _ChangePasswordScreen();
}

class _ChangePasswordScreen extends State<ChangePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // Password visibility toggles
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;

  Future<void> changePassword() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_passwordController.text.isEmpty) {
        Utils.showErrorMessage(context, 'Enter your current password.');
        return;
      }else if (_passwordController.text!=PrefUtils.getPassword()) {
        Utils.showErrorMessage(context, 'Please enter valid old password.');
        return;
      } else if (_confirmPasswordController.text.isEmpty) {
        Utils.showErrorMessage(context, 'Please enter new Password.');
        return;
      }

      try {
        setState(() {
          isLoading = true;
        });

        final authProvider = Provider.of<ChangePassword>(context, listen: false);

        final responseMessage = await authProvider.sendChangePassRequest(
          _passwordController.text,
          _confirmPasswordController.text,
        );

        if (kDebugMode) {
          print("Response Change Password ===========> $responseMessage");
        }

        setState(() {
          isLoading = false;
        });

        if (responseMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseMessage['result'])),
          );
          PrefUtils.clearPreferences();
          PrefUtils.setLoggedIn(false);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginChoiceScreen()),
                (Route<dynamic> route) => false,
          );
        } else {
          print("Get Change Password failed: ${responseMessage['message']}");
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        if (kDebugMode) {
          print("Exception =======$e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF0A2342); // dark navy
    final Color accentColor = Colors.amber[700]!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        title: Text('Change Password', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Enter Old Password",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscureOldPassword,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureOldPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureOldPassword = !_obscureOldPassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Enter New Password",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45),
                child: SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      changePassword();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9BA16),
                      // Replace with your actual button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                        color: Colors.white)
                        : const Text(
                      "Update password",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        // @color/black_color
                        fontFamily: 'TitilliumWeb',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
