import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:linphonesdk/linphoneSDK.dart';
import 'package:intl/intl.dart';
import 'package:linphonesdk_example/resourse/Utils.dart';
import 'package:permission_handler/permission_handler.dart';

import '../call_screen/call_screen.dart';
import 'call_details_screen.dart';

class CallLogScreen extends StatefulWidget {
  @override
  _CallLogScreen createState() => _CallLogScreen();
}

class _CallLogScreen extends State<CallLogScreen> {

  List<Map<String, dynamic>> callLogs = [];
  static const EventChannel _eventChannel = EventChannel('com.example.linphone/events');
  static const MethodChannel _methodChannel = MethodChannel('com.example.linphone/call_log');
  StreamSubscription? _eventSubscription;
  List<Contact>? _cachedContacts;

  @override
  void initState() {
    super.initState();
    requestPermissionsn();
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
          (event) {
        print('Received event: $event');
        // Handle events, e.g., update UI
      },
      onError: (error) {
        print('EventChannel error: $error');
      },
      onDone: () {
        print('EventChannel closed');
      },
    );
    _fetchCalls();

  }
  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchCalls() async {
    try {
      final result = await _methodChannel.invokeMethod('getCallLogs');
      setState(() {
        // Safely cast result to List<Map<String, dynamic>>
        callLogs = (result as List<dynamic>).map((item) {
          return (item as Map<Object?, Object?>).cast<String, dynamic>();
        }).toList();
      });
    } on PlatformException catch (e) {
      print("Failed to fetch call logs: '${e.message}'.");
    }
  }

  Future<void> _removeCall(String callId) async {
    try {
      await _methodChannel.invokeMethod('removeCallLog', {'callId': callId});
      _fetchCalls();
    } on PlatformException catch (e) {
      print("Failed to remove call log: '${e.message}'.");
    }
  }

  String formatTimestamp(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    DateTime now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return "Today";
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return "Yesterday";
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  String dateTimeFormate(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  Icon getCallIcon(String? direction, String? status) {
    if (direction == 'Incoming') {
      if (status == 'Missed') {
        return Icon(Icons.call_missed, color: Colors.red);
      } else {
        return Icon(Icons.call_received, color: Colors.green);
      }
    } else {
      return Icon(Icons.call_made, color: Colors.blue);
    }
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
      backgroundColor: Colors.white,
      body: ListView.separated(
        itemCount: callLogs.length,
        padding: EdgeInsets.all(12),
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) {
          final log = callLogs[index];
          return GestureDetector(
            onTap: () {
              print("Single tap on delete");
              loadContactName(log['recipient']!);
           /*   Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CallDetailsScreen(callLogs),
                ),
              );*/
            },
            onLongPress: () {
              // Handle long press
              print("Long press on delete");
              _showDeleteConfirmation(log['id']); // Example function
            },
            child:  Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.amber,
                  child: Icon(Icons.person, color: Colors.black, size: 28),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log['recipient'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          )),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          getCallIcon(log['direction'], log['status']),
                          SizedBox(width: 6),
                          Text('${Utils.formatTimestampDate(log['timestamp'])}'),
                          Spacer(),
                          Text(Utils.formatDuration(log['duration']), style: TextStyle(fontSize: 13)),
                          Spacer(),
                          Text('${Utils.formatTimestamp(log['timestamp'])}'),

                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

        },
      )
    );
  }

  void _showDeleteConfirmation(String logId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Call"),
          content: Text("Are you sure you want to delete this call log?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                _removeCall(logId); // Proceed to delete
              },
            ),
          ],
        );
      },
    );
  }

}
