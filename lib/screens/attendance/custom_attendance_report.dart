import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_code/view_model/home_provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../model/attendance_model.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/attendance_provider.dart';
import '../../view_model/employee_provider.dart';
import '../common/check_location.dart';

class CustomAttendanceReport extends StatefulWidget {
  final String userId;
  final String userName;
  const CustomAttendanceReport({super.key,required this.userId, required this.userName});

  @override
  State<CustomAttendanceReport> createState() => _CustomAttendanceReportState();
}

class _CustomAttendanceReportState extends State<CustomAttendanceReport> {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      Provider.of<AttendanceProvider>(context, listen: false).thisMonth(widget.userId,"0",false,context);
      Provider.of<AttendanceProvider>(context, listen: false).getUserAttendanceReport(widget.userId,"0",false,isAbsent: false,isLate: false,list: []);
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
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.95;
    return Consumer3<AttendanceProvider,EmployeeProvider,HomeProvider>(builder: (context,attProvider,empProvider,homeProvider,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
              preferredSize: const Size(300, 50),
              child: CustomAppbar(text: "${widget.userName} Attendance Report"),
            ),
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;

                // Swipe Left (next month)
                if (details.primaryVelocity! < 0) {
                  attProvider.decreaseMonth(widget.userId, "0", false);
                }

                // Swipe Right (previous month)
                else if (details.primaryVelocity! > 0) {
                  attProvider.increaseMonth(widget.userId, "0", false);
                }
              },
              onTapDown: (TapDownDetails details) {
                final screenWidth = MediaQuery.of(context).size.width;
                double dx = details.globalPosition.dx;

                if (dx < screenWidth / 2) {
                  attProvider.decreaseMonth(widget.userId, "0", false);
                } else {
                  attProvider.increaseMonth(widget.userId, "0", false);
                }
              },
              child: Center(
                child: SizedBox(
                  width: kIsWeb?webWidth:phoneWidth,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // if(attProvider.getUserAttendance.isNotEmpty)
                        CustomText(text: attProvider.monthName,colors: colorsConst.networkColor,isBold: true,),
                        attProvider.refresh == false ?
                        const Padding(
                          padding: EdgeInsets.all(100.0),
                          child: Loading(),
                        ):
                        attProvider.getUserAttendance.isEmpty?
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
                          child: CustomText(
                              text: constValue.noData, size: 15),
                        ):
                        Flexible(
                          child: ListView.builder(
                              itemCount: attProvider.getUserAttendance.length,
                              itemBuilder: (context, index) {
                                final sortedData = attProvider.getUserAttendance;
                                AttendanceModel data = attProvider.getUserAttendance[index];
                                var inTime = "",outTime = "-",timeD = "-";
                                var lat = data.lats.toString().split(",");
                                var lng = data.lngs.toString().split(",");
                                if (data.status.toString().contains("1,2")) {
                                  inTime = data.time!.split(",")[0];
                                  outTime = data.time!.split(",")[1];
                                  timeD=attProvider.timeDifference("$inTime,$outTime");
                                }else if (data.status.toString().contains("2,1")) {
                                  inTime = data.time!.split(",")[1];
                                  outTime = data.time!.split(",")[0];
                                  timeD=attProvider.timeDifference("$inTime,$outTime");
                                }else {
                                  inTime = data.time!.split(",")[0];
                                  timeD="-";
                                }
                                var perCreatedTsList=data.perCreatedTs.toString().split(',');
                                var perStatusList=data.perStatus.toString().split(',');
                                var perReasonList=data.perReason.toString().split(',');
                                var perTimeList=data.perTime.toString().split(',');
                                List chunked = [];
                                if(data.perTime.toString()!="null"&&data.perTime.toString()!=""){
                                  for (var i = 0; i < perTimeList.length; i += 2) {
                                    String inTime = perTimeList[i];
                                    String outTime = (i + 1 < perTimeList.length) ? perTimeList[i + 1] : ""; // fallback

                                    String inTs = perCreatedTsList[i];
                                    String outTs = (i + 1 < perCreatedTsList.length) ? perCreatedTsList[i + 1] : "";

                                    chunked.add({
                                      "in": inTime,
                                      "out": outTime,
                                      "reason": perReasonList[i],
                                      "status": perStatusList[i],
                                      "in_ts": inTs,
                                      "out_ts": outTs
                                    });
                                  }
                                }
                                return Padding(
                                  padding: EdgeInsets.fromLTRB(5, 10, 5, index==attProvider.getUserAttendance.length-1?30:0),
                                  child: GestureDetector(
                                    // onTap: callback,
                                    child: Container(
                                      width: kIsWeb?webWidth:phoneWidth,
                                      decoration: customDecoration.baseBackgroundDecoration(
                                          color: Colors.white,
                                          radius: 5,
                                          borderColor: Colors.grey.shade200,isShadow: true,shadowColor: Colors.grey.shade200
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                  SizedBox(
                                                    // color: Colors.blueAccent,
                                                      width: kIsWeb?webWidth/4:phoneWidth/4,
                                                      child: CustomText(text: data.date.toString(),size: 12,)),
                                                5.width,
                                                SizedBox(
                                                  width: kIsWeb?webWidth/5:phoneWidth/5,
                                                  // color: Colors.green,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        const CustomText(text: "In Time",colors: Colors.grey,size: 11,),5.height,
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          CustomText(text: inTime,size: 11,),
                                                          GestureDetector(
                                                            onTap: (){
                                                              utils.navigatePage(context, ()=>CheckLocation(
                                                                  lat1: lat[0].toString(),
                                                                  long1: lng[0].toString(),
                                                                  lat2: data.status.toString().contains("2")? lat[1].toString(): "",
                                                                  long2: data.status.toString().contains("2")? lng[1].toString(): ""
                                                              ));
                                                            },
                                                              child: SvgPicture.asset(assets.map,width: 13,height: 13,)),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),5.width,
                                                SizedBox(
                                                  width: kIsWeb?webWidth/5:phoneWidth/5,
                                                  // color: Colors.yellow,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        const CustomText(text: "Out Time",colors: Colors.grey,size: 11,),5.height,
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          CustomText(text: outTime.toString(),size: 11),
                                                          if(outTime.toString()!="-")
                                                            GestureDetector(
                                                                onTap: (){
                                                                  utils.navigatePage(context, ()=>CheckLocation(
                                                                      lat1: lat[0].toString(),
                                                                      long1: lng[0].toString(),
                                                                      lat2: data.status.toString().contains("2")? lat[1].toString(): "",
                                                                      long2: data.status.toString().contains("2")? lng[1].toString(): ""
                                                                  ));
                                                                },
                                                                child: SvgPicture.asset(assets.map,width: 13,height: 13)),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),5.width,
                                                SizedBox(
                                                  width: kIsWeb?webWidth/5.2:phoneWidth/5.2,
                                                  // color: Colors.blueGrey,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const CustomText(text: "Total Hrs  ",colors: Colors.grey,size: 11,),
                                                      5.height,
                                                      CustomText(text:outTime.toString()=="-"?"-":timeD,size: 11,),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            if(chunked.isNotEmpty)
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(2, 5, 2, 5),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: kIsWeb?webWidth/1:phoneWidth/1,
                                                      height: 0.2,color: Colors.grey,
                                                    ),
                                                    5.height,
                                                    CustomText(text: "Permission${chunked.length==1?"":"s"}",colors: colorsConst.greyClr,),
                                                    5.height,
                                                    ListView.builder(
                                                      shrinkWrap: true,
                                                      physics: const NeverScrollableScrollPhysics(),
                                                      itemCount: chunked.length,
                                                      itemBuilder: (context, index) {
                                                        final item = chunked[index];
                                                        return Padding(
                                                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                          child: Row(
                                                            children: [
                                                              SizedBox(
                                                                // color: Colors.pink,
                                                                width: kIsWeb?webWidth/3:phoneWidth/3,
                                                                child: CustomText(text: "${item['in']} - ${item['out']}",size: 11,isBold: true,),
                                                              ),
                                                              SizedBox(
                                                                // color: Colors.yellow,
                                                                width: kIsWeb?webWidth/5:phoneWidth/5,
                                                                child: CustomText(text: item["out_ts"]!=""?timeDifference(item["in_ts"], item["out_ts"]):"-",size: 11,isBold: true),
                                                              ),
                                                              SizedBox(
                                                                // color: Colors.green,
                                                                width: kIsWeb?webWidth/3:phoneWidth/2.7,
                                                                child: CustomText(text: "${item['reason']}",size: 11,),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
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
  String timeDifference (String dateTimeString1,String dateTimeString2) {
    DateTime startTime = DateTime.parse(dateTimeString1);
    DateTime endTime = DateTime.parse(dateTimeString2);

    Duration difference = endTime.difference(startTime);

    return difference.inMinutes==0?"${difference.inSeconds} Secs":difference.inHours==0?"${difference.inMinutes} Mins":"${difference.inHours} Hrs";
  }
}