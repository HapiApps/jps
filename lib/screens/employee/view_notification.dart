import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:master_code/screens/task/view_task.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../component/animated_button.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../component/map_dropdown.dart';
import '../../model/user_model.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/employee_provider.dart';
import '../common/dashboard.dart';
import '../customer/visit_report/visits_report.dart';
import '../task/search_custom_dropdown.dart';
import '../task/task_chat.dart';

class ViewNotification extends StatefulWidget {
  const ViewNotification({super.key});

  @override
  State<ViewNotification> createState() => _ViewNotificationState();
}

class _ViewNotificationState extends State<ViewNotification> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<EmployeeProvider>(context, listen: false).getNotifications(markSeen: true);
      Provider.of<EmployeeProvider>(context, listen: false).initFilterValue(true);

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var webWidth = MediaQuery.of(context).size.width * 0.5;
    var phoneWidth = MediaQuery.of(context).size.width * 0.9;

    return Consumer<EmployeeProvider>(builder: (context, empProvider, _) {
      var webHeight=MediaQuery.of(context).size.width * 0.5;
      var phoneHeight=MediaQuery.of(context).size.width * 0.95;
      return SafeArea(
        child: Scaffold(
          backgroundColor: colorsConst.bacColor,
          appBar: const PreferredSize(
            preferredSize: Size(300, 50),
            child: CustomAppbar(text: "View Notifications"),
          ),
          body: Center(
            child: SizedBox(
              width: kIsWeb ? webWidth : phoneWidth,
              child: empProvider.refresh == false
                  ? const Loading()
                  : Column(
                children: [
                  20.height,
                  Container(
                    width: kIsWeb?webHeight:phoneHeight,
                    decoration: customDecoration.baseBackgroundDecoration(
                      radius: 30,
                      color: colorsConst.primary,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: kIsWeb?webHeight/1.5:phoneHeight/1.4,
                          height: 45,
                          decoration: customDecoration.baseBackgroundDecoration(
                            radius: 30,
                            color: Colors.transparent,
                          ),
                          child: TextFormField(
                            cursorColor: colorsConst.primary,
                            onChanged: (value) {
                              setState(() {
                                empProvider.searchName = value;
                              });
                              },
                            textInputAction: TextInputAction.done,
                            controller: empProvider.search,
                            decoration: InputDecoration(
                                hintText:"Search Name",
                                hintStyle: TextStyle(
                                    color: colorsConst.primary,
                                    fontSize: 14
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon: Icon(Icons.search,color: Colors.grey,),
                                suffixIcon: empProvider.search.text.isNotEmpty?
                                GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        empProvider.searchName = "";
                                      });
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
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Consumer<EmployeeProvider>(
                                  builder: (context,empProvider, _) {
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
                                                          empProvider.datePick(
                                                            context: context,
                                                            isStartDate: true,
                                                            date: empProvider.startDate,
                                                          );
                                                        },
                                                        child: Container(
                                                          height: 30,
                                                          width:kIsWeb?webWidth/2.5:phoneWidth/2.5,
                                                          decoration: customDecoration.baseBackgroundDecoration(
                                                            color: Colors.white,
                                                            radius: 5,
                                                            borderColor: colorsConst.litGrey,
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              CustomText(text: empProvider.startDate),
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
                                                          empProvider.datePick(
                                                            context: context,
                                                            isStartDate: false,
                                                            date: empProvider.endDate,
                                                          );
                                                        },
                                                        child: Container(
                                                          height: 30,
                                                          width:kIsWeb?webWidth/2.5:phoneWidth/2.5,
                                                          decoration: customDecoration.baseBackgroundDecoration(
                                                            color: Colors.white,
                                                            radius: 5,
                                                            borderColor: colorsConst.litGrey,
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              CustomText(text: empProvider.endDate),
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
                                                    width:kIsWeb?webWidth/1.2:phoneWidth/1.2,
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
                                                      value: empProvider.type,
                                                      onChanged: (value) {
                                                        empProvider.changeType(value);
                                                      },
                                                      items: empProvider.typeList.map((list) {
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
                                              10.height,
                                              SizedBox(
                                                width:kIsWeb?webWidth/1.2:phoneWidth/1.2,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    CustomText(
                                                      text: "Employee Name",
                                                      colors: colorsConst.greyClr,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              EmployeeDropdown(
                                                callback: (){
                                                },
                                                text: empProvider.userName==""?"Name":empProvider.userName,
                                                employeeList: empProvider.activeEmps,
                                                onChanged: (UserModel? value) {
                                                  empProvider.selectUser(value!);
                                                },
                                                size: kIsWeb?webHeight:phoneHeight,),
                                              20.height,
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  CustomBtn(
                                                    width: 100,
                                                    text: 'Clear All',
                                                    callback: () {
                                                      empProvider.initFilterValue(true);
                                                      Navigator.of(context, rootNavigator: true).pop();
                                                    },
                                                    bgColor: Colors.grey.shade200,
                                                    textColor: Colors.black,
                                                  ),
                                                  CustomBtn(
                                                    width: 100,
                                                    text: 'Apply Filters',
                                                    callback: () {
                                                      empProvider.initFilterValue(false);
                                                      // empProvider.filterList();
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
                  if(empProvider.filter==true)
                    10.height,
                  if(empProvider.filter==true)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Left chips
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (empProvider.startDate != empProvider.endDate)
                                if (empProvider.startDate.isNotEmpty &&
                                    empProvider.endDate.isNotEmpty)
                                  _filterChip(
                                    "${empProvider.startDate} - ${empProvider.endDate}",
                                  ),

                              if (empProvider.type.isNotEmpty || empProvider.type!="null")
                                _filterChip(empProvider.type), // Last 7 days

                              if (empProvider.userName.isNotEmpty)
                                _filterChip(empProvider.userName),
                            ],
                          ),
                        ),
                      ],
                    ),
                  empProvider.filteredNotifyData.isEmpty
                      ? Column(
                    children: [
                      100.height,
                      CustomText(
                          text: "No Notifications Found",
                          colors: colorsConst.greyClr),
                    ],
                  )
                      : Expanded(
                    child: ListView.builder(
                      // itemCount: empProvider.notifyData.length,
                      // itemBuilder: (context, index) {
                      //   final employeeData = empProvider.notifyData[index];
                      itemCount: empProvider.filteredNotifyData.length,
                      itemBuilder: (context, index) {
                        final employeeData = empProvider.filteredNotifyData[index];
                        DateTime dateTime =
                        DateTime.parse(employeeData["created_ts"]);

                        String sectionTitle = formatCreatedDate(dateTime);

                        String time =
                        DateFormat('h:mm a').format(dateTime);

                        String title = employeeData["title"] ?? "";
                        String body = employeeData["body"] ?? "";
                        String createdBy =
                        employeeData["firstname"]?.toString() == "null"
                            ? ""
                            : employeeData["firstname"].toString();

                        String type =
                        title.toLowerCase().contains("task")
                            ? "Task"
                            : "Feedback";
                        final sortedData = empProvider.notifyData;

                        String? prevCreatedBy;
                        if (index != 0) {
                          final prevDateTime = DateTime.parse(
                              sortedData[index - 1]["created_ts"]);
                          prevCreatedBy = formatCreatedDate(prevDateTime);
                        }
                        bool showHeader = true;
                        if (index > 0) {
                          final prevDate =
                          DateTime.parse(empProvider.notifyData[index - 1]["created_ts"]);
                          showHeader =
                              formatCreatedDate(prevDate) != sectionTitle;
                        }

                        final showDateHeader = index == 0 ||
                            createdBy != prevCreatedBy;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showHeader) ...[
                              5.height,
                              CustomText(
                                text: sectionTitle,
                                colors: Colors.grey,
                              ),
                              5.height,
                            ],
                            GestureDetector(
                              onTap:(){
                                if(title.toLowerCase().contains("feedback")){
                                  utils.navigatePage(context, ()=> DashBoard(child: TaskChat(isVisit:false,
                                      taskId: empProvider.notifyData[index]["purpose_id"], assignedId: "", name: createdBy)));
                                }else if(title.toLowerCase().contains("assigned")){
                                  utils.navigatePage(context, ()=>DashBoard(child: ViewTask(date1:  DateFormat("dd-MM-yyyy").format(
                                    DateTime.parse(empProvider.notifyData[index]["created_ts"])), date2: DateFormat("dd-MM-yyyy").format(
                                      DateTime.parse(empProvider.notifyData[index]["created_ts"])), type: 'Today',)));
                                }else if(title.toLowerCase().contains("visit report")){
                                  utils.navigatePage(context, ()=> DashBoard(child: VisitReport(date1: DateFormat("dd-MM-yyyy").format(
                                      DateTime.parse(empProvider.notifyData[index]["created_ts"])), date2: DateFormat("dd-MM-yyyy").format(
                                      DateTime.parse(empProvider.notifyData[index]["created_ts"])),month: "",type: "Today",)));
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade200,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    /// 🔹 Top Row
                                    Row(
                                      children: [

                                        /// Type chip
                                        Container(
                                          padding:
                                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: type == "Task"
                                                ? const Color(0xffE8F5E9)
                                                : const Color(0xffE3F2FD),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            type,
                                            style: TextStyle(
                                              color: type == "Task"
                                                  ? const Color(0xff2E7D32)
                                                  : const Color(0xff1A85DB),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),

                                        const Spacer(),

                                        Row(
                                          children: [
                                            const Icon(Icons.circle,
                                                size: 6, color: Color(0xff7E7E7E)),
                                            6.width,
                                            CustomText(
                                              text: time,
                                              colors: Colors.grey,
                                              size: 12,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    // 12.height,
                                    // CustomText(
                                    //   text: title,
                                    //   size: 14,
                                    //   isBold: true,
                                    // ),

                                    5.height,

                                    /// 🔹 Body
                                    CustomText(
                                      text: title.toLowerCase().contains("feedback")&&body==""?"Voice Message":body,isBold: true,
                                    ),

                                    5.height,

                                    /// 🔹 Created By
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: title.toLowerCase().contains("feedback")?"Feedback sent by ":"Created by ",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xffA80007),
                                                ),
                                              ),
                                              TextSpan(
                                                text: createdBy=="null"?"Admin":createdBy,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xffA80007),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SvgPicture.asset(
                                          assets.tMessage,
                                          height: 25,width: 25,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            if (index == empProvider.notifyData.length - 1)
                              80.height,
                          ],
                        );

                        // return Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     if (showDateHeader)
                        //       Padding(
                        //         padding: const EdgeInsets.symmetric(vertical: 5),
                        //         child: CustomText(
                        //           text: createdBy,
                        //           colors: Colors.grey,
                        //         ),
                        //       ),
                        //     Container(
                        //       width: kIsWeb ? webWidth : phoneWidth,
                        //       decoration: customDecoration.baseBackgroundDecoration(
                        //         color: Colors.white,
                        //         borderColor: Colors.grey.shade200,
                        //         isShadow: true,
                        //         shadowColor: Colors.grey.shade200,
                        //         radius: 5,
                        //       ),
                        //       child: Padding(
                        //         padding: const EdgeInsets.all(10),
                        //         child: Column(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             Row(
                        //               mainAxisAlignment:
                        //               MainAxisAlignment.spaceBetween,
                        //               children: [
                        //                 Row(
                        //                   children: [
                        //                     CustomText(
                        //                       text: employeeData["firstname"].toString()=="null"?"":employeeData["firstname"].toString(),
                        //                       colors: colorsConst.appOrg,
                        //                     ),
                        //                     if(employeeData["role"].toString()!="null")
                        //                     CustomText(
                        //                       text:
                        //                       " ( ${employeeData["role"].toString()} )",
                        //                       colors: Colors.grey,
                        //                     ),
                        //                   ],
                        //                 ),
                        //                 CustomText(
                        //                   text: time,
                        //                   colors: colorsConst.blue2,
                        //                 ),
                        //               ],
                        //             ),
                        //             10.height,
                        //             CustomText(
                        //               text: employeeData["title"].toString(),
                        //             ),
                        //             10.height,
                        //             CustomText(
                        //               text: employeeData["body"].toString(),
                        //               colors: colorsConst.greyClr,
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ),
                        //     10.height,
                        //     if (index == empProvider.notifyData.length - 1)
                        //       80.height,
                        //   ],
                        // );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
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
}
