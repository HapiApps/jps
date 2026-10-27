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

/// ---------------------------------------------------------------------------
/// PARENT: loads all data ONCE (dropdown data + task list).
/// The child tab (ViewfilterUserData) does NOT call any API in initState.
///
/// PERF CHANGES:
///  * No Selector around the whole screen any more (it rebuilt appbar,
///    overview, tabbar and both tabs on every dataVersion bump).
///  * Calendar tab is built only AFTER the tab animation finishes and is then
///    kept alive -> tab switch is smooth and instant the 2nd time.
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

      // Task list + filter -> ONLY HERE (not in the child)
      taskProvider.initFilterValue(
        true,
        date1: widget.date1,
        date2: widget.date2,
        type: widget.type,
      );
      taskProvider.dataSource = _getDataSource();
      taskProvider.getAllIncompleteTask(
        true,
        date1: widget.date1,
        date2: widget.date2,
        type: widget.type,
      );
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
    var webHeight = MediaQuery.of(context).size.width * 0.5;
    var phoneHeight = MediaQuery.of(context).size.width * 0.95;

    return FocusScope(
      node: _myFocusScopeNode,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
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
                width: kIsWeb ? webHeight : phoneHeight,
                child: Column(
                  children: [
                    DateFilterDropdown(
                      initialType: widget.type,
                      onChanged: (r) {
                        final tp = context.read<TaskProvider>();
                        tp.initFilterValue(true, date1: r.startDate, date2: r.endDate, type: r.type);
                        tp.getAllIncompleteTask(true, date1: r.startDate, date2: r.endDate, type: r.type);
                      },
                    ),
                    const SizedBox(height: 12),
                    RepaintBoundary(
                      child: TaskOverviewCard(
                        title: constValue.taskOverview,
                        totalLabel: constValue.taskCount,
                        completed: 145,
                        pending: 32,
                        overdue: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 50,
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

                            indicatorPadding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),

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
                                    10.width,
                                    CustomText(
                                      text: "Tasks",
                                      isBold: true,
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
                                    10.width,
                                    CustomText(
                                      text: "Calendar",
                                      isBold: true,
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
                              date1: widget.date1, date2: widget.date2, type: widget.type),

                          // Calendar: lazy + keep-alive + own Selector
                          _calendarReady
                              ? _KeepAlive(
                            child: Selector<TaskProvider, int>(
                              selector: (_, p) => p.dataVersion,
                              builder: (ctx, _, __) =>
                                  TaskCalendar(taskPvr: ctx.read<TaskProvider>()),
                            ),
                          )
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

/// ---------------------------------------------------------------------------
/// CHILD TAB: only shows the data. NO API calls here.
/// Lazy loading: first 15 tasks, scroll panna innum 15 15 ah add aagum.
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

  // search / filter / tab maathum bodhu thirumba first 15 ku reset
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
        return const _ChipStyle(
            "Completed", Color(0xffE7F6EC), Color(0xff1FAF38), Icons.check_circle_outline);
      case "Started":
        return const _ChipStyle(
            "Started", Color(0xffE8F1FD), Color(0xff1A6FD1), Icons.play_circle_outline);
      case "Overdue":
        return const _ChipStyle(
            "Overdue", Color(0xffFDECEC), Color(0xffE5383B), Icons.error_outline);
      case "Assigned":
        return const _ChipStyle(
            "Assigned", Color(0xffEEEBFD), Color(0xff5B4BDB), Icons.assignment_ind_outlined);
      default:
        return _ChipStyle(
            s.isEmpty ? "-" : s, const Color(0xffF1F2F4), const Color(0xff6B7280), Icons.circle_outlined);
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

    // Only TaskProvider triggers rebuild.
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
                  const SizedBox(height: 10),
                  /// SEARCH + FILTER + DOWNLOAD
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
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
                            height: 44,
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
                                // prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(13.0),
                                  child: SvgPicture.asset("assets/images/task/task_search_icon.svg", width: 10, height: 10,),
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
                      const SizedBox(width: 8),

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
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: colorsConst.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.tune, color: Colors.white, size: 22),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // DOWNLOAD (Admin -> full report | Employee -> only assigned)x
                      // PopupMenuButton<int>(
                      //   tooltip: "Download",
                      //   color: Colors.white,
                      //   shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(12)),
                      //   onSelected: (v) async {
                      //     if (v == 0) {
                      //       taskProvider.downloadAllOnlyEmpTask(context);
                      //     } else {
                      //       await taskProvider.downloadAllTaskComment(context);
                      //     }
                      //   },
                      //   itemBuilder: (_) => const [
                      //     PopupMenuItem(value: 0, child: Text("Download Tasks")),
                      //     PopupMenuItem(value: 1, child: Text("Download Comments")),
                      //   ],
                      //   child: Container(
                      //     width: 44,
                      //     height: 44,
                      //     decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       shape: BoxShape.circle,
                      //       border: Border.all(color: Colors.grey.shade300),
                      //     ),
                      //     child: const Icon(Icons.download_rounded,
                      //         color: Colors.red, size: 22),
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  /// STATUS TABS
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      children: [
                        _statusTab(taskProvider, "All", ""),
                        _statusTab(taskProvider, "Assigned", "Assigned"),
                        _statusTab(taskProvider, "Started", "Started"),
                        _statusTab(taskProvider, "Completed", "Completed"),
                        _overdueTab(taskProvider),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          taskProvider.isFilter != true
                              ? "Today: ${taskProvider.startDate}"
                              : "",
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        if (taskProvider.isFilter == true)
                          Text(
                            "Total Tasks : ${list.length}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),
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
                                  child:
                                  CircularProgressIndicator(strokeWidth: 2),
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

            // ---------------- local helpers ----------------
            BoxDecoration boxDeco() => BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderClr),
            );

            // label on top + fixed 44px field below
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

            Widget dateBox(String text, VoidCallback onTap) {
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
                          style: const TextStyle(fontSize: 13, color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SvgPicture.asset(assets.calendar2),
                    ],
                  ),
                ),
              );
            }

            // ---- tries several getters, then falls back to the model's toJson/toMap ----
            // (once you know the real field, e.g. (e as UserModel).firstName, use that)
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

            Map? asMap(dynamic e) {
              try {
                final m = e.toJson();
                if (m is Map) return m;
              } catch (_) {}
              try {
                final m = e.toMap();
                if (m is Map) return m;
              } catch (_) {}
              return null;
            }

            // first non-empty value whose key contains any of the hints
            String fromMap(dynamic e, List<String> hints) {
              final m = asMap(e);
              if (m == null) return '';
              for (final h in hints) {
                for (final k in m.keys) {
                  final v = m[k];
                  if (k.toString().toLowerCase().contains(h) &&
                      v != null &&
                      v.toString().trim().isNotEmpty) {
                    return v.toString();
                  }
                }
              }
              return '';
            }

            String empName(dynamic e) {
              final s = pick([
                    () => e.name,
                    () => e.userName,
                    () => e.firstName,
                    () => e.empName,
                    () => e.fullName,
                    () => e.employeeName,
              ]);
              return s.isNotEmpty ? s : fromMap(e, ['name']);
            }

            String empId(dynamic e) {
              final s = pick([
                    () => e.id,
                    () => e.userId,
                    () => e.empId,
                    () => e.employeeId,
              ]);
              if (s.isNotEmpty) return s;
              final m = asMap(e);
              return (m?['id'] ?? m?['user_id'] ?? m?['userId'] ?? '').toString();
            }

            String custName(dynamic e) {
              final s = pick([
                    () => e.companyName,
                    () => e.name,
                    () => e.customerName,
                    () => e.company,
              ]);
              return s.isNotEmpty ? s : fromMap(e, ['company', 'name']);
            }

            // DEBUG: shows what the employee model really contains (check Run/Debug console)
            if (kDebugMode && empProvider.activeEmps.isNotEmpty) {
              final first = empProvider.activeEmps.first;
              debugPrint('EMP SAMPLE -> type: ${first.runtimeType}, map: ${asMap(first)}, '
                  'name: ${empName(first)}, id: ${empId(first)}');
            }

            // ---- uniform dropdown: same height / font / icon / single line ----
            Widget uniformDropdown({
              required String hint,
              required dynamic value,
              required List<DropdownMenuItem<dynamic>> items,
              required ValueChanged<dynamic> onChanged,
              bool hintIsValue = false, // show hint text in black (selected text)
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
                        style: TextStyle(
                          fontSize: 13,
                          color: hintIsValue ? Colors.black : Colors.grey,
                        ),
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

            // find the item that matches current provider value (or null)
            dynamic findWhere(List list, bool Function(dynamic) test) {
              for (final e in list) {
                if (test(e)) return e;
              }
              return null;
            }

            void clearAndClose() {
              taskProvider.initFilterValue(true,
                  date1: widget.date1, date2: widget.date2, type: widget.type);
              _resetPaging();
              Navigator.of(context, rootNavigator: true).pop();
            }

            // ---------------- data ----------------
            final dateRangeItems = taskProvider.filterTypeList.toSet().toList();
            final typeItems = taskProvider.typeList.toSet().toList();

            // ---------------- fields (2 per row) ----------------
            final fields = <Widget>[
              field(
                "From Date",
                dateBox(
                  taskProvider.startDate,
                      () => taskProvider.filterPick(
                    context: context,
                    isStartDate: true,
                    date: taskProvider.startDate,
                  ),
                ),
              ),
              field(
                "To Date",
                dateBox(
                  taskProvider.endDate,
                      () => taskProvider.filterPick(
                    context: context,
                    isStartDate: false,
                    date: taskProvider.endDate,
                  ),
                ),
              ),

              // ---- Select Date Range ----
              field(
                "Select Date Range",
                uniformDropdown(
                  hint: 'Select',
                  value: dateRangeItems.contains(taskProvider.filterType)
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

              // ---- Employee (multi select with checkbox, menu stays open) ----
              if (isAdmin)
                field(
                  "Employee Name",
                  uniformDropdown(
                    hint: taskProvider.assignedId == ""
                        ? "Select employee"
                        : taskProvider.assignedNames,
                    hintIsValue: taskProvider.assignedId != "",
                    value: null,
                    items: empProvider.activeEmps
                        .map<DropdownMenuItem<dynamic>>((e) {
                      return DropdownMenuItem<dynamic>(
                        value: e,
                        enabled: false, // keeps menu open on tap
                        child: StatefulBuilder(
                          builder: (ctx, setMenu) {
                            final checked = taskProvider.assignedId
                                .toString()
                                .split(',')
                                .map((x) => x.trim())
                                .contains(empId(e));
                            void toggle() {
                              taskProvider.selectEmployeeFilter(e);
                              setMenu(() {});
                            }

                            return InkWell(
                              onTap: toggle,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: checked,
                                      onChanged: (_) => toggle(),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(child: itemText(empName(e))),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                    onChanged: (_) {}, // must be non-null so dropdown stays enabled
                  ),
                ),

              // ---- Task type ----
              field(
                constValue.type,
                uniformDropdown(
                  hint: constValue.type,
                  value: findWhere(
                    typeItems,
                        (e) =>
                    e['id'].toString() ==
                        taskProvider.filterTypeId.toString(), // <-- adjust 'id'
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
                    if (v != null) {
                      taskProvider.checkFilterType(v['id']); // <-- adjust if it needs whole map
                    }
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
                    if (v is CustomerModel?) {
                      taskProvider.changeName(v);
                    }
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
              insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                              child: InkWell(
                                onTap: clearAndClose,
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
                              callback: clearAndClose,
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
                                taskProvider.initFilterValue(false);
                                taskProvider.filterList();
                                taskProvider.updateFilteredBeforeSearch(
                                    taskProvider.filterUserData);
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
    );
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
    return _chipButton("Overdue", _overdueOnly, () {
      setState(() => _overdueOnly = true);
      if (taskProvider.statusIds != "") {
        taskProvider.changeFilterStatusTab("");
      }
      _resetPaging();
    });
  }

  Widget _chipButton(String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? colorsConst.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colorsConst.primary : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: CustomText(
            text: text,
              colors: isSelected ? Colors.white : Colors.black,
              isBold: true,
              size: 12,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: s.icon == Icons.circle ? 7 : 11, color: s.fg),
          const SizedBox(width: 4),
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
                size: 14,
                color: ColorsConst.greyText,
                fontWeight: FontWeight.bold,
              ),
          const SizedBox(width: 4),
          Flexible(
            child: CustomText(
              text: text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
                size: 12,
                colors: ColorsConst.greyText,
              isBold: true,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openDetails(data, index),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: overdue ? Colors.red : ColorsConst.appBlack,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              10.height,
              /// title
              Text(
                data.taskTitle ?? "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff14151F),
                ),
              ),
              10.height,
              /// type + company
              if (type.isNotEmpty || company.isNotEmpty)
                Row(
                  children: [
                    if (type.isNotEmpty)
                      _metaItem(Icons.sell_outlined, type),

                    if (type.isNotEmpty && company.isNotEmpty)
                      const SizedBox(width: 12),

                    if (company.isNotEmpty)
                      _metaItem(
                        Icons.apartment,
                        company,
                        customIcon: SvgPicture.asset(
                          'assets/images/task/company_icon.svg',
                          width: 14,
                          height: 14,
                          fit: BoxFit.contain,
                          placeholderBuilder: (context) =>
                          const Icon(Icons.apartment, size: 14),
                        ),
                      ),
                  ],
                ),
              15.height,
              /// assigned + comments + view details
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
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
                  const SizedBox(width: 10),
                  const Text(
                    "View Details",
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// LEFT: title + total
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: _titleGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                              fontSize: 46,
                              fontWeight: FontWeight.w800,
                              color: _dark,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            totalLabel,
                            style: const TextStyle(
                              fontSize: 18,
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
                width: 84,
                height: 84,
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
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
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
          const SizedBox(height: 16),

          /// TILES
          Row(
            children: [
              Expanded(child: _tile("COMPLETED", completed, completedColor)),
              const SizedBox(width: 10),
              Expanded(child: _tile("PENDING", pending, pendingColor)),
              const SizedBox(width: 10),
              Expanded(child: _tile("OVERDUE", overdue, overdueColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tile(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      decoration: BoxDecoration(
        color: _tileBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
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
                    fontWeight: FontWeight.w600,
                    color: _titleGrey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              "$value",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: _dark,
              ),
            ),
          ),
        ],
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
    const stroke = 12.0;
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