
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../resourse/Utils.dart';

class FlashMessageProvider with ChangeNotifier {

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<Map<String, dynamic>> flashMessageRequest() async {
    try {
      _isLoading = true;
      notifyListeners();

      var response = await http.get(
        Uri.parse("https://my.africallconnect.com/munya_api/billing_text_display/display_flash.php"),
        headers: {
          "Accept-Language": "en-US,en;q=0.5",
        },
      );

      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print("Response Fetch Message Flash  ===========> ${response.body}");
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
}
