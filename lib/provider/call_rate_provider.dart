import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

class CallRateProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<Map<String, dynamic>> sendCallRateRequest(String CountryCode) async {
    try {
      _isLoading = true;
      notifyListeners();

      String key = '84a5b8c1&d*F8#97';

      String encryptedCountryCode = encryptString(CountryCode, key);

      String currentCountryCode = asHex(utf8.encode(encryptedCountryCode));






      var response = await http.post(
        Uri.parse("http://my.africallconnect.com/munya_api/billing_rates/get_rates.php"),
        headers: {
          "Accept-Language": "en-US,en;q=0.5",
        },
        body: {
          "rates": currentCountryCode,
        },
      );

      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print("Response Call Rates  ===========> ${response.body}");
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
