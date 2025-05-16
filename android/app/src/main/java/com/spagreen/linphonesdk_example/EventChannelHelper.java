package com.spagreen.linphonesdk_example;

import android.util.Log;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;

public class EventChannelHelper {
    private EventChannel.EventSink eventSink;
    private EventChannel eventChannel;

    public EventChannelHelper(BinaryMessenger messenger, String channelName) {
        eventChannel = new EventChannel(messenger, channelName);
        eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink sink) {
                eventSink = sink;
                Log.d("EventChannelHelper", "EventSink initialized");
            }

            @Override
            public void onCancel(Object arguments) {
                Log.d("EventChannelHelper", "EventSink cleared");
                eventSink = null;
            }
        });
    }

    public void success(Object data) {
        if (eventSink != null) {
            eventSink.success(data);
        } else {
            Log.w("EventChannelHelper", "EventSink is null, cannot send event: " + data);
        }
    }

    public void error(String errorCode, String errorMessage, Object errorDetails) {
        if (eventSink != null) {
            eventSink.error(errorCode, errorMessage, errorDetails);
        } else {
            Log.w("EventChannelHelper", "EventSink is null, cannot send error: " + errorMessage);
        }
    }
}