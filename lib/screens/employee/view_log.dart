import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/styles/decoration.dart';
import '../../view_model/employee_provider.dart';

class ViewLog extends StatefulWidget {
  final String id;
  const ViewLog({super.key, required this.id});

  @override
  State<ViewLog> createState() => _ViewLogState();
}

class _ViewLogState extends State<ViewLog> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<EmployeeProvider>(context, listen: false).getUserLogs(widget.id);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer<EmployeeProvider>(builder: (context,empProvider,_){
      return SafeArea(
        child: Scaffold(
          backgroundColor: colorsConst.bacColor,
            appBar: const PreferredSize(
              preferredSize: Size(300, 50),
              child: CustomAppbar(text: "View Activities"),
            ),
          body: Center(
            child: SizedBox(
              width: kIsWeb?webWidth:phoneWidth,
              // color: Colors.red,
              child: empProvider.refresh==false?
              const Loading():
              Column(
                children: [
                  20.height,
                  empProvider.userLogData.isEmpty ?
                  Column(
                    children: [
                      100.height,
                      CustomText(text: "No Activities Found",
                          colors: colorsConst.greyClr)
                    ],
                  ) :
                  Expanded(
                    child: ListView.builder(
                        itemCount: empProvider.userLogData.length,
                        itemBuilder: (context, index) {
                          final sortedData = empProvider.userLogData;
                          final employeeData = sortedData[index];
                          return Column(
                            children: [
                              Container(
                                width: kIsWeb?webWidth:phoneWidth,
                                decoration: customDecoration
                                    .baseBackgroundDecoration(
                                    color: Colors.white,
                                    borderColor: Colors.grey.shade200,
                                    isShadow: true,
                                    shadowColor: Colors.grey.shade200,
                                    radius: 5
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_today,color: employeeData["active"].toString()=="2"?colorsConst.appRed:colorsConst.appDarkGreen,size: 15,),5.width,
                                              CustomText(text: DateFormat('MMMM d - hh:mm a').format(DateTime.parse(employeeData["created_ts"].toString())),colors: employeeData["active"].toString()=="2"?colorsConst.appRed:colorsConst.appDarkGreen),
                                            ],
                                          ),
                                          Container(
                                            width: 80,height: 30,
                                              decoration: customDecoration
                                                  .baseBackgroundDecoration(
                                                  color: employeeData["active"].toString()=="2"?colorsConst.appRed:colorsConst.appDarkGreen,
                                                  radius: 5
                                              ),
                                              child: Center(child: CustomText(text: employeeData["active"].toString()=="2"?"Deactivated":"Reactivated",isBold: true,colors: Colors.white,))),
                                        ],
                                      ),
                                      CustomText(text: employeeData["reason"].toString(),colors: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                              10.height,
                              if(index == empProvider.userLogData.length - 1)
                                80.height
                            ],
                          );
                        }),
                  ),
                ],
              ),
            ),
          )
        ),
      );
    });
  }
}










