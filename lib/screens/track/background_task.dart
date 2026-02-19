import 'dart:async';
import 'dart:developer';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../../source/constant/local_data.dart';

// var trackServices = TrackingApiServices.instance;

class MyTaskHandler extends TaskHandler {
  int _count = 0;
  late String _trackId; // Store trackId

  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    log('onStart');

    // Initialize trackId by reading from storage
    _trackId = localData.storage.read("TrackId") ?? '';

    // Set up a listener for changes to TrackId
    localData.storage.listenKey("TrackId", (value) {
      _trackId = value;
      log("TrackId updated: $_trackId");
    });
  }

  Timer? _timer;

  // Method to handle periodic events
  @override
  void onRepeatEvent(DateTime timestamp) {
    FlutterForegroundTask.updateService(notificationText: 'Track On');

    // Send data to main isolate
    FlutterForegroundTask.sendDataToMain(_count);

    // Check if the timer already exists
    _timer ??= Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      // print("seconds ${DateTime.now()}");

      // Check if "Track" is true and insert tracking data with the latest TrackId
      // if (controller.storage.read("Track") == true) {
      //   print("Track On with TrackId: $_trackId");
      //   trackServices.insertTracking(_trackId, false);
      // }
    });

    _count++;
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    log('onDestroy');
    _timer?.cancel(); // Cancel the timer if it's running
  }

  @override
  void onReceiveData(Object data) {
    log('onReceiveData: $data');
  }

  @override
  void onNotificationButtonPressed(String id) {
    log('onNotificationButtonPressed: $id');
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/');
    log('onNotificationPressed');
  }

  @override
  void onNotificationDismissed() {
    log('onNotificationDismissed');
  }
}
