import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:master_code/screens/common/work_done.dart';
import 'package:master_code/view_model/expense_provider.dart';
import 'package:provider/provider.dart';
import '../../component/animated_button.dart';
import '../../component/custom_loading.dart';
import '../../component/new_co.dart';
import '../../component/update_app.dart';
import '../../model/attendance_model.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/dashboard_assets.dart';
import '../../source/constant/default_constant.dart';
import '../../source/constant/local_data.dart';
import '../../source/extentions/int_extensions.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/attendance_provider.dart';
import '../../view_model/customer_provider.dart';
import '../../view_model/employee_provider.dart';
import '../../view_model/home_provider.dart';
import '../../view_model/location_provider.dart';
import '../attendance/attendance_report.dart';
import '../attendance/custom_attendance.dart';
import '../controller/track_controller.dart';
import '../customer/view_task.dart';
import '../customer/visit/add_visit.dart';
import '../customer/visit_report/visits_report.dart';
import 'view_notification.dart';
import '../expense/view_expense.dart';
import '../project_report/view_project_report.dart';
import '../report_dashboard/report_dashboard.dart';
import '../task/view_task.dart';
import '../track/background_task.dart';
import '../track/live_location.dart';
import '../work_report/view_work_report.dart';
import 'dashboard.dart';
import 'home_page.dart';


