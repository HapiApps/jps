import 'dart:developer';
import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:master_code/component/custom_checkbox.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:geolocator/geolocator.dart';
import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/styles/decoration.dart';
import 'package:master_code/view_model/attendance_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../component/animated_button.dart';
import '../../model/leave/leave_model.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/language_model.dart';
import '../../source/constant/language_model.dart';
import '../../source/constant/local_data.dart';
import '../../source/utilities/utils.dart';
import '../../component/custom_text.dart';
import '../../view_model/customer_provider.dart';
import '../../view_model/leave_provider.dart';
import '../../view_model/location_provider.dart';
import 'package:provider/provider.dart';
import 'package:master_code/view_model/home_provider.dart';

import '../common/dashboard.dart';
import '../common/home_page.dart';
import '../controller/track_controller.dart';
import '../leave_management/leave_dashboard.dart';
import '../leave_management/leave_summary.dart';
import 'attendance_report.dart';

class CheckAttendance extends StatefulWidget {
  const CheckAttendance({super.key});

  @override
  State<CheckAttendance> createState() => _CheckAttendanceState();
}

class _CheckAttendanceState extends State<CheckAttendance> {

  /// ✅ NEW: button tap pannadhum udane button-kulla chinna loader.
  /// (leave check + server check mudiyura varaikkum ethuvum nadakkalanu
  ///  thonaama irukka). Double tap-um block aagum.
  bool _btnLoading = false;

