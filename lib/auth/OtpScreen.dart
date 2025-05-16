import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dashboardScreen/view_pager_with_selected_button.dart';
import '../provider/verifyOtpProvider.dart';
import '../resourse/Utils.dart';
import '../resourse/app_colors.dart';
import '../resourse/pref_utils.dart';

class OtpScreen extends StatefulWidget {
  String? ccode; String? phone; String? email; String? firstname;String? lastname;String? uipass;

  OtpScreen(this.ccode, this.phone, this.email, this.firstname, this.lastname,
      this.uipass);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  final List<TextEditingController> _controllers =
  List.generate(4, (index) => TextEditingController());
  bool isLoading = false;

  void _submitForm() async {

      final authProvider = Provider.of<Verifyotpprovider>(context, listen: false);
      String otp = _controllers.map((c) => c.text).join();

      if (otp.length != 4) {
        Utils.showErrorMessage(context, 'Please enter all 4 digits.');
        return;
      }
      try {
        setState(() {
          isLoading = true;
        });
        String mOtp = _controllers.map((c) => c.text).join();

        final responseMessage = await authProvider.sendVerifyRequest(
          widget.ccode!,
          widget.phone!,
          mOtp,
          widget.email!,
          widget.firstname!,
          widget.lastname!,
          widget.uipass!,
        );
        if (kDebugMode) {
          print("Response Verify Otp ===========> $responseMessage");
        }
        setState(() {
          isLoading = false;
        });

        if (responseMessage['result'] == 'success') {
          final message = ''
              'Register successfully';
          String userName = responseMessage['userinfo']['username'];
          String password = responseMessage['userinfo']['password'];
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
          setState(() {
            isLoading = false;
          });
          print("Otp failed: ${responseMessage['message']}");
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

  @override
  void dispose() {
    _focusNodes.forEach((node) => node.dispose());
    _controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 24),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }
        },
      ),
    );
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
        title: Text(
          "Enter OTP",
          style:TextStyle(color: AppColors.white,),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, _buildOtpBox),
            ),
            const SizedBox(height: 24),

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
                    "SUBMIT",
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
      );
  }
}
