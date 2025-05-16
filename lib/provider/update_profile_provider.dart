import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

class UpdateProfileProvider with ChangeNotifier {


  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<Map<String, dynamic>> updateProfileRequest(String userName, String password,String firstname,String lastname,email) async {
    try {
      _isLoading = true;
      notifyListeners();

      String key = '84a5b8c1&d*F8#97';

      String encryptedUserName = encryptString(userName, key);
      String encryptedPass = encryptString(password, key);
      String encryptedFirstName = encryptString(firstname, key);
      String encryptedLastName = encryptString(lastname, key);
      String encryptedEmail = encryptString(email, key);

      String mUserName = asHex(utf8.encode(encryptedUserName));
      String mPassword = asHex(utf8.encode(encryptedPass));
      String mFirstName = asHex(utf8.encode(encryptedFirstName));
      String mLastName = asHex(utf8.encode(encryptedLastName));
      String mEmail = asHex(utf8.encode(encryptedEmail));


      var response = await http.post(
        Uri.parse("http://my.africallconnect.com/munya_api/billing_user_edit/edit_user_details.php"),
        headers: {
          "Accept-Language": "en-US,en;q=0.5",
        },
        body: {
          "username": mUserName,
          "password": mPassword,
          "firstname": mFirstName,
          "lastname": mLastName,
          "email": mEmail,
        },
      );
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print("Response Update Account  ===========> ${response.body}");
      }
      var jsonData = jsonDecode(response.body);
      return jsonData;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Exception: $e");

      return {
        "result": "error",
        "msg": "An error occurred: $e",
      };
    }
  }

  String encryptString(String input, String keyStr) {
    // Make sure key is 16 bytes for AES-128
    final key = encrypt.Key.fromUtf8(keyStr.padRight(16, '0').substring(0, 16));

    // ECB mode does not require IV
    final encrypter = encrypt.Encrypter(
      encrypt.AES(
        key,
        mode: encrypt.AESMode.ecb,
        padding: 'PKCS7', // matches PKCS5 from Java
      ),
    );

    final encrypted = encrypter.encrypt(input);
    return encrypted.base64; // Just like Java's Base64.encodeBase64
  }

  String asHex(List<int> bytes) {
    const hexChars = '0123456789abcdef';
    final buffer = StringBuffer();

    for (var byte in bytes) {
      buffer.write(hexChars[(byte & 0xF0) >> 4]);
      buffer.write(hexChars[byte & 0x0F]);
    }

    return buffer.toString();
  }
}
