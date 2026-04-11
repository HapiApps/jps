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
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/local_data.dart';
import '../../source/utilities/utils.dart';
import '../../component/custom_text.dart';
import '../../view_model/leave_provider.dart';
import '../../view_model/location_provider.dart';
import 'package:provider/provider.dart';
import 'package:master_code/view_model/home_provider.dart';

import '../common/dashboard.dart';
import '../leave_management/leave_dashboard.dart';
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
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Consumer3<AttendanceProvider,LocationProvider,HomeProvider>(
        builder: (context,attProvider,locPvr,homeProvider,_){
      var split =attProvider.permissionStatus.toString().split(",");
      String lastPermissionStatus = "";
      bool isPermissionActive = lastPermissionStatus == "1";
      Color getAttendanceColor() {
        if (isPermissionActive) return colorsConst.appRed;

        if (attProvider.mainCheckOut == true) return Colors.grey;

        return attProvider.mainAttendance == 0
            ? colorsConst.appGreen
            : colorsConst.appRed;
      }
      if (attProvider.permissionStatus.isNotEmpty) {
        lastPermissionStatus =
            attProvider.permissionStatus.split(",").last;
      }


      print("permissionStatus  ${attProvider.permissionStatus}");
      print("isPermissionActive ${isPermissionActive}");
      return attProvider.attCheck==false?const Loading():
      Container(
        decoration: customDecoration.baseBackgroundDecoration(
          // borderColor: Colors.red,

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
                                            ? Colors.green // ✅ Permission Not Active
                                            : Colors.grey.shade400, // ✅ Permission Active
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
                    // attProvider.isPermission==true?
                    // SwipeButton(
                    //   width: MediaQuery.of(context).size.width*0.9,
                    //   height: 35,
                    //   thumb: Padding(
                    //     padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    //     child: SvgPicture.asset(assets.arrow),
                    //   ),
                    //   activeThumbColor: attProvider.permissionStatus==""||split.last=="2"?colorsConst.appGreen:colorsConst.appRed,
                    //   // activeTrackColor: attProvider.permissionStatus==""||split.last=="2"?colorsConst.appGreen.withOpacity(0.2):colorsConst.appRed.withOpacity(0.3),
                    //   activeTrackColor: Colors.white,
                    //   onSwipe: () async {
                    //     Map<Permission, PermissionStatus> status = await [
                    //       Permission.location,
                    //     ].request();
                    //     if (status[Permission.location] == PermissionStatus.granted) {
                    //       bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
                    //       if (!isLocationServiceEnabled) {
                    //         utils.showWarningToast(context, text: "Location services are disabled. Please enable them.");
                    //       }else{
                    //         if(locPvr.latitude==""&&locPvr.longitude==""){
                    //           utils.showWarningToast(text:"Check Your Location",context);
                    //           await locPvr.manageLocation(context,true);
                    //         }else{
                    //           if(attProvider.isSelfie==false){
                    //             attProvider.putDailyPermission(context,attProvider.permissionStatus==""||split.last=="2"?"1":"2",locPvr.latitude,locPvr.longitude);
                    //           }else{
                    //             attProvider.signDialog(context: context,
                    //               img: attProvider.profile,
                    //               onTap:(newImg){
                    //                 attProvider.profilePick(newImg);
                    //                 attProvider.putDailyPermission(context,attProvider.permissionStatus==""||split.last=="2"?"1":"2",locPvr.latitude,locPvr.longitude);
                    //               },
                    //             );
                    //           }
                    //         }
                    //       }
                    //     }
                    //     else{
                    //       await locPvr.manageLocation(context,true);
                    //     }
                    //   },
                    //   child: CustomText(text: attProvider.permissionStatus==""||split.last=="2"?
                    //   "     Permission In"
                    //       :"     Permission Out",
                    //     colors: attProvider.permissionStatus==""||split.last=="2"?colorsConst.appGreen:colorsConst.appRed,size: 15,),
                    // )
                    // :SwipeButton(
                    //   //width: attProvider.mainCheckOut == true?MediaQuery.of(context).size.width*0.9:MediaQuery.of(context).size.width*0.55,
                    //   width: MediaQuery.of(context).size.width*0.9,
                    //   height: 35,
                    //   thumb: Padding(
                    //     padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    //     child: SvgPicture.asset(assets.arrow),
                    //   ),
                    //   activeThumbColor: attProvider.mainAttendance!=0&&attProvider.mainCheckOut == true?Color(0xff7E7E7E):attProvider.mainAttendance!=0&&attProvider.mainCheckOut == false?colorsConst.appRed:colorsConst.appGreen,
                    //   //activeTrackColor: attProvider.mainAttendance!=0&&attProvider.mainCheckOut == true?Colors.grey.shade300:attProvider.mainAttendance!=0&&attProvider.mainCheckOut == false?colorsConst.appRed.withOpacity(0.2):colorsConst.litGrey.withOpacity(0.3),
                    //   activeTrackColor: Colors.white,
                    //   onSwipe: attProvider.mainCheckOut==true?null:() async {
                    //     if(!kIsWeb){
                    //       Map<Permission, PermissionStatus> status = await [
                    //         Permission.location,
                    //       ].request();
                    //       if (status[Permission.location] == PermissionStatus.granted) {
                    //         // print("in 2");
                    //         bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
                    //         if (!isLocationServiceEnabled) {
                    //           utils.showWarningToast(context, text: "Location services are disabled. Please enable them.");
                    //         }else if(attProvider.mainCheckOut==true){
                    //           // print("in 3");
                    //           utils.showWarningToast(text:"Attendance marked",context);
                    //         }else{
                    //           // print("in 4");
                    //           if(locPvr.latitude==""&&locPvr.longitude==""){
                    //             // print("in 5");
                    //             utils.showWarningToast(text:"Check Your Location",context);
                    //             await locPvr.manageLocation(context,true);
                    //           }else{
                    //             // print("in 6");
                    //             if(attProvider.isSelfie==false){
                    //               attProvider.putDailyAttendance(context,attProvider.mainAttendance==0?"1":"2",locPvr.latitude,locPvr.longitude);
                    //             }else{
                    //               attProvider.signDialog(context: context,
                    //                 img: attProvider.profile,
                    //                 onTap:(newImg){
                    //                   attProvider.profilePick(newImg);
                    //                   attProvider.putDailyAttendance(context,attProvider.mainAttendance==0?"1":"2",locPvr.latitude,locPvr.longitude);
                    //                 },
                    //               );
                    //             }
                    //           }
                    //         }
                    //       }else{
                    //         // print("in");
                    //         await locPvr.manageLocation(context,true);
                    //       }
                    //     }else{
                    //       // print("in 1");
                    //       if(attProvider.mainCheckOut==true){
                    //         // print("in 3");
                    //         utils.showWarningToast(text:"Attendance marked",context);
                    //       }else{
                    //         // print("in 4");
                    //         if(locPvr.latitude==""&&locPvr.longitude==""){
                    //           // print("in 5");
                    //           utils.showWarningToast(text:"Check Your Location",context);
                    //           await locPvr.manageLocation(context,true);
                    //         }else{
                    //           // print("in 6");
                    //           attProvider.signDialog(context: context,
                    //             img: attProvider.profile,
                    //             onTap:(newImg){
                    //               attProvider.profilePick(newImg);
                    //               attProvider.putDailyAttendance(context,attProvider.mainAttendance==0?"1":"2",locPvr.latitude,locPvr.longitude);
                    //             },
                    //           );
                    //         }
                    //       }
                    //     }
                    //   },
                    //   child: CustomText(text: attProvider.mainAttendance==0?
                    //   "Attendance In"
                    //       :attProvider.mainCheckOut == true?
                    //   "            Attendance Marked"
                    //       :"        Attendance Out",colors: attProvider.mainAttendance==0?colorsConst.appGreen
                    //       :attProvider.mainCheckOut == true?Colors.grey:colorsConst.appRed,size: 13,),
                    // ),
            // isPermissionActive
            //     ? SwipeButton(
            //   width: MediaQuery.of(context).size.width * 0.9,
            //   height: 35,
            //   thumb: Padding(
            //     padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            //     child: SvgPicture.asset(assets.arrow),
            //   ),
            //   activeThumbColor: colorsConst.appRed,
            //   activeTrackColor: Colors.white,
            //   onSwipe: () async {
            //     attProvider.putDailyPermission(
            //         context,
            //         "2",
            //         locPvr.latitude,
            //         locPvr.longitude);
            //   },
            //   child: const CustomText(
            //     text: "Permission Out",
            //     colors: Colors.red,
            //     size: 15,
            //   ),
            // )
            //     : SwipeButton(
            //   width: MediaQuery.of(context).size.width * 0.9,
            //   height: 35,
            //   thumb: Padding(
            //     padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            //     child: SvgPicture.asset(assets.arrow),
            //   ),
            //   activeThumbColor: attProvider.mainAttendance == 0
            //       ? colorsConst.appGreen
            //       : colorsConst.appRed,
            //   activeTrackColor: Colors.white,
            //   onSwipe: () async {
            //     attProvider.putDailyAttendance(
            //         context,
            //         attProvider.mainAttendance == 0 ? "1" : "2",
            //         locPvr.latitude,
            //         locPvr.longitude);
            //   },
            //   child: CustomText(
            //     text: attProvider.mainAttendance == 0
            //         ? "Attendance In"
            //         : attProvider.mainCheckOut == true?
            //          "  Attendance Marked"
            //         :"Attendance Out",
            //     colors: attProvider.mainAttendance == 0
            //         ? colorsConst.appGreen
            //         : colorsConst.appRed,
            //     size: 13,
            //   ),
            // ),

                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),

                        // ✅ Border Color same as status
                        border: Border.all(
                          color: getAttendanceColor(),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: isPermissionActive
                            ? SwipeButton(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 35,
                          thumb: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: SvgPicture.asset(assets.arrow),
                          ),
                          activeThumbColor: colorsConst.appRed,
                          activeTrackColor: Colors.white,
                          onSwipe: () async {
                            attProvider.putDailyPermission(
                              context,
                              "2",
                              locPvr.latitude,
                              locPvr.longitude,
                            );
                          },
                          child: CustomText(
                            text: "Permission Out",
                            colors: colorsConst.appRed,
                            size: 15,
                          ),
                        )
                            : SwipeButton(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 35,
                          thumb: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: SvgPicture.asset(assets.arrow),
                          ),

                          // ✅ Thumb color
                          activeThumbColor: getAttendanceColor(),
                          activeTrackColor: Colors.white,

                          // ✅ Disable swipe when marked
                          onSwipe: attProvider.mainCheckOut == true
                              ? null
                              : () async {
                            attProvider.putDailyAttendance(
                              context,
                              attProvider.mainAttendance == 0 ? "1" : "2",
                              locPvr.latitude,
                              locPvr.longitude,
                            );
                          },

                          child: CustomText(
                            text: attProvider.mainAttendance == 0
                                ? "Attendance In"
                                : attProvider.mainCheckOut == true
                                ? "              Attendance Marked"
                                : "    Attendance Out",

                            // ✅ Text color
                            colors: getAttendanceColor(),
                            size: 13,
                          ),
                        ),
                      ),
                    )

                  ],
                ),
              ),
              if(localData.storage.read("role")=="1")
              InkWell(
                onTap:(){
                  // homeProvider.updateIndex(4);
                  // utils.navigatePage(context, ()=> DashBoard(child: AttendanceReport(type: homeProvider.type,showType: "Present",date1: homeProvider.startDate,date2:homeProvider.endDate,empList: [])));
                  Provider.of<LeaveProvider>(context, listen: false).changeIndex(2);

                  utils.navigatePage(
                      context,
                          ()=>const DashBoard(child: LeaveManagementDashboard())
                  );
                },
                child: Container(
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


                        /// ✅ Leave Count + Leave Applied Count Box
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// 🟢 Leave Count

                            Container(
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
                                  // CustomText(
                                  //   text: attProvider.leaveAppliedCount == null
                                  //       ? "0"
                                  //       : attProvider.leaveAppliedCount.toString(),
                                  //   size: 16,
                                  //   isBold: true,
                                  //   colors: Colors.red.shade900,
                                  // ),
                                  CustomText(

                                      text: homeProvider.mainReportList[0]["today_apply_leave"].toString(),

                                    size: 16,
                                    isBold: true,
                                    colors: Colors.red.shade900,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height:5),
                            Container(
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

                                  // CustomText(
                                  //   text: attProvider.leaveCount == null
                                  //       ? "0"
                                  //       : attProvider.leaveCount.toString(),
                                  //   size: 16,
                                  //   isBold: true,
                                  //   colors: Colors.green.shade900,
                                  // ),
                                  CustomText(
                                    text: homeProvider.mainReportList[0]["fulldayleave_user"].toString(),
                                    size: 16,
                                    isBold: true,
                                    colors: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                            /// 🔴 Leave Applied Count

                          ],
                        ),
                      ],
                    ),
                  )
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}