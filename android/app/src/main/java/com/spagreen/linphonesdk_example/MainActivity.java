package com.spagreen.linphonesdk_example;

import android.content.Context;
import android.media.AudioManager;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import org.linphone.core.CallLog;
import org.linphone.core.Core;
import org.linphone.core.Factory;
import org.linphone.core.Address;
import org.linphone.core.Call;

import com.spagreen.linphonesdk.EventChannelHelper;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    private static final String METHOD_CHANNEL = "com.example.linphone/call_log";
    private static final String EVENT_CHANNEL = "com.example.linphone/events";
    private static final String AUDIO_CHANNEL = "audio_channel"; // <-- For Bluetooth SCO

    private Core core;
    private EventChannelHelper eventChannelHelper;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // Initialize Linphone Core
        Factory factory = Factory.instance();
        try {
            core = factory.createCore(null, null, this);
            core.start();
            Log.d("Linphone", "Core initialized successfully");
        } catch (Exception e) {
            Log.e("Linphone", "Core initialization failed: " + e.getMessage());
            e.printStackTrace();
        }

        // MethodChannel: Call Logs
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("getCallLogs")) {
                        List<Map<String, Object>> callLogList = new ArrayList<>();
                        if (core != null) {
                            CallLog[] logs = core.getCallLogs();
                            for (int i = 0; i < logs.length; i++) {
                                CallLog log = logs[i];
                                Map<String, Object> logMap = new HashMap<>();
                                Address fromAddress = log.getFromAddress();
                                logMap.put("caller", fromAddress.getUsername() != null ? fromAddress.getUsername() : fromAddress.asString());
                                Address toAddress = log.getToAddress();
                                String recipientName = "Unknown";
                                if (toAddress != null) {
                                    recipientName = toAddress.getDisplayName() != null ? toAddress.getDisplayName() :
                                            toAddress.getUsername() != null ? toAddress.getUsername() :
                                                    toAddress.asString();
                                }
                                logMap.put("recipient", recipientName);
                                logMap.put("timestamp", log.getStartDate() * 1000);
                                logMap.put("duration", log.getDuration());
                                logMap.put("direction", log.getDir() == Call.Dir.Incoming ? "Incoming" : "Outgoing");
                                logMap.put("status", log.getStatus().toString());
                                logMap.put("id", log.getCallId() != null ? log.getCallId() : String.valueOf(i));
                                callLogList.add(logMap);
                            }
                            result.success(callLogList);
                        } else {
                            result.error("CORE_NULL", "Linphone Core not initialized", null);
                        }
                    } else if (call.method.equals("removeCallLog")) {
                        String callId = call.argument("callId");
                        if (core != null && callId != null) {
                            CallLog[] logs = core.getCallLogs();
                            for (CallLog log : logs) {
                                if (callId.equals(log.getCallId())) {
                                    core.removeCallLog(log);
                                    result.success(null);
                                    return;
                                }
                            }
                            result.error("NOT_FOUND", "Call log with callId " + callId + " not found", null);
                        } else {
                            result.error("CORE_NULL", "Linphone Core not initialized or invalid callId", null);
                        }
                    } else {
                        result.notImplemented();
                    }
                });

        // EventChannel
        eventChannelHelper = new EventChannelHelper(flutterEngine.getDartExecutor().getBinaryMessenger(), EVENT_CHANNEL);

        // MethodChannel: Bluetooth SCO audio routing
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), AUDIO_CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("startBluetoothSco")) {
                        AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
                        audioManager.setMode(AudioManager.MODE_IN_CALL);
                        audioManager.startBluetoothSco();
                        audioManager.setBluetoothScoOn(true);
                        result.success(true);
                    } else {
                        result.notImplemented();
                    }
                });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (core != null) {
            core.stop();
        }
    }
}
