import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:master_code/screens/task/task_chat.dart';
import 'package:master_code/screens/task/task_details.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../model/task/task_data_model.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/task_provider.dart';
import '../common/dashboard.dart';

class TaskCalendar extends StatefulWidget {
  const TaskCalendar({super.key});

  @override
  CalendarAppointment createState() => CalendarAppointment();
}

class CalendarAppointment extends State<TaskCalendar> {
  final CalendarController _calendarController = CalendarController();

  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.95;
    final DateTime now = DateTime.now();
    final DateTime firstDayOfYear = DateTime(now.year-1, 12, 1);
    final DateTime lastDayOfYear = DateTime(now.year, 12, 31);
    return Consumer<TaskProvider>(builder: (context,taskPvr,_){
      return SafeArea(
        child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            // appBar: const PreferredSize(
            //   preferredSize: Size(300, 50),
            //   child: CustomAppbar(text: "Task Calendar",),
            // ),
          body: Center(
            child: taskPvr.refresh == false?
            Loading() :Column(
              children: [
                15.height,
                SizedBox(
                  width: kIsWeb?webWidth:phoneWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CustomText(text: "Total Task",
                              colors: colorsConst.secondary),
                          CustomText(
                            text: "  ${taskPvr.searchAllTasks.length}",
                            colors: colorsConst.primary,
                            isBold: true,)
                        ],
                      ),
                      Row(
                        children: [
                          CustomText(text: "This Month",
                              colors: colorsConst.secondary),
                          CustomText(text: "  ${taskPvr.thisMonthLeave}",
                              colors: colorsConst.appRed,
                              isBold: true),
                          // CustomText(text: "  ${taskPvr.filteredTasks.length}",
                          //     colors: colorsConst.primary,
                          //     isBold: true)
                        ],
                      ),
                    ],
                  ),
                ), 10.height,
                taskPvr.refresh == false?
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 150, 0, 0),
                  child: Center(child: Loading()),
                ) :
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: kIsWeb?webWidth:phoneWidth,
                          height: 45,
                          decoration: customDecoration.baseBackgroundDecoration(
                            radius: 30,
                            color: colorsConst.primary,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Center(child: Icon(Icons.search,color: Colors.white)),
                              SizedBox(
                                width: kIsWeb?webWidth:phoneWidth/1.1,
                                child: TextFormField(
                                  cursorColor: colorsConst.primary,
                                  onChanged: (value) {
                                    taskPvr.searchTask2(value.toString());
                                  },
                                  textInputAction: TextInputAction.done,
                                  controller: taskPvr.search2,
                                  decoration: InputDecoration(
                                      hintText:"Search Name or ${constValue.customer}",
                                      hintStyle: TextStyle(
                                          color: colorsConst.primary,
                                          fontSize: 14
                                      ),
                                      fillColor: Colors.white,
                                      filled: true,
                                      // prefixIcon: Icon(Icons.search,color: Colors.grey,),
                                      suffixIcon: taskPvr.search2.text.isNotEmpty?
                                      GestureDetector(
                                          onTap: (){
                                            taskPvr.search2.clear();
                                            taskPvr.searchTask2("");
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
                            ],
                          ),
                        ),
                        10.height,
                        Container(
                          decoration: customDecoration
                              .baseBackgroundDecoration(
                              color: Colors.white,
                              // borderColor: colorsConst.litGrey,
                              radius: 10
                          ),
                          width: kIsWeb?webWidth:phoneWidth,
                          height: 300,
                          child: SfCalendar(
                            controller: _calendarController,
                            view: CalendarView.month,
                            headerHeight: 50,
                            cellBorderColor: Colors.transparent,
                            todayTextStyle: const TextStyle(
                              color: Colors.white,
                            ),
                            dataSource: taskPvr.dataSource,
                            minDate: firstDayOfYear,
                            maxDate: lastDayOfYear,
                            // onTap: null,
                            onLongPress: null,
                            onSelectionChanged: null,
                              onTap: (CalendarTapDetails value) {
                                if (value.date != null) {
                                  final tappedMonth = value.date!.month;
                                  final visibleMonth = taskPvr.defaultMonth;

                                  if (tappedMonth != visibleMonth) {
                                    // 🔄 Switch calendar view to the tapped month
                                    _calendarController.displayDate = value.date!;
                                    return;
                                  }

                                  // ✅ Continue with tap action for current month dates
                                  taskPvr.filterDateList(
                                    DateFormat('dd-MM-yyyy').format(value.date!),
                                    value.date!,
                                  );
                                  taskPvr.checkMonth2();
                                }
                              },
                              onViewChanged: (details) {
                                // _calendarController.selectedDate = null;
                                // _calendarController.displayDate = null;
                                taskPvr.checkMonth2();
                                taskPvr.checkMonth(details);
                              },
                            monthCellBuilder: (BuildContext context, MonthCellDetails details) {
                              bool hasAppointments = taskPvr.hasAppointment(details.date);
                              bool isSelected = false;

                              if (taskPvr.filterDate != "") {
                                DateTime parsedFilterDate = DateFormat('dd-MM-yyyy').parse(taskPvr.filterDate);
                                isSelected = isSameDate(details.date, parsedFilterDate);
                              }

                              // Get the middle date in the visibleDates list to determine current month in view
                              int midIndex = details.visibleDates.length ~/ 2;
                              int visibleMonth = details.visibleDates[midIndex].month;

                              bool isInCurrentMonth = details.date.month == visibleMonth;
                              Color textColor = isSelected
                                  ? colorsConst.greyClr
                                  : isInCurrentMonth
                                  ? Colors.black
                                  : colorsConst.litGrey; // 👉 other month dates in grey

                              return Container(
                                alignment: Alignment.topLeft,
                                margin: const EdgeInsets.all(4),
                                decoration: customDecoration.baseBackgroundDecoration(
                                  color: hasAppointments
                                      ? colorsConst.primary
                                      : Colors.transparent,
                                  radius: 50,
                                ),
                                child: Center(
                                  child: CustomText(
                                    text: details.date.day.toString(),
                                    isBold: true,
                                    colors: hasAppointments?Colors.white:isSelected?Colors.black:textColor,
                                  ),
                                ),
                              );
                            },
                            monthViewSettings: MonthViewSettings(
                              appointmentDisplayMode: MonthAppointmentDisplayMode.none,
                              monthCellStyle: MonthCellStyle(
                                textStyle: TextStyle(
                                  color: colorsConst.appDarkGreen,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                                trailingDatesTextStyle: TextStyle(
                                  color: colorsConst.litGrey,
                                ),
                                leadingDatesTextStyle: TextStyle(
                                  color: colorsConst.litGrey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        taskPvr.allTasks.isEmpty?
                        CustomText(text: "\n\nNo tasks found", colors: colorsConst.secondary, size: 14,):
                        (taskPvr.taskList.isEmpty)?
                        CustomText(text: "\n\nNo tasks found", colors: colorsConst.secondary, size: 14,):
                        // (taskPvr.filteredTasks.isEmpty&&taskPvr.filterDate==""&&taskPvr.filterTasks==0)?
                        // CustomText(text: "\n\nNo tasks found", colors: colorsConst.secondary, size: 14,):
                        // (taskPvr.filteredTasks.isNotEmpty&&taskPvr.filterDate!=""&&taskPvr.filterTasks==0)?
                        // CustomText(text: "\n\nNo tasks found", colors: colorsConst.secondary, size: 14,):
                        // (taskPvr.filteredTasks.isEmpty&&taskPvr.filterTasks==0)?
                        // CustomText(text: "\n\nNo tasks found", colors: colorsConst.secondary, size: 14,):
                        taskPvr.allTasks.isNotEmpty?
                        SizedBox(
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: taskPvr.allTasks.length,
                              itemBuilder: (context, index) {
                                TaskData data = taskPvr.allTasks[index]; // e.g., "24-05-2025"
                                String dateStr = taskPvr.allTasks[index].taskDate.toString(); // e.g., "24-05-2025"
                                DateTime dateTime = DateFormat('dd-MM-yyyy').parse(dateStr);
                                var st = dateTime;
                                taskPvr.allTasks.sort((a, b) =>a.taskDate!.compareTo(b.taskDate.toString()));
                                return utils.returnPadLeft(
                                    taskPvr.defaultMonth.toString()) ==
                                    utils.returnPadLeft(st.month.toString())&&taskPvr.filterDate=="" ?
                                dataList(kIsWeb?webWidth:phoneWidth, data):
                                utils.returnPadLeft(
                                    taskPvr.defaultMonth.toString()) ==
                                    utils.returnPadLeft(st.month.toString())&&taskPvr.filterDate==data.taskDate.toString() ?
                                dataList(kIsWeb?webWidth:phoneWidth, data):0.width;
                              }),
                        )
                        :CustomText(text: "\n\nNo tasks found", colors: colorsConst.secondary, size: 14,),
                        30.height
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ),
      );
    });
  }
  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget dataList(double width,TaskData data){
    return GestureDetector(
      onTap: (){
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: colorsConst.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: Container(
              decoration: customDecoration
                  .baseBackgroundDecoration(
                  color: Colors.white,borderColor:  Colors.transparent,
                  radius: 10
              ),
              width: width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                            width: width/1.5,
                            child: CustomText( text:data.taskTitle .toString(), isBold: true,)),
                        Container(
                          width: width/4,
                          decoration: customDecoration
                              .baseBackgroundDecoration(
                              color: Colors.pink.shade100,
                              radius: 10
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: CustomText( text: data.statval .toString(),
                                  colors: colorsConst.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    5.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Row(
                          children: [
                            CustomText(text: data.projectName.toString()=="null"?"":data.projectName.toString(),colors: colorsConst.primary,),5.width,
                            Icon(Icons.circle,size: 8,),5.width,
                            CustomText(text: data.type.toString()),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_sharp,color: colorsConst.greyClr,size: 15),5.width,
                            CustomText(text: DateFormat("dd MMM yyyy").format(
                                DateFormat("dd-MM-yyyy").parse(data.taskDate.toString())),colors: colorsConst.greyClr,),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if(data.assignedNames .toString()!="null")
                        Row(
                            children: [
                              Icon(Icons.featured_play_list_outlined,color: colorsConst.greyClr,size: 15,),5.width,
                              CustomText(text: data.assignedNames .toString(),colors: colorsConst.greyClr,),
                            ],
                          ),
                        IconButton(onPressed: (){
                          utils.navigatePage(context, ()=> DashBoard(child: TaskChat(isVisit:false,
                              taskId: data.id.toString(), assignedId: data.assigned.toString(), name: data.creator.toString())));
                        }, icon: SvgPicture.asset(assets.tMessage,width: 25,height: 25,))
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
}
}
