import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:master_code/source/constant/language_model.dart';
import 'package:master_code/view_model/leave_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../component/custom_loading.dart';
import '../../component/new_co.dart';
import '../../component/update_app.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/dashboard_assets.dart';
import '../../source/constant/local_data.dart';
import '../../source/extentions/int_extensions.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/attendance_provider.dart';
import '../../view_model/customer_provider.dart';
import '../../view_model/employee_provider.dart';
import '../../view_model/home_provider.dart';
import '../../view_model/location_provider.dart';
import '../../view_model/task_provider.dart';
import '../attendance/attendance_report.dart';
import '../attendance/custom_attendance.dart';
import '../task/add_task.dart';
import 'add_day_work_plan.dart';
import 'detail_work_plan.dart';
import '../task/view_task.dart';
import '../track/background_task.dart';
import 'dashboard.dart';

@pragma('vm:entry-point')
void startCallbackDispatcher() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static int _initStateCallCount = 0;

  /// users / customers already load aagirundha (same user, 3 nimisham kulla)
  /// thirumba fetch pannaama irukka
  static String? _lastSecondaryUserId;
  static DateTime? _lastSecondaryLoad;

  // ignore: unused_field
  HomeProvider? _homeProvider;

  bool _isHomePageActive = false;
  bool _isInitialLoading = false;

  /// Home mela vera page (Tasks, Employees...) irundha, Home thirumba
  /// theriyura varaikkum kaathirukkum. Appo vera page open aagum bodhu
  /// Home oda background API calls competition panna maatanga.
  Future<void> _waitUntilVisible() async {
    while (mounted && _isHomePageActive) {
      final route = ModalRoute.of(context);
      if (route == null || route.isCurrent) return;
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  @override
  void initState() {
    super.initState();

    _initStateCallCount++;
    debugPrint("🟢 HomePage initState() — Call #$_initStateCallCount");

    _isHomePageActive = true;

    Future.delayed(Duration.zero, () async {
      if (!mounted || !_isHomePageActive) return;

      final id = localData.storage.read("id");
      final role = localData.storage.read("role");

      final now = DateTime.now();
      final today = "${now.day.toString().padLeft(2, "0")}-"
          "${now.month.toString().padLeft(2, "0")}-"
          "${now.year}";

      // ---------------- ATTENDANCE ----------------
      final attendanceProvider =
      Provider.of<AttendanceProvider>(context, listen: false);

      attendanceProvider.initDate(
        id: id,
        role: role,
        isRefresh: false,
        date1: today,
        date2: today,
      );

      // ---------------- HOME PROVIDER ----------------
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      _homeProvider = homeProvider;

      // VERY IMPORTANT: loadFullDashboard() has HomePage active check
      homeProvider.setHomePageActive(true, context);

      if (!mounted || !_isHomePageActive) return;

      // ---------------- 1) DASHBOARD (ONE call) ----------------
      if (!_isInitialLoading) {
        _isInitialLoading = true;
        await homeProvider.loadFullDashboard(context);
        _isInitialLoading = false;
      }

      if (!mounted || !_isHomePageActive) return;

      // ---------------- 2) Reports (dashboard dup reload ILLA) ----------------
      await _waitUntilVisible();
      if (!mounted || !_isHomePageActive) return;

      homeProvider.changeType(
        context,
        homeProvider.type,
        reloadDashboard: false, // munnadi idhu dashboard ah 2nd time load pannichu
      );

      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      if (taskProvider.statusList.isNotEmpty) {
        taskProvider.setStatusByName(taskProvider.statusList.first["value"]);
      }

      // ---------------- 3) Users / Customers / Notifications ----------------
      final employeeProvider =
      Provider.of<EmployeeProvider>(context, listen: false);
      final customerProvider =
      Provider.of<CustomerProvider>(context, listen: false);

      final bool fresh = _lastSecondaryUserId == id.toString() &&
          _lastSecondaryLoad != null &&
          DateTime.now().difference(_lastSecondaryLoad!) <
              const Duration(minutes: 3) &&
          employeeProvider.userData.isNotEmpty &&
          customerProvider.customer.isNotEmpty;

      if (!fresh) {
        await _waitUntilVisible();
        if (!mounted || !_isHomePageActive) return;
        await employeeProvider.getAllUsers();

        await _waitUntilVisible();
        if (!mounted || !_isHomePageActive) return;
        await customerProvider.getAllCustomers(true);

        _lastSecondaryUserId = id.toString();
        _lastSecondaryLoad = DateTime.now();
      }

      await _waitUntilVisible();
      if (!mounted || !_isHomePageActive) return;
      await employeeProvider.getNotifications();

      debugPrint("✅ ALL HOMEPAGE DATA LOADED");
    });
  }

  Widget iconBox({required VoidCallback callBack, required String img, required String text}) {
    return InkWell(
      onTap: callBack,
      child: Container(
        height: 40,
        decoration: customDecoration.baseBackgroundDecoration(
            color: Colors.white, radius: 5, borderColor: Colors.grey.shade400),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              10.width,
              SizedBox(
                  width: 20,
                  height: 20,
                  child: SvgPicture.asset(img, width: 20, height: 20)),
              10.width,
              CustomText(text),
            ],
          ),
        ),
      ),
    );
  }

  String getTimeDifferenceFrom(String timeString) {
    final now = DateTime.now();

    // Parse time string like "2:20 PM"
    final regex = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false);
    final match = regex.firstMatch(timeString.trim());

    if (match == null) return 'Invalid time format';

    int hour = int.parse(match.group(1)!);
    int minute = int.parse(match.group(2)!);
    String period = match.group(3)!.toUpperCase();

    // Convert to 24-hour format
    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    final customTime = DateTime(now.year, now.month, now.day, hour, minute);

    final difference = now.difference(customTime);

    if (difference.isNegative) {
      return 'Time is in the future';
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    return '$hours : $minutes';
  }

  String timeDifference(String dateTimeString1, String dateTimeString2) {
    DateTime startTime = DateTime.parse(dateTimeString1);
    DateTime endTime = DateTime.parse(dateTimeString2);

    Duration difference = endTime.difference(startTime);

    return difference.inHours == 0
        ? "${difference.inMinutes} Mins"
        : "${difference.inHours} Hrs";
  }

  Future<void> getWebSafeLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, // 👈 Web-safe
      );

      log("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
    } catch (e) {
      log("❌ Error fetching location: $e");
    }
  }

  String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return constValue.morning;
    if (hour < 17) return constValue.afternoon;
    if (hour < 21) return constValue.evening;
    return constValue.night;
  }

  bool isVerify = false;
  bool isPermission = false;
  DateTime selectedDate = DateTime.now();
  String? selectedFilter = "Today";

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return "$day/$month/$year";
  }

  // ---------------------------------------------------------------------------
  // main_report value helpers (null / "null" -> default)
  // ---------------------------------------------------------------------------
  String _mr(HomeProvider h, String key, {String def = "0"}) {
    if (h.mainReportList.isEmpty) return def;
    final v = h.mainReportList[0][key];
    if (v == null || v.toString() == "null") return def;
    return v.toString();
  }

  int _mrInt(HomeProvider h, String key) => int.tryParse(_mr(h, key)) ?? 0;

  // ---------------------------------------------------------------------------
  // BUILD
  //
  // Consumer2: HomeProvider + AttendanceProvider mattum. Customer / Employee /
  // Leave / Location provider notify pannina Home mulusa rebuild aagaadhu.
  // (Home vera page mela irukkum bodhu kooda memory la irukkum.)
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Consumer2<HomeProvider, AttendanceProvider>(
      builder: (context, homeProvider, attPvr, _) {
        final int taskPendingCount = _mrInt(homeProvider, "incomplete_count");
        final int taskCompletedCount = _mrInt(homeProvider, "complete_count");

        return Scaffold(
          backgroundColor: ColorsConst.background2,
          body: PopScope(
            canPop: false,
            onPopInvoked: (bool pop) {
              return utils.customDialog(
                  context: context,
                  callback: () {
                    SystemNavigator.pop();
                  },
                  title: "Do you want to Exit the App?");
            },
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: homeProvider.versionCheck == false
                    ? const Center(child: Loading())
                    : homeProvider.currentVersion != "" &&
                    homeProvider.versionCheck == true &&
                    homeProvider.versionActive == false
                    ? const UpdateApp()
                    : homeProvider.mainReportList.isNotEmpty &&
                    homeProvider.mainReportList[0]["active"] != "1"
                    ? const Center(
                    child: CustomText(
                      "Invalid",
                      color: Colors.red,
                      weight: FontWeight.bold,
                      size: 20,
                    ))
                    : NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGreetingRow(homeProvider),
                        5.height,
                        _buildFilterRow(context, homeProvider, screenWidth),
                        10.height,
                        const InkWell(child: CheckAttendance()),
                        10.height,

                        /// DAILY WORK PLAN
                        _buildDailyWorkPlan(context, homeProvider, attPvr),

                        /// ATTENDANCE CARD
                        if (localData.storage.read("role") == "1")
                          _buildAttendanceCard(context, homeProvider),
                        10.height,

                        if (homeProvider.roleAccess.any((f) =>
                        f['feature'] == 'Task Management' &&
                            f['name'] == 'View'))
                          10.height,

                        /// TASK CARD
                        _buildTaskCard(
                          context,
                          homeProvider,
                          screenWidth,
                          screenHeight,
                          taskPendingCount,
                          taskCompletedCount,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // GREETING + DATE
  // ---------------------------------------------------------------------------
  Widget _buildGreetingRow(HomeProvider homeProvider) {
    return Row(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "${greeting()}  ",
                style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
              TextSpan(
                text: "${localData.storage.read("f_name")}",
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorsConst.textBlack,
                ),
              ),
            ],
          ),
        ),
        30.width,
        CustomText(
          homeProvider.date,
          size: 14,
          color: ColorsConst.textGrey,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TYPE DROPDOWN + DATE PICKER
  // ---------------------------------------------------------------------------
  Widget _buildFilterRow(
      BuildContext context, HomeProvider homeProvider, double screenWidth) {
    return SizedBox(
      width: screenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 35,
            width: screenWidth / 2.2,
            decoration: customDecoration.baseBackgroundDecoration(
                color: Colors.white, radius: 10),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: homeProvider.type,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black,
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                items: homeProvider.typeList.map((list) {
                  return DropdownMenuItem(
                    value: list,
                    child: CustomText(
                      "  $list",
                      color: Colors.black,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    homeProvider.changeType(context, value);
                  });
                },
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              homeProvider.showDatePickerDialog(context);
            },
            child: Container(
              height: 35,
              width: screenWidth / 2.2,
              decoration: customDecoration.baseBackgroundDecoration(
                  color: Colors.white, radius: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: colorsConst.primary,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: CustomText(
                      size: 12,
                      (homeProvider.startDate == homeProvider.endDate)
                          ? homeProvider.startDate
                          : "${homeProvider.startDate} to ${homeProvider.endDate}",
                      weight: FontWeight.w600,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DAILY WORK PLAN
  // ---------------------------------------------------------------------------
  Widget _buildDailyWorkPlan(
      BuildContext context, HomeProvider homeProvider, AttendanceProvider attPvr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xffF3F6FA),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// LEFT: Daily Work Plan
              Flexible(
                flex: 3,
                child: CustomText(
                  constValue.daily,
                  size: 14,
                  weight: FontWeight.bold,
                  shrink: true,
                  color: const Color(0xff1A85DB),
                ),
              ),
              const SizedBox(width: 8),

              /// RIGHT: Total (other roles)
              if (localData.storage.read("role") != "1")
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Total: ", style: TextStyle(fontSize: 14)),
                    Text(
                      _mr(homeProvider, "workPlanTotal"),
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// RIGHT: Present Employee (role 1)
              if (localData.storage.read("role") == "1")
                Flexible(
                  flex: 2,
                  child: CustomText(
                    "${constValue.presentEmployee}: "
                        "${_mr(homeProvider, "presentEmployeesCountHapi")}",
                    size: 12,
                    shrink: true,
                    weight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
            ],
          ),
          5.height,

          /// SUBMITTED / NOT SUBMITTED (role 1)
          if (localData.storage.read("role") == "1")
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DailyReportStatusPage(
                      initialTab: 0, // Submitted
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  /// SUBMITTED
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DailyReportStatusPage(initialTab: 0),
                          ),
                        );
                      },
                      child: Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xff1A85DB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CustomText(
                          "${constValue.submit}(${_mr(homeProvider, "workPlanSubmittedCount")})",
                          size: 13,
                          weight: FontWeight.w600,
                          color: Colors.white,
                          shrink: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  /// NOT SUBMITTED
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DailyReportStatusPage(initialTab: 1),
                          ),
                        );
                      },
                      child: Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CustomText(
                          "${constValue.not_Submit}(${_mr(homeProvider, "workPlanNotSubmittedCount")})",
                          size: 13,
                          weight: FontWeight.w600,
                          color: Colors.white,
                          shrink: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          10.height,

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// ADD WORK PLAN BUTTON
              Expanded(
                flex: 5,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    if (attPvr.mainAttendance == 0) {
                      utils.showWarningToast(context,
                          text: "Please mark attendance first");
                      return;
                    }

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DayWorkPlanPage()),
                    );

                    if (result == true && context.mounted) {
                      await homeProvider.loadFullDashboard(context);
                    }
                  },
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: attPvr.mainAttendance == 0
                          ? Colors.grey.shade300
                          : const Color(0xffDAF2DC),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 4,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          assets.addButton,
                          width: 18,
                          height: 18,
                          color: attPvr.mainAttendance == 0 ? Colors.grey : null,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: CustomText(
                            constValue.addWorkPlan,
                            size: 14,
                            weight: FontWeight.bold,
                            shrink: true,
                            color: attPvr.mainAttendance == 0
                                ? Colors.black54
                                : const Color(0xff0F8D4B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              /// PROGRESS CARD
              Expanded(
                flex: 4,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DailyReportStatusPage(initialTab: 0),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 3),
                      ],
                    ),
                    child: Builder(builder: (context) {
                      final int done = _mrInt(homeProvider, "workPlanCompleted");
                      final int pending = _mrInt(homeProvider, "workPlanPending");

                      final total = done + pending;
                      final double progressValue = total == 0 ? 0 : done / total;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progressValue,
                              minHeight: 8,
                              backgroundColor: Colors.red,
                              valueColor: const AlwaysStoppedAnimation(
                                  Color(0xff0F8D4B)),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Flexible(
                                child: CustomText(
                                  "${constValue.done}: $done",
                                  size: 12,
                                  weight: FontWeight.bold,
                                  shrink: true,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: CustomText(
                                  "${constValue.pending}: $pending",
                                  size: 12,
                                  weight: FontWeight.bold,
                                  shrink: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ATTENDANCE CARD (role 1)
  // ---------------------------------------------------------------------------
  void _openAttendanceReport(
      BuildContext context, HomeProvider homeProvider, String showType) {
    homeProvider.updateIndex(4);
    utils.navigatePage(
      context,
          () => DashBoard(
        child: AttendanceReport(
          type: homeProvider.type,
          showType: showType,
          date1: homeProvider.startDate,
          date2: homeProvider.endDate,
          // listen: false -> Employee provider notify pannina Home rebuild aagaadhu
          empList: context.read<EmployeeProvider>().userData,
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(BuildContext context, HomeProvider homeProvider) {
    final int fullLeave = _mrInt(homeProvider, "fulldayleave_user");
    final int sessionLeave = _mrInt(homeProvider, "sessionleave_user");

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  "${constValue.attendLogEmp}",
                  size: 14,
                  weight: FontWeight.bold,
                  shrink: true,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomText(
                "${constValue.attendTotEmp}: ${_mr(homeProvider, "total_user_count", def: "")}",
                color: Colors.black54,
                shrink: true,
              ),
            ],
          ),
          5.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// PRESENT
              AttendanceItem(
                onClick: () {
                  if (homeProvider.mainReportList.isNotEmpty &&
                      _mr(homeProvider, "unique_attendance_count") != "0") {
                    _openAttendanceReport(context, homeProvider, "Present");
                  } else {
                    utils.showWarningToast(context,
                        text: "No present employees found");
                  }
                },
                title: "Present",
                type: "1",
                count: _mr(homeProvider, "unique_attendance_count"),
                bgColor: const Color(0xFFE8F5E9),
                borderColor: ColorsConst.present,
                imagePath: DashboardAssets.present,
              ),

              /// ABSENT
              AttendanceItem(
                title: "Absent",
                onClick: () {
                  if (homeProvider.mainReportList.isNotEmpty &&
                      _mr(homeProvider, "no_attendance_count") != "0") {
                    _openAttendanceReport(context, homeProvider, "Absent");
                  } else {
                    utils.showWarningToast(context,
                        text: "No absent employees found");
                  }
                },
                count: _mr(homeProvider, "no_attendance_count"),
                bgColor: const Color(0xFFFFEBEE),
                borderColor: ColorsConst.absent,
                imagePath: DashboardAssets.absent,
              ),

              /// LATE
              AttendanceItem(
                onClick: () {
                  if (homeProvider.lateCountShow != 0) {
                    _openAttendanceReport(context, homeProvider, "Late");
                  } else {
                    utils.showWarningToast(context,
                        text: "No late employees found");
                  }
                },
                title: "Late",
                count: "${homeProvider.lateCountShow}",
                bgColor: const Color(0xFFFFF3E0),
                borderColor: colorsConst.late,
                imagePath: DashboardAssets.late,
              ),

              /// ON-LEAVE
              AttendanceItem(
                title: "On-Leave",
                onClick: () {
                  // full day + session leave rendum count aagum
                  // (munnadi fulldayleave_user ah rendu dhadava check pannitu irundhuchu)
                  if (homeProvider.mainReportList.isNotEmpty &&
                      (fullLeave != 0 || sessionLeave != 0)) {
                    _openAttendanceReport(context, homeProvider, "Leave");
                  } else {
                    utils.showWarningToast(context,
                        text: "No on leave employee found");
                  }
                },
                count: homeProvider.mainReportList.isEmpty
                    ? "0"
                    : "${fullLeave + sessionLeave}",
                bgColor: const Color(0xFFE3F2FD),
                borderColor: ColorsConst.onLeave,
                imagePath: DashboardAssets.onLeave,
              ),

              /// PERMISSION
              AttendanceItem(
                onClick: () {
                  if (homeProvider.mainReportList.isNotEmpty &&
                      _mr(homeProvider, "perm_count") != "0") {
                    _openAttendanceReport(context, homeProvider, "Permission");
                  } else {
                    utils.showWarningToast(context,
                        text: "No permission employees found");
                  }
                },
                title: "Permission",
                type: "2",
                count: _mr(homeProvider, "perm_count"),
                bgColor: Colors.purple.shade100,
                borderColor: Colors.purple,
                imagePath: DashboardAssets.late,
              ),
            ],
          ),
          5.height,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TASK CARD
  // ---------------------------------------------------------------------------
  List<Widget> _taskCountItems(
      {required String label,
        required String value,
        required Color color}) {
    return [
      Flexible(
        child: CustomText(
          label,
          size: 13,
          weight: FontWeight.bold,
          color: color,
          shrink: true,
        ),
      ),
      const SizedBox(width: 2),
      CustomText(
        value,
        size: 13,
        weight: FontWeight.bold,
        color: color,
      ),
    ];
  }

  Widget _buildTaskCard(
      BuildContext context,
      HomeProvider homeProvider,
      double screenWidth,
      double screenHeight,
      int taskPendingCount,
      int taskCompletedCount,
      ) {
    return InkWell(
      onTap: () {
        homeProvider.updateIndex(10);
        utils.navigatePage(
            context,
                () => DashBoard(
                child: ViewTask(
                    date1: homeProvider.startDate,
                    date2: homeProvider.endDate,
                    type: homeProvider.type)));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOP ROW
            Row(
              children: [
                /// LEFT SIDE
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomText(
                        "${constValue.task}:",
                        size: 20,
                        weight: FontWeight.bold,
                      ),
                      CustomText(
                        "  ${_mr(homeProvider, "total_tasks")} ",
                        size: 25,
                        weight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),

                /// RIGHT SIDE (Add Task)
                InkWell(
                  onTap: () async {
                    utils.navigatePage(
                        context, () => const DashBoard(child: AddTask()));
                  },
                  child: Container(
                    width: screenWidth / 2.2,
                    height: screenHeight / 22,
                    decoration: BoxDecoration(
                      color: const Color(0xffDAF2DC),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 4,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(assets.addButton),
                          const SizedBox(width: 6),
                          CustomText(
                            "${constValue.add_Task}",
                            size: 14,
                            weight: FontWeight.bold,
                            color: const Color(0xff0F8D4B),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            7.height,

            /// ASSIGNED / STARTED
            Row(
              children: [
                ..._taskCountItems(
                  label: "${constValue.assigned}:",
                  value: _mr(homeProvider, "assigned_count"),
                  color: const Color(0xff008443),
                ),
                const SizedBox(width: 12),
                ..._taskCountItems(
                  label: "${constValue.started}:",
                  value: _mr(homeProvider, "started_count"),
                  color: const Color(0xffF02433),
                ),
              ],
            ),
            5.height,

            /// OVERDUE / COMPLETED
            Row(
              children: [
                ..._taskCountItems(
                  label: "${constValue.overdue}:",
                  value: _mr(homeProvider, "overdue_count"),
                  color: const Color(0xff0c5be8),
                ),
                const SizedBox(width: 12),
                ..._taskCountItems(
                  label: "${constValue.completed}:",
                  value: _mr(homeProvider, "complete_count"),
                  color: const Color(0xff0c5be8),
                ),
              ],
            ),
            5.height,

            /// PROGRESS BAR
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Row(
                children: [
                  /// Completed first
                  Expanded(
                    flex: taskCompletedCount == 0 ? 1 : taskCompletedCount,
                    child: Container(
                      height: 30,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF24FF92),
                            Color(0xFF00733A),
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// Pending second
                  Expanded(
                    flex: taskPendingCount == 0 ? 1 : taskPendingCount,
                    child: Container(
                      height: 30,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFFA953),
                            Color(0xFFE81C2B),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            5.height,

            /// PRIORITY CHIPS
            if (taskPendingCount != 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// IMMEDIATE
                  Expanded(
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xffFBF2FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: CustomText(
                        "${constValue.immediate}(${_mr(homeProvider, "Immediate_count")})",
                        color: const Color(0xffB35CFF),
                        shrink: true,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                  5.width,

                  /// NORMAL
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      margin: const EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xffF2F6FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: CustomText(
                        "${constValue.normal} (${_mr(homeProvider, "Normal_count")})",
                        color: const Color(0xff1A85DB),
                        shrink: true,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                  2.width,

                  /// HIGH
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      margin: const EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xffFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: CustomText(
                        "${constValue.high} (${_mr(homeProvider, "High_count")})",
                        color: const Color(0xffFF5C68),
                        shrink: true,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}