import 'package:master_code/screens/expense/pie.dart';
import 'package:master_code/view_model/expense_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/source/constant/local_data.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/employee_provider.dart';
import '../../component/custom_text.dart';
import '../../component/map_dropdown.dart';
import '../../model/user_model.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/styles/decoration.dart';

class ExpenseDashboard extends StatefulWidget {

  const ExpenseDashboard({super.key,});

  @override
  State<ExpenseDashboard> createState() => _ExpenseDashboardState();
}

class _ExpenseDashboardState extends State<ExpenseDashboard> {
  final ScrollController scrollController1=ScrollController();
  final ScrollController scrollController2=ScrollController();
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<ExpenseProvider>(context, listen: false).initValue();
      Provider.of<ExpenseProvider>(context, listen: false).getReport2();
      if(localData.storage.read("role")!="1"){
        Provider.of<ExpenseProvider>(context, listen: false).getReport3();
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer2<ExpenseProvider,EmployeeProvider>(builder: (context,expProvider,empProvider,_){
      return Scaffold(
      backgroundColor: colorsConst.bacColor,
      body:SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: kIsWeb?webWidth:phoneWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                10.height,
                Container(
                  decoration: customDecoration.baseBackgroundDecoration(
                      color: Colors.white,radius: 10
                  ),
                  height: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      10.height,
                      CustomText(text: "    Expense Head",isBold: true,size: 17,colors: colorsConst.primary,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: MapDropDown(
                              isHint: false,
                              isRefresh: expProvider.expenseList.isEmpty?true:false,
                              callback: (){
                                if(!kIsWeb){
                                  expProvider.refreshExpense();
                                }else{
                                  expProvider.getExpenseType();
                                }
                              },
                              hintText: "Mode",
                              list: expProvider.expenseList,
                              onChanged: (value) {
                                expProvider.selectType(value);
                              },
                              width: kIsWeb?webWidth/2.2:phoneWidth/2.2,
                              saveValue: expProvider.exType, dropText: 'value',),
                          ),
                          Container(
                            height: 45,
                            width: kIsWeb?webWidth/2.2:phoneWidth/2.2,
                            decoration: customDecoration.baseBackgroundDecoration(
                              radius: 10,
                              color: Colors.white,
                              borderColor: colorsConst.litGrey,
                            ),
                            child: DropdownButton(
                              iconEnabledColor: colorsConst.greyClr,
                              isExpanded: true,
                              underline: const SizedBox(),
                              icon: const Icon(Icons.keyboard_arrow_down_outlined),
                              value: expProvider.type,
                              onChanged: (value) {
                                expProvider.changeType(value);
                              },
                              items: expProvider.typeList.map((list) {
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
                        ],
                      ),5.height,
                      expProvider.exType==null?
                      Center(child: CustomText(text: "\n\nSelect Type",colors: colorsConst.greyClr,)):
                      expProvider.refresh1==false?const Padding(
                        padding: EdgeInsets.all(50.0),
                        child: Loading(),
                      ):
                      expProvider.report.isEmpty||(expProvider.report.length==1&&expProvider.report[0].totalAttendance==0)?
                      Center(child: CustomText(text: "\n\nNo data found",colors: colorsConst.greyClr,)):
                      // SizedBox(
                      //   height: 145,
                      //   child: BarChart(
                      //     BarChartData(
                      //       barTouchData: barTouchData,
                      //       titlesData: expProvider.titlesData,
                      //       borderData: expProvider.borderData,
                      //       barGroups: expProvider.barGroups,
                      //       gridData: const FlGridData(show: false),
                      //       alignment: BarChartAlignment.spaceAround,
                      //       // maxY: 100,
                      //       // groupsSpace:2
                      //     ),
                      //   ),
                      // ),
                      SizedBox(
                        height: 145,
                        child: Scrollbar(
                          controller: scrollController1,
                          thumbVisibility: true,
                          trackVisibility: true,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: scrollController1,
                            child: SizedBox(
                              width: expProvider.barGroups.length * 40, // Adjust based on bar count
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: BarChart(
                                      BarChartData(
                                        barTouchData: barTouchData,
                                        titlesData: expProvider.titlesData,
                                        borderData: expProvider.borderData,
                                        barGroups: expProvider.barGroups,
                                        gridData: const FlGridData(show: false),
                                        alignment: BarChartAlignment.spaceAround,
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        const barSpacing = 40.0; // or your custom spacing
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: List.generate(expProvider.barGroups.length, (index) {
                                            final yValue = expProvider.barGroups[index].barRods[0].toY;
                                            return SizedBox(
                                              width: barSpacing,
                                              child: Column(
                                                children: [
                                                  CustomText(
                                                    text:yValue.round().toString()=="0"?"":yValue.round().toString(),colors: colorsConst.primary,size: yValue.round().toString().length==7?9:10,
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
                    ],
                  ),
                ),
                10.height,
                Container(
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
                        CustomText(text: "Travel Report\n",isBold: true,size: 17,colors: colorsConst.primary,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                expProvider.datePick2(
                                  context: context,
                                  date:expProvider.startDate2
                                );
                              },
                              child: Container(
                                height: 30,
                                width: kIsWeb?webWidth/3.2:phoneWidth/3.2,
                                decoration: customDecoration.baseBackgroundDecoration(
                                  color: Colors.white,
                                  radius: 5,
                                  borderColor: colorsConst.litGrey,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomText(text: expProvider.startDate2,size: 11,),
                                    SvgPicture.asset(assets.calendar2),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 30,
                              width: kIsWeb?webWidth/3.2:phoneWidth/3.2,
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
                                value: expProvider.type2,
                                onChanged: (value) {
                                  expProvider.changeType2(value);
                                },
                                items: expProvider.typeList2.map((list) {
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
                                expProvider.showCustomMonthPicker2(
                                  context: context,
                                  function: (){
                                    expProvider.getReport2();
                                  },
                                );
                              },
                              child: Container(
                                height: 30,
                                width: kIsWeb?webWidth/3.2:phoneWidth/3.2,
                                decoration: customDecoration.baseBackgroundDecoration(
                                  color: Colors.white,
                                  radius: 5,
                                  borderColor: colorsConst.litGrey,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomText(text: expProvider.month2,size: 12,),
                                    5.width,
                                    SvgPicture.asset(assets.calendar2),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        expProvider.refresh2==false?const Padding(
                          padding: EdgeInsets.all(50.0),
                          child: Loading(),
                        ):
                        expProvider.report2.isEmpty?
                        Center(child: CustomText(text: "\n\nNo data found\n\n\n\n",colors: colorsConst.greyClr,)):
                        const TravelPieChart(),
                      ],
                    ),
                  ),
                ),
                10.height,
                Container(
                  decoration: customDecoration.baseBackgroundDecoration(
                      color: Colors.white,radius: 10
                  ),
                  height: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      10.height,
                      CustomText(text: "    Employee\n",isBold: true,size: 17,colors: colorsConst.primary,),
                      // CustomText(text:expProvider.formatDate("2025-05-01"),isBold: true,size: 17,colors: colorsConst.primary,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if(localData.storage.read("role")=="1")
                            EmployeeDropdown(
                              callback: (){
                                empProvider.getAllUsers();
                              },
                              text: expProvider.user==null?"Employee Name":"",
                              employeeList: empProvider.activeEmps,
                              onChanged: (UserModel? value) {
                                expProvider.selectUser(value!);
                              },
                              size: kIsWeb?webWidth/2.2:phoneWidth/2.2,
                            ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, empProvider.activeEmps.isEmpty?20:0, 0, 0),
                            child: Container(
                              height: 42,
                              width: localData.storage.read("role")=="1"&&kIsWeb?webWidth/2.2:
                              localData.storage.read("role")=="1"&&!kIsWeb?phoneWidth/2.2:
                              localData.storage.read("role")!="1"&&kIsWeb?webWidth/1:phoneWidth/1,
                              decoration: customDecoration.baseBackgroundDecoration(
                                radius: 10,
                                color: Colors.white,
                                borderColor: colorsConst.litGrey,
                              ),
                              child: DropdownButton(
                                iconEnabledColor: colorsConst.greyClr,
                                isExpanded: true,
                                underline: const SizedBox(),
                                icon: const Icon(Icons.keyboard_arrow_down_outlined),
                                value: expProvider.type3,
                                onChanged: (value) {
                                  expProvider.changeType3(value);
                                },
                                items: expProvider.typeList.map((list) {
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
                          ),
                        ],
                      ),
                      20.height,
                      expProvider.user==null&&localData.storage.read("role")=="1"?
                      Center(child: CustomText(text: "\n\nSelect User Name",colors: colorsConst.greyClr,)):
                      expProvider.refresh3==false?const Padding(
                        padding: EdgeInsets.all(50.0),
                        child: Loading(),
                      ):
                      expProvider.report3.isEmpty||(expProvider.report3.length==1&&expProvider.report3[0].totalAttendance==0)?
                      Center(child: CustomText(text: "\n\nNo data found",colors: colorsConst.greyClr,)):
                      SizedBox(
                        // color: Colors.yellow,
                        height: 130,
                        child: Scrollbar(
                          controller: scrollController2,
                          thumbVisibility: true,
                          trackVisibility: true,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: scrollController2,
                            child: SizedBox(
                              width: expProvider.barGroups2.length * 40, // Adjust based on bar count
                              child: Stack(
                                children:[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(5, 20, 5, 20),
                                    child: BarChart(
                                      BarChartData(
                                        barTouchData: barTouchData,
                                        titlesData: expProvider.titlesData2,
                                        borderData: expProvider.borderData,
                                        barGroups: expProvider.barGroups2,
                                        gridData: const FlGridData(show: false),
                                        alignment: BarChartAlignment.spaceAround,
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        const barSpacing = 40.0; // or your custom spacing
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: List.generate(expProvider.barGroups2.length, (index) {
                                            final yValue = expProvider.barGroups2[index].barRods[0].toY;
                                            return SizedBox(
                                              width: barSpacing,
                                              child: Column(
                                                children: [
                                                  CustomText(
                                                    text:yValue.round().toString()=="0"?"":yValue.round().toString(),colors: colorsConst.primary,size: yValue.round().toString().length==7?9:10,
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
                                ]
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Padding(
                      //   padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                      //   child: SizedBox(
                      //     height: 150,
                      //     child: SingleChildScrollView(
                      //       scrollDirection: Axis.horizontal,
                      //       child: SizedBox(
                      //         width: expProvider.barGroups.length * 40, // Adjust based on bar count
                      //         child: BarChart(
                      //           BarChartData(
                      //             barTouchData: barTouchData,
                      //             titlesData: expProvider.titlesData2,
                      //             borderData: expProvider.borderData,
                      //             barGroups: expProvider.barGroups2,
                      //             gridData: const FlGridData(show: false),
                      //             alignment: BarChartAlignment.spaceAround,
                      //             // maxY: 150,
                      //             // groupsSpace:2
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                40.height,
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

}

class MonthReport {
  // String? totalAttendance;
  int? totalAttendance;
  String? date;
  String? date2;
  String? leaveCount;
  String? expenseDate;
  MonthReport({
    this.totalAttendance,
    this.date,
    this.date2,
    this.leaveCount,
    this.expenseDate
  });
  factory MonthReport.fromJson(Map<String, dynamic> json){
    return MonthReport(
      // totalAttendance: json["total_attendance"],
        totalAttendance: int.tryParse(json["total_amount"]),
        date:json["formatted_date"],
        date2:json["date"],
        expenseDate:json["created_date"],
        leaveCount:json["not_complete_count"]?? '0'
    );
  }
}