import 'package:master_code/screens/common/dashboard.dart';
import 'package:master_code/screens/report_dashboard/pie.dart';
import 'package:master_code/screens/task/customer_task_attendance.dart';
import 'package:master_code/screens/task/customer_task_expense.dart';
import 'package:master_code/screens/task/user_task_attendance.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/source/constant/local_data.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/customer_provider.dart';
import 'package:master_code/view_model/employee_provider.dart';
import 'package:master_code/view_model/report_provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_text.dart';
import '../../component/map_dropdown.dart';
import '../../component/search_drop_down.dart';
import '../../model/customer/customer_model.dart';
import '../../model/user_model.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/home_provider.dart';
import '../common/home_page.dart';
import '../task/customer_tasks.dart';
import '../task/user_task_expense.dart';
import '../task/user_tasks.dart';

class ReportDashboard extends StatefulWidget {

  const ReportDashboard({super.key,});

  @override
  State<ReportDashboard> createState() => _ReportDashboardState();
}

class _ReportDashboardState extends State<ReportDashboard> with SingleTickerProviderStateMixin{
  final ScrollController scrollController=ScrollController();
  final ScrollController scrollController1=ScrollController();
  final ScrollController scrollController3=ScrollController();
  final ScrollController scrollController4=ScrollController();
  var companyId="";
  var companyName="";
  @override
  void initState() {
    Provider.of<ReportProvider>(context, listen: false).tabController=TabController(length:2, vsync: this);
    Future.delayed(Duration.zero, () {
      Provider.of<ReportProvider>(context, listen: false).tabController.addListener(() {
        Provider.of<ReportProvider>(context, listen: false).updateIndex(Provider.of<ReportProvider>(context, listen: false).tabController.index);
      });
      Provider.of<ReportProvider>(context, listen: false).initValue();
      Provider.of<ReportProvider>(context, listen: false).daily4();
      if(localData.storage.read("role")!="1"){
        Provider.of<ReportProvider>(context, listen: false).getCReport1(localData.storage.read("id"));
        Provider.of<ReportProvider>(context, listen: false).getReport3(localData.storage.read("id"));
        Provider.of<ReportProvider>(context, listen: false).getCReport3(localData.storage.read("id"));
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer4<ReportProvider,EmployeeProvider,CustomerProvider,HomeProvider>(builder: (context,repProvider,
        empProvider,cusPr,homeProvider,_){
      return Scaffold(
      backgroundColor: colorsConst.bacColor,
      appBar: PreferredSize(
        preferredSize: const Size(300, 50),
        child: CustomAppbar(text: constValue.reportDashboard,callback: (){
          homeProvider.updateIndex(0);
          utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
        }),
      ),
      body:PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          homeProvider.updateIndex(0);
          if (!didPop) {
            utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
          }
        },
        child: Center(
          child: SizedBox(
            width: kIsWeb?webWidth:phoneWidth,
            child: Column(
              children: [
                Container(
                    height: 40,
                    decoration: customDecoration.baseBackgroundDecoration(
                        color: Colors.transparent,
                        radius: 5
                    ),
                    child: TabBar(
                      onTap: (index){
                        repProvider.updateIndex(index);
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
                      controller: repProvider.tabController,
                      tabs:  const [
                        Tab(child:CustomText(text: "Employee")),
                        Tab(child:CustomText(text: "Customer")),
                      ],
                    )
                ),
                Expanded(
                  child: TabBarView(
                      controller: repProvider.tabController,
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              10.height,
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      repProvider.datePick(
                                        context: context,
                                        date: repProvider.startDate,
                                        isStartDate: true, function: () {
                                        repProvider.getCReport1(repProvider.user.toString());
                                        repProvider.getReport3(repProvider.user.toString());
                                        repProvider.getCReport3(repProvider.user.toString());
                                      },
                                      );
                                    },
                                    child: Container(
                                      height: 30,
                                      width: kIsWeb?MediaQuery.of(context).size.width*0.15:MediaQuery.of(context).size.width * 0.24,
                                      decoration: customDecoration.baseBackgroundDecoration(
                                        color: Colors.white,
                                        radius: 5,
                                        borderColor: colorsConst.litGrey,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CustomText(text: repProvider.startDate,size: 12,),
                                          5.width,
                                          SvgPicture.asset(assets.calendar2),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 30,
                                    width: kIsWeb?MediaQuery.of(context).size.width*0.17:MediaQuery.of(context).size.width * 0.33,
                                    decoration: customDecoration.baseBackgroundDecoration(
                                      radius: 5,
                                      color: Colors.white,
                                      borderColor: colorsConst.litGrey,
                                    ),
                                    child: DropdownButton(
                                      iconEnabledColor: colorsConst.greyClr,
                                      isExpanded: true,
                                      underline: const SizedBox(),
                                      icon: const Icon(Icons.keyboard_arrow_down_outlined),
                                      value: repProvider.type,
                                      onChanged: (value) {
                                        repProvider.changeType(value);
                                        repProvider.getCReport1(repProvider.user.toString());
                                        repProvider.getReport3(repProvider.user.toString());
                                        repProvider.getCReport3(repProvider.user.toString());
                                      },
                                      items: repProvider.typeList.map((list) {
                                        return DropdownMenuItem(
                                          value: list,
                                          child: CustomText(
                                            text: "  $list",
                                            colors: Colors.black,
                                            isBold: false,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      repProvider.showCustomMonthPicker(
                                        context: context,
                                        function: (){
                                          repProvider.getCReport1(repProvider.user.toString());
                                          repProvider.getReport3(repProvider.user.toString());
                                          repProvider.getCReport3(repProvider.user.toString());
                                        },
                                      );
                                    },
                                    child: Container(
                                      height: 30,
                                      width: kIsWeb?MediaQuery.of(context).size.width*0.15:MediaQuery.of(context).size.width * 0.25,
                                      decoration: customDecoration.baseBackgroundDecoration(
                                        color: Colors.white,
                                        radius: 5,
                                        borderColor: colorsConst.litGrey,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CustomText(text: repProvider.month,size: 12,),
                                          5.width,
                                          SvgPicture.asset(assets.calendar2),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),10.height,
                              if(localData.storage.read("role")=="1")
                              EmployeeDropdown(
                                  callback: (){
                                    empProvider.getAllUsers();
                                  },
                                  text: repProvider.user==null?"Employee Name":repProvider.userName==""?"Employee Name":repProvider.userName,
                                  employeeList: empProvider.filterUserData,
                                  onChanged: (UserModel? value) {
                                    repProvider.selectUser(value!);
                                  },
                                  size: kIsWeb?webWidth:phoneWidth,),
                              10.height,
                              InkWell(
                                onTap: (){
                                  if((repProvider.taskReport.isEmpty)||(repProvider.taskReport.isNotEmpty&&repProvider.taskReport[0]["total_tasks"].toString()=="0")){

                                  }else{
                                    utils.navigatePage(context, ()=>UserTasks(date1: repProvider.startDate,date2: repProvider.endDate, name: repProvider.userName, id: repProvider.user.toString(),));
                                  }
                                },
                                child: Container(
                                  // height: 350,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10)
                                      )
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(5, 15, 5, 0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomText(text: "    Tasks",isBold: true,size: 17,colors: colorsConst.primary,),
                                            if(repProvider.taskReport.isNotEmpty)
                                            CustomText(text: repProvider.taskReport[0]["total_tasks"].toString(),isBold: true,size: 17,colors: colorsConst.primary,),
                                          ],
                                        ),
                                        repProvider.user==null&&localData.storage.read("role")=="1"?
                                        Center(child: CustomText(text: "\n\nSelect User Name\n\n\n\n",colors: colorsConst.greyClr,)):
                                        repProvider.reportRefresh==false?const Padding(
                                          padding: EdgeInsets.all(50.0),
                                          child: Loading(),
                                        ):
                                        (repProvider.taskReport.isEmpty)||(repProvider.taskReport.isNotEmpty&&repProvider.taskReport[0]["total_tasks"].toString()=="0")?
                                        Center(child: CustomText(text: "\n\nNo data found\n\n\n\n",colors: colorsConst.greyClr,)):
                                        const TaskPieChart(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              10.height,
                              InkWell(
                                onTap: (){
                                  if(repProvider.visitReport.isEmpty||(repProvider.visitReport.length==1&&repProvider.visitReport[0].totalAttendance==0)){

                                  }else{
                                    utils.navigatePage(context, ()=>UserTaskAttendance(date1: repProvider.startDate,date2: repProvider.endDate, name: repProvider.userName, id: repProvider.user.toString(),));
                                  }
                                },
                                child: Container(
                                  width:kIsWeb?webWidth:phoneWidth,
                                  decoration: customDecoration.baseBackgroundDecoration(
                                      color: Colors.white,radius: 10
                                  ),
                                  height: 270,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      10.height,
                                      CustomText(text: "    Total Visits\n",isBold: true,size: 17,colors: colorsConst.primary,),
                                      repProvider.user==null&&localData.storage.read("role")=="1"?
                                      Center(child: CustomText(text: "\n\nSelect User Name",colors: colorsConst.greyClr,)):
                                      repProvider.reportRefresh==false?const Padding(
                                        padding: EdgeInsets.all(50.0),
                                        child: Loading(),
                                      ):
                                      repProvider.visitReport.isEmpty||(repProvider.visitReport.length==1&&repProvider.visitReport[0].totalAttendance.toString()=="0")?
                                      Center(child: CustomText(text: "\n\nNo data found",colors: colorsConst.greyClr,)):
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                                        child: SizedBox(
                                          height: 145,
                                          // color: Colors.grey,
                                          child: Scrollbar(
                                            controller: scrollController1,
                                            thumbVisibility: true,
                                            trackVisibility: true,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              controller: scrollController1,
                                              child: SizedBox(
                                                width: repProvider.empBarGroups.length * 40,
                                                child: Stack(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                                                      child: BarChart(
                                                        BarChartData(
                                                          barTouchData: barTouchData,
                                                          titlesData: repProvider.empTitlesData,
                                                            barGroups: repProvider.empBarGroups,
                                                          borderData: FlBorderData(show: false),
                                                          gridData: const FlGridData(show: false),
                                                          alignment: BarChartAlignment.spaceAround,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned.fill(
                                                      child: LayoutBuilder(
                                                        builder: (context, constraints) {
                                                          const barSpacing = 20.0; // or your custom spacing
                                                          return Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                            children: List.generate(repProvider.empBarGroups.length, (index) {
                                                              final yValue = repProvider.empBarGroups[index].barRods[0].toY;
                                                              return SizedBox(
                                                                width: barSpacing,
                                                                child: Column(
                                                                  children: [
                                                                    CustomText(
                                                                      text:yValue.round().toString()=="0"?"":yValue.round().toString(),colors: colorsConst.primary,
                                                                    ),
                                                                    5.height,
                                                                  ],
                                                                ),
                                                              );
                                                            }),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              10.height,
                              InkWell(
                                onTap: (){
                                  if(repProvider.expenseReport.isEmpty||(repProvider.expenseReport.length==1&&repProvider.expenseReport[0].total==0)){

                                  }else{
                                    utils.navigatePage(context, ()=>UserTaskExpense(date1: repProvider.startDate,date2: repProvider.endDate, name: repProvider.userName, id: repProvider.user.toString(),));
                                  }
                                },
                                child: Container(
                                  width:kIsWeb?webWidth:phoneWidth,
                                  decoration: customDecoration.baseBackgroundDecoration(
                                      color: Colors.white,radius: 10
                                  ),
                                  height: 220,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      10.height,
                                      CustomText(text: "    Expenses\n",isBold: true,size: 17,colors: colorsConst.primary,),
                                      repProvider.user==null&&localData.storage.read("role")=="1"?
                                      Center(child: CustomText(text: "\n\nSelect User Name",colors: colorsConst.greyClr,)):
                                      repProvider.reportRefresh==false?const Padding(
                                        padding: EdgeInsets.all(50.0),
                                        child: Loading(),
                                      ):
                                      repProvider.expenseReport.isEmpty||(repProvider.expenseReport.length==1&&repProvider.expenseReport[0].total==0)?
                                      Center(child: CustomText(text: "\n\nNo data found",colors: colorsConst.greyClr,)):
                                      // Padding(
                                      //   padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                                      //   child: SizedBox(
                                      //     height: 135,
                                      //     // color: Colors.grey,
                                      //     child: Scrollbar(
                                      //       controller: scrollController,
                                      //       thumbVisibility: true,
                                      //       trackVisibility: true,
                                      //       child: SingleChildScrollView(
                                      //         scrollDirection: Axis.horizontal,
                                      //         controller: scrollController,
                                      //         child: SizedBox(
                                      //           width: repProvider.barGroups.length * 40,
                                      //           child: Stack(
                                      //             children: [
                                      //               Padding(
                                      //                 padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                                      //                 child: BarChart(
                                      //                   BarChartData(
                                      //                     groupsSpace: 20,
                                      //                     barTouchData: expBarTouchData,
                                      //                     titlesData: repProvider.expTitlesData,
                                      //                     borderData: repProvider.expBorderData,
                                      //                     barGroups: repProvider.expBarGroups,
                                      //                     gridData: const FlGridData(show: false),
                                      //                     alignment: BarChartAlignment.spaceAround,
                                      //                   ),
                                      //                 ),
                                      //               ),
                                      //               Positioned.fill(
                                      //                 child: LayoutBuilder(
                                      //                   builder: (context, constraints) {
                                      //                     const barSpacing = 20.0; // or your custom spacing
                                      //                     return Row(
                                      //                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      //                       children: List.generate(repProvider.expBarGroups.length, (index) {
                                      //                         final yValue = repProvider.expBarGroups[index].barRods[0].toY;
                                      //                         return SizedBox(
                                      //                           width: barSpacing,
                                      //                           child: Column(
                                      //                             children: [
                                      //                               CustomText(
                                      //                                 text:yValue.round().toString()=="0"?"":yValue.round().toString(),colors: colorsConst.primary,size:8,
                                      //                               ),
                                      //                               5.height,
                                      //                             ],
                                      //                           ),
                                      //                         );
                                      //                       }),
                                      //                     );
                                      //                   },
                                      //                 ),
                                      //               ),
                                      //             ],
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                        child: SizedBox(
                                          height: 135,
                                          child: Scrollbar(
                                            controller: scrollController,
                                            thumbVisibility: true,
                                            trackVisibility: true,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              controller: scrollController,
                                              child: SizedBox(
                                                height: 100,
                                                // color: Colors.yellow,
                                                width: repProvider.expBarGroups.length * 50,
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(0, 25, 0, 10),
                                                  child: BarChart(
                                                    BarChartData(
                                                      groupsSpace: 20,
                                                      alignment: BarChartAlignment.spaceAround,
                                                      barTouchData: expenseBarTouchData,
                                                      titlesData: repProvider.employeeExpenseTitlesData,
                                                      borderData: repProvider.expBorderData,
                                                      barGroups: repProvider.expBarGroups,
                                                      gridData: const FlGridData(show: false),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              20.height,
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              10.height,
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      repProvider.datePick4(
                                          date: repProvider.startDate4,
                                          context: context,id:companyId);
                                    },
                                    child: Container(
                                      height: 30,
                                      width: kIsWeb?MediaQuery.of(context).size.width*0.15:MediaQuery.of(context).size.width * 0.24,
                                      decoration: customDecoration.baseBackgroundDecoration(
                                        color: Colors.white,
                                        radius: 5,
                                        borderColor: colorsConst.litGrey,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CustomText(text: repProvider.startDate4,size: 12,),
                                          5.width,
                                          SvgPicture.asset(assets.calendar2),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 30,
                                    width: kIsWeb?MediaQuery.of(context).size.width*0.17:MediaQuery.of(context).size.width * 0.33,
                                    decoration: customDecoration.baseBackgroundDecoration(
                                      radius: 5,
                                      color: Colors.white,
                                      borderColor: colorsConst.litGrey,
                                    ),
                                    child: DropdownButton(
                                      iconEnabledColor: colorsConst.greyClr,
                                      isExpanded: true,
                                      underline: const SizedBox(),
                                      icon: const Icon(Icons.keyboard_arrow_down_outlined),
                                      value: repProvider.type4,
                                      onChanged: (value) {
                                        repProvider.changeType4(value,companyId);
                                      },
                                      items: repProvider.typeList.map((list) {
                                        return DropdownMenuItem(
                                          value: list,
                                          child: CustomText(
                                            text: "  $list",
                                            colors: Colors.black,
                                            isBold: false,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      repProvider.showCustomMonthPicker4(
                                        context: context,
                                        function: (){
                                          repProvider.getCustomerTasks(companyId);
                                          repProvider.getCustomerVisits(companyId);
                                          repProvider.getCustomerExpense(companyId);
                                        },
                                      );
                                    },
                                    child: Container(
                                      height: 30,
                                      width: kIsWeb?MediaQuery.of(context).size.width*0.15:MediaQuery.of(context).size.width * 0.25,
                                      decoration: customDecoration.baseBackgroundDecoration(
                                        color: Colors.white,
                                        radius: 5,
                                        borderColor: colorsConst.litGrey,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CustomText(text: repProvider.month4,size: 12,),
                                          5.width,
                                          SvgPicture.asset(assets.calendar2),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),10.height,
                              CustomerDropdown(
                                  text: companyId==""?constValue.companyName:companyName,
                                  isRequired: true,hintText: false,
                                  employeeList: cusPr.customer,
                                  onChanged: (CustomerModel? value) {
                                    setState(() {
                                      companyId=value!.userId.toString();
                                      companyName=value.companyName.toString();
                                      repProvider.getCustomerTasks(companyId);
                                      repProvider.getCustomerVisits(companyId);
                                      repProvider.getCustomerExpense(companyId);
                                    });
                                  }, size: kIsWeb?webWidth:phoneWidth,),
                              10.height,
                              InkWell(
                                onTap: (){
                                  if((repProvider.customerTasks.isEmpty)||(repProvider.customerTasks.isNotEmpty&&repProvider.customerTasks[0]["total_tasks"].toString()=="0")){

                                  }else{
                                    utils.navigatePage(context, ()=>CustomerTasks(date1: repProvider.startDate4,date2: repProvider.endDate4, name: companyName, id: companyId));
                                  }
                                },
                                child: Container(
                                  // height: 350,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10)
                                      )
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(5, 15, 5, 0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomText(text: "    Tasks\n",isBold: true,size: 17,colors: colorsConst.primary,),
                                        companyId==""&&localData.storage.read("role")=="1"?
                                        Center(child: CustomText(text: "\n\nSelect Customer Name\n\n\n\n",colors: colorsConst.greyClr,)):
                                        repProvider.reportRefresh==false?const Padding(
                                          padding: EdgeInsets.all(50.0),
                                          child: Loading(),
                                        ):
                                        (repProvider.customerTasks.isEmpty)||(repProvider.customerTasks.isNotEmpty&&repProvider.customerTasks[0]["total_tasks"].toString()=="0")?
                                        Center(child: CustomText(text: "\n\nNo data found\n\n\n\n",colors: colorsConst.greyClr,)):
                                        const CustomerTaskPieChart(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              10.height,
                              InkWell(
                                onTap: (){
                                  if(repProvider.customerVisits.isEmpty||(repProvider.customerVisits.length==1&&repProvider.customerVisits[0].totalAttendance==0)){

                                  }else{
                                    utils.navigatePage(context, ()=>CustomerTaskAttendance(date1: repProvider.startDate4,date2: repProvider.endDate4, name: companyName, id: companyId,));
                                  }
                                },
                                child: Container(
                                  width:kIsWeb?webWidth:phoneWidth,
                                  decoration: customDecoration.baseBackgroundDecoration(
                                      color: Colors.white,radius: 10
                                  ),
                                  height: 270,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      10.height,
                                      CustomText(text: "    Total Visits\n",isBold: true,size: 17,colors: colorsConst.primary,),
                                      companyId==""&&localData.storage.read("role")=="1"?
                                      Center(child: CustomText(text: "\n\nSelect Customer Name",colors: colorsConst.greyClr,)):
                                      repProvider.reportRefresh==false?const Padding(
                                        padding: EdgeInsets.all(50.0),
                                        child: Loading(),
                                      ):
                                      repProvider.customerVisits.isEmpty||(repProvider.customerVisits.length==1&&repProvider.customerVisits[0].totalAttendance==0)?
                                      Center(child: CustomText(text: "\n\nNo data found",colors: colorsConst.greyClr,)):
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                                        child: SizedBox(
                                          height: 145,
                                          // color: Colors.grey,
                                          child: Scrollbar(
                                            controller: scrollController3,
                                            thumbVisibility: true,
                                            trackVisibility: true,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              controller: scrollController3,
                                              child: SizedBox(
                                                width: repProvider.barGroups3.length * 40,
                                                child: Stack(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                                                      child: BarChart(
                                                        BarChartData(
                                                          barTouchData: barTouchData,
                                                          titlesData: repProvider.titlesData3,
                                                          borderData: repProvider.borderData3,
                                                          barGroups: repProvider.barGroups3,
                                                          gridData: const FlGridData(show: false),
                                                          alignment: BarChartAlignment.spaceAround,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned.fill(
                                                      child: LayoutBuilder(
                                                        builder: (context, constraints) {
                                                          const barSpacing = 20.0; // or your custom spacing
                                                          return Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                            children: List.generate(repProvider.barGroups3.length, (index) {
                                                              final yValue = repProvider.barGroups3[index].barRods[0].toY;
                                                              return SizedBox(
                                                                width: barSpacing,
                                                                child: Column(
                                                                  children: [
                                                                    CustomText(
                                                                      text:yValue.round().toString()=="0"?"":yValue.round().toString(),colors: colorsConst.primary,
                                                                    ),
                                                                    5.height,
                                                                  ],
                                                                ),
                                                              );
                                                            }),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              10.height,
                              InkWell(
                                onTap: (){
                                  if(repProvider.customerExpenseReport.isEmpty||(repProvider.customerExpenseReport.length==1&&repProvider.customerExpenseReport[0].total==0)){

                                  }else{
                                    utils.navigatePage(context, ()=>CustomerTaskExpense(date1: repProvider.startDate,date2: repProvider.endDate, name: companyName, id: companyId,));
                                  }
                                },
                                child: Container(
                                  width:kIsWeb?webWidth:phoneWidth,
                                  decoration: customDecoration.baseBackgroundDecoration(
                                      color: Colors.white,radius: 10
                                  ),
                                  height: 220,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      10.height,
                                      CustomText(text: "    Expenses\n",isBold: true,size: 17,colors: colorsConst.primary,),
                                      companyId==""&&localData.storage.read("role")=="1"?
                                      Center(child: CustomText(text: "\n\nSelect Customer Name",colors: colorsConst.greyClr,)):
                                      repProvider.reportRefresh==false?const Padding(
                                        padding: EdgeInsets.all(50.0),
                                        child: Loading(),
                                      ):
                                      repProvider.customerExpenseReport.isEmpty||(repProvider.customerExpenseReport.length==1&&repProvider.customerExpenseReport[0].total==0)?
                                      Center(child: CustomText(text: "\n\nNo data found",colors: colorsConst.greyClr,)):
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                        child: SizedBox(
                                          height: 135,
                                          // color: Colors.grey,
                                          child: Scrollbar(
                                            controller: scrollController4,
                                            thumbVisibility: true,
                                            trackVisibility: true,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              controller: scrollController4,
                                              child: SizedBox(
                                                height: 100,
                                                width: repProvider.barGroups4.length * 50,
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(0, 25, 0, 10),
                                                  child: BarChart(
                                                    BarChartData(
                                                      groupsSpace: 20,
                                                      barTouchData: expenseBarTouchData,
                                                      titlesData: repProvider.expTitlesData4,
                                                      borderData: repProvider.expBorderData,
                                                      barGroups: repProvider.expBarGroups4,
                                                      gridData: const FlGridData(show: false),
                                                      alignment: BarChartAlignment.spaceAround,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]))
              ],
            ),
          ),
        ),
      ),
      );
    });
  }

  BarTouchData get barTouchData => BarTouchData(
    enabled: false,
    touchTooltipData: BarTouchTooltipData(
      getTooltipColor: (group) => Colors.transparent,
      tooltipPadding: EdgeInsets.zero,
      tooltipMargin: 2,
      getTooltipItem: (
          BarChartGroupData group,
          int groupIndex,
          BarChartRodData rod,
          int rodIndex,
          ) {
        return BarTooltipItem(
          rod.toY.round().toString(),
          const TextStyle(
            color: Colors.transparent,
            fontSize: 0,
          ),
        );
      },
    ),
  );
  BarTouchData get expenseBarTouchData => BarTouchData(
    enabled: true, // ✅ now tapping a bar shows tooltip
    touchTooltipData: BarTouchTooltipData(
      getTooltipColor: (group) => Colors.white,
      tooltipPadding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
      tooltipMargin: 1,
      getTooltipItem: (
          BarChartGroupData group,
          int groupIndex,
          BarChartRodData rod,
          int rodIndex,
          ) {
        return BarTooltipItem(
          "₹${rod.toY.round()}",
          const TextStyle(
            fontSize: 10,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    ),
  );

// BarTouchData get expBarTouchData => BarTouchData(
  //   enabled: false,
  //   touchTooltipData: BarTouchTooltipData(
  //     getTooltipColor: (group) => Colors.transparent,
  //     tooltipPadding: EdgeInsets.zero,
  //     tooltipMargin: 2,
  //     getTooltipItem: (
  //         BarChartGroupData group,
  //         int groupIndex,
  //         BarChartRodData rod,
  //         int rodIndex,
  //         ) {
  //       return BarTooltipItem(
  //         "₹${rod.toY.round().toString()}",
  //         const TextStyle(
  //           fontSize: 10,
  //         ),
  //       );
  //     },
  //   ),
  // );

}

class MonthReport {
  // String? totalAttendance;
  int? totalAttendance;
  int? total;
  String? date;
  String? dt;
  String? leaveCount;
  MonthReport({
    this.total,
    this.totalAttendance,
    this.dt,
    this.date,
    this.leaveCount
  });
  factory MonthReport.fromJson(Map<String, dynamic> json){
    return MonthReport(
      // totalAttendance: json["total_attendance"],
        total: int.tryParse(json["total"] ?? '0'),
        totalAttendance: int.tryParse(json["complete_count"] ?? '0'),
        date:json["formatted_date"],
        dt:json["dt"],
        leaveCount:json["not_complete_count"]?? '0'
    );
  }
}