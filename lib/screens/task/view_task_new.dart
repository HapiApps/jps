import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/component/custom_loading_button.dart';
import 'package:master_code/component/map_dropdown.dart';
import 'package:master_code/screens/task/add_task.dart';
import 'package:master_code/screens/task/edit_task.dart';
import 'package:master_code/screens/task/search_custom_dropdown.dart' hide MapDropDown;
import 'package:master_code/screens/task/task_calendar.dart';
import 'package:master_code/screens/task/task_chat.dart';
import 'package:master_code/screens/task/task_details.dart';
import 'package:master_code/screens/task/task_report.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/customer_provider.dart';
import 'package:master_code/view_model/employee_provider.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../component/animated_button.dart';
import '../../component/appbar_new.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_date_dropdown_new.dart';
import '../../component/custom_text.dart';
import '../../component/expand_text.dart';
import '../../component/search_drop_down.dart';
import '../../model/customer/customer_model.dart';
import '../../model/task/task_data_model.dart';
import '../../model/user_model.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/language_model.dart';
import '../../source/constant/local_data.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/task_provider.dart';
import '../common/dashboard.dart';
import '../common/home_page.dart';
import '../expense/create_expense.dart';
import 'add_wages_work_details.dart';
import 'package:url_launcher/url_launcher.dart';

/// ---------------------------------------------------------------------------
/// PARENT: loads all data ONCE (dropdown data + task list).
/// The child tab (ViewfilterUserData) does NOT call any API in initState.
///
/// PERF CHANGES:
///  * No Selector around the whole screen any more (it rebuilt appbar,
///    overview, tabbar and both tabs on every dataVersion bump).
///  * Calendar tab is built only AFTER the tab animation finishes and is then
///    kept alive -> tab switch is smooth and instant the 2nd time.
///
/// UI CHANGES (match design screenshot, 393dp base):
///  * 16dp side margin on the whole body (children use zero side padding).
///  * Task overview, tab bar, search, chips, cards and calendar re-measured.
/// ---------------------------------------------------------------------------
class ViewTaskPage extends StatefulWidget {
  final String date1;
  final String date2;
  final String type;
  const ViewTaskPage({super.key, required this.date1, required this.date2, required this.type});

  @override
  State<ViewTaskPage> createState() => _ViewTaskState();
}

