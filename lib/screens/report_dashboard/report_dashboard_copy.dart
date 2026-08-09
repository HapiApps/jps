// import 'package:aci/screens/common/dashboard.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:provider/provider.dart';
// import 'package:aci/component/custom_loading.dart';
// import 'package:aci/screens/report_dashboard/visit_box.dart';
// import 'package:aci/source/constant/local_data.dart';
// import 'package:aci/source/extentions/extensions.dart';
// import 'package:aci/view_model/customer_provider.dart';
// import 'package:aci/view_model/employee_provider.dart';
// import 'package:aci/view_model/report_provider.dart';
// import '../../component/custom_appbar.dart';
// import '../../component/custom_text.dart';
// import '../../component/map_dropdown.dart';
// import '../../model/user_model.dart';
// import '../../source/constant/assets_constant.dart';
// import '../../source/constant/colors_constant.dart';
// import '../../source/constant/default_constant.dart';
// import '../../source/styles/decoration.dart';
// import '../../source/utilities/utils.dart';
// import '../../view_model/home_provider.dart';
// import '../common/home_page.dart';
//
// class ReportDashboard extends StatefulWidget {
//
//   const ReportDashboard({super.key,});
//
//   @override
//   State<ReportDashboard> createState() => _ReportDashboardState();
// }
//
// class _ReportDashboardState extends State<ReportDashboard> {
//   final ScrollController scrollController=ScrollController();
//   final ScrollController scrollController1=ScrollController();
//   @override
//   void initState() {
//     Future.delayed(Duration.zero, () {
//       Provider.of<ReportProvider>(context, listen: false).initValue();
//       Provider.of<ReportProvider>(context, listen: false).getReport1();
//       Provider.of<ReportProvider>(context, listen: false).getReport2();
//       Provider.of<ReportProvider>(context, listen: false).getReport4();
//       if(localData.storage.read("role")!="1"){
//         Provider.of<ReportProvider>(context, listen: false).getReport3(localData.storage.read("id"));
//       }
//     });
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     var webHeight=MediaQuery.of(context).size.width * 0.5;
//     var phoneHeight=MediaQuery.of(context).size.width * 0.9;
//     return Consumer4<ReportProvider,EmployeeProvider,CustomerProvider,HomeProvider>(builder: (context,repProvider,
//         empProvider,cusPr,homeProvider,_){
//       return Scaffold(
//       backgroundColor: colorsConst.bacColor,
//       appBar: PreferredSize(
//         preferredSize: const Size(300, 50),
//         child: CustomAppbar(text: constValue.reportDashboard,callback: (){
//           homeProvider.updateIndex(0);
//           utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
//         }),
//       ),
//       body:PopScope(
//         canPop: false,
//         onPopInvoked: (bool didPop) {
//           homeProvider.updateIndex(0);
//           if (!didPop) {
//             utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
//           }
//         },
//         child: SingleChildScrollView(
//           child: Center(
//             child: SizedBox(
//               width: kIsWeb?webHeight:phoneHeight,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   10.height,
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       InkWell(
//                         onTap: () {
//                           repProvider.datePick(
//                             context: context,
//                             isStartDate: true, function: () {
//                             repProvider.getReport1();
//                           },
//                           );
//                         },
//                         child: Container(
//                           height: 30,
//                           width: kIsWeb?MediaQuery.of(context).size.width*0.15:MediaQuery.of(context).size.width * 0.24,
//                           decoration: customDecoration.baseBackgroundDecoration(
//                             color: Colors.white,
//                             radius: 5,
//                             borderColor: colorsConst.litGrey,
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               CustomText(text: repProvider.startDate,size: 12,),
//                               5.width,
//                               SvgPicture.asset(assets.calendar2),
//                             ],
//                           ),
//                         ),
//                       ),
//                       Container(
//                         height: 30,
//                         width: kIsWeb?MediaQuery.of(context).size.width*0.17:MediaQuery.of(context).size.width * 0.33,
//                         decoration: customDecoration.baseBackgroundDecoration(
//                           radius: 5,
//                           color: Colors.white,
//                           borderColor: colorsConst.litGrey,
//                         ),
//                         child: DropdownButton(
//                           iconEnabledColor: colorsConst.greyClr,
//                           isExpanded: true,
//                           underline: const SizedBox(),
//                           icon: const Icon(Icons.keyboard_arrow_down_outlined),
//                           value: repProvider.type,
//                           onChanged: (value) {
//                             repProvider.changeType(value);
//                           },
//                           items: repProvider.typeList.map((list) {
//                             return DropdownMenuItem(
//                               value: list,
//                               child: CustomText(
//                                 text: "  $list",
//                                 colors: Colors.black,
//                                 isBold: false,
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                       InkWell(
//                         onTap: () {
//                           repProvider.showCustomMonthPicker(
//                             context: context,
//                             function: (){
//                                repProvider.getReport1();
//                             },
//                           );
//                         },
//                         child: Container(
//                           height: 30,
//                           width: kIsWeb?MediaQuery.of(context).size.width*0.15:MediaQuery.of(context).size.width * 0.25,
//                           decoration: customDecoration.baseBackgroundDecoration(
//                             color: Colors.white,
//                             radius: 5,
//                             borderColor: colorsConst.litGrey,
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               CustomText(text: repProvider.month,size: 12,),
//                               5.width,
//                               SvgPicture.asset(assets.calendar2),
//                             ],
//                           ),
//                         ),
//                       )
//                     ],
//                   ),10.height,
//                   repProvider.refresh1==false?const Loading():
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       VisitCard(
//                         color: colorsConst.blueClr,
//                         image: assets.chart, text: 'Total Visits',text2: '${repProvider.report1.isEmpty?"0":repProvider.report1[0]["total_count"]}',
//                         isFirst: true,
//                         widget2: const Text(""),),10.width,
//                       // VisitCard(
//                       //     color: colorsConst.appDarkGreen,
//                       //     image: localData.storage.read("role")=="1"?assets.thumb:assets.completed, text: localData.storage.read("role")=="1"?'${constValue.customer} Feedback':'Completed Visit',text2: '${repProvider.report1.isEmpty?"0":repProvider.report1[0]["positive_count"]}% Positive',
//                       //     text3: "Based on ${cusPr.filterCustomerData.length} ${cusPr.filterCustomerData.length==1||cusPr.filterCustomerData.isEmpty?constValue.customer:"${constValue.customer}s"}"),10.width,
//                       // if(localData.storage.read("role")!="1")
//                       // VisitCard(
//                       //     color: localData.storage.read("role")=="1"?colorsConst.orangeColor:colorsConst.appRed,
//                       //     image: localData.storage.read("role")=="1"?assets.emp:assets.pending, text: localData.storage.read("role")=="1"?'Active Employees':'Revisit',text2: '${repProvider.report1.isEmpty?"0":localData.storage.read("role")=="1"?repProvider.report1[0]["date_count"]:int.parse(repProvider.report1[0]["total_count"])-int.parse(repProvider.report1[0]["positive_count"])}',
//                       //     text3: localData.storage.read("role")=="1"?
//                       //     "Out of ${repProvider.report1.isEmpty?"0":repProvider.report1[0]["total_emp_count"]} total"
//                       //     :"Based on ${cusPr.filterCustomerData.length}  ${cusPr.filterCustomerData.length==1||cusPr.filterCustomerData.isEmpty?constValue.customer:"${constValue.customer}s"}"),10.width,
//                       // VisitCard(
//                       //     color: colorsConst.violet,
//                       //     image: assets.visit, text: 'Average Visit Time',text2: '1.5 hours',
//                       //     text3: "Per interaction"),
//                     ],
//                   ),
//                   10.height,
//                   Container(
//                     decoration: customDecoration.baseBackgroundDecoration(
//                         color: Colors.white,radius: 10
//                     ),
//                     height: 270,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         10.height,
//                         CustomText(text: "    Total Visits\n",isBold: true,size: 17,colors: colorsConst.primary,),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             if(localData.storage.read("role")=="1")
//                             EmployeeDropdown(
//                               callback: (){
//                                 empProvider.getAllUsers();
//                               },
//                               text: repProvider.user==null?"Employee Name":"",
//                               employeeList: empProvider.assignEmployees,
//                               onChanged: (UserModel? value) {
//                                 repProvider.selectUser(value!);
//                               },
//                               size: kIsWeb?MediaQuery.of(context).size.width*0.23:MediaQuery.of(context).size.width*0.37,),
//                             Padding(
//                               padding: EdgeInsets.fromLTRB(0, empProvider.assignEmployees.isEmpty?20:0, 0, 0),
//                               child: Container(
//                                 height: 40,
//                                 width: localData.storage.read("role")=="1"&&kIsWeb?
//                               MediaQuery.of(context).size.width * 0.23:
//                                 localData.storage.read("role")=="1"&&!kIsWeb?MediaQuery.of(context).size.width * 0.37:kIsWeb?MediaQuery.of(context).size.width * 0.45:MediaQuery.of(context).size.width * 0.8,
//                                 decoration: customDecoration.baseBackgroundDecoration(
//                                   radius: 10,
//                                   color: Colors.white,
//                                   borderColor: colorsConst.litGrey,
//                                 ),
//                                 child: DropdownButton(
//                                   iconEnabledColor: colorsConst.greyClr,
//                                   isExpanded: true,
//                                   underline: const SizedBox(),
//                                   icon: const Icon(Icons.keyboard_arrow_down_outlined),
//                                   value: repProvider.type3,
//                                   onChanged: (value) {
//                                     repProvider.changeType3(value);
//                                   },
//                                   items: repProvider.typeList3.map((list) {
//                                     return DropdownMenuItem(
//                                       value: list,
//                                       child: CustomText(
//                                         text: "  $list",
//                                         colors: Colors.black,
//                                         isBold: false,
//                                       ),
//                                     );
//                                   }).toList(),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         repProvider.user==null&&localData.storage.read("role")=="1"?
//                         Center(child: CustomText(text: "\n\nSelect User Name",colors: colorsConst.greyClr,)):
//                         repProvider.refresh3==false?const Padding(
//                           padding: EdgeInsets.all(50.0),
//                           child: Loading(),
//                         ):
//                         repProvider.report3.isEmpty||(repProvider.report3.length==1&&repProvider.report3[0].totalAttendance==0)?
//                         Center(child: CustomText(text: "\n\nNo data found",colors: colorsConst.greyClr,)):
//                         Padding(
//                           padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
//                           child: SizedBox(
//                             height: 145,
//                             // color: Colors.grey,
//                             child: Scrollbar(
//                               controller: scrollController1,
//                               thumbVisibility: true,
//                               trackVisibility: true,
//                               child: SingleChildScrollView(
//                                 scrollDirection: Axis.horizontal,
//                                 controller: scrollController1,
//                                 child: SizedBox(
//                                   width: repProvider.barGroups.length * 40, // Adjust based on bar count
//                                   // child: BarChart(
//                                   //   BarChartData(
//                                   //     barTouchData: barTouchData,
//                                   //     titlesData: repProvider.titlesData,
//                                   //     borderData: repProvider.borderData,
//                                   //     barGroups: repProvider.barGroups,
//                                   //     gridData: const FlGridData(show: false),
//                                   //     alignment: BarChartAlignment.spaceAround,
//                                   //     // groupsSpace:2
//                                   //   ),
//                                   // ),
//                                   child: Stack(
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
//                                         child: BarChart(
//                                           BarChartData(
//                                             barTouchData: barTouchData,
//                                             titlesData: repProvider.titlesData,
//                                             borderData: repProvider.borderData,
//                                             barGroups: repProvider.barGroups,
//                                             gridData: const FlGridData(show: false),
//                                             alignment: BarChartAlignment.spaceAround,
//                                           ),
//                                         ),
//                                       ),
//                                       Positioned.fill(
//                                         child: LayoutBuilder(
//                                           builder: (context, constraints) {
//                                             const barSpacing = 20.0; // or your custom spacing
//                                             return Row(
//                                               mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                               children: List.generate(repProvider.barGroups.length, (index) {
//                                                 final yValue = repProvider.barGroups[index].barRods[0].toY;
//                                                 return SizedBox(
//                                                   width: barSpacing,
//                                                   child: Column(
//                                                     children: [
//                                                       CustomText(
//                                                         text:yValue.round().toString()=="0"?"":yValue.round().toString(),colors: colorsConst.primary,
//                                                       ),
//                                                       5.height,
//                                                     ],
//                                                   ),
//                                                 );
//                                               }),
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   10.height,
//                   // Container(
//                   //   // height: 350,
//                   //   decoration: const BoxDecoration(
//                   //       color: Colors.white,
//                   //       borderRadius: BorderRadius.only(
//                   //           topLeft: Radius.circular(10),
//                   //           topRight: Radius.circular(10)
//                   //       )
//                   //   ),
//                   //   child: Padding(
//                   //     padding: const EdgeInsets.fromLTRB(5, 15, 5, 0),
//                   //     child: Column(
//                   //       crossAxisAlignment: CrossAxisAlignment.start,
//                   //       children: [
//                   //         CustomText(text: "Visits Status\n",isBold: true,size: 17,colors: colorsConst.primary,),
//                   //         Row(
//                   //           crossAxisAlignment: CrossAxisAlignment.start,
//                   //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   //           children: [
//                   //             InkWell(
//                   //               onTap: () {
//                   //                 repProvider.datePick2(
//                   //                   context: context,
//                   //                 );
//                   //               },
//                   //               child: Container(
//                   //                 height: 30,
//                   //                 width: kIsWeb?MediaQuery.of(context).size.width * 0.15:MediaQuery.of(context).size.width * 0.22,
//                   //                 decoration: customDecoration.baseBackgroundDecoration(
//                   //                   color: Colors.white,
//                   //                   radius: 5,
//                   //                   borderColor: colorsConst.litGrey,
//                   //                 ),
//                   //                 child: Row(
//                   //                   mainAxisAlignment: MainAxisAlignment.center,
//                   //                   children: [
//                   //                     CustomText(text: repProvider.startDate2,size: 11,),
//                   //                     SvgPicture.asset(assets.calendar2),
//                   //                   ],
//                   //                 ),
//                   //               ),
//                   //             ),
//                   //             Container(
//                   //               height: 30,
//                   //               width: kIsWeb?MediaQuery.of(context).size.width * 0.17:MediaQuery.of(context).size.width * 0.33,
//                   //               decoration: customDecoration.baseBackgroundDecoration(
//                   //                 radius: 5,
//                   //                 color: Colors.white,
//                   //                 borderColor: colorsConst.litGrey,
//                   //               ),
//                   //               child: DropdownButton(
//                   //                 iconEnabledColor: colorsConst.greyClr,
//                   //                 isExpanded: true,
//                   //                 underline: const SizedBox(),
//                   //                 icon: const Icon(Icons.keyboard_arrow_down_outlined),
//                   //                 value: repProvider.type2,
//                   //                 onChanged: (value) {
//                   //                   repProvider.changeType2(value);
//                   //                 },
//                   //                 items: repProvider.typeList2.map((list) {
//                   //                   return DropdownMenuItem(
//                   //                     value: list,
//                   //                     child: CustomText(
//                   //                       text: "  $list",
//                   //                       colors: Colors.black,
//                   //                       isBold: false,
//                   //                     ),
//                   //                   );
//                   //                 }).toList(),
//                   //               ),
//                   //             ),
//                   //             InkWell(
//                   //               onTap: () {
//                   //                 repProvider.showCustomMonthPicker2(
//                   //                   context: context,
//                   //                   function: (){
//                   //                     repProvider.getReport2();
//                   //                   },
//                   //                 );
//                   //               },
//                   //               child: Container(
//                   //                 height: 30,
//                   //                 width: kIsWeb?MediaQuery.of(context).size.width * 0.15:MediaQuery.of(context).size.width * 0.25,
//                   //                 decoration: customDecoration.baseBackgroundDecoration(
//                   //                   color: Colors.white,
//                   //                   radius: 5,
//                   //                   borderColor: colorsConst.litGrey,
//                   //                 ),
//                   //                 child: Row(
//                   //                   mainAxisAlignment: MainAxisAlignment.center,
//                   //                   children: [
//                   //                     CustomText(text: repProvider.month2,size: 12,),
//                   //                     5.width,
//                   //                     SvgPicture.asset(assets.calendar2),
//                   //                   ],
//                   //                 ),
//                   //               ),
//                   //             )
//                   //           ],
//                   //         ),
//                   //         repProvider.refresh2==false?const Padding(
//                   //           padding: EdgeInsets.all(50.0),
//                   //           child: Loading(),
//                   //         ):
//                   //         repProvider.report2.isNotEmpty&&repProvider.report2[0]["positive_count"].toString()=="0"&&
//                   //             repProvider.report2[0]["negative_count"].toString()=="0"?
//                   //         Center(child: CustomText(text: "\n\nNo data found\n\n\n\n",colors: colorsConst.greyClr,)):
//                   //         const PieChartSample2(),
//                   //       ],
//                   //     ),
//                   //   ),
//                   // ),
//                   // 10.height,
//                   ///
//                   // if(localData.storage.read("role")=="1")
//                   // Container(
//                   //   decoration: const BoxDecoration(
//                   //       color: Colors.white,
//                   //     borderRadius: BorderRadius.only(
//                   //       topLeft: Radius.circular(10),
//                   //       topRight: Radius.circular(10)
//                   //     )
//                   //   ),
//                   //   child: Padding(
//                   //     padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
//                   //     child: Column(
//                   //       crossAxisAlignment: CrossAxisAlignment.start,
//                   //       children: [
//                   //         10.height,
//                   //         CustomText(text: "Active Employees",colors: colorsConst.primary,isBold: true,size: 17,),15.height,
//                   //         Row(
//                   //           crossAxisAlignment: CrossAxisAlignment.start,
//                   //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   //           children: [
//                   //             InkWell(
//                   //               onTap: () {
//                   //                 repProvider.datePick4(
//                   //                   context: context,
//                   //                 );
//                   //               },
//                   //               child: Container(
//                   //                 height: 30,
//                   //                 width: MediaQuery.of(context).size.width * 0.22,
//                   //                 decoration: customDecoration.baseBackgroundDecoration(
//                   //                   color: Colors.white,
//                   //                   radius: 5,
//                   //                   borderColor: colorsConst.litGrey,
//                   //                 ),
//                   //                 child: Row(
//                   //                   mainAxisAlignment: MainAxisAlignment.center,
//                   //                   children: [
//                   //                     CustomText(text: repProvider.startDate4,size: 11,),
//                   //                     SvgPicture.asset(assets.calendar2),
//                   //                   ],
//                   //                 ),
//                   //               ),
//                   //             ),
//                   //             Container(
//                   //               height: 30,
//                   //               width: MediaQuery.of(context).size.width * 0.33,
//                   //               decoration: customDecoration.baseBackgroundDecoration(
//                   //                 radius: 5,
//                   //                 color: Colors.white,
//                   //                 borderColor: colorsConst.litGrey,
//                   //               ),
//                   //               child: DropdownButton(
//                   //                 iconEnabledColor: colorsConst.greyClr,
//                   //                 isExpanded: true,
//                   //                 underline: const SizedBox(),
//                   //                 icon: const Icon(Icons.keyboard_arrow_down_outlined),
//                   //                 value: repProvider.type4,
//                   //                 onChanged: (value) {
//                   //                   repProvider.changeType4(value);
//                   //                 },
//                   //                 items: repProvider.typeList.map((list) {
//                   //                   return DropdownMenuItem(
//                   //                     value: list,
//                   //                     child: CustomText(
//                   //                       text: "  $list",
//                   //                       colors: Colors.black,
//                   //                       isBold: false,
//                   //                     ),
//                   //                   );
//                   //                 }).toList(),
//                   //               ),
//                   //             ),
//                   //             InkWell(
//                   //               onTap: () {
//                   //                 repProvider.showCustomMonthPicker4(
//                   //                   context: context,
//                   //                   function: (){
//                   //                     repProvider.getReport4();
//                   //                   },
//                   //                 );
//                   //               },
//                   //               child: Container(
//                   //                 height: 30,
//                   //                 width: MediaQuery.of(context).size.width * 0.25,
//                   //                 decoration: customDecoration.baseBackgroundDecoration(
//                   //                   color: Colors.white,
//                   //                   radius: 5,
//                   //                   borderColor: colorsConst.litGrey,
//                   //                 ),
//                   //                 child: Row(
//                   //                   mainAxisAlignment: MainAxisAlignment.center,
//                   //                   children: [
//                   //                     CustomText(text: repProvider.month4,size: 12,),
//                   //                     5.width,
//                   //                     SvgPicture.asset(assets.calendar2),
//                   //                   ],
//                   //                 ),
//                   //               ),
//                   //             )
//                   //           ],
//                   //         ),15.height,
//                   //       ],
//                   //     ),
//                   //   ),
//                   // ),
//                   // if(localData.storage.read("role")=="1")
//                   // Container(
//                   //   height: 300,
//                   //   decoration: const BoxDecoration(
//                   //       color: Colors.white,
//                   //       borderRadius: BorderRadius.only(
//                   //           bottomLeft: Radius.circular(10),
//                   //           bottomRight: Radius.circular(10)
//                   //       )
//                   //   ),
//                   //   child: repProvider.refresh4==false?
//                   //       const Loading()
//                   //   :repProvider.report4.isNotEmpty?
//                   //   SizedBox(
//                   //       height: 300,
//                   //       child: LineChart(
//                   //         LineChartData(
//                   //           minY: 0,
//                   //           maxY: 100,
//                   //           backgroundColor: Colors.white,
//                   //           borderData: FlBorderData(show: false),
//                   //           titlesData: FlTitlesData(
//                   //             leftTitles: AxisTitles(
//                   //               sideTitles: SideTitles(
//                   //                 showTitles: true,
//                   //                 interval: 25,
//                   //                 getTitlesWidget: (value, meta) {
//                   //                   return CustomText(text:'${value.toInt()}',colors: Colors.grey,size: 12,);
//                   //                 },
//                   //               ),
//                   //             ),
//                   //             rightTitles: const AxisTitles(
//                   //               sideTitles: SideTitles(showTitles: false),
//                   //             ),
//                   //             topTitles: const AxisTitles(
//                   //               sideTitles: SideTitles(showTitles: false),
//                   //             ),
//                   //             // bottomTitles: AxisTitles(
//                   //             //   sideTitles: SideTitles(
//                   //             //     showTitles: true,
//                   //             //     getTitlesWidget: (value, meta) {
//                   //             //       // You can add custom text here for each tick mark
//                   //             //       return Padding(
//                   //             //         padding: const EdgeInsets.only(top: 8.0),
//                   //             //         child: Text(
//                   //             //           '$value', // Replace with your dynamic text
//                   //             //           style: TextStyle(fontSize: 12, color: Colors.grey),
//                   //             //         ),
//                   //             //       );
//                   //             //     },
//                   //             //   ),
//                   //             // ),
//                   //             bottomTitles: AxisTitles(
//                   //               sideTitles: SideTitles(
//                   //                 showTitles: true,
//                   //                 getTitlesWidget: (value, meta) {
//                   //                   // List of custom values for each tick on the bottom axis
//                   //
//                   //                   // Use the value (the index of the tick) to map to the custom label
//                   //                   int index = value.toInt(); // Get the index (e.g., 0 for Jan, 1 for Feb)
//                   //                   if (index >= 0 && index < repProvider.flText.length) {
//                   //                     return Padding(
//                   //                       padding: const EdgeInsets.only(top: 8.0),
//                   //                       child: Text(
//                   //                         repProvider.flText[index], // Display corresponding value from the list
//                   //                         style: const TextStyle(fontSize: 12, color: Colors.grey),
//                   //                       ),
//                   //                     );
//                   //                   }
//                   //                   return Container(); // Return empty if no label is available for the index
//                   //                 },
//                   //               ),
//                   //             ),
//                   //           ),
//                   //           gridData: FlGridData(
//                   //             show: true,
//                   //             drawHorizontalLine: true,
//                   //             drawVerticalLine: false,
//                   //             horizontalInterval: 25,
//                   //             getDrawingHorizontalLine: (value) => FlLine(
//                   //               color: Colors.grey.withOpacity(0.3),
//                   //               strokeWidth: 1,
//                   //               dashArray: [4, 4], // [dash length, space length]
//                   //             ),
//                   //           ),
//                   //           lineBarsData: [
//                   //             LineChartBarData(
//                   //               spots: repProvider.flSpot,
//                   //               isCurved: false,
//                   //               barWidth: 2,
//                   //             ),
//                   //           ],
//                   //         ),
//                   //       )
//                   //   )
//                   //   : Center(child: CustomText(text: "\n\nNo employees found",colors: colorsConst.greyClr)),
//                   // ),
//                   20.height,
//                   // Container(
//                   //   decoration: customDecoration.baseBackgroundDecoration(
//                   //       color: Colors.white,radius: 10
//                   //   ),
//                   //   child: Padding(
//                   //     padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
//                   //     child: Column(
//                   //       crossAxisAlignment: CrossAxisAlignment.start,
//                   //       children: [
//                   //         10.height,
//                   //         CustomText(text: "Average Visit Time",colors: colorsConst.primary,isBold: true,size: 17,),15.height,
//                   //         Row(
//                   //           crossAxisAlignment: CrossAxisAlignment.start,
//                   //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   //           children: [
//                   //             InkWell(
//                   //               onTap: () {
//                   //                 repProvider.datePick(
//                   //                   context: context,
//                   //                   isStartDate: true, function: () {  },
//                   //                 );
//                   //               },
//                   //               child: Container(
//                   //                 height: 30,
//                   //                 width: MediaQuery.of(context).size.width * 0.22,
//                   //                 decoration: customDecoration.baseBackgroundDecoration(
//                   //                   color: Colors.white,
//                   //                   radius: 5,
//                   //                   borderColor: colorsConst.litGrey,
//                   //                 ),
//                   //                 child: Row(
//                   //                   mainAxisAlignment: MainAxisAlignment.center,
//                   //                   children: [
//                   //                     CustomText(text: repProvider.startDate,size: 11,),
//                   //                     SvgPicture.asset(assets.calendar2),
//                   //                   ],
//                   //                 ),
//                   //               ),
//                   //             ),
//                   //             Container(
//                   //               height: 30,
//                   //               width: MediaQuery.of(context).size.width * 0.33,
//                   //               decoration: customDecoration.baseBackgroundDecoration(
//                   //                 radius: 5,
//                   //                 color: Colors.white,
//                   //                 borderColor: colorsConst.litGrey,
//                   //               ),
//                   //               child: DropdownButton(
//                   //                 iconEnabledColor: colorsConst.greyClr,
//                   //                 isExpanded: true,
//                   //                 underline: const SizedBox(),
//                   //                 icon: const Icon(Icons.keyboard_arrow_down_outlined),
//                   //                 value: repProvider.type,
//                   //                 onChanged: (value) {
//                   //                   repProvider.changeType(value);
//                   //                 },
//                   //                 items: repProvider.typeList.map((list) {
//                   //                   return DropdownMenuItem(
//                   //                     value: list,
//                   //                     child: CustomText(
//                   //                       text: "  $list",
//                   //                       colors: Colors.black,
//                   //                       isBold: false,
//                   //                     ),
//                   //                   );
//                   //                 }).toList(),
//                   //               ),
//                   //             ),
//                   //             InkWell(
//                   //               onTap: () {
//                   //                 repProvider.showCustomMonthPicker(
//                   //                   context: context,
//                   //                   function: (){
//                   //                     // attendanceServices.getMonthlyReport();
//                   //                   },
//                   //                 );
//                   //               },
//                   //               child: Container(
//                   //                 height: 30,
//                   //                 width: MediaQuery.of(context).size.width * 0.23,
//                   //                 decoration: customDecoration.baseBackgroundDecoration(
//                   //                   color: Colors.white,
//                   //                   radius: 5,
//                   //                   borderColor: colorsConst.litGrey,
//                   //                 ),
//                   //                 child: Row(
//                   //                   mainAxisAlignment: MainAxisAlignment.center,
//                   //                   children: [
//                   //                     CustomText(text: repProvider.month,size: 12,),
//                   //                     5.width,
//                   //                     SvgPicture.asset(assets.calendar2),
//                   //                   ],
//                   //                 ),
//                   //               ),
//                   //             )
//                   //           ],
//                   //         ),15.height,
//                   //         const EmployeeTable(),
//                   //       ],
//                   //     ),
//                   //   )),
//                   // 20.height
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//           );
//     });
//   }
//
//   BarTouchData get barTouchData => BarTouchData(
//     enabled: false,
//     touchTooltipData: BarTouchTooltipData(
//       getTooltipColor: (group) => Colors.transparent,
//       tooltipPadding: EdgeInsets.zero,
//       tooltipMargin: 2,
//       getTooltipItem: (
//           BarChartGroupData group,
//           int groupIndex,
//           BarChartRodData rod,
//           int rodIndex,
//           ) {
//         return BarTooltipItem(
//           rod.toY.round().toString(),
//           const TextStyle(
//             color: Colors.transparent,
//             fontSize: 0,
//           ),
//         );
//       },
//     ),
//   );
//
// }
//
// class MonthReport {
//   // String? totalAttendance;
//   int? totalAttendance;
//   String? date;
//   String? leaveCount;
//   MonthReport({
//     this.totalAttendance,
//     this.date,
//     this.leaveCount
//   });
//   factory MonthReport.fromJson(Map<String, dynamic> json){
//     return MonthReport(
//       // totalAttendance: json["total_attendance"],
//         totalAttendance: int.tryParse(json["complete_count"] ?? '0'),
//         date:json["formatted_date"],
//         leaveCount:json["not_complete_count"]?? '0'
//     );
//   }
// }