// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:group_button/group_button.dart';
// import 'package:intl/intl.dart';
// import 'package:master_code/source/extentions/extensions.dart';
// import 'package:master_code/source/utilities/utils.dart';
// import 'package:provider/provider.dart';
// import '../../component/custom_appbar.dart';
// import '../../component/custom_loading.dart';
// import '../../component/custom_text.dart';
// import '../../component/custom_textfield.dart';
// import '../../model/leave/leave_model.dart';
// import '../../source/constant/colors_constant.dart';
// import '../../source/constant/default_constant.dart';
// import '../../source/constant/key_constant.dart';
// import '../../source/constant/local_data.dart';
// import '../../source/styles/decoration.dart';
// import '../../view_model/leave_provider.dart';
// import 'apply_leave.dart';
// import 'leave_details.dart';
//
// class ViewMyLeaves extends StatefulWidget {
//   final String? date1;
//   final String? date2;
//   const ViewMyLeaves({super.key,  this.date1,  this.date2});
//
//   @override
//   State<ViewMyLeaves> createState() => _ViewMyLeavesState();
// }
//
// class _ViewMyLeavesState extends State<ViewMyLeaves> {
//   final FocusScopeNode _myFocusScopeNode = FocusScopeNode();
//
//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp){
//       Provider.of<LeaveProvider >(context, listen: false).initDate(widget.date1!,widget.date2!);
//       // Provider.of<LeaveProvider >(context, listen: false).iniValues3();
//       if(localData.storage.read("role")!="1"){
//         Provider.of<LeaveProvider >(context, listen: false).getLeaveTypes();
//       }
//       // Provider.of<LeaveProvider >(context, listen: false).getLeaves();
//     });
//     super.initState();
//   }
//   @override
//   void dispose() {
//     super.dispose();
//     _myFocusScopeNode.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     var webWidth=MediaQuery.of(context).size.width*0.7;
//     var phoneWidth=MediaQuery.of(context).size.width*0.95;
//     return Consumer<LeaveProvider>(builder: (context,levProvider,_){
//       return FocusScope(
//         node: _myFocusScopeNode,
//         child: SafeArea(
//           child: Scaffold(
//             backgroundColor: colorsConst.bacColor,
//             appBar: PreferredSize(
//               preferredSize: Size(300, 50),
//               child: CustomAppbar(text: localData.storage.read("role") == "1"? "Leave Report"
//                   : "My Leaves",
//                 callback: (){
//                   levProvider.changePage();
//                   _myFocusScopeNode.unfocus();
//                 },
//                 isButton: localData.storage.read("role") != "1"?true:false,
//                 buttonCallback: () {
//                   _myFocusScopeNode.unfocus();
//                   utils.navigatePage(context, ()=>const ApplyLeave());
//                 },
//               ),
//             ),
//             body: PopScope(
//               canPop: localData.storage.read("role") == "1" ? false : true,
//               onPopInvoked: (bool pop) async {
//                 if (localData.storage.read("role") == "1") {
//                   levProvider.changePage();
//                 }
//                 _myFocusScopeNode.unfocus();
//               },
//               child: Center(
//                 child: Column(
//                   children: [
//                     15.height,
//                     SizedBox(
//                       width: kIsWeb?webWidth:phoneWidth,
//                       child: GroupButton(
//                         isRadio: true,
//                         controller: levProvider.groupController,
//                         options: GroupButtonOptions(
//                             borderRadius: BorderRadius.circular(20),
//                             spacing: 10,
//                             elevation: 0.5,
//                             buttonHeight: 30,
//                             selectedColor: colorsConst.primary,
//                             unselectedColor: Colors.white,
//                             unselectedTextStyle: TextStyle(
//                                 color: colorsConst.greyClr
//                             ),
//                             unselectedBorderColor: Colors.white
//                         ),
//                         onSelected: (name, index, isSelected) {
//                           levProvider.changeReportType(name.toString());
//                           levProvider.search.clear();
//                         },
//                         buttons: levProvider.reportList,
//                       ),
//                     ),
//                     10.height,
//                     Container(
//                       height: 50,
//                       decoration: customDecoration.baseBackgroundDecoration(
//                           color: Colors.white,
//                           radius: 10,
//                           borderColor: Colors.grey.shade300
//                       ),
//                       width: kIsWeb?webWidth:phoneWidth,
//                       child: Padding(
//                           padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
//                           child: levProvider.report == "Today" ?
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               Row(
//                                 children: [
//                                   InkWell(
//                                     onTap: () {
//                                       levProvider.decrementDates();
//                                     },
//                                     child: Icon(
//                                       Icons.arrow_back_ios_new_outlined, size: 20,
//                                       color: colorsConst.greyClr,),
//                                   ),
//                                   10.width,
//                                   InkWell(
//                                     onTap: () {
//                                       levProvider.customPick(context: context);
//                                     },
//                                     child: Row(
//                                       children: [
//                                         CustomText(text: levProvider.date1,
//                                             colors: colorsConst.primary,
//                                             size: 14),
//                                       ],
//                                     ),
//                                   ),
//                                   10.width,
//                                   InkWell(
//                                     onTap: () {
//                                       levProvider.incrementDates();
//                                     },
//                                     child: Icon(
//                                       Icons.arrow_forward_ios_outlined, size: 20,
//                                       color: colorsConst.greyClr,),
//                                   ),
//                                 ],
//                               ),
//                               CustomText(text: levProvider.levCount1,
//                                 colors: colorsConst.primary,
//                                 isBold: true,)
//                             ],
//                           ) :
//                           levProvider.report == "  This Week  " ?
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               Row(
//                                 children: [
//                                   InkWell(
//                                     onTap: () {
//                                       levProvider.decrementWeek();
//                                     },
//                                     child: Icon(
//                                       Icons.arrow_back_ios_new_outlined, size: 20,
//                                       color: colorsConst.greyClr,),
//                                   ),
//                                   10.width,
//                                   Row(
//                                     children: [
//                                       CustomText(text: levProvider.showDate3,
//                                           colors: colorsConst.primary,
//                                           size: 14),
//                                       CustomText(text: "  To  ",
//                                           colors: colorsConst.greyClr,
//                                           size: 14),
//                                       CustomText(text: levProvider.showDate4,
//                                           colors: colorsConst.primary,
//                                           size: 14),
//                                     ],
//                                   ),
//                                   10.width,
//                                   InkWell(
//                                     onTap: () {
//                                       levProvider.incrementWeek();
//                                     },
//                                     child: Icon(
//                                       Icons.arrow_forward_ios_outlined, size: 20,
//                                       color: colorsConst.greyClr,),
//                                   ),
//                                 ],
//                               ),
//                               CustomText(text: levProvider.levCount2,
//                                 colors: colorsConst.primary,
//                                 isBold: true,)
//                             ],
//                           ) :
//                           levProvider.report == "  This month  " ?
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 children: [
//                                   InkWell(
//                                     onTap: () {
//                                       levProvider.decrementMonth();
//                                     },
//                                     child: Icon(
//                                       Icons.arrow_back_ios_new_outlined, size: 20,
//                                       color: colorsConst.greyClr,),
//                                   ),
//                                   10.width,
//                                   GestureDetector(
//                                     onTap: () {
//                                       levProvider.showCustomMonthPicker(
//                                         context: context,
//                                       );
//                                     },
//                                     child: Row(
//                                       children: [
//                                         Icon(
//                                           Icons.calendar_today, size: 15,
//                                           color: colorsConst.primary,), 10.width,
//                                         CustomText(text: levProvider.month,
//                                             colors: colorsConst.primary,
//                                             size: 14),
//                                       ],
//                                     ),
//                                   ),
//                                   10.width,
//                                   InkWell(
//                                     onTap: () {
//                                       levProvider.incrementMonth();
//                                     },
//                                     child: Icon(
//                                       Icons.arrow_forward_ios_outlined, size: 20,
//                                       color: colorsConst.greyClr,),
//                                   ),
//                                 ],
//                               ),
//                               CustomText(text: levProvider.levCount3,
//                                 colors: colorsConst.primary,
//                                 isBold: true,)
//                             ],
//                           ) :
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               InkWell(
//                                 onTap: () {
//                                   levProvider.showDatePickerCalendar(context);
//                                 },
//                                 child: Row(
//                                   children: [
//                                     Icon(
//                                       Icons.calendar_today, size: 15,color: colorsConst.primary,), 2.width,
//                                     CustomText(text: "${levProvider.showDate7==""?"Start Date":levProvider.showDate7} To ${levProvider.showDate8==""?"End Date":levProvider.showDate8}",),
//                                   ],
//                                 ),
//                               ),
//                               CustomText(text: levProvider.levCount4,
//                                 colors: colorsConst.primary,
//                                 isBold: true,)
//                             ],
//                           )
//                       ),
//                     ),
//                     // 5.height,
//                     if(localData.storage.read("role") == "1")
//                     CustomTextField(
//                         text: "",
//                         controller: levProvider.search,
//                         keyboardType: TextInputType.text,
//                         inputFormatters: constInputFormatters.numTextInput,
//                         textInputAction: TextInputAction.done,
//                         width: kIsWeb?webWidth:phoneWidth,
//                         hintText: "Search Name",
//                         isIcon: true,
//                         iconData: Icons.search,
//                         isShadow: true,
//                         onChanged: (value) {
//                           levProvider.searchReport(value.toString());
//                         },
//                         isSearch: levProvider.search.text.isNotEmpty?true:false,
//                         searchCall: (){
//                           levProvider.search.clear();
//                           levProvider.searchReport("");
//                         },
//                       ),
//                     levProvider.report == "Today" ?
//                     levProvider.isLoading == false ?
//                     const Padding(
//                       padding: EdgeInsets.fromLTRB(0, 150, 0, 0),
//                       child: Loading(),
//                     )
//                     : levProvider.myLevSearch.isEmpty ?
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
//                       child: CustomText(
//                         text: constValue.noData, colors: colorsConst.greyClr,),)
//                     : Flexible(
//                       child: itemBuilder(levProvider.myLevSearch),
//                     ) :
//                     levProvider.report == "  This Week  " ?
//                     levProvider.isLoading2 == false ?
//                     const Padding(
//                       padding: EdgeInsets.fromLTRB(0, 150, 0, 0),
//                       child: Loading(),
//                     )
//                     : levProvider.myLev2Search.isEmpty ?
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
//                       child: CustomText(
//                         text: constValue.noData, colors: colorsConst.greyClr,),)
//                     : Flexible(
//                       child: itemBuilder(levProvider.myLev2Search),
//                     ) :
//                     levProvider.report == "  This month  " ?
//                     levProvider.isLoading3 == false ?
//                     const Padding(
//                       padding: EdgeInsets.fromLTRB(0, 150, 0, 0),
//                       child: Loading(),
//                     )
//                     : levProvider.myLev3Search.isEmpty ?
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
//                       child: CustomText(
//                         text: constValue.noData, colors: colorsConst.greyClr,),)
//                     : Flexible(
//                       child: itemBuilder(levProvider.myLev3Search),
//                     ) :
//                     levProvider.isLoading4 == false ?
//                     const Padding(
//                       padding: EdgeInsets.fromLTRB(0, 150, 0, 0),
//                       child: Loading(),
//                     )
//                     :levProvider.myLev4Search.isEmpty ?
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
//                       child: CustomText(
//                         text: constValue.noData, colors: colorsConst.greyClr,),)
//                         : Flexible(
//                       child: itemBuilder(levProvider.myLev4Search),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//   }
//   String getCreatedDate(data) {
//     final timestamp = data.createdTs.toString();
//     final dateTime = DateTime.parse(timestamp);
//     return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
//   }
//   Widget itemBuilder(List<LeaveModel> dataList){
//     var webWidth=MediaQuery.of(context).size.width*0.7;
//     var phoneWidth=MediaQuery.of(context).size.width*0.95;
//     return ListView.builder(
//         itemCount: dataList.length,
//         itemBuilder: (context,index){
//           final sortedData = dataList;
//           sortedData.sort((a, b) =>
//               a.startDate!.compareTo(b.startDate.toString()));
//           final data = sortedData[index];
//           var createdBy = "";
//           String timestamp = data.createdTs.toString();
//           DateTime dateTime = DateTime.parse(timestamp);
//           String dayOfWeek = DateFormat('EEEE').format(dateTime);
//           DateTime today = DateTime.now();
//           if (dateTime.day == today.day && dateTime.month == today.month && dateTime.year == today.year) {
//             dayOfWeek = 'Today';
//           } else if (dateTime.isAfter(today.subtract(const Duration(days: 1))) &&
//               dateTime.isBefore(today)) {
//             dayOfWeek = 'Yesterday';
//           } else {
//             dayOfWeek = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
//           }
//           createdBy = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
//           final showDateHeader = index == 0 || createdBy != getCreatedDate(sortedData[index - 1]);
//           var st = DateTime.parse(data.startDate.toString());
//           var date1 = "${st.day.toString().padLeft(2,"0")}/${st.month.toString().padLeft(2,"0")}/${st.year}";
//           var date2="";
//           if(data.startDate.toString()!=data.endDate.toString()&&data.endDate.toString()!=""){
//             var en = DateTime.parse(data.endDate.toString());
//             // print(data.endDate.toString());
//             date2 = "${en.day.toString().padLeft(2,"0")}/${en.month.toString().padLeft(2,"0")}/${en.year}";
//           }
//           return SizedBox(
//             width: kIsWeb?webWidth:phoneWidth,
//             child: Column(
//               children: [
//                 if(index==0)
//                   10.height,
//                 if (showDateHeader)
//                   SizedBox(
//                     width: kIsWeb?webWidth:phoneWidth,
//                     child: Column(
//                       children: [
//                         10.height,
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             CustomText(
//                               text: dayOfWeek,
//                               colors: colorsConst.greyClr
//                             ),
//                           ],
//                         ),
//                         10.height,
//                       ],
//                     ),
//                   ),
//                 InkWell(
//                   onTap: (){
//                     utils.navigatePage(context, ()=>LeaveDetails(empId: data.userId.toString(), name: data.fName.toString(), role: data.role.toString(),));
//                   },
//                   child: Container(
//                     width: kIsWeb?webWidth:phoneWidth,
//                     // height: 75,
//                     decoration: customDecoration.baseBackgroundDecoration(
//                       radius: 5,
//                       color: Colors.white,
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           5.height,
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               CustomText(
//                                 text: data.type.toString(),
//                                 colors: colorsConst.greyClr,
//                               ),
//                               if(data.creater.toString()!=data.fName.toString())
//                                 Row(
//                                   children: [
//                                     CustomText(
//                                     text: "Added By  ",
//                                     colors: colorsConst.greyClr,
//                                       ),
//                                     CustomText(
//                                       text: "${data.creater.toString()} ( HR )",
//                                       colors: colorsConst.primary,
//                                     ),
//                                   ],
//                                 ),
//                               // CustomText(
//                               //   text: time,
//                               //   colors: colorsConst.greyClr,
//                               // ),
//                             ],
//                           ),
//                           5.height,
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   CustomText(
//                                     text: data.fName.toString(),
//                                     isBold: true,
//                                     size: 15,
//                                     colors: colorsConst.shareColor,
//                                   ),
//                                   5.width,
//                                   CustomText(
//                                     text: data.role.toString(),
//                                     size: 13,
//                                     colors: Colors.black,
//                                   ),
//                                 ],
//                               ),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   CustomText(
//                                     text: "$date1${date2!=""?" To $date2":""}",
//                                     size: 13,
//                                     colors: Colors.black,
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           5.height,
//                           CustomText(
//                             text: "Requested for ${data.dayType.toString()=="0.5"?"Half":data.dayCount} ${data.dayCount.toString()=="1"?"day":"days"} leave ${data.dayType.toString()=="0.5"&&data.session.toString()!="null"?"( ${data.session.toString()} )":""}",
//                             colors: colorsConst.greyClr,
//                           ),
//                           5.height,
//                           CustomText(
//                             text: data.reason.toString(),
//                             colors: colorsConst.stateColor.withOpacity(0.7),
//                           ),
//                           5.height,
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 5.height,
//                 if(index==dataList.length-1)
//                 80.height,
//               ],
//             ),
//           );
//         });
//   }
// }
