import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SupportScreen extends StatefulWidget {
  @override
  _SupportScreen createState() => _SupportScreen();
}

class _SupportScreen extends State<SupportScreen> {

  final Color primaryColor = const Color(0xFF0A2342);
  final Color accentColor = Colors.amber;

  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('http://africallconnect.com/support/'));
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
        title: Text("Africall Support",style: TextStyle(color: Colors.white),),
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