  @override
  void initState() {
    super.initState();
    final locProvider = Provider.of<LocationProvider>(context, listen: false);
    final attProvider = Provider.of<AttendanceProvider>(context, listen: false);

    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      Provider.of<LeaveProvider>(context, listen: false)
          .refreshMyTodayLeave(context);
    });

    if (attProvider.attCheck == false) {
      Future.delayed(Duration.zero, () {
        if (!mounted) return;
        locProvider.manageLocation(context, false);
      });
    }
  }
  // ===========================================================================
  // ✅ FRESH LOCATION (attendance / permission tap pannum bodhu)
  //  1. high accuracy, 15 sec
  //  2. vehicle / weak GPS -> medium accuracy, 10 sec
  //  3. last known position (5 nimisham kulla irundha mattum, mobile)
  //  4. edhuvum kidaikkala -> null (attendance block + clear message)
  // ===========================================================================
  static const int _lastKnownMaxAgeMins = 5;

  bool _validCoord(String v) {
    final d = double.tryParse(v.trim());
    return d != null && d.isFinite && d != 0;
  }

  Future<Position?> _freshPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return null;
      }
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
      } catch (e) {
        log("GPS high accuracy failed: $e");
      }
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (e) {
        log("GPS medium accuracy failed: $e");
      }
      if (!kIsWeb) {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null &&
            DateTime.now().difference(last.timestamp).inMinutes <=
                _lastKnownMaxAgeMins) {
          log("Using last known position (${last.timestamp})");
          return last;
        }
      }
    } catch (e) {
      log("freshPosition error: $e");
    }
    return null;
  }

  /// [lat, lng] (valid mattum) illana null
  Future<List<String>?> _resolveLatLng() async {
    final p = await _freshPosition();
    if (p == null) return null;
    final la = p.latitude.toString();
    final lo = p.longitude.toString();
    if (!_validCoord(la) || !_validCoord(lo)) return null;
    return [la, lo];
  }

  void startTracking(BuildContext context,String lat,String lng){
    showDialog(context: context,
        barrierDismissible: false,
        builder: ( context){
          return AlertDialog(
            title: Center(
              child: Column(
                children: [
                  CustomText(text: 'Do you want',colors: Colors.black,size:16,isBold:true),
                  10.height,
                  const CustomText(text: 'track your travel?',colors: Colors.black,size:16,isBold:true)
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomBtn(width: 70,text: 'NO',
                    callback: (){
                      setState(() {
                        localData.storage.write("Track",false);
                        Navigator.of(context, rootNavigator: true).pop();
                      });
                    },
                    bgColor: colorsConst.litGrey,textColor: Colors.black, ),
                  CustomBtn(width: 70,text: 'YES',
                    callback: ()  {
                      showDialog(context: context,
                          barrierDismissible: false,
                          builder: ( context){
                            return AlertDialog(
                              title: Center(
                                child: Column(
                                  children: [
                                    const CustomText(text: 'Do not close the app or',colors: Colors.black,size:16,isBold:true),
                                    10.height,
                                    const CustomText(text: 'turn off the location.',colors: Colors.black,size:16,isBold:true)
                                  ],
                                ),
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    CustomBtn(width: 70,text: 'OK',
                                      callback: () async {
                                        await _startTracking();
                                        if (!mounted) return;
                                        setState(() {
                                          Provider.of<CustomerProvider>(context, listen: false).actionTracking(context,"1");
                                        });
                                        Provider.of<CustomerProvider>(context, listen: false).trackingInsert(localData.storage.read("TrackId").toString(),true,lat,lng);
                                        Navigator.of(context, rootNavigator: true).pop();
                                        Navigator.of(context, rootNavigator: true).pop();
                                      },
                                      bgColor: colorsConst.primary,textColor: Colors.white, )
                                  ],
                                )
                              ],
                            );
                          }
                      );
                    },
                    bgColor: colorsConst.primary,textColor: Colors.white, ),
                ],
              )
            ],
          );});
  }
  void stopTracking(BuildContext context){
    showDialog(context: context,
        barrierDismissible: false,
        builder: ( context){
          return AlertDialog(
            title: Center(
              child: Column(
                children: [
                  const CustomText(text: 'Do you want',colors: Colors.black,size:16,isBold:true),
                  10.height,
                  const CustomText(text: 'track off?',colors: Colors.black,size:16,isBold:true)
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomBtn(width: 70,text: 'NO',
                    callback: (){
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    bgColor: colorsConst.litGrey,textColor: Colors.black, ),
                  CustomBtn(width: 70,text: 'YES',
                    callback: _stopTracking,
                    bgColor: colorsConst.primary,textColor: Colors.white, ),
                ],
              )
            ],
          );});
  }

  /// ✅ FIX: use localData.storage everywhere (was using a separate/unnamed
  /// GetStorage() instance before, so "Track" written here was never seen
  /// by the rest of the app that reads localData.storage.read("Track")).
  Future<void> _startTracking() async {
    await _checkBatteryOptimization();

    /// ✅ Update values using the SAME storage instance as the rest of the app
    await localData.storage.write("Track", true);
    await localData.storage.write("TrackId", localData.storage.read("TrackId") ?? "0");
    await localData.storage.write("TrackUnitName", localData.storage.read("TrackUnitName") ?? "null");
    await localData.storage.write("TrackStatus", "1");

    /// ✅ Delay to allow value flush
    await Future.delayed(const Duration(milliseconds: 500));

    /// ✅ Start the foreground task
    final isRunning = await FlutterForegroundTask.isRunningService;

    if (!isRunning) {
      await FlutterForegroundTask.startService(
        notificationTitle: constValue.appName,
        notificationText: 'Tracking is on',
        callback: startCallbackDispatcher,
      );
    }

    if (!mounted) return;
    setState(() {
      log("✅ Tracking started. Track=${localData.storage.read("Track")}, Unit=${localData.storage.read("TrackUnitName")}");
    });
  }

  /// ✅ FIX: capture + await the API insert BEFORE clearing locationList,
  /// so data isn't lost/cleared before it reaches the backend.
  Future<void> _stopTracking() async {
    await FlutterForegroundTask.stopService();

    if (trackCtr.locationList.isNotEmpty) {
      final listToSend = List.from(trackCtr.locationList); // snapshot first

      await Provider.of<CustomerProvider>(context, listen: false)
          .insertTrackList(listToSend);

      trackCtr.locationList.clear();
    }



    await localData.storage.write("Track", false);

    if (!mounted) return;

    Provider.of<CustomerProvider>(context, listen: false).actionTracking(context, "2");

    setState(() {});

    Navigator.of(context, rootNavigator: true).pop();
    utils.showSuccessToast(context: context, text: "Tracking stopped");
  }

  Future<void> _checkBatteryOptimization() async {
    if (Platform.isAndroid) {
      bool isIgnored = await FlutterForegroundTask.isIgnoringBatteryOptimizations;
      if (!isIgnored) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: CustomText(text: "Battery Optimization",colors: colorsConst.primary,isBold: true,),
            content: CustomText(text: "Please disable battery optimization for background tracking.",colors: colorsConst.greyClr),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: CustomText(text: "Don't Allow",colors: colorsConst.appRed,isBold: true,),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await FlutterForegroundTask.requestIgnoreBatteryOptimization();
                },
                child: CustomText(isBold: true,text: "Allow",colors: colorsConst.blueClr,),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Consumer4<AttendanceProvider,LocationProvider,HomeProvider,LeaveProvider>(
        builder: (context,attProvider,locPvr,homeProvider,leaveProvider,_){
          var split =attProvider.permissionStatus.toString().split(",");
          String lastPermissionStatus = "";
          bool isPermissionActive = lastPermissionStatus == "1";
          /// ✅ MULTI CHECK-IN: check out aanaalum grey/disable illa.
          /// Ippo check-in-la irundha -> red (Check Out), illana -> green (Check In)
          Color getAttendanceColor() {
            if (isPermissionActive) return Colors.red;
            return attProvider.isCheckedIn ? Colors.red : Colors.green;
          }
          if (attProvider.permissionStatus.isNotEmpty) {
            lastPermissionStatus =
                attProvider.permissionStatus.split(",").last;
          }


          print("permissionStatus  ${attProvider.permissionStatus}");
          print("isPermissionActive ${isPermissionActive}");

          /// ✅ NEW: Aswin build -> swipe attendance + auto selfie (no verify checkbox)
          final bool isAswin =
          constValue.appName.toString().toLowerCase().contains("aswin");

          /// ✅ NEW: Common attendance / permission-out handler.
          /// [forceSelfie] = true  -> always open the selfie camera first (Aswin swipe)
          /// [forceSelfie] = false -> old behaviour (selfie only if verify checkbox ticked)
          Future<void> markAttendance({required bool forceSelfie}) async {
            // ✅ tap pannum bodhu FRESH GPS edukkurom.
            // Munnadi locPvr.latitude (app open aana bodhu oru dhadava mattum
            // edutha value) anuppichu -> stale / empty / "null" location store aachu.
            final coords = await _resolveLatLng();
            if (!context.mounted) return;
            if (coords == null) {
              utils.showWarningToast(
                context,
                text: "Unable to get your location. Turn on GPS, move to an open area and try again.",
              );
              return;
            }
            final String lat = coords[0];
            final String lng = coords[1];

            String isOnLeaveValue = homeProvider.mainReportList.isEmpty
                ? "0"
                : homeProvider.mainReportList[0]["is_on_leave"].toString() == "null"
                ? "0"
                : homeProvider.mainReportList[0]["is_on_leave"].toString();

            bool isOnLeave = isOnLeaveValue == "1";
            print("isOnLeaveValue${isOnLeaveValue}");

            await leaveProvider.refreshMyTodayLeave(context);
            if (!context.mounted) return;

            // Leave data load aanaa adha use pannu. Load aagala na (offline)
            // old flag fallback, aana check-out ku eppovum allow.
            final bool blocked = attProvider.leaveChecked
                ? attProvider.attendanceBlockedByLeave
                : (isOnLeaveValue == "1" && !attProvider.isCheckedIn);

            if (blocked) {
              utils.showWarningToast(
                context,
                text: "You are on leave today. Attendance cannot be marked.",
              );
              return;
            }

            final bool needSelfie = forceSelfie || attProvider.isSelfie == true;

            if (attProvider.permissionStatus == "1") {
              // Permission OUT
              if (!needSelfie) {
                await attProvider.putDailyPermission(
                  context,
                  "2",
                  lat,
                  lng,
                );
              } else {
                await attProvider.signDialog(
                  context: context,
                  img: attProvider.profile,
                  onTap: (newImg) {
                    attProvider.profilePick(newImg);
                    attProvider.putDailyPermission(
                      context,
                      "2",
                      lat,
                      lng,
                    );
                  },
                );
              }
            } else {
              // Attendance IN / OUT
              // type is calculated ONCE at tap time, so it can't
              // change if provider state updates later.
              // ✅ MULTI CHECK-IN: kadaisi action vechu (out aana thirumba "1")
              final String type = attProvider.nextAttendanceStatus;

              if (!needSelfie) {
                await attProvider.putDailyAttendance(
                  context,
                  type,
                  lat,
                  lng,
                );
              } else {
                await attProvider.signDialog(
                  context: context,
                  img: attProvider.profile,
                  onTap: (newImg) {
                    attProvider.profilePick(newImg);
                    attProvider.putDailyAttendance(
                      context,
                      type,
                      lat,
                      lng,
                    );
                  },
                );
              }
            }
          }

          /// ✅ NEW: tap -> udane loader, mudinjadhum (success / error / cancel) normal
          Future<void> onAttendTap({required bool forceSelfie}) async {
            if (_btnLoading) return; // double tap block
            setState(() => _btnLoading = true);
            try {
              await markAttendance(forceSelfie: forceSelfie);
            } catch (e) {
              log("markAttendance error: $e");
            } finally {
              if (mounted) setState(() => _btnLoading = false);
            }
          }

          /// ✅ NEW: button label + colour shared by normal button & swipe button
          /// ✅ MULTI CHECK-IN: "Attendance Marked" + disable REMOVE.
          /// Check out pannitaa thirumba "Check In" kaattum.
          final String attendBtnText = attProvider.permissionStatus == "1"
              ? constValue.perOut
              : attProvider.isCheckedIn
              ? constValue.attendOut
              : constValue.attendIn;

          final Color attendBtnColor = attProvider.permissionStatus == "1"
              ? Colors.red
              : getAttendanceColor();

          /// ✅ button keezha chinna status line (simple text, "Session" word illa)
          ///   check-in-la irundha  -> "Checked in at 03:10 PM"
          ///   check-out aana       -> "Checked out at 05:30 PM · Worked 6h 20m"
          String sessionInfo() {
            if (attProvider.sessionCount == 0) return "";

            if (attProvider.isCheckedIn) {
              final t = attProvider.currentInTime;
              return t.isEmpty ? "" : constValue.checkedInAt(t);
            }

            final out = attProvider.outTime;
            if (out.isEmpty || out == "-") return "";

            // Provider format "6 : 20 mins" -> "6h 20m"
            String worked = "";

            final m = RegExp(r'(\d+)\s*:\s*(\d+)')
                .firstMatch(attProvider.totalHrs);

            if (m != null) {
              final h = int.parse(m.group(1)!);
              final mi = int.parse(m.group(2)!);

              worked = constValue.workedHours(h, mi);
            }

            return "${constValue.checkedOutAt(out)}$worked";
          }
          final String statusLine = sessionInfo();

          return
            // attProvider.attCheck==false?const Loading():
            Column(
              children: [
                Container(
                  decoration: customDecoration.baseBackgroundDecoration(
                      color: Colors.white,radius: 10
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: screenWidth/2.2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // ✅ MULTI CHECK-IN: eppovum kaattu (re-check-in ku verify/selfie venum)
                                  Row(
                                    children: [
                                      /// ✅ CHANGED: verify checkbox hidden for Aswin
                                      if(!isAswin) ...[
                                        GestureDetector(
                                          onTap: () {
                                            attProvider.manageSelfie();
                                          },
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: attProvider.isSelfie ? Color(0xffD9D9D9) :Color(0xffD9D9D9),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: Color(0xffD9D9D9), width: 1.2),
                                            ),
                                            child: attProvider.isSelfie
                                                ? Icon(
                                              Icons.check,
                                              size: 14,
                                              color: colorsConst.primary,
                                            )
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        CustomText(
                                          //text:  "verify",
                                          text:  "${constValue.verify}",

                                          shrink: true,
                                          size: 11,
                                          colors: Colors.blue,isBold: true,
                                        ),
                                        3.width,
                                      ],
                                      GestureDetector(
                                        onTap: attProvider.permissionStatus != "1"
                                            ? () {
                                          if (attProvider.mainCheckOut == true) {
                                            // check out aana nilai-la permission illa
                                            utils.showWarningToast(context,
                                                text: "Please check in to add permission.");
                                          } else {
                                            if (split.last == "2") {
                                              attProvider.permissionReason.clear();
                                            }

                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  actions: [
                                                    Center(
                                                      child: SizedBox(
                                                        width: kIsWeb
                                                            ? MediaQuery.of(context).size.width * 0.3
                                                            : MediaQuery.of(context).size.width * 0.8,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Center(
                                                              child: CustomText(
                                                                text: "${constValue.permission}\n",
                                                                colors: Colors.black,
                                                                size: 15,
                                                                isBold: true,
                                                              ),
                                                            ),
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    CustomText(
                                                                        text: "Reason",
                                                                        colors: colorsConst.greyClr),
                                                                    CustomText(
                                                                        text: "*",
                                                                        colors: colorsConst.appRed,
                                                                        size: 20),
                                                                  ],
                                                                ),
                                                                5.height,
                                                                TextField(
                                                                  textCapitalization:
                                                                  TextCapitalization.sentences,
                                                                  minLines: 1,
                                                                  maxLines: null,
                                                                  controller: attProvider.permissionReason,
                                                                  textInputAction: TextInputAction.done,
                                                                  decoration: InputDecoration(
                                                                    hintText: "",
                                                                    fillColor: Colors.white,
                                                                    filled: true,
                                                                    enabledBorder: OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          color: Colors.grey.shade300),
                                                                      borderRadius: BorderRadius.circular(10),
                                                                    ),
                                                                    focusedBorder: OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          color: colorsConst.primary),
                                                                      borderRadius: BorderRadius.circular(10),
                                                                    ),
                                                                    contentPadding: const EdgeInsets.fromLTRB(
                                                                        10, 10, 10, 10),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            20.height,

                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              children: [
                                                                OutlinedButton(
                                                                  onPressed: () {
                                                                    attProvider.permissionReason.clear();
                                                                    Navigator.pop(context);
                                                                  },
                                                                  style: OutlinedButton.styleFrom(
                                                                    backgroundColor: Colors.grey.shade200,
                                                                    side:
                                                                    const BorderSide(color: Colors.white),
                                                                  ),
                                                                  child: CustomText(
                                                                    text: "Cancel",
                                                                    colors: colorsConst.secondary,
                                                                    size: 15,
                                                                    isBold: true,
                                                                  ),
                                                                ),
                                                                OutlinedButton(
                                                                  onPressed: () async {
                                                                    if (attProvider.permissionReason.text
                                                                        .trim()
                                                                        .isNotEmpty) {
                                                                      Map<Permission, PermissionStatus>
                                                                      status = await [
                                                                        Permission.location,
                                                                      ].request();

                                                                      if (status[Permission.location] ==
                                                                          PermissionStatus.granted) {
                                                                        bool isLocationServiceEnabled =
                                                                        await Geolocator
                                                                            .isLocationServiceEnabled();

                                                                        if (!isLocationServiceEnabled) {
                                                                          utils.showWarningToast(context,
                                                                              text:
                                                                              "Location services are disabled. Please enable them.");
                                                                        } else {
                                                                          // ✅ permission-kum fresh GPS
                                                                          final coords = await _resolveLatLng();
                                                                          if (!context.mounted) return;
                                                                          if (coords == null) {
                                                                            utils.showWarningToast(
                                                                                text: "Check Your Location",
                                                                                context);
                                                                            await locPvr.manageLocation(
                                                                                context, true);
                                                                          } else {
                                                                            final String pLat = coords[0];
                                                                            final String pLng = coords[1];
                                                                            if (attProvider.isSelfie == false) {
                                                                              attProvider.putDailyPermission(
                                                                                  context,
                                                                                  "1",
                                                                                  pLat,
                                                                                  pLng);
                                                                            } else {
                                                                              attProvider.signDialog(
                                                                                context: context,
                                                                                img: attProvider.profile,
                                                                                onTap: (newImg) {
                                                                                  attProvider
                                                                                      .profilePick(newImg);
                                                                                  attProvider.putDailyPermission(
                                                                                      context,
                                                                                      "1",
                                                                                      pLat,
                                                                                      pLng);
                                                                                },
                                                                              );
                                                                            }
                                                                          }
                                                                        }
                                                                      } else {
                                                                        await locPvr.manageLocation(
                                                                            context, true);
                                                                      }
                                                                    } else {
                                                                      utils.showWarningToast(context,
                                                                          text: "Please type a reason");
                                                                    }
                                                                  },
                                                                  style: OutlinedButton.styleFrom(
                                                                    backgroundColor: colorsConst.primary,
                                                                    side: BorderSide(
                                                                        color: colorsConst.primary),
                                                                  ),
                                                                  child: const CustomText(
                                                                    text: "Ok",
                                                                    colors: Colors.white,
                                                                    size: 15,
                                                                    isBold: true,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            40.height,
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        }
                                            : null,

                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: attProvider.permissionStatus != "1"
                                                ? Colors.green
                                                : Colors.grey.shade400,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.lock_clock,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 6),
                                              CustomText(
                                                text: "${constValue.permission}",
                                                size: 11,
                                                shrink: true,
                                                isBold: true,
                                                colors: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                    ],
                                  ),
                                ],
                              ),
                              20.height,

                              /// ✅ NEW: Aswin -> Swipe button (selfie opens automatically,
                              /// attendance is marked right after the selfie).
                              /// Everyone else -> existing button (unchanged behaviour).
                              isAswin
                                  ? SwipeAttendanceButton(
                                text: attendBtnText,
                                color: attendBtnColor,
                                enabled: true, // ✅ check out apram-um enable
                                loading: _btnLoading,
                                onSwipe: () {
                                  onAttendTap(forceSelfie: true);
                                },
                              )
                                  : Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: 35,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: attendBtnColor,
                                    // loading-la konjam light aagum (colour maaraadhu)
                                    disabledBackgroundColor: attendBtnColor.withOpacity(0.75),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),

                                  // ✅ FIX: Confirmation dialog + 2nd API call removed.
                                  // Before: putDailyAttendance was called once (selfie/direct),
                                  // then again after the empty "Confirmation" dialog.
                                  // 2nd call saw mainAttendance already = 1 -> sent "2" (check-out)
                                  // so check-in + check-out happened together.
                                  // Now: ONLY ONE API call per tap.
                                  // ✅ MULTI CHECK-IN: eppovum enable
                                  // ✅ loading-la tap disable (null)
                                  onPressed: _btnLoading
                                      ? null
                                      : () async {
                                    // (same flow as before: selfie only if verify is ticked)
                                    await onAttendTap(forceSelfie: false);
                                  },

                                  // ✅ tap pannadhum button-kulla chinna loader + "Please wait"
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 150),
                                    child: _btnLoading
                                        ? Row(
                                      key: const ValueKey("loading"),
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                        8.width,
                                        const CustomText(
                                          text: "Please wait...",
                                          size: 13,
                                          isBold: true,
                                          colors: Colors.white,
                                          shrink: true,
                                        ),
                                      ],
                                    )
                                        : CustomText(
                                      key: const ValueKey("text"),
                                      text: attendBtnText,
                                      size: 13,
                                      isBold: true,
                                      colors: Colors.white,
                                      shrink: true,
                                    ),
                                  ),
                                ),
                              ),
                              /// ✅ status (eg: "Checked in at 03:10 PM")
                              if (statusLine.isNotEmpty) ...[
                                4.height,
                                CustomText(
                                  text: statusLine,
                                  size: 10.5,
                                  shrink: true,
                                  colors: colorsConst.greyClr,
                                ),
                              ],
                            ],
                          ),
                        ),
                        localData.storage.read("role")=="1"?
                        Container(
                            height: 90,
                            width: screenWidth/2.5,
                            decoration: customDecoration.baseBackgroundDecoration(
                                color: Colors.white,radius: 10
                            ),
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      /// LEAVE APPLIED -> Tab 1 (Leave Created / Applied)
                                      GestureDetector(
                                        onTap: () {
                                          final leaveProvider = Provider.of<LeaveProvider>(context, listen: false);
                                          leaveProvider.changeIndex(2);
                                          leaveProvider.setViewLeaveTab(0);

                                          utils.navigatePage(
                                            context,
                                                () => const DashBoard(child: LeaveManagementDashboard()),
                                          );
                                        },
                                        child: Container(
                                          width: 150,
                                          height: 32,
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.red, width: 1),
                                          ),
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: CustomText(
                                                  text: "${constValue.leave_Applided}:",
                                                  size: 12,
                                                  colors: Colors.red.shade800,
                                                  isBold: true,
                                                  shrink: true,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              CustomText(
                                                text: homeProvider.mainReportList.isEmpty
                                                    ? ""
                                                    : homeProvider.mainReportList[0]["today_apply_leave"].toString(),
                                                size: 16,
                                                isBold: true,
                                                colors: Colors.red.shade900,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),

                                      /// ON LEAVE -> Tab 2 (Employees On Leave)
                                      GestureDetector(
                                        onTap: () {
                                          final leaveProvider = Provider.of<LeaveProvider>(context, listen: false);
                                          leaveProvider.changeIndex(2);
                                          leaveProvider.setViewLeaveTab(1);

                                          utils.navigatePage(
                                            context,
                                                () => const DashBoard(child: LeaveManagementDashboard()),
                                          );
                                        },
                                        child: Container(
                                          width: 150,
                                          height: 32,
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.green, width: 1),
                                          ),
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: CustomText(
                                                  text: "${constValue.on_Leave}:",
                                                  size: 12,
                                                  colors: Colors.green.shade800,
                                                  isBold: true,
                                                  shrink: true,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              CustomText(
                                                text: homeProvider.mainReportList.isEmpty
                                                    ? "0"
                                                    : "${int.parse(homeProvider.mainReportList[0]["fulldayleave_user"].toString() == "null" ? "0" : homeProvider.mainReportList[0]["fulldayleave_user"].toString()) + int.parse(homeProvider.mainReportList[0]["sessionleave_user"].toString() == "null" ? "0" : homeProvider.mainReportList[0]["sessionleave_user"].toString())}",
                                                size: 16,
                                                isBold: true,
                                                colors: Colors.black,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                        ): Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            if(localData.storage.read("role")!="1")
                              Column(
                                children: [

                                  CustomText(text: constValue.tapHereTo,colors: ColorsConst.textGrey,),
                                  CustomText(text: constValue.startTracking,colors: ColorsConst.textGrey,),
                                  15.height,
                                  GestureDetector(
                                    onTap: () async {
                                      if (localData.storage.read("Track") == true) {
                                        stopTracking(context);
                                      } else {
                                        Map<Permission, PermissionStatus> status = await [
                                          Permission.location,
                                          Permission.locationAlways,
                                        ].request();

                                        if (status[Permission.location] != PermissionStatus.granted) {
                                          utils.showWarningToast(
                                            context,
                                            text: "Location permission is required to start tracking.",
                                          );
                                          return;
                                        }

                                        if (locPvr.latitude=="" && locPvr.longitude==""){
                                          locPvr.manageLocation(context,true);
                                        } else {
                                          startTracking(context, locPvr.latitude, locPvr.longitude);
                                        }
                                      }
                                      setState(() {});
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      height: 30,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: localData.storage.read("Track") == true
                                            ? Colors.green
                                            : Colors.grey,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: CustomText(
                                              text: localData.storage.read("Track") == true
                                                  ? 'ON     '
                                                  : '     Tracker Off',
                                              size: 11, colors: Colors.white,
                                            ),
                                          ),
                                          Align(
                                            alignment: localData.storage.read("Track") ==
                                                true ? Alignment.centerRight : Alignment
                                                .centerLeft,
                                            child: Container(
                                              margin: const EdgeInsets.all(3),
                                              width: 25,
                                              height: 25,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                10.height,
                localData.storage.read("role")!="1"?
                LeaveSummaryCard(
                  allowed:" ${ homeProvider.mainReportList.isEmpty ?"0":homeProvider.
                  mainReportList[0]["emp_leave_allowed"].toString()=="null"?"0":
                  homeProvider.mainReportList[0]["emp_leave_allowed"].toString()}",
                  // is_on_leave
                  taken: " ${ homeProvider.mainReportList.isEmpty ?"0":homeProvider.
                  mainReportList[0]["emp_leave_taken"].toString()=="null"?"0":
                  homeProvider.mainReportList[0]["emp_leave_taken"].toString()}",
                ):SizedBox(),
              ],
            );
        });
  }
}


