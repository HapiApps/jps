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

  @override
  void initState() {
    super.initState();
    if (kDebugMode) debugPrint('>>> ViewTask initState');
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      _myFocusScopeNode.unfocus();
    });

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
    var webHeight = MediaQuery.of(context).size.width * 0.5;
    var phoneHeight = MediaQuery.of(context).size.width * 0.95;

    // Only TaskProvider triggers rebuild. HomeProvider is read once (no listen).
    // Selector: rebuilds ONLY when provider data really changes (dataVersion).
    // The 1-second timer ticker no longer rebuilds the whole task list.
    return Selector<TaskProvider, int>(
        selector: (_, p) => p.dataVersion,
        builder: (context, _, __) {
          final taskProvider = context.read<TaskProvider>();
          final homeProvider = context.read<HomeProvider>();

          return FocusScope(
            node: _myFocusScopeNode,
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
                            final taskProvider = context.read<TaskProvider>();
                            taskProvider.initFilterValue(true, date1: r.startDate, date2: r.endDate, type: r.type);
                            taskProvider.getAllIncompleteTask(true, date1: r.startDate, date2: r.endDate, type: r.type);
                          },
                        ),
                        20.height,
                        TaskOverviewCard(
                          title: constValue.taskOverview,
                           totalLabel: constValue.taskCount,
                           completed: 145,
                           pending: 32,
                           overdue: 15,
                        ),
                        20.height,
                        Container(
                          height: 50,
                          decoration: customDecoration.baseBackgroundDecoration(
                            color: Colors.white,
                            radius: 30,
                          ),
                          child: AnimatedBuilder(
                            animation: tabController,
                            builder: (context, _) {
                              final isTasksActive = tabController.index == 0;
                              final isCalendarActive = tabController.index == 1;

                              return TabBar(
                                controller: tabController,
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
                                          colors: isTasksActive ? Colors.white : Colors.black,
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
                                          colors: isCalendarActive ? Colors.white : Colors.black,
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
                                  // ViewfilterUserData(
                                  //     date1: widget.date1, date2: widget.date2, type: widget.type),
                                  // TaskCalendar(taskPvr: taskProvider),
                                ],
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  _DataSource _getDataSource() {
    List<Appointment> appointments = <Appointment>[];
    return _DataSource(appointments);
  }
}

/// ---------------------------------------------------------------------------
/// CHILD TAB: only shows the data. NO API calls here.
/// Lazy loading: first 15 tasks kaatum, scroll panna innum 15 15 ah add aagum.
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

  // ✅ lazy loading
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 15;
  int _visibleCount = _pageSize;
  bool _isLoadingMore = false;

  @override
  bool get wantKeepAlive => true; // tab switch panna list rebuild / reset aagaadhu

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isLoadingMore) return;
    if (!_scrollController.hasClients) return;

    final total = context.read<TaskProvider>().filterUserData.length;
    if (_visibleCount >= total) return;

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

  // ✅ search / filter / tab maathum bodhu thirumba first 15 ku reset
  void _resetPaging() {
    if (!mounted) return;
    setState(() => _visibleCount = _pageSize);
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  @override
  void dispose() {
    if (kDebugMode) debugPrint('>>> ViewfilterUserData dispose');
    _scrollController.dispose();
    _myFocusScopeNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required for keep-alive
    if (kDebugMode) debugPrint('>>> ViewfilterUserData rebuild');
    var webHeight = MediaQuery.of(context).size.width * 0.5;
    var phoneHeight = MediaQuery.of(context).size.width * 0.95;

    // Only TaskProvider triggers rebuild (Location/Home providers removed).
    // Selector: rebuilds ONLY when provider data really changes (dataVersion).
    // The 1-second timer ticker no longer rebuilds the whole task list.
    return Selector<TaskProvider, int>(
        selector: (_, p) => p.dataVersion,
        builder: (context, _, __) {
          final taskProvider = context.read<TaskProvider>();
          final homeProvider = context.read<HomeProvider>();

          return FocusScope(
            node: _myFocusScopeNode,
            child: Scaffold(
              backgroundColor: const Color(0xffEAEAEA),
              body: taskProvider.viewRefresh == false
                  ? const Loading()
                  : Column(
                children: [
                  10.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: kIsWeb ? webHeight / 1.2 : phoneHeight / 1.4,
                        decoration: customDecoration.baseBackgroundDecoration(
                          radius: 30,
                          color: colorsConst.primary,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: kIsWeb ? webHeight / 1.5 : phoneHeight / 1.8,
                              height: 45,
                              decoration: customDecoration.baseBackgroundDecoration(
                                radius: 30,
                                color: Colors.transparent,
                              ),
                              child: TextFormField(
                                controller: taskProvider.search,
                                cursorColor: colorsConst.primary,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                                onChanged: (value) {
                                  _resetPaging();
                                  Future.microtask(() {
                                    taskProvider.searchTask(value);
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: "Search Name or ${constValue.customer}",
                                  hintStyle: TextStyle(
                                    color: colorsConst.primary,
                                    fontSize: 14,
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: Colors.grey,
                                  ),
                                  suffixIcon: taskProvider.search.text.isNotEmpty
                                      ? IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      taskProvider.search.clear();
                                      taskProvider.searchTask("");
                                      _resetPaging();
                                    },
                                  )
                                      : null,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                      color: colorsConst.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                _myFocusScopeNode.unfocus();
                                // lazy load: filter dialog ku mattum thevai
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
                              child: const Padding(
                                padding: EdgeInsets.all(6.0),
                                child: Icon(
                                  Icons.filter_alt,
                                  size: 27,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            5.width
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Admin -> full report | Employee -> only assigned (same call)
                          InkWell(
                            onTap: () async {
                              taskProvider.downloadAllOnlyEmpTask(context);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.download_rounded,
                                  size: 27,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Task",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () async {
                              await taskProvider.downloadAllTaskComment(context);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.download_rounded,
                                  size: 27,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Comments",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  10.height,
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// STATUS TABS
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _statusTab(taskProvider, "All", ""),
                              _statusTab(taskProvider, "Assigned", "Assigned"),
                              _statusTab(taskProvider, "Started", "Started"),
                              _statusTab(taskProvider, "Completed", "Completed"),
                            ],
                          ),
                        ),
                        10.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: taskProvider.isFilter != true
                                  ? "Today: ${taskProvider.startDate}"
                                  : "",
                            ),
                            if (taskProvider.isFilter == true)
                              Text(
                                "Total Tasks : ${taskProvider.filterUserData.length}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                          ],
                        ),
                        6.height,
                      ],
                    ),
                  ),
                  taskProvider.filterUserData.isEmpty ||
                      (taskProvider.statusId != "" && taskProvider.matched == 0)
                      ? Column(
                    children: [
                      100.height,
                      CustomText(text: "No Task Found", colors: colorsConst.greyClr)
                    ],
                  )
                      : Expanded(
                    child: Builder(builder: (context) {
                      final total = taskProvider.filterUserData.length;
                      final visible = _visibleCount > total ? total : _visibleCount;
                      final hasMore = visible < total;

                      return ListView.builder(
                        controller: _scrollController,
                        physics: const ClampingScrollPhysics(),
                        cacheExtent: 600,
                        addAutomaticKeepAlives: false,
                        itemCount: hasMore ? visible + 1 : visible,
                        itemBuilder: (context, index) {
                          // ✅ last la loader kaatu
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

                          final sortedData = taskProvider.filterUserData;
                          final data = sortedData[index];
                          String timestamp = data.createdTs.toString();
                          DateTime dateTime = DateTime.parse(timestamp);

                          DateTime today = DateTime.now();
                          String headerText;

                          if (dateTime.year == today.year &&
                              dateTime.month == today.month &&
                              dateTime.day == today.day) {
                            headerText = "Today";
                          } else if (dateTime
                              .isAfter(today.subtract(const Duration(days: 1))) &&
                              dateTime.isBefore(today)) {
                            headerText = "Yesterday";
                          } else {
                            headerText =
                            "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                          }

                          String createdBy =
                              "${dateTime.day}/${dateTime.month}/${dateTime.year}";

                          final showDateHeader = index == 0 ||
                              createdBy != getCreatedDate(sortedData[index - 1]);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showDateHeader)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                  child: CustomText(
                                    text: headerText,
                                    colors: colorsConst.greyClr,
                                    size: 13,
                                    isBold: true,
                                  ),
                                ),
                              // ✅ RepaintBoundary -> scroll smooth ah irukka
                              RepaintBoundary(
                                child: KeyedSubtree(
                                  key: ValueKey('task_${data.id}'),
                                  child: _taskCard(data, taskProvider, homeProvider, index),
                                ),
                              ),
                              if (index == visible - 1 && !hasMore) 50.height,
                            ],
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      20.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          70.width,
                          const CustomText(
                            text: 'Filters',
                            colors: Colors.black,
                            size: 16,
                            isBold: true,
                          ),
                          30.width,
                          InkWell(
                            onTap: () {
                              taskProvider.initFilterValue(true,
                                  date1: widget.date1, date2: widget.date2, type: widget.type);
                              _resetPaging();
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                            child: SvgPicture.asset(assets.cancel),
                          )
                        ],
                      ),
                      20.height,
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: "From Date",
                                  colors: colorsConst.greyClr,
                                  size: 12,
                                ),
                                InkWell(
                                  onTap: () {
                                    taskProvider.filterPick(
                                      context: context,
                                      isStartDate: true,
                                      date: taskProvider.startDate,
                                    );
                                  },
                                  child: Container(
                                    height: 30,
                                    width: double.infinity,
                                    decoration: customDecoration.baseBackgroundDecoration(
                                      color: Colors.white,
                                      radius: 5,
                                      borderColor: colorsConst.litGrey,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: CustomText(
                                            text: taskProvider.startDate,
                                          ),
                                        ),
                                        5.width,
                                        SvgPicture.asset(assets.calendar2),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          10.width,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: "To Date",
                                  colors: colorsConst.greyClr,
                                  size: 12,
                                ),
                                InkWell(
                                  onTap: () {
                                    taskProvider.filterPick(
                                      context: context,
                                      isStartDate: false,
                                      date: taskProvider.endDate,
                                    );
                                  },
                                  child: Container(
                                    height: 30,
                                    width: double.infinity,
                                    decoration: customDecoration.baseBackgroundDecoration(
                                      color: Colors.white,
                                      radius: 5,
                                      borderColor: colorsConst.litGrey,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: CustomText(
                                            text: taskProvider.endDate,
                                          ),
                                        ),
                                        5.width,
                                        SvgPicture.asset(assets.calendar2),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      10.height,
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: "Select Date Range",
                                  colors: colorsConst.greyClr,
                                  size: 12,
                                ),
                                Container(
                                  height: 30,
                                  decoration: customDecoration.baseBackgroundDecoration(
                                    radius: 5,
                                    color: Colors.white,
                                    borderColor: colorsConst.litGrey,
                                  ),
                                  child: DropdownButton<String>(
                                    value: taskProvider.filterTypeList
                                        .contains(taskProvider.filterType)
                                        ? taskProvider.filterType
                                        : null,
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    icon: const Icon(Icons.keyboard_arrow_down_outlined),
                                    onChanged: (value) {
                                      if (value != null) {
                                        taskProvider.changeFilterType(value);
                                      }
                                    },
                                    items: taskProvider.filterTypeList
                                        .toSet()
                                        .map<DropdownMenuItem<String>>((list) {
                                      return DropdownMenuItem<String>(
                                        value: list,
                                        child: CustomText(text: "  $list"),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          10.width,
                          Expanded(
                            child: localData.storage.read("role") == "1"
                                ? SearchCustomDropdown(
                              text: "Employee Name",
                              hintText: taskProvider.assignedId == ""
                                  ? ""
                                  : taskProvider.assignedNames,
                              valueList: empProvider.activeEmps,
                              onChanged: (value) {
                                if (value is UserModel) {
                                  taskProvider.selectEmployeeFilter(value);
                                }
                              },
                              width: double.infinity,
                            )
                                : const SizedBox(),
                          ),
                        ],
                      ),
                      10.height,
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: constValue.type,
                                  colors: colorsConst.greyClr,
                                  size: 12,
                                ),
                                MapDropDown(
                                  saveValue: taskProvider.filterTypeId, // CHANGED (was taskProvider.type)
                                  hintText: constValue.type,
                                  isHint: false,
                                  onChanged: (value) {
                                    taskProvider.checkFilterType(value);
                                  },
                                  dropText: 'value',
                                  list: taskProvider.typeList.toSet().toList(),
                                ),
                              ],
                            ),
                          ),
                          10.width,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: constValue.companyName,
                                  colors: colorsConst.greyClr,
                                  size: 12,
                                ),
                                cusPvr.customer.isEmpty
                                    ? const SizedBox(
                                  height: 30,
                                  child: Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                                    : CustomerDropdown(
                                  text: taskProvider.companyName.isEmpty
                                      ? constValue.companyName
                                      : taskProvider.companyName,
                                  isRequired: false,
                                  hintText: false,
                                  employeeList: cusPvr.customer,
                                  onChanged: (CustomerModel? value) {
                                    taskProvider.changeName(value);
                                  },
                                  size: double.infinity,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      20.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomBtn(
                            width: 100,
                            text: 'Clear All',
                            callback: () {
                              taskProvider.initFilterValue(true,
                                  date1: widget.date1, date2: widget.date2, type: widget.type);
                              _resetPaging();
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                            bgColor: Colors.grey.shade200,
                            textColor: Colors.black,
                          ),
                          CustomBtn(
                            width: 100,
                            text: 'Apply Filters',
                            callback: () {
                              taskProvider.initFilterValue(false);
                              taskProvider.filterList();
                              taskProvider.updateFilteredBeforeSearch(taskProvider.filterUserData);
                              _resetPaging();
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                            bgColor: colorsConst.primary,
                            textColor: Colors.white,
                          ),
                        ],
                      ),
                      20.height,
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

  Widget _statusTab(TaskProvider taskProvider, String text, String id) {
    bool isSelected = taskProvider.statusIds == id;

    return InkWell(
      onTap: () {
        taskProvider.changeFilterStatusTab(id);
        _resetPaging();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorsConst.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colorsConst.primary : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _taskCard(
      TaskData data, TaskProvider taskPvr, HomeProvider homeProvider, int index) {
    Color priorityBg;
    Color priorityTextColor;
    String priorityText;
    switch (data.level.toString()) {
      case "High":
        priorityBg = const Color(0xffFEF2F2);
        priorityTextColor = Colors.red;
        priorityText = "High";
        break;
      case "Normal":
        priorityBg = const Color(0xffF2F6FE);
        priorityTextColor = const Color(0xff1A85DB);
        priorityText = "Normal";
        break;
      case "Immediate":
        priorityBg = const Color(0xffFBF2FE);
        priorityTextColor = const Color(0xffB35CFF);
        priorityText = "Immediate";
        break;
      default:
        priorityBg = const Color(0xffF2F6FE);
        priorityTextColor = Colors.grey;
        priorityText = "Normal";
    }

    final formattedNames = formatAssignedNames(data.assignedNames);
    String fullName = formattedNames.split('+').first.trim();
    String displayName =
    fullName.length > 15 ? "${fullName.substring(0, 15)}..." : fullName;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
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
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE + wages + edit
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ExpandableText(
                            text: data.taskTitle ?? "",
                            trimLines: 2,
                            fontSize: 14,
                            isBold: true,
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            utils.navigatePage(
                              context,
                                  () => DashBoard(
                                child: EditTask(
                                  data: data,
                                  isDirect: false,
                                  numberList: [],
                                ),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ),
                    5.height,
                    if (data.taskDesc != null && data.taskDesc!.trim().isNotEmpty)
                      CustomText(
                        text: data.taskDesc!,
                        size: 12,
                      ),
                    5.height,
                    /// ASSIGNED USERS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // GestureDetector instead of TapGestureRecognizer
                        // (no recognizer created on every build -> no leak)
                        Flexible(
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Assigned User"),
                                      content: Text(fullName),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("Close"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: RichText(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: displayName,
                                      style: const TextStyle(
                                        color: Color(0xff007AAE),
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (formattedNames.contains('+'))
                                      TextSpan(
                                        text: " +${formattedNames.split('+').last.trim()}",
                                        style: const TextStyle(
                                          color: Color(0xff007AAE),
                                          fontSize: 11,
                                        ),
                                      ),
                                    if (formattedNames.contains('+'))
                                      const TextSpan(
                                        text: " oths",
                                        style: TextStyle(
                                          color: Color(0xff007AAE),
                                          fontSize: 11,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            )),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 2, 0),
                          child: Container(height: 16, width: 2, color: Colors.grey),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _statusChip(
                              data.statval ?? "",
                              data.statval == "Completed"
                                  ? const Color(0xff1FAF38)
                                  : const Color(0xff007AAE),
                              Colors.white,
                            ),
                            2.width,
                            Container(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: priorityBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.circle, size: 8, color: priorityTextColor),
                                  const SizedBox(width: 6),
                                  CustomText(
                                    text: priorityText,
                                    colors: priorityTextColor,
                                    size: 13,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(thickness: 2),
                    ///Comment for JPS
                    Row(
                      children: [
                        if ((data.projectName ?? "").trim().isNotEmpty)
                          _infoBlock("Company", data.projectName ?? ""),
                        const Spacer(),
                        WagesAddWorkDetails(
                          taskId: data.id.toString(),
                        ),
                      ],
                    ),
                    10.height,
                    if (data.name.toString() != "null" && data.name.toString() != "")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: "Customer",
                                size: 12,
                                colors: const Color(0xff7E7E7E),
                                isBold: true,
                              ),
                              CustomText(
                                text: data.name ?? '',
                                size: 14,
                                isBold: true,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              CustomText(text: data.phoneNo ?? '', size: 14),
                              5.width,
                              GestureDetector(
                                onTap: () {
                                  utils.makingPhoneCall(ph: data.phoneNo.toString());
                                },
                                child: const Icon(Icons.call, color: Colors.blue),
                              )
                            ],
                          )
                        ],
                      ),

                    /// Task type + Task date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoBlock("Task type", data.type ?? ""),
                        _infoBlock("Task Date", data.taskDate ?? ""),
                      ],
                    ),
                    const Divider(thickness: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(backgroundColor: data.expenseReportCount.toString()=="0"?colorsConst.red2:colorsConst.green2,radius: 4,),
                            2.width,
                            CustomText(text: "Expense",colors: data.expenseReportCount.toString()=="0"?colorsConst.red2:colorsConst.green2,isItalic: true,),
                            10.width,
                            TextButton(
                                onPressed: (){
                                  _myFocusScopeNode.unfocus();
                                  utils.navigatePage(context, ()=> DashBoard(child: CreateExpense(taskId: data.id.toString(),data: data,coId: "",numberList: const [], companyName: data.projectName.toString(), type: data.type.toString(), desc: data.taskTitle.toString(),
                                      date: data.taskDate.toString())));
                                },
                                child: CustomText(text: "Add Expense",colors: colorsConst.blueClr,)),
                          ],
                        ),
                      ],
                    ),    // only for aci

                    const Divider(thickness: 2,),

                    /// CREATED / UPDATED
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomText(
                                  text: "Created:  ",
                                  colors: const Color(0xff7E7E7E),
                                  size: 13,
                                  isBold: true,
                                ),
                                CustomText(
                                  text: data.creator.toString(),
                                  colors: Colors.black,
                                  size: 13,
                                  isBold: true,
                                ),
                              ],
                            ),
                            CustomText(
                              text: formatDateTime(data.createdTs.toString()),
                              colors: Colors.black,
                              size: 12,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomText(
                                  text: "Updated :  ",
                                  colors: const Color(0xff7E7E7E),
                                  size: 13,
                                  isBold: true,
                                ),
                                CustomText(
                                  text: data.updatedByName == null
                                      ? "-"
                                      : data.updatedByName.toString(),
                                  colors: Colors.black,
                                  size: 13,
                                  isBold: true,
                                ),
                              ],
                            ),
                            CustomText(
                              text: formatDateTime(data.updatedTs.toString()),
                              colors: Colors.black,
                              size: 12,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(thickness: 2),

                    /// COMMENTS
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.message,
                                color: Colors.red,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                (data.commentCount ?? "").toString().isNotEmpty
                                    ? "(${data.commentCount}) - "
                                    : "No comments",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Expanded(
                                child: RichText(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: data.lastComment ?? "",
                                      ),
                                      if (data.lastCommentBy != null &&
                                          data.lastCommentBy.toString().trim().isNotEmpty)
                                        TextSpan(
                                          text: " (last comment by ${data.lastCommentBy})",
                                          style: TextStyle(
                                            color: Colors.red.shade900,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
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
                              Provider.of<TaskProvider>(
                                context,
                                listen: false,
                              ).getAllTask(false);
                            }
                          },
                          child: const Icon(
                            Icons.message_outlined,
                            size: 20,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget taskButton(TaskProvider taskPvr, String id, String status) {
    switch (status) {
      case "Complete":
        return Row(
          children: [
            CustomLoadingButton(
                callback: () async {
                  taskPvr.changeStatusT("Completed");
                  taskPvr.changeStatus({"id": "3", "value": "Completed"});
                  taskPvr.updateChanges();
                  await taskPvr.insertTaskLogHistory(context, id: id, level: "Completed");
                },
                isLoading: false,
                backgroundColor: colorsConst.pink,
                radius: 50,
                height: 30,
                width: 70,
                text: "Start"),
            10.width,
            CustomLoadingButton(
                callback: () {
                  taskPvr.insertTaskLogHistory(context, id: id, level: "Complete");
                },
                isLoading: false,
                backgroundColor: Colors.green,
                radius: 50,
                height: 30,
                width: 100,
                text: "Complete"),
          ],
        );
      case "Pending":
        return Row(
          children: [
            CustomLoadingButton(
                callback: () {
                  taskPvr.insertTaskLogHistory(context, id: id, level: "Start");
                },
                isLoading: false,
                backgroundColor: colorsConst.pink,
                radius: 50,
                height: 30,
                width: 70,
                text: "Start"),
            10.width,
            CustomLoadingButton(
                callback: () {
                  taskPvr.insertTaskLogHistory(context, id: id, level: "Complete");
                },
                isLoading: false,
                backgroundColor: Colors.green,
                radius: 50,
                height: 30,
                width: 100,
                text: "Complete"),
          ],
        );
      case "Start":
        return Row(
          children: [
            CustomLoadingButton(
              callback: () {
                taskPvr.insertTaskLogHistory(context, id: id, level: "Hold");
              },
              isLoading: false,
              backgroundColor: Colors.blue,
              radius: 50,
              height: 30,
              width: 70,
              text: "Hold",
            ),
            10.width,
            CustomLoadingButton(
                callback: () {
                  taskPvr.insertTaskLogHistory(context, id: id, level: "Complete");
                },
                isLoading: false,
                backgroundColor: Colors.green,
                radius: 50,
                height: 30,
                width: 100,
                text: "Complete"),
          ],
        );
      case "Hold":
        return CustomLoadingButton(
            callback: () {
              taskPvr.insertTaskLogHistory(context, id: id, level: "Start");
            },
            isLoading: false,
            backgroundColor: colorsConst.red1,
            radius: 50,
            height: 30,
            width: 100,
            text: "Resume");
      case "Completed":
        return const Text(
          "✓ Task Completed",
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        );
      default:
        return const SizedBox();
    }
  }

  String formatDateTime(String? date) {
    if (date == null || date.isEmpty) return "";
    final parsedDate = DateTime.tryParse(date);
    if (parsedDate == null) return "";
    return DateFormat('dd-MM-yyyy h:mm a').format(parsedDate);
  }

  String formatAssignedNames(String? names) {
    if (names == null || names.trim().isEmpty) return "";

    List<String> nameList = names.split(',').map((e) => e.trim()).toList();

    if (nameList.length <= 4) {
      return nameList.join(', ');
    }

    final firstFour = nameList.take(4).join(', ');
    final remainingCount = nameList.length - 4;

    return "$firstFour +$remainingCount";
  }

  Widget _statusChip(String text, Color bg, Color txt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomText(
        text: text,
        colors: txt,
        size: 11,
      ),
    );
  }

  /// GoogleFonts.lato REMOVED -> uses bundled 'Lato' font (no runtime font load)
  Widget _infoBlock(String title, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$title\n",
            style: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 12,
              color: Color(0xff7E7E7E),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String getCreatedDate(data) {
    final timestamp = data.createdTs.toString();
    final dateTime = DateTime.parse(timestamp);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
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
