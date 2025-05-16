
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../resourse/Utils.dart';

class Marqueeprovider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String> marqueeRequest() async {
    try {
      _isLoading = true;
      notifyListeners();

      var response = await http.get(
        Uri.parse("http://192.99.233.140/munya_api/display_text.php"),
        headers: {
          "Accept-Language": "en-US,en;q=0.5",
        },
      );

      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print("Response Fetch Marquee  ===========> ${response.body}");
      }
      Utils.marqueeValue = response.body;
      return response.body;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Exception: $e");

      return "An error occurred: $e";
    }
  }
}
