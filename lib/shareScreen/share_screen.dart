import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../resourse/image_paths.dart';

class ShareScreen extends StatefulWidget {
  @override
  _ShareScreen createState() => _ShareScreen();
}

class _ShareScreen extends State<ShareScreen> {
  final String shareLink = "I use AfriCall to call Zimbabwe. For US 0.12/min, This is great! I highly recommend. Use this link to register and start calling. http://africallconnect.com/invite-friends";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Color(0xFF0D203E),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.yellow),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Share AfriCall Link",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImagePaths.backGround), // Replace with your background image
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3), BlendMode.darken),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  ImagePaths.earn, // Replace with your image
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  color: Colors.yellow,
                  child: Text(
                    'Be the reason why someone says thank you.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF0E213D),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0D203E),
                    padding:
                    EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    Share.share(shareLink);
                  },
                  child: Text(
                    'Click to Share',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 18,
                      letterSpacing: 1,
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
}
