import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linphonesdk_example/resourse/app_colors.dart';
import 'package:linphonesdk_example/resourse/pref_utils.dart';
import 'package:provider/provider.dart';

import '../auth/login_choice_screen.dart';
import '../provider/delet_account_provider.dart';
import '../provider/fetch_profile_provider.dart';
import '../provider/update_profile_provider.dart';

class UpdateAccountPage extends StatefulWidget {
  @override
  _UpdateAccountPage createState() => _UpdateAccountPage();
}

class _UpdateAccountPage extends State<UpdateAccountPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  Future<void> getProfile() async {
    // Utils.showLoadingDialog(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final authProvider =
            Provider.of<FetchProfileProvider>(context, listen: false);
        final responseMessage = await authProvider.getProfileRequest(
            PrefUtils.getUserId(), PrefUtils.getPassword());

        if (kDebugMode) {
          print("Response Profile Data ===========> $responseMessage");
        }

        if (responseMessage['result'] == 'success') {
          // Utils.hideLoadingDialog();
          setState(() {
            firstNameController.text = responseMessage['msg']['firstname'];
            surnameController.text = responseMessage['msg']['lastname'];
            phoneController.text = responseMessage['msg']['phone'];
            usernameController.text = responseMessage['msg']['email'];
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseMessage['result'])),
            );
          });
        } else {
          // Utils.hideLoadingDialog();
          print("Get Profile Data failed: ${responseMessage['message']}");
        }
      } catch (e) {
        if (kDebugMode) {
          //Utils.hideLoadingDialog();
          print("Exception =======$e");
        }
      }
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final authProvider =
          Provider.of<UpdateProfileProvider>(context, listen: false);

      try {
        setState(() {
          isLoading = true;
        });
        final responseMessage = await authProvider.updateProfileRequest(
          PrefUtils.getUserId(),
          PrefUtils.getPassword(),
          firstNameController.text,
          surnameController.text,
          usernameController.text,
        );
        if (kDebugMode) {
          print("Response update Profile ===========> $responseMessage");
        }
        setState(() {
          isLoading = false;
        });

        if (responseMessage['result'] == 'success') {
          final message = responseMessage['msg'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        } else {
          print("Update profile failed: ${responseMessage['message']}");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Exception =======$e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueGrey[900],
        title: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(8),
                color: Colors.amber,
                child: Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
            SizedBox(width: 16),
            Text(
              "Update Account",
              style: TextStyle(color: AppColors.white),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildLabel("First Name"),
                buildTextField(controller: firstNameController),
                buildLabel("Surname"),
                buildTextField(controller: surnameController),
                buildLabel("Phone"),
                buildTextField(controller: phoneController, enabled: false),
                buildLabel("Username"),
                buildTextField(controller: usernameController),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      _submitForm();
                    },
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "UPDATE",
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
                SizedBox(height: 12),
                buildButton("CLOSE", Colors.amber, Colors.black),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      _showDeleteDialog(context);
                    },
                    child: const Text(
                      "DELETE ACCOUNT",
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 4),
      child: Text(label, style: TextStyle(fontSize: 16)),
    );
  }

  Widget buildTextField(
      {required TextEditingController controller, bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: TextStyle(
        color: enabled ? Colors.black : Colors.grey,
      ),
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black26),
        ),
      ),
    );
  }

  Widget buildButton(String text, Color bgColor, Color textColor) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          text,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        bool isDialogLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Important Reminder',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Account deletion is an unrecoverable operation...\n'),
                    Text(
                        '1) Your personal and account information will be completely deleted and unrecoverable.'),
                    SizedBox(height: 8),
                    Text(
                        '2) You will forfeit the remainder of your credit balance.'),
                    SizedBox(height: 8),
                    Text(
                        '3) Not possible to check information on your account and historical data.'),
                    SizedBox(height: 8),
                    Text(
                        '4) No access to Africall; you will need to create a new account.\n'),
                    Text(
                        'By clicking the “Delete Account” button, you agree to the above reminder'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                  ),
                  child: isDialogLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "DELETE ACCOUNT",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontFamily: 'TitilliumWeb',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                  onPressed: isDialogLoading
                      ? null
                      : () async {
                          setState(() => isDialogLoading = true);

                          final authProvider =
                              Provider.of<DeletAccountProvider>(context,
                                  listen: false);
                          final responseMessage =
                              await authProvider.sendDeleteAccountRequest(
                            PrefUtils.getUserId(),
                            PrefUtils.getPassword(),
                          );

                          setState(() => isDialogLoading = false);

                          if (responseMessage['status'] == 'success') {
                            final message = responseMessage['message'];

                            Navigator.of(dialogContext).pop();
                            PrefUtils.clearPreferences();
                            PrefUtils.setLoggedIn(false);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => LoginChoiceScreen()),
                                  (Route<dynamic> route) => false,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                            // You might want to log the user out or navigate away here
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Delete failed: ${responseMessage['message']}"),
                              ),
                            );
                          }
                        },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
