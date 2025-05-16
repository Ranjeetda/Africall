import 'package:flutter/material.dart';
import 'package:linphonesdk_example/auth/create_account.dart';

import '../resourse/image_paths.dart';
import 'login_choice_screen.dart';

class ContinueScreen extends StatelessWidget {
  const ContinueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background image
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImagePaths.backGround), // from @drawable/background_bg
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100),

              // Logo Image
              Center(
                child: Image.asset(
                  ImagePaths.logoVertical, // from @drawable/logo_vertical
                  width: 100,
                  height: 100,
                ),
              ),

              const SizedBox(height: 30),

              // Text Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: const [
                    Text(
                      "To sign up you will need on activation code.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Use you valid Mobile number to register and we ll test you code to this phone",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "By Signing Up. you agree to Africall Connect's",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Terms & Conditions",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFFF9BA16),
                      ),
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),

              // "and Privacy Policy"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "and",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Privacy Policy",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFF9BA16),
                    ),
                  ),
                ],
              ),

              // Continue Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 25),
                child: SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateAccount(),
                        ),
                      );

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9BA16), // match your drawable bg if custom
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // match round_corner_button_color
                      ),
                    ),
                    child: const Text(
                      "CONTINUE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'TitilliumWeb', // Load your custom font
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
