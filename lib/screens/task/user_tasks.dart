import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/component/custom_radio_button.dart';
import 'package:master_code/component/dotted_border.dart';
import 'package:master_code/component/map_dropdown.dart';
import 'package:master_code/screens/task/task_report.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:master_code/view_model/location_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_text.dart';
import '../../model/task/task_data_model.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/task_provider.dart';
import '../common/dashboard.dart';


class UserTasks extends StatefulWidget {
  final String id;
  final String date1;
  final String date2;
  final String name;
  const UserTasks({super.key, required this.date1, required this.date2, required this.name, required this.id});

  @override
  State<UserTasks> createState() => _UserTasksState();
}

class _UserTasksState extends State<UserTasks>{

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.getUserTasks(widget.id,widget.date1,widget.date2);
    });
  }

  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.95;
    return Consumer3<TaskProvider,HomeProvider,LocationProvider>(
        builder: (context, taskProvider, homeProvider,locPvr, _) {
          return Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
              preferredSize: const Size(300, 50),
              child: CustomAppbar(text: constValue.tasks),
            ),
            body: taskProvider.viewRefresh==false?
            const Loading():
            Column(
              children: [
                CustomText(text: "${widget.name}\n"),
                if(taskProvider.userAllTasks.isNotEmpty)
                SizedBox(
                    width: kIsWeb?webWidth:phoneWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomRadioButton(text: "Date",
                            width: MediaQuery.of(context).size.width*0.2,
                            onChanged: (value){
                              taskProvider.changeFilter(value.toString());
                              taskProvider.userAllTasks.sort((a, b) =>
                                  a.taskDate!.compareTo(b.taskDate.toString()));
                            },
                            saveValue: taskProvider.filter, confirmValue: "1"),
                        CustomRadioButton(text: constValue.customer,
                            width: MediaQuery.of(context).size.width*0.2,
                            onChanged: (value){
                              taskProvider.changeFilter(value.toString());
                              taskProvider.userAllTasks.sort((a, b) =>
                                  a.projectName!.compareTo(b.projectName.toString()));
                            },
                            saveValue: taskProvider.filter, confirmValue: "2"),
                        CustomRadioButton(text: "Type",
                            width: MediaQuery.of(context).size.width*0.2,
                            onChanged: (value){
                              taskProvider.changeFilter(value.toString());
                              taskProvider.userAllTasks.sort((a, b) =>
                                  a.type!.compareTo(b.type.toString()));
                            },
                            saveValue: taskProvider.filter, confirmValue: "3"),
                        // MapDropDown(saveValue: taskProvider.status, hintText: "Status",
                        //     width: kIsWeb?MediaQuery.of(context).size.width*0.2:MediaQuery.of(context).size.width*0.4,isHint: false,
                        //     onChanged: (value){
                        //       taskProvider.changeFilterStatus(value);
                        //     }, dropText: "value", list: taskProvider.statusList)
                      ],
                    ),
                  ),
                taskProvider.userAllTasks.isEmpty||(taskProvider.statusId!=""&&taskProvider.matched==0)?
                Center(
                  child: CustomText(text: "\n\n\nNo Task Found",
                      colors: colorsConst.greyClr),
                ) :
                Expanded(
                  child: ListView.builder(
                      itemCount: taskProvider.userAllTasks.length,
                      itemBuilder: (context, index) {
                        final sortedData = taskProvider.userAllTasks;
                        final data = sortedData[index];
                        return Column(
                          children: [
                            taskProvider.statusId==""?
                            detail(
                                width: kIsWeb?webWidth:phoneWidth,
                                data: data)
                                :taskProvider.statusId!=""&&taskProvider.statusId==data.statval?
                            detail(
                                width: kIsWeb?webWidth:phoneWidth,
                                data: data):const SizedBox.shrink(),
                            if(index==taskProvider.userAllTasks.length-1)
                              50.height
                          ],
                        );
                        // :0.width;
                      }),
                ),
              ],
            ),
          );
        });
  }
  String getCreatedDate(data) {
    final timestamp = data.createdTs.toString();
    final dateTime = DateTime.parse(timestamp);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
  Widget detail({required double width, required TaskData data}){
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Container(
        width: width,
        decoration: customDecoration.baseBackgroundDecoration(
            color: Colors.white,radius: 10
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: data.statval.toString().contains("ompleted")?Colors.green:Colors.blue,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(50),
                          bottomLeft: Radius.circular(50),
                        ),
                      ),
                      height: 100,),
                    kIsWeb?10.width:
                    5.width,
                    SizedBox(
                      width: kIsWeb?MediaQuery.of(context).size.width * 0.3:MediaQuery.of(context).size.width * 0.6,
                      // color: Colors.yellow,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          5.height,
                          if(data.taskDate.toString()!="")
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(text: data.taskDate.toString(),colors: colorsConst.greyClr,),
                                Row(
                                  children: [
                                    CircleAvatar(backgroundColor: data.expenseReportCount.toString()=="0"?colorsConst.red2:colorsConst.green2,radius: 4,),
                                    2.width,
                                    CustomText(text: "Expense",colors: data.expenseReportCount.toString()=="0"?colorsConst.red2:colorsConst.green2,isItalic: true,),10.width,
                                    CircleAvatar(backgroundColor: data.visitReportCount.toString()=="0"?colorsConst.red2:colorsConst.green2,radius: 4,),2.width,
                                    CustomText(text: "Visit",colors: data.visitReportCount.toString()=="0"?colorsConst.red2:colorsConst.green2,isItalic: true),
                                  ],
                                ),
                              ],
                            ),5.height,
                          CustomText(text: data.projectName.toString(),colors: colorsConst.primary,size:16,isBold: true,),5.height,
                          Row(
                            children: [
                              CircleAvatar(backgroundColor: data.statval.toString().contains("ompleted")?Colors.green:Colors.blue,radius: 4,),2.width,
                              CustomText(text: data.type.toString().trim(),),5.width,
                            ],
                          ),5.height,
                          CustomText(text: data.taskTitle.toString(),colors: Colors.grey,),5.height
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: kIsWeb?MediaQuery.of(context).size.width * 0.1:MediaQuery.of(context).size.width * 0.25,
                  // color: Colors.black45,
                  child: Column(
                    children: [
                      Container(
                        height: 25,
                        decoration: customDecoration.baseBackgroundDecoration(
                            color: data.statval.toString().contains("ompleted")?Colors.green:Colors.grey,
                            radius: 30
                        ),
                        child: Center(child:
                        CustomText(text: "  ${data.statval==""?"-":data.statval}  ",colors: Colors.white,)),
                      )
                    ],
                  ),
                ),5.width
              ],
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
              child: DotLine(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(kIsWeb?10:5, 0, 5, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if(data.assignedNames.toString()!="null")
                    SizedBox(
                      // color:Colors.pinkAccent,
                        width: kIsWeb?MediaQuery.of(context).size.width*0.3:MediaQuery.of(context).size.width*0.6,
                        child: CustomText(text: data.assignedNames.toString())),
                    TextButton(
                        onPressed: (){
                          utils.navigatePage(context, ()=>DashBoard(child:
                          TaskReport(taskId: data.id.toString(),coId: data.companyId.toString(),numberList: const [], isTask: true,
                            coName: data.projectName.toString(),description: data.taskTitle.toString(),type: data.type.toString(),
                            callback: () {
                              Future.microtask(() => Navigator.pop(context));
                            }, index: 0,
                          )));
                        },
                        child: CustomText(text: "View Report",colors: colorsConst.appDarkGreen,)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}