import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:linphonesdk/linphoneSDK.dart';
import 'package:provider/provider.dart';

import '../dashboardScreen/view_pager_with_selected_button.dart';
import '../forgot_screen/forgot_screen.dart';
import '../provider/AuthProvider.dart';
import '../resourse/Utils.dart';
import '../resourse/image_paths.dart';
import '../resourse/pref_utils.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final _linphoneSdkPlugin = LinphoneSDK();
  bool _obscureText = true;


  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (_emailController.text.isEmpty) {
        Utils.showErrorMessage(context, 'Enter your mobile no.');
        return;
      } else if (_passwordController.text.isEmpty) {
        Utils.showErrorMessage(context, 'Password is required.');
        return;
      }

      // Call the registration function and await the response message
      try {
        setState(() {
          isLoading = true;
        });
        final responseMessage = await authProvider.sendLoginRequest(
          _emailController.text,
          _passwordController.text,
        );
        if (kDebugMode) {
          print("Response Register ===========> $responseMessage");
        }
        setState(() {
          isLoading = false;
        });
        final message = responseMessage['msg'];

        if (responseMessage['result'] == 'success') {
          String userName = responseMessage['userinfo']['username'];
          String password = responseMessage['userinfo']['uipass'];
          print("userName ===========> $userName");
          print("password ===========> $password");
          PrefUtils.setUserId(userName);
          PrefUtils.setPassword(password);
          PrefUtils.setLoggedIn(true);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => ViewPagerWithSelectedButton()),
                (Route<dynamic> route) => false,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print("Exception =======$e");
        }
      }
    }
  }


  @override
  void initState() {
    super.initState();
    requestPermissions();

  }

  Future<void> requestPermissions() async {
    try {
      _linphoneSdkPlugin.requestPermissions();
    } catch (e) {
      print("Error on request permission. ${e.toString()}");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                  ),
                  // Logo
                  Center(
                    child: Image.asset(
                      ImagePaths.logoVertical,
                      width: 100,
                      height: 100,
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Email and Password Fields
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 45),
                    child: Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'Enter registered Email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          obscureText: _obscureText,
                          controller: _passwordController,
                          decoration: InputDecoration(
                            hintText: 'Enter password',
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Forgotten Password
                  const SizedBox(height: 20),
                  InkWell(onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotScreen(),
                      ),
                    );
                  },
                  child:  Padding(
                    padding: const EdgeInsets.only(right: 45),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Forgotten Password',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  ),
                  // Login Button
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 45),
                    child: SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          _submitForm();
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
                                "LOGIN",
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
            )),
      ),
    );
  }
}
