import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:master_code/screens/attendance/user_attendance_report.dart';
import 'package:master_code/screens/common/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:master_code/component/custom_dropdown.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:master_code/source/utilities/excel_reports.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:master_code/view_model/leave_provider.dart';
import 'package:provider/provider.dart';
import 'package:master_code/view_model/home_provider.dart';
import '../../component/animated_button.dart';
import '../../component/attendance_detail.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../component/map_dropdown.dart';
import '../../model/attendance_model.dart';
import '../../model/leave/leave_model.dart';
import '../../model/user_model.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/constant/local_data.dart';
import '../../source/styles/decoration.dart';
import '../../view_model/attendance_provider.dart';
import '../../view_model/employee_provider.dart';
import '../common/check_location.dart';
import '../common/dashboard.dart';
import '../leave_management/leave_report.dart';
import 'custom_attendance_report.dart';

class AttendanceReport extends StatefulWidget {
  final String date1;
  final String date2;
  final String type;
  final String showType;
  final List<UserModel> empList;
  const AttendanceReport({super.key,required this.date1, required this.date2, required this.type, required this.showType, required this.empList});

  @override
  State<AttendanceReport> createState() => _AttendanceReportState();
}

class _AttendanceReportState extends State<AttendanceReport> {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();
  late String showType;
  @override
  void initState() {
    showType = widget.showType;
    check();
    Future.delayed(Duration.zero, () {
      print("attendance report init ${widget.type}");
      if (!mounted) return;
      print(Provider.of<EmployeeProvider>(context, listen: false).userData.length);
      Provider.of<AttendanceProvider>(context, listen: false).initDate(id:localData.storage.read("id"),role:localData.storage.read("role"),isRefresh:true,date1:widget.date1,date2:widget.date2,type:widget.type);
      Provider.of<AttendanceProvider>(context, listen: false).getAttendanceReport(localData.storage.read("id"),localData.storage.read("role"),false,isAbsent: showType=="Absent"?true:false,isLate: showType=="Late"?true:false,list: widget.empList);
    });
    super.initState();
  }
void check(){
  setState(() {
    if(showType=="0"){
      Provider.of<AttendanceProvider>(context, listen: false).selectedIndex=0;
    }else if(showType=="Absent"){
      Provider.of<AttendanceProvider>(context, listen: false).selectedIndex=1;
    }else if(showType=="Late"){
      Provider.of<AttendanceProvider>(context, listen: false).selectedIndex=2;
    }else if(showType=="Leave"){
      Provider.of<AttendanceProvider>(context, listen: false).selectedIndex=3;
    }else{
      Provider.of<AttendanceProvider>(context, listen: false).selectedIndex=4;
    }
  });
}
  var reportTypeList = [
    "All",
    "Present",
    "Absent",
    "Late",
    "Leave",
    "Permission",
  ];
  @override
  void dispose() {
    _myFocusScopeNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.95;
    return Consumer4<AttendanceProvider,EmployeeProvider,HomeProvider,LeaveProvider>(builder: (context,attProvider,empProvider,homeProvider,levPvr,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
              preferredSize: const Size(300, 50),
              child: CustomAppbar(text: showType.toString()=="Absent"?"Absent Report":showType.toString()=="Late"?"Late Attendance Report":"Attendance Report",callback: (){
                homeProvider.updateIndex(0);
                _myFocusScopeNode.unfocus();
                utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
              }),
            ),
            body: PopScope(
              canPop: false,
              onPopInvoked: (bool didPop) {
                homeProvider.updateIndex(0);
                _myFocusScopeNode.unfocus();
                if (!didPop) {
                  utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
                }
              },
              child: Center(
                child: SizedBox(
                  width: kIsWeb?webWidth:phoneWidth,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // if(showType.toString()!="Absent"&&showType.toString()!="Late")
                        if(localData.storage.read("role")=="1")
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: kIsWeb?webWidth/1.2:phoneWidth/1.2,
                                decoration: customDecoration.baseBackgroundDecoration(
                                  radius: 30,
                                  color: colorsConst.primary,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: showType.toString()=="Absent"?phoneWidth/1.24:phoneWidth/1.5,
                                      height: 45,
                                      decoration: customDecoration.baseBackgroundDecoration(
                                        radius: 30,
                                        color: Colors.transparent,
                                      ),
                                      child: TextFormField(
                                        cursorColor: colorsConst.primary,
                                        onChanged: (value) {
                                          if(showType=="Present"||showType=="Permission"){
                                            attProvider.searchAttendanceReport(value.toString());
                                          }else if(showType=="Absent"){
                                            attProvider.searchAttendanceReport2(value.toString());
                                          }else if(showType=="Late"){
                                            attProvider.searchAttendanceReport3(value.toString());
                                          }else{
                                            levPvr.searchReport(value.toString());
                                          }
                                          },
                                        textInputAction: TextInputAction.done,
                                        controller: attProvider.search,
                                        decoration: InputDecoration(
                                            hintText:"Search Name or ${constValue.customer}",
                                            hintStyle: TextStyle(
                                                color: colorsConst.primary,
                                                fontSize: 14
                                            ),
                                            fillColor: Colors.white,
                                            filled: true,
                                            prefixIcon: Icon(Icons.search,color: Colors.grey,),
                                            suffixIcon: attProvider.search.text.isNotEmpty?
                                            GestureDetector(
                                                onTap: (){
                                                  attProvider.search.clear();
                                                  if(showType=="Present"||showType=="Permission"){
                                                    attProvider.searchAttendanceReport("");
                                                  }else if(showType=="Absent"){
                                                    attProvider.searchAttendanceReport2("");
                                                  }else if(showType=="Late"){
                                                    attProvider.searchAttendanceReport3("");
                                                  }else{
                                                    levPvr.searchReport("");
                                                  }
                                                  },
                                                child: Container(
                                                    width: 10,height: 10,color: Colors.transparent,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: SvgPicture.asset(assets.cancel2),
                                                    ))):null,
                                            errorStyle: const TextStyle(
                                              fontSize: 12.0,
                                              height: 0.20,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              // grey.shade300
                                                borderSide:  BorderSide(color: Colors.grey.shade300),
                                                borderRadius: BorderRadius.circular(30)
                                            ),
                                            contentPadding:const EdgeInsets.fromLTRB(10, 10, 10, 10)
                                        ),
                                      ),
                                    ),
                                    if(showType.toString()!="Absent")
                                    InkWell(
                                      onTap: (){
                                        // _myFocusScopeNode.unfocus();
                                        // if (!attProvider.typeList.any((e) => e['value'] == 'All')) {
                                        //   attProvider.typeList.insert(0, {
                                        //     "id": "",
                                        //     "value": "All",
                                        //   });
                                        // }
                                        // showDialog(
                                        //   context: context,
                                        //   builder: (context) {
                                        //     return Consumer3<attProvider,CustomerProvider,EmployeeProvider>(
                                        //       builder: (context, attProvider,cusPvr,empProvider, _) {
                                        //         return AlertDialog(
                                        //           actions: [
                                        //             SizedBox(
                                        //               width: kIsWeb?MediaQuery.of(context).size.width*0.3:MediaQuery.of(context).size.width*0.9,
                                        //               child: Column(
                                        //                 crossAxisAlignment: CrossAxisAlignment.start,
                                        //                 children: [
                                        //                   20.height,
                                        //                   Row(
                                        //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        //                     children: [
                                        //                       70.width,
                                        //                       const CustomText(
                                        //                         text: 'Filters',
                                        //                         colors: Colors.black,
                                        //                         size: 16,
                                        //                         isBold: true,
                                        //                       ),
                                        //                       30.width,
                                        //                       InkWell(
                                        //                         onTap: () {
                                        //                           Navigator.of(context, rootNavigator: true).pop();
                                        //                         },
                                        //                         child: SvgPicture.asset(assets.cancel),
                                        //                       )
                                        //                     ],
                                        //                   ),
                                        //                   20.height,
                                        //                   Row(
                                        //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        //                     children: [
                                        //                       Column(
                                        //                         crossAxisAlignment: CrossAxisAlignment.start,
                                        //                         children: [
                                        //                           CustomText(
                                        //                             text: "From Date",
                                        //                             colors: colorsConst.greyClr,
                                        //                             size: 12,
                                        //                           ),
                                        //                           InkWell(
                                        //                             onTap: () {
                                        //                               attProvider.filterPick(
                                        //                                 context: context,
                                        //                                 isStartDate: true,
                                        //                                 date: attProvider.startDate,
                                        //                               );
                                        //                             },
                                        //                             child: Container(
                                        //                               height: 30,
                                        //                               width: kIsWeb?webHeight/2.8:phoneHeight/2.8,
                                        //                               decoration: customDecoration.baseBackgroundDecoration(
                                        //                                 color: Colors.white,
                                        //                                 radius: 5,
                                        //                                 borderColor: colorsConst.litGrey,
                                        //                               ),
                                        //                               child: Row(
                                        //                                 mainAxisAlignment: MainAxisAlignment.center,
                                        //                                 children: [
                                        //                                   CustomText(text: attProvider.startDate),
                                        //                                   5.width,
                                        //                                   SvgPicture.asset(assets.calendar2),
                                        //                                 ],
                                        //                               ),
                                        //                             ),
                                        //                           )
                                        //                         ],
                                        //                       ),
                                        //                       Column(
                                        //                         crossAxisAlignment: CrossAxisAlignment.start,
                                        //                         children: [
                                        //                           CustomText(
                                        //                             text: "To Date",
                                        //                             colors: colorsConst.greyClr,
                                        //                             size: 12,
                                        //                           ),
                                        //                           InkWell(
                                        //                             onTap: () {
                                        //                               attProvider.filterPick(
                                        //                                 context: context,
                                        //                                 isStartDate: false,
                                        //                                 date: attProvider.endDate,
                                        //                               );
                                        //                             },
                                        //                             child: Container(
                                        //                               height: 30,
                                        //                               width: kIsWeb?webHeight/2.8:phoneHeight/2.8,
                                        //                               decoration: customDecoration.baseBackgroundDecoration(
                                        //                                 color: Colors.white,
                                        //                                 radius: 5,
                                        //                                 borderColor: colorsConst.litGrey,
                                        //                               ),
                                        //                               child: Row(
                                        //                                 mainAxisAlignment: MainAxisAlignment.center,
                                        //                                 children: [
                                        //                                   CustomText(text: attProvider.endDate),
                                        //                                   5.width,
                                        //                                   SvgPicture.asset(assets.calendar2),
                                        //                                 ],
                                        //                               ),
                                        //                             ),
                                        //                           )
                                        //                         ],
                                        //                       ),
                                        //                     ],
                                        //                   ),
                                        //                   10.height,
                                        //                   Column(
                                        //                     crossAxisAlignment: CrossAxisAlignment.start,
                                        //                     children: [
                                        //                       CustomText(
                                        //                         text: "Select Date Range",
                                        //                         colors: colorsConst.greyClr,
                                        //                         size: 12,
                                        //                       ),
                                        //                       Container(
                                        //                           height: 30,
                                        //                           width: kIsWeb?webHeight:phoneHeight,
                                        //                           decoration: customDecoration.baseBackgroundDecoration(
                                        //                             radius: 5,
                                        //                             color: Colors.white,
                                        //                             borderColor: colorsConst.litGrey,
                                        //                           ),
                                        //                           child: DropdownButton<String>(
                                        //                             value: attProvider.filterTypeList
                                        //                                 .contains(attProvider.filterType)
                                        //                                 ? attProvider.filterType
                                        //                                 : null,
                                        //                             isExpanded: true,
                                        //                             underline: const SizedBox(),
                                        //                             icon: const Icon(Icons.keyboard_arrow_down_outlined),
                                        //                             iconEnabledColor: colorsConst.greyClr,
                                        //                             onChanged: (value) {
                                        //                               if (value != null) {
                                        //                                 attProvider.changeFilterType(value);
                                        //                               }
                                        //                             },
                                        //                             items: attProvider.filterTypeList
                                        //                                 .toSet() // removes duplicates
                                        //                                 .map<DropdownMenuItem<String>>((list) {
                                        //                               return DropdownMenuItem<String>(
                                        //                                 value: list,
                                        //                                 child: CustomText(
                                        //                                   text: "  $list",
                                        //                                   colors: Colors.black,
                                        //                                   isBold: false,
                                        //                                 ),
                                        //                               );
                                        //                             }).toList(),
                                        //                           )
                                        //                       ),
                                        //                     ],
                                        //                   ),
                                        //                   10.height,
                                        //                   // CustomText(
                                        //                   //   text: "Employee Name",
                                        //                   //   colors: colorsConst.greyClr,
                                        //                   //   size: 12,
                                        //                   // ),
                                        //                   SearchCustomDropdown(
                                        //                       text: "Employee Name",
                                        //                       hintText: attProvider.assignedId==""?"":attProvider.assignedNames,
                                        //                       valueList: empProvider.activeEmps,
                                        //                       onChanged: (value) {},
                                        //                       width: kIsWeb?webHeight:phoneHeight),
                                        //                   // EmployeeDropdown(
                                        //                   //   callback: (){
                                        //                   //   },
                                        //                   //   text: attProvider.userName==""?"Name":attProvider.userName,
                                        //                   //   employeeList: empProvider.activeEmps,
                                        //                   //   onChanged: (UserModel? value) {
                                        //                   //     attProvider.selectUser(value!);
                                        //                   //   },
                                        //                   //   size: kIsWeb?webHeight:phoneHeight,),
                                        //                   10.height,
                                        //                   MapDropDown(saveValue: attProvider.type, hintText: constValue.type,
                                        //                       onChanged: (value){
                                        //                         attProvider.checkFilterType(value);
                                        //                       }, dropText: 'value',
                                        //                       list: attProvider.typeList.toSet().toList()),
                                        //                   CustomText(
                                        //                     text: constValue.companyName,
                                        //                     colors: colorsConst.greyClr,
                                        //                     size: 12,
                                        //                   ),
                                        //                   // 2.height,
                                        //                   CustomerDropdown(
                                        //                     text: attProvider.companyName==""?constValue.companyName:attProvider.companyName,
                                        //                     isRequired: true,hintText: false,
                                        //                     employeeList: cusPvr.customer,
                                        //                     onChanged: (CustomerModel? value) {
                                        //                       attProvider.changeName(value);
                                        //                     }, size: kIsWeb?webHeight:phoneHeight,),
                                        //                   20.height,
                                        //                   Row(
                                        //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        //                     children: [
                                        //                       CustomBtn(
                                        //                         width: 100,
                                        //                         text: 'Clear All',
                                        //                         callback: () {
                                        //                           attProvider.initFilterValue(true,date1:widget.date1,date2:widget.date2,type:widget.type);
                                        //                           Navigator.of(context, rootNavigator: true).pop();
                                        //                         },
                                        //                         bgColor: Colors.grey.shade200,
                                        //                         textColor: Colors.black,
                                        //                       ),
                                        //                       CustomBtn(
                                        //                         width: 100,
                                        //                         text: 'Apply Filters',
                                        //                         callback: () {
                                        //                           attProvider.initFilterValue(false);
                                        //                           attProvider.filterList();
                                        //                           Navigator.of(context, rootNavigator: true).pop();
                                        //                         },
                                        //                         bgColor: colorsConst.primary,
                                        //                         textColor: Colors.white,
                                        //                       ),
                                        //                     ],
                                        //                   ),
                                        //                   20.height,
                                        //                 ],
                                        //               ),
                                        //             )
                                        //           ],
                                        //         );
                                        //       },
                                        //     );
                                        //   },
                                        // );
                                        _myFocusScopeNode.unfocus();
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return Consumer<AttendanceProvider>(
                                                        builder: (context, custProvider, _) {
                                                          return AlertDialog(
                                                            actions: [
                                                              SizedBox(
                                                                width: kIsWeb?webWidth:phoneWidth,
                                                                child: Column(
                                                                  children: [
                                                                    20.height,
                                                                    Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        70.width,
                                                                        const CustomText(
                                                                          text: 'Filters',
                                                                          colors: Colors.black,
                                                                          size: 16,
                                                                          isBold: true,
                                                                        ),
                                                                        30.width,
                                                                        InkWell(
                                                                          onTap: () {
                                                                            Navigator.of(context, rootNavigator: true).pop();
                                                                          },
                                                                          child: SvgPicture.asset(assets.cancel),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    20.height,
                                                                    Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                      children: [
                                                                        Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            CustomText(
                                                                              text: "From Date",
                                                                              colors: colorsConst.greyClr,
                                                                              size: 12,
                                                                            ),
                                                                            InkWell(
                                                                              onTap: () {
                                                                                custProvider.datePick(
                                                                                  context: context,
                                                                                  isStartDate: true,
                                                                                  date: attProvider.startDate,
                                                                                );
                                                                              },
                                                                              child: Container(
                                                                                height: 30,
                                                                                width: kIsWeb?webWidth/2.7:phoneWidth/2.7,
                                                                                decoration: customDecoration.baseBackgroundDecoration(
                                                                                  color: Colors.white,
                                                                                  radius: 5,
                                                                                  borderColor: colorsConst.litGrey,
                                                                                ),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    CustomText(text: custProvider.startDate),
                                                                                    5.width,
                                                                                    SvgPicture.asset(assets.calendar2),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                        Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            CustomText(
                                                                              text: "To Date",
                                                                              colors: colorsConst.greyClr,
                                                                              size: 12,
                                                                            ),
                                                                            InkWell(
                                                                              onTap: () {
                                                                                custProvider.datePick(
                                                                                  context: context,
                                                                                  isStartDate: false,
                                                                                  date: attProvider.endDate,
                                                                                );
                                                                              },
                                                                              child: Container(
                                                                                height: 30,
                                                                                width: kIsWeb?webWidth/2.7:phoneWidth/2.7,
                                                                                decoration: customDecoration.baseBackgroundDecoration(
                                                                                  color: Colors.white,
                                                                                  radius: 5,
                                                                                  borderColor: colorsConst.litGrey,
                                                                                ),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    CustomText(text: custProvider.endDate),
                                                                                    5.width,
                                                                                    SvgPicture.asset(assets.calendar2),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    10.height,
                                                                    Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                      children: [
                                                                        Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            CustomText(
                                                                              text: "Employee Name",
                                                                              colors: colorsConst.greyClr,
                                                                              size: 12,
                                                                            ),
                                                                            EmployeeDropdown(
                                                                              callback: (){
                                                                                empProvider.getAllUsers();
                                                                              },
                                                                              text: attProvider.userName,
                                                                              employeeList: empProvider.filterUserData,
                                                                              onChanged: (UserModel? value) {
                                                                                attProvider.selectUser(context,value!,widget.empList);
                                                                              },
                                                                              size: kIsWeb?webWidth/2.7:phoneWidth/2.7,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsets.fromLTRB(0, empProvider.filterUserData.isEmpty?20:0, 0, 0),
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              CustomText(
                                                                                text: "Select Date Range",
                                                                                colors: colorsConst.greyClr,
                                                                                size: 12,
                                                                              ),
                                                                              Container(
                                                                                height: 40,
                                                                                width: kIsWeb?webWidth/2.7:phoneWidth/2.7,
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
                                                                                  value: attProvider.type,
                                                                                  onChanged: (value) {
                                                                                    attProvider.changeType(value,localData.storage.read("id"),localData.storage.read("role"),false,widget.empList);
                                                                                  },
                                                                                  items: attProvider.typeList.map((list) {
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
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    20.height,
                                                                    Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                      children: [
                                                                        CustomBtn(
                                                                          width: 100,
                                                                          text: 'Clear All',
                                                                          callback: () {
                                                                            attProvider.initDate(id:localData.storage.read("id"),role:localData.storage.read("role"),isRefresh: false,date1:widget.date1,date2:widget.date2,type:widget.type);
                                                                            Navigator.of(context, rootNavigator: true).pop();
                                                                            // attProvider.getAttendanceReport(localData.storage.read("id"),localData.storage.read("role"),false,isAbsent: showType=="Absent"?true:false,isLate: showType=="Late"?true:false,list: widget.empList);
                                                                            if(attProvider.selectedIndex==1){
                                                                              showType="Absent";
                                                                              attProvider.getAttendanceReport(localData.storage.read("id"),localData.storage.read("role"),false,isAbsent: true,isLate: false,list: widget.empList);
                                                                            }
                                                                            if(attProvider.selectedIndex==2){
                                                                              showType="Late";
                                                                              attProvider.getAttendanceReport(localData.storage.read("id"),localData.storage.read("role"),false,isAbsent: false,isLate: true,list: widget.empList);
                                                                            }
                                                                            if(attProvider.selectedIndex==4){
                                                                              showType="Present";
                                                                              attProvider.getAttendanceReport(localData.storage.read("id"),localData.storage.read("role"),false,isAbsent: false,isLate: false,list: widget.empList);
                                                                            }
                                                                            },
                                                                          bgColor: Colors.grey.shade200,
                                                                          textColor: Colors.black,
                                                                        ),
                                                                        CustomBtn(
                                                                          width: 100,
                                                                          text: 'Apply Filters',
                                                                          callback: () {
                                                                            attProvider.getAttendanceReport(localData.storage.read("id"),localData.storage.read("role"),true,isAbsent: showType=="Absent"?true:false,isLate: showType=="Late"?true:false,list: widget.empList);
                                                                            Navigator.of(context, rootNavigator: true).pop();
                                                                          },
                                                                          bgColor: colorsConst.primary,
                                                                          textColor: Colors.white,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    20.height,
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                  // empProvider.filterUserData = empProvider.filterUserData.where((contact){
                                                  //   DateTime contactDate = DateFormat('yyyy-MM-dd').parse(contact.updatedTs.toString().split(' ')[0]);
                                                  //   return contactDate.isAfter(startDate) && contactDate.isBefore(currentDate);
                                                  // }).toList();
                                                },
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: SvgPicture.asset(assets.tFilter,width: 20,height: 20,),
                                      ),
                                    ),5.width
                                  ],
                                ),),
                              GestureDetector(
                                  onTap: (){
                                    if(attProvider.getDailyAttendance.isEmpty){
                                      utils.showWarningToast(context, text: "No Data Found");
                                    }else{
                                      if(attProvider.userName!=""){
                                        excelReports.exportUserAttendanceToExcel(context,chunked: attProvider.getDailyAttendance, date: "${attProvider.startDate} ${attProvider.startDate==attProvider.endDate?"":"To ${attProvider.endDate}"}");
                                      }else{
                                        excelReports.exportAttendanceToExcel(context,chunked: attProvider.getDailyAttendance, date: "${attProvider.startDate} ${attProvider.startDate==attProvider.endDate?"":"To ${attProvider.endDate}"}");
                                      }
                                    }
                                    },
                                  child: SvgPicture.asset(assets.tDownload,width: 27,height: 27,)),
                              // CustomLoadingButton(callback: (){
                              // }, text: "PF", isLoading: false,
                              //     backgroundColor: colorsConst.primary, radius: 5, width: 60)
                            ],
                          ),
                        // Column(
                        //   crossAxisAlignment: CrossAxisAlignment.end,
                        //   children: [
                        //     CustomText(text: attProvider.lastRefreshed,colors:colorsConst.greyClr,isBold: true,size: 12,),
                        //     Row(
                        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //         children: [
                        //           SizedBox(
                        //             height: 85,
                        //             child: CustomTextField(
                        //               text: "",radius: 30,
                        //               controller: attProvider.search,
                        //               textInputAction: TextInputAction.done,
                        //               width: kIsWeb?webWidth/1.5:phoneWidth/1.6,
                        //               hintText: "Search By Name",
                        //               isIcon: true,
                        //               iconData: Icons.search,
                        //               isShadow: true,
                        //               onChanged: (value) {
                        //
                        //               },
                        //               isSearch: attProvider.search.text.isNotEmpty?true:false,
                        //               searchCall: (){
                        //                 attProvider.search.clear();
                        //                 attProvider.searchAttendanceReport("");
                        //               },
                        //             ),
                        //           ),
                        //           // InkWell(
                        //           //   onTap: (){
                        //           //     _myFocusScopeNode.unfocus();
                        //           //     showDialog(
                        //           //       context: context,
                        //           //       builder: (context) {
                        //           //         return Consumer<AttendanceProvider>(
                        //           //           builder: (context, custProvider, _) {
                        //           //             return AlertDialog(
                        //           //               actions: [
                        //           //                 SizedBox(
                        //           //                   width: kIsWeb?webWidth:phoneWidth,
                        //           //                   child: Column(
                        //           //                     children: [
                        //           //                       20.height,
                        //           //                       Row(
                        //           //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //           //                         children: [
                        //           //                           70.width,
                        //           //                           const CustomText(
                        //           //                             text: 'Filters',
                        //           //                             colors: Colors.black,
                        //           //                             size: 16,
                        //           //                             isBold: true,
                        //           //                           ),
                        //           //                           30.width,
                        //           //                           InkWell(
                        //           //                             onTap: () {
                        //           //                               Navigator.of(context, rootNavigator: true).pop();
                        //           //                             },
                        //           //                             child: SvgPicture.asset(assets.cancel),
                        //           //                           )
                        //           //                         ],
                        //           //                       ),
                        //           //                       20.height,
                        //           //                       Row(
                        //           //                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //           //                         children: [
                        //           //                           Column(
                        //           //                             crossAxisAlignment: CrossAxisAlignment.start,
                        //           //                             children: [
                        //           //                               CustomText(
                        //           //                                 text: "From Date",
                        //           //                                 colors: colorsConst.greyClr,
                        //           //                                 size: 12,
                        //           //                               ),
                        //           //                               InkWell(
                        //           //                                 onTap: () {
                        //           //                                   custProvider.datePick(
                        //           //                                     context: context,
                        //           //                                     isStartDate: true,
                        //           //                                     date: attProvider.startDate,
                        //           //                                   );
                        //           //                                 },
                        //           //                                 child: Container(
                        //           //                                   height: 30,
                        //           //                                   width: kIsWeb?webWidth/2.7:phoneWidth/2.7,
                        //           //                                   decoration: customDecoration.baseBackgroundDecoration(
                        //           //                                     color: Colors.white,
                        //           //                                     radius: 5,
                        //           //                                     borderColor: colorsConst.litGrey,
                        //           //                                   ),
                        //           //                                   child: Row(
                        //           //                                     mainAxisAlignment: MainAxisAlignment.center,
                        //           //                                     children: [
                        //           //                                       CustomText(text: custProvider.startDate),
                        //           //                                       5.width,
                        //           //                                       SvgPicture.asset(assets.calendar2),
                        //           //                                     ],
                        //           //                                   ),
                        //           //                                 ),
                        //           //                               )
                        //           //                             ],
                        //           //                           ),
                        //           //                           Column(
                        //           //                             crossAxisAlignment: CrossAxisAlignment.start,
                        //           //                             children: [
                        //           //                               CustomText(
                        //           //                                 text: "To Date",
                        //           //                                 colors: colorsConst.greyClr,
                        //           //                                 size: 12,
                        //           //                               ),
                        //           //                               InkWell(
                        //           //                                 onTap: () {
                        //           //                                   custProvider.datePick(
                        //           //                                     context: context,
                        //           //                                     isStartDate: false,
                        //           //                                     date: attProvider.endDate,
                        //           //                                   );
                        //           //                                 },
                        //           //                                 child: Container(
                        //           //                                   height: 30,
                        //           //                                   width: kIsWeb?webWidth/2.7:phoneWidth/2.7,
                        //           //                                   decoration: customDecoration.baseBackgroundDecoration(
                        //           //                                     color: Colors.white,
                        //           //                                     radius: 5,
                        //           //                                     borderColor: colorsConst.litGrey,
                        //           //                                   ),
                        //           //                                   child: Row(
                        //           //                                     mainAxisAlignment: MainAxisAlignment.center,
                        //           //                                     children: [
                        //           //                                       CustomText(text: custProvider.endDate),
                        //           //                                       5.width,
                        //           //                                       SvgPicture.asset(assets.calendar2),
                        //           //                                     ],
                        //           //                                   ),
                        //           //                                 ),
                        //           //                               )
                        //           //                             ],
                        //           //                           ),
                        //           //                         ],
                        //           //                       ),
                        //           //                       10.height,
                        //           //                       Row(
                        //           //                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //           //                         children: [
                        //           //                           Column(
                        //           //                             crossAxisAlignment: CrossAxisAlignment.start,
                        //           //                             children: [
                        //           //                               CustomText(
                        //           //                                 text: "Employee Name",
                        //           //                                 colors: colorsConst.greyClr,
                        //           //                                 size: 12,
                        //           //                               ),
                        //           //                               EmployeeDropdown(
                        //           //                                 callback: (){
                        //           //                                   empProvider.getAllUsers();
                        //           //                                 },
                        //           //                                 text: attProvider.userName,
                        //           //                                 employeeList: empProvider.filterUserData,
                        //           //                                 onChanged: (UserModel? value) {
                        //           //                                   attProvider.selectUser(value!);
                        //           //                                 },
                        //           //                                 size: kIsWeb?webWidth/2.7:phoneWidth/2.7,
                        //           //                               ),
                        //           //                             ],
                        //           //                           ),
                        //           //                           Padding(
                        //           //                             padding: EdgeInsets.fromLTRB(0, empProvider.filterUserData.isEmpty?20:0, 0, 0),
                        //           //                             child: Column(
                        //           //                               crossAxisAlignment: CrossAxisAlignment.start,
                        //           //                               children: [
                        //           //                                 CustomText(
                        //           //                                   text: "Select Date Range",
                        //           //                                   colors: colorsConst.greyClr,
                        //           //                                   size: 12,
                        //           //                                 ),
                        //           //                                 Container(
                        //           //                                   height: 40,
                        //           //                                   width: kIsWeb?webWidth/2.7:phoneWidth/2.7,
                        //           //                                   decoration: customDecoration.baseBackgroundDecoration(
                        //           //                                     radius: 5,
                        //           //                                     color: Colors.white,
                        //           //                                     borderColor: colorsConst.litGrey,
                        //           //                                   ),
                        //           //                                   child: DropdownButton(
                        //           //                                     iconEnabledColor: colorsConst.greyClr,
                        //           //                                     isExpanded: true,
                        //           //                                     underline: const SizedBox(),
                        //           //                                     icon: const Icon(Icons.keyboard_arrow_down_outlined),
                        //           //                                     value: attProvider.type,
                        //           //                                     onChanged: (value) {
                        //           //                                       attProvider.changeType(value,localData.storage.read("id"),localData.storage.read("role"),false);
                        //           //                                     },
                        //           //                                     items: attProvider.typeList.map((list) {
                        //           //                                       return DropdownMenuItem(
                        //           //                                         value: list,
                        //           //                                         child: CustomText(
                        //           //                                           text: "  $list",
                        //           //                                           colors: Colors.black,
                        //           //                                           isBold: false,
                        //           //                                         ),
                        //           //                                       );
                        //           //                                     }).toList(),
                        //           //                                   ),
                        //           //                                 ),
                        //           //                               ],
                        //           //                             ),
                        //           //                           ),
                        //           //                         ],
                        //           //                       ),
                        //           //                       20.height,
                        //           //                       Row(
                        //           //                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //           //                         children: [
                        //           //                           CustomBtn(
                        //           //                             width: 100,
                        //           //                             text: 'Clear All',
                        //           //                             callback: () {
                        //           //                               attProvider.initDate(id:localData.storage.read("id"),role:localData.storage.read("role"),isRefresh: false,date1:widget.date1,date2:widget.date2,type:widget.type);
                        //           //                               Navigator.of(context, rootNavigator: true).pop();
                        //           //                               // attProvider.getAttendanceReport(localData.storage.read("id"),localData.storage.read("role"),false,isAbsent: showType=="Absent"?true:false,isLate: showType=="Late"?true:false,list: widget.empList);
                        //           //                               if(attProvider.selectedIndex==1){
                        //           //                                 showType="Absent";
                        //           //                                 attProvider.getAttendanceReport(localData.storage.read("id"),localData.storage.read("role"),false,isAbsent: true,isLate: false,list: widget.empList);
                        //           //                               }
                        //           //                               if(attProvider.selectedIndex==2){
                        //           //                                 showType="Late";
                        //           //                                 attProvider.getAttendanceReport(localData.storage.read("id"),localData.storage.read("role"),false,isAbsent: false,isLate: true,list: widget.empList);
                        //           //                               }
                        //           //                               if(attProvider.selectedIndex==4){
                        //           //                                 showType="Present";
                        //           //                                 attProvider.getAttendanceReport(localData.storage.read("id"),localData.storage.read("role"),false,isAbsent: false,isLate: false,list: widget.empList);
                        //           //                               }
                        //           //                               },
                        //           //                             bgColor: Colors.grey.shade200,
                        //           //                             textColor: Colors.black,
                        //           //                           ),
                        //           //                           CustomBtn(
                        //           //                             width: 100,
                        //           //                             text: 'Apply Filters',
                        //           //                             callback: () {
                        //           //                               attProvider.getAttendanceReport(localData.storage.read("id"),localData.storage.read("role"),true,isAbsent: showType=="Absent"?true:false,isLate: showType=="Late"?true:false,list: widget.empList);
                        //           //                               Navigator.of(context, rootNavigator: true).pop();
                        //           //                             },
                        //           //                             bgColor: colorsConst.primary,
                        //           //                             textColor: Colors.white,
                        //           //                           ),
                        //           //                         ],
                        //           //                       ),
                        //           //                       20.height,
                        //           //                     ],
                        //           //                   ),
                        //           //                 )
                        //           //               ],
                        //           //             );
                        //           //           },
                        //           //         );
                        //           //       },
                        //           //     );
                        //           //     // empProvider.filterUserData = empProvider.filterUserData.where((contact){
                        //           //     //   DateTime contactDate = DateFormat('yyyy-MM-dd').parse(contact.updatedTs.toString().split(' ')[0]);
                        //           //     //   return contactDate.isAfter(startDate) && contactDate.isBefore(currentDate);
                        //           //     // }).toList();
                        //           //   },
                        //           //   child: Container(
                        //           //     width: kIsWeb?webWidth/6.5:phoneWidth/7,
                        //           //     height: 45,
                        //           //     decoration: customDecoration.baseBackgroundDecoration(
                        //           //         color: attProvider.filter==true?colorsConst.primary:Colors.grey.shade300,radius: 5
                        //           //     ),
                        //           //     child: Padding(
                        //           //       padding: const EdgeInsets.all(5.0),
                        //           //       child: SvgPicture.asset(assets.filter,width: 15,height: 15,),
                        //           //     ),
                        //           //   ),
                        //           // ),
                        //           IconButton(onPressed: (){
                        //             if(attProvider.getDailyAttendance.isEmpty){
                        //               utils.showWarningToast(context, text: "No Data Found");
                        //             }else{
                        //               if(attProvider.userName!=""){
                        //                 excelReports.exportUserAttendanceToExcel(context,chunked: attProvider.getDailyAttendance, date: "${attProvider.startDate} ${attProvider.startDate==attProvider.endDate?"":"To ${attProvider.endDate}"}");
                        //               }else{
                        //                 excelReports.exportAttendanceToExcel(context,chunked: attProvider.getDailyAttendance, date: "${attProvider.startDate} ${attProvider.startDate==attProvider.endDate?"":"To ${attProvider.endDate}"}");
                        //               }
                        //             }
                        //           }, icon: Icon(Icons.download)),
                        //           IconButton(onPressed: (){
                        //             Provider.of<AttendanceProvider>(context, listen: false).getAttendanceReport(localData.storage.read("id"),localData.storage.read("role"),attProvider.filter,
                        //                 isAbsent: showType=="Absent"?true:false,isLate: showType=="Late"?true:false,list: widget.empList);
                        //           }, icon: Icon(Icons.refresh,color: Colors.red,)),
                        //           InkWell(onTap: (){
                        //             attProvider.initDate(id:localData.storage.read("id"),role:localData.storage.read("role"),isRefresh: false,date1:widget.date1,date2:widget.date2);
                        //             showType="Present";
                        //             attProvider.getAttendanceReport(localData.storage.read("id"),localData.storage.read("role"),false,isAbsent: false,isLate: false,list: widget.empList,);
                        //           }, child: Icon(Icons.cancel,color: Colors.red,))
                        //           ///
                        //         ],
                        //       ),
                        //   ],
                        // ),
                        if(localData.storage.read("role") !="1"&&showType!="0"&&showType!="Absent"&&showType!="Late")
                        CustomDropDown(
                              text: "", valueList: attProvider.typeList,
                              saveValue: attProvider.type,color: Colors.white,
                              onChanged: (value){
                                attProvider.changeType(value,localData.storage.read("id"),localData.storage.read("role"),false,widget.empList);
                              }, width: kIsWeb?webWidth:phoneWidth),
                        10.height,
                        Column(
                          children: [
                            SizedBox(
                              width: kIsWeb?webWidth:phoneWidth,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if(attProvider.filter==true)
                                  CustomText(text: "Filter Selected",colors:colorsConst.greyClr,size: 14,),10.height,
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CustomText(text: "Total Records: ",colors:colorsConst.greyClr,size: 14,),
                                      CustomText(text: showType=="Leave"?levPvr.myLevSearch.length.toString():showType=="Late"?attProvider.lateUsers.length.toString():showType=="Absent"?attProvider.noAttendanceList.length.toString():showType=="0"?attProvider.getDailyAttendance.length.toString():attProvider.permisCount.toString(),colors:colorsConst.primary,size: 14,),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            10.height,
                            if(attProvider.filter==true)
                            Row(
                                // spacing: 8,
                                // runSpacing: 8,
                                children: [
                                  if (attProvider.startDate != attProvider.endDate)
                                    if (attProvider.startDate.isNotEmpty &&
                                        attProvider.endDate.isNotEmpty)
                                      _filterChip(
                                        "${attProvider.startDate} - ${attProvider.endDate}",
                                      ),

                                  if (attProvider.type.isNotEmpty || attProvider.type!="null")
                                    _filterChip(attProvider.type), // Last 7 days

                                  if (attProvider.userName.isNotEmpty)
                                    _filterChip(attProvider.userName),

                                ],
                              ),
                            10.height,
                          ],
                        ),
                        // if(attProvider.getDailyAttendance.isNotEmpty)
                        Column(
                          children: [
                            // GroupButton(
                            //   options: GroupButtonOptions(
                            //       spacing: 10,
                            //       borderRadius:BorderRadius.circular(5),
                            //       buttonHeight: 30,
                            //       buttonWidth: phoneWidth/7,
                            //       selectedBorderColor:colorsConst.primary,
                            //       unselectedBorderColor:colorsConst.primary,
                            //       selectedTextStyle:const TextStyle(
                            //           fontSize: 13,
                            //           fontFamily:'Lato'
                            //       ),unselectedTextStyle:TextStyle(
                            //       color: colorsConst.primary,
                            //       fontSize: 13,
                            //       fontFamily:'Lato'
                            //   )),
                            //   buttons: attProvider.items,
                            //   controller:attProvider.statusController,
                            //   onSelected: (name, index, isSelect) {
                            //     attProvider.changeExpense(name.toString(),index);
                            //   },
                            // ),
                            Row(
                              children: [
                                Container(
                                  width: kIsWeb?webWidth:phoneWidth/1.14,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(5),
                                      bottomLeft: Radius.circular(5),
                                    ),
                                    // border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: ToggleButtons(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(5),
                                      bottomLeft: Radius.circular(5),
                                    ),
                                    // borderColor: Colors.grey.shade300,
                                    selectedBorderColor: Colors.white,
                                    fillColor: Colors.green, // selected background

                                    borderColor: Colors.transparent,        // ⭐ unselected border remove
                                    // selectedBorderColor: Colors.transparent, // ⭐ selected border remove
                                    disabledBorderColor: Colors.transparent,
                                    borderWidth: 0,

                                    isSelected: List.generate(
                                      attProvider.items.length,
                                          (index) => attProvider.selectedIndex == index,
                                    ),

                                    onPressed: (index) {
                                      setState(() {
                                        attProvider.selectedIndex = index;
                                        if(attProvider.selectedIndex==1){
                                          showType="Absent";
                                          attProvider.getAttendanceReport(localData.storage.read("id"),localData.storage.read("role"),false,isAbsent: true,isLate: false,list: widget.empList);
                                        }
                                        if(attProvider.selectedIndex==2){
                                          showType="Late";
                                          attProvider.getAttendanceReport(localData.storage.read("id"),localData.storage.read("role"),false,isAbsent: false,isLate: true,list: widget.empList);
                                        }
                                        if(attProvider.selectedIndex==4){
                                          showType="Present";
                                          attProvider.getAttendanceReport(localData.storage.read("id"),localData.storage.read("role"),false,isAbsent: false,isLate: false,list: widget.empList);
                                        }
                                        if(attProvider.selectedIndex==3){
                                          showType="Leave";
                                          levPvr.allLeaves(attProvider.startDate,attProvider.endDate,false);
                                        }
                                      });
                                    },

                                    children: List.generate(attProvider.items.length, (index) {
                                      bool isSelected = attProvider.selectedIndex == index;

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomText(
                                              text:"  ${attProvider.items[index]}",
                                              colors: isSelected
                                                  ? Colors.white
                                                  : attProvider.itemColors[index].withOpacity(0.6),isBold: true,
                                            ),5.width,
                                            if(!isSelected)
                                              Container(
                                                color: Colors.grey.shade200,height: 30,width: 1,
                                              )
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                InkWell(
                                  onTap: (){
                                    attProvider.sorting();
                                  },
                                  child: Container(
                                      height: 45,
                                      width: kIsWeb?webWidth:phoneWidth/9,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Icon(Icons.sort_by_alpha),
                                      )
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        empProvider.refresh == false||attProvider.refresh == false ?
                        const Padding(
                          padding: EdgeInsets.all(100.0),
                          child: Loading(),
                        )
                        :(showType.toString()!="Absent"&&showType.toString()!="Late")&&attProvider.getDailyAttendance.isEmpty?
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
                          child: CustomText(
                              text: constValue.noData, size: 15),
                        )
                        :localData.storage.read("role")=="1"&&showType.toString()=="Absent"&&attProvider.noAttendanceList.isEmpty?
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
                          child: CustomText(
                              text: constValue.noData, size: 15),
                        ):localData.storage.read("role")=="1"&&showType.toString()=="Absent"?
                        Flexible(
                          child: ListView.builder(
                              itemCount: attProvider.noAttendanceList.length,
                              itemBuilder: (context, index) {
                                var data = attProvider.noAttendanceList[index];
                                return Padding(
                                  padding: EdgeInsets.fromLTRB(5, 10, 5, index==attProvider.noAttendanceList.length-1?30:0),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          // CustomText(text:  DateFormat('dd-MM-yyyy hh:mm a')
                                          //     .format(DateTime.parse(data.createdTs.toString())),colors:colorsConst.red1),5.height,
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              CustomText(text: data.firstname.toString(),colors:colorsConst.greyClr),
                                              CustomText(text: data.roleName.toString(),colors:Colors.grey),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ):
                        localData.storage.read("role")!="1"&&showType.toString()=="Absent"&&attProvider.missingDateList.isEmpty?
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
                          child: CustomText(
                              text: constValue.noData, size: 15),
                        ):localData.storage.read("role")!="1"&&showType.toString()=="Absent"?
                        Flexible(
                          child: ListView.builder(
                              itemCount: attProvider.missingDateList.length,
                              itemBuilder: (context, index) {
                                var data = attProvider.missingDateList[index];
                                return Padding(
                                  padding: EdgeInsets.fromLTRB(5, 10, 5, index==attProvider.missingDateList.length-1?30:0),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          CustomText(text: attProvider.missingDateList[index],colors:colorsConst.greyClr),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ):
                        showType.toString()=="Late"&&attProvider.lateUsers.isEmpty?
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
                          child: CustomText(
                              text: constValue.noData, size: 15),
                        ):
                        showType.toString()=="Late"?
                        Flexible(
                          child: ListView.builder(
                              itemCount: attProvider.lateUsers.length,
                              itemBuilder: (context, index) {
                                final sortedData = attProvider.lateUsers;
                                AttendanceModel data = attProvider.lateUsers[index];
                                var inTime = "",outTime = "-",timeD = "-";
                                var lat = data.lats.toString().split(",");
                                var lng = data.lngs.toString().split(",");
                                if (data.status.toString().contains("1,2")) {
                                  inTime = data.time!.split(",")[0];
                                  outTime = data.time!.split(",")[1];
                                  timeD=attProvider.timeDifference(data.createdTs!.split(",")[0], data.createdTs!.split(",")[1]);
                                }else if (data.status.toString().contains("2,1")) {
                                  inTime = data.time!.split(",")[1];
                                  outTime = data.time!.split(",")[0];
                                  timeD=attProvider.timeDifference(data.createdTs!.split(",")[0], data.createdTs!.split(",")[1]);
                                }else {
                                  inTime = data.time!.split(",")[0];
                                  timeD="-";
                                }
                                String timestamp =data.createdTs.toString();
                                List<String> times = timestamp.split(',');
                                DateTime startTime = DateTime.parse(times[0]);

                                String createdBy = formatCreatedDate(startTime);
                                String? prevCreatedBy;
                                if (index != 0) {
                                  String timestamp =sortedData[index - 1].createdTs.toString();
                                  List<String> times = timestamp.split(',');
                                  DateTime startTime = DateTime.parse(times[0]);
                                  prevCreatedBy = formatCreatedDate(startTime);
                                }

                                final showDateHeader = index == 0 ||
                                    createdBy != prevCreatedBy;
                                return Padding(
                                  padding: EdgeInsets.fromLTRB(5, 10, 5, index==attProvider.lateUsers.length-1?30:0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if(localData.storage.read("role")=="1"&&showDateHeader)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                        child: CustomText(text: createdBy,colors:colorsConst.greyClr,size: 12,),
                                      ),
                                      AttendanceDetails(
                                        showDate: index==0?true:false,
                                        date: data.date.toString(),
                                        img: data.image.toString(),
                                        inTime: inTime,
                                        outTime: outTime,
                                        timeD:timeD,
                                        name: data.firstname.toString(),
                                        role: data.role.toString(),
                                        callback: () {
                                          utils.navigatePage(context, ()=>CheckLocation(
                                              lat1: lat[0].toString(),
                                              long1: lng[0].toString(),
                                              lat2: data.status.toString().contains("2")? lat[1].toString(): "",
                                              long2: data.status.toString().contains("2")? lng[1].toString(): ""
                                          ));
                                        },
                                        perStatus: data.perStatus.toString(),
                                        perReason: data.perReason.toString(),
                                        perTime: data.perTime.toString(),
                                        perCreatedTs: data.perCreatedTs.toString(),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ):
                        attProvider.selectedIndex==3&&levPvr.isLoading == false ?
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 150, 0, 0),
                          child: Loading(),
                        )
                        :attProvider.selectedIndex==3&&levPvr.myLevSearch.isEmpty ?
                        Column(
                          children: [
                            100.height,
                            CustomText(
                              text: constValue.noData, colors: colorsConst.greyClr,),
                          ],
                        )
                        :attProvider.selectedIndex==3&&levPvr.myLevSearch.isNotEmpty?Flexible(
                          child: itemBuilder(levPvr.myLevSearch,levPvr)):
                        attProvider.selectedIndex==4&&attProvider.permisCount==0?
                        Column(
                          children: [
                            100.height,
                            CustomText(
                              text: constValue.noData, colors: colorsConst.greyClr,),
                          ],
                        ):
                        attProvider.selectedIndex==4&&attProvider.permisCount!=0?
                        Flexible(
                          child: ListView.builder(
                              itemCount: attProvider.getDailyAttendance.length,
                              itemBuilder: (context, index) {
                                final sortedData = attProvider.getDailyAttendance;
                                AttendanceModel data = attProvider.getDailyAttendance[index];
                                var inTime = "",outTime = "-",timeD = "-";
                                var lat = data.lats.toString().split(",");
                                var lng = data.lngs.toString().split(",");
                                if (data.status.toString().contains("1,2")) {
                                  inTime = data.time!.split(",")[0];
                                  outTime = data.time!.split(",")[1];
                                  timeD=attProvider.timeDifference(data.createdTs!.split(",")[0], data.createdTs!.split(",")[1]);
                                }else if (data.status.toString().contains("2,1")) {
                                  inTime = data.time!.split(",")[1];
                                  outTime = data.time!.split(",")[0];
                                  timeD=attProvider.timeDifference(data.createdTs!.split(",")[0], data.createdTs!.split(",")[1]);
                                }else {
                                  inTime = data.time!.split(",")[0];
                                  timeD="-";
                                }
                                String timestamp =data.createdTs.toString();
                                List<String> times = timestamp.split(',');
                                DateTime startTime = DateTime.parse(times[0]);

                                String createdBy = formatCreatedDate(startTime);
                                String? prevCreatedBy;
                                if (index != 0) {
                                  String timestamp =sortedData[index - 1].createdTs.toString();
                                  List<String> times = timestamp.split(',');
                                  DateTime startTime = DateTime.parse(times[0]);
                                  prevCreatedBy = formatCreatedDate(startTime);
                                }

                                final showDateHeader = index == 0 ||
                                    createdBy != prevCreatedBy;
                                return data.perStatus.toString().contains(",")?
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if(localData.storage.read("role")=="1"&&showDateHeader)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                        child: CustomText(text: createdBy,colors:colorsConst.greyClr,size: 12,),
                                      ),
                                    InkWell(
                                        onTap:(){
                                          utils.navigatePage(context, ()=> DashBoard(child:
                                          CustomAttendanceReport(userId:data.salesmanId.toString(),userName: data.firstname.toString())));
                                        },
                                        child: AttendanceDetails(
                                          isName: attProvider.userName!=""?false:true,
                                          showDate: index==0?true:false,
                                          date: data.date.toString(),
                                          img: data.image.toString(),
                                          inTime: inTime,
                                          outTime: outTime,
                                          timeD:timeD,
                                          name: data.firstname.toString(),
                                          role: data.role.toString(),
                                          callback: () {
                                            utils.navigatePage(context, ()=>CheckLocation(
                                                lat1: lat[0].toString(),
                                                long1: lng[0].toString(),
                                                lat2: data.status.toString().contains("2")? lat[1].toString(): "",
                                                long2: data.status.toString().contains("2")? lng[1].toString(): ""
                                            ));
                                          },
                                          perStatus: data.perStatus.toString(),
                                          perReason: data.perReason.toString(),
                                          perTime: data.perTime.toString(),
                                          perCreatedTs: data.perCreatedTs.toString(),
                                        )
                                    ),5.height
                                  ],
                                )
                                :0.height;
                              }),
                        ):
                        Flexible(
                          child: ListView.builder(
                              itemCount: attProvider.getDailyAttendance.length,
                              itemBuilder: (context, index) {
                                final sortedData = attProvider.getDailyAttendance;
                                AttendanceModel data = attProvider.getDailyAttendance[index];
                                var inTime = "",outTime = "-",timeD = "-";
                                var lat = data.lats.toString().split(",");
                                var lng = data.lngs.toString().split(",");
                                if (data.status.toString().contains("1,2")) {
                                  inTime = data.time!.split(",")[0];
                                  outTime = data.time!.split(",")[1];
                                  timeD=attProvider.timeDifference(data.createdTs!.split(",")[0], data.createdTs!.split(",")[1]);
                                }else if (data.status.toString().contains("2,1")) {
                                  inTime = data.time!.split(",")[1];
                                  outTime = data.time!.split(",")[0];
                                  timeD=attProvider.timeDifference(data.createdTs!.split(",")[0], data.createdTs!.split(",")[1]);
                                }else {
                                  inTime = data.time!.split(",")[0];
                                  timeD="-";
                                }
                                String timestamp =data.createdTs.toString();
                                List<String> times = timestamp.split(',');
                                DateTime startTime = DateTime.parse(times[0]);

                                String createdBy = formatCreatedDate(startTime);
                                String? prevCreatedBy;
                                if (index != 0) {
                                  String timestamp =sortedData[index - 1].createdTs.toString();
                                  List<String> times = timestamp.split(',');
                                  DateTime startTime = DateTime.parse(times[0]);
                                  prevCreatedBy = formatCreatedDate(startTime);
                                }

                                final showDateHeader = index == 0 ||
                                    createdBy != prevCreatedBy;
                                return attProvider.selectedIndex==2&&isLate(inTime)?
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if(localData.storage.read("role")=="1"&&showDateHeader)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                      child: CustomText(text: createdBy,colors:colorsConst.greyClr,size: 12,),
                                    ),
                                    InkWell(
                                      onTap:(){
                                          utils.navigatePage(context, ()=> DashBoard(child:
                                          CustomAttendanceReport(userId:data.salesmanId.toString(),userName: data.firstname.toString())));
                                      },
                                      child: AttendanceDetails(
                                        isName: attProvider.userName!=""?false:true,
                                        showDate: index==0?true:false,
                                        date: data.date.toString(),
                                        img: data.image.toString(),
                                        inTime: inTime,
                                        outTime: outTime,
                                        timeD:timeD,
                                        name: data.firstname.toString(),
                                        role: data.role.toString(),
                                        callback: () {
                                          utils.navigatePage(context, ()=>CheckLocation(
                                              lat1: lat[0].toString(),
                                              long1: lng[0].toString(),
                                              lat2: data.status.toString().contains("2")? lat[1].toString(): "",
                                              long2: data.status.toString().contains("2")? lng[1].toString(): ""
                                          ));
                                        },
                                        perStatus: data.perStatus.toString(),
                                        perReason: data.perReason.toString(),
                                        perTime: data.perTime.toString(),
                                        perCreatedTs: data.perCreatedTs.toString(),
                                      )
                                    ),5.height
                                  ],
                                )
                                :attProvider.selectedIndex==4&&attProvider.permisCount==0?
                                Column(
                                  children: [
                                    100.height,
                                    CustomText(
                                      text: constValue.noData, colors: colorsConst.greyClr,),
                                  ],
                                )
                                :attProvider.selectedIndex==0?
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if(localData.storage.read("role")=="1"&&showDateHeader)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                      child: CustomText(text: createdBy,colors:colorsConst.greyClr,size: 12,),
                                    ),
                                    InkWell(
                                      onTap:(){
                                          utils.navigatePage(context, ()=> DashBoard(child:
                                          CustomAttendanceReport(userId:data.salesmanId.toString(),userName: data.firstname.toString())));
                                      },
                                      child: AttendanceDetails(
                                        isName: attProvider.userName!=""?false:true,
                                        showDate: index==0?true:false,
                                        date: data.date.toString(),
                                        img: data.image.toString(),
                                        inTime: inTime,
                                        outTime: outTime,
                                        timeD:timeD,
                                        name: data.firstname.toString(),
                                        role: data.role.toString(),
                                        callback: () {
                                          utils.navigatePage(context, ()=>CheckLocation(
                                              lat1: lat[0].toString(),
                                              long1: lng[0].toString(),
                                              lat2: data.status.toString().contains("2")? lat[1].toString(): "",
                                              long2: data.status.toString().contains("2")? lng[1].toString(): ""
                                          ));
                                        },
                                        perStatus: data.perStatus.toString(),
                                        perReason: data.perReason.toString(),
                                        perTime: data.perTime.toString(),
                                        perCreatedTs: data.perCreatedTs.toString(),
                                      ),
                                    ),5.height
                                  ],
                                )
                                :0.height;
                              }),
                        ),
                      ]
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
  String getCreatedDate(data) {
    final timestamp = data.createdTs.toString();
    final dateTime = DateTime.parse(timestamp);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
  Widget itemBuilder(List<LeaveModel> dataList,LeaveProvider levProvider){
    var webWidth=MediaQuery.of(context).size.width*0.7;
    var phoneWidth=MediaQuery.of(context).size.width*0.95;
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: dataList.length,
        itemBuilder: (context,index){
          final sortedData = dataList;
          sortedData.sort((a, b) =>
              a.startDate!.compareTo(b.startDate.toString()));
          final data = sortedData[index];
          var createdBy = "";
          String timestamp = data.createdTs.toString();
          DateTime dateTime = DateTime.parse(timestamp);
          String dayOfWeek = DateFormat('EEEE').format(dateTime);
          DateTime today = DateTime.now();
          if (dateTime.day == today.day && dateTime.month == today.month && dateTime.year == today.year) {
            dayOfWeek = 'Today';
          } else if (dateTime.isAfter(today.subtract(const Duration(days: 1))) &&
              dateTime.isBefore(today)) {
            dayOfWeek = 'Yesterday';
          } else {
            dayOfWeek = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
          }
          createdBy = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
          final showDateHeader = index == 0 || createdBy != getCreatedDate(sortedData[index - 1]);
          var st = DateTime.parse(data.startDate.toString());
          var date1 = "${st.day.toString().padLeft(2,"0")}/${st.month.toString().padLeft(2,"0")}/${st.year}";
          var date2="";
          if(data.startDate.toString()!=data.endDate.toString()&&data.endDate.toString()!=""){
            var en = DateTime.parse(data.endDate.toString());
            // print(data.endDate.toString());
            date2 = "${en.day.toString().padLeft(2,"0")}/${en.month.toString().padLeft(2,"0")}/${en.year}";
          }
          return SizedBox(
            width: kIsWeb?webWidth:phoneWidth,
            child: Column(
              children: [
                if(index==0)
                  5.height,
                if (showDateHeader)
                  SizedBox(
                    width: kIsWeb?webWidth:phoneWidth,
                    child: Column(
                      children: [
                        10.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomText(
                                text: dayOfWeek,
                                colors: colorsConst.greyClr
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                GestureDetector(
                  child: Container(
                    width: kIsWeb?webWidth:phoneWidth,
                    // height: 75,
                    decoration: customDecoration.baseBackgroundDecoration(
                      radius: 5,
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          5.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                text: data.type.toString(),
                                colors: colorsConst.greyClr,
                              ),
                              if(localData.storage.read("role")!="1")
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomText(
                                      text: "$date1${date2!=""?" To $date2":""}",
                                      size: 13,
                                      colors: Colors.black,
                                    ),
                                  ],
                                ),
                              if(data.creater.toString()!=data.fName.toString())
                                Row(
                                  children: [
                                    CustomText(
                                      text: "Added By  ",
                                      colors: colorsConst.greyClr,
                                    ),
                                    CustomText(
                                      text: "${data.creater.toString()} ( HR )",
                                      colors: colorsConst.primary,
                                    ),
                                  ],
                                ),
                              // CustomText(
                              //   text: time,
                              //   colors: colorsConst.greyClr,
                              // ),
                            ],
                          ),
                          5.height,
                          if(localData.storage.read("role")=="1")
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomText(
                                      text: data.fName.toString(),
                                      isBold: true,
                                      size: 15,
                                      colors: colorsConst.shareColor,
                                    ),
                                    5.width,
                                    CustomText(
                                      text: data.role.toString(),
                                      size: 13,
                                      colors: Colors.black,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomText(
                                      text: "$date1${date2!=""?" To $date2":""}",
                                      size: 13,
                                      colors: Colors.black,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          if(localData.storage.read("role")=="1")
                            5.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                text: "Requested for ${data.dayType.toString()=="0.5"?"Half Day":data.dayType.toString()=="1"?"1 Day":"${data.dayCount }days"} leave ${data.dayType.toString()=="0.5"&&data.session.toString()!="null"?"( ${data.session.toString()} )":""}",
                                colors: colorsConst.greyClr,
                              ),
                              if(localData.storage.read("id")==data.createdBy)
                                InkWell(
                                    onTap: (){
                                      utils.customDialog(
                                        context: context,
                                        title: "Are you sure you want to delete",
                                        callback: () {
                                          levProvider.deleteLeave(context,data.id.toString());
                                        },
                                        roundedLoadingButtonController: levProvider.submitCtr,
                                        isLoading: true,
                                      );
                                    }, child: CustomText(text: "Delete",colors: colorsConst.appRed,isBold: true,))
                            ],
                          ),
                          5.height,
                          CustomText(
                            text: data.reason.toString(),
                            colors: colorsConst.stateColor.withOpacity(0.7),
                          ),
                          5.height,
                        ],
                      ),
                    ),
                  ),
                ),
                5.height,
                if(index==dataList.length-1)
                  80.height,
              ],
            ),
          );
        });
  }
  bool isLate(String inTime) {
    final format = DateFormat("hh:mm a");

    DateTime officeTime = format.parse("09:00 AM");
    DateTime userTime = format.parse(inTime);

    return userTime.isAfter(officeTime);
  }
  String formatCreatedDate(DateTime dateTime) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime dataDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dataDate == today) {
      return "Today";
    } else if (dataDate == today.subtract(const Duration(days: 1))) {
      return "Yesterday";
    } else {
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    }
  }
  Widget _filterChip(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
      child: Container(
        // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xff353535),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomText(
            text:text,colors: Color(0xffF5F5F5),size: 12,
          ),
        ),
      ),
    );
  }
}
