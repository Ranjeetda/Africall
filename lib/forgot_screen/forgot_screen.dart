import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:linphonesdk/linphoneSDK.dart';
import 'package:linphonesdk_example/resourse/app_colors.dart';
import 'package:provider/provider.dart';

import '../dashboardScreen/view_pager_with_selected_button.dart';
import '../provider/AuthProvider.dart';
import '../provider/forgot_service_provider.dart';
import '../resourse/Utils.dart';
import '../resourse/image_paths.dart';
import '../resourse/pref_utils.dart';

class ForgotScreen extends StatefulWidget {
  @override
  _ForgotScreen createState() => _ForgotScreen();
}

class _ForgotScreen extends State<ForgotScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final _linphoneSdkPlugin = LinphoneSDK();


  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final authProvider = Provider.of<ForgotServiceProvider>(context, listen: false);

      if (_emailController.text.isEmpty) {
        Utils.showErrorMessage(context, 'Enter your register email.');
        return;
      }

      // Call the registration function and await the response message
      try {
        setState(() {
          isLoading = true;
        });
        final responseMessage = await authProvider.sendForgotRequest(
          _emailController.text,
        );
        if (kDebugMode) {
          print("Response Forgot  ===========> $responseMessage");
        }
        setState(() {
          isLoading = false;
        });

        if (responseMessage['result'] == 'success') {
          final message = responseMessage['msg'];
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseMessage['msg'])),
          );
          print("Forgot failed: ${responseMessage['msg']}");
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
    final Color primaryColor = const Color(0xFF0A2342); // dark navy

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        title: Text('Forgot Password',style: TextStyle(color: Colors.white),),
      ),
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
                      ],
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
                          "Submit",
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
