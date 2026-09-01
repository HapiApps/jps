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
import '../../source/constant/default_constant.dart';
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
  @override
  void initState() {
    Future.delayed(
        Duration.zero, () {
      if (!mounted) return;
      Provider.of<LocationProvider>(context, listen: false).manageLocation(context,false);
    });
    super.initState();
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
          Color getAttendanceColor() {
            if (isPermissionActive) return Colors.red;

            if (attProvider.mainCheckOut == true) return Colors.grey;

            return attProvider.mainAttendance == 0
                ? Colors.green
                : Colors.red;
          }
          if (attProvider.permissionStatus.isNotEmpty) {
            lastPermissionStatus =
                attProvider.permissionStatus.split(",").last;
          }


          print("permissionStatus  ${attProvider.permissionStatus}");
          print("isPermissionActive ${isPermissionActive}");
          return attProvider.attCheck==false?const Loading():
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
                                if(attProvider.mainCheckOut == false)
                                  Row(
                                    children: [
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
                                      const SizedBox(width: 6),
                                      const CustomText(
                                        text:  "Verify",
                                        size: 13,
                                        colors: Colors.blue,isBold: true,
                                      ),
                                      5.width,
                                      GestureDetector(
                                        onTap: attProvider.permissionStatus != "1"
                                            ? () {
                                          if (attProvider.mainCheckOut == true) {
                                            utils.showWarningToast(context,
                                                text: "Permission cannot be added after marking attendance.");
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
                                                                text: "Permission\n",
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
                                                                          if (locPvr.latitude == "" &&
                                                                              locPvr.longitude == "") {
                                                                            utils.showWarningToast(
                                                                                text: "Check Your Location",
                                                                                context);
                                                                            await locPvr.manageLocation(
                                                                                context, true);
                                                                          } else {
                                                                            if (attProvider.isSelfie == false) {
                                                                              attProvider.putDailyPermission(
                                                                                  context,
                                                                                  "1",
                                                                                  locPvr.latitude,
                                                                                  locPvr.longitude);
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
                                                                                      locPvr.latitude,
                                                                                      locPvr.longitude);
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
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 6),
                                              const CustomText(
                                                text: "Permission",
                                                size: 12,
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
                            Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: 35,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: attProvider.mainCheckOut
                                      ? Colors.grey
                                      : attProvider.permissionStatus == "1"
                                      ? Colors.red
                                      : getAttendanceColor(),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),

                                onPressed: attProvider.mainCheckOut
                                    ? null
                                    : () async {

                                  if (locPvr.latitude == null ||
                                      locPvr.longitude == null) {
                                    utils.showWarningToast(
                                      context,
                                      text:
                                      "Location not available. Please enable GPS and try again.",
                                    );
                                    return;
                                  }

                                  final leaveProvider =
                                  Provider.of<LeaveProvider>(
                                    context,
                                    listen: false,
                                  );

                                  String isOnLeaveValue = homeProvider.mainReportList.isEmpty
                                      ? "0"
                                      : homeProvider.mainReportList[0]["is_on_leave"].toString() == "null"
                                      ? "0"
                                      : homeProvider.mainReportList[0]["is_on_leave"].toString();

                                  bool isOnLeave = isOnLeaveValue == "1";
                                  print("isOnLeaveValue${isOnLeaveValue}");
                                  if (isOnLeave) {
                                    utils.showWarningToast(
                                      context,
                                      text:
                                      "You are on leave today. Attendance cannot be marked.",
                                    );
                                    return;
                                  }

                                  String message = "";

                                  if (attProvider.permissionStatus == "1") {
                                    message =
                                    "Do you want to mark Permission Out?";
                                  } else {
                                    if (attProvider.mainAttendance == 0) {
                                      message =
                                      "Do you want to mark Attendance In?";
                                    } else {
                                      message =
                                      "Do you want to mark Attendance Out?";
                                    }
                                  }

                                  bool? confirm =
                                  await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Confirmation"),
                                      content: Text(message),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(
                                                  context, false),
                                          child: const Text("No"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(
                                                  context, true),
                                          child: const Text("Yes"),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm != true) return;

                                  if (attProvider.permissionStatus ==
                                      "1") {
                                    attProvider.putDailyPermission(
                                      context,
                                      "2",
                                      locPvr.latitude,
                                      locPvr.longitude,
                                    );
                                  }

                                  else {
                                    attProvider.putDailyAttendance(
                                      context,
                                      attProvider.mainAttendance == 0
                                          ? "1"
                                          : "2",
                                      locPvr.latitude,
                                      locPvr.longitude,
                                    );
                                  }
                                },

                                child: Text(
                                  attProvider.mainCheckOut
                                      ? "Attendance Marked"
                                      : attProvider.permissionStatus == "1"
                                      ? "Permission Out"
                                      : attProvider.mainAttendance == 0
                                      ? "Attendance In"
                                      : "Attendance Out",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
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
                                    onTap: (){
                                      final leaveProvider = Provider.of<LeaveProvider>(context, listen: false);
                                      leaveProvider.changeIndex(2);
                                      leaveProvider.setViewLeaveTab(0);   // 👈 Tab 1

                                      utils.navigatePage(
                                          context,
                                              ()=>const DashBoard(child: LeaveManagementDashboard())
                                      );
                                    },
                                    child: Container(
                                      width: 130,
                                      height: 30,
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.red, width: 1),
                                      ),
                                      child: Row(
                                        children: [
                                          CustomText(
                                            text: "Leave Applied: ",
                                            size: 12,
                                            colors: Colors.red.shade800,
                                            isBold: true,
                                          ),
                                          const SizedBox(height: 6),
                                          CustomText(
                                            text: homeProvider.mainReportList.isEmpty?"":homeProvider.mainReportList[0]["today_apply_leave"].toString(),
                                            size: 16,
                                            isBold: true,
                                            colors: Colors.red.shade900,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height:5),

                                  /// ON LEAVE -> Tab 2 (Employees On Leave)
                                  GestureDetector(
                                    onTap: (){
                                      final leaveProvider = Provider.of<LeaveProvider>(context, listen: false);
                                      leaveProvider.changeIndex(2);
                                      leaveProvider.setViewLeaveTab(1);   // 👈 Tab 2

                                      utils.navigatePage(
                                          context,
                                              ()=>const DashBoard(child: LeaveManagementDashboard())
                                      );
                                    },
                                    child: Container(
                                      width: 130,  height: 30,
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.green, width: 1),
                                      ),
                                      child: Row(
                                        children: [
                                          CustomText(
                                            text: "On Leave : ",
                                            size: 12,
                                            colors: Colors.green.shade800,
                                            isBold: true,
                                          ),
                                          CustomText(
                                            text:  homeProvider.mainReportList.isEmpty?"0":"${int.parse(
                                                homeProvider.mainReportList[0]["fulldayleave_user"].toString()=="null"?"0":
                                                homeProvider.mainReportList[0]["fulldayleave_user"].toString())+int.parse(
                                                homeProvider.mainReportList[0]["sessionleave_user"].toString() =="null"?"0":
                                                homeProvider.mainReportList[0]["sessionleave_user"].toString())}",
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

                                CustomText(text: "Tap Here to",colors: ColorsConst.textGrey,),
                                CustomText(text: "Start Tracking",colors: ColorsConst.textGrey,),
                                15.height,
                                GestureDetector(
                                  onTap: () async {
                                    /// ✅ FIX: request background location permission
                                    /// before starting tracking, so it keeps working
                                    /// after the app is minimized.
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