/// ✅ NEW: Custom swipe button used for Aswin build.
/// - Solid (slightly darker) track so the white text is always readable
/// - Big bold label (size 14), no chevrons / no clutter
/// - White round thumb with coloured icon (">>" double arrow by default, tick when swiped)
/// - Swipe >= 85% triggers [onSwipe], then the thumb resets automatically
class SwipeAttendanceButton extends StatefulWidget {
  final String text;
  final Color color;
  final bool enabled;
  final double height;
  final IconData icon;
  final VoidCallback onSwipe;
  /// ✅ NEW: true -> thumb-la chinna loader, swipe block
  final bool loading;

  const SwipeAttendanceButton({
    super.key,
    required this.text,
    required this.color,
    required this.onSwipe,
    this.enabled = true,
    this.loading = false,
    this.height = 40,
    this.icon = Icons.keyboard_double_arrow_right_rounded,
  });

  @override
  State<SwipeAttendanceButton> createState() => _SwipeAttendanceButtonState();
}

class _SwipeAttendanceButtonState extends State<SwipeAttendanceButton> {
  double _pos = 0;
  bool _dragging = false;
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    final double h = widget.height;
    const double pad = 4;
    final double thumb = h - pad * 2;

    // darker shade of the state colour -> white text has strong contrast
    final Color base = widget.enabled
        ? Color.lerp(widget.color, Colors.black, 0.18)!
        : Colors.grey.shade600;

