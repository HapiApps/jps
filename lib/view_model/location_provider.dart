import 'dart:async';
import 'dart:developer';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../component/custom_text.dart';
import '../source/utilities/utils.dart';


class LocationProvider with ChangeNotifier{
String _latitude = "";
String _longitude = "";
String get latitude=>_latitude;
String get longitude=>_longitude;

  late StreamSubscription<Position> streamSubscription;

  // @override
  // void onInit() {
  //   super.onInit();
  //   requestPermissions();
  // }
  //
  // @override
  // void onClose() {
  //   streamSubscription.cancel();
  //   super.onClose();
  // }

  /// Request permissions and fetch location
  // void requestPermissions() async {
  //   try {
  //     // Request location and notification permissions
  //     Map<Permission, PermissionStatus> status = await [
  //       Permission.location,
  //       Permission.notification,
  //     ].request();
  //
  //     // Handle location permission
  //     if (status[Permission.location] == PermissionStatus.granted) {
  //       // Start fetching the location stream
  //       _startLocationStream();
  //     } else if (status[Permission.location] == PermissionStatus.denied) {
  //       var permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.deniedForever) {
  //         log("Location permissions are permanently denied.");
  //         // await openAppSettings();
  //       }
  //     }
  //
  //     // Handle notification permission
  //     if (status[Permission.notification] == PermissionStatus.granted) {
  //       // log("Notification permission granted.");
  //     } else if (status[Permission.notification] == PermissionStatus.denied) {
  //       if (status[Permission.notification]!.isPermanentlyDenied) {
  //       }
  //     }
  //   } catch (e) {
  //     log("Error requesting permissions: $e");
  //   }
  // }
void requestPermissions() async {
  try {
    // 1️⃣ Ask LOCATION permission first
    PermissionStatus locationStatus = await Permission.location.request();

    if (locationStatus == PermissionStatus.granted) {
      _startLocationStream();
    }

    // 2️⃣ Small delay (VERY IMPORTANT)
    await Future.delayed(const Duration(milliseconds: 500));

    // 3️⃣ Ask NOTIFICATION permission
    await askNotificationPermission();

  } catch (e) {
    log("Error requesting permissions: $e");
  }
}
void requestNotificationPermissions() async {
  try {
    await askNotificationPermission();
  } catch (e) {
    log("Error requesting permissions: $e");
  }
}

Future<void> askNotificationPermission() async {
  PermissionStatus status = await Permission.notification.status;

  if (status.isGranted) return; // don't ask again

  PermissionStatus newStatus = await Permission.notification.request();

  if (newStatus.isGranted) {
    log("Notification permission granted");
  } else if (newStatus.isPermanentlyDenied) {
    log("Notification permission permanently denied");
  }
}

Future<void> manageLocation(context, bool openSetting) async {
  try {
    // log('get location: $_latitude $_longitude');

    // Request location permission
    PermissionStatus status = await Permission.location.request();
    _latitude="";_longitude="";
    if (status == PermissionStatus.granted) {
      // Check if Location Service is enabled
      bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled&&!kIsWeb) {
        utils.showWarningToast(context, text: "Location services are disabled. Please enable them from settings.");
        return;
      }

      if(kIsWeb){
        var position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high, // or .best for iOS/web
          ),);
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
      }else{
        Position position = await Geolocator.getCurrentPosition();
        _latitude = "${position.latitude}";
        _longitude = "${position.longitude}";
      }
      // log('Current location: $_latitude $_longitude');

      if (_latitude == "" && _longitude == "") {
        utils.showWarningToast(context, text: "Check your location accuracy.");
      }

    } else if (status == PermissionStatus.denied) {
      utils.showWarningToast(context, text: "Location permission is required to continue.");

    } else if (status == PermissionStatus.permanentlyDenied) {
      // iOS compliance: Show info dialog, don't auto-redirect to settings
      if (!kIsWeb&&openSetting) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: CustomText(text:"Permission Required",colors: colorsConst.primary,isBold: true,),
            content: CustomText(text:"This feature requires location permission. Please enable it from Settings.",colors: colorsConst.secondary,),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: CustomText(text:"Not Now",colors: colorsConst.appRed),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings(); // Only if user agrees
                },
                child: CustomText(text:"Go to Settings",colors: colorsConst.blueClr),
              ),
            ],
          ),
        );
      }else{
        var position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
      }
      // log('Current location: $_latitude $_longitude');
    }

  } on PlatformException catch (e) {
    log('Failed to get location: ${e.message}');
  }
  notifyListeners();
}

//separate function for showing dialog
/// Starts streaming the user's location and updating latitude/longitude
  void _startLocationStream() {
    try {
      streamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,  // Set to high accuracy
          distanceFilter: 10,               // Minimum distance to trigger updates
          // timeLimit is optional here if you want to use it for limiting the request time
        ),
      ).listen((Position position) {
        _latitude = "${position.latitude}";
        _longitude = "${position.longitude}";
      });
    } catch (e) {
      log("Error starting location stream: $e");
    }
  }

  /// Cancels the location stream when no longer needed (optional)
  void stopLocationStream() {
    streamSubscription.cancel();
    log("Location stream cancelled.");
    }

  /// Check if the location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      log("Location services are disabled.");
    }
    return serviceEnabled;
  }

  /// Gets the current position once, with a timeout and error handling
  void getLocation() async {
    const platform = MethodChannel('location');
    try {
      final String location = await platform.invokeMethod('getCurrentLocation');
      _latitude=location.toString().split(",")[0];
      _longitude=location.toString().split(",")[1];
      log('Current location: $location');
    } on PlatformException catch (e) {
      log('Failed to get location: ${e.message}');
    }
  }
}