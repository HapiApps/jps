import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:master_code/component/custom_loading_button.dart';
import 'package:master_code/screens/common/dashboard.dart';
import 'package:master_code/screens/customer/visit_report/visits_report.dart';
import 'package:master_code/screens/common/view_notification.dart';
import 'package:master_code/screens/report_dashboard/report_dashboard.dart';
import 'package:master_code/screens/work_report/view_work_report.dart';
import 'package:master_code/source/constant/default_constant.dart';
import 'package:master_code/view_model/location_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:master_code/component/custom_text.dart';
import 'package:master_code/source/constant/assets_constant.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/constant/local_data.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/styles/decoration.dart';
import '../../component/animated_button.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/update_app.dart';
import '../../source/constant/api.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/attendance_provider.dart';
import '../../view_model/customer_provider.dart';
import '../../view_model/employee_provider.dart';
import '../../view_model/home_provider.dart';
import '../attendance/attendance_report.dart';
import '../attendance/custom_attendance.dart';
import '../controller/track_controller.dart';
import 'package:http/http.dart' as http;
import '../customer/visit/add_visit.dart';
import '../expense/view_expense.dart';
import '../leave_management/leave_report.dart';
import '../project_report/view_project_report.dart';
import '../task/view_task.dart';
import '../track/live_location.dart';
import '../track/tracking_report.dart';

@pragma('vm:entry-point')
void startCallbackDispatcher() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class DashHomePage extends StatefulWidget {
  const DashHomePage({super.key});

  @override
  State<DashHomePage> createState() => _DashHomePageState();
}