class _ViewTaskState extends State<ViewTaskPage> with SingleTickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();
  late TabController tabController;
  final GlobalKey<_ViewfilterUserDataState> _listKey = GlobalKey<_ViewfilterUserDataState>();

  // Calendar is heavy -> build it lazily, after the tab animation completes.
  bool _calendarReady = false;
  bool _calendarScheduled = false;

  void _onTabChange() {
    _myFocusScopeNode.unfocus();
    if (tabController.index == 1 && !_calendarReady && !_calendarScheduled) {
      _calendarScheduled = true;
      Future.delayed(const Duration(milliseconds: 320), () {
        if (!mounted) return;
        setState(() => _calendarReady = true);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (kDebugMode) debugPrint('>>> ViewTask initState');
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(_onTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final custProvider = Provider.of<CustomerProvider>(context, listen: false);

      // employees / customers / task users -> HomePage already loaded them.
      // They are loaded lazily (only if empty) when the Filter dialog opens.

      taskProvider.search.clear();
      taskProvider.search2.clear();

      // Dropdown / master data
      if (kIsWeb) {
        taskProvider.getTaskType(false);
        taskProvider.getTaskStatuses();
        custProvider.getLeadCategory();
        custProvider.getVisitType();
        custProvider.getCmtType();
      } else {
        taskProvider.getAllTypes();
        taskProvider.getTypeSts();
        custProvider.getLead();
        custProvider.getVisit();
        custProvider.getCommentType();
      }

      taskProvider.dataSource = _getDataSource();

      taskProvider.initFilterValue(
        true,
        date1: widget.date1,
        date2: widget.date2,
        type: widget.type,
      );
      taskProvider.getAllTask(true);
    });
  }

  @override
  void dispose() {
    if (kDebugMode) debugPrint('>>> ViewTask dispose');
    tabController.dispose();
    _myFocusScopeNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.read<TaskProvider>();
    final homeProvider = context.read<HomeProvider>();
    final webWidth = MediaQuery.of(context).size.width * 0.5;

    return FocusScope(
      node: _myFocusScopeNode,
      child: Padding(
        padding: EdgeInsets.zero, // was 5
        child: Scaffold(
          backgroundColor: colorsConst.bacColor,
          appBar: PreferredSize(
            preferredSize: const Size(300, 50),
            child: MyAppbar(
              text: "${constValue.viewTask}",
              callback: () {
                _myFocusScopeNode.unfocus();
                homeProvider.updateIndex(0);
                utils.navigateAndClear(context, () => const DashBoard(child: HomePage()));
              },
              isLoading: taskProvider.isAddTaskLoading,
              buttonCallback: () async {
                if (taskProvider.isAddTaskLoading) return; // double-tap block

                setState(() {
                  taskProvider.isAddTaskLoading = true;
                });

                taskProvider.typeList.removeWhere((e) => e['value'] == 'All');

                if (taskProvider.assignedNames.isEmpty) {
                  await taskProvider.getTaskUsers();
                }

                if (!mounted) return;

                setState(() {
                  taskProvider.isAddTaskLoading = false;
                });

                utils.navigatePage(
                  context,
                      () => const DashBoard(child: AddTask()),
                );
              },
            ),
          ),
          body: PopScope(
            canPop: false,
            onPopInvoked: (bool didPop) {
              _myFocusScopeNode.unfocus();
              homeProvider.updateIndex(0);
              if (!didPop) {
                utils.navigateAndClear(context, () => const DashBoard(child: HomePage()));
              }
            },
            child: Center(
              child: SizedBox(
                width: kIsWeb ? webWidth : double.infinity,
                child: Padding(
                  // 16dp side margin (screenshot)
                  padding: EdgeInsets.symmetric(horizontal: kIsWeb ? 0 : 16),
                  child: Column(
                    children: [
                      _TopDateFilter(onChanged: () => _listKey.currentState?._resetPaging()),
                      const SizedBox(height: 12),
                      // Swipe: page 1 = all tasks, page 2 = logged-in admin's own tasks
                      RepaintBoundary(
                        child: _OverviewSwitcher(
                          isAdmin: localData.storage.read("role").toString() == "1",
                          onChanged: (mine) {
                            context.read<TaskProvider>().setMineOnly(mine);
                            _listKey.currentState?._resetPaging();
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 46, // was 50
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: AnimatedBuilder(
                          animation: tabController,
                          builder: (context, _) {
                            final isTasksActive = tabController.index == 0;
                            final isCalendarActive = tabController.index == 1;

                            return TabBar(
                              controller: tabController,
                              indicatorPadding: const EdgeInsets.all(4), // was symmetric(6,4)
                              indicator: customDecoration.baseBackgroundDecoration(
                                radius: 30,
                                color: colorsConst.primary,
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              tabs: [
                                // ---------- Tab 1: Tasks ----------
                                Tab(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        isTasksActive
                                            ? "assets/images/task_active.svg"
                                            : "assets/images/task_icon.svg",
                                      ),
                                      8.width, // was 10
                                      CustomText(
                                        text: "Tasks",
                                        isBold: true,
                                        size: 15,
                                        colors: isTasksActive ? Colors.white : ColorsConst.greyText,
                                      ),
                                    ],
                                  ),
                                ),

                                // ---------- Tab 2: Calendar ----------
                                Tab(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        isCalendarActive
                                            ? "assets/images/calender_active.svg"
                                            : "assets/images/task_calender.svg",
                                      ),
                                      8.width, // was 10
                                      CustomText(
                                        text: "Calendar",
                                        isBold: true,
                                        size: 15,
                                        colors: isCalendarActive ? Colors.white : ColorsConst.greyText,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: tabController,
                          children: [
                            ViewfilterUserData(
                                key: _listKey,
                                date1: widget.date1,
                                date2: widget.date2,
                                type: widget.type),

                            // Calendar: lazy + keep-alive + own Selector
                            _calendarReady
                                ? const _KeepAlive(child: _TaskCalendarTab())
                                : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _DataSource _getDataSource() {
    List<Appointment> appointments = <Appointment>[];
    return _DataSource(appointments);
  }
}

/// Keeps a tab page alive so it is not rebuilt every time the tab is switched.
class _KeepAlive extends StatefulWidget {
  final Widget child;
  const _KeepAlive({required this.child});

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// Small immutable style holder for the chips on the card.
class _ChipStyle {
  final String label;
  final Color bg;
  final Color fg;
  final IconData icon;
  const _ChipStyle(this.label, this.bg, this.fg, this.icon);
}

/// Display text only. Logic / API still use the English status value.
String _localStatus(String s) {
  switch (s.trim()) {
    case "Completed":
      return constValue.taskCompleted;
    case "Started":
      return constValue.taskStarted;
    case "Overdue":
      return constValue.taskOverdue;
    case "Assigned":
      return constValue.taskAssigned;
    case "Pending":
      return constValue.taskPending;
    default:
      return s;
  }
}

/// ---------------------------------------------------------------------------
/// CHILD TAB: only shows the data. NO API calls here.
/// Lazy loading: first 15 tasks, then 15 more as you scroll.
/// ---------------------------------------------------------------------------
class ViewfilterUserData extends StatefulWidget {
  final String date1;
  final String date2;
  final String type;
  const ViewfilterUserData(
      {super.key, required this.date1, required this.date2, required this.type});

  @override
  State<ViewfilterUserData> createState() => _ViewfilterUserDataState();
}

class _ViewfilterUserDataState extends State<ViewfilterUserData>
    with AutomaticKeepAliveClientMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  // lazy loading
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 15;
  int _visibleCount = _pageSize;
  bool _isLoadingMore = false;
  int _total = 0;

  // local "Overdue" tab (no provider change needed)
  bool _overdueOnly = false;

  // search debounce
  Timer? _debounce;

  // cached formatters / parsed dates (avoid re-creating per card)
  static final DateFormat _dueFmt = DateFormat('dd MMM yyyy');
  static final List<DateFormat> _parseFmts = [
    DateFormat('dd-MM-yyyy'),
    DateFormat('dd/MM/yyyy'),
    DateFormat('d-M-yyyy'),
    DateFormat('d/M/yyyy'),
  ];
  final Map<String, DateTime?> _dateCache = {};

  static const List<Color> _avatarColors = [
    Color(0xff0B5FB5),
    Color(0xff3B82F6),
    Color(0xffF59E0B),
    Color(0xff10B981),
    Color(0xff8B5CF6),
    Color(0xffEF4444),
    Color(0xff14B8A6),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isLoadingMore) return;
    if (!_scrollController.hasClients) return;
    if (_visibleCount >= _total) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      setState(() => _isLoadingMore = true);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() {
          _visibleCount += _pageSize;
          _isLoadingMore = false;
        });
      });
    }
  }

  // reset to first 15 whenever search / filter / tab changes
  void _resetPaging() {
    if (!mounted) return;
    setState(() => _visibleCount = _pageSize);
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  @override
  void dispose() {
    if (kDebugMode) debugPrint('>>> ViewfilterUserData dispose');
    _debounce?.cancel();
    _scrollController.dispose();
    _myFocusScopeNode.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // helpers
  // -------------------------------------------------------------------------
  DateTime? _parseDate(String? s) {
    if (s == null) return null;
    final t = s.trim();
    if (t.isEmpty) return null;
    if (_dateCache.containsKey(t)) return _dateCache[t];

    DateTime? result;
    final iso = DateTime.tryParse(t);
    if (iso != null) {
      result = DateTime(iso.year, iso.month, iso.day);
    } else {
      for (final f in _parseFmts) {
        try {
          result = f.parseStrict(t);
          break;
        } catch (_) {}
      }
    }
    _dateCache[t] = result;
    return result;
  }

  // -------------------------------------------------------------------------
  // CUSTOMER CALL
  // -------------------------------------------------------------------------
  // company name -> phone (only non-empty results are cached)
  final Map<String, String> _phoneCache = {};

  /// Tries the usual field names on a model (TaskData / customer model).
  /// >>> If your model uses another name, add it to the list below. <<<
  String _readPhone(dynamic o) {
    final getters = <dynamic Function()>[
          () => o.customerMobile,
          () => o.customerMobileNo,
          () => o.customerNumber,
          () => o.mobile,
          () => o.mobileNo,
          () => o.mobileNumber,
          () => o.phone,
          () => o.phoneNumber,
          () => o.contactNo,
          () => o.contactNumber,
          () => o.companyMobile,
          () => o.number,
    ];
    for (final g in getters) {
      try {
        final v = g();
        if (v == null) continue;
        final t = v.toString().trim();
        if (t.isEmpty || t == "null" || t == "0") continue;
        // several numbers "98.., 97.." -> first one
        final first = t.split(RegExp(r'[,/;]')).first.trim();
        final cleaned = first.replaceAll(RegExp(r'[^0-9+]'), '');
        if (cleaned.length >= 6) return cleaned;
      } catch (_) {}
    }
    return "";
  }

  /// 1) number on the task itself, 2) fallback: look up the customer by company name
  String _phoneFor(TaskData d) {
    final direct = _readPhone(d);
    if (direct.isNotEmpty) return direct;

    final company = (d.projectName ?? "").toString().trim();
    if (company.isEmpty) return "";
    final cached = _phoneCache[company];
    if (cached != null) return cached;

    try {
      final customers = context.read<CustomerProvider>().customer;
      for (final c in customers) {
        String name = "";
        try {
          name = (c as dynamic).companyName.toString().trim();
        } catch (_) {}
        if (name.toLowerCase() == company.toLowerCase()) {
          final p = _readPhone(c);
          if (p.isNotEmpty) {
            _phoneCache[company] = p;
            return p;
          }
        }
      }
    } catch (_) {}
    return "";
  }

  Future<void> _callCustomer(String phone) async {
    _myFocusScopeNode.unfocus();
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        utils.showWarningToast(context, text: "Unable to open dialer");
      }
    } catch (_) {
      if (mounted) utils.showWarningToast(context, text: "Unable to open dialer");
    }
  }

  bool _isOverdue(TaskData d) {
    if ((d.statval ?? "") == "Completed") return false;
    final due = _parseDate(d.taskDate);
    if (due == null) return false;
    final now = DateTime.now();
    return due.isBefore(DateTime(now.year, now.month, now.day));
  }

  String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+'));
    if (p.isEmpty || p.first.isEmpty) return "?";
    if (p.length == 1) {
      return p.first.substring(0, math.min(2, p.first.length)).toUpperCase();
    }
    return (p[0][0] + p[1][0]).toUpperCase();
  }

  _ChipStyle _statusStyle(String s) {
    switch (s) {
      case "Completed":
        return _ChipStyle(
            _localStatus("Completed"), Color(0xffE7F6EC), Color(0xff1FAF38), Icons.check_circle_outline);
      case "Started":
        return _ChipStyle(
            _localStatus("Started"), Color(0xffE8F1FD), Color(0xff1A6FD1), Icons.schedule);
      case "Overdue":
        return _ChipStyle(
            _localStatus("Overdue"), Color(0xffFDECEC), Color(0xffE5383B), Icons.adjust);
      case "Assigned":
        return _ChipStyle(
            _localStatus("Assigned"), Color(0xffE8F1FD), Color(0xff1A6FD1), Icons.adjust);
      default:
        return _ChipStyle(s.isEmpty ? "-" : _localStatus(s), const Color(0xffF1F2F4),
            const Color(0xff6B7280), Icons.circle_outlined);
    }
  }

  _ChipStyle _priorityStyle(String level) {
    switch (level) {
      case "High":
        return const _ChipStyle(
            "High Priority", Color(0xffFEE9EC), Color(0xffE5383B), Icons.circle);
      case "Immediate":
        return const _ChipStyle(
            "Immediate", Color(0xffF6EAFE), Color(0xffB35CFF), Icons.circle);
      default:
        return const _ChipStyle(
            "Normal", Color(0xffF1EAFE), Color(0xff7C3AED), Icons.circle);
    }
  }

  // -------------------------------------------------------------------------
  // BUILD
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    super.build(context); // required for keep-alive
    if (kDebugMode) debugPrint('>>> ViewfilterUserData rebuild');

    // Selector: rebuilds ONLY when provider data really changes (dataVersion).
    return Selector<TaskProvider, int>(
        selector: (_, p) => p.dataVersion,
        builder: (context, _, __) {
          final taskProvider = context.read<TaskProvider>();

          final allData = taskProvider.filterUserData;
          final list = _overdueOnly ? allData.where((e) => _isOverdue(e)).toList() : allData;
          _total = list.length;

          final noData = _overdueOnly
              ? list.isEmpty
              : (list.isEmpty || (taskProvider.statusId != "" && taskProvider.matched == 0));

          return FocusScope(
            node: _myFocusScopeNode,
            child: ColoredBox(
              color: const Color(0xffF3F4F6),
              child: taskProvider.viewRefresh == false
                  ? const Loading()
                  : Column(
                children: [
                  const SizedBox(height: 16), // was 10 (tab bar -> search)

                  /// SEARCH + FILTER
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40, // was 44
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            height: 40,
                            child: TextFormField(
                              controller: taskProvider.search,
                              cursorColor: colorsConst.primary,
                              style: const TextStyle(color: Colors.black, fontSize: 14),
                              onChanged: (value) {
                                _debounce?.cancel();
                                _debounce = Timer(const Duration(milliseconds: 300), () {
                                  if (!mounted) return;
                                  _resetPaging();
                                  taskProvider.searchTask(value);
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Search employee, customer, task",
                                hintStyle: const TextStyle(
                                  color: ColorsConst.greyText,
                                  fontSize: 15,
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                isDense: true,
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(13.0),
                                  child: SvgPicture.asset(
                                    "assets/images/task/task_search_icon.svg",
                                    width: 10,
                                    height: 10,
                                  ),
                                ),
                                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                                  valueListenable: taskProvider.search,
                                  builder: (_, v, __) {
                                    if (v.text.isEmpty) return const SizedBox.shrink();
                                    return IconButton(
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        _debounce?.cancel();
                                        taskProvider.search.clear();
                                        taskProvider.searchTask("");
                                        _resetPaging();
                                      },
                                    );
                                  },
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide(
                                    color: colorsConst.primary,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10), // was 8

                      // FILTER
                      InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () {
                          _myFocusScopeNode.unfocus();
                          final cust = context.read<CustomerProvider>();
                          final emp = context.read<EmployeeProvider>();
                          if (cust.customer.isEmpty) cust.getAllCustomers(true);
                          if (emp.activeEmps.isEmpty) emp.getAllUsers(isRefresh: false);
                          if (!taskProvider.typeList.any((e) => e['value'] == 'All')) {
                            taskProvider.typeList.insert(0, {
                              "id": "",
                              "value": "All",
                            });
                          }
                          _showFilterDialog();
                        },
                        child: Container(
                          width: 40, // was 44
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorsConst.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.tune, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  /// STATUS TABS
                  SizedBox(
                    height: 30, // was 36
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      children: [
                        _statusTab(taskProvider, constValue.taskAll, ""),
                        _statusTab(taskProvider, constValue.taskAssigned, "Assigned"),
                        _statusTab(taskProvider, constValue.taskStarted, "Started"),
                        _statusTab(taskProvider, constValue.taskCompleted, "Completed"),
                        _overdueTab(taskProvider),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  /// LIST
                  noData
                      ? Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: CustomText(
                        text: "No Task Found", colors: colorsConst.greyClr),
                  )
                      : Expanded(
                    child: Builder(builder: (context) {
                      final total = list.length;
                      final visible = _visibleCount > total ? total : _visibleCount;
                      final hasMore = visible < total;

                      return ListView.builder(
                        controller: _scrollController,
                        physics: const ClampingScrollPhysics(),
                        cacheExtent: 600,
                        padding: const EdgeInsets.only(bottom: 60),
                        addAutomaticKeepAlives: false,
                        itemCount: hasMore ? visible + 1 : visible,
                        itemBuilder: (context, index) {
                          if (index == visible) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          }

                          final data = list[index];
                          // real index in provider list (for details/chat)
                          final realIndex = _overdueOnly
                              ? taskProvider.filterUserData.indexOf(data)
                              : index;

                          return RepaintBoundary(
                            key: ValueKey('task_${data.id}'),
                            child: _taskCard(data, realIndex),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        });
  }

  // -------------------------------------------------------------------------
  // FILTER DIALOG
  // -------------------------------------------------------------------------
  void _showFilterDialog() {
    final tp = context.read<TaskProvider>();
    final snapshot = tp.filterSnapshot(); // restore this if dialog is dismissed
    bool committed = false; // true after Apply / Clear All

    showDialog(
      context: context,
      builder: (context) {
        return Consumer3<TaskProvider, CustomerProvider, EmployeeProvider>(
          builder: (context, taskProvider, cusPvr, empProvider, _) {
            final screenW = MediaQuery.of(context).size.width;
            final screenH = MediaQuery.of(context).size.height;
            final isAdmin = localData.storage.read("role") == "1";

            // ---------------- layout constants ----------------
            const double fieldH = 44;
            const double rowGap = 16;
            const double colGap = 12;
            const Color borderClr = Color(0xffD9DCE1);

            BoxDecoration boxDeco() => BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderClr),
            );

            Widget field(String label, Widget child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorsConst.greyClr,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(height: fieldH, width: double.infinity, child: child),
                ],
              );
            }

            Widget dateBox(String text, VoidCallback onTap, {bool isHint = false}) {
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: boxDeco(),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: isHint ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SvgPicture.asset(assets.calendar2),
                    ],
                  ),
                ),
              );
            }

            // ---- name extraction helpers ----
            String pick(List<dynamic Function()> getters) {
              for (final g in getters) {
                try {
                  final v = g();
                  if (v != null && v.toString().trim().isNotEmpty) {
                    return v.toString();
                  }
                } catch (_) {}
              }
              return '';
            }

            String empName(dynamic e) => pick([
                  () => e.firstname,
                  () => e.name,
                  () => e.userName,
                  () => e.firstName,
            ]);

            String custName(dynamic e) => pick([
                  () => e.companyName,
                  () => e.name,
                  () => e.customerName,
                  () => e.company,
            ]);

            // ---- uniform dropdown ----
            Widget uniformDropdown({
              required String hint,
              required dynamic value,
              required List<DropdownMenuItem<dynamic>> items,
              required ValueChanged<dynamic> onChanged,
            }) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: boxDeco(),
                child: Center(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<dynamic>(
                      value: value,
                      isExpanded: true,
                      isDense: true,
                      menuMaxHeight: 300,
                      borderRadius: BorderRadius.circular(10),
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.keyboard_arrow_down_outlined, size: 22),
                      hint: Text(
                        hint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      items: items,
                      onChanged: onChanged,
                    ),
                  ),
                ),
              );
            }

            Text itemText(String t) => Text(
              t,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.black),
            );

            dynamic findWhere(List list, bool Function(dynamic) test) {
              for (final e in list) {
                if (test(e)) return e;
              }
              return null;
            }

            // ---------------- EMPLOYEE MULTI-SELECT (bottom sheet) ----------------
            void openEmployeeSheet() {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (sheetCtx) {
                  return StatefulBuilder(
                    builder: (ctx, setSheet) {
                      final list = empProvider.activeEmps;
                      return SafeArea(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: screenH * 0.7),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Select Employees',
                                        style: TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        taskProvider.clearEmployeeFilter();
                                        setSheet(() {});
                                      },
                                      child: const Text('Clear'),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              Flexible(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: list.length,
                                  itemBuilder: (_, i) {
                                    final e = list[i];
                                    return CheckboxListTile(
                                      dense: true,
                                      value: taskProvider.isEmployeeSelected(e),
                                      controlAffinity: ListTileControlAffinity.leading,
                                      title: itemText(empName(e)),
                                      onChanged: (_) {
                                        taskProvider.selectEmployeeFilter(e);
                                        setSheet(() {});
                                      },
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorsConst.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () => Navigator.pop(sheetCtx),
                                    child: const Text('Done'),
                                  ),
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
            }

            // uses the FILTER's selected employees (not Add-Task `assignedNames`)
            Widget employeeField() {
              final hasSel = taskProvider.hasEmployeeFilter;
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: openEmployeeSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: boxDeco(),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          hasSel ? taskProvider.filterEmpNames : "Select employee",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: hasSel ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_outlined, size: 22),
                    ],
                  ),
                ),
              );
            }

            // ---------------- data ----------------
            final dateRangeItems = taskProvider.filterTypeList.toSet().toList();
            final typeItems = taskProvider.typeList.toSet().toList();
            final dateOn = taskProvider.dateFilterOn;

            // ---------------- fields (2 per row) ----------------
            final fields = <Widget>[
              field(
                "From Date",
                dateBox(
                  dateOn ? taskProvider.startDate : 'All dates',
                      () => taskProvider.filterPick(
                    context: context,
                    isStartDate: true,
                    date: taskProvider.startDate,
                  ),
                  isHint: !dateOn,
                ),
              ),
              field(
                "To Date",
                dateBox(
                  dateOn ? taskProvider.endDate : 'All dates',
                      () => taskProvider.filterPick(
                    context: context,
                    isStartDate: false,
                    date: taskProvider.endDate,
                  ),
                  isHint: !dateOn,
                ),
              ),

              // ---- Select Date Range ----
              field(
                "Select Date Range",
                uniformDropdown(
                  hint: 'Select',
                  value: dateOn && dateRangeItems.contains(taskProvider.filterType)
                      ? taskProvider.filterType
                      : null,
                  items: dateRangeItems
                      .map<DropdownMenuItem<dynamic>>(
                        (e) => DropdownMenuItem<dynamic>(
                      value: e,
                      child: itemText(e.toString()),
                    ),
                  )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) taskProvider.changeFilterType(v);
                  },
                ),
              ),

              // ---- Employee ----
              if (isAdmin) field("Employee Name", employeeField()),

              // ---- Task type ----
              field(
                constValue.type,
                uniformDropdown(
                  hint: constValue.type,
                  value: findWhere(
                    typeItems,
                        (e) => e['id'].toString() == taskProvider.filterTypeId.toString(),
                  ),
                  items: typeItems
                      .map<DropdownMenuItem<dynamic>>(
                        (e) => DropdownMenuItem<dynamic>(
                      value: e,
                      child: itemText(e['value'].toString()),
                    ),
                  )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) taskProvider.checkFilterType(v); // whole map
                  },
                ),
              ),

              // ---- Company ----
              field(
                constValue.companyName,
                cusPvr.customer.isEmpty
                    ? Container(
                  decoration: boxDeco(),
                  child: const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
                    : uniformDropdown(
                  hint: constValue.companyName,
                  value: findWhere(
                    cusPvr.customer,
                        (e) =>
                    taskProvider.companyName.isNotEmpty &&
                        custName(e) == taskProvider.companyName,
                  ),
                  items: cusPvr.customer
                      .map<DropdownMenuItem<dynamic>>(
                        (e) => DropdownMenuItem<dynamic>(
                      value: e,
                      child: itemText(custName(e)),
                    ),
                  )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) taskProvider.changeName(v);
                  },
                ),
              ),
            ];

            // pair up into rows (odd last field takes full width)
            final rows = <Widget>[];
            for (int i = 0; i < fields.length; i += 2) {
              if (i > 0) rows.add(const SizedBox(height: rowGap));
              rows.add(
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: fields[i]),
                    if (i + 1 < fields.length) ...[
                      const SizedBox(width: colGap),
                      Expanded(child: fields[i + 1]),
                    ],
                  ],
                ),
              );
            }

            // ---------------- dialog ----------------
            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: kIsWeb ? screenW * 0.3 : screenW * 0.9,
                  maxHeight: screenH * 0.85,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 32,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Text(
                              'Filters',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              // X = just close (changes are reverted in .then below)
                              child: InkWell(
                                onTap: () =>
                                    Navigator.of(context, rootNavigator: true).pop(),
                                child: SvgPicture.asset(assets.cancel),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      ...rows,

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: CustomBtn(
                              width: double.infinity,
                              text: 'Clear All',
                              callback: () {
                                committed = true;
                                taskProvider.resetFilters(
                                  date1: widget.date1,
                                  date2: widget.date2,
                                  type: widget.type,
                                );
                                _resetPaging();
                                Navigator.of(context, rootNavigator: true).pop();
                              },
                              bgColor: Colors.grey.shade200,
                              textColor: Colors.black,
                            ),
                          ),
                          const SizedBox(width: colGap),
                          Expanded(
                            child: CustomBtn(
                              width: double.infinity,
                              text: 'Apply Filters',
                              callback: () {
                                committed = true;
                                taskProvider.applyFilters();
                                _resetPaging();
                                Navigator.of(context, rootNavigator: true).pop();
                              },
                              bgColor: colorsConst.primary,
                              textColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      // closed without Apply / Clear -> undo the live preview
      if (!committed && mounted) {
        tp.restoreFilterSnapshot(snapshot);
        _resetPaging();
      }
    });
  }

  // -------------------------------------------------------------------------
  // STATUS TABS
  // -------------------------------------------------------------------------
  Widget _statusTab(TaskProvider taskProvider, String text, String id) {
    final isSelected = !_overdueOnly && taskProvider.statusIds == id;
    return _chipButton(text, isSelected, () {
      if (_overdueOnly) setState(() => _overdueOnly = false);
      taskProvider.changeFilterStatusTab(id);
      _resetPaging();
    });
  }

  Widget _overdueTab(TaskProvider taskProvider) {
    return _chipButton(constValue.taskOverdue, _overdueOnly, () {
      setState(() => _overdueOnly = true);
      taskProvider.setOverdueTab();
      _resetPaging();
    });
  }

  Widget _chipButton(String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? colorsConst.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colorsConst.primary : const Color(0xffD9DCE1),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xff6B7280),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // NAVIGATION
  // -------------------------------------------------------------------------
  void _openDetails(TaskData data, int index) {
    _myFocusScopeNode.unfocus();
    Provider.of<HomeProvider>(context, listen: false).panelClose();
    utils.navigatePage(
      context,
          () => DashBoard(
        child: TaskDetails(
          data: data,
          isDirect: true,
          coId: "0",
          numberList: const [],
          index: index,
        ),
      ),
    );
  }

  Future<void> _openChat(TaskData data, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DashBoard(
          child: TaskChat(
            isVisit: false,
            taskId: data.id.toString(),
            assignedId: data.assigned.toString(),
            name: data.creator.toString(),
            assignedName: data.assignedNames.toString(),
            date1: widget.date1,
            date2: widget.date2,
            type: widget.type,
            index: index,
          ),
        ),
      ),
    );

    if (result == true) {
      if (!mounted) return;
      Provider.of<TaskProvider>(context, listen: false).getAllTask(false);
    }
  }

  // -------------------------------------------------------------------------
  // COMPACT TASK CARD
  // -------------------------------------------------------------------------
  Widget _pill(_ChipStyle s) {
    final showIcon = s.icon != Icons.circle; // priority pills have no icon
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(s.icon, size: 11, color: s.fg),
            const SizedBox(width: 4),
          ],
          Text(
            s.label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: s.fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaItem(
      IconData icon,
      String text, {
        Widget? customIcon,
      }) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          customIcon ??
              Icon(
                icon,
                size: 15, // was 14
                color: ColorsConst.greyText,
              ),
          const SizedBox(width: 4),
          Flexible(
            child: CustomText(
              text: text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              size: 13, // was 12
              colors: ColorsConst.greyText,
              isBold: false, // was true
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskCard(TaskData data, int index) {
    final overdue = _isOverdue(data);
    final statusText = overdue ? "Overdue" : (data.statval ?? "");
    final statusStyle = _statusStyle(statusText);
    final priorityStyle = _priorityStyle(data.level.toString());

    // due date
    final dueDate = _parseDate(data.taskDate);
    final dueText = dueDate != null ? _dueFmt.format(dueDate) : (data.taskDate ?? "");

    // assigned user
    final names = (data.assignedNames ?? "")
        .toString()
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final firstName = names.isEmpty ? "-" : names.first;
    final extra = names.length > 1 ? names.length - 1 : 0;
    final avatarColor = _avatarColors[firstName.hashCode.abs() % _avatarColors.length];

    final cc = (data.commentCount ?? "").toString();
    final commentText = cc.isEmpty ? "0" : cc;

    final type = (data.type ?? "").toString();
    final company = (data.projectName ?? "").toString();
    final phone = _phoneFor(data);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6), // was h8 v5
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openDetails(data, index),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12), // was 14,12,14,12
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xffE9ECF0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// chips + DUE
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [_pill(statusStyle), _pill(priorityStyle)],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "DUE",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          color: Color(0xff6B7280),
                        ),
                      ),
                      Text(
                        dueText,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: ColorsConst.appBlack, // always dark (screenshot)
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              4.height, // was 10 (chips -> title)

              /// title
              Text(
                data.taskTitle ?? "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18, // was 16
                  fontWeight: FontWeight.w700,
                  color: Color(0xff14151F),
                ),
              ),
              4.height, // was 10 (title -> type/company)

              /// type + company
              if (type.isNotEmpty || company.isNotEmpty)
                Row(
                  children: [
                    if (type.isNotEmpty) _metaItem(Icons.sell_outlined, type),
                    if (type.isNotEmpty && company.isNotEmpty) const SizedBox(width: 10),
                    if (company.isNotEmpty)
                      _metaItem(
                        Icons.apartment,
                        company,
                        customIcon: SvgPicture.asset(
                          'assets/images/task/company_icon.svg',
                          width: 15,
                          height: 15,
                          fit: BoxFit.contain,
                          placeholderBuilder: (context) =>
                          const Icon(Icons.apartment, size: 15),
                        ),
                      ),
                  ],
                ),
              12.height, // was 15 (meta -> assigned row)

              /// assigned + comments + view details
              Row(
                children: [
                  CircleAvatar(
                    radius: 15, // was 14
                    backgroundColor: avatarColor,
                    child: Text(
                      _initials(firstName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            firstName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff14151F),
                            ),
                          ),
                        ),
                        if (extra > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              "+$extra",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff007AAE),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _openChat(data, index),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chat_bubble_outline,
                              size: 16, color: Color(0xff6B7280)),
                          const SizedBox(width: 4),
                          Text(
                            commentText,
                            style: const TextStyle(fontSize: 12, color: Color(0xff4B5563)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (phone.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _callCustomer(phone),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xffE7F6EC),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.call, size: 15, color: Color(0xff1FAF38)),
                      ),
                    ),
                  ],
                  SizedBox(width: phone.isNotEmpty ? 10 : 16),
                  Text(
                    constValue.viewDetailsText,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff0B5FB5),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_right, size: 16, color: Color(0xff0B5FB5)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}

/// ---------------------------------------------------------------------------
/// Swipeable overview (admin only):
///   page 1 -> "Task Overview"    : all tasks (as before)
///   page 2 -> "My Task Overview" : only tasks assigned to the logged-in admin
/// Swiping also switches the task list + calendar below to "my tasks".
/// Non-admin users just see the normal single card.
/// ---------------------------------------------------------------------------
class _OverviewSwitcher extends StatefulWidget {
  final bool isAdmin;
  final ValueChanged<bool> onChanged; // true = my tasks only
  const _OverviewSwitcher({required this.isAdmin, required this.onChanged});

  @override
  State<_OverviewSwitcher> createState() => _OverviewSwitcherState();
}

class _OverviewSwitcherState extends State<_OverviewSwitcher> {
  bool _mine = false;
  int _dir = 1; // 1 = new card enters from right, -1 = from left

  void _go(bool mine) {
    if (!widget.isAdmin || mine == _mine) return;
    _dir = mine ? 1 : -1;
    widget.onChanged(mine); // update provider first
    setState(() => _mine = mine);
  }

  Widget _dot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: active ? 18 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? colorsConst.primary : const Color(0xffD1D5DB),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<TaskProvider, int>(
      selector: (_, p) => p.dataVersion,
      builder: (ctx, _, __) {
        final o = ctx.read<TaskProvider>().overview;

        final card = TaskOverviewCard(
          key: ValueKey(_mine),
          title: _mine ? constValue.myTaskOverview : constValue.taskOverview,
          totalLabel: constValue.taskCount,
          completed: o.completed,
          pending: o.pending,
          overdue: o.overdue,
        );

        if (!widget.isAdmin) return card;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: (d) {
                final v = d.primaryVelocity ?? 0;
                if (v < -200) {
                  _go(true); // swipe left -> my tasks
                } else if (v > 200) {
                  _go(false); // swipe right -> all tasks
                }
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) {
                  final incoming = child.key == ValueKey(_mine);
                  final begin = Offset((incoming ? _dir : -_dir) * 0.25, 0);
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: begin, end: Offset.zero).animate(anim),
                      child: child,
                    ),
                  );
                },
                child: card,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _go(!_mine),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_dot(!_mine), _dot(_mine)],
              ),
            ),
          ],
        );
      },
    );
  }
}

