import 'package:master_code/component/custom_text.dart';
import 'package:master_code/screens/common/setting.dart';
import 'package:master_code/screens/group_attendance/project_attendance.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/constant/default_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../component/panel_button.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/local_data.dart';
import '../../view_model/home_provider.dart';
import '../customer/view_all_customer.dart';
import '../employee/view_all_employees.dart';
import '../expense/expense_page.dart';
import '../leave_management/leave_dashboard.dart';
import '../leave_management/leave_report.dart';
import '../payroll/payroll_dashboard.dart';
import '../project/view_all_project.dart';
import '../task/view_task.dart';
import 'home_page.dart';

class DashBoard extends StatefulWidget {
  final Widget child;
  const DashBoard({super.key, required this.child});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> with SingleTickerProviderStateMixin{
  final ScrollController scrollController=ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, homeProvider, _) {
      final homeProvider = context.read<HomeProvider>();
      return SafeArea(
        child: Scaffold(
          backgroundColor: colorsConst.bacColor,
          bottomNavigationBar: homeProvider.isOpen==true?Container(
            height: kIsWeb?MediaQuery.of(context).size.width*0.2:MediaQuery.of(context).size.width*0.62,
            width: kIsWeb?MediaQuery.of(context).size.width*0.5:MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20)
                ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(2, 2),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, kIsWeb?90:10, kIsWeb?50:5),
                      child: InkWell(onTap: (){
                        homeProvider.changeButton();
                      }, child: SvgPicture.asset(assets.cancel)),
                    )
                  ],
                ),
                Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              PanelButton(image: assets.home,callback: (){
                                homeProvider.updateIndex(0);
                                utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
                                homeProvider.panelClose();
                              },
                                isColor: homeProvider.selectedIndex==0?true:false, text: 'Home',),
                              PanelButton(image: assets.report,callback: (){
                                homeProvider.updateIndex(10);
                                utils.navigatePage(context, ()=> DashBoard(child: ViewTask(date1: homeProvider.startDate, date2: homeProvider.endDate, type: homeProvider.type)));
                                homeProvider.panelClose();
                              },
                                isColor: homeProvider.selectedIndex==10?true:false, text: 'Task',),
                            ],
                          ),
                            Column(
                              children: [
                                localData.storage.read("role") =="1"?
                                PanelButton(image: assets.grpAtt,callback: (){
                                  homeProvider.updateIndex(14);
                                  utils.navigatePage(context, ()=>const DashBoard(child: ProjectAttendance()));
                                  homeProvider.panelClose();
                                },
                                  isColor: homeProvider.selectedIndex==14?true:false, text: "      Group Attendance",):
                                PanelButton(image: assets.expense,callback: (){
                                  homeProvider.updateIndex(9);
                                  utils.navigatePage(context, ()=>const DashBoard(child: ExpensePage()));
                                  homeProvider.panelClose();
                                },isColor: homeProvider.selectedIndex==9?true:false, text: 'Expense',),
                                PanelButton(image: assets.project,callback: (){
                                  homeProvider.updateIndex(13);
                                  utils.navigatePage(context, ()=>const DashBoard(child: ViewProject()));
                                  homeProvider.panelClose();
                                },
                                  isColor: homeProvider.selectedIndex==13?true:false, text: constValue.project,),
                              ],
                            ),
                          if(localData.storage.read("role") =="1")
                            Column(
                              children: [
                                PanelButton(image: assets.leave,callback: (){
                                  homeProvider.updateIndex(11);
                                  utils.navigatePage(context, ()=>const DashBoard(child: LeaveManagementDashboard()));
                                  homeProvider.panelClose();
                                },
                                  isColor: homeProvider.selectedIndex==11?true:false, text: 'Leave',),
                                PanelButton(image: assets.payroll,callback: (){
                                  homeProvider.updateIndex(12);
                                  utils.navigatePage(context, ()=>const DashBoard(child: PayrollDashboard()));
                                  homeProvider.panelClose();
                                },
                                  isColor: homeProvider.selectedIndex==12?true:false, text: 'Payroll',),
                              ],
                            ),

                          if(localData.storage.read("role") =="1")
                          Column(
                              children: [
                                  PanelButton(image: assets.employees,callback: (){
                                  homeProvider.updateIndex(1);
                                  utils.navigatePage(context, ()=>const DashBoard(child: ViewEmployees()));
                                  homeProvider.panelClose();
                                  },
                                  isColor: homeProvider.selectedIndex==1?true:false, text: 'Employee',),
                                PanelButton(image: assets.expense,callback: (){
                                  homeProvider.updateIndex(9);
                                  utils.navigatePage(context, ()=>const DashBoard(child: ExpensePage()));
                                  homeProvider.panelClose();
                                },isColor: homeProvider.selectedIndex==9?true:false, text: 'Expense',),
                              ],
                            ),
                          Column(
                            children: [
                              PanelButton(image: assets.customer,callback: (){
                                homeProvider.updateIndex(2);
                                utils.navigatePage(context, ()=>const DashBoard(child: ViewCustomer()));
                                homeProvider.panelClose();
                              },
                                isColor: homeProvider.selectedIndex==2?true:false, text: constValue.customer,),
                              PanelButton(image: assets.setting,callback: (){
                                homeProvider.updateIndex(7);
                                utils.navigatePage(context, ()=>const DashBoard(child: Setting()));
                                homeProvider.panelClose();
                              },
                                isColor: homeProvider.selectedIndex==7?true:false, text: 'Settings',),
                            ],
                          ),
                          if(localData.storage.read("role") !="1")
                            Column(
                              children: [
                                PanelButton(image: assets.leave,callback: (){
                                  homeProvider.updateIndex(11);
                                  utils.navigatePage(context, ()=> DashBoard(child: ViewMyLeaves(date1:homeProvider.startDate,date2:homeProvider.endDate,isDirect: true)));
                                  homeProvider.panelClose();
                                },
                                  isColor: homeProvider.selectedIndex==11?true:false, text: 'Apply\nLeave',),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 7, 0, 0),
                                  child: SizedBox(
                                    height: kIsWeb?MediaQuery.of(context).size.width*0.04:MediaQuery.of(context).size.width*0.15,
                                  ),
                                )
                              ],
                            ),
                          ///
                          // Column(
                          //     children: [
                          //
                          //       Padding(
                          //         padding: const EdgeInsets.fromLTRB(10, 7, 0, 0),
                          //         child: SizedBox(
                          //           height: kIsWeb?MediaQuery.of(context).size.width*0.04:MediaQuery.of(context).size.width*0.15,
                          //         ),
                          //       )
                          //     ],
                          //   ),
                        ],
                      ),
                    ),
                  ),
                ),
                5.height,
                SizedBox(
                  width:MediaQuery.of(context).size.width*0.85,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomText(text: "Version ${localData.versionNumber}",colors: Colors.grey.shade400,),
                      ],
                    ))
              ],
            ),
          ):
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton(
                  heroTag: null,
                  backgroundColor: colorsConst.primary,
                  onPressed: (){
                  homeProvider.changeButton();
                },child: const Icon(Icons.menu),),
                CustomText(text: "Version ${localData.versionNumber}",colors: Colors.grey,)
              ],
            ),
          ),
          body: widget.child,
          // body: homeProvider.mainContents[homeProvider.selectedIndex],
            ),
      );
    });
  }
}

