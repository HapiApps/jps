import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:master_code/source/constant/assets_constant.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/extentions/lib_extensions.dart';
import 'package:flutter/material.dart';
import 'package:master_code/source/styles/decoration.dart';
import '../source/constant/local_data.dart';
import 'custom_text.dart';

class AttendanceDetails extends StatelessWidget {
  final String date;
  final bool? showDate;
  final String inTime;
  final String outTime;
  final VoidCallback callback;
  final String img;
  final String timeD;
  final String name;
  final String role;
  final String perCreatedTs;
  final String perStatus;
  final String perReason;
  final String perTime;
  final bool? isName;
  const AttendanceDetails({super.key, required this.date, required this.inTime, required this.outTime, required this.callback, required this.img,required this.timeD, required this.name, required this.role, this.showDate=false, required this.perStatus,
    required this.perReason, required this.perTime, required this.perCreatedTs,  this.isName=true});

  @override
  Widget build(BuildContext context) {
    var perCreatedTsList=perCreatedTs.toString().split(',');
    var perStatusList=perStatus.toString().split(',');
    var perReasonList=perReason.toString().split(',');
    var perTimeList=perTime.toString().split(',');
    List chunked = [];
    if(perTime.toString()!="null"&&perTime.toString()!=""){
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
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.95;
    return Column(
      children: [
        if(localData.storage.read("role")!="1"&&showDate==true)
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                    width: kIsWeb?webWidth/4:phoneWidth/4,
                    child: CustomText(text: "Date",colors:colorsConst.greyClr,size: 12,)),
                5.width,
                SizedBox(
                  width: kIsWeb?webWidth/5:phoneWidth/5,
                  child: const CustomText(text: "In Time",size: 12,),
                ),5.width,
                SizedBox(
                  width: kIsWeb?webWidth/5:phoneWidth/5,
                  child: const CustomText(text: "Out Time",size: 12),
                ),5.width,
                SizedBox(
                  width: kIsWeb?webWidth/5.2:phoneWidth/5.2,
                  child: CustomText(text:"Total Hrs",size: 12,),
                ),
              ],
            ),
          ),
        Container(
          width: kIsWeb?webWidth:phoneWidth,
          decoration: customDecoration.baseBackgroundDecoration(
              color: isLate(inTime)?const Color(0xFFFFF3E0):Colors.white,
              radius: 5,
              borderColor: Colors.grey.shade200,isShadow: true,shadowColor: Colors.grey.shade200
          ),
          child: Padding(
            padding: isName==false?const EdgeInsets.fromLTRB(5, 4, 5, 4):localData.storage.read("role") !="1"?const EdgeInsets.fromLTRB(5, 10, 5, 10):const EdgeInsets.all(0.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if(isName==true)
                      if(!kIsWeb&&localData.storage.read("role") =="1")
                        SizedBox(
                          width: phoneWidth/3.8,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.grey.shade400,
                                  child: SvgPicture.asset(assets.profile)
                              ),5.height,
                              CustomText(text: name,isBold: true,size: 13,),5.height,
                              CustomText(text: role,colors:colorsConst.blueClr,size: 11,),
                            ],
                          ),
                        ),
                    if(isName==true)
                      if(localData.storage.read("role") =="1")
                        Container(color: colorsConst.litGrey,width: 1,height: 75,),
                    if(localData.storage.read("role") !="1")
                      SizedBox(
                          width: kIsWeb?webWidth/4:phoneWidth/4,
                          child: CustomText(text: date,size: 12,)),
                    if(isName==true)
                      2.width,
                    SizedBox(
                      width: kIsWeb?webWidth/5:phoneWidth/5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(localData.storage.read("role") =="1")
                            const CustomText(text: "In Time",colors: Colors.grey,size: 11,),5.height,
                          CustomText(text: inTime.toString()!="null"?inTime:"-",size: 11,),
                        ],
                      ),
                    ),2.width,
                    SizedBox(
                      width: kIsWeb?webWidth/5:phoneWidth/5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(localData.storage.read("role") =="1")
                            const CustomText(text: "Out Time",colors: Colors.grey,size: 11,),5.height,
                          CustomText(text: outTime.toString(),size: 11),
                        ],
                      ),
                    ),2.width,
                    SizedBox(
                      width: kIsWeb?webWidth/5.2:phoneWidth/5.2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(localData.storage.read("role") =="1")
                            const CustomText(text: "Total Hrs  ",colors: Colors.grey,size: 11,),
                          if(localData.storage.read("role") =="1")
                            2.height,
                          CustomText(text:outTime.toString()=="-"?"-":timeD,size: 11,),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: _mapIcon(callback),
                    ),
                  ],
                ),
                if(chunked.isNotEmpty)
                  Padding(
                    padding: isName==false?const EdgeInsets.fromLTRB(5, 10, 5, 10):EdgeInsets.fromLTRB(localData.storage.read("role") =="1"?10:2, localData.storage.read("role") =="1"?0:5, localData.storage.read("role") =="1"?10:2, 5),
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
                        SizedBox(
                          width: localData.storage.read("role") =="1"?phoneWidth/1:phoneWidth,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: chunked.length,
                            itemBuilder: (context, index) {
                              final item = chunked[index];
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    if(localData.storage.read("role") == "1" && chunked.isNotEmpty)
                                      SizedBox(
                                        width: kIsWeb ? webWidth/4 : phoneWidth/3,
                                        child: CustomText(
                                          text: name,
                                          size: 11,
                                          isBold: true,
                                        ),
                                      ),
                                    10.height,
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: kIsWeb?webWidth/3:phoneWidth/3,
                                          child: CustomText(text: "${item['in']} - ${item['out']}",size: 11,isBold: true,),
                                        ),
                                        SizedBox(
                                          width: kIsWeb?webWidth/5:phoneWidth/5,
                                          child: CustomText(text: item["out"]!=""?timeDifference("${item["in"]},${item["out"]}"):"-",size: 11,isBold: true),
                                        ),
                                        SizedBox(
                                          width: kIsWeb?webWidth/3:phoneWidth/2.7,
                                          child: CustomText(text: "${item['reason']}",size: 11,),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Common clickable map icon with bigger tap area and ripple effect
  Widget _mapIcon(VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(2),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: colorsConst.primary.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          assets.map,
          width: 22,
          height: 22,
          colorFilter: ColorFilter.mode(colorsConst.primary, BlendMode.srcIn),
        ),
      ),
    );
  }

  bool isLate(String? inTime) {
    if (inTime == null || inTime.trim().isEmpty) return false;

    final format = DateFormat("hh:mm a");

    try {
      DateTime officeTime = format.parse("09:00 AM");
      DateTime userTime = format.parse(inTime);
      return userTime.isAfter(officeTime);
    } catch (e) {
      return false; // invalid time format
    }
  }
  String timeDifference(String timeRange) {
    // Split the two times
    List<String> parts = timeRange.split(',');

    DateFormat format = DateFormat("hh:mm a");

    DateTime startTime = format.parse(parts[0].trim());
    DateTime endTime = format.parse(parts[1].trim());

    Duration difference = endTime.difference(startTime);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} Mins";
    } else {
      int hours = difference.inHours;
      int minutes = difference.inMinutes.remainder(60);

      return minutes == 0
          ? "$hours Hrs"
          : "$hours Hrs $minutes Mins";
    }
  }
  DateTime parseTime(String time) {
    final now = DateTime.now(); // Get today's date
    final parts = time.split(" ");
    final period = parts[1]; // AM or PM
    final timeParts = parts[0].split(":");
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    if (period == "PM" && hour != 12) {
      hour += 12;
    } else if (period == "AM" && hour == 12) {
      hour = 0;
    }

    return DateTime(now.year, now.month, now.day, hour, minute); // Use today's date
  }
}