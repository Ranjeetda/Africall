import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:linphonesdk/call_state.dart';
import 'package:linphonesdk/linphoneSDK.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import '../resourse/image_paths.dart';

class CallScreen extends StatefulWidget {
  final String? mNumber;
  final String? mDisplayName;

  CallScreen(this.mNumber, this.mDisplayName);

  @override
  _CallScreen createState() => _CallScreen();
}

class _CallScreen extends State<CallScreen> {
  final _linphoneSdkPlugin = LinphoneSDK();
  final AudioPlayer _audioPlayer = AudioPlayer();
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;

  bool isSpeakerOn = false;
  bool isMuted = false;
  bool isBluetoothOn = false;
  bool hasPermissions = false;

  Timer? _callTimer;
  Duration _callDuration = Duration.zero;
  CallState? _currentCallState;

  static const platform = MethodChannel('audio_channel');


  @override
  void initState() {
    super.initState();
    call(widget.mNumber!);
    _checkBluetoothState();
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    stopRingtone();
    super.dispose();
  }

  void startCallTimer() {
    _callTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration += Duration(seconds: 1);
      });
    });
  }

  void stopCallTimer() {
    _callTimer?.cancel();
    _callTimer = null;
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds % 60);
    return "$minutes:$seconds";
  }

  Future<void> call(String number) async {
    if (number.isNotEmpty) {
      await _linphoneSdkPlugin.call(number: number);
    }
  }

  Future<void> hangUp(BuildContext context) async {
    try {
      print('Hanging up...');
      await _linphoneSdkPlugin.hangUp();
      print('Hang up successful');
    } catch (e) {
      print('Hang up error: $e');
    }
    print('Navigated back');
  }


  Future<void> toggleSpeaker() async {
    await _linphoneSdkPlugin.toggleSpeaker();
  }

  Future<bool> toggleMute() async {
    return await _linphoneSdkPlugin.toggleMute();
  }

  void toggleSpeakerClick() {
    setState(() {
      toggleSpeaker();
      isSpeakerOn = !isSpeakerOn;
    });
  }

  void toggleMuteClick() {
    setState(() {
      toggleMute();
      isMuted = !isMuted;
    });
  }

  Future<void> playRingtone() async {
    await _audioPlayer.play(AssetSource('sounds/phone_ring.mp3'), volume: 1.0);
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> stopRingtone() async {
    await _audioPlayer.stop();
  }

  Future<void> _checkBluetoothState() async {
    bool? isEnabled = await bluetooth.isEnabled;
    setState(() {
      isBluetoothOn = isEnabled ?? false;
    });
    if (isBluetoothOn) {
      _connectToDevice();
    }
  }

  Future<void> _toggleBluetooth() async {
    if (isBluetoothOn) {
      await bluetooth.requestDisable();
      setState(() {
        isBluetoothOn = false;
      });
    } else {
      bool? enabled = await bluetooth.requestEnable();
      if (enabled == true) {
        setState(() {
          isBluetoothOn = true;
        });
        await _connectToDevice();
      }
    }
  }

  Future<void> _connectToDevice() async {
    if (await Permission.bluetoothConnect.request().isGranted &&
        await Permission.bluetoothScan.request().isGranted &&
        await Permission.location.request().isGranted) {
      List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
      if (devices.isNotEmpty) {
        BluetoothDevice targetDevice = devices.first;
        try {
          BluetoothConnection connection =
          await BluetoothConnection.toAddress(targetDevice.address);
          print('Connected to ${targetDevice.name}');
          connection.input?.listen((data) {
            print('Data received: ${String.fromCharCodes(data)}');
          });
        } catch (e) {
          print('Connection failed: $e');
        }
      } else {
        print('No paired devices found');
      }
    } else {
      print('Bluetooth permissions not granted');
    }
  }


  Future<void> startBluetoothSco() async {
    try {
      await platform.invokeMethod('startBluetoothSco');
    } on PlatformException catch (e) {
      print("Failed to start SCO: '${e.message}'.");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImagePaths.callback),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.6), BlendMode.darken),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 30),
            Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.yellow,
                  child: Icon(Icons.person, size: 50, color: Colors.black),
                ),
                SizedBox(height: 10),
                Text(
                  widget.mDisplayName ?? '',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.mNumber ?? '',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 10),
                StreamBuilder<CallState>(
                  stream: _linphoneSdkPlugin.addCallStateListener(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text("Calling...",
                          style: TextStyle(color: Colors.white));
                    }

                    final status = snapshot.data!;

                    if (_currentCallState != status) {
                      _currentCallState = status;

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        switch (status) {
                          case CallState.outgoingRinging:
                            playRingtone();
                            break;
                          case CallState.connected:
                            stopRingtone();
                            break;
                          case CallState.streamsRunning:
                            stopRingtone();
                            if (_callTimer == null) startCallTimer();
                            startBluetoothSco();
                            break;
                          case CallState.released:
                            hangUp(context);
                            Navigator.pop(context);

                            break;
                          case CallState.error:
                            stopRingtone();
                            stopCallTimer();
                            break;
                          default:
                            break;
                        }
                      });
                    }

                    // UI status display
                    switch (status) {
                      case CallState.outgoingInit:
                      case CallState.outgoingProgress:
                        return const Text("Calling...",
                            style: TextStyle(color: Colors.white));
                      case CallState.outgoingRinging:
                        return const Text("Ringing...",
                            style: TextStyle(color: Colors.white));
                      case CallState.connected:
                        return const Text("Connected",
                            style: TextStyle(color: Colors.white));
                      case CallState.streamsRunning:
                        return Column(
                          children: [
                            Text("Connected",
                                style: TextStyle(color: Colors.white)),
                            SizedBox(height: 5),
                            Text(
                              formatDuration(_callDuration),
                              style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        );
                      case CallState.paused:
                        return const Text("Call Paused",
                            style: TextStyle(color: Colors.white));
                      case CallState.pausedByRemote:
                        return const Text("Paused by Remote",
                            style: TextStyle(color: Colors.white));
                      case CallState.released:
                        return const Text("Call Ended",
                            style: TextStyle(color: Colors.white));
                      case CallState.error:
                        return const Text("Call Error",
                            style: TextStyle(color: Colors.red));
                      default:
                        return Text("Status: $status",
                            style: const TextStyle(color: Colors.white));
                    }
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(
                    ImagePaths.dialKeypad,
                    width: 40,
                    height: 40,
                    color: Colors.yellow,
                  ),
                  InkWell(
                    onTap: _toggleBluetooth,
                    child: Icon(
                      Icons.bluetooth,
                      size: 40,
                      color: isBluetoothOn ? Colors.green : Colors.yellow,
                    ),
                  ),
                  InkWell(
                    onTap: toggleSpeakerClick,
                    child: Icon(
                      Icons.volume_up,
                      size: 40,
                      color: isSpeakerOn ? Colors.green : Colors.yellow,
                    ),
                  ),
                  InkWell(
                    onTap: toggleMuteClick,
                    child: Icon(
                      Icons.mic_off,
                      size: 40,
                      color: isMuted ? Colors.red : Colors.yellow,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: GestureDetector(
                onTap: () {
                  print("RanjeetTest ========> Cut call");
                  hangUp(context);
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.call_end, size: 40, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
