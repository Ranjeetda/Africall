import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:linphonesdk/linphoneSDK.dart';
import 'package:linphonesdk/login_state.dart';
import 'package:linphonesdk_example/call_screen/call_screen.dart';
import 'package:linphonesdk_example/resourse/Utils.dart';
import 'package:marquee/marquee.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_number/phone_number.dart';
import 'package:provider/provider.dart';

import '../paymentScreen/buy_credit_screen.dart';
import '../provider/balanceProvider.dart';
import '../provider/call_rate_provider.dart';
import '../provider/marqueeProvider.dart';
import '../resourse/image_paths.dart';
import '../resourse/pref_utils.dart';

class HomeScreen extends StatefulWidget {
  final String? contactName;
  final DateTime? refreshTrigger;

  const HomeScreen({
    Key? key,
    this.contactName,
    this.refreshTrigger,
  }) : super(key: key);

  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  String typedNumber = "";
  bool isSelected = false;
  bool _isPressed0 = false;
  bool _isPressed1 = false;
  bool _isPressed2 = false;
  bool _isPressed3 = false;
  bool _isPressed4 = false;
  bool _isPressed5 = false;
  bool _isPressed6 = false;
  bool _isPressed7 = false;
  bool _isPressed8 = false;
  bool _isPressed9 = false;
  bool _isPressed10 = false;
  bool _isPressed11 = false;
  String? credit = '';
  String? currency = '';
  String? callprefix = '';
  String mRate="";
  String? marqueeValue = '';
  List<Contact>? _cachedContacts;
  final _linphoneSdkPlugin = LinphoneSDK();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final plugin = PhoneNumberUtil();

  DateTime? _lastRefresh;
  bool _hasRefreshedForThisTrigger = false;

  void _refreshData(String contactName) {
    setState(() {
      typedNumber = Utils.contactNumber;
      Utils.contactNumber = '';
    });
  }

  void _onNumberPressed(String number) {
    setState(() {
      typedNumber += number;
      if (typedNumber.startsWith("00") && typedNumber.length >= 5) {
        String value = typedNumber.replaceAll("00", "");
        callRate(value);
      }
    });
  }

  Future<void> callRate(String mCountryCode) async {
    try {
      final authProvider =
          Provider.of<CallRateProvider>(context, listen: false);
      final responseMessage =
          await authProvider.sendCallRateRequest(mCountryCode);
      if (responseMessage['result'] == 'success') {
        setState(() {
          mRate = responseMessage['rates'];
        });
      } else {
        print("Get Call Rate failed: ${responseMessage['message']}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Call Rate exception: $e");
      }
    }
  }

  void _deleteLastDigit() {
    setState(() {
      if (typedNumber.isNotEmpty) {
        typedNumber = typedNumber.substring(0, typedNumber.length - 1);
      }
    });
  }

  void _clearAll() {
    setState(() {
      typedNumber = "";
      mRate = "";
    });
  }

  @override
  void initState() {
    super.initState();
    login(PrefUtils.getUserId(), PrefUtils.getPassword());
    requestPermissionsn();
    requestPermissions();
    Future.microtask(() {
      balance();
      // marquee();
    });
  }

  Future<void> marquee() async {
    try {
      final authProvider = Provider.of<Marqueeprovider>(context, listen: false);

      final responseMessage = await authProvider.marqueeRequest();
      if (responseMessage.isNotEmpty) {
        setState(() {
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              marqueeValue = responseMessage;
            });
          });

          print("Response Marquee RealValue ===========> ${marqueeValue}");
        });
      } else {
        print("Get Marquee failed: $responseMessage");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception =======$e");
      }
    }
  }

  Future<void> login(String mUserName, String mPassword) async {
    await _linphoneSdkPlugin.login(
        userName: mUserName,
        domain: "my.africallconnect.com",
        password: mPassword);
  }

