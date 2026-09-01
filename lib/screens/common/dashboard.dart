import 'package:master_code/component/custom_loading_button.dart';
import 'package:master_code/component/custom_text.dart';
import 'package:master_code/screens/common/setting.dart';
import 'package:master_code/screens/common/view_notification.dart';
import 'package:master_code/screens/customer/visit_report/visits_report.dart';
import 'package:master_code/screens/track/live_location.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/constant/default_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../component/animated_drawer.dart';
import '../../component/panel_button.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/local_data.dart';
import '../../view_model/employee_provider.dart';
import '../../view_model/home_provider.dart';
import '../attendance/attendance_report.dart';
import '../customer/view_all_customer.dart';
import '../employee/view_all_employees.dart';
import '../expasy/expasy_screen.dart';
import '../expense/expense_page.dart';
import '../group_attendance/project_attendance.dart';
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

class _DashBoardState extends State<DashBoard> {
  final ScrollController scrollController = ScrollController();
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    if(homeProvider.appFeatures.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<HomeProvider>().activeFeatures();
        context.read<HomeProvider>().appComponents();
        context.read<HomeProvider>().getRoleAccess();
      });
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    scrollController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider,EmployeeProvider>(builder: (context, homeProvider,empPvr, _) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: ColorsConst.background2,

            /// ✅ Drawer Menu
            drawer: SizedBox(
              width: MediaQuery.of(context).size.width * 0.60, // ✅ 75% width
              child: Drawer(
                child: SafeArea(
                  child: Column(
                    children: [
                      /// 🔥 Drawer Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        color: ColorsConst.background2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: constValue.appName,
                              colors: colorsConst.primary,
                              size: 18,
                              isBold: true,
                            ),

                        InkWell(
                          onTap: () {
                            Navigator.pop(context); // ✅ Drawer close
                          },
                          child:  Icon(
                            Icons.close,
                            color: colorsConst.primary,
                            size: 22,
                          ),
                            // 5.height,
                            // CustomText(
                            //   text: "Version ${localData.versionNumber}",
                            //   colors: Colors.white70,
                            // ),
                        ),
                          ],
                        ),
                      ),

                      /// 🔥 Menu List
                      // Expanded(
                      //   child: SingleChildScrollView(
                      //     child: Padding(
                      //       padding: const EdgeInsets.all(12),
                      //       child: Column(
                      //         children: [
                      //           /// Home
                      //           PanelButton(
                      //             image: assets.home,
                      //             callback: () {
                      //               Navigator.pop(context);
                      //               homeProvider.updateIndex(0);
                      //               utils.navigatePage(
                      //                 context,
                      //                     () => const DashBoard(child: HomePage()),
                      //               );
                      //             },
                      //             isColor: homeProvider.selectedIndex == 0,
                      //             text: ' Home',
                      //           ),
                      //
                      //           /// Task
                      //           PanelButton(
                      //             image: assets.report,
                      //             callback: () {
                      //               Navigator.pop(context);
                      //               homeProvider.updateIndex(10);
                      //               utils.navigatePage(
                      //                 context,
                      //                     () => DashBoard(
                      //                   child: ViewTask(
                      //                     date1: homeProvider.startDate,
                      //                     date2: homeProvider.endDate,
                      //                     type: homeProvider.type,
                      //                   ),
                      //                 ),
                      //               );
                      //             },
                      //             isColor: homeProvider.selectedIndex == 10,
                      //             text: ' Task',
                      //           ),
                      //
                      //           /// Admin Only
                      //           if (localData.storage.read("role") == "1") ...[
                      //             PanelButton(
                      //               image: assets.leave,
                      //               callback: () {
                      //                 Navigator.pop(context);
                      //                 homeProvider.updateIndex(11);
                      //                 utils.navigatePage(
                      //                   context,
                      //                       () => const DashBoard(
                      //                     child: LeaveManagementDashboard(),
                      //                   ),
                      //                 );
                      //               },
                      //               isColor: homeProvider.selectedIndex == 11,
                      //               text: '  Leave',
                      //             ),
                      //
                      //             PanelButton(
                      //               image: assets.employees,
                      //               callback: () {
                      //                 Navigator.pop(context);
                      //                 homeProvider.updateIndex(1);
                      //                 utils.navigatePage(
                      //                   context,
                      //                       () => const DashBoard(
                      //                     child: ViewEmployees(),
                      //                   ),
                      //                 );
                      //               },
                      //               isColor: homeProvider.selectedIndex == 1,
                      //               text: '   Employee',
                      //             ),
                      //           ],
                      //
                      //           /// Customer
                      //           PanelButton(
                      //             image: assets.customer,
                      //             callback: () {
                      //               Navigator.pop(context);
                      //               homeProvider.updateIndex(2);
                      //               utils.navigatePage(
                      //                 context,
                      //                     () => const DashBoard(
                      //                   child: ViewCustomer(),
                      //                 ),
                      //               );
                      //             },
                      //             isColor: homeProvider.selectedIndex == 2,
                      //             text: constValue.customer1,
                      //           ),
                      //           /// Employee Only
                      //           if (localData.storage.read("role") != "1")
                      //             PanelButton(
                      //               image: assets.leave,
                      //               callback: () {
                      //                 Navigator.pop(context);
                      //                 homeProvider.updateIndex(11);
                      //                 utils.navigatePage(
                      //                   context,
                      //                       () => DashBoard(
                      //                     child: ViewMyLeaves(
                      //                       date1: homeProvider.startDate,
                      //                       date2: homeProvider.endDate,
                      //                       isDirect: true,
                      //                     ),
                      //                   ),
                      //                 );
                      //               },
                      //               isColor: homeProvider.selectedIndex == 11,
                      //               text: 'Apply Leave',
                      //             ),
                      //           if (localData.storage.read("role") == "1")
                      //             PanelButton(
                      //             image: assets.expense,
                      //             callback: () {
                      //               Navigator.pop(context);
                      //               homeProvider.updateIndex(8);
                      //               utils.navigatePage(
                      //                 context,
                      //                     () => const DashBoard(
                      //                   child: ExpasyScreen(),
                      //                 ),
                      //               );
                      //             },
                      //             isColor: homeProvider.selectedIndex == 8,
                      //             text: '  Office Expense',
                      //           ),
                      //           /// Settings
                      //           PanelButton(
                      //             image: assets.setting,
                      //             callback: () {
                      //               Navigator.pop(context);
                      //               homeProvider.updateIndex(7);
                      //               utils.navigatePage(
                      //                 context,
                      //                     () => const DashBoard(
                      //                   child: Setting(),
                      //                 ),
                      //               );
                      //             },
                      //             isColor: homeProvider.selectedIndex == 7,
                      //             text: '  Settings',
                      //           ),
                      //           20.height,
                      //           ElevatedButton.icon(
                      //             onPressed: () {
                      //               utils.customDialog(
                      //                 context: context,
                      //                 title: "Are you sure you want",
                      //                 title2: "to end the session?",
                      //                 callback: () {
                      //                   homeProvider.loginOuts(context);
                      //                 },
                      //                 isLoading: true,
                      //                 roundedLoadingButtonController: homeProvider.loginCtr,
                      //               );
                      //             },
                      //             icon: const Icon(Icons.logout, color: Colors.white),
                      //             label: const Text(
                      //               "Logout",
                      //               style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      //             ),
                      //             style: ElevatedButton.styleFrom(
                      //               backgroundColor: Colors.red,
                      //               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      //               shape: RoundedRectangleBorder(
                      //                 borderRadius: BorderRadius.circular(12),
                      //               ),
                      //             ),
                      //           )
                      //
                      //
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Scrollbar(
                        controller: scrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              // children: _buildPanelButtons(context, homeProvider),
                              children: [
                                for (int i = 0; i < _buildPanelButtons(context, homeProvider,empPvr).length; i ++)
                                  _buildPanelButtons(context, homeProvider,empPvr)[i]
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red
                          ),
                            onPressed: (){
                              utils.customDialog(
                                  context: context,
                                  title: "Are you sure you want",
                                  title2: "to end the session?",
                                  callback: () {
                                    homeProvider.loginOuts(context);
                                  },
                                  isLoading: true,roundedLoadingButtonController: homeProvider.loginCtr);
                            }, child: Row(
                          children: [
                            Icon(Icons.logout_outlined,color: Colors.white,),
                            CustomText(text: 'Logout',isBold: true,colors: Colors.white)
                          ],
                        )),
                      ),
                      /// 🔥 Footer Version
                      Padding(
                        padding: const EdgeInsets.only(left: 110),
                        child: CustomText(
                          text: "Version ${localData.versionNumber}",
                          colors: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// ✅ AppBar with Drawer Button
            appBar:widget.child is HomePage
          ? AppBar(
          backgroundColor: ColorsConst.background2,
            iconTheme:  IconThemeData(color: colorsConst.primary,),
            automaticallyImplyLeading: true,
            toolbarHeight: 60,
            titleSpacing: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// ARUU Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Image.asset(
                        assets.logo,
                        height: 40,width: 100,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: CustomText(
                        text: "V ${localData.versionNumber}",
                        colors: Colors.grey,
                        size: 10,
                      ),
                    ),
                  ],
                ),
                /// Right Side Icons
                Row(
                  children: [
                    /// Tracking icon (Admin only)
                    if (homeProvider.roleAccess.any((f) => f['feature'] == 'Tracking'&&f['name'] == 'Live Tracking'))
                      InkWell(
                        onTap: () {
                          homeProvider.updateIndex(3);
                          utils.navigatePage(
                            context,
                                () => const DashBoard(child: TrackingLive()),
                          );
                        },
                        child: SvgPicture.asset(
                          assets.loc,
                          height: 24,
                          width: 24,
                          color: Colors.green.shade800,
                        ),
                      ),

                    20.width,

                    /// Notification with Badge
                    Consumer<HomeProvider>(
                      builder: (context, homeProvider, _) {

                        final totalUsers = int.tryParse(
                          homeProvider.mainReportList.isNotEmpty
                              ? homeProvider.mainReportList[0]["unread_notification_count"]
                              .toString()
                              : "0",
                        ) ??
                            0;

                        return Stack(
                          children: [
                            InkWell(
                              onTap: () async {

                                // ✅ Badge instant-a 0 aagum
                                if (homeProvider.mainReportList.isNotEmpty) {
                                  homeProvider.mainReportList[0]["unread_notification_count"] = "0";
                                  homeProvider.notifyListeners();
                                }

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const DashBoard(child: ViewNotification()),
                                  ),
                                );

                                // ✅ Notification page lendhu back vandha
                                // dashboard count refresh
                                await homeProvider.loadFullDashboard(context);
                              },
                              child: SvgPicture.asset(
                                assets.not,
                                height: 28,
                                width: 20,
                                color: Colors.blue.shade900,
                              ),
                            ),

                            if (totalUsers > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Center(
                                    child: Text(
                                      totalUsers.toString(),
                                      style: TextStyle(
                                        color: Colors.blue.shade900,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),

                    10.width,

                    /// Reports Button
                    Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        IconButton(
        icon: Icon(
        Icons.description_sharp,
        color: Colors.pink.shade800,
        size: 26,
        ),
        onPressed: () {
        showDialog(
        context: context,
        builder: (context) {
        return Consumer2<HomeProvider, EmployeeProvider>(
        builder: (context, homeProvider, empro, _) {
        return AlertDialog(
        content: SizedBox(
        width: kIsWeb
        ? MediaQuery.of(context).size.width * 0.3
            : MediaQuery.of(context).size.width * 0.9,
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
        IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
        Navigator.pop(context);
        },
        ),
        ],
        ),

        const Center(
        child: Text(
        "Choose a report",
        style: TextStyle(
        fontWeight: FontWeight.bold,
        ),
        ),
        ),

        20.height,

        Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
        /// Attendance Report
        InkWell(
        onTap: () {
        homeProvider.updateIndex(4);
        Navigator.pop(context);

        utils.navigatePage(
        context,
        () => DashBoard(
        child: AttendanceReport(
        type: homeProvider.type,
        showType: "0",
        date1: homeProvider.startDate,
        date2: homeProvider.endDate,
        empList: empro.userData,
        ),
        ),
        );
        },
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        const Icon(Icons.assignment_turned_in,
        size: 35, color: Colors.blue),
        5.height,
        const Text(
        "Attendance",
        style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        ),
        ),
        ],
        ),
        ),

        /// Daily Work Plan
        // InkWell(
        // onTap: () {
        // Navigator.pop(context);
        //
        // utils.navigatePage(
        // context,
        // () => DashBoard(
        // child: VisitReport(
        // date1: homeProvider.startDate,
        // date2: homeProvider.endDate,
        // month: homeProvider.month,
        // type: homeProvider.type,
        // ),
        // ),
        // );
        // },
        // child: Column(
        // mainAxisSize: MainAxisSize.min,
        // children: [
        // const Icon(Icons.rate_review,
        // size: 35, color: Colors.green),
        // 5.height,
        // const Text(
        // "Daily Work Activity Report",
        // style: TextStyle(
        // fontWeight: FontWeight.bold,
        // fontSize: 12,
        // ),
        // ),
        // ],
        // ),
        // ),
        ],
        ),

        20.height,

        Center(
        child: TextButton(
        child: Text(
        "Cancel",
        style: TextStyle(
        color: colorsConst.appRed,
        fontWeight: FontWeight.bold,
        ),
        ),
        onPressed: () {
        Navigator.pop(context);
        },
        ),
        ),
        ],
        ),
        ),
        );
        },
        );
        },
        );
        },
        ),
        ],
        ),

                    5.width,
                  ],
                ),
              ],
            ),
          )
              : null,

            // body: widget.child,
            body: widget.child,
          ),
        );
      },
    );
  }
  List<Widget> _buildPanelButtons(BuildContext context, HomeProvider homeProvider, EmployeeProvider empPvr) {
    String role = localData.storage.read("role");

    final List<_PanelItem> allItems = [
      _PanelItem("Home", assets.home, 0, const DashBoard(child: HomePage())),
      if (homeProvider.roleAccess.any((f) => f['feature'] == 'Employee Management'&&f['name'] == 'View'))
        _PanelItem("Employee", assets.employees, 1, const DashBoard(child: ViewEmployees())),
      if (homeProvider.roleAccess.any((f) => f['feature'] == 'Customer Management'&&f['name'] == 'View'))
        _PanelItem(constValue.customer, assets.customer, 2, const DashBoard(child: ViewCustomer())),
      if (homeProvider.roleAccess.any((f) => f['feature'] == 'Expense'&&f['name'] == 'View'))
        _PanelItem("Expense", assets.expense, 9, const DashBoard(child: ExpensePage())),
      if (homeProvider.roleAccess.any((f) => f['feature'] == 'Office Expense'&&f['name'] == 'View'))
        _PanelItem("Office Expense", assets.expense, 15, const DashBoard(child: ExpasyScreen())),
      if (homeProvider.roleAccess.any((f) => f['feature'] == 'Task Management'&&f['name'] == 'View'))
        _PanelItem("Task", assets.report, 10, DashBoard(child: ViewTask(date1: homeProvider.startDate, date2: homeProvider.endDate, type: homeProvider.type))),
      if (homeProvider.roleAccess.any((f) => f['feature'] == 'Tracking'&&f['name'] == 'View'))
        _PanelItem("Tracking", assets.track, 3, const DashBoard(child: TrackingLive())),
      if (homeProvider.roleAccess.any((f) => f['feature'] == 'Leave Management'&&f['name'] == 'View'||homeProvider.roleAccess.any((f) => f['feature'] == 'Leave Management'&&f['name'] == 'Apply Leave')))
        _PanelItem("Leave", assets.leave, 11, DashBoard(child: role=="1"?LeaveManagementDashboard():ViewMyLeaves(date1:homeProvider.startDate,date2:homeProvider.endDate, isDirect: true,))),
      if (homeProvider.roleAccess.any((f) => f['feature'] == 'Payroll Management'&&f['name'] == 'View'))
        _PanelItem("Payroll", assets.payroll, 12, const DashBoard(child: PayrollDashboard())),
      if (homeProvider.roleAccess.any((f) => f['feature'] == 'Project Management'&&f['name'] == 'View'))
        _PanelItem(constValue.project, assets.project, 13, const DashBoard(child: ViewProject())),
      if (homeProvider.roleAccess.any((f) => f['feature'] == 'Project Management'&&f['name'] == 'Group Attendance'))
        _PanelItem("GrpAtt", assets.grpAtt, 14, const DashBoard(child: ProjectAttendance())),
      _PanelItem("Settings", assets.setting, 7, const DashBoard(child: Setting())),
      if(role!="1")
        _PanelItem("", "", 999,  const DashBoard(child: Setting()), isShow: false),
    ];

    return allItems.map((item) {
      return PanelButton(
        image: item.image,
        text: item.title,
        isShow: item.isShow,
        isColor: homeProvider.selectedIndex == item.index,
        callback: () {
          homeProvider.updateIndex(item.index);
          utils.navigatePage(context, () => item.page);
          homeProvider.panelClose();
        },
      );
    }).toList();
  }
}
class _PanelItem {
  final String title;
  final String image;
  final int index;
  final Widget page;
  final bool isShow;

  _PanelItem(
      this.title,
      this.image,
      this.index,
      this.page, {
        this.isShow = true, // <-- DEFAULT TRUE
      });
}