@pragma('vm:entry-point')
void startCallbackDispatcher() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        final provider =
        Provider.of<EmployeeProvider>(context, listen: false);

        provider.getNotifications();
        provider.markNotificationsAsSeen();
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
                   CustomText('Do you want',color: Colors.black,size:16,weight: FontWeight.bold,),
                  10.height,
                  const CustomText('track your travel?',color: Colors.black,size:16,weight: FontWeight.bold,)
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
                                    const CustomText('Do not close the app or',color: Colors.black,size:16,weight: FontWeight.bold,),
                                    10.height,
                                    const CustomText('turn off the location.',color: Colors.black,size:16,weight: FontWeight.bold,)
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
                  const CustomText('Do you want',color: Colors.black,size:16,weight: FontWeight.bold,),
                  10.height,
                  const CustomText('track off?',color: Colors.black,size:16,weight: FontWeight.bold,)
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
            title: CustomText("Battery Optimization",color: colorsConst.primary,weight: FontWeight.bold,),
            content: CustomText("Please disable battery optimization for background tracking.",color: colorsConst.greyClr),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: CustomText("Don't Allow",color: colorsConst.appRed,weight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await FlutterForegroundTask.requestIgnoreBatteryOptimization();
                },
                child: CustomText("Allow",color: colorsConst.blueClr,weight: FontWeight.bold,),
              ),
            ],
          ),
        );
      }
    }
  }
  Future<void> _startTracking() async {
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
              CustomText( text),
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
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  bool isVerify = false;
  bool isPermission = false;
  DateTime selectedDate = DateTime.now();
  String? selectedFilter = "Today";

  // Future<void> _pickDate() async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: selectedDate,
  //     firstDate: DateTime(2020),
  //     lastDate: DateTime(2100),
  //   );
  //
  //   if (picked != null) {
  //     setState(() {
  //       selectedDate = picked;
  //       selectedFilter = null; // Important
  //     });
  //   }
  // }
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return "$day/$month/$year";
  }

  String _formatDateRange() {
    return "${_formatDate(selectedDate)} - ${_formatDate(selectedDate)}";
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Consumer5<HomeProvider,CustomerProvider,AttendanceProvider,LocationProvider,EmployeeProvider>(
      builder: (context,homeProvider,custProvider,attPvr,locPvr,empPvr,_){
        int visitPendingCount = homeProvider.mainReportList.isEmpty
            ? 0
            : homeProvider.inActiveVisit;

        int visitActiveCount = homeProvider.activeVisit;
        int totalVisits = visitPendingCount + visitActiveCount;

        int taskPendingCount = homeProvider.mainReportList.isEmpty
            ? 0
            : int.tryParse(
          homeProvider.mainReportList[0]["incomplete_count"].toString(),
        ) ?? 0;

        int taskCompletedCount = homeProvider.mainReportList.isEmpty
            ? 0
            : int.tryParse(
          homeProvider.mainReportList[0]["complete_count"].toString(),
        ) ?? 0;

        int taskTotal = taskPendingCount + taskCompletedCount;

        int approvedCount = homeProvider.mainReportList.isEmpty
            ? 0
            : int.tryParse(
          homeProvider.mainReportList[0]["approved_expense_count"].toString(),
        ) ?? 0;

        int pendingCount = homeProvider.mainReportList.isEmpty
            ? 0
            : int.tryParse(
          homeProvider.mainReportList[0]["pending_expense_count"].toString(),
        ) ?? 0;

        int rejectedCount = homeProvider.mainReportList.isEmpty
            ? 0
            : int.tryParse(
          homeProvider.mainReportList[0]["rejected_expense_count"].toString(),
        ) ?? 0;

        int total = approvedCount + pendingCount + rejectedCount;

        return StreamBuilder(
            stream:FirebaseFirestore.instance.collection('attendance').snapshots(),
            builder: (context,snapshot){
              return Scaffold(
                backgroundColor: ColorsConst.background2,
                body: PopScope(
                  canPop: false,
                  onPopInvoked: (bool pop){
                    return utils.customDialog(
                        context: context,
                        callback: (){
                          SystemNavigator.pop();
                          }, title: "Do you want to Exit the App?");
                  },
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: homeProvider.versionCheck==false
                          ?const Center(child: Loading())
                          :homeProvider.currentVersion!=""&&homeProvider.versionCheck==true&&
                          homeProvider.versionActive==false?
                      const UpdateApp()
                          :homeProvider.refresh==false||homeProvider.vRefresh==false?
                      const Loading():
                      homeProvider.mainReportList.isNotEmpty&&homeProvider.mainReportList[0]["active"]!="1"
                          ?const Center(child: CustomText(
                        "Invalid",color: Colors.red,weight: FontWeight.bold,
                        size: 20,))
                          :NotificationListener<OverscrollIndicatorNotification>(
                        onNotification: (overscroll) {
                          overscroll.disallowIndicator();
                          return true;
                        },
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Top Header Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  /// ARUU Logo
                                  Image.asset(assets.logo),

                                  /// Right Side Icons
                                  Row(
                                    children: [
                                      if(localData.storage.read("role")=="1")
                                      InkWell(
                                        onTap: (){
                                          homeProvider.updateIndex(3);
                                          utils.navigatePage(context, ()=>const DashBoard(child: TrackingLive()));
                                        },
                                          child: Image.asset(assets.tracks)),
                                      25.width,
                    Consumer<EmployeeProvider>(
                      builder: (context, emp, _) {
                        // print("count ${emp.unreadCount}");
                        return Stack(
                          children: [
                            InkWell(
                              onTap: () {
                                utils.navigatePage(
                                  context,
                                      () => const DashBoard(child: ViewNotification()),
                                );
                              },
                              child: Image.asset(DashboardAssets.reminder,width: 40,height: 50,),
                            ),

                            if (emp.unreadCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    emp.unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    25.width,
                                      //Image.asset(DashboardAssets.menu),
                                    ],
                                  ),
                                ],
                              ),
                              10.height,

                              /// Greeting Text
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "${greeting()}  ",
                                      style: GoogleFonts.lato(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color:Colors.black
                                      ),
                                    ),
                                    TextSpan(
                                      text: "${localData.storage.read("f_name")}",
                                      style: GoogleFonts.lato(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: ColorsConst.textBlack,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              5.height,

                              /// Date + Reports Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(
                                    homeProvider.date,
                                    size: 14,
                                    color: ColorsConst.textGrey,
                                  ),
                                  if(localData.storage.read("role")!="1")
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
                                             localData.storage.read("Track") == true
                                                  ? 'ON     '
                                                  : '     Tracker Off',
                                              size: 11, color: Colors.white,
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
                                  /// Reports Elevated Button
                                  ElevatedButton(
                                    onPressed: () {
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
                                                        Center(child: CustomText("Choose a report",weight:FontWeight.bold)),
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
                                                            child:CustomText("Cancel",color: colorsConst.appRed,),
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
                                      debugPrint("Reports Clicked");
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorsConst.primary,
                                      elevation: 4,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 25,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(DashboardAssets.reportIcon),
                                        8.width,
                                        const CustomText(
                                          "Reports",
                                          color: Colors.white,
                                          weight: FontWeight.w600,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              5.height,
                              SizedBox(
                                width: screenWidth,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        height: 35,
                                        width: screenWidth/2.2,
                                        decoration: customDecoration.baseBackgroundDecoration(
                                            color: Colors.white,radius: 10
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: homeProvider.type,
                                            isExpanded: true,
                                            // dropdownColor: Color(0xFFD88D90),
                                            icon: const Icon(
                                              Icons.keyboard_arrow_down,
                                              color: Colors.black,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            items: homeProvider.typeList.map((list) {
                                              return DropdownMenuItem(
                                                value: list,
                                                child: CustomText(
                                                  "  $list",
                                                  color: Colors.black,
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                homeProvider.changeType(context,value);
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap:(){
                                          homeProvider.showDatePickerDialog(context);
                                        },
                                        child: Container(
                                          height: 35,
                                          width: screenWidth/2.2,
                                          decoration: customDecoration.baseBackgroundDecoration(
                                              color: Colors.white,radius: 10
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: 18,
                                                color: colorsConst.primary,
                                              ),
                                              const SizedBox(width: 5),
                                              Expanded(
                                                child: CustomText(
                                                  size: 12,
                                                  (homeProvider.startDate == homeProvider.endDate)
                                                      ? homeProvider.startDate
                                                      : "${homeProvider.startDate} to ${homeProvider.endDate}",
                                                  weight: FontWeight.w600,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                ),
                              ),
                              10.height,
                              InkWell(
                                  child: const CheckAttendance()),
                              10.height,
                              /// DAILY WORK PLAN
                              Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xffF3F6FA),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: const Color(0xff0078D7), width: 1.5),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    /// LEFT TEXT
                                    const CustomText(
                                      "Daily Work Plan",
                                      size: 14,
                                      weight: FontWeight.bold,
                                      color: Color(0xff1A85DB),
                                    ),
                                    /// SUBMIT BUTTON
                                    localData.storage.read("role")=="1"?
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => WorkDoneEmployeesPage(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xff1A85DB),
                                              Color(0xff1A85DB),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: const [
                                            CustomText(
                                              "View",
                                              size: 13,
                                              weight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 6),
                                            Icon(Icons.check_circle,
                                                color: Colors.white, size: 15),
                                          ],
                                        ),
                                      ),
                                    ):
                                    Row(
                                      children: [

                                        /// 🔥 If Work Already Done → Show Submitted
                                        attPvr.isWorkDone != 0
                                            ? Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: const [
                                              CustomText(
                                                "Submitted",
                                                size: 13,
                                                weight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 6),
                                              Icon(Icons.check_circle,
                                                  color: Colors.white, size: 15),
                                            ],
                                          ),
                                        )

                                        /// 🔥 If Not Done → Show YES Button
                                            :
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                attPvr.putWorkDone(context);
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                                                decoration: BoxDecoration(
                                                  gradient: const LinearGradient(
                                                    colors: [
                                                      Color(0xff1A85DB),
                                                      Color(0xff1A85DB),
                                                    ],
                                                  ),
                                                  borderRadius: BorderRadius.circular(10),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black45,
                                                      blurRadius: 6,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  children: const [
                                                    CustomText(
                                                      "Yes",
                                                      size: 13,
                                                      weight: FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 6),
                                                    Icon(Icons.check_circle,
                                                        color: Colors.white, size: 15),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            5.width,
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xff1A85DB),
                                                    Color(0xff1A85DB),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black45,
                                                    blurRadius: 6,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: const Row(
                                                children: [
                                                  CustomText(
                                                    "No",
                                                    size: 13,
                                                    weight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              /// ================= ATTENDANCE CARD =================
                               if(localData.storage.read("role")=="1")
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const CustomText(
                                            "Employees Attendance Log",
                                            size: 14,
                                            weight: FontWeight.bold,
                                            color: Colors.black,
                                          ),

                                          CustomText(
                                              "Total Employees : ${homeProvider.mainReportList.isEmpty?"":homeProvider.mainReportList[0]["total_user_count"].toString()}",
                                              color:Color(0xffA2A2A2)
                                          ),
                                        ],
                                      ),
                                    ),     ///ADDED NEW
                                    5.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                         AttendanceItem(
                                           onClick: (){
                                               if(homeProvider.mainReportList.isNotEmpty&&homeProvider.mainReportList[0]["unique_attendance_count"].toString()!="0"){
                                                 homeProvider.updateIndex(4);
                                                 utils.navigatePage(context, ()=> DashBoard(child: AttendanceReport(type: homeProvider.type,showType: "Present",date1: homeProvider.startDate,date2:homeProvider.endDate,empList: empPvr.userData)));
                                               }else{
                                                 utils.showWarningToast(context, text: "No present employees found");
                                               }
                                           },
                                          title: "Present",type: "1",
                                          count: homeProvider.mainReportList.isEmpty ?"0":homeProvider.mainReportList[0]["unique_attendance_count"].toString()=="null"?"0": homeProvider.mainReportList[0]["unique_attendance_count"].toString(),
                                          bgColor: Color(0xFFE8F5E9),
                                          borderColor: ColorsConst.present,
                                          imagePath: DashboardAssets.present,
                                        ),
                                         AttendanceItem(
                                          title: "Absent",
                                          onClick: (){
                                            if(homeProvider.mainReportList.isNotEmpty&&homeProvider.mainReportList[0]["no_attendance_count"].toString()!="0"&&homeProvider.mainReportList[0]["no_attendance_count"].toString()!="null"){
                                              homeProvider.updateIndex(4);
                                              utils.navigatePage(context, ()=> DashBoard(child: AttendanceReport(type: homeProvider.type,showType: "Absent",date1: homeProvider.startDate,date2:homeProvider.endDate,empList: empPvr.userData)));
                                            }else{
                                              utils.showWarningToast(context, text: "No absent employees found");
                                            }
                                          },
                                           count: homeProvider.mainReportList.isEmpty ?"0":homeProvider.mainReportList[0]["no_attendance_count"].toString()=="null"?"0": homeProvider.mainReportList[0]["no_attendance_count"].toString(),
                                           bgColor: Color(0xFFFFEBEE),
                                          borderColor: ColorsConst.absent,
                                          imagePath: DashboardAssets.absent,
                                        ),
                                         AttendanceItem(
                                          title: "On-Leave",
                                          onClick: (){
                                            if(homeProvider.mainReportList.isNotEmpty&&(homeProvider.mainReportList[0]["fulldayleave_user"].toString()!="0"||homeProvider.mainReportList[0]["sessionleave_user"].toString()!="0")){
                                              // homeProvider.updateIndex(11);
                                              // utils.navigatePage(context, ()=> DashBoard(child: ViewMyLeaves(date1:homeProvider.startDate,date2:homeProvider.endDate,isDirect: true)));
                                              homeProvider.updateIndex(4);
                                              utils.navigatePage(context, ()=> DashBoard(child: AttendanceReport(type: homeProvider.type,showType: "Leave",date1: homeProvider.startDate,date2:homeProvider.endDate,empList: empPvr.userData)));
                                            }else{
                                              utils.showWarningToast(context, text: "No on leave employee found");
                                            }
                                          },
                                          count: homeProvider.mainReportList.isEmpty?"0":"${int.parse(homeProvider.mainReportList[0]["fulldayleave_user"].toString()=="null"?"0":homeProvider.mainReportList[0]["fulldayleave_user"].toString())+int.parse(homeProvider.mainReportList[0]["sessionleave_user"].toString() =="null"?"0":homeProvider.mainReportList[0]["sessionleave_user"].toString())}",
                                          bgColor: Color(0xFFE3F2FD),
                                          borderColor: ColorsConst.onLeave,
                                          imagePath: DashboardAssets.onLeave,
                                        ),
                                         AttendanceItem(
                                          onClick: (){
                                            if(attPvr.lateCount!=0){
                                              homeProvider.updateIndex(4);
                                              utils.navigatePage(context, ()=> DashBoard(child: AttendanceReport(type: homeProvider.type,showType: "Late",date1: homeProvider.startDate,date2:homeProvider.endDate,empList: empPvr.userData)));
                                            }else{
                                              utils.showWarningToast(context, text: "No late employees found");
                                            }
                                          },
                                          title: "Late",
                                          count: "${attPvr.lateCount}",
                                          bgColor: const Color(0xFFFFF3E0),
                                          borderColor: colorsConst.late,
                                          imagePath: DashboardAssets.late,
                                        ),
                                         AttendanceItem(
                                          onClick: (){
                                            if(homeProvider.mainReportList.isNotEmpty&&homeProvider.mainReportList[0]["perm_count"].toString()!="0"){
                                              homeProvider.updateIndex(4);
                                              utils.navigatePage(context, ()=> DashBoard(child: AttendanceReport(type: homeProvider.type,showType: "Permission",date1: homeProvider.startDate,date2:homeProvider.endDate,empList: empPvr.userData)));
                                            }else{
                                              utils.showWarningToast(context, text: "No permission employees found");
                                            }
                                          },
                                          title: "Permission",type: "2",
                                          count: homeProvider.mainReportList.isEmpty ?"0":homeProvider.mainReportList[0]["perm_count"].toString()=="null"?"0": homeProvider.mainReportList[0]["perm_count"].toString(),
                                          bgColor: Colors.purple.shade200,
                                          borderColor:Colors.purple,
                                          imagePath: DashboardAssets.late,
                                        ),
                                      ],
                                    ),
                                    5.height,
                                    //  Center(
                                    //   child: CustomText(
                                    //     "Total Employees : ${homeProvider.mainReportList.isEmpty?"":homeProvider.mainReportList[0]["total_user_count"].toString()}",
                                    //     color: ColorsConst.textGrey,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                              10.height,
                              InkWell(
                                onTap:(){
                                  utils.navigatePage(context, ()=> DashBoard(child: VisitReport(date1: homeProvider.startDate, date2: homeProvider.endDate,month: homeProvider.month,type: homeProvider.type,)));
                                },
                                child: homeProvider.vRefresh==false
                                    ? const Loading():Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      /// Top Row
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const CustomText(
                                                "Total Visits  ",
                                                size: 18,
                                                weight: FontWeight.bold,
                                              ),
                                              CustomText("${homeProvider.visitCount.length}", size: 28, weight: FontWeight.bold),
                                            ],
                                          ),
                                          InkWell(
                                            onTap: (){
                                              utils.navigatePage(context, ()=> DashBoard(child:
                                              CusAddVisit(taskId:"",companyId: "",companyName: "",
                                                  numberList: [],isDirect: true, type: "", desc: "")));
                                            },
                                            child: Container(
                                              width: screenWidth/3,
                                              height: screenHeight/22,
                                              decoration: BoxDecoration(
                                                color: Color(0xffDAF2DC),
                                                borderRadius: BorderRadius.circular(10),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black38,
                                                    blurRadius: 4,
                                                    offset: Offset(0, 0),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      assets.addButton,
                                                    ),
                                                    SizedBox(width: 6),
                                                    CustomText(
                                                      "Add Visits",
                                                      size: 12,
                                                      weight: FontWeight.bold,
                                                      color: Color(0xff0F8D4B),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ), ///ADDED NEW,
                                          ),
                                        ],
                                      ),15.height,

                                      /// Big Count

                                      /// Main Content Row
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          /// LEFT SECTION
                                          Expanded(
                                            flex: 55,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CustomText(
                                                  "Active Visits(${homeProvider.activeVisit})",
                                                  size: 16,
                                                  weight: FontWeight.bold,
                                                  color: colorsConst.primary,
                                                ),
                                                const SizedBox(height: 8),
                                                /// Scrollable List (3 visible items height)
                                                SizedBox(
                                                  height: 95,
                                                  child: SingleChildScrollView(
                                                    physics: const BouncingScrollPhysics(),
                                                    child: Column(
                                                      children: [
                                                        !homeProvider.vRefresh
                                                            ? const SkeletonLoading()
                                                            : homeProvider.visitCount.isEmpty
                                                                ? const Center(
                                                                    child: CustomText(
                                                                       "No Visits Found",
                                                                    ),
                                                                  )
                                                                : Padding(
                                                                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                                                                    child: ListView.builder(
                                                                      itemCount: homeProvider.visitCount.length,
                                                                      shrinkWrap: true,
                                                                      physics: const NeverScrollableScrollPhysics(),
                                                                      itemBuilder: (context, index) {
                                                                        return  Padding(
                                                                          padding: const EdgeInsets.symmetric(
                                                                            vertical: 4,
                                                                          ),
                                                                          child: Row(
                                                                            children: [
                                                                              const Text("• "),
                                                                              Expanded(
                                                                                child: CustomText(
                                                                                  homeProvider.visitCount[index]["value"],
                                                                                  size: 13,
                                                                                ),
                                                                              ),
                                                                              Container(
                                                                                padding: const EdgeInsets.symmetric(
                                                                                  horizontal: 8,
                                                                                  vertical: 2,
                                                                                ),
                                                                                decoration: BoxDecoration(
                                                                                  color: colorsConst.primary,
                                                                                  borderRadius:
                                                                                  BorderRadius.circular(
                                                                                    12,
                                                                                  ),
                                                                                ),
                                                                                child: CustomText(
                                                                                  homeProvider.visitCount[index]["total_count"],
                                                                                  size: 10,
                                                                                  color: Colors.white,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          /// RIGHT SECTION
                                          Expanded(
                                            flex: 45,
                                            child: Column(
                                              children: [
                                                /// Larger Pie Chart (closer to reference)
                                                SizedBox(
                                                  height: 80,
                                                  child:
                                                  // totalVisits == 0
                                                  //     ? const Center(
                                                  //   child: CustomText("No Data"),
                                                  // )
                                                  //     :
                                                  PieChart(
                                                    PieChartData(
                                                      sectionsSpace: 0,
                                                      centerSpaceRadius: 0,
                                                      sections: [
                                                        PieChartSectionData(
                                                          value: visitPendingCount.toDouble(),
                                                          color: Color(0xffE34853),
                                                          radius: 50,
                                                          showTitle: false,
                                                        ),
                                                        PieChartSectionData(
                                                          value: visitActiveCount.toDouble(),
                                                          color: Color(0xff63D076),
                                                          radius: 50,
                                                          showTitle: false,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),15.height,
                                                Container(
                                                  width: screenWidth/2,
                                                  decoration: BoxDecoration(
                                                    color: colorsConst.primary,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.calendar_month,
                                                          size: 16,
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(width: 6),
                                                        CustomText(
                                                          "Pending Visits: ${homeProvider.inActiveVisit}",
                                                          size: 12,
                                                          weight: FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                // 20.height,
                                                // Container(
                                                //   padding: const EdgeInsets.symmetric(
                                                //     horizontal: 12,
                                                //     vertical: 6,
                                                //   ),
                                                //   decoration: BoxDecoration(
                                                //     color: Colors.white,
                                                //     borderRadius: BorderRadius.circular(8),
                                                //     boxShadow: const [
                                                //       BoxShadow(
                                                //         color: Colors.black38,
                                                //         blurRadius: 10,
                                                //         offset: Offset(0, 2),
                                                //       ),
                                                //     ],
                                                //   ),
                                                //   child: const CustomText(
                                                //     "View All 20 Types",
                                                //     size: 12,
                                                //     weight: FontWeight.w600,
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      10.height,
                                      ///  Inactive Visits CENTERED AT BOTTOM (LIKE IMAGE)
                                      // Center(
                                      //   child: CustomText(
                                      //     "Inactive Visits (18)",
                                      //     color: colorsConst.primary,
                                      //     weight: FontWeight.w600,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                              if (homeProvider.mainReportList.isNotEmpty && homeProvider.mainReportList[0]["total_expense_count"].toString() != "0")
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// TOP ROW
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        /// Left: Icon + Title
                                        InkWell(
                                          onTap: (){
                                            homeProvider.updateIndex(9);
                                            utils.navigatePage(context, ()=> DashBoard(child: ViewExpense(tab:false,date1: homeProvider.startDate, date2: homeProvider.endDate,type: homeProvider.type)));
                                          },
                                          child: Row(
                                            children: [
                                              /// Green Circle Icon
                                              Image.asset(DashboardAssets.expense),
                                              const SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    "Expenses",
                                                    size: 14,
                                                    color: Colors.black,
                                                    weight: FontWeight.bold,
                                                  ),
                                                  SizedBox(height: 2),
                                                  CustomText(
                                                    "${homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["total_expense_count"]} total reports",
                                                    size: 12,
                                                    color: Color(0xffA2A2A2),
                                                    weight: FontWeight.bold,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        /// Right: Approval Due Pill
                                        // Container(
                                        //   padding: const EdgeInsets.symmetric(
                                        //       horizontal: 14, vertical: 8),
                                        //   decoration: BoxDecoration(
                                        //     color: colorsConst.primary,
                                        //     borderRadius: BorderRadius.circular(20),
                                        //   ),
                                        //   child: Row(
                                        //     children: [
                                        //       Icon(
                                        //         Icons.refresh,
                                        //         size: 16,
                                        //         color: Colors.white,
                                        //       ),
                                        //       SizedBox(width: 6),
                                        //       CustomText(
                                        //         "Approval Due: ${homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["approved_expense_count"]}",
                                        //         size: 12,
                                        //         weight: FontWeight.w600,
                                        //         color: Colors.white,
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    /// PROGRESS BAR
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Row(
                                        children: [
                                          /// Approved (Green)
                                          Expanded(
                                            flex: total == 0 ? 0 : approvedCount,
                                            child: Container(
                                              height: 10,
                                              color: const Color(0xff0F8D4B),
                                            ),
                                          ),

                                          /// In Progress / Pending (Blue)
                                          Expanded(
                                            flex: total == 0 ? 0 : pendingCount,
                                            child: Container(
                                              height: 10,
                                              color: const Color(0xffD7EDFB),
                                            ),
                                          ),

                                          /// Rejected (Light Red)
                                          Expanded(
                                            flex: total == 0 ? 0 : rejectedCount,
                                            child: Container(
                                              height: 10,
                                              color: const Color(0xffFEDADE),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 16),
                                    /// STATUS CHIPS ROW
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        /// Approved
                                        InkWell(
                                          onTap: (){
                                            Provider.of<ExpenseProvider>(context, listen: false).checkFilterType("Approved");
                                            if(homeProvider.mainReportList.isNotEmpty&&homeProvider.mainReportList[0]["approved_expense_count"].toString()!="0"){
                                              homeProvider.updateIndex(9);
                                              utils.navigatePage(context, ()=> DashBoard(
                                                  child:
                                              ViewExpense(tab:true,date1: homeProvider.startDate,
                                                  date2: homeProvider.endDate,type: homeProvider.type)));
                                            }else{
                                              utils.showWarningToast(context, text: "No approved expenses found");
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: Color(0xff0F8D4B)),
                                            ),
                                            child: CustomText(
                                                "Approved(${"${homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["approved_expense_count"]}"})",
                                                size: 12,
                                                weight: FontWeight.w600,
                                                color: Color(0xff0F8D4B)
                                            ),
                                          ),
                                        ),

                                        /// In-Progress
                                        InkWell(
                                          onTap: (){
                                            Provider.of<ExpenseProvider>(context, listen: false).checkFilterType("In Process");
                                            if(homeProvider.mainReportList.isNotEmpty&&homeProvider.mainReportList[0]["approved_expense_count"].toString()!="0"){
                                              homeProvider.updateIndex(9);
                                              utils.navigatePage(context, ()=> DashBoard(
                                                  child:
                                                  ViewExpense(tab:true,date1: homeProvider.startDate,
                                                      date2: homeProvider.endDate,type: homeProvider.type)));
                                            }else{
                                              utils.showWarningToast(context, text: "No In-Progress expenses found");
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Color(0xffD7EDFB),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: Color(0xff0985D9)),
                                            ),
                                            child:  CustomText(
                                                "In-Progress($pendingCount)",
                                                size: 12,
                                                weight: FontWeight.w600,
                                                color: Color(0xff0985D9)
                                            ),
                                          ),
                                        ),

                                        /// Rejected
                                        InkWell(
                                          onTap: (){
                                            Provider.of<ExpenseProvider>(context, listen: false).checkFilterType("In Process");
                                            if(homeProvider.mainReportList.isNotEmpty&&homeProvider.mainReportList[0]["approved_expense_count"].toString()!="0"){
                                              homeProvider.updateIndex(9);
                                              utils.navigatePage(context, ()=> DashBoard(
                                                  child: ViewExpense(tab:true,date1: homeProvider.startDate,
                                                      date2: homeProvider.endDate,type: homeProvider.type)));
                                            }else{
                                              utils.showWarningToast(context, text: "No Rejected expenses found");
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Color(0xffFEDADE),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color:Color(0xffEF414D)),
                                            ),
                                            child: CustomText(
                                                "Rejected($rejectedCount)",
                                                size: 12,
                                                weight: FontWeight.w600,
                                                color: Color(0xffEF414D)
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              InkWell(
                                onTap: (){
                                  homeProvider.updateIndex(10);
                                  utils.navigatePage(context, ()=> DashBoard(child: ViewTask(date1: homeProvider.startDate, date2: homeProvider.endDate, type: homeProvider.type)));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [     ///ADDED NEW
                                      /// TOP ROW
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          /// LEFT SIDE (Icon + Title)
                                          Row(
                                            children: [
                                              Image.asset(
                                                DashboardAssets.task,
                                                width: 40,
                                                height: 40,
                                              ),
                                              const SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const CustomText(
                                                    "Tasks",
                                                    size: 16,
                                                    weight: FontWeight.bold,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  CustomText(
                                                    "${homeProvider.mainReportList.isEmpty ? "0" : homeProvider.mainReportList[0]["total_tasks"]} total tasks",
                                                    size: 12,
                                                    color: const Color(0xffA2A2A2),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          /// RIGHT SIDE (Add Task Button)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xffDAF2DC),
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black38,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 0),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children:  [
                                                Image.asset(
                                                  assets.addButton,
                                                ),
                                                SizedBox(width: 6),
                                                CustomText(
                                                  "Add Task",
                                                  size: 13,
                                                  weight: FontWeight.bold,
                                                  color: Color(0xff0F8D4B),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      /// SECOND ROW (Pending / Completed)
                                      Row(
                                        children: [
                                          const CustomText(
                                            "Pending: ",
                                            size: 13,
                                            weight: FontWeight.bold,
                                            color: Color(0xffF02433),
                                          ),
                                          CustomText(
                                            "${homeProvider.mainReportList.isEmpty ? "0" : homeProvider.mainReportList[0]["incomplete_count"]}",
                                            size: 13,
                                            weight: FontWeight.bold,
                                            color: const Color(0xffF02433),
                                          ),
                                          const SizedBox(width: 20),
                                          const CustomText(
                                            "Completed: ",
                                            size: 13,
                                            weight: FontWeight.bold,
                                            color: Color(0xff008443),
                                          ),
                                          CustomText(
                                            "${homeProvider.mainReportList.isEmpty ? "0" : homeProvider.mainReportList[0]["complete_count"]}",
                                            size: 13,
                                            weight: FontWeight.bold,
                                            color: const Color(0xff008443),
                                          ),
                                        ],
                                      ),
                                      5.height,
                                      /// PROGRESS BAR
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(2),
                                        child: Row(
                                          children: [
                                            /// Pending (Orange → Red)
                                            Expanded(
                                              flex: taskTotal == 0 ? 0 : taskPendingCount,
                                              child: Container(
                                                height: 30,
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFFFFA953),
                                                      Color(0xFFE81C2B),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),

                                            /// Completed (Green)
                                            Expanded(
                                              flex: taskTotal == 0 ? 0 : taskCompletedCount,
                                              child: Container(
                                                height: 30,
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFF24FF92),
                                                      Color(0xFF00733A),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      5.height,
                                      if(taskPendingCount!=0)
                                      // Row(
                                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      //   children: [
                                      //     CustomText(
                                      //       "Normal (${homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["Normal_count"]})",
                                      //       color: Colors.blue,
                                      //     ),
                                      //     CustomText(
                                      //       "High (${homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["High_count"]})",
                                      //       color: Colors.red,
                                      //     ),
                                      //     CustomText(
                                      //       "Immediate (${homeProvider.mainReportList.isEmpty?"0":homeProvider.mainReportList[0]["High_count"]})",
                                      //       color: Colors.purple,
                                      //     ),
                                      //   ],
                                      // ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [

                                            /// NORMAL
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                margin: const EdgeInsets.only(right: 8),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xffF2F6FE),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                alignment: Alignment.center,
                                                child: CustomText(
                                                  "Normal (${homeProvider.mainReportList.isEmpty ? "0" : homeProvider.mainReportList[0]["Normal_count"]})",
                                                  color: Color(0xff1A85DB),
                                                  weight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            /// HIGH
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                margin: const EdgeInsets.only(right: 8),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xffFEF2F2),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                alignment: Alignment.center,
                                                child: CustomText(
                                                  "High (${homeProvider.mainReportList.isEmpty ? "0" : homeProvider.mainReportList[0]["High_count"]})",
                                                  color: const Color(0xffFF5C68),
                                                  weight: FontWeight.w600,
                                                ),
                                              ),
                                            ),

                                            /// IMMEDIATE
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xffFBF2FE),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                alignment: Alignment.center,
                                                child: CustomText(
                                                  "Immediate (${homeProvider.mainReportList.isEmpty ? "0" : homeProvider.mainReportList[0]["High_count"]})",
                                                  color: Color(0xffB35CFF),
                                                  weight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            });
      },
    );
  }
}
