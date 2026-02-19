import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:master_code/screens/leave_management/leave_setting.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_text.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/leave_provider.dart';
import '../common/dashboard.dart';
import '../common/home_page.dart';
import 'add_leave_rules.dart';
import 'apply_leave.dart';
import 'leave_report.dart';
import 'leave_type.dart';

class FixedLeave extends StatefulWidget {
  const FixedLeave({super.key});

  @override
  CalendarAppointment createState() => CalendarAppointment();
}

class CalendarAppointment extends State<FixedLeave> {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();
  final CalendarController _calendarController = CalendarController();

  @override
  void initState() {
    Provider.of<LeaveProvider >(context, listen: false).dataSource = _getDataSource();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp){
      Provider.of<LeaveProvider >(context, listen: false).iniValues2();
      Provider.of<LeaveProvider >(context, listen: false).getTotalLeaves(true);
      Provider.of<LeaveProvider >(context, listen: false).getCommonLeaves();
      Provider.of<LeaveProvider >(context, listen: false).listCheck();
    });
    super.initState();
  }
  @override
  void dispose() {
    _myFocusScopeNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime firstDayOfYear = DateTime(now.year-1, 12, 1);
    final DateTime lastDayOfYear = DateTime(now.year, 12, 31);
    var webWidth=MediaQuery.of(context).size.width*0.7;
    var phoneWidth=MediaQuery.of(context).size.width*0.95;
    return Consumer2<LeaveProvider,HomeProvider>(builder: (context,levProvider,homeProvider,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            body: PopScope(
              canPop: false,
              onPopInvoked: (bool didPop) {
                _myFocusScopeNode.unfocus();
                homeProvider.updateIndex(0);
                if (!didPop) {
                  utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
                }
              },
              child: levProvider.selectedIndex==0&&levProvider.settingPage==false?Center(
                child: SizedBox(
                  child: Column(
                    children: [
                      PreferredSize(
                        preferredSize: Size(300, 50),
                        child: CustomAppbar(
                            text: "YEAR  - ${levProvider.year}",
                        callback: (){
                          _myFocusScopeNode.unfocus();
                          homeProvider.updateIndex(0);
                          utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
                        },),
                      ),
                      SizedBox(
                        width: kIsWeb?webWidth:phoneWidth,
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CustomText(text: "Working Days",
                                    colors: colorsConst.primary),
                                CustomText(
                                  text: "  ${365 - levProvider.total}",
                                  colors: colorsConst.appRed,
                                  isBold: true,)
                              ],
                            ),
                            Row(
                              children: [
                                CustomText(text: "Leave Days",
                                    colors: colorsConst.primary),
                                CustomText(text: "  ${levProvider.total}",
                                    colors: colorsConst.appRed,
                                    isBold: true)
                              ],
                            ),
                            IconButton(
                                onPressed: () {
                                  levProvider.changeSetting();
                                },
                                icon: Icon(Icons.settings, color: colorsConst
                                    .primary, size: 20,)),
                          ],
                        ),
                      ),
                      levProvider.refresh == false?
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 150, 0, 0),
                        child: Center(child: Loading()),
                      ) :
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                decoration: customDecoration
                                    .baseBackgroundDecoration(
                                    color: Colors.transparent,
                                    borderColor: colorsConst.litGrey,
                                    radius: 10
                                ),
                                width: 330,
                                height: 300,
                                child: SfCalendar(
                                  cellBorderColor: Colors.transparent,
                                  // backgroundColor: colorsConst.litGrey,
                                  // todayHighlightColor:colorsConst.primary.withOpacity(0.005),
                                  todayTextStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  view: CalendarView.month,
                                  dataSource: levProvider.dataSource,
                                  minDate: firstDayOfYear,
                                  maxDate: lastDayOfYear,
                                  // onTap: calendarTapped,
                                  onTap: (CalendarTapDetails value) {
                                    if (value.date != null) {
                                      final tappedMonth = value.date!.month;
                                      final visibleMonth = levProvider.defaultMonth;

                                      if (tappedMonth != visibleMonth) {
                                        // 🔄 Switch calendar view to the tapped month
                                        _calendarController.displayDate = value.date!;
                                        return;
                                      }

                                      // ✅ Continue with tap action for current month dates
                                      levProvider.filterDateList(
                                        DateFormat('dd-MM-yyyy').format(value.date!),
                                        value.date!,
                                      );
                                      levProvider.checkMonth2();
                                    }
                                    if(levProvider.filterDate!=""&&levProvider.filterTasks==0){
                                      _showReasonDialog(context,
                                          "${value.date?.year}-${utils.returnPadLeft(value.date!.month.toString())}-${utils.returnPadLeft(value.date!.day.toString())}",
                                          "${utils.returnPadLeft(value.date!.day.toString())}/${utils.returnPadLeft(value.date!.month.toString())}/${value.date?.year}");
                                    }
                                  },
                                  onViewChanged: (details) {
                                    _myFocusScopeNode.unfocus();
                                    levProvider.checkMonth2();
                                    levProvider.checkMonth(details);
                                  },
                                  allowedViews: const [
                                    CalendarView.month,
                                  ],
                                  monthCellBuilder: (BuildContext context, MonthCellDetails details) {
                                    bool hasAppointments = levProvider.hasAppointment(details.date);
                                    bool isSelected = false;

                                    if (levProvider.filterDate != "") {
                                      DateTime parsedFilterDate = DateFormat('dd-MM-yyyy').parse(levProvider.filterDate);
                                      isSelected = isSameDate(details.date, parsedFilterDate);
                                    }

                                    // Get the middle date in the visibleDates list to determine current month in view
                                    int midIndex = details.visibleDates.length ~/ 2;
                                    int visibleMonth = details.visibleDates[midIndex].month;

                                    bool isInCurrentMonth = details.date.month == visibleMonth;

                                    Color textColor = isSelected
                                        ? colorsConst.greyClr
                                        : isInCurrentMonth
                                        ? colorsConst.primary
                                        : colorsConst.litGrey;

                                    return Container(
                                      alignment: Alignment.topLeft,
                                      margin: const EdgeInsets.all(4),
                                      decoration: customDecoration.baseBackgroundDecoration(
                                        color: isSelected
                                            ? Colors.white
                                            : hasAppointments
                                            ? colorsConst.adm5
                                            : Colors.transparent,
                                        radius: isSelected ? 0 : 10,
                                      ),
                                      child: Center(
                                        child: CustomText(
                                          text: details.date.day.toString(),
                                          isBold: true,
                                          colors: textColor,
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
                                  // monthViewSettings: const MonthViewSettings(showAgenda: true),
                                ),
                              ),
                              20.height,
                              if(levProvider.fixedLeaves.isNotEmpty)
                              SizedBox(
                                  width: kIsWeb?webWidth:phoneWidth,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CustomText(text: "This Month Leave",
                                        colors: colorsConst.primary,
                                        size: 14,),
                                      10.width,
                                      CustomText(text: levProvider.thisMonthLeave,
                                        colors: colorsConst.primary,
                                        size: 14,),
                                    ],
                                  ),
                                ),
                              (levProvider.fixedLeaves.isEmpty)?
                              CustomText(text: "\n\nNo Leaves Found", colors: colorsConst.secondary, size: 14,):
                              // (levProvider.fixedLeaves.isEmpty&&levProvider.thisMonthLeave=="0")?
                              // CustomText(text: "\n\nNo Leaves Found", colors: colorsConst.secondary, size: 14,):
                              // (levProvider.thisMonthLeave=="0"&&levProvider.filterDate==""&&levProvider.filterTasks==0)?
                              // CustomText(text: "\n\nNo Leaves Found", colors: colorsConst.secondary, size: 14,):
                              // (levProvider.thisMonthLeave!="0"&&levProvider.filterDate!=""&&levProvider.filterTasks==0)?
                              // CustomText(text: "\n\nNo Leaves Found", colors: colorsConst.secondary, size: 14,):
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: levProvider.fixedLeaves.length,
                                  itemBuilder: (context, index) {
                                    // print(utils.returnPadLeft(levProvider.defaultMonth.toString()));
                                    var st = DateTime.parse(levProvider.fixedLeaves[index].levDate.toString());
                                    final DateFormat formatter = DateFormat('dd-MM-yyyy');

                                    // print(levProvider.filterDate);
                                    // print(formatter.format(DateTime.parse(levProvider.fixedLeaves[index].levDate.toString())));

                                    return utils.returnPadLeft(levProvider.defaultMonth.toString())==utils.returnPadLeft(st.month.toString())&&levProvider.filterDate=="" ?
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 10, 20, 0),
                                      child: Container(
                                        decoration: customDecoration
                                            .baseBackgroundDecoration(
                                            color: Colors.grey.shade200,
                                            radius: 5
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                5.height,
                                                CustomText(
                                                  text: "  ${st.day.toString()
                                                      .padLeft(2, "0")}/${st.month
                                                      .toString()
                                                      .padLeft(2, "0")}/${st
                                                      .year}",
                                                  colors: colorsConst.greyClr,),
                                                5.height,
                                                CustomText(text: "  ${levProvider
                                                    .fixedLeaves[index].reason
                                                    .toString()}"),
                                                5.height,
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                InkWell(
                                                    onTap: () {
                                                      levProvider.reason.text = levProvider
                                                          .fixedLeaves[index]
                                                          .reason.toString();
                                                      showDialog(
                                                          context: context,
                                                          barrierDismissible: false,
                                                          builder: (BuildContext context){
                                                            return AlertDialog(
                                                              actions: [
                                                                Center(
                                                                  child: SizedBox(
                                                                    // color: Colors.yellow,
                                                                    width: kIsWeb?webWidth:phoneWidth,
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            SizedBox(
                                                                              // color: Colors.yellow,
                                                                                width: kIsWeb?webWidth/1.6:phoneWidth/1.6,
                                                                                child: CustomText(text:  "Enter Reason for Leave ${st.day.toString().padLeft(2,"0")}/${st.month.toString().padLeft(2,"0")}/${st.year}",size: 15,isBold: true,)),
                                                                            Padding(
                                                                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                                                              child: InkWell(onTap: (){
                                                                                Navigator.pop(context);
                                                                              }, child: SvgPicture.asset(assets.cancel)),
                                                                            ),
                                                                          ],
                                                                        ),20.height,
                                                                        Column(
                                                                          children: [
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    const CustomText(text: "Reason"),
                                                                                    CustomText(text:"*",colors: colorsConst.appRed,size:20,isBold: false,)
                                                                                  ],
                                                                                ),5.height,
                                                                                TextField(
                                                                                  textCapitalization: TextCapitalization.sentences,
                                                                                  minLines: 1, // Minimum height (1 line)
                                                                                  maxLines: null, // Auto-expand based on content
                                                                                  controller: levProvider.reason,textInputAction: TextInputAction.done,
                                                                                  decoration: InputDecoration(
                                                                                    hintText:"",
                                                                                    hintStyle: const TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontSize: 14
                                                                                    ),
                                                                                    fillColor: Colors.white,
                                                                                    filled: true,
                                                                                    enabledBorder: OutlineInputBorder(
                                                                                      // grey.shade300
                                                                                        borderSide:  BorderSide(color: Colors.grey.shade300),
                                                                                        borderRadius: BorderRadius.circular(10)
                                                                                    ),
                                                                                    focusedBorder: OutlineInputBorder(
                                                                                        borderSide:  BorderSide(color: colorsConst.primary),
                                                                                        borderRadius: BorderRadius.circular(10)
                                                                                    ),
                                                                                    focusedErrorBorder: OutlineInputBorder(
                                                                                        borderSide: BorderSide(color: colorsConst.primary),
                                                                                        borderRadius: BorderRadius.circular(10)
                                                                                    ),
                                                                                    contentPadding:const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                                                                    errorBorder: OutlineInputBorder(
                                                                                        borderSide:  BorderSide(color: Colors.grey.shade300),
                                                                                        borderRadius: BorderRadius.circular(10)
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        30.height,
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            CustomLoadingButton(
                                                                                callback: (){
                                                                                  _myFocusScopeNode.unfocus();
                                                                                  Navigator.pop(context);
                                                                                }, isLoading: false,text: "Cancel",
                                                                                backgroundColor: Colors.white,
                                                                                textColor: colorsConst.primary,radius: 10,
                                                                                width: kIsWeb?webWidth/3.5:phoneWidth/3.5),
                                                                            CustomLoadingButton(
                                                                              width: kIsWeb?webWidth/3.5:phoneWidth/3.5,
                                                                              isLoading: true,
                                                                              callback: () {
                                                                                if(levProvider.reason.text.trim().isNotEmpty){
                                                                                  _myFocusScopeNode.unfocus();
                                                                                  levProvider.updateLeaves(context,levProvider.fixedLeaves[index].id.toString(),levProvider.reason.text);
                                                                                }else{
                                                                                  utils.showWarningToast(context, text: "Please type reason");
                                                                                  levProvider.submitCtr.reset();
                                                                                }
                                                                              },
                                                                              controller: levProvider.submitCtr, text: 'Save', backgroundColor: colorsConst.primary, radius: 10,),
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          }
                                                      );
                                                    },
                                                    child: Icon(Icons.edit,
                                                      color: colorsConst.greyClr,
                                                      size: 20,)),
                                                25.width,
                                                InkWell(
                                                    onTap: () {
                                                      levProvider.reason.text = levProvider
                                                          .fixedLeaves[index]
                                                          .reason.toString();
                                                      utils.customDialog(
                                                          context: context,
                                                          title: "Are you sure you want to",
                                                          title2: "delete this Leave? - ${st.day.toString().padLeft(2,"0")}/${st.month.toString().padLeft(2,"0")}/${st.year}",
                                                          callback:  () {
                                                            levProvider.deleteLeaves(context,levProvider.fixedLeaves[index].id.toString());
                                                          },isLoading: true,
                                                          roundedLoadingButtonController: levProvider.submitCtr,
                                                      );
                                                    },
                                                    child: Icon(Icons.delete,
                                                      color: colorsConst.greyClr,
                                                      size: 20,)),
                                                5.width
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ) :
                                    utils.returnPadLeft(levProvider.defaultMonth.toString())==utils.returnPadLeft(st.month.toString())&&levProvider.filterDate==formatter.format(DateTime.parse(levProvider.fixedLeaves[index].levDate.toString()))?
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 10, 20, 0),
                                      child: Container(
                                        decoration: customDecoration
                                            .baseBackgroundDecoration(
                                            color: Colors.grey.shade200,
                                            radius: 5
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                5.height,
                                                CustomText(
                                                  text: "  ${st.day.toString()
                                                      .padLeft(2, "0")}/${st.month
                                                      .toString()
                                                      .padLeft(2, "0")}/${st
                                                      .year}",
                                                  colors: colorsConst.greyClr,),
                                                5.height,
                                                CustomText(text: "  ${levProvider
                                                    .fixedLeaves[index].reason
                                                    .toString()}"),
                                                5.height,
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                InkWell(
                                                    onTap: () {
                                                      levProvider.reason.text = levProvider
                                                          .fixedLeaves[index]
                                                          .reason.toString();
                                                      showDialog(
                                                          context: context,
                                                          barrierDismissible: false,
                                                          builder: (BuildContext context){
                                                            return AlertDialog(
                                                              actions: [
                                                                Center(
                                                                  child: SizedBox(
                                                                    // color: Colors.yellow,
                                                                    width: kIsWeb?webWidth:phoneWidth,
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            SizedBox(
                                                                              // color: Colors.yellow,
                                                                                width: kIsWeb?webWidth/1.6:phoneWidth/1.6,
                                                                                child: CustomText(text:  "Enter Reason for Leave ${st.day.toString().padLeft(2,"0")}/${st.month.toString().padLeft(2,"0")}/${st.year}",size: 15,isBold: true,)),
                                                                            Padding(
                                                                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                                                              child: InkWell(onTap: (){
                                                                                Navigator.pop(context);
                                                                              }, child: SvgPicture.asset(assets.cancel)),
                                                                            ),
                                                                          ],
                                                                        ),20.height,
                                                                        Column(
                                                                          children: [
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    const CustomText(text: "Reason"),
                                                                                    CustomText(text:"*",colors: colorsConst.appRed,size:20,isBold: false,)
                                                                                  ],
                                                                                ),5.height,
                                                                                TextField(
                                                                                  textCapitalization: TextCapitalization.sentences,
                                                                                  minLines: 1, // Minimum height (1 line)
                                                                                  maxLines: null, // Auto-expand based on content
                                                                                  controller: levProvider.reason,textInputAction: TextInputAction.done,
                                                                                  decoration: InputDecoration(
                                                                                    hintText:"",
                                                                                    hintStyle: const TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontSize: 14
                                                                                    ),
                                                                                    fillColor: Colors.white,
                                                                                    filled: true,
                                                                                    enabledBorder: OutlineInputBorder(
                                                                                      // grey.shade300
                                                                                        borderSide:  BorderSide(color: Colors.grey.shade300),
                                                                                        borderRadius: BorderRadius.circular(10)
                                                                                    ),
                                                                                    focusedBorder: OutlineInputBorder(
                                                                                        borderSide:  BorderSide(color: colorsConst.primary),
                                                                                        borderRadius: BorderRadius.circular(10)
                                                                                    ),
                                                                                    focusedErrorBorder: OutlineInputBorder(
                                                                                        borderSide: BorderSide(color: colorsConst.primary),
                                                                                        borderRadius: BorderRadius.circular(10)
                                                                                    ),
                                                                                    contentPadding:const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                                                                    errorBorder: OutlineInputBorder(
                                                                                        borderSide:  BorderSide(color: Colors.grey.shade300),
                                                                                        borderRadius: BorderRadius.circular(10)
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        30.height,
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            CustomLoadingButton(
                                                                                callback: (){
                                                                                  _myFocusScopeNode.unfocus();
                                                                                  Navigator.pop(context);
                                                                                }, isLoading: false,text: "Cancel",
                                                                                backgroundColor: Colors.white,
                                                                                textColor: colorsConst.primary,radius: 10,
                                                                                width: kIsWeb?webWidth/3.5:phoneWidth/3.5),
                                                                            CustomLoadingButton(
                                                                              width: kIsWeb?webWidth/3.5:phoneWidth/3.5,
                                                                              isLoading: true,
                                                                              callback: () {
                                                                                if(levProvider.reason.text.trim().isNotEmpty){
                                                                                  _myFocusScopeNode.unfocus();
                                                                                  levProvider.updateLeaves(context,levProvider.fixedLeaves[index].id.toString(),levProvider.reason.text);
                                                                                }else{
                                                                                  utils.showWarningToast(context, text: "Please type reason");
                                                                                  levProvider.submitCtr.reset();
                                                                                }
                                                                              },
                                                                              controller: levProvider.submitCtr, text: 'Save', backgroundColor: colorsConst.primary, radius: 10,),
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          }
                                                      );
                                                    },
                                                    child: Icon(Icons.edit,
                                                      color: colorsConst.greyClr,
                                                      size: 20,)),
                                                25.width,
                                                InkWell(
                                                    onTap: () {
                                                      levProvider.reason.text = levProvider
                                                          .fixedLeaves[index]
                                                          .reason.toString();
                                                      utils.customDialog(
                                                          context: context,
                                                          title: "Are you sure you want to",
                                                          title2: "delete this Leave? - ${st.day.toString().padLeft(2,"0")}/${st.month.toString().padLeft(2,"0")}/${st.year}",
                                                          callback:  () {
                                                            levProvider.deleteLeaves(context,levProvider.fixedLeaves[index].id.toString());
                                                          },isLoading: true,
                                                          roundedLoadingButtonController: levProvider.submitCtr,
                                                      );
                                                    },
                                                    child: Icon(Icons.delete,
                                                      color: colorsConst.greyClr,
                                                      size: 20,)),
                                                5.width
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ) : 0.width;
                                  }),
                              30.height
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ):
                levProvider.selectedIndex==0&&levProvider.settingPage==true?const LeaveSetting():
                levProvider.selectedIndex==1&&levProvider.addType==false?
                const LeaveTypes():
                levProvider.selectedIndex==1&&levProvider.addType==true?const AddType():
                levProvider.selectedIndex==2?
                ViewMyLeaves(date1:homeProvider.startDate,date2:homeProvider.endDate):
                levProvider.selectedIndex==3?
                const ApplyLeave():
                const AddLeaveRules(),
            ),
              ),
            ),
      );
    });
  }
  void calendarTapped(CalendarTapDetails calendarTapDetails) async {
    Provider.of<LeaveProvider >(context, listen: false).dataSource.appointments?.clear();
    Provider.of<LeaveProvider >(context, listen: false).dataSource.dispose();
    if (calendarTapDetails.targetElement == CalendarElement.calendarCell) {
      final existingAppointment = Provider.of<LeaveProvider >(context, listen: false).dataSource.appointments!.any(
            (appointment) => isSameDate(appointment.startTime, calendarTapDetails.date!),
      );

      if (existingAppointment) {
        utils.showWarningToast(context, text: "Already added");
        return;
      }

      final reason = await _showReasonDialog(context,
          "${calendarTapDetails.date?.year}-${utils.returnPadLeft(calendarTapDetails.date!.month.toString())}-${utils.returnPadLeft(calendarTapDetails.date!.day.toString())}",
          "${utils.returnPadLeft(calendarTapDetails.date!.day.toString())}/${utils.returnPadLeft(calendarTapDetails.date!.month.toString())}/${calendarTapDetails.date?.year}");
      if (reason != null && reason.isNotEmpty) {
        Appointment app = Appointment(
          startTime: calendarTapDetails.date!,
          endTime: calendarTapDetails.date!.add(const Duration(hours: 1)),
          subject: reason,
          color: Colors.greenAccent,
        );
        Provider.of<LeaveProvider >(context, listen: false).dataSource.appointments!.add(app);
        Provider.of<LeaveProvider >(context, listen: false).dataSource.notifyListeners(CalendarDataSourceAction.add, <Appointment>[app]);
      }
    }
  }



  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  Future<String?> _showReasonDialog(BuildContext context,String date,String showDate) {
    TextEditingController reasonController = TextEditingController();
    var webWidth=MediaQuery.of(context).size.width*0.7;
    var phoneWidth=MediaQuery.of(context).size.width*0.95;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actions: [
            Center(
              child: SizedBox(
                // color: Colors.yellow,
                width: kIsWeb?webWidth:phoneWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          // color: Colors.yellow,
                            width: kIsWeb?webWidth/1.6:phoneWidth/1.6,
                            child: CustomText(text:  "Enter Reason for Leave $showDate",size: 15,isBold: true,)),
                        IconButton(onPressed: (){
                          Navigator.pop(context);
                        }, icon: SvgPicture.asset(assets.cancel)),
                      ],
                    ),20.height,
                    Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CustomText(text: "Reason"),
                                CustomText(text:"*",colors: colorsConst.appRed,size:20,isBold: false,)
                              ],
                            ),5.height,
                            TextField(
                              textCapitalization: TextCapitalization.sentences,
                              minLines: 1, // Minimum height (1 line)
                              maxLines: null, // Auto-expand based on content
                              controller: reasonController,textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                hintText:"",
                                hintStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                  // grey.shade300
                                    borderSide:  BorderSide(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:  BorderSide(color: colorsConst.primary),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: colorsConst.primary),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                contentPadding:const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                errorBorder: OutlineInputBorder(
                                    borderSide:  BorderSide(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    30.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomLoadingButton(
                            callback: (){
                              _myFocusScopeNode.unfocus();
                              Navigator.pop(context);
                            }, isLoading: false,text: "Cancel",
                            backgroundColor: Colors.white,
                            textColor: colorsConst.primary,radius: 10,
                            width: kIsWeb?webWidth/3.5:phoneWidth/3.5),
                        CustomLoadingButton(
                          width: kIsWeb?webWidth/3.5:phoneWidth/3.5,
                          isLoading: true,
                          callback: () {
                            if(reasonController.text.trim().isNotEmpty){
                              _myFocusScopeNode.unfocus();
                              Provider.of<LeaveProvider >(context, listen: false).fixLeaves(context,date,reasonController.text);
                            }else{
                              utils.showWarningToast(context, text: "Please type reason");
                              Provider.of<LeaveProvider >(context, listen: false).submitCtr.reset();
                            }
                          },
                          controller: Provider.of<LeaveProvider >(context, listen: false).submitCtr, text: 'Save', backgroundColor: colorsConst.primary, radius: 10,),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _DataSource _getDataSource() {
    List<Appointment> appointments = <Appointment>[];
    // appointments.add(Appointment(
    //   startTime: DateTime.now(),
    //   endTime: DateTime.now().add(const Duration(hours: 1)),
    //   subject: widget.title,
    //   color: Colors.teal,
    // ));
    return _DataSource(appointments);
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}