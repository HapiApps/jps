import 'package:master_code/component/custom_dropdown.dart';
import 'package:master_code/model/user_model.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:provider/provider.dart';
import 'package:master_code/view_model/home_provider.dart';
import '../../component/attendance_detail.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../model/attendance_model.dart';
import '../../source/constant/default_constant.dart';
import '../../view_model/attendance_provider.dart';
import '../../view_model/employee_provider.dart';
import '../common/check_location.dart';

class UserAttendanceReport extends StatefulWidget {
  final String id;
  final String name;
  final String active;
  final String roleName;
  const UserAttendanceReport({super.key, required this.id, required this.name, required this.active, required this.roleName});

  @override
  State<UserAttendanceReport> createState() => _UserAttendanceReportState();
}

class _UserAttendanceReportState extends State<UserAttendanceReport> {

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (!mounted) return;

      Provider.of<AttendanceProvider>(context, listen: false).initDate(type: Provider.of<AttendanceProvider>(context, listen: false).type,id:widget.id,role:"0",isRefresh: true,date1: Provider.of<AttendanceProvider>(context, listen: false).startDate,date2: Provider.of<AttendanceProvider>(context, listen: false).endDate);
      Provider.of<AttendanceProvider>(context, listen: false).getAttendanceReport(widget.id);


    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer3<AttendanceProvider,HomeProvider,EmployeeProvider>(builder: (context,attProvider,homeProvider,empProvider,_){
      return SafeArea(
        child: Scaffold(
          backgroundColor: colorsConst.bacColor,
          appBar: PreferredSize(
            preferredSize: const Size(300, 50),
            child: CustomAppbar(text: "${widget.name} Attendance Report"),
          ),
          body: Center(
            child: SizedBox(
              width: kIsWeb?webWidth:phoneWidth,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: CustomDropDown(
                          text: "", valueList: attProvider.typeList,
                          saveValue: attProvider.type,color: Colors.white,
                          onChanged: (value){
                            attProvider.changeType(value,widget.id,"0",true,[],context);
                          },width: kIsWeb?webWidth:phoneWidth),
                    ),10.height,
                    attProvider.refresh == false ?
                    const Padding(
                      padding: EdgeInsets.all(100.0),
                      child: Loading(),
                    )
                        :attProvider.getDailyAttendance.isEmpty?
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
                      child: CustomText(
                          text: constValue.noData, size: 15),
                    )
                        :Flexible(
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
                            return Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, index==attProvider.getDailyAttendance.length-1?30:0),
                              child: Column(
                                children: [
                                  if(showDateHeader)
                                    CustomText(text: createdBy,colors:colorsConst.greyClr,size: 12,),
                                  AttendanceDetails(
                                    showDate: index==0?true:false,
                                    date: data.date.toString(),
                                    img: data.image.toString(),
                                    inTime: inTime,
                                    outTime: outTime,
                                    timeD: timeD,
                                    name: data.firstname.toString(),
                                    role: data.role.toString(),
                                    callback: () {
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
                                    perStatus: data.perStatus.toString(),
                                    perReason: data.perReason.toString(),
                                    perTime: data.perTime.toString(),
                                    perCreatedTs: data.perCreatedTs.toString(),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),
                  ]
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
}
