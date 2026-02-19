import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/component/dotted_border.dart';
import 'package:master_code/screens/task/task_details.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/location_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_radio_button.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../component/map_dropdown.dart';
import '../../model/task/task_data_model.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/task_provider.dart';
import '../common/dashboard.dart';
import '../task/task_report.dart';

class ViewTasks extends StatefulWidget {
  final String coId;
  final List numberList;
  final String companyName;
  const ViewTasks({super.key, required this.coId, required this.numberList, required this.companyName});

  @override
  State<ViewTasks> createState() => _ViewTasksState();
}

class _ViewTasksState extends State<ViewTasks> with SingleTickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.getAllCoTask(widget.coId,true);
      if(kIsWeb){
        taskProvider.getTaskType(false);
        taskProvider.getTaskStatuses();
      }else{
        taskProvider.getAllTypes();
        taskProvider.getTypeSts();
      }
    });
  }
  @override
  void dispose() {
    _myFocusScopeNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer2<TaskProvider,LocationProvider>(builder: (context, taskProvider,locPvr, _) {
      return FocusScope(
        node: _myFocusScopeNode,
        child: Scaffold(
          backgroundColor: colorsConst.bacColor,
          appBar: PreferredSize(
            preferredSize: const Size(300, 50),
            child: CustomAppbar(text: "${widget.companyName} Tasks"),
          ),
          body: Center(
            child: SizedBox(
              width: kIsWeb?webWidth:phoneWidth,
              child: taskProvider.refresh==false?
              const Loading():
              Column(
                children: [
                  CustomTextField(
                    controller: taskProvider.search,radius: 30,
                    width: kIsWeb?webWidth:phoneWidth,
                    text: "",
                    isIcon: true,hintText: "Search Name",
                    iconData: Icons.search,
                    textInputAction: TextInputAction.done,
                    onChanged: (value) {
                      taskProvider.searchTask(value.toString());
                    },
                    isSearch: taskProvider.search.text.isNotEmpty?true:false,
                    searchCall: (){
                      taskProvider.search.clear();
                      taskProvider.searchTask("");
                    },
                  ),
                  if(taskProvider.allTasks.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomRadioButton(text: "Date",
                          width: MediaQuery.of(context).size.width*0.37,
                          onChanged: (value){
                            taskProvider.changeFilter(value.toString());
                            taskProvider.allTasks.sort((a, b) =>
                                a.taskDate!.compareTo(b.taskDate.toString()));
                          },
                          saveValue: taskProvider.filter, confirmValue: "1"),
                      // CustomRadioButton(text: "Company",
                      //     onChanged: (value){
                      //       taskProvider.changeFilter(value.toString());
                      //       taskProvider.allTasks.sort((a, b) =>
                      //           a.projectName!.compareTo(b.projectName.toString()));
                      //     },
                      //     saveValue: taskProvider.filter, confirmValue: "2"),
                      CustomRadioButton(text: "Type",
                          width: MediaQuery.of(context).size.width*0.37,
                          onChanged: (value){
                            taskProvider.changeFilter(value.toString());
                            taskProvider.allTasks.sort((a, b) =>
                                a.type!.compareTo(b.type.toString()));
                          },
                          saveValue: taskProvider.filter, confirmValue: "3"),
                      MapDropDown(saveValue: taskProvider.status, hintText: "Status",
                          width: kIsWeb?webWidth/1.7:phoneWidth/1.7,
                          isHint: false,
                          onChanged: (value){
                            taskProvider.changeFilterStatus(value);
                          }, dropText: "value", list: taskProvider.statusList)
                    ],
                  ),
                  taskProvider.allTasks.isEmpty||(taskProvider.statusId!=""&&taskProvider.matched==0)?
                  Column(
                    children: [
                      100.height,
                      CustomText(text: "No Task Found",
                          colors: colorsConst.greyClr)
                    ],
                  ) :
                  Expanded(
                    child: ListView.builder(
                        itemCount: taskProvider.allTasks.length,
                        itemBuilder: (context, index) {
                          final sortedData = taskProvider.allTasks;
                          final data = sortedData[index];
                          return GestureDetector(
                            onTap: (){
                              _myFocusScopeNode.unfocus();
                              utils.navigatePage(context, ()=> DashBoard(child:
                              TaskDetails(data: data,isDirect: false,coId: widget.coId.toString(),numberList: widget.numberList)));
                            },
                            child: Column(
                              children: [
                                taskProvider.statusId==""?
                                detail(width: kIsWeb?webWidth:phoneWidth, data: data)
                                :taskProvider.statusId!=""&&taskProvider.statusId==data.statval?
                                detail(width: kIsWeb?webWidth:phoneWidth, data: data):const SizedBox.shrink(),
                                if(index==taskProvider.allTasks.length-1)
                                50.height
                              ],
                            ),
                          );
                          // :0.width;
                        }),
                  ),
                ],
              ),
            ),
          ),
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
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
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
                Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: data.statval.toString().contains("ompleted")?Colors.green:Colors.blue,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      bottomLeft: Radius.circular(50),
                    ),
                  ),
                  height: 100,),5.width,
                SizedBox(
                  width: kIsWeb?webWidth/1.5:phoneWidth/1.5,
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
                      // CustomText(text: data.projectName.toString(),colors: colorsConst.primary,size:16,isBold: true,),5.height,
                      Row(
                        children: [
                          CircleAvatar(backgroundColor: data.statval.toString().contains("ompleted")?Colors.green:Colors.blue,radius: 4,),2.width,
                          CustomText(text: data.type.toString(),),
                        ],
                      ),5.height,
                      CustomText(text: data.taskTitle.toString(),colors: Colors.grey,),5.height
                    ],
                  ),
                ),
                SizedBox(
                  width: kIsWeb?webWidth/4:phoneWidth/4,
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
            if(data.assignedNames.toString()!="null"&&data.assignedNames.toString()!="")
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                child: DotLine(),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if(data.assignedNames.toString()!="null"&&data.assignedNames.toString()!="")
                    SizedBox(
                      // color:Colors.pinkAccent,
                        width: kIsWeb?webWidth/1.5:phoneWidth/1.5,
                        child: CustomText(text: " ${data.assignedNames.toString()}")),
                  TextButton(
                      onPressed: (){
                        utils.navigatePage(context, ()=> DashBoard(child:
                        TaskReport(taskId: data.id.toString(),coId: widget.coId,numberList: widget.numberList,isTask: false,
                          coName: data.projectName.toString(),description: data.taskTitle.toString(),type: data.type.toString(),callback: () {
                              Future.microtask(() => Navigator.pop(context));
                            }, index: 0,)));
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
