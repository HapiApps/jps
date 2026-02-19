import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:master_code/view_model/employee_provider.dart';
import 'package:provider/provider.dart';
import '../../component/animated_button.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../component/map_dropdown.dart';
import '../../model/leave/leave_model.dart';
import '../../model/user_model.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/constant/key_constant.dart';
import '../../source/constant/local_data.dart';
import '../../source/styles/decoration.dart';
import '../../view_model/home_provider.dart';
import '../../view_model/leave_provider.dart';
import '../common/dashboard.dart';
import '../common/home_page.dart';
import 'apply_leave.dart';
import 'leave_details.dart';

class ViewMyLeaves extends StatefulWidget {
  final String? date1;
  final String? date2;
  final bool? isDirect;
  const ViewMyLeaves({super.key,  this.date1,  this.date2, this.isDirect});

  @override
  State<ViewMyLeaves> createState() => _ViewMyLeavesState();
}

class _ViewMyLeavesState extends State<ViewMyLeaves> {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp){
      Provider.of<LeaveProvider >(context, listen: false).initDate(widget.date1!,widget.date2!);
      // Provider.of<LeaveProvider >(context, listen: false).iniValues3();
      if(localData.storage.read("role")!="1"){
        Provider.of<LeaveProvider >(context, listen: false).getLeaveTypes();
      }
      // Provider.of<LeaveProvider >(context, listen: false).daily(localData.storage.read("id"),localData.storage.read("role"),false);

    });
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
    _myFocusScopeNode.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width*0.7;
    var phoneWidth=MediaQuery.of(context).size.width*0.95;
    return Consumer2<LeaveProvider,HomeProvider>(builder: (context,levProvider,homeProvider,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
              preferredSize: Size(300, 50),
              child: CustomAppbar(text: localData.storage.read("role") == "1"? "Leave Report"
                  : "My Leaves",
                callback: (){
                  if (localData.storage.read("role") == "1"&&widget.isDirect==false) {
                    levProvider.changePage(context);
                  }else{
                    homeProvider.updateIndex(0);
                    utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
                  }
                  _myFocusScopeNode.unfocus();
                },
                isButton: localData.storage.read("role") != "1"?true:false,
                buttonCallback: () {
                  _myFocusScopeNode.unfocus();
                  utils.navigatePage(context, ()=> ApplyLeave(date1:widget.date1,date2:widget.date2));
                },
              ),
            ),
            body: PopScope(
              canPop: localData.storage.read("role") == "1"&&widget.isDirect==false ? false : true,
              onPopInvoked: (bool pop) async {
                if (localData.storage.read("role") == "1"&&widget.isDirect==false) {
                  levProvider.changePage(context);
                }else{
                  homeProvider.updateIndex(0);
                  utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
                }
                _myFocusScopeNode.unfocus();
              },
              child: Center(
                child: SizedBox(
                  width: kIsWeb?webWidth:phoneWidth,
                  child: Column(
                    children: [
                      // 15.height,
                      // SizedBox(
                      //   width: kIsWeb?webWidth:phoneWidth,
                      //   child: GroupButton(
                      //     isRadio: true,
                      //     controller: levProvider.groupController,
                      //     options: GroupButtonOptions(
                      //         borderRadius: BorderRadius.circular(20),
                      //         spacing: 10,
                      //         elevation: 0.5,
                      //         buttonHeight: 30,
                      //         selectedColor: colorsConst.primary,
                      //         unselectedColor: Colors.white,
                      //         unselectedTextStyle: TextStyle(
                      //             color: colorsConst.greyClr
                      //         ),
                      //         unselectedBorderColor: Colors.white
                      //     ),
                      //     onSelected: (name, index, isSelected) {
                      //       levProvider.changeReportType(name.toString());
                      //       levProvider.search.clear();
                      //     },
                      //     buttons: levProvider.reportList,
                      //   ),
                      // ),
                      10.height,
                      InkWell(
                        onTap:(){
                          levProvider.showDatePickerCalendar(context);
                        },
                        child:Container(
                          height: 50,
                          decoration: customDecoration.baseBackgroundDecoration(
                              color: Colors.white,
                              radius: 10,
                              borderColor: Colors.grey.shade300
                          ),
                          width: kIsWeb?webWidth:phoneWidth,
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today, size: 15,color: colorsConst.primary,), 2.width,
                                      CustomText(
                                        text:
                                        "${levProvider.startDate}${(levProvider.startDate!=levProvider.endDate)&&levProvider.endDate!=""? " To ${levProvider.endDate}" : ""}",
                                      )
                                    ],
                                  ),
                                  CustomText(text: levProvider.levCount1,
                                    colors: colorsConst.primary,
                                    isBold: true,)
                                ],
                              )
                          ),
                        )
                      ),
                      // 5.height,
                      if(localData.storage.read("role") == "1")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextField(
                              text: "",
                              controller: levProvider.search2,
                              keyboardType: TextInputType.text,
                              inputFormatters: constInputFormatters.numTextInput,
                              textInputAction: TextInputAction.done,
                              width: kIsWeb?webWidth:phoneWidth/1.2,
                              hintText: "Search Name",
                              isIcon: true,
                              iconData: Icons.search,
                              isShadow: true,
                              onChanged: (value) {
                                levProvider.searchReport(value.toString());
                              },
                              isSearch: levProvider.search2.text.isNotEmpty?true:false,
                              searchCall: (){
                                levProvider.search2.clear();
                                levProvider.searchReport("");
                              },
                            ),
                          InkWell(
                            onTap: (){
                              _myFocusScopeNode.unfocus();
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Consumer2<LeaveProvider,EmployeeProvider>(
                                    builder: (context, levPvr,empProvider, _) {
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
                                                            levPvr.datePick(
                                                              context: context,
                                                              isStartDate: true,
                                                              date: levPvr.startDate,
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
                                                                CustomText(text: levPvr.startDate),
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
                                                            levPvr.datePick(
                                                              context: context,
                                                              isStartDate: false,
                                                              date: levPvr.endDate,
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
                                                                CustomText(text: levPvr.endDate),
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
                                                          text: levPvr.userName==""?"Name":levPvr.userName,
                                                          employeeList: empProvider.filterUserData,
                                                          onChanged: (UserModel? value) {
                                                            levPvr.selectUserReport(value!);
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
                                                              value: levPvr.typeReport,
                                                              onChanged: (value) {
                                                                levPvr.changeRrtType(value,localData.storage.read("id"),localData.storage.read("role"),false);
                                                              },
                                                              items: levPvr.typeList.map((list) {
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
                                                        levPvr.initDates(id:localData.storage.read("id"),role:localData.storage.read("role"),isRefresh: false);
                                                        Navigator.of(context, rootNavigator: true).pop();
                                                        levPvr.getLeaveReport(levPvr.filter);
                                                      },
                                                      bgColor: Colors.grey.shade200,
                                                      textColor: Colors.black,
                                                    ),
                                                    CustomBtn(
                                                      width: 100,
                                                      text: 'Apply Filters',
                                                      callback: () {
                                                        levPvr.changeFilter();
                                                        levPvr.getLeaveReport(levPvr.filter);
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
                            child: Container(
                              width: kIsWeb?webWidth/6.5:phoneWidth/7,
                              height: 45,
                              decoration: customDecoration.baseBackgroundDecoration(
                                  color: levProvider.filter==true?colorsConst.primary:Colors.grey.shade300,radius: 5
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: SvgPicture.asset(assets.filter,width: 15,height: 15,),
                              ),
                            ),
                          ),
                        ],
                      ),
                      levProvider.isLoading == false ?
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 150, 0, 0),
                        child: Loading(),
                      )
                      : levProvider.myLevSearch.isEmpty ?
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
                        child: CustomText(
                          text: constValue.noData, colors: colorsConst.greyClr,),)
                      : Flexible(
                        child: itemBuilder(levProvider.myLevSearch,levProvider),
                      )
                    ],
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
                  onTap: (){
                    utils.navigatePage(context, ()=>LeaveDetails(empId: data.userId.toString(), name: data.fName.toString(), role: data.role.toString(),date1: widget.date1!,date2: widget.date2!));
                  },
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
}
