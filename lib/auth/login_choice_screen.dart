import 'package:flutter/material.dart';
import 'package:linphonesdk_example/auth/login_screen.dart';

import '../resourse/image_paths.dart';
import 'continue_screen.dart';
import 'create_account.dart';

class LoginChoiceScreen extends StatelessWidget {
  const LoginChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImagePaths.backGround), // @drawable/background_bg
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Main Content
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 100),

                  // Logo
                  Center(
                    child: Image.asset(
                      ImagePaths.logoVertical,
                      width: 100,
                      height: 100,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Buttons Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 45),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF9BA16), // Use your theme color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "LOGIN",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontFamily: 'TitilliumWeb',
                                letterSpacing: 1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "or",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () {

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ContinueScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF9BA16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "CREATE ACCOUNT",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontFamily: 'TitilliumWeb',
                                letterSpacing: 1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 150), // To make room above bottom text
                ],
              ),
            ),

            // Contact Info Bottom Section
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "To Contact Us,",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF1E88E5), // Replace with your @color/primary_color
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "CALL ",
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                        Text(
                          "OR ",
                          style: TextStyle(
                              fontSize: 18, color: Color(0xFF1E88E5)),
                        ),
                        Text(
                          "WhatsApp ",
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                        Text(
                          "Us on",
                          style: TextStyle(fontSize: 18, color: Color(0xFFF9BA16)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "+447455843955",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF1E88E5),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