class _DashHomePageState extends State<DashHomePage>  with TickerProviderStateMixin {
  Timer? _timer;
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      Provider.of<LocationProvider>(context, listen: false).requestNotificationPermissions();
      Provider.of<AttendanceProvider>(context, listen: false).getTotalHours(Provider.of<HomeProvider>(context, listen: false).startDate,Provider.of<HomeProvider>(context, listen: false).endDate);
      // if (localData.storage.read("refreshHomeData") == true) {
      //   homeProvider.getMainReport(true);
      //   homeProvider.getDashboardReport(true);
      //   // print("***** Check");
      //   localData.storage.write("refreshHomeData", false);
      // }
      homeProvider.updateToken(context);
      FirebaseFirestore.instance
          .collection('attendance')
          .snapshots()
          .listen((snapshot) {
        // When any new attendance record is added/updated
        final homeProvider = Provider.of<HomeProvider>(context, listen: false);
        homeProvider.checkThisMonth();
        homeProvider.getMainReport(false);
        homeProvider.getDashboardReport(false);
        Provider.of<AttendanceProvider>(context, listen: false).getLateCount(Provider.of<HomeProvider>(context, listen: false).startDate,Provider.of<HomeProvider>(context, listen: false).endDate,);
      });
      Provider.of<AttendanceProvider>(context, listen: false).getLateCount(Provider.of<HomeProvider>(context, listen: false).startDate,Provider.of<HomeProvider>(context, listen: false).endDate,);
      Provider.of<EmployeeProvider>(context, listen: false).getAllUsers();
      Provider.of<CustomerProvider>(context, listen: false).getAllCustomers(true);
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
                  const CustomText(text: 'Do you want',colors: Colors.black,size:16,isBold: true,),
                  10.height,
                  const CustomText(text: 'track your travel?',colors: Colors.black,size:16,isBold: true,)
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
                                    const CustomText(text: 'Do not close the app or',colors: Colors.black,size:16,isBold: true,),
                                    10.height,
                                    const CustomText(text: 'turn off the location.',colors: Colors.black,size:16,isBold: true,)
                                  ],
                                ),
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    CustomBtn(width: 70,text: 'OK',
                                      callback: (){
                                        setState(() {
                                          _startTracking();
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
                  const CustomText(text: 'Do you want',colors: Colors.black,size:16,isBold: true,),
                  10.height,
                  const CustomText(text: 'track off?',colors: Colors.black,size:16,isBold: true,)
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
  Future<void> _checkBatteryOptimization() async {
    if (Platform.isAndroid) {
      bool isIgnored = await FlutterForegroundTask.isIgnoringBatteryOptimizations;
      if (!isIgnored) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: CustomText(text:"Battery Optimization",colors: colorsConst.primary,isBold: true,),
            content: CustomText(text:"Please disable battery optimization for background tracking.",colors: colorsConst.greyClr),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: CustomText(text:"Don't Allow",colors: colorsConst.appRed,isBold: true),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await FlutterForegroundTask.requestIgnoreBatteryOptimization();
                },
                child: CustomText(text:"Allow",colors: colorsConst.blueClr,isBold: true,),
              ),
            ],
          ),
        );
      }
    }
  }
  Future<void> _startTracking() async {
    log("📍 Starting tracking...");

    await _checkBatteryOptimization();

    final storage = GetStorage();

    /// ✅ Update values
    await storage.write("Track", true);
    await storage.write("TrackId", localData.storage.read("TrackId") ?? "0");
    await storage.write("TrackUnitName", localData.storage.read("TrackUnitName") ?? "null");
    await storage.write("TrackStatus", "1");

    /// ✅ Delay to allow value flush
    await Future.delayed(const Duration(milliseconds: 500));

    /// ✅ Start the foreground task
    await FlutterForegroundTask.startService(
      notificationTitle: constValue.appName,
      notificationText: 'Tracking is on',
      callback: startCallbackDispatcher,
    );

    setState(() {
      log("✅ Tracking started. Track=${storage.read("Track")}, Unit=${storage.read("TrackUnitName")}");
    });
  }
  Future<void> _stopTracking() async {
    await FlutterForegroundTask.stopService();
    setState(() {
      localData.storage.write("Track",false);
      if (trackCtr.locationList.isNotEmpty) {
        Provider.of<CustomerProvider>(context, listen: false).insertTrackList(trackCtr.locationList);
        trackCtr.locationList.clear();
        // print("Balance list added list cleared.");
      }
      Provider.of<CustomerProvider>(context, listen: false).actionTracking(context,"2");
      // if(trackCtr.todayTrackReport.isEmpty){
      //   /// New Changes
      //   localData.storage.write("TrackId","0");
      //   localData.storage.write("TrackStatus","2");
      //   localData.storage.write("T_Shift","");
      //   localData.storage.write("TrackUnitName","null");
      // }
      Navigator.of(context, rootNavigator: true).pop();
      utils.showSuccessToast(context: context,text: "Tracking stopped");
    });
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.95;
    return Consumer5<HomeProvider,CustomerProvider,AttendanceProvider,LocationProvider,EmployeeProvider>(builder: (context,homeProvider,custProvider,attPvr,locPvr,empPvr,_){
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('attendance').snapshots(),
        builder: (context, snapshot) {
          // if (!snapshot.hasData) {
          //   return CircularProgressIndicator();
          // }
          // final count = snapshot.data!.docs.length;
          return Center(
            child: SizedBox(
              width: kIsWeb?webWidth:phoneWidth,
              child: SafeArea(
                child: Scaffold(
                  backgroundColor: colorsConst.bacColor,
                  appBar: const PreferredSize(
                    preferredSize: Size(300, 50),
                    child: CustomAppbar(text: "Dashboard",isMain: true,),
                  ),
                  body: PopScope(
                      canPop: false,
                      onPopInvoked: (bool pop){
                        return utils.customDialog(
                            context: context,
                            callback: (){
                              SystemNavigator.pop();}, title: "Do you want to Exit the App?");
                      },
                      child: homeProvider.versionCheck==false
                          ?const Center(child: Loading())
                          :homeProvider.currentVersion!=""&&homeProvider.versionCheck==true&&
                          homeProvider.versionActive==false?
                      const UpdateApp()
                          :homeProvider.refresh==false||homeProvider.vRefresh==false?
                      const Loading():
                      homeProvider.mainReportList.isNotEmpty&&homeProvider.mainReportList[0]["active"]!="1"
                          ?const Center(child: CustomText(text: "Invalid",colors: Colors.red,isBold:true,size: 20,))
                          :NotificationListener<OverscrollIndicatorNotification>(
                        onNotification: (overscroll) {
                          overscroll.disallowIndicator();
                          return true;
                        },
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            Center(child: CustomText(text: "${greeting()} ${localData.storage.read("f_name")}",colors: colorsConst.primary,isBold: true,size: 15,)),
                            5.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset(assets.calendar,width: 13,height: 13,),5.width,
                                    CustomText(text: homeProvider.date)
                                  ],
                                ),
                                // 10.width,
                                // Row(
                                //   children: [
                                //     SvgPicture.asset(assets.clock,width: 14,height: 14,),5.width,
                                //     CustomText(text: homeProvider.time)
                                //   ],
                                // ),
                              ],
                            ),
                            10.height,
                            if(!kIsWeb)
                              homeProvider.versionCheck==false
                                  ?const Center(child: Loading())
                                  :homeProvider.currentVersion!=""&&homeProvider.versionCheck==true&&
                                  homeProvider.versionActive==false?
                              0.height
                                  :const CheckAttendance(),
                            10.height,
                            localData.storage.read("role")=="1"?
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          homeProvider.datePick(
                                            context: context,
                                            date: homeProvider.startDate,
                                            isStartDate: true, function: () {
                                            // homeProvider.roleEmployees();
                                            homeProvider.getMainReport(true);
                                            homeProvider.getDashboardReport(true);
                                            attPvr.getLateCount(attPvr.startDate,attPvr.endDate);
                                          },
                                          );
                                        },
                                        child: Container(
                                          height: 30,
                                          width: kIsWeb?MediaQuery.of(context).size.width*0.15:MediaQuery.of(context).size.width * 0.24,
                                          decoration: customDecoration.baseBackgroundDecoration(
                                            color: Colors.white,
                                            radius: 5,
                                            borderColor: colorsConst.litGrey,
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              CustomText(text: homeProvider.startDate,size: 12,),
                                              5.width,
                                              SvgPicture.asset(assets.calendar2),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 30,
                                        width: kIsWeb?MediaQuery.of(context).size.width*0.17:MediaQuery.of(context).size.width * 0.33,
                                        decoration: customDecoration.baseBackgroundDecoration(
                                          radius: 5,
                                          color: Colors.white,
                                          borderColor: colorsConst.litGrey,
                                        ),
                                        child: DropdownButton(
                                          iconEnabledColor: colorsConst.greyClr,
                                          isExpanded: true,
                                          underline: const SizedBox(),
                                          icon: const Icon(Icons.keyboard_arrow_down_outlined),
                                          value: homeProvider.type,
                                          onChanged: (value) {
                                            homeProvider.changeType(context,value);
                                          },
                                          items: homeProvider.typeList.map((list) {
                                            return DropdownMenuItem(
                                              value: list,
                                              child: CustomText(
                                                text: "  $list",
                                                colors: Colors.black,
                                                isBold: false,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          homeProvider.showCustomMonthPicker(
                                            context: context,
                                            function: (){
                                              // homeProvider.roleEmployees();
                                              homeProvider.getMainReport(true);
                                              homeProvider.getDashboardReport(true);
                                              attPvr.getLateCount(attPvr.startDate,attPvr.endDate);
                                            },
                                          );
                                        },
                                        child: Container(
                                          height: 30,
                                          width: kIsWeb?MediaQuery.of(context).size.width*0.15:MediaQuery.of(context).size.width * 0.25,
                                          decoration: customDecoration.baseBackgroundDecoration(
                                            color: Colors.white,
                                            radius: 5,
                                            borderColor: colorsConst.litGrey,
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              CustomText(text: homeProvider.month,size: 12,),
                                              5.width,
                                              SvgPicture.asset(assets.calendar2),
                                            ],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(onTap: (){
                                        homeProvider.getMainReport(true);
                                        homeProvider.getDashboardReport(true);
                                        attPvr.getLateCount(attPvr.startDate,attPvr.endDate);
                                      }, child: Icon(Icons.refresh,color: Colors.red,))
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: (){
                                    homeProvider.updateIndex(4);
                                    utils.navigatePage(context, ()=> DashBoard(child: AttendanceReport(type: homeProvider.type,showType: "0",date1: homeProvider.startDate,date2:homeProvider.endDate,empList: empPvr.userData)));
                                  },
                                  child: Container(
                                    decoration: customDecoration.baseBackgroundDecoration(
                                        color: Colors.white,radius: 20,isShadow: true,shadowColor: Colors.grey.shade300
                                    ),
                                    height: 90,
                                    child: homeProvider.refresh==true&&homeProvider.mainReportList.isNotEmpty?
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const CustomText(text: "Attendance Status",isBold: true,),
                                              // CustomText(text: "30/35",
                                              //   size: 15,),
                                              Row(
                                                children: [
                                                  CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["unique_attendance_count"].toString(),size: 15,colors: colorsConst.appGreen,isBold: true,),
                                                  CustomText(text: " / ${homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["total_user_count"].toString()}",size: 15,isBold: true),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Expanded(
                                        //   child: ListView.builder(
                                        //       shrinkWrap: true,
                                        //       physics: const NeverScrollableScrollPhysics(),
                                        //       scrollDirection: Axis.horizontal,
                                        //       // itemCount: homeProvider.roleEmp.length,
                                        //       itemCount: homeProvider.roleEmp.length,
                                        //       itemBuilder: (context,index){
                                        //         return Padding(
                                        //           padding: const EdgeInsets.all(8.0),
                                        //           child: GestureDetector(
                                        //             onTap: (){
                                        //               homeProvider.updateIndex(1);
                                        //               utils.navigatePage(context, ()=>const DashBoard(child: ViewEmployees()));
                                        //             },
                                        //             child: Container(
                                        //               decoration: customDecoration.baseBackgroundDecoration(
                                        //                   color: Colors.grey.shade100,radius: 5
                                        //               ),width: 70,
                                        //               // color: Colors.yellow,
                                        //               child: Column(
                                        //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        //                 children: [
                                        //                   CustomText(text: "${homeProvider.roleEmp[index]["role_name"]}",size: 12,),
                                        //                   CustomText(text: homeProvider.roleEmp[index]["employee_count"],isBold: true,),
                                        //                 ],
                                        //               ),
                                        //             ),
                                        //           ),
                                        //         );
                                        //       }),
                                        // ),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            // shrinkWrap: true,
                                            // physics: const NeverScrollableScrollPhysics(),
                                            // scrollDirection: Axis.horizontal,
                                            // itemCount: homeProvider.roleEmp.length,
                                            children: [
                                              GestureDetector(
                                                onTap: (){
                                                  if(homeProvider.mainReportList.isNotEmpty&&homeProvider.mainReportList[0]["unique_attendance_count"].toString()!="0"){
                                                    homeProvider.updateIndex(4);
                                                    utils.navigatePage(context, ()=> DashBoard(child: AttendanceReport(type: homeProvider.type,showType: "0",date1: homeProvider.startDate,date2:homeProvider.endDate,empList: empPvr.userData)));
                                                  }else{
                                                    utils.showWarningToast(context, text: "No present employees found");
                                                  }
                                                },
                                                child: Container(
                                                  decoration: customDecoration.baseBackgroundDecoration(
                                                      color: Colors.grey.shade100,radius: 5
                                                  ),width: 70,
                                                  // color: Colors.yellow,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      CustomText(text: "Present",size: 12,),
                                                      CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["unique_attendance_count"].toString(),isBold: true,),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: (){
                                                  if(homeProvider.mainReportList.isNotEmpty&&
                                                      (int.parse(homeProvider.mainReportList[0]["total_user_count"].toString())-
                                                          int.parse(homeProvider.mainReportList[0]["unique_attendance_count"].toString())
                                                          -int.parse(homeProvider.mainReportList[0]["fulldayleave_user"].toString())).toString()!="0"){
                                                    homeProvider.updateIndex(4);
                                                    utils.navigatePage(context, ()=> DashBoard(child: AttendanceReport(type: homeProvider.type,showType: "Absent",date1: homeProvider.startDate,date2:homeProvider.endDate,empList: empPvr.userData)));
                                                  }else{
                                                    utils.showWarningToast(context, text: "No absent employees found");
                                                  }
                                                },
                                                child: Container(
                                                  decoration: customDecoration.baseBackgroundDecoration(
                                                      color: Colors.grey.shade100,radius: 5
                                                  ),width: 70,
                                                  // color: Colors.yellow,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      CustomText(text: "Absent",size: 12,),
                                                      // CustomText(text: "${homeProvider.mainReportList.isEmpty?"0"
                                                      //     :(int.parse(homeProvider.mainReportList[0]["total_user_count"].toString())-
                                                      //     int.parse(homeProvider.mainReportList[0]["unique_attendance_count"].toString())-int.parse(homeProvider.mainReportList[0]["fulldayleave_user"].toString()))}",isBold: true,),
                                                      CustomText(
                                                        text: homeProvider.mainReportList.isEmpty
                                                            ? "0"
                                                            : (() {
                                                          final total = int.parse(homeProvider.mainReportList[0]["total_user_count"].toString());
                                                          final attend = int.parse(homeProvider.mainReportList[0]["unique_attendance_count"].toString());
                                                          final leave = int.parse(homeProvider.mainReportList[0]["fulldayleave_user"].toString());
                                                          final result = total - attend - leave;
                                                          return result < 0 ? "0" : result.toString();
                                                        })(),
                                                        isBold: true,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: (){
                                                  if(homeProvider.mainReportList.isNotEmpty&&(homeProvider.mainReportList[0]["fulldayleave_user"].toString()!="0"||homeProvider.mainReportList[0]["sessionleave_user"].toString()!="0")){
                                                    // homeProvider.updateIndex(11);
                                                    // utils.navigatePage(context, ()=> DashBoard(child: ViewMyLeaves(date1:homeProvider.startDate,date2:homeProvider.endDate,isDirect: true)));
                                                    homeProvider.updateIndex(4);
                                                    utils.navigatePage(context, ()=> DashBoard(child: AttendanceReport(type: homeProvider.type,showType: "On Leave",date1: homeProvider.startDate,date2:homeProvider.endDate,empList: empPvr.userData)));
                                                  }else{
                                                    utils.showWarningToast(context, text: "No on leave employee found");
                                                  }
                                                },
                                                child: Container(
                                                  decoration: customDecoration.baseBackgroundDecoration(
                                                      color: Colors.grey.shade100,radius: 5
                                                  ),width: 70,
                                                  // color: Colors.yellow,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      CustomText(text: "On Leave",size: 12,),
                                                      CustomText(text: homeProvider.mainReportList.isEmpty?"0":"${int.parse(homeProvider.mainReportList[0]["fulldayleave_user"].toString())+int.parse(homeProvider.mainReportList[0]["sessionleave_user"].toString())}",isBold: true,),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: (){
                                                  if(attPvr.lateCount!=0){
                                                    homeProvider.updateIndex(4);
                                                    utils.navigatePage(context, ()=> DashBoard(child: AttendanceReport(type: homeProvider.type,showType: "Late",date1: homeProvider.startDate,date2:homeProvider.endDate,empList: empPvr.userData)));
                                                  }else{
                                                    utils.showWarningToast(context, text: "No late employees found");
                                                  }
                                                },
                                                child: Container(
                                                  decoration: customDecoration.baseBackgroundDecoration(
                                                      color: Colors.grey.shade100,radius: 5
                                                  ),width: 70,
                                                  // color: Colors.yellow,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      CustomText(text: "Late",size: 12,),
                                                      CustomText(text: "${attPvr.lateCount}",isBold: true,),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),5.height
                                      ],
                                    ):homeProvider.roleEmp.isEmpty?
                                    const Center(child: CustomText(text: "\nNo Employees Found\n"))
                                        :const SkeletonLoading(),
                                  ),
                                ),10.height,
                                5.height,
                                InkWell(
                                  onTap: (){
                                    // Provider.of<EmployeeProvider>(context, listen: false).sendUserNotification(
                                    //   "A new task has been assigned to .",
                                    //   "dfghj",
                                    //   localData.storage.read("id"),
                                    // );
                                    utils.navigatePage(context, ()=> DashBoard(child: VisitReport(date1: homeProvider.startDate, date2: homeProvider.endDate,month: homeProvider.month,type: homeProvider.type)));
                                  },
                                  child: Container(
                                    // height: homeProvider.visitCount.length <= 2
                                    //     ? 60
                                    //     : (homeProvider.visitCount.length / 2).ceil() * 36 + 45,
                                      height:170,
                                      decoration: customDecoration.baseBackgroundDecoration(
                                          color: colorsConst.adm2,radius: 20
                                      ),
                                      // height: homeProvider.visitCount.length*30,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const CustomText(text: "Visits",isBold: true),
                                                Row(
                                                  children: [
                                                    // CustomText(text: "10"),
                                                    CustomText(text: homeProvider.totalV.toString()),
                                                    GestureDetector(
                                                      onTap: (){
                                                        utils.navigatePage(context, ()=> DashBoard(child:
                                                        CusAddVisit(taskId:"",companyId: "",companyName: "",
                                                            numberList: [],isDirect: true, type: "", desc: "")));
                                                      },
                                                      child: SizedBox(
                                                          height: 25,width: 25,
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            children: [
                                                              CustomText(text: "+",size: 22,),
                                                            ],
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: homeProvider.vRefresh==false?
                                            const SkeletonLoading():homeProvider.visitCount.isEmpty?
                                            const Center(child: CustomText(text: "No Visits Found\n")):
                                            Padding(
                                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                                              child: GridView.builder(
                                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 2,
                                                    crossAxisSpacing: 2,
                                                    mainAxisSpacing: 2,
                                                    mainAxisExtent: 36,
                                                  ),
                                                  itemCount: homeProvider.visitCount.length,
                                                  shrinkWrap: true,
                                                  // physics: const NeverScrollableScrollPhysics(),
                                                  itemBuilder: (context,index){
                                                    return  Padding(
                                                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            // color: Colors.pink,
                                                              width: kIsWeb?MediaQuery.of(context).size.width*0.15:MediaQuery.of(context).size.width*0.32,
                                                              child: CustomText(text: homeProvider.visitCount[index]["value"].toString().trim(),)),
                                                          // CustomText(text: (index+1).toString()),
                                                          CustomText(text: homeProvider.visitCount[index]["total_count"].toString().trim(),),
                                                          5.height,
                                                        ],
                                                      ),
                                                    );
                                                  }
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                ),
                                5.height,
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //   children: [
                                //     Row(
                                //       children: [
                                //         CustomText(text: "Leave",isBold: true,colors: colorsConst.greyClr),10.width,
                                //         CustomText(text: homeProvider.mainReportList.isEmpty?"0":"${(int.parse(homeProvider.mainReportList[0]["total_user_count"].toString())-(int.parse(homeProvider.mainReportList[0]["unique_attendance_count"].toString())))}"),
                                //       ],
                                //     ),
                                //     Row(
                                //       children: [
                                //         CustomText(text: "Late",isBold: true,colors: colorsConst.greyClr,),10.width,
                                //         CustomText(text: "0"),
                                //       ],
                                //     ),
                                //   ],
                                // ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: (){
                                            homeProvider.updateIndex(10);
                                            utils.navigatePage(context, ()=> DashBoard(child: ViewTask(date1: homeProvider.startDate, date2: homeProvider.endDate, type: homeProvider.type)));
                                          },
                                          child: Container(
                                            decoration: customDecoration.baseBackgroundDecoration(
                                                color: colorsConst.adm3,radius: 10
                                            ),
                                            width: kIsWeb?webWidth/2:phoneWidth/2,
                                            child: Column(
                                              children: [
                                                // Padding(
                                                //   padding: const EdgeInsets.all(8.0),
                                                //   child: Row(
                                                //     mainAxisAlignment: kIsWeb?MainAxisAlignment.start:homeProvider.mainReportList.isNotEmpty&&homeProvider.mainReportList[0]["total_tasks"]!="0"?MainAxisAlignment.spaceEvenly:MainAxisAlignment.center,
                                                //     children: [
                                                //       if(homeProvider.mainReportList.isNotEmpty&&homeProvider.mainReportList[0]["total_tasks"]!="0")
                                                //         const SizedBox(
                                                //             width: 50,
                                                //             height: 50,
                                                //             // color: Colors.blue,
                                                //             child: PieChartDash()),
                                                //       // if(kIsWeb&&homeProvider.mainReportList.isNotEmpty&&homeProvider.mainReportList[0]["total_tasks"]!="0")
                                                //       // 15.width,
                                                //       CustomText(text: kIsWeb?"Task Status":homeProvider.mainReportList.isNotEmpty&&homeProvider.mainReportList[0]["total_tasks"]!="0"?"Task Status":"Task Status",isBold: true,),
                                                //     ],
                                                //   ),
                                                // ),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [5.height,
                                                          CustomText(text: localData.storage.read("role")=="1"?"Tasks":"Assigned",isBold: true,),10.height,
                                                          CustomText(text: localData.storage.read("role")=="1"?"Pending":"New Task\nAssigned"),10.height,
                                                          const CustomText(text: "Completed"),5.height,
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [5.height,
                                                          CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["total_tasks"],isBold: true),10.height,
                                                          CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["incomplete_count"],),10.height,
                                                          CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["complete_count"],),5.height,
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            5.height,
                                            if(localData.storage.read("role")=="1")
                                              CustomLoadingButton(
                                                height: 35,isBold: false,
                                                callback: (){
                                                  homeProvider.updateIndex(3);
                                                  utils.navigatePage(context, ()=>const DashBoard(child: TrackingLive()));
                                                }, isLoading: false,text: "Live Tracking",
                                                textColor: Colors.black,
                                                backgroundColor: colorsConst.buto1, radius: 10,
                                                width: kIsWeb?webWidth/2:phoneWidth/2,),5.height,
                                            CustomLoadingButton(
                                              height: 35,isBold: false,
                                              callback: (){
                                                // homeProvider.updateIndex(5);
                                                // utils.navigatePage(context, ()=>const DashBoard(child: ReportDashboard()));

                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return Consumer<HomeProvider>(
                                                      builder: (context, homeProvider, _) {
                                                        return AlertDialog(
                                                          actions: [
                                                            SizedBox(
                                                              width: kIsWeb?MediaQuery.of(context).size.width*0.3:MediaQuery.of(context).size.width*0.9,
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                    children: [
                                                                      IconButton(
                                                                        icon:SvgPicture.asset(assets.cancel),
                                                                        onPressed: (){
                                                                          Navigator.pop(context);
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Center(child: CustomText(text: "Choose a report",isBold:true)),
                                                                  20.height,
                                                                  iconBox(
                                                                      callBack: (){
                                                                        homeProvider.updateIndex(4);
                                                                        utils.navigatePage(context, ()=> DashBoard(child: AttendanceReport(type: homeProvider.type,showType: "0",date1: homeProvider.startDate,date2:homeProvider.endDate,empList: empPvr.userData)));
                                                                      },img: assets.aTt,text: "Attendance Report"
                                                                  ),
                                                                  20.height,
                                                                  iconBox(
                                                                      callBack: (){
                                                                        homeProvider.updateIndex(5);
                                                                        utils.navigatePage(context, ()=>const DashBoard(child: ReportDashboard()));
                                                                      },img: assets.aTask,text: "Task Report"
                                                                  ),
                                                                  20.height,
                                                                  iconBox(
                                                                      callBack: (){
                                                                        homeProvider.updateIndex(16);
                                                                        utils.navigatePage(context, ()=>const DashBoard(child: ViewWorkReport()));
                                                                      },img: assets.aRep,text: "Work Report"
                                                                  ),
                                                                  20.height,
                                                                  iconBox(
                                                                      callBack: (){
                                                                        homeProvider.updateIndex(15);
                                                                        utils.navigatePage(context, ()=>const DashBoard(child: ViewProjectReport()));
                                                                      },img: assets.aPrj,text: "Project Report"
                                                                  ),20.height,
                                                                  iconBox(
                                                                      callBack: (){
                                                                        utils.navigatePage(context, ()=> DashBoard(child: VisitReport(date1: homeProvider.startDate, date2: homeProvider.endDate,month: homeProvider.month,type: homeProvider.type)));
                                                                      },img: assets.aLoc,text: "Visit Report"
                                                                  ),20.height,
                                                                  iconBox(
                                                                      callBack: (){
                                                                        homeProvider.updateIndex(3);
                                                                        utils.navigatePage(context, ()=>const DashBoard(child: CorrectionReport()));
                                                                      },img: assets.aLoc2,text: "Tracking Report"
                                                                  ),
                                                                  20.height,
                                                                  Center(
                                                                    child: TextButton(
                                                                      child:CustomText(text: "Cancel",colors: colorsConst.appRed,),
                                                                      onPressed: (){
                                                                        Navigator.pop(context);
                                                                      },
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                );

                                              }, isLoading: false,text: "Reports",
                                              textColor: Colors.black,
                                              backgroundColor: colorsConst.buto2, radius: 10,
                                              width: kIsWeb?webWidth/2:phoneWidth/2,),5.height,
                                            CustomLoadingButton(
                                              height: 35,isBold: false,
                                              callback: (){
                                                utils.navigatePage(context, ()=>const DashBoard(child: ViewNotification()));
                                                // Provider.of<EmployeeProvider>(context, listen: false).sendUserNotification(
                                                //     "Your Expenses Rejected",
                                                //     "Task ",localData.storage.read("id"));
                                              }, isLoading: false,text: "Notifications",
                                              textColor: Colors.black,
                                              backgroundColor: colorsConst.pendingRep, radius: 10,
                                              width: kIsWeb?webWidth/2:phoneWidth/2,),5.height,
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: (){
                                            homeProvider.updateIndex(10);
                                            utils.navigatePage(context, ()=> DashBoard(child: ViewTask(date1: homeProvider.startDate, date2: homeProvider.endDate, type: homeProvider.type)));
                                          },
                                          child: Container(
                                            decoration: customDecoration.baseBackgroundDecoration(
                                                color: colorsConst.adm4,radius: 10
                                            ),
                                            height: 130,
                                            width: kIsWeb?webWidth/2.2:phoneWidth/2.2,
                                            child: Center(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [5.height,
                                                  const CustomText(text: "Task Waiting for action",isBold: true),
                                                  Container(
                                                    color: colorsConst.litBlu,
                                                    height: 40,
                                                    width: kIsWeb?webWidth/2.5:phoneWidth/2.5,
                                                    child: Center(
                                                      child: Padding(
                                                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            const CustomText(text: "Expenses Approval",size: 12.5,),
                                                            CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["pending_expense_report_count"]),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),5.height,
                                                  Container(
                                                    color: colorsConst.litBlu,
                                                    height: 40,
                                                    width: kIsWeb?webWidth/2.5:phoneWidth/2.5,
                                                    child: Center(
                                                      child: Padding(
                                                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            const CustomText(text: "Visit Reports",size: 12.5),
                                                            CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["pending_visit_count"]),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  5.height,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        10.height,
                                        GestureDetector(
                                          onTap: (){
                                            homeProvider.updateIndex(9);
                                            utils.navigatePage(context, ()=> DashBoard(child: ViewExpense(tab:false,date1: homeProvider.startDate, date2: homeProvider.endDate,type: homeProvider.type)));
                                          },
                                          child: Container(
                                            decoration: customDecoration.baseBackgroundDecoration(
                                                color: colorsConst.adm5,radius: 10
                                            ),
                                            height: 110,
                                            width: kIsWeb?webWidth/2.2:phoneWidth/2.2,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: kIsWeb?webWidth/2.5:phoneWidth/2.5,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            const CustomText(text: "Expense Reports",isBold: true),5.height,
                                                            const CustomText(text: "Approved"),5.height,
                                                            const CustomText(text: "Inprocess"),5.height,
                                                            const CustomText(text: "Rejected"),
                                                          ],
                                                        ),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["total_expense_count"],isBold: true),5.height,
                                                            CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["approved_expense_count"]),5.height,
                                                            CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["pending_expense_count"]),5.height,
                                                            CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["rejected_expense_count"]),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ):
                            Column(
                              children: [
                                if(!kIsWeb)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (localData.storage.read("Track") == true) {
                                          stopTracking(context);
                                        } else {
                                          if(locPvr.latitude==""&&locPvr.longitude==""){
                                            locPvr.manageLocation(context,true);
                                          }else{
                                            startTracking(context,locPvr.latitude,locPvr.longitude);
                                          }
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(100, 0, 100, 0),
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
                                                    : '     Track Off',
                                                size: 11, colors: Colors.white,
                                              ),
                                            ),
                                            Align(
                                              alignment: localData.storage.read("Track") ==
                                                  true ? Alignment.centerRight : Alignment
                                                  .centerLeft,
                                              child: Container(
                                                margin: const EdgeInsets.all(3),
                                                width: 22,
                                                height: 22,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),),10.height,
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        homeProvider.datePick(
                                          context: context,
                                          date: homeProvider.startDate,
                                          isStartDate: true, function: () {
                                          homeProvider.getMainReport(true);
                                          homeProvider.getDashboardReport(true);
                                          Provider.of<AttendanceProvider>(context, listen: false).getTotalHours(homeProvider.startDate,homeProvider.endDate);
                                        },
                                        );
                                      },
                                      child: Container(
                                        height: 30,
                                        width: kIsWeb?MediaQuery.of(context).size.width*0.15:MediaQuery.of(context).size.width * 0.24,
                                        decoration: customDecoration.baseBackgroundDecoration(
                                          color: Colors.white,
                                          radius: 5,
                                          borderColor: colorsConst.litGrey,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CustomText(text: homeProvider.startDate,size: 12,),
                                            5.width,
                                            SvgPicture.asset(assets.calendar2),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 30,
                                      width: kIsWeb?MediaQuery.of(context).size.width*0.17:MediaQuery.of(context).size.width * 0.33,
                                      decoration: customDecoration.baseBackgroundDecoration(
                                        radius: 5,
                                        color: Colors.white,
                                        borderColor: colorsConst.litGrey,
                                      ),
                                      child: DropdownButton(
                                        iconEnabledColor: colorsConst.greyClr,
                                        isExpanded: true,
                                        underline: const SizedBox(),
                                        icon: const Icon(Icons.keyboard_arrow_down_outlined),
                                        value: homeProvider.type,
                                        onChanged: (value) {
                                          homeProvider.changeType(context,value);
                                        },
                                        items: homeProvider.typeList.map((list) {
                                          return DropdownMenuItem(
                                            value: list,
                                            child: CustomText(
                                              text: "  $list",
                                              colors: Colors.black,
                                              isBold: false,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        homeProvider.showCustomMonthPicker(
                                          context: context,
                                          function: (){
                                            homeProvider.getMainReport(true);
                                            homeProvider.getDashboardReport(true);
                                            Provider.of<AttendanceProvider>(context, listen: false).getTotalHours(homeProvider.startDate,homeProvider.endDate);
                                          },
                                        );
                                      },
                                      child: Container(
                                        height: 30,
                                        width: kIsWeb?MediaQuery.of(context).size.width*0.15:MediaQuery.of(context).size.width * 0.25,
                                        decoration: customDecoration.baseBackgroundDecoration(
                                          color: Colors.white,
                                          radius: 5,
                                          borderColor: colorsConst.litGrey,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CustomText(text: homeProvider.month,size: 12,),
                                            5.width,
                                            SvgPicture.asset(assets.calendar2),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),10.height,
                                GestureDetector(
                                  onTap: (){
                                    homeProvider.updateIndex(4);
                                    utils.navigatePage(context, ()=> DashBoard(child: AttendanceReport(type: homeProvider.type,showType: "0",date1: homeProvider.startDate,date2:homeProvider.endDate,empList: empPvr.userData)));
                                  },
                                  child: Container(
                                    decoration: customDecoration.baseBackgroundDecoration(
                                        color: Colors.white,radius: homeProvider.type=="Today"||homeProvider.type=="Yesterday"?10:20,isShadow: true,shadowColor: Colors.grey.shade300
                                    ),
                                    height: homeProvider.type=="Today"||homeProvider.type=="Yesterday"?50:90,
                                    child: homeProvider.refresh==true&&homeProvider.mainReportList.isNotEmpty?
                                    homeProvider.type=="Today"||homeProvider.type=="Yesterday"?
                                    Center(
                                      child: CustomText(text: homeProvider.mainReportList.isEmpty?"-":
                                      homeProvider.mainReportList[0]["emp_present"].toString()=="1"&&isLate(attPvr.inTime)?"Late"
                                          :homeProvider.mainReportList[0]["emp_present"].toString()=="1"?"Present"
                                          :homeProvider.mainReportList[0]["emp_leave"].toString()!="0"?"Leave"
                                          :homeProvider.mainReportList[0]["emp_absent"].toString()=="1"?"Absent"
                                          :"",isBold: true,),
                                    ):
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const CustomText(text: "Status",isBold: true,),
                                              // CustomText(text: "30/35",
                                              //   size: 15,),
                                              // Row(
                                              //   children: [
                                              //     CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["unique_attendance_count"].toString(),size: 15,colors: colorsConst.appGreen,isBold: true,),
                                              //     CustomText(text: " / ${homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["total_user_count"].toString()}",size: 15,isBold: true),
                                              //   ],
                                              // ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              GestureDetector(
                                                onTap: (){
                                                  if(homeProvider.mainReportList.isNotEmpty&&homeProvider.mainReportList[0]["emp_present"].toString()!="0"){
                                                    homeProvider.updateIndex(4);
                                                    utils.navigatePage(context, ()=> DashBoard(child: AttendanceReport(type: homeProvider.type,showType: "0",date1: homeProvider.startDateM,date2: homeProvider.endDateM,empList: empPvr.userData)));
                                                  }else{
                                                    utils.showWarningToast(context, text: "No present employees found");
                                                  }
                                                },
                                                child: Container(
                                                  decoration: customDecoration.baseBackgroundDecoration(
                                                      color: Colors.grey.shade100,radius: 5
                                                  ),width: 70,
                                                  // color: Colors.yellow,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      CustomText(text: "Present",size: 12,),
                                                      CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["emp_present"].toString(),isBold: true,),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: (){
                                                  if(homeProvider.mainReportList.isNotEmpty&&homeProvider.mainReportList[0]["emp_absent"].toString()!="0"){
                                                    homeProvider.updateIndex(4);
                                                    utils.navigatePage(context, ()=> DashBoard(child: AttendanceReport(type: homeProvider.type,showType: "Absent",date1: homeProvider.startDateM,date2:homeProvider.endDateM,empList: empPvr.userData)));
                                                  }else{
                                                    utils.showWarningToast(context, text: "No absent employees found");
                                                  }
                                                },
                                                child: Container(
                                                  decoration: customDecoration.baseBackgroundDecoration(
                                                      color: Colors.grey.shade100,radius: 5
                                                  ),width: 70,
                                                  // color: Colors.yellow,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      CustomText(text: "Absent",size: 12,),
                                                      CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["emp_absent"].toString(),isBold: true,),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: (){
                                                  if(homeProvider.mainReportList.isNotEmpty&&homeProvider.mainReportList[0]["emp_leave"].toString()!="0"){
                                                    homeProvider.updateIndex(11);
                                                    utils.navigatePage(context, ()=> DashBoard(child: ViewMyLeaves(date1:homeProvider.startDateM,date2:homeProvider.endDateM,isDirect: true)));
                                                  }else{
                                                    utils.showWarningToast(context, text: "No on leave employee found");
                                                  }
                                                },
                                                child: Container(
                                                  decoration: customDecoration.baseBackgroundDecoration(
                                                      color: Colors.grey.shade100,radius: 5
                                                  ),width: 70,
                                                  // color: Colors.yellow,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      CustomText(text: "On Leave",size: 12,),
                                                      CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["emp_leave"].toString()=="0.0"?"0":homeProvider.mainReportList[0]["emp_leave"].toString(),isBold: true,),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: (){
                                                  if(homeProvider.mainReportList.isNotEmpty&&homeProvider.mainReportList[0]["emp_late"].toString()!="0"){
                                                    homeProvider.updateIndex(4);
                                                    utils.navigatePage(context, ()=> DashBoard(child: AttendanceReport(type: homeProvider.type,showType: "Late",date1: homeProvider.startDateM,date2:homeProvider.endDateM,empList: empPvr.userData)));
                                                  }else{
                                                    utils.showWarningToast(context, text: "No late employees found");
                                                  }
                                                },
                                                child: Container(
                                                  decoration: customDecoration.baseBackgroundDecoration(
                                                      color: Colors.grey.shade100,radius: 5
                                                  ),width: 70,
                                                  // color: Colors.yellow,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      CustomText(text: "Late",size: 12,),
                                                      CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["emp_late"].toString(),isBold: true,),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),5.height
                                      ],
                                    ):homeProvider.roleEmp.isEmpty?
                                    const Center(child: CustomText(text: "\nNo Employees Found\n"))
                                        :const SkeletonLoading(),
                                  ),
                                ),10.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap:(){
                                        utils.navigatePage(context, ()=> DashBoard(child: VisitReport(date1: homeProvider.startDate, date2: homeProvider.endDate,month: homeProvider.month,type: homeProvider.type)));
                                      },
                                      child: Container(
                                        width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                        decoration: customDecoration.baseBackgroundDecoration(
                                            color: colorsConst.emp1,radius: 10
                                        ),
                                        height: 80,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              const CustomText(text: "Today’s Visits"),
                                              CustomText(size:16,text: homeProvider.totalV.toString(),isBold: true,),
                                              // CustomText(size:16,text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["total_attendance"],isBold: true,),
                                              CustomText(text: "Based on ${homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["customer_count"].toString()} ${homeProvider.mainReportList.isEmpty||homeProvider.mainReportList[0]["customer_count"].toString()=="0"?constValue.customer:"${constValue.customer}s"}",
                                                  size: 12),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap:(){
                                        homeProvider.updateIndex(4);
                                        utils.navigatePage(context, ()=> DashBoard(child: AttendanceReport(type: homeProvider.type,showType: "0",date1: homeProvider.startDate,date2:homeProvider.endDate,empList: empPvr.userData)));
                                      },
                                      child: Container(
                                        width: kIsWeb?webWidth/2.1:phoneWidth/2.1,height: 80,
                                        decoration: customDecoration.baseBackgroundDecoration(
                                            color: colorsConst.emp2,radius: 10
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              const CustomText(text: "Total Hours Worked"),
                                              CustomText(text:attPvr.totalHrs2==""?"0 mins":attPvr.totalHrs2,size: 16,isBold: true),
                                              const CustomText(text: "Based on 12 Hours",size: 12)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),15.height,
                                GestureDetector(
                                  onTap: (){
                                    homeProvider.updateIndex(10);
                                    utils.navigatePage(context, ()=> DashBoard(child: ViewTask(date1: homeProvider.startDate, date2: homeProvider.endDate, type: homeProvider.type)));
                                  },
                                  child: Container(
                                    decoration: customDecoration.baseBackgroundDecoration(
                                        color: colorsConst.emp3,radius: 10
                                    ),
                                    width: kIsWeb?webWidth:phoneWidth,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const CustomText(text: "Pending & Completed Tasks",isBold: true),10.height,
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                // color: Colors.pink,
                                                width: kIsWeb?webWidth/2.5:phoneWidth/2.5,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const CustomText(text: "Assigned"),10.height,
                                                    const CustomText(text: "Pending"),10.height,
                                                    const CustomText(text: "Completed"),5.height,
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  Container(
                                                      decoration: customDecoration.baseBackgroundDecoration(
                                                          color: colorsConst.blue1,radius: 8
                                                      ),
                                                      width: 40,
                                                      child: Center(child:
                                                      CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["total_tasks"],
                                                        isBold: true,colors: colorsConst.blue2,))),10.height,
                                                  Container(
                                                      decoration: customDecoration.baseBackgroundDecoration(
                                                          color: colorsConst.red1,radius: 8
                                                      ),
                                                      width: 40,
                                                      child: Center(child:
                                                      CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["incomplete_count"],
                                                          isBold: true,colors: colorsConst.red2))),10.height,
                                                  Container(
                                                      decoration: customDecoration.baseBackgroundDecoration(
                                                          color: colorsConst.green1,radius: 8
                                                      ),
                                                      width: 40,
                                                      child: Center(child:
                                                      CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["complete_count"],
                                                          isBold: true,colors: colorsConst.green2))),5.height,
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),15.height,
                                GestureDetector(
                                  onTap: (){
                                    homeProvider.updateIndex(10);
                                    utils.navigatePage(context, ()=> DashBoard(child: ViewTask(date1: homeProvider.startDate, date2: homeProvider.endDate, type: homeProvider.type)));
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const CustomText(text: "Tasks waiting for action",isBold: true),15.height,
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            height: 60,
                                            decoration: customDecoration.baseBackgroundDecoration(
                                                color: colorsConst.sandal1,radius: 5
                                            ),
                                            width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CustomText(text: "Expense Report",colors: colorsConst.sandal2),
                                                  CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["pending_expense_report_count"],isBold: true,colors: colorsConst.sandal2),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: 60,
                                            decoration: customDecoration.baseBackgroundDecoration(
                                                color: colorsConst.blue3,radius: 5
                                            ),
                                            width: kIsWeb?webWidth/2.1:phoneWidth/2.1,
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CustomText(text: "Visit Report",colors: colorsConst.blue4,),
                                                  CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["pending_visit_count"], isBold:true, colors: colorsConst.blue4),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                15.height,
                                GestureDetector(
                                  onTap: (){
                                    homeProvider.updateIndex(9);
                                    utils.navigatePage(context, ()=> DashBoard(child: ViewExpense(tab:false,date1: homeProvider.startDate, date2: homeProvider.endDate,type: homeProvider.type)));
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const CustomText(text: "Expense Reports",isBold: true),15.height,
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            height: 50,
                                            decoration: customDecoration.baseBackgroundDecoration(
                                                color: colorsConst.emp1,radius: 5
                                            ),
                                            width: kIsWeb?webWidth/4.2:phoneWidth/4.2,
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CustomText(text: "Total",colors: colorsConst.blue5,),
                                                  CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["total_expense_count"], isBold:true, colors: colorsConst.blue5),
                                                ],
                                              ),
                                            ),
                                          ),5.width,
                                          Container(
                                            height: 50,
                                            decoration: customDecoration.baseBackgroundDecoration(
                                                color: colorsConst.emp2,radius: 5
                                            ),
                                            width: kIsWeb?webWidth/4.2:phoneWidth/4.2,
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CustomText(text: "Approved",colors: colorsConst.green3,),
                                                  CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["approved_expense_count"], isBold:true, colors: colorsConst.green3),
                                                ],
                                              ),
                                            ),
                                          ),5.width,
                                          Container(
                                            height: 50,
                                            decoration: customDecoration.baseBackgroundDecoration(
                                                color: colorsConst.org1,radius: 5
                                            ),
                                            width: kIsWeb?webWidth/4.2:phoneWidth/4.2,
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CustomText(text: "Inprocess",colors: colorsConst.org2,),
                                                  CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["pending_expense_count"], isBold:true, colors: colorsConst.org2),
                                                ],
                                              ),
                                            ),
                                          ),5.width,
                                          Container(
                                            height: 50,
                                            decoration: customDecoration.baseBackgroundDecoration(
                                                color: colorsConst.red3,radius: 5
                                            ),
                                            width: kIsWeb?webWidth/4.2:phoneWidth/4.2,
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CustomText(text: "Rejected",colors: colorsConst.red4,),
                                                  CustomText(text: homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["rejected_expense_count"], isBold:true, colors: colorsConst.red4),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                10.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomLoadingButton(
                                      height: 35,isBold: false,
                                      callback: (){
                                        // homeProvider.updateIndex(5);
                                        // utils.navigatePage(context, ()=>const DashBoard(child: ReportDashboard()));

                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Consumer<HomeProvider>(
                                              builder: (context, homeProvider, _) {
                                                return AlertDialog(
                                                  actions: [
                                                    SizedBox(
                                                      width: kIsWeb?MediaQuery.of(context).size.width*0.3:MediaQuery.of(context).size.width*0.9,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            children: [
                                                              IconButton(
                                                                icon:SvgPicture.asset(assets.cancel,width: 20,height: 20,),
                                                                onPressed: (){
                                                                  Navigator.pop(context);
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                          Center(child: CustomText(text: "Choose a report",isBold:true)),
                                                          20.height,

                                                          iconBox(
                                                              callBack: (){
                                                                homeProvider.updateIndex(4);
                                                                utils.navigatePage(context, ()=> DashBoard(child: AttendanceReport(type: homeProvider.type,showType: "0",date1: homeProvider.startDate,date2:homeProvider.endDate,empList: empPvr.userData)));
                                                              },img: assets.aTt,text: "Attendance Report"
                                                          ),
                                                          20.height,
                                                          iconBox(
                                                              callBack: (){
                                                                homeProvider.updateIndex(5);
                                                                utils.navigatePage(context, ()=>const DashBoard(child: ReportDashboard()));
                                                              },img: assets.aTask,text: "Task Report"
                                                          ),
                                                          20.height,
                                                          iconBox(
                                                              callBack: (){
                                                                homeProvider.updateIndex(16);
                                                                utils.navigatePage(context, ()=>const DashBoard(child: ViewWorkReport()));
                                                              },img: assets.aRep,text: "Work Report"
                                                          ),
                                                          20.height,
                                                          iconBox(
                                                              callBack: (){
                                                                homeProvider.updateIndex(15);
                                                                utils.navigatePage(context, ()=>const DashBoard(child: ViewProjectReport()));
                                                              },img: assets.aPrj,text: "Project Report"
                                                          ),20.height,
                                                          iconBox(
                                                              callBack: (){
                                                                utils.navigatePage(context, ()=> DashBoard(child: VisitReport(date1: homeProvider.startDate, date2: homeProvider.endDate,month: homeProvider.month,type: homeProvider.type,)));
                                                              },img: assets.aLoc,text: "Visit Report"
                                                          ),
                                                          20.height,
                                                          Center(
                                                            child: TextButton(
                                                              child:CustomText(text: "Cancel",colors: colorsConst.appRed,),
                                                              onPressed: (){
                                                                Navigator.pop(context);
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        );

                                      }, isLoading: false,text: "Reports",
                                      textColor: Colors.black,
                                      backgroundColor: colorsConst.buto2, radius: 10,
                                      width: kIsWeb?webWidth/2:phoneWidth/2.3,),
                                    CustomLoadingButton(
                                      height: 35,isBold: false,
                                      callback: (){
                                        utils.navigatePage(context, ()=>const DashBoard(child: ViewNotification()));
                                      }, isLoading: false,text: "Notifications",
                                      textColor: Colors.black,
                                      backgroundColor: colorsConst.pendingRep, radius: 10,
                                      width: kIsWeb?webWidth/2:phoneWidth/2.3,)
                                  ],
                                ),10.height,
                              ],
                            ),
                          ],
                        ),
                      )
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
  bool isLate(String inTime) {
    final format = DateFormat("hh:mm a");

    DateTime officeTime = format.parse("09:00 AM");
    DateTime userTime = format.parse(inTime);

    return userTime.isAfter(officeTime);
  }
  Widget iconBox({required VoidCallback callBack,required String img,required String text}){
    return InkWell(
      onTap:callBack,
      child: Container(
        height: 40,
        decoration: customDecoration.baseBackgroundDecoration(
            color: Colors.white,radius: 5,borderColor: Colors.grey.shade400
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              10.width,
              SizedBox(
                  width: 20,height: 20,
                  // color: Colors.pinkAccent,
                  child: SvgPicture.asset(img,width: 20,height: 20,)),
              10.width,
              CustomText(text: text),
            ],
          ),
        ),
      ),
    );
  }
  String getTimeDifferenceFrom(String timeString) {
    final now = DateTime.now();

    // Parse time string like "2:20 PM"
    final regex = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false);
    final match = regex.firstMatch(timeString.trim());

    if (match == null) return 'Invalid time format';

    int hour = int.parse(match.group(1)!);
    int minute = int.parse(match.group(2)!);
    String period = match.group(3)!.toUpperCase();

    // Convert to 24-hour format
    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    final customTime = DateTime(now.year, now.month, now.day, hour, minute);

    final difference = now.difference(customTime);

    if (difference.isNegative) {
      return 'Time is in the future';
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    return '$hours : $minutes';
  }
  String timeDifference (String dateTimeString1,String dateTimeString2) {
    DateTime startTime = DateTime.parse(dateTimeString1);
    DateTime endTime = DateTime.parse(dateTimeString2);

    Duration difference = endTime.difference(startTime);

    return difference.inHours==0?"${difference.inMinutes} Mins":"${difference.inHours} Hrs";
  }
  Future<void> getWebSafeLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, // 👈 Web-safe
      );

      log("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
    } catch (e) {
      log("❌ Error fetching location: $e");
    }
  }

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    }
    if (hour < 17) {
      return 'Good Afternoon,';
    }
    return 'Good Evening,';
  }
}

class MyTaskHandler extends TaskHandler {
  DateTime updateTs=DateTime.now();
  DateTime updateServerTs=DateTime.now();

  // @override
  // Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
  //   await GetStorage.init();
  //   print("✅ Tracking started");
  // }
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // await GetStorage.init();
    final storage = GetStorage();
    log("✅ Tracking started in background task");
    log("📦 Task Read: Track=${storage.read("Track")}, Unit=${storage.read("TrackUnitName")}");
  }


  @override
  Future<void> onDestroy(DateTime timestamp) async {
    updateTs=DateTime.now();
    updateServerTs=DateTime.now();
    log("🛑 Tracking stopped");
    final storage = GetStorage();
    storage.write("wasTracking", true);
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }

  @override
  @override
  void onRepeatEvent(DateTime timestamp) async {
    // await GetStorage.init();
    log("**** OnRepeat Start {${localData.storage.read("TrackUnitName")}}");

    bool result = isMoreThan5Seconds(updateTs);
    bool serverResult = isMoreThanOneMinute(updateServerTs);

    if (result) {
      log("5 seconds passed ${DateTime.now().hour} ${DateTime.now().minute} ${DateTime.now().second}");
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        // double speedInKmph = position.speed * 3.6;

        trackCtr.locationList.add({
          "emp_id":localData.storage.read("id"),
          "unit_id": localData.storage.read("TrackId"),
          "unit_name": localData.storage.read("TrackUnitName"),
          "date": "${DateTime.now().day.toString().padLeft(2, "0")}-${DateTime.now().month.toString().padLeft(2, "0")}-${DateTime.now().year}",
          "shift": "",
          "status": localData.storage.read("TrackStatus"),
          "lat": position.latitude,
          "lng": position.longitude,
          "created_ts": DateTime.now().toString(),
          "speed": position.speed.toStringAsFixed(2)
        });
        log("📍 OnStart Location (${DateTime.now()})");
      } catch (e) {
        log("⚠️ Location error: $e");
      }
      updateTs = DateTime.now();
    }

    if (serverResult) {
      log("One minute passed ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}");
      if (trackCtr.locationList.isNotEmpty) {
        try {
          final Map<String, dynamic> data = {
            "action": trackListInsert,
            "empList": trackCtr.locationList,
          };

          final response = await http.post(
            Uri.parse(phpFile),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          );
          log(response.body);
          if (response.statusCode == 200) {
            log("✅ Location uploaded");
            trackCtr.locationList.clear();
          } else {
            log("❌ Upload failed: ${response.statusCode}");
          }
        } catch (e) {
          log("⚠️ Upload error: $e");
        }
      }
      updateServerTs = DateTime.now();
    }
  }
  bool isMoreThan5Seconds(DateTime customTime) {
    DateTime currentTime = DateTime.now();
    Duration difference = currentTime.difference(customTime);
    return difference.inSeconds > 5;
  }
  bool isMoreThanOneMinute(DateTime customTime) {
    DateTime currentTime = DateTime.now();
    Duration difference = currentTime.difference(customTime);
    return difference.inSeconds > 60;
  }

}