    return LayoutBuilder(
      builder: (context, c) {
        final double w = c.maxWidth.isFinite
            ? c.maxWidth
            : MediaQuery.of(context).size.width * 0.45;
        final double maxDrag = (w - thumb - pad * 2).clamp(1.0, double.infinity);
        final double progress = (_pos / maxDrag).clamp(0.0, 1.0);
        final Duration anim =
        _dragging ? Duration.zero : const Duration(milliseconds: 250);
        final bool canDrag = widget.enabled && !_done && !widget.loading;

        return Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(h / 2),
            boxShadow: [
              BoxShadow(
                color: base.withOpacity(0.35),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              /// light fill that follows the thumb
              AnimatedContainer(
                duration: anim,
                width: _pos + thumb + pad * 2,
                height: h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(h / 2),
                ),
              ),

              /// label (big + bold + clearly visible)
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(left: thumb + pad * 2, right: 12),
                  child: Center(
                    child: Opacity(
                      opacity: (1 - progress * 1.3).clamp(0.0, 1.0),
                      child: Text(
                        widget.loading ? "Please wait..." : widget.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /// thumb
              AnimatedPositioned(
                duration: anim,
                curve: Curves.easeOut,
                left: pad + _pos,
                top: pad,
                child: GestureDetector(
                  onHorizontalDragStart: canDrag
                      ? (_) => setState(() => _dragging = true)
                      : null,
                  onHorizontalDragUpdate: canDrag
                      ? (d) => setState(() {
                    _pos = (_pos + d.delta.dx).clamp(0.0, maxDrag);
                  })
                      : null,
                  onHorizontalDragEnd: canDrag
                      ? (_) {
                    if (progress >= 0.85) {
                      setState(() {
                        _dragging = false;
                        _pos = maxDrag;
                        _done = true;
                      });
                      widget.onSwipe();
                      Future.delayed(const Duration(milliseconds: 700), () {
                        if (!mounted) return;
                        setState(() {
                          _pos = 0;
                          _done = false;
                        });
                      });
                    } else {
                      setState(() {
                        _dragging = false;
                        _pos = 0;
                      });
                    }
                  }
                      : null,
                  child: Container(
                    width: thumb,
                    height: thumb,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: widget.loading
                        ? Padding(
                      padding: EdgeInsets.all(thumb * 0.25),
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: base),
                    )
                        : Icon(
                      _done ? Icons.check_rounded : widget.icon,
                      color: base,
                      size: thumb * 0.72,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}