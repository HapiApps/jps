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
import '../../component/panel_button.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/dashboard_assets.dart';
import '../../source/constant/local_data.dart';
import '../../view_model/employee_provider.dart';
import '../../view_model/home_provider.dart';
import '../attendance/attendance_report.dart';
import '../customer/view_all_customer.dart';
import '../employee/view_all_employees.dart';
import '../leave_management/leave_dashboard.dart';
import '../leave_management/leave_report.dart';
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
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, _) {
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
                              text: "JPS",
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
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                /// Home
                                PanelButton(
                                  image: assets.home,
                                  callback: () {
                                    Navigator.pop(context);
                                    homeProvider.updateIndex(0);
                                    utils.navigatePage(
                                      context,
                                          () => const DashBoard(child: HomePage()),
                                    );
                                  },
                                  isColor: homeProvider.selectedIndex == 0,
                                  text: ' Home',
                                ),

                                /// Task
                                PanelButton(
                                  image: assets.report,
                                  callback: () {
                                    Navigator.pop(context);
                                    homeProvider.updateIndex(10);
                                    utils.navigatePage(
                                      context,
                                          () => DashBoard(
                                        child: ViewTask(
                                          date1: homeProvider.startDate,
                                          date2: homeProvider.endDate,
                                          type: homeProvider.type,
                                        ),
                                      ),
                                    );
                                  },
                                  isColor: homeProvider.selectedIndex == 10,
                                  text: ' Task',
                                ),

                                /// Admin Only
                                if (localData.storage.read("role") == "1") ...[
                                  PanelButton(
                                    image: assets.leave,
                                    callback: () {
                                      Navigator.pop(context);
                                      homeProvider.updateIndex(11);
                                      utils.navigatePage(
                                        context,
                                            () => const DashBoard(
                                          child: LeaveManagementDashboard(),
                                        ),
                                      );
                                    },
                                    isColor: homeProvider.selectedIndex == 11,
                                    text: '  Leave',
                                  ),

                                  PanelButton(
                                    image: assets.employees,
                                    callback: () {
                                      Navigator.pop(context);
                                      homeProvider.updateIndex(1);
                                      utils.navigatePage(
                                        context,
                                            () => const DashBoard(
                                          child: ViewEmployees(),
                                        ),
                                      );
                                    },
                                    isColor: homeProvider.selectedIndex == 1,
                                    text: '   Employee',
                                  ),
                                ],

                                /// Customer
                                PanelButton(
                                  image: assets.customer,
                                  callback: () {
                                    Navigator.pop(context);
                                    homeProvider.updateIndex(2);
                                    utils.navigatePage(
                                      context,
                                          () => const DashBoard(
                                        child: ViewCustomer(),
                                      ),
                                    );
                                  },
                                  isColor: homeProvider.selectedIndex == 2,
                                  text: constValue.customer1,
                                ),

                                /// Settings
                                PanelButton(
                                  image: assets.setting,
                                  callback: () {
                                    Navigator.pop(context);
                                    homeProvider.updateIndex(7);
                                    utils.navigatePage(
                                      context,
                                          () => const DashBoard(
                                        child: Setting(),
                                      ),
                                    );
                                  },
                                  isColor: homeProvider.selectedIndex == 7,
                                  text: '  Settings',
                                ),

                                /// Employee Only
                                if (localData.storage.read("role") != "1")
                                  PanelButton(
                                    image: assets.leave,
                                    callback: () {
                                      Navigator.pop(context);
                                      homeProvider.updateIndex(11);
                                      utils.navigatePage(
                                        context,
                                            () => DashBoard(
                                          child: ViewMyLeaves(
                                            date1: homeProvider.startDate,
                                            date2: homeProvider.endDate,
                                            isDirect: true,
                                          ),
                                        ),
                                      );
                                    },
                                    isColor: homeProvider.selectedIndex == 11,
                                    text: 'Apply\nLeave',
                                  ),
                              ],
                            ),
                          ),
                        ),
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
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Image.asset(
                    assets.logo,
                    height: 40,
                  ),
                ),

                /// Right Side Icons
                Row(
                  children: [
                    /// Tracking icon (Admin only)
                    if (localData.storage.read("role") == "1")
                      InkWell(
                        onTap: () {
                          homeProvider.updateIndex(3);
                          utils.navigatePage(
                            context,
                                () => const DashBoard(child: TrackingLive()),
                          );
                        },
                        child: Image.asset(
                          assets.tracks,
                          height: 35,
                          width: 35,
                          color: colorsConst.primary,
                        ),
                      ),

                    20.width,

                    /// Notification with Badge
                    Consumer<EmployeeProvider>(
                      builder: (context, emp, _) {
                        return Stack(
                          children: [
                            InkWell(
                              onTap: () {
                                utils.navigatePage(
                                  context,
                                      () => const DashBoard(child: ViewNotification()),
                                );
                              },
                              child: Image.asset(
                                DashboardAssets.reminder,
                                width: 40,
                                height: 50,
                                color: colorsConst.primary,
                              ),
                            ),

                            if (emp.unreadCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    emp.unreadCount.toString(),
                                    style:  TextStyle(
                                      color: colorsConst.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
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
                          icon:  Icon(
                            Icons.description_sharp,
                            color: colorsConst.primary,
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
                                                  icon: SvgPicture.asset(
                                                    assets.cancel,
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            ),

                                            Center(
                                              child: CustomText(
                                                text: "Choose a report",
                                                isBold: true,
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
                                                      Image.asset(
                                                        assets.aTt,
                                                        width: 50,
                                                        height: 50,
                                                      ),
                                                      5.height,
                                                      CustomText(
                                                        text: "Attendance",
                                                        isBold: true,
                                                        size: 12,
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                /// Daily Work Plan
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.pop(context);

                                                    utils.navigatePage(
                                                      context,
                                                          () => DashBoard(
                                                        child: VisitReport(
                                                          date1: homeProvider.startDate,
                                                          date2: homeProvider.endDate,
                                                          month: homeProvider.month,
                                                          type: homeProvider.type,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Image.asset(
                                                        assets.aLoc,
                                                        width: 50,
                                                        height: 50,
                                                      ),
                                                      5.height,
                                                      CustomText(
                                                        text: "Daily Plan",
                                                        isBold: true,
                                                        size: 12,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            20.height,

                                            Center(
                                              child: TextButton(
                                                child: CustomText(
                                                  text: "Cancel",
                                                  colors: colorsConst.appRed,
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
                        CustomText(
                          text: "Reports",
                          colors: colorsConst.primary,
                          isBold: true,
                          size: 10,
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

            body: widget.child,
          ),
        );
      },
    );
  }
}