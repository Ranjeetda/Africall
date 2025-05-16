import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:linphonesdk_example/resourse/image_paths.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  @override
  _ContactUsScreen createState() => _ContactUsScreen();
}

class _ContactUsScreen extends State<ContactUsScreen> {

  final Color primaryColor = const Color(0xFF0A2342);
  final Color accentColor = Colors.amber;

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildContactRow(IconData icon, String label, String content, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.amber[800], size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$label :", style: const TextStyle(fontSize: 16)),
                GestureDetector(
                  onTap: () => _launchURL(url),
                  child: Text(
                    content,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        title: Text('Contact Us',style: TextStyle(color: Colors.white),),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Logo
          Image.asset(ImagePaths.connectLogo, height: 150,width: 150,), // Replace with your image asset
          const SizedBox(height: 20),

          // Contact Details
          _buildContactRow(Icons.email, "Email", "info@africallconect.com", "mailto:info@africallconect.com"),
          _buildContactRow(FontAwesomeIcons.whatsapp, "WhatsApp", "+447455843955", "https://wa.me/447455843955"),
          _buildContactRow(Icons.phone_android, "Phone", "+447455843955", "tel:+447455843955"),
        ],
      ),
    );
  }
}
