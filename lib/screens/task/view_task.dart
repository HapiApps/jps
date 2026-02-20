import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/component/custom_textfield.dart';
import 'package:master_code/component/dotted_border.dart';
import 'package:master_code/component/map_dropdown.dart';
import 'package:master_code/screens/task/add_task.dart';
import 'package:master_code/screens/task/edit_task.dart';
import 'package:master_code/screens/task/search_custom_dropdown.dart';
import 'package:master_code/screens/task/task_calendar.dart';
import 'package:master_code/screens/task/task_chat.dart';
import 'package:master_code/screens/task/task_details.dart';
import 'package:master_code/screens/task/task_report.dart';
import 'package:master_code/screens/task/visit/add_visit.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/customer_provider.dart';
import 'package:master_code/view_model/employee_provider.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:master_code/view_model/location_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../component/animated_button.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_text.dart';
import '../../component/search_drop_down.dart';
import '../../model/customer/customer_model.dart';
import '../../model/task/task_data_model.dart';
import '../../model/user_model.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/constant/local_data.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/task_provider.dart';
import '../common/dashboard.dart';
import '../common/home_page.dart';
import '../expense/create_expense.dart';

class ViewTask extends StatefulWidget {
  final String date1;
  final String date2;
  final String type;
  const ViewTask({super.key,required this.date1, required this.date2, required this.type});

  @override
  State<ViewTask> createState() => _ViewTaskState();
}

