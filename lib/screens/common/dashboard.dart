import 'package:master_code/component/custom_loading_button.dart';
import 'package:master_code/component/custom_text.dart';
import 'package:master_code/screens/common/setting.dart';
import 'package:master_code/screens/common/view_notification.dart';
import 'package:master_code/screens/customer/visit_report/visits_report.dart';
import 'package:master_code/screens/track/live_location.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/constant/language_model.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../component/animated_drawer.dart';
import '../../component/panel_button.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/language_model.dart';
import '../../source/constant/local_data.dart';
import '../../view_model/employee_provider.dart';
import '../../view_model/home_provider.dart';
import '../attendance/attendance_report.dart';
import '../attendance/offline_attendance.dart';
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
import '../task/wages_employee_details.dart';
import 'home_page.dart';

// ✅ NEW: Offline attendance sync icon-ku thevai
import 'package:master_code/view_model/attendance_provider.dart';
// un path-ku match pannu

class DashBoard extends StatefulWidget {
  final Widget child;
  const DashBoard({super.key, required this.child});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final ScrollController scrollController = ScrollController();

  // ✅ Cache panel buttons so we don't rebuild + re-run roleAccess checks
  // multiple times per build.
  List<Widget>? _cachedPanelButtons;
  List<dynamic>? _cachedRoleAccess;
  String? _cachedRole;

  // ✅ language change aana cache-um refresh aaganum,
  // illana drawer labels pazhaya language-la irukkum.
  AppLang? _cachedLang;

  @override
  void initState() {
    super.initState();
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    if (homeProvider.appFeatures.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<HomeProvider>().activeFeatures();
        context.read<HomeProvider>().appComponents();
        context.read<HomeProvider>().getRoleAccess();
      });
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // ✅ LANGUAGE HELPERS
  // ---------------------------------------------------------------------
  String _langName(AppLang l) {
    switch (l) {
      case AppLang.tamil:
        return "தமிழ்";
      case AppLang.hindi:
        return "हिन्दी";
      case AppLang.english:
        return "English";
    }
  }

