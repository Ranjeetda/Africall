import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:linphonesdk_example/resourse/app_colors.dart';
import 'package:provider/provider.dart';

import '../provider/registerProvider.dart';
import '../resourse/Utils.dart';
import '../resourse/image_paths.dart';
import 'OtpScreen.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccount createState() => _CreateAccount();
}

class _CreateAccount extends State<CreateAccount> {
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _sureController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? mCountryCode = '+44';
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final authProvider = Provider.of<Registerprovider>(context, listen: false);

      if (_firstController.text.isEmpty) {
        Utils.showErrorMessage(context, 'Enter your first name.');
        return;
      } else if (_sureController.text.isEmpty) {
        Utils.showErrorMessage(context, 'Enter your last name.');
        return;
      } else if (mCountryCode!.isEmpty) {
        Utils.showErrorMessage(context, 'Select country code.');
        return;
      } else if (_mobileController.text.isEmpty) {
        Utils.showErrorMessage(context, 'Enter your mobile number.');
        return;
      } else if (_emailController.text.isEmpty) {
        Utils.showErrorMessage(context, 'Enter your email.');
        return;
      } else if (_passwordController.text.isEmpty) {
        Utils.showErrorMessage(context, 'Password is required.');
        return;
      }

      try {
        setState(() {
          isLoading = true;
        });

        final responseMessage = await authProvider.sendSignupRequest(
          mCountryCode!,
          _mobileController.text,
          _emailController.text,
          _firstController.text,
          _sureController.text,
          _passwordController.text,
        );

        setState(() {
          isLoading = false;
        });

        if (responseMessage['result'] == 'success') {
          final message = responseMessage['OTP'];

          showOTPDialog(context,message.toString().replaceAll("Your OTP  send to your Mobile number.", ""));
    /*      ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );*/
        } else {
          Utils.showErrorMessage(context, responseMessage['message'] ?? 'Registration failed.');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        if (kDebugMode) {
          print("Exception =======> $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.button_color),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Create Account",
          style: TextStyle(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImagePaths.backGround),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 150),
                  _buildTextField(
                    hint: 'First Name',
                    mcontroller: _firstController,
                  ),
                  const SizedBox(height: 5),
                  _buildTextField(
                    hint: 'SurName',
                    mcontroller: _sureController,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      CountryCodePicker(
                        initialSelection: 'GB',
                        favorite: ['+44', 'GB'],
                        showCountryOnly: false,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                        onChanged: (country) {
                          mCountryCode = country.dialCode;
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTextField(
                          hint: 'Phone Number',
                          mcontroller: _mobileController,
                          inputType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  _buildTextField(
                    hint: 'E-mail',
                    mcontroller: _emailController,
                    inputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    obscureText: _obscureText,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: 'Create Password',
                      hintStyle: const TextStyle(color: Color(0xFF959595)),
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
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () {
                      showDialogebox(context, mCountryCode!+_mobileController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9BA16),
                      minimumSize: const Size(double.infinity, 35),
                    ),
                    child:  Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontFamily: 'TitilliumWeb',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController mcontroller,
    TextInputType inputType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: mcontroller,
      keyboardType: inputType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF959595)),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF959595)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  void showOTPDialog(BuildContext context, String otp) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$otp. valid for\n30 seconds',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    minimumSize: Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtpScreen(
                          mCountryCode,
                          _mobileController.text,
                          _emailController.text,
                          _firstController.text,
                          _sureController.text,
                          _passwordController.text,
                        ),
                      ),
                    );

                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showDialogebox(BuildContext context, String phoneNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          content: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.cyan[100], fontSize: 18),
              children: [
                TextSpan(text: "We will send a verification code to this number\n"),
                TextSpan(
                  text: "$phoneNumber ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: "Is this OK, or would you like to edit the number?"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
              child: Text("Edit"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _submitForm(); // Proceed
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

}