class _ViewTaskState extends State<ViewTask> with SingleTickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();
  late TabController tabController;
  @override
  void initState() {
    super.initState();
    tabController=TabController(length:2, vsync: this);
    tabController.addListener(() {
      _myFocusScopeNode.unfocus();
      tabController.index;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).search.clear();
      Provider.of<TaskProvider>(context, listen: false).search2.clear();
      Provider.of<EmployeeProvider>(context, listen: false).filterEmps();
      if(kIsWeb){
        Provider.of<TaskProvider>(context, listen: false).getTaskType(false);
        Provider.of<TaskProvider>(context, listen: false).getTaskStatuses();
        Provider.of<CustomerProvider>(context, listen: false).getLeadCategory();
        Provider.of<CustomerProvider>(context, listen: false).getVisitType();
        Provider.of<CustomerProvider>(context, listen: false).getCmtType();
      }else{
        Provider.of<TaskProvider>(context, listen: false).getAllTypes();
        Provider.of<TaskProvider>(context, listen: false).getTypeSts();
        Provider.of<CustomerProvider>(context, listen: false).getLead();
        Provider.of<CustomerProvider>(context, listen: false).getVisit();
        Provider.of<CustomerProvider>(context, listen: false).getCommentType();
      }
    });
  }
  @override
  void dispose() {
    tabController.dispose();
    _myFocusScopeNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var webHeight=MediaQuery.of(context).size.width * 0.5;
    var phoneHeight=MediaQuery.of(context).size.width * 0.95;
    return Consumer3<TaskProvider,HomeProvider,LocationProvider>(
        builder: (context, taskProvider, homeProvider,locPvr, _) {
          return FocusScope(
            node: _myFocusScopeNode,
            child: Scaffold(
              backgroundColor: colorsConst.bacColor,
              appBar: PreferredSize(
                preferredSize: const Size(300, 50),
                child: CustomAppbar(text: "View Tasks",
                  callback: (){
                    _myFocusScopeNode.unfocus();
                    homeProvider.updateIndex(0);
                    utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
                  },
                  isButton: localData.storage.read("role") =="1"?true:false,
                  buttonCallback:  () {
                    taskProvider.typeList.removeWhere((e) => e['value'] == 'All');
                    _myFocusScopeNode.unfocus();
                    utils.navigatePage(context, ()=>const DashBoard(child: AddTask()));
                  },),
              ),
              body: PopScope(
                canPop: false,
                onPopInvoked: (bool didPop) {
                  _myFocusScopeNode.unfocus();
                  homeProvider.updateIndex(0);
                  if (!didPop) {
                    utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
                  }
                },
                child: Center(
                  child: SizedBox(
                    width: kIsWeb?webHeight:phoneHeight,
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                            decoration: customDecoration.baseBackgroundDecoration(
                              color: Colors.white,
                              radius: 30,
                            ),
                            child: TabBar(
                              indicator: customDecoration.baseBackgroundDecoration(
                                  radius: 30,
                                  color:colorsConst.primary
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.black,
                              controller: tabController,
                              tabs:  [
                                Tab(child:Text("Tasks",style:TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily:'Lato'))),
                                Tab(child:Text("Calendar",style:TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily:'Lato'))),
                              ],
                            )
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: tabController,
                            children: [
                              ViewfilterUserData(date1: widget.date1,date2:widget.date2,type:widget.type),
                              TaskCalendar()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}



class ViewfilterUserData extends StatefulWidget {
  final String date1;
  final String date2;
  final String type;
  const ViewfilterUserData({super.key,required this.date1, required this.date2, required this.type});

  @override
  State<ViewfilterUserData> createState() => _ViewfilterUserDataState();
}

class _ViewfilterUserDataState extends State<ViewfilterUserData>{
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.initFilterValue(true,date1:widget.date1,date2:widget.date2,type:widget.type);
      taskProvider.dataSource = _getDataSource();
      taskProvider.getAllTask(true,date1:widget.date1,date2:widget.date2,type:widget.type);
      if(localData.storage.read("role")=="1"){
        taskProvider.getTaskUsers();
      }
    });
  }
  @override
  void dispose() {
    _myFocusScopeNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var webHeight=MediaQuery.of(context).size.width * 0.5;
    var phoneHeight=MediaQuery.of(context).size.width * 0.95;
    return Consumer3<TaskProvider,HomeProvider,LocationProvider>(
        builder: (context, taskProvider, homeProvider,locPvr, _) {
          return FocusScope(
            node: _myFocusScopeNode,
            child: Scaffold(
              backgroundColor: Color(0xffEAEAEA),
              body: taskProvider.viewRefresh==false?
              const Loading():
              Column(
                children: [
                  10.height,Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: kIsWeb?webHeight/1.2:phoneHeight/1.2,
                        decoration: customDecoration.baseBackgroundDecoration(
                          radius: 30,
                          color: colorsConst.primary,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: kIsWeb?webHeight/1.5:phoneHeight/1.5,
                              height: 45,
                              decoration: customDecoration.baseBackgroundDecoration(
                                radius: 30,
                                color: Colors.transparent,
                              ),
                              child: TextFormField(
                                cursorColor: colorsConst.primary,
                                onChanged: (value) {
                                  taskProvider.searchTask(value.toString());
                                },
                                textInputAction: TextInputAction.done,
                                controller: taskProvider.search,
                                decoration: InputDecoration(
                                    hintText:"Search Name or ${constValue.customer}",
                                    hintStyle: TextStyle(
                                        color: colorsConst.primary,
                                        fontSize: 14
                                    ),
                                    fillColor: Colors.white,
                                    filled: true,
                                    prefixIcon: Icon(Icons.search,color: Colors.grey,),
                                    suffixIcon: taskProvider.search.text.isNotEmpty?
                                    GestureDetector(
                                        onTap: (){
                                          taskProvider.search.clear();
                                          taskProvider.searchTask("");
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
                            InkWell(
                              onTap: (){
                                _myFocusScopeNode.unfocus();
                                if (!taskProvider.typeList.any((e) => e['value'] == 'All')) {
                                  taskProvider.typeList.insert(0, {
                                    "id": "",
                                    "value": "All",
                                  });
                                }
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Consumer3<TaskProvider,CustomerProvider,EmployeeProvider>(
                                      builder: (context, taskProvider,cusPvr,empProvider, _) {
                                        return AlertDialog(
                                          actions: [
                                            SizedBox(
                                              width: kIsWeb?MediaQuery.of(context).size.width*0.3:MediaQuery.of(context).size.width*0.9,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                              taskProvider.filterPick(
                                                                context: context,
                                                                isStartDate: true,
                                                                date: taskProvider.startDate,
                                                              );
                                                            },
                                                            child: Container(
                                                              height: 30,
                                                              width: kIsWeb?webHeight/2.8:phoneHeight/2.8,
                                                              decoration: customDecoration.baseBackgroundDecoration(
                                                                color: Colors.white,
                                                                radius: 5,
                                                                borderColor: colorsConst.litGrey,
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  CustomText(text: taskProvider.startDate),
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
                                                              taskProvider.filterPick(
                                                                context: context,
                                                                isStartDate: false,
                                                                date: taskProvider.endDate,
                                                              );
                                                            },
                                                            child: Container(
                                                              height: 30,
                                                              width: kIsWeb?webHeight/2.8:phoneHeight/2.8,
                                                              decoration: customDecoration.baseBackgroundDecoration(
                                                                color: Colors.white,
                                                                radius: 5,
                                                                borderColor: colorsConst.litGrey,
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  CustomText(text: taskProvider.endDate),
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
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CustomText(
                                                        text: "Select Date Range",
                                                        colors: colorsConst.greyClr,
                                                        size: 12,
                                                      ),
                                                      Container(
                                                          height: 30,
                                                          width: kIsWeb?webHeight:phoneHeight,
                                                          decoration: customDecoration.baseBackgroundDecoration(
                                                            radius: 5,
                                                            color: Colors.white,
                                                            borderColor: colorsConst.litGrey,
                                                          ),
                                                          child: DropdownButton<String>(
                                                            value: taskProvider.filterTypeList
                                                                .contains(taskProvider.filterType)
                                                                ? taskProvider.filterType
                                                                : null,
                                                            isExpanded: true,
                                                            underline: const SizedBox(),
                                                            icon: const Icon(Icons.keyboard_arrow_down_outlined),
                                                            iconEnabledColor: colorsConst.greyClr,
                                                            onChanged: (value) {
                                                              if (value != null) {
                                                                taskProvider.changeFilterType(value);
                                                              }
                                                            },
                                                            items: taskProvider.filterTypeList
                                                                .toSet() // removes duplicates
                                                                .map<DropdownMenuItem<String>>((list) {
                                                              return DropdownMenuItem<String>(
                                                                value: list,
                                                                child: CustomText(
                                                                  text: "  $list",
                                                                  colors: Colors.black,
                                                                  isBold: false,
                                                                ),
                                                              );
                                                            }).toList(),
                                                          )
                                                      ),
                                                    ],
                                                  ),
                                                  10.height,
                                                  // CustomText(
                                                  //   text: "Employee Name",
                                                  //   colors: colorsConst.greyClr,
                                                  //   size: 12,
                                                  // ),
                                                  SearchCustomDropdown(
                                                      text: "Employee Name",
                                                      hintText: taskProvider.assignedId==""?"":taskProvider.assignedNames,
                                                      valueList: empProvider.activeEmps,
                                                      onChanged: (value) {},
                                                      width: kIsWeb?webHeight:phoneHeight),
                                                  // EmployeeDropdown(
                                                  //   callback: (){
                                                  //   },
                                                  //   text: taskProvider.userName==""?"Name":taskProvider.userName,
                                                  //   employeeList: empProvider.activeEmps,
                                                  //   onChanged: (UserModel? value) {
                                                  //     taskProvider.selectUser(value!);
                                                  //   },
                                                  //   size: kIsWeb?webHeight:phoneHeight,),
                                                  10.height,
                                                  MapDropDown(saveValue: taskProvider.type, hintText: constValue.type,
                                                      onChanged: (value){
                                                        taskProvider.checkFilterType(value);
                                                      }, dropText: 'value',
                                                      list: taskProvider.typeList.toSet().toList()),
                                                  CustomText(
                                                    text: constValue.companyName,
                                                    colors: colorsConst.greyClr,
                                                    size: 12,
                                                  ),
                                                  // 2.height,
                                                  CustomerDropdown(
                                                    text: taskProvider.companyName==""?constValue.companyName:taskProvider.companyName,
                                                    isRequired: true,hintText: false,
                                                    employeeList: cusPvr.customer,
                                                    onChanged: (CustomerModel? value) {
                                                      taskProvider.changeName(value);
                                                    }, size: kIsWeb?webHeight:phoneHeight,),
                                                  20.height,
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      CustomBtn(
                                                        width: 100,
                                                        text: 'Clear All',
                                                        callback: () {
                                                          taskProvider.initFilterValue(true,date1:widget.date1,date2:widget.date2,type:widget.type);
                                                          Navigator.of(context, rootNavigator: true).pop();
                                                        },
                                                        bgColor: Colors.grey.shade200,
                                                        textColor: Colors.black,
                                                      ),
                                                      CustomBtn(
                                                        width: 100,
                                                        text: 'Apply Filters',
                                                        callback: () {
                                                          taskProvider.initFilterValue(false);
                                                          taskProvider.filterList();
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
                            taskProvider.downloadAllTask(context);
                          },
                          child: SvgPicture.asset(assets.tDownload,width: 27,height: 27,)),
                      // CustomLoadingButton(callback: (){
                      // }, text: "PF", isLoading: false,
                      //     backgroundColor: colorsConst.primary, radius: 5, width: 60)
                    ],
                  )
                  ,10.height,
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if(taskProvider.isFilter==true)
                            const Text(
                              "Filters Selected",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Total Tasks : ${taskProvider.filterUserData.length}",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        6.height,
                        if(taskProvider.isFilter==true)

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Left chips
                            Expanded(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (taskProvider.startDate != taskProvider.endDate)
                                  if (taskProvider.startDate.isNotEmpty &&
                                      taskProvider.endDate.isNotEmpty)
                                    _filterChip(
                                      "${taskProvider.startDate} - ${taskProvider.endDate}",
                                    ),

                                  if (taskProvider.filterType.isNotEmpty || taskProvider.filterType!="null")
                                    _filterChip(taskProvider.filterType), // Last 7 days

                                  if (taskProvider.assignedNames.isNotEmpty)
                                    _filterChip(taskProvider.assignedNames),

                                  if (taskProvider.fType.isNotEmpty && taskProvider.fType!="null")
                                    _filterChip(taskProvider.fType),

                                  if (taskProvider.companyName.isNotEmpty)
                                    _filterChip(taskProvider.companyName),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // if(taskProvider.filterUserData.isNotEmpty)
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     InkWell(
                  //         onTap: () {
                  //           taskProvider.showDatePickerDialog(context);
                  //         },
                  //         child: Container(
                  //           height: 45,
                  //           width: kIsWeb?webHeight/2:phoneHeight/1.6,
                  //           decoration: customDecoration.baseBackgroundDecoration(
                  //               color: Colors.white,
                  //               radius: 5,borderColor: Colors.grey.shade200
                  //           ),
                  //           child: Row(
                  //             children: [
                  //               5.width,
                  //               CustomText(
                  //                   text: "${taskProvider.startDate}${taskProvider.startDate!=taskProvider.endDate? " To ${taskProvider.endDate}": ""}"),10.width,
                  //               SvgPicture.asset(assets.calendar2)
                  //             ],
                  //           ),
                  //         )),
                  //     // Padding(
                  //     //   padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  //     //   child: MapDropDown(saveValue: taskProvider.status, hintText: "Status",
                  //     //       width: kIsWeb?webHeight/1.5:phoneHeight/4,isHint: false,
                  //     //       onChanged: (value){
                  //     //         taskProvider.changeFilterStatus(value);
                  //     //       }, dropText: "value", list: taskProvider.statusList),
                  //     // ),
                  //     CustomLoadingButton(callback: (){
                  //       taskProvider.downloadAllTask(context);
                  //     }, text: "Download", isLoading: false,
                  //         backgroundColor: colorsConst.primary, radius: 5, width: kIsWeb?webHeight/2:phoneHeight/3)
                  //   ],
                  // ),
                  taskProvider.filterUserData.isEmpty||(taskProvider.statusId!=""&&taskProvider.matched==0)?
                  Column(
                    children: [
                      100.height,
                      CustomText(text: "No Task Found",
                          colors: colorsConst.greyClr)
                    ],
                  ) :
                  Expanded(
                    child: ListView.builder(
                      itemCount: taskProvider.filterUserData.length,
                      itemBuilder: (context, index) {
                        final sortedData = taskProvider.filterUserData;
                        final data = sortedData[index];
                        String timestamp = data.createdTs.toString();
                        DateTime dateTime = DateTime.parse(timestamp);

                        DateTime today = DateTime.now();
                        String headerText;

                        if (dateTime.year == today.year &&
                            dateTime.month == today.month &&
                            dateTime.day == today.day) {
                          headerText = "Today";
                        } else if (dateTime.isAfter(today.subtract(const Duration(days: 1))) &&
                            dateTime.isBefore(today)) {
                          headerText = "Yesterday";
                        } else {
                          headerText = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                        }

                        String createdBy =
                            "${dateTime.day}/${dateTime.month}/${dateTime.year}";

                        final showDateHeader =
                            index == 0 || createdBy != getCreatedDate(sortedData[index - 1]);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showDateHeader)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                child: CustomText(
                                  text: headerText,
                                  colors: colorsConst.greyClr,
                                  size: 13,
                                  isBold: true,
                                ),
                              ),
                            _taskCard(data),
                            if (index == taskProvider.filterUserData.length - 1)
                              50.height,
                          ],
                        );
                      },
                    ),
                  ),

                  // Expanded(
                  //   child: ListView.builder(
                  //       itemCount: taskProvider.filterUserData.length,
                  //       itemBuilder: (context, index) {
                  //         final sortedData = taskProvider.filterUserData;
                  //         final data = sortedData[index];
                  //         var createdBy = "";
                  //         String timestamp = data.createdTs.toString();
                  //         DateTime dateTime = DateTime.parse(timestamp);
                  //         String dayOfWeek = DateFormat('EEEE').format(dateTime);
                  //         DateTime today = DateTime.now();
                  //         if (dateTime.day == today.day && dateTime.month == today.month && dateTime.year == today.year) {
                  //           dayOfWeek = 'Today';
                  //         } else if (dateTime.isAfter(today.subtract(const Duration(days: 1))) &&
                  //             dateTime.isBefore(today)) {
                  //           dayOfWeek = 'Yesterday';
                  //         } else {
                  //           dayOfWeek = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                  //         }
                  //         createdBy = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                  //         final showDateHeader = index == 0 || createdBy != getCreatedDate(sortedData[index - 1]);
                  //         return InkWell(
                  //           onTap: (){
                  //             _myFocusScopeNode.unfocus();
                  //             Provider.of<HomeProvider >(context, listen: false).panelClose();
                  //             utils.navigatePage(context, ()=>DashBoard(child: TaskDetails(
                  //                 data:data,isDirect:true,coId: "0", numberList: const [])));
                  //           },
                  //           child: Column(
                  //             children: [
                  //               if (showDateHeader)
                  //                 CustomText(
                  //                     text: dayOfWeek,
                  //                     colors: colorsConst.greyClr
                  //                 ),
                  //               taskProvider.statusId==""?
                  //               detail(
                  //                   width: kIsWeb?webHeight:phoneHeight,
                  //                   data: data, callBack: () async {
                  //                 _myFocusScopeNode.unfocus();
                  //                 if(locPvr.latitude!=""&&locPvr.longitude!=""){
                  //                   if(taskProvider.checkAtt==""){
                  //                     taskProvider.signDialog(context: context,
                  //                       img: taskProvider.profile,
                  //                       onTap:(newImg){
                  //                         taskProvider.profilePick(newImg);
                  //                         taskProvider.taskAttDirect(
                  //                             context,
                  //                             status:data.isChecked.toString()=="null"||data.isChecked.toString()=="2"?"1":"2",
                  //                             taskId: data.id.toString(),
                  //                             lat:locPvr.latitude,
                  //                             lng:locPvr.longitude);
                  //                       },
                  //                     );
                  //                   }
                  //                   else if(taskProvider.checkAtt==data.id.toString()){
                  //                     taskProvider.signDialog(context: context,
                  //                       img: taskProvider.profile,
                  //                       onTap:(newImg){
                  //                         taskProvider.profilePick(newImg);
                  //                         taskProvider.taskAttDirect(
                  //                             context,
                  //                             status:data.isChecked.toString()=="null"||data.isChecked.toString()=="2"?"1":"2",
                  //                             taskId: data.id.toString(),
                  //                             lat:locPvr.latitude,
                  //                             lng:locPvr.longitude);
                  //                       },
                  //                     );
                  //                   }else{
                  //                     utils.showWarningToast(context, text: "Please check out previous ${taskProvider.checkAttName} task");
                  //                   }
                  //                 }else{
                  //                   utils.showWarningToast(context, text: "Check your location accuracy.");
                  //                   await locPvr.manageLocation(context, true);
                  //                 }
                  //               })
                  //                   :taskProvider.statusId!=""&&taskProvider.statusId==data.statval?
                  //               detail(
                  //                   width: kIsWeb?webHeight:phoneHeight,
                  //                   data: data, callBack: () async {
                  //                 _myFocusScopeNode.unfocus();
                  //                 if(locPvr.latitude!=""&&locPvr.longitude!=""){
                  //                   if(taskProvider.checkAtt==""){
                  //                     taskProvider.signDialog(context: context,
                  //                       img: taskProvider.profile,
                  //                       onTap:(newImg){
                  //                         taskProvider.profilePick(newImg);
                  //                         taskProvider.taskAttDirect(
                  //                             context,
                  //                             status:data.isChecked.toString()=="null"||data.isChecked.toString()=="2"?"1":"2",
                  //                             taskId: data.id.toString(),
                  //                             lat:locPvr.latitude,
                  //                             lng:locPvr.longitude);
                  //                       },
                  //                     );
                  //                   }
                  //                   else if(taskProvider.checkAtt==data.id.toString()){
                  //                     taskProvider.signDialog(context: context,
                  //                       img: taskProvider.profile,
                  //                       onTap:(newImg){
                  //                         taskProvider.profilePick(newImg);
                  //                         taskProvider.taskAttDirect(
                  //                             context,
                  //                             status:data.isChecked.toString()=="null"||data.isChecked.toString()=="2"?"1":"2",
                  //                             taskId: data.id.toString(),
                  //                             lat:locPvr.latitude,
                  //                             lng:locPvr.longitude);
                  //                       },
                  //                     );
                  //                   }else{
                  //                     utils.showWarningToast(context, text: "Please check out previous ${taskProvider.checkAttName} task");
                  //                   }
                  //                 }else{
                  //                   utils.showWarningToast(context, text: "Check your location accuracy.");
                  //                   await locPvr.manageLocation(context, true);
                  //                 }
                  //               }):const SizedBox.shrink(),
                  //               if(index==taskProvider.filterUserData.length-1)
                  //                 50.height
                  //             ],
                  //           ),
                  //         );
                  //         // :0.width;
                  //       }),
                  // ),
                ],
              ),
            ),
          );
        });
  }
  Widget _filterChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xff353535),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xffF5F5F5),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }


  Widget _taskCard(dynamic data) {
    Color priorityBg;
    Color priorityTextColor;
    String priorityText;
    switch (data.level.toString()) {
      case "High":
        priorityBg = const Color(0xffFEF2F2);
        priorityTextColor = Colors.red;
        priorityText = "High";
        break;
      case "Normal":
        priorityBg = const Color(0xffF2F6FE);
        priorityTextColor = const Color(0xff1A85DB);
        priorityText = "Normal";
        break;
      case "Immediate":
        priorityBg = const Color(0xffFBF2FE);
        priorityTextColor = const Color(0xffB35CFF);
        priorityText = "Immediate";
        break;
      default:
        priorityBg = const Color(0xffF2F6FE);
        priorityTextColor = Colors.grey;
        priorityText = "Normal";
    }
    //final Color roleColor = const Color(0xffFF8E1C);
    final Color roleColor =
    data.role.toString() == "1"
        ? const Color(0xffA80007)
        : const Color(0xffFF8E1C);

    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: (){
          _myFocusScopeNode.unfocus();
          Provider.of<HomeProvider>(context, listen: false).panelClose();
          utils.navigatePage(
            context, () => DashBoard(
            child: TaskDetails(
              data: data,
              isDirect: true,
              coId: "0",
              numberList: const [],
            ),
          ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: kIsWeb?webWidth/1.2:phoneWidth/1.2,
                          child: CustomText(
                            text: data.taskTitle ?? "",
                            size: 14,
                            isBold: true,
                            colors: Colors.black,
                          ),
                        ),
                        if(localData.storage.read("role") =="1")
                        InkWell(onTap: (){
                          utils.navigatePage(context, ()=> DashBoard(child: EditTask(
                              data: data,isDirect: false,numberList: [])));
                        }, child: SvgPicture.asset(assets.tEdit,width: 20,height: 20,))
                      ],
                    ),

                    const SizedBox(height: 6),

                    /// ASSIGNED USERS
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: formatAssignedNames(data.assignedNames).split('+').first.trim(),
                            style: const TextStyle(
                              color: Color(0xff007AAE),
                              fontSize: 15,
                            ),
                          ),
                          if (formatAssignedNames(data.assignedNames).contains('+'))
                            TextSpan(
                              text: " +${formatAssignedNames(data.assignedNames)
                                      .split('+')
                                      .last
                                      .trim()}",
                              style: const TextStyle(
                                color: Color(0xff007AAE),
                                fontSize: 11,
                              ),
                            ),
                          if (formatAssignedNames(data.assignedNames).contains('+'))
                            const TextSpan(
                              text: " others",
                              style: TextStyle(
                                color: Color(0xff007AAE),
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    /// COMPANY + TASK TYPE
                    Row(
                      children: [
                        _infoBlock("Company", data.projectName ?? ""),
                        const SizedBox(width: 40),
                        _infoBlock("Task Type", data.type ?? ""),
                      ],
                    ),

                    const SizedBox(height: 5),
                    const Divider(),

                    /// DATE + CREATED BY
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset("assets/images/clock.png"),
                            const SizedBox(width: 6),
                            CustomText(
                              //text: DateFormat("dd MMM yyyy, hh:mm a").format(DateTime.parse(data.taskDate)),
                              text: data.taskDate,
                              size: 13,
                            ),
                          ],
                        ),
                        5.width,
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Container(height: 16, width: 1, color: Colors.grey),
                        ),
                        Row(
                          children: [
                            CustomText(
                              text: "Created by:  ",
                              size: 11,
                              isBold: true,
                            ),
                            CustomText(
                              text: "${data.creator ?? ""}",
                              size: 15,
                              isBold: true,
                            ),
                          ],
                        ),

                      ],
                    ),
                    const Divider(),
                    /// STATUS + PRIORITY
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _statusChip(
                          data.statval ?? "",
                          data.statval == "Completed"
                              ? const Color(0xff1FAF38)
                              : Color(0xff007AAE),
                          Colors.white,
                        ),
                        20.width,
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: priorityBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.circle,
                                  size: 8, color: priorityTextColor),
                              const SizedBox(width: 6),
                              CustomText(
                                text: priorityText,
                                colors: priorityTextColor,
                                size: 13,
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(onTap: (){
                          utils.navigatePage(context, ()=> DashBoard(child: TaskChat(
                              taskId: data.id.toString(), assignedId: data.assigned.toString(), name: data.creator.toString())));
                        }, child: SvgPicture.asset(assets.tMessage,width: 20,height: 20,)),
                      ],
                    ),
                  ],
                ),
              ),

              /// BOTTOM BAR
              Container(
                height: 32,
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                decoration: BoxDecoration(
                  color: roleColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
                      // InkWell(
                      //   onTap: (){
                      //                 utils.navigatePage(context, ()=> DashBoard(child: CreateExpense(taskId: data.id.toString(),data: data,coId: "",numberList: const [], companyName: data.projectName.toString(), type: data.type.toString(), desc: data.taskTitle.toString(),
                      //                     date: data.taskDate.toString())));
                      //   },
                      //     child: Center(child: CustomText(text: "         Add Expense", colors: Colors.white))),
                      // VerticalDivider(color: Colors.white),
                      GestureDetector(
                        onTap: (){
                                      utils.navigatePage(context, ()=> DashBoard(child:
                                      AddVisit(taskId:data.id.toString(),companyId: data.companyId.toString(),companyName: data.projectName.toString(),
                                          numberList: const [],isDirect: true, type: data.type.toString(), desc: data.taskTitle.toString())));
                        },
                        child: Center(child: CustomText(text: "Add Visit", colors: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  String formatAssignedNames(String? names) {
    if (names == null || names.trim().isEmpty) return "";

    List<String> nameList =
    names.split(',').map((e) => e.trim()).toList();

    if (nameList.length <= 4) {
      return nameList.join(', ');
    }

    final firstFour = nameList.take(4).join(', ');
    final remainingCount = nameList.length - 4;

    return "$firstFour +$remainingCount";
  }

  Widget _statusChip(String text, Color bg, Color txt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomText(
        text: text,
        colors: txt,
        size: 11,
      ),
    );
  }

  Widget _infoBlock(String title, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$title\n",
            style: GoogleFonts.lato(
              fontSize: 12,
              color: const Color(0xff7E7E7E),
              fontWeight: FontWeight.bold
            ),
          ),
          TextSpan(
            text: value,
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
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
  String getCreatedDate(data) {
    final timestamp = data.createdTs.toString();
    final dateTime = DateTime.parse(timestamp);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
  Widget detail({required double width, required TaskData data,required VoidCallback callBack}){
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Container(
        width: width,
        // decoration: customDecoration.baseBackgroundDecoration(
        //     color: Colors.white,radius: 10
        // ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),

          // shadow
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],

          // top border color (blue line)
          border: Border(
            top: BorderSide(
              color: data.statval.toString().contains("ompleted")?Colors.green:Colors.blue,
              width: 4,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Container(
                    //   width: 3,
                    //   decoration: BoxDecoration(
                    //     color: data.statval.toString().contains("ompleted")?Colors.green:Colors.blue,
                    //     borderRadius: const BorderRadius.only(
                    //       topLeft: Radius.circular(50),
                    //       bottomLeft: Radius.circular(50),
                    //     ),
                    //   ),
                    //   height: 100,),
                    // kIsWeb?10.width:
                    // 5.width,
                    SizedBox(
                      width: width,
                      // color: Colors.yellow,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // 5.height,
                            //   Row(
                            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //     children: [
                            //       CustomText(text: data.taskDate.toString(),colors: colorsConst.greyClr,),
                            //       Row(
                            //         children: [
                            //           CircleAvatar(backgroundColor: data.expenseReportCount.toString()=="0"?colorsConst.red2:colorsConst.green2,radius: 4,),
                            //           2.width,
                            //           CustomText(text: "Expense",colors: data.expenseReportCount.toString()=="0"?colorsConst.red2:colorsConst.green2,isItalic: true,),10.width,
                            //           CircleAvatar(backgroundColor: data.visitReportCount.toString()=="0"?colorsConst.red2:colorsConst.green2,radius: 4,),2.width,
                            //           CustomText(text: "Visit",colors: data.visitReportCount.toString()=="0"?colorsConst.red2:colorsConst.green2,isItalic: true),
                            //         ],
                            //       ),
                            //     ],
                            //   ),5.height,
                            Row(
                              children: [
                                CustomText(text: "Service Date ",colors: colorsConst.greyClr,isBold: true),
                                CustomText(text: data.taskDate.toString()),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CustomText(text: data.projectName.toString()=="null"?"":data.projectName.toString(),isBold: true,),
                                    if(data.projectName.toString()!="null")
                                    CustomText(text: " - ",isBold: true),
                                    CustomText(text: data.type.toString().trim(),isBold: true),
                                  ],
                                ),
                                if(localData.storage.read("role") =="1")
                                  IconButton(icon: SvgPicture.asset(assets.tEdit,width: 20,height: 20,),onPressed: (){
                                  utils.navigatePage(context, ()=> DashBoard(child: EditTask(
                                      data: data,isDirect:true, numberList: const [])));
                                },)
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(text: "ASSIGNED TO",colors: colorsConst.greyClr,isBold: true),
                                CustomText(text: data.assignedNames.toString().trim()),
                              ],
                            ),3.height,
                            Divider(color: Colors.grey.shade200,),3.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(text: "CREATED BY",colors: colorsConst.greyClr,isBold: true),
                                CustomText(text: data.creator.toString().trim()),
                              ],
                            ),3.height,
                            Divider(color: Colors.grey.shade200,),
                            // Row(
                            //   children: [
                            //     CircleAvatar(backgroundColor: data.statval.toString().contains("ompleted")?Colors.green:Colors.blue,radius: 4,),2.width,
                            //   ],
                            // ),5.height,
                            // CustomText(text: data.taskTitle.toString(),colors: Colors.grey,),5.height
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: customDecoration.baseBackgroundDecoration(
                        color: data.statval.toString().contains("ompleted")?Colors.green:Colors.grey,
                        radius: 30
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: CustomText(text: "${data.statval==""?"-":data.statval}",colors: Colors.white,),
                    ),
                  ),
                Row(
                  children: [
                    Container(
                        decoration: customDecoration.baseBackgroundDecoration(
                            color: data.level=='High'?Colors.red.shade50:data.level=='Immediate'?Colors.orange.shade50:Colors.pink.shade50,
                            radius: 10
                        ),
                        child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        children: [
                          Icon(Icons.circle,color: data.level=='High'?Colors.red:data.level=='Immediate'?Colors.orange:Colors.pink,size: 10,),5.width,
                          CustomText(text: "${data.level}",colors: data.level=='High'?Colors.red:data.level=='Immediate'?Colors.orange:Colors.pink),
                        ],
                      ),
                    )),
                    Icon(Icons.add),
                    IconButton(onPressed: (){
                      utils.navigatePage(context, ()=> DashBoard(child: TaskChat(
                          taskId: data.id.toString(), assignedId: data.assigned.toString(), name: data.creator.toString())));
                    }, icon: SvgPicture.asset(assets.tMessage,width: 10,height: 10,)),
                  ],
                ),
                ],
              ),
            ),
            // const Padding(
            //   padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
            //   child: DotLine(),
            // ),
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(kIsWeb?10:5, 0, 5, 0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       if(data.assignedNames.toString()!="null")
            //         SizedBox(
            //           // color:Colors.pinkAccent,
            //             width: kIsWeb?MediaQuery.of(context).size.width*0.3:MediaQuery.of(context).size.width*0.6,
            //             child: CustomText(text: data.assignedNames.toString())),
            //       if((localData.storage.read("role")=="1"&&data.assignedNames.toString().contains(localData.storage.read("f_name"))||localData.storage.read("role")!="1")&&(!kIsWeb&&!data.statval.toString().contains("ompleted")))
            //         SizedBox(
            //           width:MediaQuery.of(context).size.width*0.3,
            //           height: 30,
            //           child: ElevatedButton(
            //             style: ElevatedButton.styleFrom(
            //                 backgroundColor: data.isChecked.toString()=="null"?colorsConst.litGrey
            //                     :data.isChecked.toString()=="2"?colorsConst.litGrey:colorsConst.appGreen,
            //                 shape: const StadiumBorder()
            //             ),
            //             onPressed: callBack,
            //             child: Row(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //                 Icon(Icons.location_on_outlined,color: data.isChecked.toString()=="null"?Colors.black: data.isChecked.toString()=="2"?Colors.black: Colors.white,size: 15,),
            //                 CustomText(text: data.isChecked.toString()=="null"?"Check In":data.isChecked.toString()=="1"?"Check Out":"Check In",
            //                   colors: data.isChecked.toString()=="null"?Colors.black:data.isChecked.toString()=="2"?Colors.black: Colors.white,isBold: true,),
            //               ],
            //             ),
            //           ),
            //         ),
            //       // if(data.statval.toString().contains("ompleted")||kIsWeb)
            //       //   TextButton(
            //       //       onPressed: (){
            //       //         _myFocusScopeNode.unfocus();
            //       //         utils.navigatePage(context, ()=>DashBoard(child:
            //       //         TaskReport(taskId: data.id.toString(),coId: data.companyId.toString(),numberList: const [], isTask: true,
            //       //           coName: data.projectName.toString(),description: data.taskTitle.toString(),type: data.type.toString(),
            //       //           callback: () {
            //       //             Future.microtask(() => Navigator.pop(context));
            //       //           }, index: 0,
            //       //         )));
            //       //       },
            //       //       child: CustomText(text: "View Report",colors: colorsConst.appDarkGreen,)),
            //     ],
            //   ),
            // ),
            // if(!kIsWeb)
            //   Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       TextButton(
            //           onPressed: (){
            //             _myFocusScopeNode.unfocus();
            //             utils.navigatePage(context, ()=> DashBoard(child: CreateExpense(taskId: data.id.toString(),data: data,coId: "",numberList: const [], companyName: data.projectName.toString(), type: data.type.toString(), desc: data.taskTitle.toString(),
            //                 date: data.taskDate.toString())));
            //           },
            //           child: CustomText(text: "Add Expense",colors: colorsConst.blueClr,)),
            //       TextButton(
            //           onPressed: (){
            //             _myFocusScopeNode.unfocus();
            //             utils.navigatePage(context, ()=> DashBoard(child:
            //             AddVisit(taskId:data.id.toString(),companyId: data.companyId.toString(),companyName: data.projectName.toString(),
            //                 numberList: const [],isDirect: true, type: data.type.toString(), desc: data.taskTitle.toString())));
            //           },
            //           child: CustomText(text: "Add Visit Report",colors: colorsConst.bankColor,)),
            //       TextButton(
            //           onPressed: (){
            //             _myFocusScopeNode.unfocus();
            //             // homeProvider.showTaskType(5);
            //             // homeProvider.changeTaskList(taskId: data.id.toString(),coId: data.companyId.toString(),numberList: [],isDirect: true);
            //
            //             utils.navigatePage(context, ()=>DashBoard(child:
            //             TaskReport(taskId: data.id.toString(),coId: data.companyId.toString(),numberList: const [], isTask: true,
            //               coName: data.projectName.toString(),description: data.taskTitle.toString(),type: data.type.toString(),
            //               callback: () {
            //                 Future.microtask(() => Navigator.pop(context));
            //               }, index: 0,
            //             )));
            //           },
            //           child: CustomText(text: "View Report",colors: colorsConst.appDarkGreen,)),
            //     ],
            //   ),
          ],
        ),
      ),
    );
  }
  _DataSource _getDataSource() {
    List<Appointment> appointments = <Appointment>[];
    return _DataSource(appointments);
  }

}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}