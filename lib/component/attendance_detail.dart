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
      // for (var i = 0; i < perTimeList.length; i += 2) {
      //   int end = (i + 2 < perTimeList.length) ? i + 2 : perTimeList.length;
      //   chunked.add({
      //     "in": perTimeList[i],
      //     "out": perTimeList[i+1],
      //     "reason": perReasonList[i],
      //     "status": perStatusList[i],
      //     "in_ts": perCreatedTsList[i],
      //     "out_ts": perCreatedTsList[i+1]
      //   });
      // }
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
        // if(showDate==true)
        // CustomText(text: "$date\n",colors: Provider.of<HomeProvider>(context, listen: false).primary,),
        if(localData.storage.read("role")!="1"&&showDate==true)
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                    width: kIsWeb?webWidth/4:phoneWidth/4,
                    // color: Colors.orangeAccent,
                    child: CustomText(text: "Date",colors:colorsConst.greyClr,size: 12,)),
                5.width,
                SizedBox(
                  width: kIsWeb?webWidth/5:phoneWidth/5,
                  // color: Colors.pink,
                  child: const CustomText(text: "In Time",size: 12,),
                ),5.width,
                SizedBox(
                  width: kIsWeb?webWidth/5:phoneWidth/5,
                  // color: Colors.yellow,
                  child: const CustomText(text: "Out Time",size: 12),
                ),5.width,
                SizedBox(
                  width: kIsWeb?webWidth/5.2:phoneWidth/5.2,
                  // color: Colors.blueAccent,
                  child: CustomText(text:"Total Hrs",size: 12,),
                ),
              ],
            ),
          ),
        Container(
          width: kIsWeb?webWidth:phoneWidth,
          decoration: customDecoration.baseBackgroundDecoration(
              color: isLate(inTime)?colorsConst.late:Colors.white,
              radius: 5,
              borderColor: Colors.grey.shade200,isShadow: true,shadowColor: Colors.grey.shade200
          ),
          child: Padding(
            padding: isName==false?const EdgeInsets.fromLTRB(5, 10, 5, 10):localData.storage.read("role") !="1"?const EdgeInsets.fromLTRB(5, 10, 5, 10):const EdgeInsets.all(0.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if(isName==true)
                      if(!kIsWeb&&localData.storage.read("role") =="1")
                        SizedBox(
                          width: phoneWidth/3.5,
                          // color: Colors.pink,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.grey.shade400,
                                  // child: NetworkImg(image: img, width: 50,)
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
                        // color: Colors.blueAccent,
                          width: kIsWeb?webWidth/4:phoneWidth/4,
                          child: CustomText(text: date,size: 12,)),
                    if(isName==true)
                      5.width,
                    SizedBox(
                      width: kIsWeb?webWidth/5:phoneWidth/5,
                      // color: Colors.green,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(localData.storage.read("role") =="1")
                            const CustomText(text: "In Time",colors: Colors.grey,size: 11,),5.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(text: inTime,size: 11,),
                              GestureDetector(
                                  onTap: callback,
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
                          if(localData.storage.read("role") =="1")
                            const CustomText(text: "Out Time",colors: Colors.grey,size: 11,),5.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(text: outTime.toString(),size: 11),
                              if(outTime.toString()!="-")
                                GestureDetector(
                                    onTap: callback,
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
                          if(localData.storage.read("role") =="1")
                            const CustomText(text: "Total Hrs  ",colors: Colors.grey,size: 11,),
                          if(localData.storage.read("role") =="1")
                            5.height,
                          CustomText(text:outTime.toString()=="-"?"-":timeD,size: 11,),
                        ],
                      ),
                    )
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
                          // color: Colors.blueAccent,
                          width: localData.storage.read("role") =="1"?phoneWidth/1:phoneWidth,
                          child: ListView.builder(
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
  bool isLate(String inTime) {
    final format = DateFormat("hh:mm a");

    DateTime officeTime = format.parse("09:00 AM");
    DateTime userTime = format.parse(inTime);

    return userTime.isAfter(officeTime);
  }
  String timeDifference (String dateTimeString1,String dateTimeString2) {
    DateTime startTime = DateTime.parse(dateTimeString1);
    DateTime endTime = DateTime.parse(dateTimeString2);

    Duration difference = endTime.difference(startTime);

    return difference.inMinutes==0?"${difference.inSeconds} Secs":difference.inHours==0?"${difference.inMinutes} Mins":"${difference.inHours} Hrs";
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
