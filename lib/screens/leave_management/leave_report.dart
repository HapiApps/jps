import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:master_code/source/constant/language_model.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:master_code/view_model/employee_provider.dart';
import 'package:provider/provider.dart';
import '../../component/animated_button.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_text.dart';
import '../../component/map_dropdown.dart';
import '../../model/leave/leave_model.dart';
import '../../model/user_model.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/local_data.dart';
import '../../source/styles/decoration.dart';
import '../../view_model/home_provider.dart';
import '../../view_model/leave_provider.dart';
import '../common/dashboard.dart';
import '../common/home_page.dart';
import 'apply_leave.dart';
import 'leave_details.dart';

class ViewMyLeaves extends StatefulWidget {
  final String? date1;
  final String? date2;
  final bool? isDirect;
  const ViewMyLeaves({super.key, this.date1, this.date2, this.isDirect});

  @override
  State<ViewMyLeaves> createState() => _ViewMyLeavesState();
}

class _ViewMyLeavesState extends State<ViewMyLeaves>
    with SingleTickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();
  late TabController _tabController; // manual controller (replaces DefaultTabController)

  // ===== HOME RANGE (dd-MM-yyyy) =====
  String _rangeD1 = "";
  String _rangeD2 = "";
  String? _rangeType;
  static final DateFormat _apiFmt = DateFormat('dd-MM-yyyy');

  /// "yyyy-MM-dd" / "yyyy-MM-dd HH:mm:ss" / "dd-MM-yyyy" -> "dd-MM-yyyy"
  String _toApi(String? v) {
    final s = (v ?? "").trim();
    if (s.isEmpty || s == "null") return "";
    if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(s)) return s;
    if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(s)) {
      final d = DateTime.tryParse(s.substring(0, 10));
      if (d != null) return _apiFmt.format(d);
    }
    return "";
  }

  /// Priority: Home page range -> widget dates -> today
  void _resolveRange() {
    final home = Provider.of<HomeProvider>(context, listen: false);
    String d1 = _toApi(home.startDate);
    String d2 = _toApi(home.endDate);
    String? type = home.type;

    if (d1.isEmpty) {
      d1 = _toApi(widget.date1);
      d2 = _toApi(widget.date2);
      type = null;
    }
    if (d1.isEmpty) {
      d1 = _apiFmt.format(DateTime.now());
      type = "Today";
    }
    if (d2.isEmpty) d2 = d1;

    _rangeD1 = d1;
    _rangeD2 = d2;
    _rangeType = type;
  }

  @override
  void initState() {
    super.initState();

    final leaveProvider = Provider.of<LeaveProvider>(context, listen: false);
    _resolveRange();

    // start on whichever tab the provider says (set by LeaveSummaryCard / CheckAttendance taps)
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: leaveProvider.viewLeaveTabIndex,
    );

    // FIX: munnadi dailys() + initDate(today, "yyyy-MM-dd") + daily() ->
    // eppovum TODAY data mattum (format-um thappu). Ippo Home range.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      if (localData.storage.read("role") != "1") {
        leaveProvider.getLeaveTypes();
      }
      leaveProvider.applyHomeRange(_rangeD1, _rangeD2, label: _rangeType);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _myFocusScopeNode.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // DATE HELPERS
  // ---------------------------------------------------------------
  DateTime onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Leave-oda (startDate - endDate) filter range-oda overlap aaguthaa?
  bool leaveInRange(LeaveModel e, DateTime? fs, DateTime? fe) {
    if (fs == null || fe == null) return false;
    final ls = parseLeaveDate(e.startDate?.toString());
    final le = parseLeaveDate(e.endDate?.toString()) ?? ls;
    if (ls == null || le == null) return false;
    return !onlyDate(ls).isAfter(onlyDate(fe)) &&
        !onlyDate(le).isBefore(onlyDate(fs));
  }

  /// Leave apply panna (created) date filter range-kulla irukka?
  bool createdInRange(LeaveModel e, DateTime? fs, DateTime? fe) {
    if (fs == null || fe == null) return false;
    final c = parseCreatedDate(e.createdTs?.toString());
    if (c == null) return false;
    return !onlyDate(c).isBefore(onlyDate(fs)) &&
        !onlyDate(c).isAfter(onlyDate(fe));
  }

  /// ✅ NEW -> OLD sort (latest apply panna leave mela varum)
  /// createdTs same-a irundha, leave startDate vachi latest mela varum
  List<LeaveModel> sortNewToOld(List<LeaveModel> list) {
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    final sorted = List<LeaveModel>.from(list);
    sorted.sort((a, b) {
      final ca = parseCreatedDate(a.createdTs?.toString()) ?? epoch;
      final cb = parseCreatedDate(b.createdTs?.toString()) ?? epoch;
      final c = cb.compareTo(ca); // descending
      if (c != 0) return c;

      final sa = parseLeaveDate(a.startDate?.toString()) ?? epoch;
      final sb = parseLeaveDate(b.startDate?.toString()) ?? epoch;
      return sb.compareTo(sa); // descending
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    var webWidth = MediaQuery.of(context).size.width * 0.7;
    var phoneWidth = MediaQuery.of(context).size.width * 0.95;

    // ===== PAGE CONTENT WIDTH (ella section-um idhe width) =====
    // Web: max 960, screen-oda 70% -> center-la, rendu pakkamum equal space
    // Phone: 12dp left + right padding
    final double screenW = MediaQuery.of(context).size.width;
    final double contentW = kIsWeb
        ? math.min(screenW * 0.7, 960).toDouble()
        : screenW - 24;

    return Consumer2<LeaveProvider, HomeProvider>(
        builder: (context, levProvider, homeProvider, _) {
          // If this page is already alive in the navigation stack,
          // initState() will NOT re-run when user taps "On Leave" / "Leave Applied" again.
          // So force the tab to match the provider's requested index on every rebuild.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _tabController.index != levProvider.viewLeaveTabIndex) {
              _tabController.animateTo(levProvider.viewLeaveTabIndex);
            }
          });
          return FocusScope(
            node: _myFocusScopeNode,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: colorsConst.bacColor,
                appBar: PreferredSize(
                  preferredSize: Size(300, 50),
                  child: CustomAppbar(
                    text: localData.storage.read("role") == "1"
                        ? "${constValue.leaveReport}"
                        : "${constValue.Myleave}",
                    callback: () {
                      if (localData.storage.read("role") == "1" &&
                          widget.isDirect == false) {
                        levProvider.changePage(context);
                      } else {
                        homeProvider.updateIndex(0);
                        utils.navigatePage(
                            context, () => const DashBoard(child: HomePage()));
                      }
                      _myFocusScopeNode.unfocus();
                    },
                    isButton: localData.storage.read("role") != "1" ? true : false,
                    buttonCallback: () {
                      _myFocusScopeNode.unfocus();
                      utils.navigatePage(
                          context,
                              () => ApplyLeave(
                              date1: _rangeD1, date2: _rangeD2));
                    },
                  ),
                ),
                body: PopScope(
                  canPop: localData.storage.read("role") == "1" &&
                      widget.isDirect == false
                      ? false
                      : true,
                  onPopInvoked: (bool pop) async {
                    if (localData.storage.read("role") == "1" &&
                        widget.isDirect == false) {
                      levProvider.changePage(context);
                    } else {
                      homeProvider.updateIndex(0);
                      utils.navigatePage(
                          context, () => const DashBoard(child: HomePage()));
                    }
                    _myFocusScopeNode.unfocus();
                  },
                  // Center + fixed width -> search, banner, tabs, lists
                  // ellam ore alignment-la (web-la edge-ku ottaama)
                  child: Center(
                    child: SizedBox(
                      width: contentW,
                      child: Column(
                        children: [
                          20.height,

                          /// SEARCH BAR
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Container(
                              width: contentW,
                              decoration: customDecoration.baseBackgroundDecoration(
                                radius: 30,
                                color: colorsConst.primary,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  /// SEARCH FIELD
                                  Container(
                                    // filter icon (~48dp) + gap pothum
                                    width: contentW - 60,
                                    height: 45,
                                    decoration:
                                    customDecoration.baseBackgroundDecoration(
                                      radius: 20,
                                      color: Colors.transparent,
                                    ),
                                    child: TextFormField(
                                      controller: levProvider.search2,
                                      cursorColor: colorsConst.primary,
                                      onChanged: (value) {
                                        levProvider.searchReport(value.toString());
                                      },
                                      decoration: InputDecoration(
                                        hintText: "Search for Employees",
                                        hintStyle: TextStyle(
                                          color: colorsConst.primary,
                                          fontSize: 14,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.search,
                                            color: Colors.grey),
                                        suffixIcon: levProvider.search2.text.isNotEmpty
                                            ? GestureDetector(
                                            onTap: () {
                                              levProvider.search2.clear();
                                              levProvider.searchReport("");
                                            },
                                            child: Container(
                                                width: 10,
                                                height: 10,
                                                color: Colors.transparent,
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets.all(8.0),
                                                  child: SvgPicture.asset(
                                                      assets.cancel2),
                                                )))
                                            : null,
                                        errorStyle: const TextStyle(
                                          fontSize: 12.0,
                                          height: 0.20,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide:
                                            BorderSide(color: colorsConst.primary),
                                            borderRadius: BorderRadius.circular(30)),
                                        focusedErrorBorder: OutlineInputBorder(
                                            borderSide:
                                            BorderSide(color: colorsConst.primary),
                                            borderRadius: BorderRadius.circular(30)),
                                        contentPadding:
                                        const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                        errorBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.transparent),
                                            borderRadius: BorderRadius.circular(30)),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide:
                                            BorderSide(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(30)),
                                      ),
                                    ),
                                  ),

                                  /// FILTER ICON
                                  InkWell(
                                    onTap: () {
                                      _myFocusScopeNode.unfocus();
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Consumer2<LeaveProvider,
                                              EmployeeProvider>(
                                            builder:
                                                (context, levPvr, empProvider, _) {
                                              return AlertDialog(
                                                actions: [
                                                  SizedBox(
                                                    width:
                                                    kIsWeb ? webWidth : phoneWidth,
                                                    child: Column(
                                                      children: [
                                                        20.height,
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
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
                                                                Navigator.of(context,
                                                                    rootNavigator:
                                                                    true)
                                                                    .pop();
                                                              },
                                                              child: SvgPicture.asset(
                                                                  assets.cancel),
                                                            )
                                                          ],
                                                        ),
                                                        20.height,
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                CustomText(
                                                                  text: "From Date",
                                                                  colors: colorsConst
                                                                      .greyClr,
                                                                  size: 12,
                                                                ),
                                                                InkWell(
                                                                  onTap: () {
                                                                    levPvr.datePick(
                                                                      context: context,
                                                                      isStartDate: true,
                                                                      date: levPvr
                                                                          .startDate,
                                                                    );
                                                                  },
                                                                  child: Container(
                                                                    height: 30,
                                                                    width: kIsWeb
                                                                        ? webWidth / 2.7
                                                                        : phoneWidth /
                                                                        2.7,
                                                                    decoration: customDecoration
                                                                        .baseBackgroundDecoration(
                                                                      color:
                                                                      Colors.white,
                                                                      radius: 5,
                                                                      borderColor:
                                                                      colorsConst
                                                                          .litGrey,
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                      children: [
                                                                        CustomText(
                                                                            text: levPvr
                                                                                .startDate),
                                                                        5.width,
                                                                        SvgPicture.asset(
                                                                            assets
                                                                                .calendar2),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                CustomText(
                                                                  text: "To Date",
                                                                  colors: colorsConst
                                                                      .greyClr,
                                                                  size: 12,
                                                                ),
                                                                InkWell(
                                                                  onTap: () {
                                                                    levPvr.datePick(
                                                                      context: context,
                                                                      isStartDate:
                                                                      false,
                                                                      date: levPvr
                                                                          .endDate,
                                                                    );
                                                                  },
                                                                  child: Container(
                                                                    height: 30,
                                                                    width: kIsWeb
                                                                        ? webWidth / 2.7
                                                                        : phoneWidth /
                                                                        2.7,
                                                                    decoration: customDecoration
                                                                        .baseBackgroundDecoration(
                                                                      color:
                                                                      Colors.white,
                                                                      radius: 5,
                                                                      borderColor:
                                                                      colorsConst
                                                                          .litGrey,
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                      children: [
                                                                        CustomText(
                                                                            text: levPvr
                                                                                .endDate),
                                                                        5.width,
                                                                        SvgPicture.asset(
                                                                            assets
                                                                                .calendar2),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        10.height,
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                          children: [
                                                            if (localData.storage
                                                                .read("role") ==
                                                                "1")
                                                              Column(
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                                children: [
                                                                  CustomText(
                                                                    text:
                                                                    "Employee Name",
                                                                    colors: colorsConst
                                                                        .greyClr,
                                                                    size: 12,
                                                                  ),
                                                                  EmployeeDropdown(
                                                                    callback: () {
                                                                      empProvider
                                                                          .getAllUsers();
                                                                    },
                                                                    text: levPvr.userName ==
                                                                        ""
                                                                        ? "Name"
                                                                        : levPvr
                                                                        .userName,
                                                                    employeeList:
                                                                    empProvider
                                                                        .filterUserData,
                                                                    onChanged:
                                                                        (UserModel?
                                                                    value) {
                                                                      levPvr
                                                                          .selectUserReport(
                                                                          value!);
                                                                    },
                                                                    size: kIsWeb
                                                                        ? webWidth / 2.7
                                                                        : phoneWidth /
                                                                        2.7,
                                                                  ),
                                                                ],
                                                              ),
                                                            Padding(
                                                              padding:
                                                              EdgeInsets.fromLTRB(
                                                                  0,
                                                                  empProvider
                                                                      .filterUserData
                                                                      .isEmpty
                                                                      ? 20
                                                                      : 0,
                                                                  0,
                                                                  0),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                                children: [
                                                                  CustomText(
                                                                    text:
                                                                    "Select Date Range",
                                                                    colors: colorsConst
                                                                        .greyClr,
                                                                    size: 12,
                                                                  ),
                                                                  Container(
                                                                    height: 40,
                                                                    width: kIsWeb
                                                                        ? webWidth / 2.7
                                                                        : phoneWidth /
                                                                        2.7,
                                                                    decoration: customDecoration
                                                                        .baseBackgroundDecoration(
                                                                      radius: 5,
                                                                      color:
                                                                      Colors.white,
                                                                      borderColor:
                                                                      colorsConst
                                                                          .litGrey,
                                                                    ),
                                                                    child:
                                                                    DropdownButton(
                                                                      iconEnabledColor:
                                                                      colorsConst
                                                                          .greyClr,
                                                                      isExpanded: true,
                                                                      underline:
                                                                      const SizedBox(),
                                                                      icon: const Icon(
                                                                          Icons
                                                                              .keyboard_arrow_down_outlined),
                                                                      value: levPvr
                                                                          .typeReport,
                                                                      onChanged:
                                                                          (value) {
                                                                        levPvr.changeRrtType(
                                                                            value,
                                                                            localData
                                                                                .storage
                                                                                .read(
                                                                                "id"),
                                                                            localData
                                                                                .storage
                                                                                .read(
                                                                                "role"),
                                                                            false);
                                                                      },
                                                                      items: levPvr
                                                                          .typeList
                                                                          .map((list) {
                                                                        return DropdownMenuItem(
                                                                          value: list,
                                                                          child:
                                                                          CustomText(
                                                                            text:
                                                                            "  $list",
                                                                            colors: Colors
                                                                                .black,
                                                                            isBold:
                                                                            false,
                                                                          ),
                                                                        );
                                                                      }).toList(),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        20.height,
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                          children: [
                                                            CustomBtn(
                                                              width: 100,
                                                              text: 'Clear All',
                                                              callback: () {
                                                                // Clear All -> TODAY illa, Home range-ku thirumba
                                                                Navigator.of(context,
                                                                    rootNavigator:
                                                                    true)
                                                                    .pop();
                                                                levPvr.applyHomeRange(
                                                                    _rangeD1,
                                                                    _rangeD2,
                                                                    label:
                                                                    _rangeType);
                                                              },
                                                              bgColor:
                                                              Colors.grey.shade200,
                                                              textColor: Colors.black,
                                                            ),
                                                            CustomBtn(
                                                              width: 100,
                                                              text: 'Apply Filters',
                                                              callback: () {
                                                                levPvr.isFilterApplied =
                                                                true;
                                                                levPvr.changeFilter();
                                                                levPvr.getLeaveReport(
                                                                    levPvr.filter);
                                                                Navigator.of(context,
                                                                    rootNavigator:
                                                                    true)
                                                                    .pop();
                                                              },
                                                              bgColor:
                                                              colorsConst.primary,
                                                              textColor: Colors.white,
                                                            ),
                                                          ],
                                                        ),
                                                        20.height,
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.filter_alt,
                                        size: 27,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  5.width,
                                ],
                              ),
                            ),
                          ),

                          /// ===== DATE RANGE BANNER (enna range-ku data) =====
                          _rangeBanner(levProvider, contentW),
                          6.height,

                          /// TAB BAR
                          TabBar(
                            controller: _tabController,
                            labelColor: Colors.black,
                            indicatorColor: colorsConst.primary,
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.grey.shade300,
                            tabs: [
                              Tab(text: "Leave Created "),
                              Tab(text: "Employees On Leave"),
                            ],
                          ),

                          /// TAB VIEW
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                /// ===============================
                                /// TAB 1 – LEAVE CREATED
                                /// ===============================
                                Builder(
                                  builder: (context) {
                                    final DateTime? fs =
                                    parseLeaveDate(levProvider.startDate);
                                    final DateTime? fe =
                                    parseLeaveDate(levProvider.endDate);

                                    final List<LeaveModel> applied;
                                    final List<LeaveModel> approved;

                                    if (levProvider.isFilterApplied) {
                                      // FIX: leave date match OR apply panna (created) date match,
                                      // rendu-la edhu irundhaalum Applied tab-la show aagum
                                      applied = levProvider.myLevSearch
                                          .where((e) =>
                                      leaveInRange(e, fs, fe) ||
                                          createdInRange(e, fs, fe))
                                          .toList();
                                    } else {
                                      applied = levProvider.myLevSearch;
                                    }

                                    approved = levProvider.myLevSearch
                                        .where((e) => leaveInRange(e, fs, fe))
                                        .toList();

                                    return DefaultTabController(
                                      length: 3,
                                      child: Column(
                                        children: [
                                          /// SUB TAB BAR
                                          TabBar(
                                            labelColor: Colors.black,
                                            indicatorColor: colorsConst.primary,
                                            indicatorSize: TabBarIndicatorSize.tab,
                                            dividerColor: Colors.grey.shade200,
                                            tabs: [
                                              Tab(text: "Applied"),
                                              Tab(text: "Approved"),
                                              Tab(text: "Rejected"),
                                            ],
                                          ),

                                          Expanded(
                                            child: TabBarView(
                                              children: [
                                                /// APPLIED (status 0)
                                                leaveStatusList(applied, "0",
                                                    levProvider.isLoading),

                                                /// APPROVED (status 1)
                                                leaveStatusList(approved, "1",
                                                    levProvider.isLoading),

                                                /// REJECTED (status 2)
                                                leaveStatusList(approved, "2",
                                                    levProvider.isLoading),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                /// ===============================
                                /// TAB 2 – EMPLOYEE ON LEAVE
                                /// ===============================
                                Builder(
                                  builder: (context) {
                                    // Loading first
                                    if (levProvider.isLoading) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }

                                    final DateTime? fs =
                                    parseLeaveDate(levProvider.startDate);
                                    final DateTime? fe =
                                    parseLeaveDate(levProvider.endDate);

                                    // only APPROVED leaves count as "On Leave"
                                    final List<LeaveModel> onLeaveToday = sortNewToOld(levProvider
                                        .myLevSearch
                                        .where((e) =>
                                    e.status.toString() == "1" &&
                                        leaveInRange(e, fs, fe))
                                        .toList());

                                    if (onLeaveToday.isEmpty) {
                                      return const Center(
                                          child: Text("No Employees On Leave in this range"));
                                    }
                                    return ListView.builder(
                                      padding: const EdgeInsets.symmetric(vertical: 10), // side padding parent-la
                                      itemCount: onLeaveToday.length,
                                      itemBuilder: (context, index) {
                                        final data = onLeaveToday[index];
                                        return leaveCard(data,
                                            showButtons: false, showCancelOnly: true);
                                      },
                                    );
                                  },
                                ),
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
        });
  }

  // ---------------------------------------------------------------
  // DATE RANGE BANNER
  // ---------------------------------------------------------------
  /// "24 Nov 2026 (Tue)" | "01 – 24 Nov 2026" | "28 Oct – 24 Nov 2026"
  String _prettyRange(String a, String b) {
    DateTime? p(String s) {
      try {
        return _apiFmt.parseStrict(s);
      } catch (_) {
        return null;
      }
    }

    final s = p(a);
    final e = p(b) ?? s;
    if (s == null || e == null) return "-";
    if (DateUtils.isSameDay(s, e)) {
      return DateFormat('dd MMM yyyy (EEE)').format(s);
    }
    if (s.year == e.year) {
      if (s.month == e.month) {
        return "${DateFormat('dd').format(s)} – ${DateFormat('dd MMM yyyy').format(e)}";
      }
      return "${DateFormat('dd MMM').format(s)} – ${DateFormat('dd MMM yyyy').format(e)}";
    }
    return "${DateFormat('dd MMM yy').format(s)} – ${DateFormat('dd MMM yy').format(e)}";
  }

  int _rangeDayCount(String a, String b) {
    try {
      final s = _apiFmt.parseStrict(a);
      final e = b.isEmpty ? s : _apiFmt.parseStrict(b);
      return e.difference(s).inDays.abs() + 1;
    } catch (_) {
      return 1;
    }
  }

  Widget _rangeBanner(LeaveProvider lp, double width) {
    final Color primary = colorsConst.primary;
    final String label = lp.isFilterApplied
        ? (lp.typeReport?.toString() ?? "Custom")
        : (_rangeType != null && lp.typeList.contains(_rangeType)
        ? _rangeType!
        : "Custom");
    final int days = _rangeDayCount(lp.startDate, lp.endDate);

    return Container(
      width: width,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Color.alphaBlend(primary.withOpacity(0.07), Colors.white),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(Icons.calendar_month_rounded, size: 16, color: primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SHOWING LEAVES · ${label.toUpperCase()}"
                      "${days > 1 ? ' · $days DAYS' : ''}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _prettyRange(lp.startDate, lp.endDate),
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xff14151F),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (lp.isFilterApplied)
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Filtered",
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  DateTime? parseCreatedDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      // yyyy-MM-dd HH:mm:ss
      return DateTime.parse(value);
    } catch (e) {
      return null;
    }
  }

  DateTime? parseLeaveDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final date = value.trim();

    try {
      // yyyy-MM-dd
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
        return DateTime.parse(date);
      }

      // dd-MM-yyyy
      if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(date)) {
        final parts = date.split('-');

        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (e) {
      debugPrint("Date parse error: $value -> $e");
    }

    return null;
  }

  String getCreatedDate(data) {
    final timestamp = data.createdTs.toString();
    final dateTime = DateTime.parse(timestamp);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  Widget itemBuilder(List<LeaveModel> dataList, LeaveProvider levProvider) {
    var webWidth = MediaQuery.of(context).size.width * 0.7;
    var phoneWidth = MediaQuery.of(context).size.width * 0.95;

    /// CALCULATE FULL & HALF DAY COUNTS
    final fullDayCount =
        dataList.where((e) => e.dayType.toString() == "1").length;

    final halfDayCount =
        dataList.where((e) => e.dayType.toString() == "0.5").length;
    return ListView.builder(
        itemCount: dataList.length,
        itemBuilder: (context, index) {
          final sortedData = dataList;
          sortedData
              .sort((a, b) => a.startDate!.compareTo(b.startDate.toString()));
          final data = sortedData[index];
          var createdBy = "";
          String timestamp = data.createdTs.toString();
          DateTime dateTime = DateTime.parse(timestamp);
          String dayOfWeek = DateFormat('EEEE').format(dateTime);
          DateTime today = DateTime.now();
          if (dateTime.day == today.day &&
              dateTime.month == today.month &&
              dateTime.year == today.year) {
            dayOfWeek = 'Today';
          } else if (dateTime
              .isAfter(today.subtract(const Duration(days: 1))) &&
              dateTime.isBefore(today)) {
            dayOfWeek = 'Yesterday';
          } else {
            dayOfWeek = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
          }
          createdBy = "${dateTime.day}/${dateTime.month}/${dateTime.year}";

          /// FORMAT START & END DATE
          final start = DateTime.parse(data.startDate.toString());
          final end = (data.endDate != null &&
              data.endDate.toString() != "" &&
              data.startDate.toString() != data.endDate.toString())
              ? DateTime.parse(data.endDate.toString())
              : null;
          String displayDate;

          if (end != null) {
            /// 28 Oct - 1 Nov
            displayDate =
            "${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM').format(end)}";
          } else {
            /// Mon, 28 Oct
            displayDate = DateFormat('EEE, dd MMM').format(start);
          }
          return SizedBox(
            width: kIsWeb ? webWidth : phoneWidth,
            child: Column(
              children: [
                if (index == 0) ...[
                  10.height,

                  /// FULL DAY / HALF DAY SUMMARY
                  SizedBox(
                    width: kIsWeb ? webWidth : phoneWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomText(
                            text:
                            "Full Day: ${fullDayCount.toString() != "0" ? fullDayCount.toString().padLeft(2, "0") : "0"}",
                            size: 13,
                            isBold: true,
                            colors: Color(0xff7E7E7E)),
                        20.width,
                        CustomText(
                            text:
                            "Half Day: ${halfDayCount.toString() != "0" ? halfDayCount.toString().padLeft(2, "0") : "0"}",
                            size: 13,
                            isBold: true,
                            colors: Color(0xff7E7E7E)),
                      ],
                    ),
                  ),
                  5.height,
                ],
                SizedBox(
                  width: kIsWeb ? webWidth : phoneWidth,
                  child: Column(
                    children: [
                      10.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomText(
                              text: dayOfWeek, colors: colorsConst.greyClr),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    utils.navigatePage(
                        context,
                            () => LeaveDetails(
                            empId: data.userId.toString(),
                            name: data.fName.toString(),
                            role: data.role.toString(),
                            date1: _rangeD1,
                            date2: _rangeD2));
                  },
                  child: Container(
                    width: kIsWeb ? webWidth : phoneWidth,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(2, 2),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// TOP ROW (Name + Date + Status)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// LEFT SIDE (Name + Role)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: data.fName.toString(),
                                    size: 16,
                                    isBold: true,
                                  ),
                                  3.height,
                                  CustomText(
                                    text: data.role.toString(),
                                    size: 13,
                                    colors: Color(0xffA80007),
                                  ),
                                ],
                              ),

                              /// RIGHT SIDE (Date + Status Badge)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  CustomText(
                                      text: displayDate,
                                      size: 12,
                                      isBold: true,
                                      colors: Color(0xff7E7E7E)),
                                  5.height,

                                  /// STATUS BADGE
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffA80007),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: CustomText(
                                      text:
                                      "${data.type} : ${data.dayType == "0.5" ? "Half / ${data.session}" : "Full Day"}",
                                      size: 11,
                                      colors: Colors.white,
                                      isBold: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          5.height,

                          /// REASON
                          Row(
                            children: [
                              const CustomText(
                                text: "Reason : ",
                                size: 13,
                                colors: Colors.black,
                                isBold: true,
                              ),
                              Expanded(
                                child: CustomText(
                                    text: data.reason.toString(),
                                    size: 13,
                                    colors: Color(0xff7E7E7E)),
                              ),
                            ],
                          ),
                          10.height,

                          /// REQUESTED BY DATE
                          Align(
                            alignment: Alignment.centerRight,
                            child: CustomText(
                              text: "Requested By : $createdBy",
                              size: 12,
                              colors: Colors.black,
                              isBold: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                6.height,
                if (index == dataList.length - 1) 80.height,
              ],
            ),
          );
        });
  }

  /// small "label : value" row used inside the info box
  Widget infoRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: "$label : ",
          size: 11,
          colors: const Color(0xff7E7E7E),
        ),
        Expanded(
          child: CustomText(
            text: value,
            size: 12,
            isBold: true,
            colors: valueColor ?? const Color(0xff393636),
          ),
        ),
      ],
    );
  }

  Widget leaveCard(
      LeaveModel data, {
        bool showButtons = false,
        bool showCancelOnly = false,
        bool showSummary = false,
      }) {
    final start = DateTime.parse(data.startDate.toString());

    final end = (data.endDate != null && data.endDate.toString() != "")
        ? DateTime.parse(data.endDate.toString())
        : null;

    final DateTime createdDateTime =
    DateTime.parse(data.createdTs.toString()).toLocal();

    final DateTime updatedDateTime =
    DateTime.parse(data.updatedTs.toString()).toLocal();

    final String createdBy =
    DateFormat('dd-MM-yyyy • hh:mm a').format(createdDateTime);

    final String updatedBy =
    DateFormat('dd-MM-yyyy • hh:mm a').format(updatedDateTime);
    final double allowed = double.tryParse(data.leaveAllowed ?? "0") ?? 0;
    final double taken = double.tryParse(data.leaveTaken ?? "0") ?? 0;
    String displayDate;

    num leaveDays = 0;

    if (data.dayType.toString() == "0.5") {
      leaveDays = 0.5;
    } else {
      if (end != null) {
        DateTime current = start;

        while (!current.isAfter(end)) {
          if (current.weekday != DateTime.sunday) {
            leaveDays += 1;
          }

          current = current.add(
            const Duration(days: 1),
          );
        }
      } else {
        if (start.weekday != DateTime.sunday) {
          leaveDays = 1;
        }
      }
    }

    // REMOVE .0
    String leaveDaysText =
    leaveDays % 1 == 0 ? leaveDays.toInt().toString() : leaveDays.toString();

    if (end != null) {
      // Same Date
      if (start.year == end.year &&
          start.month == end.month &&
          start.day == end.day) {
        displayDate = DateFormat('dd-MM-yyyy').format(start);
      } else {
        // Different Dates
        displayDate = "${DateFormat('dd-MM-yyyy').format(start)} - "
            "${DateFormat('dd-MM-yyyy').format(end)}";
      }
    } else {
      displayDate = DateFormat('dd-MM-yyyy').format(start);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: data.fName.toString(),
                      size: 16,
                      isBold: true,
                    ),
                    CustomText(
                      text: data.role.toString(),
                      size: 13,
                      colors: const Color(0xffA80007),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: CustomText(
                            text:
                            "${data.type} : ${data.dayType == "0.5" ? "Half / ${data.session}" : "Full Day"}",
                            size: 11,
                            colors: Colors.white,
                            isBold: true,
                          ),
                        ),
                        if (localData.storage.read("role") == "1") ...[
                          5.width,
                          InkWell(
                            onTap: () {
                              _myFocusScopeNode.unfocus();
                              utils.navigatePage(
                                context,
                                    () => ApplyLeave(
                                  date1: _rangeD1,
                                  date2: _rangeD2,
                                  editData: data, // prefill with this leave record
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Color(0xffA80007),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// Reason
            Row(
              children: [
                const CustomText(
                  text: " Reason : ",
                  size: 13,
                  isBold: true,
                ),
                Expanded(
                  child: CustomText(
                    text: data.reason.toString(),
                    size: 13,
                    colors: const Color(0xff7E7E7E),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// "Employee On Leave" tab ONLY (showCancelOnly == true)
            if (showCancelOnly) ...[
              /// LEAVE FOR (Date Range)
              Row(
                children: [
                  const CustomText(
                    text: " Leave For : ",
                    size: 13,
                    isBold: true,
                  ),
                  Expanded(
                    child: CustomText(
                      text: displayDate,
                      size: 13,
                      colors: const Color(0xff7E7E7E),
                      isBold: true,
                    ),
                  ),
                  CustomText(
                    text: "$leaveDaysText Day${leaveDays > 1 ? 's' : ''}",
                    size: 12,
                    colors: Colors.black54,
                    isBold: true,
                  ),
                ],
              ),

              const SizedBox(height: 6),

              /// CLEAN INFO BOX
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xffF7F7F7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Requested On
                    infoRow("Requested on", createdBy),

                    /// Approved / Rejected By + On
                    if (data.status == "1" || data.status == "2") ...[
                      4.height,
                      Divider(height: 1, color: Colors.grey.shade300),
                      4.height,
                      infoRow(
                        data.status == "1" ? "Approved by" : "Rejected by",
                        "${data.updater} on ${DateFormat('dd-MM-yyyy hh:mma').format(updatedDateTime)}",
                        valueColor: data.status == "1"
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ],
                  ],
                ),
              ),

              8.height,
            ] else ...[
              /// ORIGINAL LAYOUT — used by "Leave Created" tab
              Row(
                children: [
                  const CustomText(
                    text: " Leave For: ",
                    size: 13,
                    isBold: true,
                  ),
                  Expanded(
                    child: CustomText(
                      text: displayDate,
                      size: 13,
                      colors: const Color(0xff393636),
                    ),
                  ),
                ],
              ),
              10.height,
              Row(
                children: [
                  const CustomText(
                    text: " Requested on: ",
                    size: 13,
                    isBold: true,
                  ),
                  Expanded(
                    child: CustomText(
                      text: createdBy,
                      size: 13,
                      colors: const Color(0xff393636),
                    ),
                  ),
                  const CustomText(
                    text: " Days: ",
                    size: 13,
                    isBold: true,
                  ),
                  CustomText(
                    text: "$leaveDaysText Day${leaveDays > 1 ? 's' : ''}",
                    size: 12,
                    colors: Colors.black54,
                    isBold: true,
                  ),
                ],
              ),
              10.height,
              if (data.status == "1" || data.status == "2") ...[
                Row(
                  children: [
                    CustomText(
                      text: data.status == "1"
                          ? " Approved by : "
                          : " Rejected by : ",
                      size: 13,
                      isBold: true,
                    ),
                    Expanded(
                      child: CustomText(
                        text: "${data.updater.toString()} on $updatedBy",
                        size: 13,
                        colors: const Color(0xff393636),
                      ),
                    ),
                  ],
                ),
                10.height,
              ],
            ],

            // SHOW SUMMARY ONLY IF FILTER NOT APPLIED
            if (showSummary) ...[
              if (allowed > 0 || taken > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CustomText(
                          text: " Total Leave: ",
                          size: 13,
                          isBold: true,
                        ),
                        CustomText(
                          text: taken % 1 == 0
                              ? taken.toInt().toString()
                              : taken.toString(),
                          size: 13,
                          colors: const Color(0xff7E7E7E),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const CustomText(
                          text: " Leave Taken : ",
                          size: 13,
                          isBold: true,
                        ),
                        CustomText(
                          text: taken % 1 == 0
                              ? taken.toInt().toString()
                              : taken.toString(),
                          size: 13,
                          colors: const Color(0xff7E7E7E),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
              10.height,
            ],

            /// Cancel Only Button
            if (showCancelOnly &&
                localData.storage.read("role") != "1" &&
                data.status != "3") ...[
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    final provider =
                    Provider.of<LeaveProvider>(context, listen: false);

                    await provider.approveApply(
                      context,
                      data.id.toString(),
                      data.userId.toString(),
                      "3",
                    );
                  },
                  child: const Text("Cancel Leave"),
                ),
              ),
            ],

            /// Admin Buttons - Pending
            if (showButtons && localData.storage.read("role") == "1") ...[
              if (data.status == "0") ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () async {
                          final provider = Provider.of<LeaveProvider>(context,
                              listen: false);

                          await provider.approveApply(
                            context,
                            data.id.toString(),
                            data.userId.toString(),
                            "1",
                          );
                        },
                        child: const Text("Approve Leave"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          final provider = Provider.of<LeaveProvider>(context,
                              listen: false);

                          await provider.approveApply(
                            context,
                            data.id.toString(),
                            data.userId.toString(),
                            "2",
                          );
                        },
                        child: const Text("Reject Leave"),
                      ),
                    ),
                  ],
                ),
              ],
            ],

            /// Admin Buttons - Approved
            if (showButtons && localData.storage.read("role") == "1") ...[
              if (data.status == "1") ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () async {
                          final provider = Provider.of<LeaveProvider>(context,
                              listen: false);

                          await provider.approveApply(
                            context,
                            data.id.toString(),
                            data.userId.toString(),
                            "2",
                          );
                        },
                        child: const Text("Cancel Approved Leave"),
                      ),
                    ),
                  ],
                ),
              ],
            ],

            /// Admin Buttons - Rejected
            if (showButtons && localData.storage.read("role") == "1") ...[
              if (data.status == "2") ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          final provider = Provider.of<LeaveProvider>(context,
                              listen: false);

                          await provider.approveApply(
                            context,
                            data.id.toString(),
                            data.userId.toString(),
                            "1",
                          );
                        },
                        child: const Text("Approve Rejected Leave"),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget leaveStatusList(List<LeaveModel> list, String status, bool isLoading) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final levPvr = Provider.of<LeaveProvider>(context, listen: false);

    final filtered =
    sortNewToOld(list.where((e) => e.status == status).toList());

    if (filtered.isEmpty) {
      return const Center(child: Text("No Data Found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10), // side padding parent-la
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return leaveCard(
          filtered[index],
          showButtons: true,
          showSummary: !levPvr.isFilterApplied, // filter illana mattum show
        );
      },
    );
  }
}