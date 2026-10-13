// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:aci/screens/common/dashboard.dart';
// import 'package:aci/screens/report_dashboard/report_dashboard.dart';
// import 'package:aci/source/constant/language_model.dart';
// import 'package:aci/view_model/location_provider.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:intl/intl.dart';
// import 'package:percent_indicator/linear_percent_indicator.dart';
// import 'package:provider/provider.dart';
// import 'package:aci/component/custom_text.dart';
// import 'package:aci/component/dotted_border.dart';
// import 'package:aci/source/constant/assets_constant.dart';
// import 'package:aci/source/constant/colors_constant.dart';
// import 'package:aci/source/constant/local_data.dart';
// import 'package:aci/source/extentions/extensions.dart';
// import 'package:aci/source/styles/decoration.dart';
// import '../../component/animated_button.dart';
// import '../../component/custom_appbar.dart';
// import '../../component/custom_loading.dart';
// import '../../component/update_app.dart';
// import '../../source/constant/api.dart';
// import '../../source/utilities/utils.dart';
// import '../../view_model/attendance_provider.dart';
// import '../../view_model/customer_provider.dart';
// import '../../view_model/employee_provider.dart';
// import '../../view_model/expense_provider.dart';
// import '../../view_model/home_provider.dart';
// import '../attendance/attendance_report.dart';
// import '../controller/track_controller.dart';
// import 'package:http/http.dart' as http;
//
// import '../expense/expense_page.dart';
// import '../expense/view_expense.dart';
// import '../task/view_task.dart';
// import '../track/tracking_report.dart';
//
// @pragma('vm:entry-point')
// void startCallbackDispatcher() {
//   FlutterForegroundTask.setTaskHandler(MyTaskHandler());
// }
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage>  with TickerProviderStateMixin {
//   Timer? _timer;
// @override
//   void initState() {
//   WidgetsBinding.instance.addPostFrameCallback((timeStamp){
//     if(!kIsWeb){
//       Provider.of<EmployeeProvider >(context, listen: false).getAllRoles();
//     }else{
//       Provider.of<EmployeeProvider >(context, listen: false).getRoles();
//     }
//     if(Provider.of<HomeProvider>(context, listen: false).roleEmp.isEmpty){
//       Provider.of<HomeProvider>(context, listen: false).roleEmployees();
//       Provider.of<AttendanceProvider>(context, listen: false).getMainAttendance();
//       Provider.of<CustomerProvider>(context, listen: false).getMainReport(true);
//       Provider.of<CustomerProvider>(context, listen: false).getDashboardReport(true);
//     }
//     Provider.of<EmployeeProvider>(context, listen: false).getAllUsers();
//     Provider.of<CustomerProvider>(context, listen: false).getAllCustomers(true);
//   });
//   final homeProvider = context.read<HomeProvider>();
//
//   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//     homeProvider.check();
//   });
//   super.initState();
//   }
//   void startTracking(BuildContext context,String lat,String lng){
//     showDialog(context: context,
//         barrierDismissible: false,
//         builder: ( context){
//           return AlertDialog(
//             title: Center(
//               child: Column(
//                 children: [
//                   const CustomText(text: 'Do you want',colors: Colors.black,size:16,isBold: true,),
//                   10.height,
//                   const CustomText(text: 'track your travel?',colors: Colors.black,size:16,isBold: true,)
//                 ],
//               ),
//             ),
//             actions: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   CustomBtn(width: 70,text: 'NO',
//                     callback: (){
//                       setState(() {
//                         localData.storage.write("Track",false);
//                         Navigator.of(context, rootNavigator: true).pop();
//                       });
//                     },
//                     bgColor: colorsConst.litGrey,textColor: Colors.black, ),
//                   CustomBtn(width: 70,text: 'YES',
//                     callback: ()  {
//                      showDialog(context: context,
//                           barrierDismissible: false,
//                           builder: ( context){
//                             return AlertDialog(
//                               title: Center(
//                                 child: Column(
//                                   children: [
//                                     const CustomText(text: 'Do not close the app or',colors: Colors.black,size:16,isBold: true,),
//                                     10.height,
//                                     const CustomText(text: 'turn off the location.',colors: Colors.black,size:16,isBold: true,)
//                                   ],
//                                 ),
//                               ),
//                               actions: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                   children: [
//                                     CustomBtn(width: 70,text: 'OK',
//                                       callback: (){
//                                         setState(() {
//                                           _startTracking();
//                                           Provider.of<CustomerProvider>(context, listen: false).actionTracking(context,"1");
//                                         });
//                                         Provider.of<CustomerProvider>(context, listen: false).trackingInsert(localData.storage.read("TrackId").toString(),true,lat,lng);
//                                         Navigator.of(context, rootNavigator: true).pop();
//                                         Navigator.of(context, rootNavigator: true).pop();
//                                         },
//                                       bgColor: colorsConst.primary,textColor: Colors.white, )
//                                   ],
//                                 )
//                               ],
//                             );
//                           }
//                       );
//                     },
//                     bgColor: colorsConst.primary,textColor: Colors.white, ),
//                 ],
//               )
//             ],
//           );});
//   }
//   void stopTracking(BuildContext context){
//     showDialog(context: context,
//         barrierDismissible: false,
//         builder: ( context){
//           return AlertDialog(
//             title: Center(
//               child: Column(
//                 children: [
//                   const CustomText(text: 'Do you want',colors: Colors.black,size:16,isBold: true,),
//                   10.height,
//                   const CustomText(text: 'track off?',colors: Colors.black,size:16,isBold: true,)
//                 ],
//               ),
//             ),
//             actions: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   CustomBtn(width: 70,text: 'NO',
//                     callback: (){
//                         Navigator.of(context, rootNavigator: true).pop();
//                     },
//                     bgColor: colorsConst.litGrey,textColor: Colors.black, ),
//                   CustomBtn(width: 70,text: 'YES',
//                     callback: _stopTracking,
//                     bgColor: colorsConst.primary,textColor: Colors.white, ),
//                 ],
//               )
//             ],
//           );});
//   }
//   Future<void> _checkBatteryOptimization() async {
//     if (Platform.isAndroid) {
//       bool isIgnored = await FlutterForegroundTask.isIgnoringBatteryOptimizations;
//       if (!isIgnored) {
//         await showDialog(
//           context: context,
//           builder: (_) => AlertDialog(
//             title: CustomText(text:"Battery Optimization",colors: colorsConst.primary,isBold: true,),
//             content: CustomText(text:"Please disable battery optimization for background tracking.",colors: colorsConst.greyClr),
//             actions: [
//               TextButton(
//                 onPressed: (){
//                   Navigator.pop(context);
//                 },
//                 child: CustomText(text:"Don't Allow",colors: colorsConst.appRed,isBold: true),
//               ),
//               TextButton(
//                 onPressed: () async {
//                   Navigator.pop(context);
//                   await FlutterForegroundTask.requestIgnoreBatteryOptimization();
//                 },
//                 child: CustomText(text:"Allow",colors: colorsConst.blueClr,isBold: true,),
//               ),
//             ],
//           ),
//         );
//       }
//     }
//   }
//   Future<void> _startTracking() async {
//     log("📍 Starting tracking...");
//
//     await _checkBatteryOptimization();
//
//     final storage = GetStorage();
//
//     /// ✅ Update values
//     await storage.write("Track", true);
//     await storage.write("TrackId", localData.storage.read("TrackId") ?? "0");
//     await storage.write("TrackUnitName", localData.storage.read("TrackUnitName") ?? "null");
//     await storage.write("TrackStatus", "1");
//
//     /// ✅ Delay to allow value flush
//     await Future.delayed(const Duration(milliseconds: 500));
//
//     /// ✅ Start the foreground task
//     await FlutterForegroundTask.startService(
//       notificationTitle: constValue.appName,
//       notificationText: 'Tracking is on',
//       callback: startCallbackDispatcher,
//     );
//
//     setState(() {
//       log("✅ Tracking started. Track=${storage.read("Track")}, Unit=${storage.read("TrackUnitName")}");
//     });
//   }
//   Future<void> _stopTracking() async {
//     await FlutterForegroundTask.stopService();
//     setState(() {
//       localData.storage.write("Track",false);
//       if (trackCtr.locationList.isNotEmpty) {
//         Provider.of<CustomerProvider>(context, listen: false).insertTrackList(trackCtr.locationList);
//         trackCtr.locationList.clear();
//         // print("Balance list added list cleared.");
//       }
//       Provider.of<CustomerProvider>(context, listen: false).actionTracking(context,"2");
//       // if(trackCtr.todayTrackReport.isEmpty){
//       //   /// New Changes
//       //   localData.storage.write("TrackId","0");
//       //   localData.storage.write("TrackStatus","2");
//       //   localData.storage.write("T_Shift","");
//       //   localData.storage.write("TrackUnitName","null");
//       // }
//       Navigator.of(context, rootNavigator: true).pop();
//       utils.showSuccessToast(context: context,text: "Tracking stopped");
//     });
//   }
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Consumer4<HomeProvider,CustomerProvider,AttendanceProvider,LocationProvider>(builder: (context,homeProvider,custProvider,attPvr,locPvr,_){
//       return SafeArea(
//         child: Scaffold(
//           backgroundColor: colorsConst.bacColor,
//           appBar: const PreferredSize(
//             preferredSize: Size(300, 50),
//             child: CustomAppbar(text: "Dashboard",isMain: true,),
//           ),
//           body: PopScope(
//               canPop: false,
//                   onPopInvoked: (bool pop){
//                       return utils.customDialog(
//                           context: context,
//                           callback: (){
//                             SystemNavigator.pop();}, title: "Do you want to Exit the App?");
//                     },
//               child: homeProvider.versionCheck==false
//                     ?const Center(child: Loading())
//                     :homeProvider.currentVersion!=""&&homeProvider.versionCheck==true&&
//                     homeProvider.versionActive==false?
//                      const UpdateApp()
//                     :Column(
//                       children: [
//                         // ElevatedButton(
//                         //   onPressed: getWebSafeLocation,
//                         //   child: Text("Get Location"),
//                         // ),
//                         Center(child: CustomText(text: "${greeting()} ${localData.storage.read("f_name")}",colors: colorsConst.primary,isBold: true,size: 15,)),
//                         10.height,
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Row(
//                               children: [
//                                 SvgPicture.asset(assets.calendar,width: 13,height: 13,),5.width,
//                                 CustomText(text: homeProvider.date)
//                               ],
//                             ),10.width,
//                             Row(
//                               children: [
//                                 SvgPicture.asset(assets.clock,width: 14,height: 14,),5.width,
//                                 CustomText(text: homeProvider.time)
//                               ],
//                             ),
//                           ],
//                         ),
//                         10.height,
//                         if(!kIsWeb&&localData.storage.read("role") !="1")
//                         GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               if (localData.storage.read("Track") == true) {
//                                 stopTracking(context);
//                               } else {
//                                 if(locPvr.latitude==""&&locPvr.longitude==""){
//                                   locPvr.manageLocation(context,true);
//                                 }else{
//                                   startTracking(context,locPvr.latitude,locPvr.longitude);
//                                 }
//                               }
//                             });
//                           },
//                           child: AnimatedContainer(
//                             duration: const Duration(milliseconds: 200),
//                             height: 30,
//                             width: 100,
//                             decoration: BoxDecoration(
//                               color: localData.storage.read("Track") == true
//                                   ? Colors.green
//                                   : Colors.grey,
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             child: Stack(
//                               children: [
//                                 Center(
//                                   child: CustomText(
//                                     text: localData.storage.read("Track") == true
//                                         ? 'ON     '
//                                         : '     Track Off',
//                                     size: 11, colors: Colors.white,
//                                   ),
//                                 ),
//                                 Align(
//                                   alignment: localData.storage.read("Track") ==
//                                       true ? Alignment.centerRight : Alignment
//                                       .centerLeft,
//                                   child: Container(
//                                     margin: const EdgeInsets.all(5),
//                                     width: 20,
//                                     height: 20,
//                                     decoration: const BoxDecoration(
//                                       color: Colors.white,
//                                       shape: BoxShape.circle,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),),
//                         Expanded(
//                           child: SizedBox(
//                             width: kIsWeb?MediaQuery.of(context).size.width*0.5:MediaQuery.of(context).size.width*0.9,
//                             child: ListView(
//                               shrinkWrap: true,
//                               children: [
//                                   Center(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         if(localData.storage.read("role")=="1")
//                                           const CustomText(text: "\n  Total Employees",isBold: true,size: 17,),5.height,
//                                         if(localData.storage.read("role")=="1")
//                                           SizedBox(
//                                             width: kIsWeb?MediaQuery.of(context).size.width*0.5:MediaQuery.of(context).size.width*0.85,
//                                             child: homeProvider.refresh==true&&homeProvider.roleEmp.isNotEmpty?
//                                             ListView.builder(
//                                                 shrinkWrap: true,
//                                                 physics: const NeverScrollableScrollPhysics(),
//                                                 itemCount: homeProvider.roleEmp.length,
//                                                 itemBuilder: (context,index){
//                                                   return SizedBox(
//                                                     height: 40,
//                                                     // color: Colors.yellow,
//                                                     child: Row(
//                                                       // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                       children: [
//                                                         8.width,
//                                                         SizedBox(
//                                                           // color: Colors.yellow,
//                                                             width: kIsWeb?MediaQuery.of(context).size.width*0.05:MediaQuery.of(context).size.width*0.2,
//                                                             child: CustomText(text: "${homeProvider.roleEmp[index]["role_name"]}",colors: colorsConst.greyClr,)),
//                                                         Column(
//                                                           children: [
//                                                             CustomText(text: homeProvider.roleEmp[index]["employee_count"],colors: colorsConst.greyClr,),
//                                                             SizedBox(
//                                                               height: 10,
//                                                               width: kIsWeb?MediaQuery.of(context).size.width*0.43:MediaQuery.of(context).size.width*0.55,
//                                                               // color: Colors.pink,
//                                                               child: SliderTheme(
//                                                                 data: SliderTheme.of(context).copyWith(
//                                                                   tickMarkShape: SliderTickMarkShape.noTickMark,
//                                                                   thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 3),
//                                                                   valueIndicatorShape: const PaddleSliderValueIndicatorShape(), // Shows the value on the thumb
//                                                                   valueIndicatorColor: Colors.red, // Color of the value indicator
//                                                                   valueIndicatorTextStyle: const TextStyle(color: Colors.white,fontSize: 20), // Text style for the value
//                                                                   trackHeight: 5,
//                                                                 ),
//                                                                 child: Slider(
//                                                                   value: double.parse(homeProvider.roleEmp[index]["employee_count"]),
//                                                                   min: -0.0,
//                                                                   max: homeProvider.roleEmpColor.length*10,
//                                                                   divisions: 10,
//                                                                   activeColor: homeProvider.roleEmpColor[index],
//                                                                   inactiveColor: homeProvider.roleEmpColor[index].withOpacity(0.2),
//                                                                   onChanged: (value) {
//                                                                     homeProvider.roleEmp[index]["employee_count"] = homeProvider.roleEmp[index]["employee_count"];
//                                                                   },
//                                                                   label: homeProvider.roleEmp[index]["employee_count"],
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         )
//                                                       ],
//                                                     ),
//                                                   );
//                                                 }):homeProvider.roleEmp.isEmpty?
//                                                 const Center(child: CustomText(text: "\nNo Employees Found\n"))
//                                                 :const SkeletonLoading(),
//                                           ),
//                                         if(localData.storage.read("role")!="1")
//                                           Column(
//                                             children: [
//                                               15.height,
//
//                                               15.height,
//                                             ],
//                                           ),
//                                         Center(
//                                           child: SizedBox(
//                                               width: kIsWeb?MediaQuery.of(context).size.width*0.489:MediaQuery.of(context).size.width*0.86,
//                                               child: const DotLine()),
//                                         ),
//                                         10.height,
//                                         if(localData.storage.read("role")=="1")
//                                         GestureDetector(
//                                           onTap: (){
//                                             homeProvider.updateIndex(4);
//                                             utils.navigatePage(context, ()=>const DashBoard(child: AttendanceReport()));
//                                           },
//                                           child: Container(
//                                             color: Colors.white,
//                                             height: 40,
//                                             width: kIsWeb?MediaQuery.of(context).size.width*0.489:MediaQuery.of(context).size.width*0.86,
//                                             child: Row(
//                                               mainAxisAlignment: MainAxisAlignment.center,
//                                               children: [
//                                                 CustomText(text: "Today Attendance",isBold: true,size: 16,colors: colorsConst.greyClr,),5.width,
//                                                 CustomText(size: 16,text: custProvider.mainReportList.isEmpty?"0":custProvider.mainReportList[0]["unique_attendance_count"].toString(),colors: colorsConst.appGreen,),
//                                                 const CustomText(text: " / ",size: 16,),
//                                                 CustomText(size: 16,text: custProvider.mainReportList.isEmpty?"0":custProvider.mainReportList[0]["total_user_count"].toString(),colors: colorsConst.primary,),
//                                               ],
//                                             ),
//                                           ),
//                                         ),5.height,
//                                         if(localData.storage.read("role")=="1")
//                                         GestureDetector(
//                                           onTap: (){
//                                             Provider.of<CustomerProvider>(context, listen: false).getDashboardReport(true);
//                                           },
//                                             child: const CustomText(text: "  Real-time Visits\n",isBold: true,size: 17,)),
//                                         if(localData.storage.read("role")=="1")
//                                         SizedBox(
//                                           width: MediaQuery.of(context).size.width*0.9,
//                                           child: custProvider.vRefresh==false?
//                                           const SkeletonLoading():custProvider.visitCount.isEmpty?
//                                           const Center(child: CustomText(text: "No Visits Found\n")):
//                                           ListView.builder(
//                                               shrinkWrap: true,
//                                               physics: const NeverScrollableScrollPhysics(),
//                                               itemCount: custProvider.visitCount.length,
//                                               itemBuilder: (context,index){
//                                                 return Column(
//                                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                                   mainAxisAlignment: MainAxisAlignment.start,
//                                                   children: [
//                                                     CustomText(text: "   ${custProvider.visitCount[index]["value"].toString().trim()}",colors: colorsConst.greyClr,),5.height,
//                                                     LinearPercentIndicator(
//                                                         lineHeight: 30.0,
//                                                         percent: (double.tryParse(custProvider.visitCount[index]["total_count"].toString()) ?? 0) / 100,
//                                                         center: CustomText(
//                                                           text: custProvider.visitCount[index]["total_count"],colors: Colors.black,
//                                                           isBold: true,
//                                                         ),
//                                                         backgroundColor: Colors.white,
//                                                         progressColor: colorsConst.appDarkGreen
//                                                     ),
//                                                     5.height,
//                                                   ],
//                                                 );
//                                               }),
//                                         ),
//                                         10.height,
//                                         if(localData.storage.read("role")=="1")
//                                         Center(
//                                           child: SizedBox(
//                                               width: kIsWeb?MediaQuery.of(context).size.width*0.489:MediaQuery.of(context).size.width*0.86,
//                                               child: const DotLine()),
//                                         ),
//                                         10.height,
//                                         // if(localData.storage.read("role")=="1")
//                                         // Padding(
//                                         //   padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
//                                         //   child: SizedBox(
//                                         //     // color: Colors.pinkAccent,
//                                         //     width: MediaQuery.of(context).size.width*0.9,
//                                         //     child: Row(
//                                         //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                         //       children: [
//                                         //         ElevatedButton(
//                                         //           onPressed: () {
//                                         //             homeProvider.updateIndex(2);
//                                         //             // homeProvider.showCusType(1);
//                                         //             // homeProvider.changeCusList();
//                                         //             homeProvider.showCusType(5);
//                                         //             homeProvider.changeCusList(companyId: "",companyName: "", customerList: [],isDirect:true,taskId: "0");
//                                         //           },
//                                         //           child: const CustomText(text: "Start New Visit",size: 12,colors: Colors.white,isBold: true,),
//                                         //         ),
//                                         //         ElevatedButton(
//                                         //           style: ElevatedButton.styleFrom(
//                                         //               backgroundColor: colorsConst.appOrg
//                                         //           ),
//                                         //           onPressed: () {
//                                         //             homeProvider.updateIndex(2);
//                                         //             homeProvider.showCusType(0);
//                                         //             homeProvider.changeCusList();
//                                         //           },
//                                         //           child: const CustomText(text: "Add Interaction",size: 12,colors: Colors.white,isBold: true,),
//                                         //         ),
//                                         //       ],
//                                         //     ),
//                                         //   ),
//                                         // ),
//                                         Padding(
//                                           padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
//                                           child: GestureDetector(
//                                             onTap: (){
//                                               homeProvider.updateIndex(10);
//                                               utils.navigatePage(context, ()=>const DashBoard(child: ViewAllTasks()));
//                                             },
//                                             child: Container(
//                                               color: Colors.white,
//                                               height: 140,
//                                               width: kIsWeb?MediaQuery.of(context).size.width*0.5:MediaQuery.of(context).size.width*0.85,
//                                               child: Padding(
//                                                 padding: const EdgeInsets.all(8.0),
//                                                 child: Column(
//                                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                                   children: [
//                                                     const CustomText(text: "Pending & Completed Tasks",isBold: true,size: 17,),
//                                                     Row(
//                                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                       children: [
//                                                         Container(
//                                                           width: kIsWeb?MediaQuery.of(context).size.width*0.23:MediaQuery.of(context).size.width*0.23,
//                                                           height: MediaQuery.of(context).size.width*0.2,
//                                                           decoration: customDecoration.baseBackgroundDecoration(
//                                                               color: colorsConst.vio,radius: 10
//                                                           ),
//                                                           child: Center(
//                                                             child: Column(
//                                                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                                               children: [
//                                                                 CustomText(text: localData.storage.read("role")=="1"?"Total":"Assigned"),
//                                                                 CustomText(text: custProvider.mainReportList.isEmpty?"0":custProvider.mainReportList[0]["total_tasks"],isBold: true,),5.height,
//                                                               ],
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         Container(
//                                                           width: kIsWeb?MediaQuery.of(context).size.width*0.23:MediaQuery.of(context).size.width*0.23,
//                                                           height: MediaQuery.of(context).size.width*0.2,
//                                                           decoration: customDecoration.baseBackgroundDecoration(
//                                                               color: colorsConst.sandal,radius: 10
//                                                           ),
//                                                           child: Center(
//                                                             child: Column(
//                                                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                                               children: [
//                                                                 CustomText(text: localData.storage.read("role")=="1"?"Pending":"New Task\nAssigned"),
//                                                                 CustomText(text: custProvider.mainReportList.isEmpty?"0":custProvider.mainReportList[0]["incomplete_count"],isBold: true,),5.height,
//                                                               ],
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         Container(
//                                                           width: kIsWeb?MediaQuery.of(context).size.width*0.23:MediaQuery.of(context).size.width*0.23,
//                                                           height: MediaQuery.of(context).size.width*0.2,
//                                                           decoration: customDecoration.baseBackgroundDecoration(
//                                                               color: colorsConst.lgreen,radius: 10
//                                                           ),
//                                                           child: Center(
//                                                             child: Column(
//                                                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                                               children: [
//                                                                 const CustomText(text: "Completed"),
//                                                                 CustomText(text: custProvider.mainReportList.isEmpty?"0":custProvider.mainReportList[0]["complete_count"],isBold: true,),5.height,
//                                                               ],
//                                                             ),
//                                                           ),
//                                                         )
//                                                       ],
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),20.height,
//                                         Center(
//                                           child: SizedBox(
//                                               width: kIsWeb?MediaQuery.of(context).size.width*0.489:MediaQuery.of(context).size.width*0.86,
//                                               child: const DotLine()),
//                                         ),
//                                         const CustomText(text: "\n  Pending Task Reports\n",isBold: true,size: 17,),
//                                         Padding(
//                                           padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
//                                           child: SizedBox(
//                                             // color: Colors.yellow,
//                                             width: kIsWeb?MediaQuery.of(context).size.width*0.5:MediaQuery.of(context).size.width*0.85,
//                                             child: Row(
//                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                               children: [
//                                                 Container(
//                                                   color: Colors.white,
//                                                   height: kIsWeb?MediaQuery.of(context).size.width*0.5:MediaQuery.of(context).size.width*0.2,
//                                                   width: kIsWeb?MediaQuery.of(context).size.width*0.5:MediaQuery.of(context).size.width*0.4,
//                                                   child: Column(
//                                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                                     children: [
//                                                       CircleAvatar(
//                                                         backgroundColor: Colors.grey.shade300,
//                                                         radius: 15,
//                                                         child: CustomText(text: custProvider.mainReportList.isEmpty?"0":custProvider.mainReportList[0]["pending_expense_report_count"],isBold: true,),),
//                                                       const CustomText(text: "Expense Report")
//                                                     ],
//                                                   ),
//                                                 ),
//                                                 Container(
//                                                   color: Colors.white,
//                                                   height: kIsWeb?MediaQuery.of(context).size.width*0.5:MediaQuery.of(context).size.width*0.2,
//                                                   width: kIsWeb?MediaQuery.of(context).size.width*0.5:MediaQuery.of(context).size.width*0.4,
//                                                   child: Column(
//                                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                                     children: [
//                                                       CircleAvatar(
//                                                         backgroundColor: Colors.grey.shade300,
//                                                         radius: 15,
//                                                         child: CustomText(text: custProvider.mainReportList.isEmpty?"0":custProvider.mainReportList[0]["pending_visit_count"],isBold: true,),),
//                                                       const CustomText(text: "Visit Report")
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                         20.height,
//                                         Center(
//                                           child: SizedBox(
//                                               width: kIsWeb?MediaQuery.of(context).size.width*0.489:MediaQuery.of(context).size.width*0.86,
//                                               child: const DotLine()),
//                                         ),
//                                         GestureDetector(
//                                           onTap: (){
//                                             homeProvider.updateIndex(9);
//                                             utils.navigatePage(context, ()=>const DashBoard(child: ViewExpense()));
//                                           },
//                                           child: Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               const CustomText(text: "\n  Expense Reports\n",isBold: true,size: 17,),
//                                               Padding(
//                                                 padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
//                                                 child: SizedBox(
//                                                   // color: Colors.yellow,
//                                                   width: kIsWeb?MediaQuery.of(context).size.width*0.5:MediaQuery.of(context).size.width*0.85,
//                                                   child: Row(
//                                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                     children: [
//                                                       Row(
//                                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                                         children: [
//                                                           const CustomText(text: "Total"),5.width,
//                                                           CustomText(text: custProvider.mainReportList.isEmpty?"0":custProvider.mainReportList[0]["total_expense_count"],isBold: true,),5.height,
//                                                         ],
//                                                       ), Row(
//                                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                                         children: [
//                                                           CustomText(text: "Approved",colors: colorsConst.lgreen),5.width,
//                                                           CustomText(text: custProvider.mainReportList.isEmpty?"0":custProvider.mainReportList[0]["approved_expense_count"],isBold: true,),5.height,
//                                                         ],
//                                                       ),
//                                                       Row(
//                                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                                         children: [
//                                                           CustomText(text: "Pending",colors: colorsConst.greyClr),5.width,
//                                                           CustomText(text: custProvider.mainReportList.isEmpty?"0":custProvider.mainReportList[0]["pending_expense_count"],isBold: true,),5.height,
//                                                         ],
//                                                       ),
//                                                       Row(
//                                                         children: [
//                                                           CustomText(text: "Rejected",colors: colorsConst.appRed),5.width,
//                                                           CustomText(text: custProvider.mainReportList.isEmpty?"0":custProvider.mainReportList[0]["rejected_expense_count"],isBold: true,),5.height,
//                                                         ],
//                                                       )
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         20.height,
//                                         if(localData.storage.read("role")=="1")
//                                           Center(
//                                           child: SizedBox(
//                                               width: kIsWeb?MediaQuery.of(context).size.width*0.489:MediaQuery.of(context).size.width*0.86,
//                                               child: const DotLine()),
//                                       ),
//                                       ],
//                                     ),
//                                   ),
//                                   10.height,
//                                   if(localData.storage.read("role")=="1")
//                                   SizedBox(
//                                     // color: Colors.pink,
//                                     width: MediaQuery.of(context).size.width*0.9,
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         GestureDetector(
//                                           onTap: (){
//                                             homeProvider.updateIndex(3);
//                                             utils.navigatePage(context, ()=>const DashBoard(child: CorrectionReport()));
//                                           },
//                                             child: Row(
//                                               children: [
//                                                 SvgPicture.asset(assets.tracking),5.width,
//                                                 const CustomText(text: "Track Report",size: 12),
//                                               ],
//                                             )),
//                                         TextButton(
//                                           onPressed: () {
//                                             homeProvider.updateIndex(5);
//                                             utils.navigatePage(context, ()=>const DashBoard(child: ReportDashboard()));
//                                           },
//                                           child: Row(
//                                             children: [
//                                               SvgPicture.asset(assets.rep),5.width,
//                                               const CustomText(text: "Reports",size: 12,)
//                                             ],
//                                           ),
//                                         ),
//                                         TextButton(
//                                           onPressed: () {  },
//                                           child: Row(
//                                             children: [
//                                               SvgPicture.asset(assets.notify),5.width,
//                                               const CustomText(text: "Notifications",size: 12)
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   // :Padding(
//                                   //   padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
//                                   //   child: SizedBox(
//                                   //     width: MediaQuery.of(context).size.width*0.9,
//                                   //     child: Row(
//                                   //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   //       children: [
//                                   //         ElevatedButton(
//                                   //           onPressed: () {
//                                   //             homeProvider.updateIndex(2);
//                                   //             // homeProvider.showCusType(1);
//                                   //             // homeProvider.changeCusList();
//                                   //             homeProvider.showCusType(5);
//                                   //             homeProvider.changeCusList(companyId: "",companyName: "", customerList: [],isDirect:true,taskId: "0");
//                                   //           },
//                                   //           child: const CustomText(text: "Start New Visit",size: 12,colors: Colors.white,isBold: true,),
//                                   //         ),
//                                   //         ElevatedButton(
//                                   //           style: ElevatedButton.styleFrom(
//                                   //               backgroundColor: colorsConst.appOrg
//                                   //           ),
//                                   //           onPressed: () {
//                                   //             homeProvider.updateIndex(2);
//                                   //             homeProvider.showCusType(0);
//                                   //             homeProvider.changeCusList();
//                                   //           },
//                                   //           child: const CustomText(text: "Add Interaction",size: 12,colors: Colors.white,isBold: true,),
//                                   //         ),
//                                   //       ],
//                                   //     ),
//                                   //   ),
//                                   // ),
//                                   25.height,
//                               ],
//                             ),
//                           ),
//                         )
//                       ],
//                     )
//           ),
//         ),
//       );
//     });
//   }
//   String getTimeDifferenceFrom(String timeString) {
//     final now = DateTime.now();
//
//     // Parse time string like "2:20 PM"
//     final regex = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false);
//     final match = regex.firstMatch(timeString.trim());
//
//     if (match == null) return 'Invalid time format';
//
//     int hour = int.parse(match.group(1)!);
//     int minute = int.parse(match.group(2)!);
//     String period = match.group(3)!.toUpperCase();
//
//     // Convert to 24-hour format
//     if (period == 'PM' && hour != 12) hour += 12;
//     if (period == 'AM' && hour == 12) hour = 0;
//
//     final customTime = DateTime(now.year, now.month, now.day, hour, minute);
//
//     final difference = now.difference(customTime);
//
//     if (difference.isNegative) {
//       return 'Time is in the future';
//     }
//
//     final hours = difference.inHours;
//     final minutes = difference.inMinutes % 60;
//     final seconds = difference.inSeconds % 60;
//
//     return '$hours : $minutes';
//   }
//   String getTimeDifferenceBetween(String time1, String time2) {
//     DateTime now = DateTime.now();
//
//     DateTime? parseTime(String timeStr) {
//       final regex = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false);
//       final match = regex.firstMatch(timeStr.trim());
//
//       if (match == null) return null;
//
//       int hour = int.parse(match.group(1)!);
//       int minute = int.parse(match.group(2)!);
//       String period = match.group(3)!.toUpperCase();
//
//       // Convert to 24-hour format
//       if (period == 'PM' && hour != 12) hour += 12;
//       if (period == 'AM' && hour == 12) hour = 0;
//
//       return DateTime(now.year, now.month, now.day, hour, minute);
//     }
//
//     DateTime? dt1 = parseTime(time1);
//     DateTime? dt2 = parseTime(time2);
//
//     if (dt1 == null || dt2 == null) return 'Invalid time format';
//
//     Duration difference = dt1.difference(dt2).abs();
//
//     int hours = difference.inHours;
//     int minutes = difference.inMinutes % 60;
//     // int seconds = difference.inSeconds % 60;
//
//     return '$hours : $minutes';
//   }
//
//
//   Future<void> getWebSafeLocation() async {
//     try {
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.low, // 👈 Web-safe
//       );
//
//       print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
//     } catch (e) {
//       print("❌ Error fetching location: $e");
//     }
//   }
//
//   String greeting() {
//     var hour = DateTime.now().hour;
//     if (hour < 12) {
//       return 'Good Morning,';
//     }
//     if (hour < 17) {
//       return 'Good Afternoon,';
//     }
//     return 'Good Evening,';
//   }
// }
//
// class MyTaskHandler extends TaskHandler {
//   DateTime updateTs=DateTime.now();
//   DateTime updateServerTs=DateTime.now();
//
//   // @override
//   // Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
//   //   await GetStorage.init();
//   //   print("✅ Tracking started");
//   // }
//   @override
//   Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
//     // await GetStorage.init();
//     final storage = GetStorage();
//     log("✅ Tracking started in background task");
//     log("📦 Task Read: Track=${storage.read("Track")}, Unit=${storage.read("TrackUnitName")}");
//   }
//
//
//   @override
//   Future<void> onDestroy(DateTime timestamp) async {
//     updateTs=DateTime.now();
//     updateServerTs=DateTime.now();
//     log("🛑 Tracking stopped");
//     final storage = GetStorage();
//     storage.write("wasTracking", true);
//   }
//
//   @override
//   void onNotificationPressed() {
//     FlutterForegroundTask.launchApp();
//   }
//
//   @override
//   @override
//   void onRepeatEvent(DateTime timestamp) async {
//     // await GetStorage.init();
//     log("**** OnRepeat Start {${localData.storage.read("TrackUnitName")}}");
//
//     bool result = isMoreThan5Seconds(updateTs);
//     bool serverResult = isMoreThanOneMinute(updateServerTs);
//
//     if (result) {
//       log("5 seconds passed ${DateTime.now().hour} ${DateTime.now().minute} ${DateTime.now().second}");
//       try {
//         Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high,
//         );
//         // double speedInKmph = position.speed * 3.6;
//
//         trackCtr.locationList.add({
//           "emp_id":localData.storage.read("id"),
//           "unit_id": localData.storage.read("TrackId"),
//           "unit_name": localData.storage.read("TrackUnitName"),
//           "date": "${DateTime.now().day.toString().padLeft(2, "0")}-${DateTime.now().month.toString().padLeft(2, "0")}-${DateTime.now().year}",
//           "shift": "",
//           "status": localData.storage.read("TrackStatus"),
//           "lat": position.latitude,
//           "lng": position.longitude,
//           "created_ts": DateTime.now().toString(),
//           "speed": position.speed.toStringAsFixed(2)
//         });
//         log("📍 OnStart Location (${DateTime.now()})");
//       } catch (e) {
//         log("⚠️ Location error: $e");
//       }
//       updateTs = DateTime.now();
//     }
//
//     if (serverResult) {
//       log("One minute passed ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}");
//       if (trackCtr.locationList.isNotEmpty) {
//         try {
//           final Map<String, dynamic> data = {
//             "action": trackListInsert,
//             "empList": trackCtr.locationList,
//           };
//
//           final response = await http.post(
//             Uri.parse(phpFile),
//             headers: {'Content-Type': 'application/json'},
//             body: jsonEncode(data),
//           );
//           log(response.body);
//           if (response.statusCode == 200) {
//             log("✅ Location uploaded");
//             trackCtr.locationList.clear();
//           } else {
//             log("❌ Upload failed: ${response.statusCode}");
//           }
//         } catch (e) {
//           log("⚠️ Upload error: $e");
//         }
//       }
//       updateServerTs = DateTime.now();
//     }
//   }
//   bool isMoreThan5Seconds(DateTime customTime) {
//     DateTime currentTime = DateTime.now();
//     Duration difference = currentTime.difference(customTime);
//     return difference.inSeconds > 5;
//   }
//   bool isMoreThanOneMinute(DateTime customTime) {
//     DateTime currentTime = DateTime.now();
//     Duration difference = currentTime.difference(customTime);
//     return difference.inSeconds > 60;
//   }
// }