  /// Bottom sheet with 3 languages. Current one shows a tick.
  void _showLanguageSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetCtx) {
        final current = LanguageManager.instance.lang;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                child: Text(
                  constValue.selectLanguage,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: colorsConst.primary,
                  ),
                ),
              ),
              ...AppLang.values.map((l) {
                final selected = l == current;
                return ListTile(
                  leading: Icon(Icons.language, color: colorsConst.primary),
                  title: Text(
                    _langName(l),
                    style: TextStyle(
                      fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: selected
                      ? Icon(Icons.check_circle, color: colorsConst.primary)
                      : null,
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    Navigator.pop(sheetCtx); // sheet close

                    // Same language-a thirumba select panna edhuvum panna vendaam
                    if (l == current) return;

                    await LanguageManager.instance.setLanguage(l);

                    // ✅ Pazhaya pages ellam stack-la irundhu remove pannitu,
                    // fresh Home open pannum. Appo ella pages-um
                    // pudhu language-la thaan build aagum.
                    if (!ctx.mounted) return;
                    ctx.read<HomeProvider>().updateIndex(0);
                    Navigator.of(ctx).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const DashBoard(child: HomePage()),
                      ),
                          (route) => false,
                    );
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // 🔄 NEW: Offline attendance sync icon (pending irundha mattum kaattum)
  // ---------------------------------------------------------------------
  Widget _buildSyncIcon() {
    return ValueListenableBuilder<int>(
      valueListenable: OfflineAttendanceService.pendingNotifier,
      builder: (context, count, _) {
        // pending illana icon maraiyum
        if (count == 0) {
          return const SizedBox.shrink();
        }

        return Consumer<AttendanceProvider>(
          builder: (context, attPvr, _) {
            return Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      splashColor: Colors.orange.withOpacity(0.25),
                      highlightColor: Colors.orange.withOpacity(0.12),
                      onTap: attPvr.isSyncing
                          ? null
                          : () {
                        HapticFeedback.lightImpact();
                        attPvr.syncPending(context, manual: true);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: attPvr.isSyncing
                            ? const SizedBox(
                          width: 26,
                          height: 26,
                          child: Padding(
                            padding: EdgeInsets.all(4),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                            : Icon(
                          Icons.sync,
                          size: 26,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                    if (!attPvr.isSyncing)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: IgnorePointer(
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 17,
                              minHeight: 17,
                            ),
                            child: Center(
                              child: Text(
                                count.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                20.width,
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ListenableBuilder -> language maarina udane dashboard rebuild
    return ListenableBuilder(
      listenable: LanguageManager.instance,
      builder: (context, _) {
        return Consumer2<HomeProvider, EmployeeProvider>(
          builder: (context, homeProvider, empPvr, _) {
            return SafeArea(
              child: Scaffold(
                backgroundColor: ColorsConst.background2,

                /// ✅ Drawer Menu
                drawer: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.60,
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
                                  borderRadius: BorderRadius.circular(20),
                                  splashColor:
                                  colorsConst.primary.withOpacity(0.2),
                                  highlightColor:
                                  colorsConst.primary.withOpacity(0.1),
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.pop(context); // ✅ Drawer close
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Icon(
                                      Icons.close,
                                      color: colorsConst.primary,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// 🔥 Menu List
                          // ✅ Expanded: small screens-la overflow aagaama,
                          // Select Language + Logout + Version keezha fix-ah irukkum
                          Expanded(
                            child: Scrollbar(
                              controller: scrollController,
                              thumbVisibility: true,
                              trackVisibility: true,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: _getPanelButtons(
                                        context, homeProvider, empPvr),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          /// 🌐 Select Language
                          InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.pop(context); // drawer close
                              _showLanguageSheet(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(Icons.language,
                                      color: colorsConst.primary, size: 24),
                                  10.width,
                                  Expanded(
                                    child: CustomText(
                                      text: constValue.selectLanguage,
                                      colors: colorsConst.primary,
                                      isBold: true,
                                      shrink: true,
                                    ),
                                  ),
                                  CustomText(
                                    text: _langName(
                                        LanguageManager.instance.lang),
                                    colors: Colors.grey,
                                    size: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                utils.customDialog(
                                  context: context,
                                  title: constValue.sureWantTo,
                                  title2: constValue.endSessionQ,
                                  callback: () {
                                    homeProvider.loginOuts(context);
                                  },
                                  isLoading: true,
                                  roundedLoadingButtonController:
                                  homeProvider.loginCtr,
                                );
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.logout_outlined,
                                      color: Colors.white),
                                  CustomText(
                                    text: '${constValue.logOut}',
                                    isBold: true,
                                    shrink: true,
                                    colors: Colors.white,
                                  ),
                                ],
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
                appBar: widget.child is HomePage
                    ? AppBar(
                  backgroundColor: ColorsConst.background2,
                  iconTheme: IconThemeData(color: colorsConst.primary),
                  automaticallyImplyLeading: true,
                  toolbarHeight: 60,
                  titleSpacing: 0,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Image.asset(
                              assets.logo,
                              height: 40,
                              width: 100,
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
                          /// 🔄 Offline Attendance Sync icon (NEW)
                          _buildSyncIcon(),
                          if (localData.storage.read("role") == "1")
                          /// Tracking icon
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            splashColor: Colors.green.withOpacity(0.25),
                            highlightColor:
                            Colors.green.withOpacity(0.12),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              homeProvider.updateIndex(3);
                              utils.navigatePage(
                                context,
                                    () => const DashBoard(
                                    child: TrackingLive()),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.location_on_outlined,
                                size: 26,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ),

                          20.width,

                          /// Notification with Badge
                          Consumer<HomeProvider>(
                            builder: (context, homeProvider, _) {
                              final totalUsers = int.tryParse(
                                homeProvider
                                    .mainReportList.isNotEmpty
                                    ? homeProvider.mainReportList[0]
                                ["unread_notification_count"]
                                    .toString()
                                    : "0",
                              ) ??
                                  0;

                              return Stack(
                                children: [
                                  InkWell(
                                    borderRadius:
                                    BorderRadius.circular(20),
                                    splashColor: Colors.blue.shade900
                                        .withOpacity(0.25),
                                    highlightColor: Colors.blue.shade900
                                        .withOpacity(0.12),
                                    onTap: () async {
                                      HapticFeedback.lightImpact();

                                      // ✅ Badge instant-a 0 aagum
                                      if (homeProvider
                                          .mainReportList.isNotEmpty) {
                                        homeProvider.mainReportList[0][
                                        "unread_notification_count"] = "0";
                                        homeProvider.notifyListeners();
                                      }

                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const DashBoard(
                                              child: ViewNotification()),
                                        ),
                                      );

                                      // ✅ Back vandha count refresh
                                      if (context.mounted) {
                                        await homeProvider
                                            .loadFullDashboard(context);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.notifications_none_outlined,
                                        size: 26,
                                        color: Colors.blue.shade900,
                                      ),
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
                                        constraints:
                                        const BoxConstraints(
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

                          /// ✅ Reports Button
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
                                  HapticFeedback.lightImpact();

                                  homeProvider.updateIndex(4);

                                  utils.navigatePage(
                                    context,
                                        () => DashBoard(
                                      child: AttendanceReport(
                                        type: homeProvider.type,
                                        showType: "0",
                                        date1: homeProvider.startDate,
                                        date2: homeProvider.endDate,
                                        empList: empPvr.userData,
                                      ),
                                    ),
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

                body: widget.child,
              ),
            );
          },
        );
      },
    );
  }

  /// ✅ Cached panel buttons. Rebuilds only when roleAccess, role
  /// or LANGUAGE changes.
  List<Widget> _getPanelButtons(BuildContext context,
      HomeProvider homeProvider, EmployeeProvider empPvr) {
    final role = localData.storage.read("role");
    final lang = LanguageManager.instance.lang;

    final bool roleAccessChanged =
    !identical(_cachedRoleAccess, homeProvider.roleAccess);
    final bool roleChanged = _cachedRole != role;
    final bool langChanged = _cachedLang != lang;

    if (_cachedPanelButtons == null ||
        roleAccessChanged ||
        roleChanged ||
        langChanged) {
      _cachedPanelButtons = _buildPanelButtons(context, homeProvider, empPvr);
      _cachedRoleAccess = homeProvider.roleAccess;
      _cachedRole = role;
      _cachedLang = lang;
    }

    return _cachedPanelButtons!;
  }

  List<Widget> _buildPanelButtons(BuildContext context,
      HomeProvider homeProvider, EmployeeProvider empPvr) {
    String role = localData.storage.read("role");

    final List<_PanelItem> allItems = [
      _PanelItem("${constValue.home}", assets.home, 0,
          const DashBoard(child: HomePage())),
      // if (homeProvider.roleAccess.any((f) =>
      // f['feature'] == 'Employee Management' && f['name'] == 'View'))
      if (localData.storage.read("role") == "1")
      _PanelItem("${constValue.employee}", assets.employees, 1,
          const DashBoard(child: ViewEmployees())),
      _PanelItem(constValue.wages, assets.employees, 16,
          const DashBoard(child: WagesWorkerDetailsPage())),
      // if (homeProvider.roleAccess.any(
      //         (f) => f['feature'] == 'Customer Management' && f['name'] == 'View'))
      _PanelItem(constValue.customer, assets.customer, 2,
          const DashBoard(child: ViewCustomer())),
      // if (homeProvider.roleAccess
      //     .any((f) => f['feature'] == 'Expense' && f['name'] == 'View'))
      //   _PanelItem(
      //       "Expense", assets.expense, 9, const DashBoard(child: ExpensePage())),
      // if (homeProvider.roleAccess
      //     .any((f) => f['feature'] == 'Office Expense' && f['name'] == 'View'))
      //   _PanelItem("${constValue.office}", assets.expense, 15,
      //       const DashBoard(child: ExpasyScreen())),
      // if (homeProvider.roleAccess
      //     .any((f) => f['feature'] == 'Task Management' && f['name'] == 'View'))
      _PanelItem(
          "${constValue.task}",
          assets.report,
          10,
          DashBoard(
              child: ViewTask(
                  date1: homeProvider.startDate,
                  date2: homeProvider.endDate,
                  type: homeProvider.type))),
      // if (homeProvider.roleAccess
      //     .any((f) => f['feature'] == 'Tracking' && f['name'] == 'View'))
      //   _PanelItem(
      //       "Tracking", assets.track, 3, const DashBoard(child: TrackingLive())),
      // if (homeProvider.roleAccess.any((f) =>
      // f['feature'] == 'Leave Management' && f['name'] == 'View') ||
      //     homeProvider.roleAccess.any((f) =>
      //     f['feature'] == 'Leave Management' &&
      //         f['name'] == 'Apply Leave'))
      _PanelItem(
          "${constValue.leave}",
          assets.leave,
          11,
          DashBoard(
              child: role == "1"
                  ? LeaveManagementDashboard()
                  : ViewMyLeaves(
                date1: homeProvider.startDate,
                date2: homeProvider.endDate,
                isDirect: true,
              ))),
      // if (homeProvider.roleAccess
      //     .any((f) => f['feature'] == 'Payroll Management' && f['name'] == 'View'))
      //   _PanelItem("Payroll", assets.payroll, 12,
      //       const DashBoard(child: PayrollDashboard())),
      // if (homeProvider.roleAccess
      //     .any((f) => f['feature'] == 'Project Management' && f['name'] == 'View'))
      //   _PanelItem(constValue.project, assets.project, 13,
      //       const DashBoard(child: ViewProject())),
      // if (homeProvider.roleAccess.any((f) =>
      // f['feature'] == 'Project Management' &&
      //     f['name'] == 'Group Attendance'))
      //   _PanelItem("GrpAtt", assets.grpAtt, 14,
      //       const DashBoard(child: ProjectAttendance())),
      _PanelItem("${constValue.setting}", assets.setting, 7,
          const DashBoard(child: Setting())),
      if (role != "1")
        _PanelItem("", "", 999, const DashBoard(child: Setting()),
            isShow: false),
    ];

    return allItems.map((item) {
      return PanelButton(
        image: item.image,
        text: item.title,
        isShow: item.isShow,
        isColor: homeProvider.selectedIndex == item.index,
        callback: () {
          HapticFeedback.selectionClick();
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