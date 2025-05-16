package com.spagreen.linphonesdk_example;

import android.os.Bundle;
import android.util.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.BinaryMessenger;
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
    private Core core;
    private EventChannelHelper eventChannelHelper;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

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

        // Set up MethodChannel
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("getCallLogs")) {
                                List<Map<String, Object>> callLogList = new ArrayList<>();
                                if (core != null) {
                                    CallLog[] logs = core.getCallLogs();
                                    for (int i = 0; i < logs.length; i++) {
                                        CallLog log = logs[i];
                                        Map<String, Object> logMap = new HashMap<>();
                                        // Caller information
                                        Address fromAddress = log.getFromAddress();
                                        logMap.put("caller", fromAddress.getUsername() != null ? fromAddress.getUsername() : fromAddress.asString());
                                        // Recipient information
                                        Address toAddress = log.getToAddress();
                                        String recipientName = "Unknown";
                                        if (toAddress != null) {
                                            recipientName = toAddress.getDisplayName() != null ? toAddress.getDisplayName() :
                                                    toAddress.getUsername() != null ? toAddress.getUsername() :
                                                            toAddress.asString();
                                        }
                                        logMap.put("recipient", recipientName);

                                        //logMap.put("recipient", toAddress.getUsername() != null ? toAddress.getUsername() : toAddress.asString());
                                        // Timestamp (convert seconds to milliseconds)
                                        logMap.put("timestamp", log.getStartDate() * 1000);
                                        // Duration (in seconds)
                                        logMap.put("duration", log.getDuration());
                                        // Direction (Incoming or Outgoing)
                                        logMap.put("direction", log.getDir() == Call.Dir.Incoming ? "Incoming" : "Outgoing");
                                        // Status (e.g., Success, Missed)
                                        logMap.put("status", log.getStatus().toString());
                                        // Call ID as unique identifier
                                        logMap.put("id", log.getCallId() != null ? log.getCallId() : String.valueOf(i));
                                        // Video enabled (comment out if getVideoEnabled is unavailable)
                                      //  logMap.put("videoEnabled", log.getVideoEnabled());
                                        // Call quality
                                        //logMap.put("quality", log.getQuality());
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
                        }
                );

        // Set up EventChannel
        eventChannelHelper = new EventChannelHelper(getFlutterEngine().getDartExecutor().getBinaryMessenger(), EVENT_CHANNEL);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (core != null) {
            core.stop();
        }
    }
}