import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:linphonesdk_example/resourse/Utils.dart';
import 'package:permission_handler/permission_handler.dart';

import '../call_screen/call_screen.dart';
import '../resourse/app_colors.dart';
import '../resourse/image_paths.dart';

class CallDetailsScreen extends StatefulWidget {
  List<Map<String, dynamic>> callLogs = [];

  CallDetailsScreen(this.callLogs);

  @override
  _CallDetailsScreen createState() => _CallDetailsScreen();
}

class _CallDetailsScreen extends State<CallDetailsScreen> {
/*  List<Map<String, dynamic>> callLogs = [];
  static const EventChannel _eventChannel =
      EventChannel('com.example.linphone/events');
  static const MethodChannel _methodChannel =
      MethodChannel('com.example.linphone/call_log');
  StreamSubscription? _eventSubscription;*/
  List<Contact>? _cachedContacts;

  String? name;
  String? number;

  @override
  void initState() {
    super.initState();
    requestPermissionsn();
    setState(() {
      loadContactName1(widget.callLogs[0]['recipient'].toString().replaceAll('00263', ''));
      number = widget.callLogs[0]['recipient'];
    });
  }

  void loadContactName(String mNumber) async {
    String? name = await getNameFromNumber(mNumber);
    String displayName = name ?? "Unknown";
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(mNumber, displayName),
      ),
    );
  }

  void loadContactName1(String mNumber) async {
    String? name = await getNameFromNumber(mNumber.replaceAll("00", ""));
    String displayName = name ?? "Unknown";
    setState(() {
      name=displayName;
    });
  }

  String? getNameFromNumber(String number) {
    if (_cachedContacts == null) return null;
    String cleanedInput = number.replaceAll(RegExp(r'\D'), '');

    for (var contact in _cachedContacts!) {
      for (var phone in contact.phones) {
        String cleanedPhone = phone.number.replaceAll(RegExp(r'\D'), '');
        if (cleanedPhone.endsWith(cleanedInput) ||
            cleanedInput.endsWith(cleanedPhone)) {
          return contact.displayName;
        }
      }
    }
    return null;
  }

  Future<void> requestPermissionsn() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      Permission.microphone,
      Permission.contacts,
      Permission.bluetoothConnect
    ].request();

    if (statuses.values.any((status) => status != PermissionStatus.granted)) {
      print("Not all permissions granted!");
    } else {
      print("All permissions granted!");
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      _cachedContacts = contacts.toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with custom design
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.blue[900],
          leading: Container(
            color: Colors.yellow,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: Text(
            'Call Details',
            style: TextStyle(color: AppColors.white),
          ),
          centerTitle: true,
        ),
      ),
      body: Stack(
        children: [
          // Optional: blurred background image
          Positioned.fill(
            child: Image.asset(
              ImagePaths.backGround, // your background image
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.2),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Column(
            children: [
              // User Info
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.yellow,
                      child: Icon(Icons.person, size: 30, color: Colors.black),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.callLogs[0]['recipient'],
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                       /* Text(number!,
                            style: TextStyle(fontSize: 14)),*/
                      ],
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        loadContactName(number!);
                      },
                      child: Icon(Icons.call, size: 28),
                    )
                  ],
                ),
              ),
              // Call Details Box
              Expanded(
                flex: 1,
                child: ListView.separated(
                  itemCount: widget.callLogs.length,
                  padding: EdgeInsets.all(12),
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, index) {
                    final log = widget.callLogs[index];
                    return GestureDetector(
                      onTap: () {
                        print("Single tap on delete");
                        loadContactName(log['recipient']);
                      },
                      onLongPress: () {
                        // Handle long press
                      },
                      child: Card(
                        elevation: 4,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                           Padding(
                             padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                             child: Text(log['recipient']!,
                              style: TextStyle(fontSize: 14)),
                           ),
                              Row(
                                children: [
                                  Icon(Icons.call, color: Colors.amber),
                                  SizedBox(width: 8),
                                  Text(log['direction'],
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(Utils.formatTimes(log['timestamp'])),
                                  Text(Utils.formatDate(log['timestamp'])),
                                  Text(Utils.formatDuration(log['duration'])),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
