import 'package:flutter/material.dart';
import 'package:linphonesdk_example/resourse/pref_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatefulWidget {
  String? mAmount;

  PaymentScreen(this.mAmount);

  @override
  _PaymentScreen createState() => _PaymentScreen();
}

class _PaymentScreen extends State<PaymentScreen> {

  final Color primaryColor = const Color(0xFF0A2342);
  final Color accentColor = Colors.amber;

  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    String user1 = PrefUtils.getUserId();
    String pass1 = PrefUtils.getPassword();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse("http://192.99.233.140/customer/checkout_confirmation_mo.php?pr_login=$user1&pr_password=$pass1&payment=paypal&amount=${widget.mAmount!}&mobiledone=submit_log"));
  }
  Future<void> _handleBackButton() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
    } else {
      Navigator.of(context).pop();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("Africall",style: TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: _handleBackButton,
        ),
      ),
      body: SafeArea(

        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