/*  @override
  void dispose() {
    _linphoneSdkPlugin.removeLoginListener();
    super.dispose();
  }*/

  Future<void> requestPermissions() async {
    try {
      _linphoneSdkPlugin.requestPermissions();
    } catch (e) {
      print("Error requesting permission: ${e.toString()}");
    }
  }

  Future<void> requestPermissionsn() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      Permission.microphone,
      Permission.contacts,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    if (statuses.values.any((status) => status != PermissionStatus.granted)) {
      print("Not all permissions granted!");
    } else {
      print("All permissions granted!");
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      _cachedContacts = contacts.toList();
    }
  }

  void loadContactName(String mNumber) async {
    String? name = await getNameFromNumber(mNumber);
    String displayName = name ?? "Unknown";
    print("RanjeetTestHomeScreen ==========> "+typedNumber!);
    String mCallNumber=typedNumber;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(mCallNumber, displayName),
      ),
    );

    _clearAll();
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

  Future<void> balance() async {
    try {
      final authProvider = Provider.of<Balanceprovider>(context, listen: false);
      final responseMessage = await authProvider.getBalanceRequest(
          PrefUtils.getUserId(), PrefUtils.getPassword());
      if (responseMessage.isNotEmpty) {
        setState(() {
          credit = responseMessage['credit'];
          currency = responseMessage['currency'];
          callprefix = responseMessage['callprefix'];
          print("Get Balance credit: ${credit}");
          print("Get Balance currency: ${currency}");
          print("Get Balance callprefix: ${callprefix}");

        });
      } else {
        print("Get Balance failed: ${responseMessage['message']}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Balance exception: $e");
      }
    }
  }

  Widget _buildMarquee() {
    return Marquee(
      text:
          "For any issues, please get in touch with us on +447455843955 from 9am-8pm GMT (WhatsApp calls & messages )          ",
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasRefreshedForThisTrigger &&
        widget.refreshTrigger != null &&
        widget.refreshTrigger != _lastRefresh &&
        widget.contactName != null) {
      _lastRefresh = widget.refreshTrigger;
      _hasRefreshedForThisTrigger = true;
      _refreshData(widget.contactName!);
    }
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImagePaths.backGround),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: _buildMarquee(),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      typedNumber.isEmpty ? "" : typedNumber,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (typedNumber.isNotEmpty)
                    GestureDetector(
                      onTap: _deleteLastDigit,
                      onLongPress: _clearAll,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Icon(Icons.backspace,
                            size: 28, color: Colors.redAccent),
                      ),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                mRate == ''
                    ? SizedBox()
                    : Padding(
                        padding: const EdgeInsets.only(right: 16.0, top: 5),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "  Rate : \$${mRate}",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0, top: 5),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: StreamBuilder<LoginState>(
                      stream: _linphoneSdkPlugin.addLoginListener(),
                      builder: (context, snapshot) {
                        LoginState status = snapshot.data ?? LoginState.none;
                        if(status.name=='none'){
                          login(PrefUtils.getUserId(), PrefUtils.getPassword());
                        }
                        return Text(
                          status.name == 'ok' ? 'Ready to call' :status.name=='none'?"Registering..": status.name,
                          textAlign: TextAlign.right,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 35.0, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Listener(
                    onPointerDown: (_) {
                      setState(() {
                        _isPressed1 = true;
                      });
                    },
                    onPointerUp: (_) {
                      setState(() {
                        _isPressed1 = false;

                      });
                      _onNumberPressed("1");
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isPressed1 ? Colors.amber : Colors.black,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          Text('1',
                              style:
                                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                          SizedBox(
                            height: 5,
                          ),
                          Text('',
                              style:
                                  TextStyle(color: Colors.amber, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  Listener(
                    onPointerDown: (_) {
                      setState(() {
                        _isPressed2 = true;
                      });
                    },
                    onPointerUp: (_) {
                      setState(() {
                        _isPressed2 = false;
                      });
                      _onNumberPressed("2");
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isPressed2 ? Colors.amber : Colors.black,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('2',
                              style:
                                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                          SizedBox(
                            height: 5,
                          ),
                          Text('ABC',
                              style:
                                  TextStyle(color: Colors.amber, fontWeight: FontWeight.bold,fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  Listener(
                    onPointerDown: (_) {
                      setState(() {
                        _isPressed3 = true;
                      });
                    },
                    onPointerUp: (_) {
                      setState(() {
                        _isPressed3 = false;
                      });
                      _onNumberPressed("3");
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isPressed3 ? Colors.amber : Colors.black,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('3',
                              style:
                                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.amber)),
                          SizedBox(
                            height: 5,
                          ),
                          Text('DEF',
                              style:
                                  TextStyle(color: Colors.amber, fontSize: 12)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 35.0, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Listener(
                    onPointerDown: (_) {
                      setState(() {
                        _isPressed4 = true;
                      });
                    },
                    onPointerUp: (_) {
                      setState(() {
                        _isPressed4 = false;
                      });
                      _onNumberPressed("4");
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isPressed4 ? Colors.amber : Colors.black,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('4',
                              style:
                                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                          SizedBox(
                            height: 5,
                          ),
                          Text('GHI',
                              style:
                                  TextStyle(color: Colors.amber, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  Listener(
                    onPointerDown: (_) {
                      setState(() {
                        _isPressed5 = true;
                      });
                    },
                    onPointerUp: (_) {
                      setState(() {
                        _isPressed5 = false;
                      });
                      _onNumberPressed("5");
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isPressed5 ? Colors.amber : Colors.black,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('5',
                              style:
                                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                          SizedBox(
                            height: 5,
                          ),
                          Text('JKL',
                              style:
                                  TextStyle(color: Colors.amber, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  Listener(
                    onPointerDown: (_) {
                      setState(() {
                        _isPressed6 = true;
                      });
                    },
                    onPointerUp: (_) {
                      setState(() {
                        _isPressed6 = false;
                      });
                      _onNumberPressed("6");
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isPressed6 ? Colors.amber : Colors.black,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('6',
                              style:
                                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                          SizedBox(
                            height: 5,
                          ),
                          Text('MNO',
                              style:
                                  TextStyle(color: Colors.amber, fontSize: 12)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 35.0, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Listener(
                    onPointerDown: (_) {
                      setState(() {
                        _isPressed7 = true;
                      });
                    },
                    onPointerUp: (_) {
                      setState(() {
                        _isPressed7 = false;
                      });
                      _onNumberPressed("7");
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isPressed7 ? Colors.amber : Colors.black,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('7',
                              style:
                                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                          SizedBox(
                            height: 5,
                          ),
                          Text('PQRS',
                              style:
                                  TextStyle(color: Colors.amber, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  Listener(
                    onPointerDown: (_) {
                      setState(() {
                        _isPressed8 = true;
                      });
                    },
                    onPointerUp: (_) {
                      setState(() {
                        _isPressed8 = false;
                      });
                      _onNumberPressed("8");
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isPressed8 ? Colors.amber : Colors.black,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('8',
                              style:
                                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                          SizedBox(
                            height: 5,
                          ),
                          Text('TUV',
                              style:
                                  TextStyle(color: Colors.amber, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  Listener(
                    onPointerDown: (_) {
                      setState(() {
                        _isPressed9 = true;
                      });
                    },
                    onPointerUp: (_) {
                      setState(() {
                        _isPressed9 = false;
                      });
                      _onNumberPressed("9");
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isPressed9 ? Colors.amber : Colors.black,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('9',
                              style:
                                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                          SizedBox(
                            height: 5,
                          ),
                          Text('WXYZ',
                              style:
                                  TextStyle(color: Colors.amber, fontSize: 12)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 35.0, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Listener(
                    onPointerDown: (_) {
                      setState(() {
                        _isPressed10 = true;
                      });
                    },
                    onPointerUp: (_) {
                      setState(() {
                        _isPressed10 = false;
                      });
                      _onNumberPressed("*");
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isPressed10 ? Colors.amber : Colors.black,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('*',
                              style:
                                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                          SizedBox(
                            height: 5,
                          ),
                          Text('',
                              style:
                                  TextStyle(color: Colors.amber, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  Listener(
                    onPointerDown: (_) {
                      setState(() {
                        _isPressed0 = true;
                      });
                    },
                    onPointerUp: (_) {
                      setState(() {
                        _isPressed0 = false;
                      });
                      _onNumberPressed("0");
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isPressed0 ? Colors.amber : Colors.black,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('0',
                              style:
                                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                          SizedBox(
                            height: 5,
                          ),
                          Text('',
                              style:
                                  TextStyle(color: Colors.amber, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  Listener(
                    onPointerDown: (_) {
                      setState(() {
                        _isPressed11 = true;
                      });
                    },
                    onPointerUp: (_) {
                      setState(() {
                        _isPressed11 = false;
                      });
                      _onNumberPressed("#");
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isPressed11 ? Colors.amber : Colors.black,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('#',
                              style:
                                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                          SizedBox(
                            height: 5,
                          ),
                          Text('',
                              style:
                                  TextStyle(color: Colors.amber, fontSize: 12)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
              color: Colors.grey,
              thickness: 1,
              height: 1,
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 35.0, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _bottomInfoBalence("Balance:", "\$$credit"),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(20),
                    ),
                    onPressed: () {
                      if (typedNumber.isNotEmpty) {

                        loadContactName(typedNumber);
                      }
                    },
                    child: Icon(Icons.call, size: 30, color: Colors.white),
                  ),
                  _bottomInfo(Icons.credit_card, "Top Up", ""),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomInfo(IconData icon, String label, String amount) {
    return InkWell(
      onTap: () {
        if (label == 'Top Up') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BuyCreditScreen()),
          );
        }
      },
      child: Container(
        height: 80,
        width: 80,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.amber),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.amber)),
            if (amount.isNotEmpty)
              Text(amount, style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _bottomInfoBalence(String label, String amount) {
    return InkWell(
      onTap: () {
        if (label == 'Top Up') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BuyCreditScreen()),
          );
        }
      },
      child: Container(
        height: 80,
        width: 80,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 10,
            ),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.amber)),
            SizedBox(
              height: 5,
            ),
            if (amount.isNotEmpty)
              Text(amount, style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