///Task Overview Card
class TaskOverviewCard extends StatelessWidget {
  final int completed;
  final int pending;
  final int overdue;

  /// Leave null -> completed + pending + overdue
  final int? total;

  final String title;
  final String totalLabel;

  final Color completedColor;
  final Color pendingColor;
  final Color overdueColor;

  const TaskOverviewCard({
    super.key,
    required this.completed,
    required this.pending,
    required this.overdue,
    this.total,
    required this.title,
    required this.totalLabel,
    this.completedColor = const Color(0xff009B48),
    this.pendingColor = const Color(0xff0B5FB5),
    this.overdueColor = const Color(0xffEE3A43),
  });

  static const Color _titleGrey = Color(0xff5B6070);
  static const Color _dark = Color(0xff14151F);
  static const Color _tileBg = Color(0xffF6F7F9);

  @override
  Widget build(BuildContext context) {
    final totalCount = total ?? (completed + pending + overdue);
    final percent = totalCount == 0 ? 0 : (completed / totalCount * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 60,
            child: Row(
              children: [
                /// LEFT: title + total
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          color: _titleGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              "$totalCount",
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                color: _dark,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              totalLabel,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: _titleGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                /// RIGHT: donut with % in center
                SizedBox(
                  width: 60, // was 84
                  height: 60,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, t, _) {
                      return CustomPaint(
                        painter: _DonutPainter(
                          completed: completed,
                          pending: pending,
                          overdue: overdue,
                          completedColor: completedColor,
                          pendingColor: pendingColor,
                          overdueColor: overdueColor,
                          progress: t,
                        ),
                        child: Center(
                          child: Text(
                            "$percent%",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _dark,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          /// TILES
          Row(
            children: [
              Expanded(child: _tile(constValue.taskCompleted.toUpperCase(), completed, completedColor)),
              const SizedBox(width: 10),
              Expanded(child: _tile(constValue.taskPending.toUpperCase(), pending, pendingColor)),
              const SizedBox(width: 10),
              Expanded(child: _tile(constValue.taskOverdue.toUpperCase(), overdue, overdueColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tile(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        color: _tileBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _titleGrey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              "$value",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _dark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopDateFilter extends StatelessWidget {
  final VoidCallback onChanged;
  const _TopDateFilter({required this.onChanged});

  static final DateFormat _df = DateFormat('dd-MM-yyyy'); // provider format
  static final DateFormat _show = DateFormat('dd MMM yyyy'); // display format
  static const String _all = '__all__';
  static const String _custom = '__custom__';

  DateTime _parse(String s, DateTime fallback) {
    try {
      return _df.parse(s);
    } catch (_) {
      return fallback;
    }
  }

  // ---------------- small popup for custom range ----------------
  Future<void> _pickCustom(BuildContext context, TaskProvider tp) async {
    final now = DateTime.now();
    DateTime from = tp.dateFilterOn ? _parse(tp.startDate, now) : now;
    DateTime to = tp.dateFilterOn ? _parse(tp.endDate, now) : now;

    await showDialog(
      context: context,
      builder: (dCtx) {
        return StatefulBuilder(
          builder: (dCtx, setD) {
            Future<void> pick(bool isFrom) async {
              final d = await showDatePicker(
                context: dCtx,
                initialDate: isFrom ? from : to,
                firstDate: DateTime(2020),
                lastDate: DateTime(now.year + 2),
              );
              if (d == null) return;
              setD(() {
                if (isFrom) {
                  from = d;
                  if (to.isBefore(from)) to = from;
                } else {
                  to = d;
                  if (from.isAfter(to)) from = to;
                }
              });
            }

            Widget dateBox(String label, DateTime value, bool isFrom) {
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorsConst.greyClr,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => pick(isFrom),
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xffD9DCE1)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _show.format(value),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, color: Colors.black),
                              ),
                            ),
                            Icon(Icons.calendar_today_outlined,
                                size: 16, color: colorsConst.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Custom Range',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          dateBox('From Date', from, true),
                          const SizedBox(width: 12),
                          dateBox('To Date', to, false),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(dCtx),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorsConst.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                tp.applyDateRange(
                                  date1: _df.format(from),
                                  date2: _df.format(to),
                                  type: "Custom",
                                );
                                onChanged();
                                Navigator.pop(dCtx);
                              },
                              child: const Text('Apply'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------- full readable date text (right side) ----------------
  String _subText(TaskProvider tp) {
    if (!tp.dateFilterOn) return "Showing all dates";
    final now = DateTime.now();
    final s = _parse(tp.startDate, now);
    final e = _parse(tp.endDate, now);
    if (s.year == e.year && s.month == e.month && s.day == e.day) {
      return DateFormat('EEEE, MMMM d yyyy').format(s);
    }
    return "${_show.format(s)}  to  ${_show.format(e)}";
  }

  @override
  Widget build(BuildContext context) {
    return Selector<TaskProvider, int>(
      selector: (_, p) => p.dataVersion,
      builder: (ctx, _, __) {
        final tp = ctx.read<TaskProvider>();
        final on = tp.dateFilterOn;
        final isPreset = tp.filterTypeList.contains(tp.filterType);
        // label only shows the NAME; real dates are shown on the right
        final label = !on ? 'All Dates' : (isPreset ? tp.filterType.toString() : 'Custom');

        PopupMenuItem<String> item(String value, String text, bool selected) {
          return PopupMenuItem<String>(
            value: value,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? colorsConst.primary : Colors.black,
                    ),
                  ),
                ),
                if (selected) Icon(Icons.check, size: 18, color: colorsConst.primary),
              ],
            ),
          );
        }

        return Row(
          children: [
            PopupMenuButton<String>(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              onSelected: (v) {
                if (v == _all) {
                  tp.clearDateFilter();
                  onChanged();
                } else if (v == _custom) {
                  _pickCustom(ctx, tp);
                } else {
                  tp.changeFilterType(v);
                  tp.applyFilters();
                  onChanged();
                }
              },
              itemBuilder: (_) => [
                item(_all, 'All Dates', !on),
                ...tp.filterTypeList.map<PopupMenuItem<String>>(
                      (e) => item(e.toString(), e.toString(), on && tp.filterType == e),
                ),
                item(_custom, 'Custom', on && !isPreset),
              ],
              child: Container(
                padding: const EdgeInsets.fromLTRB(7, 6, 12, 6), // was h10 v8
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30, // was 36
                      height: 30,
                      decoration: BoxDecoration(
                        color: colorsConst.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.calendar_today_outlined,
                          size: 16, color: colorsConst.primary),
                    ),
                    const SizedBox(width: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 120),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15, // was 16
                          fontWeight: FontWeight.w600,
                          color: Color(0xff14151F),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _subText(tp),
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TaskCalendarTab extends StatefulWidget {
  const _TaskCalendarTab();

  @override
  State<_TaskCalendarTab> createState() => _TaskCalendarTabState();
}

class _TaskCalendarTabState extends State<_TaskCalendarTab> {
  static const Color _blue = Color(0xff0B5FB5);
  static const Color _sunBlue = Color(0xff0B5FB5); // same blue as screenshot
  static const Color _dark = Color(0xff14151F);
  static const Color _grey = Color(0xff6B7280);
  static const Color _outGrey = Color(0xff9CA3AF);
  static const Color _mark = Color(0xff7C3AED); // underline for days having tasks

  // screenshot has no underline under task days; set true to show them
  // static const bool _showMarks = false;

  static final List<DateFormat> _fmts = [
    DateFormat('dd-MM-yyyy'),
    DateFormat('dd/MM/yyyy'),
    DateFormat('d-M-yyyy'),
    DateFormat('d/M/yyyy'),
  ];
  static const List<Color> _avatarColors = [
    Color(0xff3B82F6),
    Color(0xffF59E0B),
    Color(0xff10B981),
    Color(0xff8B5CF6),
    Color(0xffEF4444),
    Color(0xff14B8A6),
    Color(0xff0B5FB5),
  ];
  static const List<String> _weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  final Map<String, DateTime?> _dateCache = {};
  late DateTime _month; // first day of visible month
  late DateTime _selected;

  int _cacheVersion = -1;
  Map<int, List<TaskData>> _byDay = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selected = DateTime(now.year, now.month, now.day);
    _month = DateTime(now.year, now.month, 1);
  }

  // ---------------------------------------------------------------- helpers
  DateTime? _parse(String? s) {
    if (s == null) return null;
    final t = s.trim();
    if (t.isEmpty) return null;
    if (_dateCache.containsKey(t)) return _dateCache[t];
    DateTime? r;
    final iso = DateTime.tryParse(t);
    if (iso != null) {
      r = DateTime(iso.year, iso.month, iso.day);
    } else {
      for (final f in _fmts) {
        try {
          r = f.parseStrict(t);
          break;
        } catch (_) {}
      }
    }
    _dateCache[t] = r;
    return r;
  }

  int _key(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  void _rebuildIndex(TaskProvider tp) {
    if (_cacheVersion == tp.dataVersion) return;
    _cacheVersion = tp.dataVersion;
    final map = <int, List<TaskData>>{};
    for (final t in tp.calendarTasks) {
      final d = _parse(t.taskDate);
      if (d == null) continue;
      map.putIfAbsent(_key(d), () => []).add(t);
    }
    _byDay = map;
  }

  String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (p.isEmpty) return "?";
    if (p.length == 1) return p.first[0].toUpperCase();
    return (p[0][0] + p[1][0]).toUpperCase();
  }

  bool _isOverdue(TaskData t) {
    if ((t.statval ?? "").toString().trim() == "Completed") return false;
    final d = _parse(t.taskDate);
    if (d == null) return false;
    final n = DateTime.now();
    return d.isBefore(DateTime(n.year, n.month, n.day));
  }

  Color _dayDotColor(List<TaskData> tasks) {
    bool allDone = true;
    for (final t in tasks) {
      if (_isOverdue(t)) return const Color(0xffE5383B);
      if ((t.statval ?? "").toString().trim() != "Completed") allDone = false;
    }
    return allDone ? const Color(0xff1FAF38) : const Color(0xffF59E0B);
  }

  void _open(TaskData t, TaskProvider tp) {
    Provider.of<HomeProvider>(context, listen: false).panelClose();
    int idx = tp.filterUserData.indexOf(t);
    if (idx < 0) idx = 0;
    utils.navigatePage(
      context,
          () => DashBoard(
        child: TaskDetails(
          data: t,
          isDirect: true,
          coId: "0",
          numberList: const [],
          index: idx,
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ build
  @override
  Widget build(BuildContext context) {
    return Selector<TaskProvider, int>(
      selector: (_, p) => p.dataVersion,
      builder: (ctx, _, __) {
        final tp = ctx.read<TaskProvider>();
        _rebuildIndex(tp);
        final dayTasks = _byDay[_key(_selected)] ?? const <TaskData>[];

        return ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 60),
          children: [
            _calendarCard(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _LegendDot(Color(0xffE5383B), 'Overdue'),
                SizedBox(width: 16),
                _LegendDot(Color(0xffF59E0B), 'Pending'),
                SizedBox(width: 16),
                _LegendDot(Color(0xff1FAF38), 'Completed'),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.zero, // was horizontal 6
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tasks – ${DateFormat('MMMM d').format(_selected)}",
                    style: const TextStyle(
                      fontSize: 18, // was 16
                      fontWeight: FontWeight.w700,
                      color: _dark,
                    ),
                  ),
                  Text(
                    "${dayTasks.length} ${dayTasks.length == 1 ? 'task' : 'tasks'}",
                    style: const TextStyle(fontSize: 15, color: _grey), // was 13
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12), // was 10
            if (dayTasks.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    "No tasks on this day",
                    style: TextStyle(fontSize: 13, color: _grey),
                  ),
                ),
              )
            else
              ...dayTasks.map((t) => _taskTile(t, tp)),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------- calendar card
  Widget _calendarCard() {
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);
    final leading = _month.weekday % 7; // SUN = 0
    final rows = ((leading + daysInMonth) / 7).ceil();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10), // was (10,8,10,12)
      child: Column(
        children: [
          // month header
          SizedBox(
            height: 56,
            child: Row(
              children: [
                const SizedBox(width: 12),
                IconButton(
                  constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: _dark),
                  onPressed: () =>
                      setState(() => _month = DateTime(_month.year, _month.month - 1, 1)),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      DateFormat('MMMM yyyy').format(_month),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _dark,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _dark),
                  onPressed: () =>
                      setState(() => _month = DateTime(_month.year, _month.month + 1, 1)),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xffE9ECF0)),
          const SizedBox(height: 12),

          // weekday labels
          Row(
            children: _weekdays
                .map(
                  (w) => Expanded(
                child: Center(
                  child: Text(
                    w,
                    style: const TextStyle(
                      fontSize: 12, // was 10
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.6,
                      color: Color(0xff374151),
                    ),
                  ),
                ),
              ),
            )
                .toList(),
          ),
          const SizedBox(height: 8),

          // day grid
          for (int r = 0; r < rows; r++)
            Row(
              children: [
                for (int c = 0; c < 7; c++)
                  Expanded(
                    child: _dayCell(
                      DateTime(_month.year, _month.month, 1 - leading + r * 7 + c),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _dayCell(DateTime d) {
    final inMonth = d.month == _month.month;
    final isSel = DateUtils.isSameDay(d, _selected);
    final isToday = DateUtils.isSameDay(d, DateTime.now());

    // dots only for current-month days (other-month days stay quiet)
    final dayTasks = inMonth ? _byDay[_key(d)] : null;
    final hasTasks = dayTasks != null && dayTasks.isNotEmpty;

    Color textColor;
    if (isSel) {
      textColor = Colors.white;
    } else if (!inMonth) {
      textColor = _outGrey.withOpacity(0.6);
    } else if (isToday) {
      textColor = _blue;
    } else {
      textColor = _dark;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() {
        _selected = d;
        if (!inMonth) _month = DateTime(d.year, d.month, 1);
      }),
      child: SizedBox(
        height: 48, // more breathing room between rows
        child: Center(
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isSel ? _blue : Colors.transparent,
              shape: BoxShape.circle,
              border: (isToday && !isSel) ? Border.all(color: _blue, width: 1.5) : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  "${d.day}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: (isSel || isToday) ? FontWeight.w600 : FontWeight.w400,
                    color: textColor,
                  ),
                ),
                if (hasTasks)
                  Positioned(
                    bottom: 2,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSel ? Colors.white : _dayDotColor(dayTasks),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------- task tile
  Widget _taskTile(TaskData t, TaskProvider tp) {
    final names = (t.assignedNames ?? "")
        .toString()
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final first = names.isEmpty ? "-" : names.first;
    final extra = names.length > 1 ? names.length - 1 : 0;
    final avatar = _avatarColors[first.hashCode.abs() % _avatarColors.length];

    final overdue = _isOverdue(t);
    final status = overdue ? "Overdue" : (t.statval ?? "").toString().trim();

    Color bg, fg;
    IconData icon;
    switch (status) {
      case "Completed":
        bg = const Color(0xffE7F6EC);
        fg = const Color(0xff1FAF38);
        icon = Icons.check_circle_outline;
        break;
      case "Started":
        bg = const Color(0xffFFF4E5);
        fg = const Color(0xffD97706);
        icon = Icons.play_circle_outline;
        break;
      case "Overdue":
        bg = const Color(0xffFDECEC);
        fg = const Color(0xffE5383B);
        icon = Icons.error_outline;
        break;
      default: // Assigned & others
        bg = const Color(0xffE8F1FD);
        fg = const Color(0xff1A6FD1);
        icon = Icons.adjust;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _open(t, tp),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12), // was 10
        padding: const EdgeInsets.all(16), // was (14,14,12,14)
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24), // was 20
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20, // was 22
              backgroundColor: avatar,
              child: Text(
                _initials(first),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15, // was 14
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10), // was 12
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.taskTitle ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18, // was 16
                      fontWeight: FontWeight.w600,
                      color: _dark,
                    ),
                  ),
                  const SizedBox(height: 2), // was 4
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: _grey),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          extra > 0 ? "$first  +$extra" : first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, color: _grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 12, color: fg),
                  const SizedBox(width: 4),
                  Text(
                    status.isEmpty ? "-" : _localStatus(status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Donut painter: rounded-cap segments (overdue -> completed -> pending),
/// overdue (red) is centered on top like the design.
/// ---------------------------------------------------------------------------
class _DonutPainter extends CustomPainter {
  final int completed;
  final int pending;
  final int overdue;
  final Color completedColor;
  final Color pendingColor;
  final Color overdueColor;
  final double progress; // 0..1 animation

  _DonutPainter({
    required this.completed,
    required this.pending,
    required this.overdue,
    required this.completedColor,
    required this.pendingColor,
    required this.overdueColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 7.0; // was 12.0
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final total = completed + pending + overdue;

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    // no data -> grey ring
    if (total == 0) {
      canvas.drawArc(
        rect,
        0,
        math.pi * 2,
        false,
        base..color = const Color(0xffE6E8EC),
      );
      return;
    }

    const full = math.pi * 2;
    // small gap so rounded caps don't overlap
    const gap = 0.10;

    final segments = <_Seg>[
      _Seg(overdue, overdueColor),
      _Seg(completed, completedColor),
      _Seg(pending, pendingColor),
    ].where((s) => s.value > 0).toList();

    final onlyOne = segments.length == 1;

    // overdue centered at top
    final overdueSweep = overdue / total * full;
    double start = -math.pi / 2 - (overdue > 0 ? overdueSweep / 2 : 0);

    for (final s in segments) {
      final sweep = s.value / total * full;

      if (onlyOne) {
        canvas.drawArc(
          rect,
          -math.pi / 2,
          full * progress,
          false,
          base..color = s.color,
        );
        break;
      }

      // keep a minimum visible length for tiny segments
      final drawSweep = math.max(sweep - gap, 0.02) * progress;
      canvas.drawArc(
        rect,
        start + gap / 2,
        drawSweep,
        false,
        base..color = s.color,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.completed != completed ||
          old.pending != pending ||
          old.overdue != overdue ||
          old.progress != progress ||
          old.completedColor != completedColor ||
          old.pendingColor != pendingColor ||
          old.overdueColor != overdueColor;
}

class _Seg {
  final int value;
  final Color color;
  _Seg(this.value, this.color);
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xff6B7280))),
      ],
    );
  }
}