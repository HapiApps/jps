import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:master_code/screens/leave_management/leave_report.dart';
import 'package:master_code/source/constant/assets_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../model/attendance_model.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/local_data.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/leave_provider.dart';
import '../common/check_location.dart';
import '../common/dashboard.dart';

class LeaveDetails extends StatefulWidget {
  final String empId;
  final String name;
  final String role;
  final String? date1;
  final String? date2;
  const LeaveDetails({super.key, required this.empId, required this.name, required this.role, this.date1, this.date2});

  @override
  State<LeaveDetails> createState() => _LeaveDetailsState();
}

class _LeaveDetailsState extends State<LeaveDetails> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp){
      Provider.of<LeaveProvider >(context, listen: false).initVal();
      Provider.of<LeaveProvider >(context, listen: false).setDMonth();
      Provider.of<LeaveProvider >(context, listen: false).getOwnLeaves(widget.empId.toString(), Provider.of<LeaveProvider >(context, listen: false).d1, Provider.of<LeaveProvider >(context, listen: false).d2);
      Provider.of<LeaveProvider >(context, listen: false).getLeavesRules(widget.empId.toString());
      Provider.of<LeaveProvider>(context, listen: false).getAttendanceReport(widget.empId,"");
    });
    // getAttendanceDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeaveProvider>(builder: (context,levProvider,_) {
      return SafeArea(
          child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
                preferredSize: Size(300, 50),
                child: CustomAppbar(text: "Leave Details",
                  // callback: () {
                  // if (localData.storage.read("role") == "1") {
                  //   levProvider.changeIndex(2);
                  // }else{
                  //   utils.navigatePage(context, ()=> DashBoard(child: ViewMyLeaves(date1: widget.date1!,date2: widget.date2!)));
                  // }
                // },
              )),
            body:PopScope(
              // canPop:true,
              // onPopInvoked: (bool pop) async {
              //   if (localData.storage.read("role") == "1") {
              //     levProvider.changeIndex(2);
              //   }else{
              //     utils.navigatePage(context, ()=> DashBoard(child: ViewMyLeaves(date1: widget.date1!,date2: widget.date2!)));
              //   }
              // },
              child: SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomText(text: widget.name,
                              colors: colorsConst.shareColor,
                              isBold: true,
                              size: 15,),
                            10.width,
                            Row(
                              children: [
                                // InkWell(
                                //   onTap: () {
                                //     levProvider.decrementMonth2();
                                //   },
                                //   child: Icon(
                                //     Icons.arrow_back_ios_new_outlined, size: 20,
                                //     color: colorsConst.greyClr,),
                                // ),
                                // 10.width,
                                GestureDetector(
                                  child: Row(
                                    children: [
                                      // Icon(
                                      //   Icons.calendar_today, size: 15,
                                      //   color: colorsConst.primary,), 10.width,
                                      CustomText(text: levProvider.dMonth,
                                          colors: colorsConst.primary,
                                          size: 14),
                                    ],
                                  ),
                                ),
                                // 10.width,
                                // InkWell(
                                //   onTap: () {
                                //     levProvider.incrementMonth2();
                                //   },
                                //   child: Icon(
                                //     Icons.arrow_forward_ios_outlined, size: 20,
                                //     color: colorsConst.greyClr,),
                                // ),
                              ],
                            )
                          ],
                        ),
                        10.height,
                        levProvider.isLoading4 == false &&
                            levProvider.isLeave == false && levProvider.allSelect == false
                            ?const Padding(
                          padding: EdgeInsets.fromLTRB(0, 140, 0, 0),
                          child: Loading(),
                        )
                        :Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CustomText(text: "Leave Policy",
                                  colors: colorsConst.primary,
                                  isBold: true,),
                              ],
                            ),
                            10.height,
                            ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: levProvider.types.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      if(index == 0)
                                        tableBox(text: "Type",
                                            isHead: true,
                                            text2: "Days"),
                                      tableBox(text: levProvider.types[index]["type"],
                                          text2: levProvider.types[index]["days"].text),
                                    ],
                                  );
                                }),
                            10.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CustomText(text: "This Month",
                                  colors: colorsConst.primary,
                                  isBold: true,),
                              ],
                            ),
                            10.height,
                            tableBox(text: 'Official Leaves',
                                isHead: true,
                                text2: levProvider.fixedMonthLeaves.length.toString()),
                            tableBox(text: 'Total Leave',
                                isHead: true,
                                text2: levProvider.totalLeaveDays),
                            tableBox(text: 'Total Working Day',
                                isHead: true,
                                text2: '${int.parse(levProvider.noOfWorkingDay.text) -
                                    levProvider.fixedMonthLeaves.length}'),
                            tableBox(text: 'Present Days',
                                isHead: true,
                                text2: '${levProvider.getDailyAttendance.length}'),
                            20.height,
                            levProvider.isLoading4==false?
                            Loading():
                            ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: levProvider.myLev4Search.length,
                                itemBuilder: (context, index) {
                                  final sortedData = levProvider.myLev4Search;
                                  sortedData.sort((a, b) =>
                                      a.startDate!.compareTo(b.startDate.toString()));
                                  final data = sortedData[index];
                                  String timestamp = data.createdTs.toString();
                                  DateTime dateTime = DateTime.parse(timestamp);
                                  DateFormat('EEEE').format(dateTime);
                                  DateTime today = DateTime.now();
                                  if (dateTime.day == today.day &&
                                      dateTime.month == today.month &&
                                      dateTime.year == today.year) {} else
                                  if (dateTime.isAfter(today.subtract(
                                      const Duration(days: 1))) &&
                                      dateTime.isBefore(today)) {} else {}
                                  var st = DateTime.parse(data.startDate.toString());
                                  var date1 = "${st.day.toString().padLeft(
                                      2, "0")}/${st.month.toString().padLeft(
                                      2, "0")}/${st.year}";
                                  var date2 = "";
                                  if (data.startDate.toString() != data.endDate
                                      .toString() && data.endDate.toString() != "") {
                                    var en = DateTime.parse(data.endDate.toString());
                                    // print(data.endDate.toString());
                                    date2 = "${en.day.toString().padLeft(2, "0")}/${en
                                        .month.toString().padLeft(2, "0")}/${en.year}";
                                  }
                                  return Column(
                                    children: [
                                      if(index==0)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          CustomText(text: "Leave Days",
                                            colors: colorsConst.primary,
                                            isBold: true,),
                                        ],
                                      ),
                                      Container(
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width * 0.9,
                                        decoration: customDecoration
                                            .baseBackgroundDecoration(
                                            radius: 2,
                                            color: Colors.white,
                                            borderColor: Colors.grey
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 0, 10, 0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceEvenly,
                                            children: [
                                              5.height,
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  CustomText(
                                                    text: data.type.toString(),
                                                    colors: colorsConst.primary,
                                                  ),
                                                  CustomText(
                                                    text: "$date1${date2 != ""
                                                        ? " To $date2"
                                                        : ""}",
                                                    size: 13,
                                                    colors: Colors.black,
                                                  ),
                                                  CustomText(
                                                    text: "${data.dayType
                                                        .toString() == "0.5"
                                                        ? "Half"
                                                        : data.dayCount} ${data
                                                        .dayCount.toString() ==
                                                        "0.5" ||
                                                        data.dayCount.toString() ==
                                                            "1" ? "day" : "days"}",
                                                    colors: colorsConst.greyClr,
                                                  ),
                                                ],
                                              ),
                                              5.height,

                                              5.height,
                                              CustomText(
                                                text: data.reason.toString(),
                                                colors: colorsConst.greyClr,
                                              ),
                                              5.height,
                                            ],
                                          ),
                                        ),
                                      ),
                                      10.height
                                    ],
                                  );
                                }),
                            10.height,
                            ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: levProvider.getDailyAttendance.length,
                                itemBuilder: (context, index) {
                                  AttendanceModel data = levProvider
                                      .getDailyAttendance[index];
                                  var inTime = "",
                                      outTime = "-";
                                  var lat = data.lats.toString().split(",");
                                  var lng = data.lngs.toString().split(",");
                                  if (data.status.toString().contains("1,2")) {
                                    inTime = data.time!.split(",")[0];
                                    outTime = data.time!.split(",")[1];
                                  } else if (data.status.toString().contains("2,1")) {
                                    outTime = data.time!.split(",")[0];
                                    inTime = data.time!.split(",")[1];
                                  } else {
                                    inTime = data.time!.split(",")[0];
                                  }
                                  return Column(
                                    children: [
                                      if(index == 0)
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            CustomText(text: "Attendance Details",
                                              colors: colorsConst.primary,
                                              isBold: true,),
                                          ],
                                        ),
                                      Container(
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width * 0.9,
                                        decoration: customDecoration
                                            .baseBackgroundDecoration(
                                            radius: 2,
                                            color: Colors.white,
                                            borderColor: Colors.grey
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 0, 10, 0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceEvenly,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  CustomText(
                                                    text: inTime,
                                                    colors: colorsConst.primary,
                                                  ),
                                                  CustomText(
                                                    text: outTime,
                                                    size: 13,
                                                    colors: Colors.black,
                                                  ),
                                                  CustomText(
                                                    text:  data.date.toString(),
                                                    colors: colorsConst.greyClr,
                                                  ),
                                                  IconButton(
                                                      onPressed: (){
                                                          utils.navigatePage(context, ()=>CheckLocation(
                                                              lat1: lat[0].toString(),
                                                              long1: lng[0].toString(),
                                                              lat2: data.status.toString().contains("2")
                                                                  ? lat[1].toString()
                                                                  : "",
                                                              long2: data.status.toString().contains("2")
                                                                  ? lng[1].toString()
                                                                  : ""
                                                          ));
                                                        },
                                                      icon: SvgPicture.asset(assets.map))
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      10.height
                                    ],
                                  );
                                }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ));
    });
  }
  String getCreatedDate(data) {
    final timestamp = data.createdTs.toString();
    final dateTime = DateTime.parse(timestamp);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
  Widget tableBox({bool? isHead=false,required String text,required String text2}){
    return Row(
      children: [
        Container(
          width: 150,decoration: customDecoration.baseBackgroundDecoration(
            borderColor: isHead==true?Colors.grey.shade300:Colors.grey.shade100,
            color: isHead==true?Colors.grey.shade100:Colors.white,
            radius: 0
        ),
          child: CustomText(text: "\n  $text\n",colors: Colors.black),
        ),
        Container(
          width: 100,decoration: customDecoration.baseBackgroundDecoration(
            borderColor: isHead==true?Colors.grey.shade300:Colors.grey.shade100,
            color: isHead==true?Colors.grey.shade100:Colors.white,
            radius: 0
        ),
          child: CustomText(text: "\n  $text2\n",colors: colorsConst.greyClr),
        ),
      ],
    );
  }
}
