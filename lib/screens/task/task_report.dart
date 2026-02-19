import 'package:master_code/screens/task/task_attendance.dart';
import 'package:master_code/screens/task/view_task.dart';
import 'package:master_code/screens/task/visit/customer_visits.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:master_code/view_model/expense_provider.dart';
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
import '../../view_model/customer_provider.dart';
import '../../view_model/task_provider.dart';
import '../common/dashboard.dart';
import '../expense/expense_details.dart';

class TaskReport extends StatefulWidget {
  final String taskId;
  final String coId;
  final List numberList;
  final bool isTask;
  final String coName;
  final String type;
  final String description;
  final VoidCallback callback;
  final int index;
  const TaskReport({super.key, required this.taskId, required this.coId, required this.numberList, required this.isTask,
    required this.coName, required this.type, required this.description, required this.callback, required this.index});

  @override
  State<TaskReport> createState() => _TaskReportState();
}

class _TaskReportState extends State<TaskReport> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    Provider.of<ExpenseProvider>(context, listen: false).tabController2=TabController(length:3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).tabController2.animateTo(widget.index);
      Provider.of<ExpenseProvider>(context, listen: false).tabController2.addListener(() {
        Provider.of<ExpenseProvider>(context, listen: false).updateIndex2(Provider.of<ExpenseProvider>(context, listen: false).tabController2.index);
      });
      Provider.of<TaskProvider>(context, listen: false).getAttendance(widget.taskId);
      Provider.of<ExpenseProvider>(context, listen: false).getTaskExpense(widget.taskId);
      Provider.of<CustomerProvider>(context, listen: false).getVisits(widget.coId,widget.taskId);
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer2<ExpenseProvider,TaskProvider>(builder: (context,expProvider,taskPvr,_){
      return SafeArea(
        child: Scaffold(
          backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
              preferredSize: const Size(300, 50),
              child: CustomAppbar(text: "Report",
              callback: widget.callback),
            ),
          body: Center(
            child: SizedBox(
              width: kIsWeb?webWidth:phoneWidth,
              // color: Colors.red,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if(widget.coName!="null")
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: CustomText(text: widget.coName,colors: colorsConst.primary,isBold: true,),
                      ),
                      CustomText(text: widget.type,colors: colorsConst.greyClr,isItalic: true,),
                    ],
                  ),
                  10.height,
                  Container(
                      height: 40,
                      decoration: customDecoration.baseBackgroundDecoration(
                          color: Colors.transparent,
                          radius: 5
                      ),
                      child: TabBar(
                        onTap: (index){
                          expProvider.updateIndex2(index);
                        },
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorWeight: 0,
                        indicator: customDecoration.baseBackgroundDecoration(
                            color: Colors.white,
                            borderColor: colorsConst.primary,
                            radius: 5
                        ),
                        labelColor: Colors.green,
                        unselectedLabelColor: Colors.green,
                        controller: expProvider.tabController2,
                        tabs:  const [
                          Tab(child:CustomText(text: "Visits")),
                          Tab(child:CustomText(text: "Visit Report")),
                          Tab(child:CustomText(text: "Expenses")),
                        ],
                      )
                  ),
                   Expanded(
                    child: TabBarView(
                        controller: expProvider.tabController2,
                        children: [
                          TaskAttendance(taskId: widget.taskId, customerAttendanceReport: taskPvr.customerAttendanceReport,),
                          CustomerVisits(companyId: widget.coId, customerList: widget.numberList, companyName: "", taskId: widget.taskId,),
                          expProvider.refresh==false?
                          const Loading():
                          Column(
                            children: [
                              expProvider.expenseData.isEmpty ?
                              Column(
                                children: [
                                  100.height,
                                  CustomText(text: "No Expense Found",
                                      colors: colorsConst.greyClr)
                                ],
                              ) :
                              Expanded(
                                child: ListView.builder(
                                    itemCount: expProvider.expenseData.length,
                                    itemBuilder: (context, index) {
                                      var createdBy = "";
                                      String timestamp = expProvider.expenseData[index].createdTs.toString();
                                      DateTime dateTime = DateTime.parse(timestamp);
                                      DateFormat('EEEE').format(dateTime);
                                      DateTime today = DateTime.now();
                                      if (dateTime.day == today.day && dateTime.month == today.month && dateTime.year == today.year) {
                                      } else if (dateTime.isAfter(today.subtract(const Duration(days: 1))) &&
                                          dateTime.isBefore(today)) {
                                      } else {
                                      }
                                      createdBy = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                                      return InkWell(
                                        onTap: (){
                                          utils.navigatePage(context, ()=> DashBoard(child: ExpenseDetails(visitId: widget.taskId, isExpense: false,companyId: widget.coId, id: expProvider.expenseData[index].id.toString(),
                                              name: expProvider.expenseData[index].firstname.toString(), role: expProvider.expenseData[index].role.toString(),
                                              customer: widget.coName.toString(), purpose: expProvider.expenseData[index].taskTitle.toString())));
                                          },
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                          child: Column(
                                            children: [
                                              if(index==0)
                                                const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      CustomText(text: "Employee Name",colors: Colors.grey,),
                                                      CustomText(text: "Visited Place",colors: Colors.grey,),
                                                      CustomText(text: "Total Amount",colors: Colors.grey,),
                                                    ],
                                                  ),
                                                ),
                                              Container(
                                                width: kIsWeb?webWidth:phoneWidth,
                                                decoration: customDecoration.baseBackgroundDecoration(
                                                    color: Colors.white,radius: 10
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          expProvider.expenseData[index].projectName.toString()!="null"?
                                                          Row(
                                                            children: [
                                                              const CustomText(text: "Task : ",colors: Colors.grey),
                                                              CustomText(text: expProvider.expenseData[index].projectName.toString(),colors: colorsConst.bankColor),
                                                            ],
                                                          ):
                                                          CustomText(text: expProvider.expenseData[index].status.toString()=="0"?"Rejected":expProvider.expenseData[index].status.toString()=="2"?"Approved":"In Process",
                                                            colors: expProvider.expenseData[index].status.toString()=="0"?colorsConst.appRed:expProvider.expenseData[index].status.toString()=="2"?colorsConst.appDarkGreen:Colors.grey,isItalic: true),
                                                          CustomText(text: createdBy,colors: Colors.grey,),
                                                        ],
                                                      ),
                                                      5.height,
                                                      if(expProvider.expenseData[index].projectName.toString()!="null")
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            SizedBox(
                                                                width: kIsWeb?webWidth/2:phoneWidth/1.4,
                                                                child: CustomText(text: expProvider.expenseData[index].taskTitle.toString(),colors: colorsConst.greyClr)),
                                                            CustomText(text: expProvider.expenseData[index].status.toString()=="0"?"Rejected":expProvider.expenseData[index].status.toString()=="2"?"Approved":"In Process",
                                                              colors: expProvider.expenseData[index].status.toString()=="0"?colorsConst.appRed:expProvider.expenseData[index].status.toString()=="2"?colorsConst.appDarkGreen:Colors.grey,isItalic: true,),
                                                          ],
                                                        ),
                                                      5.height,
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          if(expProvider.expenseData[index].firstname.toString()!="null")
                                                          CustomText(text: expProvider.expenseData[index].firstname.toString(),),
                                                          // CustomText(text: data.placeVisited.toString(),),
                                                          CustomText(text: "₹ ${utils.formatNo(expProvider.expenseData[index].amount.toString())}",colors: colorsConst.appRed,isBold: true,),
                                                        ],
                                                      ),
                                                      if(expProvider.expenseData[index].status.toString()=="2")
                                                      5.height,
                                                      if(expProvider.expenseData[index].status.toString()=="2")
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const CustomText(text: "Approved Amount : ",colors: Colors.blueGrey,),
                                                              CustomText(text: "₹ ${expProvider.expenseData[index].approvalAmt.toString()!=""&&expProvider.expenseData[index].approvalAmt.toString()!="null"?
                                                              utils.formatNo(expProvider.expenseData[index].approvalAmt.toString()):"0"}",colors: colorsConst.appOrg,isBold: true,),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              const CustomText(text: "Paid Amount : ",colors: Colors.blueGrey,),
                                                              CustomText(text: "₹ ${expProvider.expenseData[index].paidAmt.toString()!=""&&expProvider.expenseData[index].paidAmt.toString()!="null"?
                                                              utils.formatNo(expProvider.expenseData[index].paidAmt.toString()):"0"}",colors: colorsConst.appGreen,isBold: true,),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if(index==expProvider.expenseData.length-1)
                                                80.height
                                            ],
                                          ),
                                        ),
                                      );
                                      // :0.width;
                                    }),
                              ),
                            ],
                          )
                        ]),
                  )
                ],
              ),
            ),
          )
        ),
      );
    });
  }
  String getCreatedDate(data) {
    final timestamp = data.createdTs.toString();
    final dateTime = DateTime.parse(timestamp);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
}










