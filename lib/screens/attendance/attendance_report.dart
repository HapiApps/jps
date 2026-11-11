import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:master_code/screens/common/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:master_code/component/custom_dropdown.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:master_code/source/utilities/excel_reports.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:master_code/view_model/leave_provider.dart';
import 'package:provider/provider.dart';
import 'package:master_code/view_model/home_provider.dart';
import '../../component/animated_button.dart';
import '../../component/attendance_detail.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../component/map_dropdown.dart';
import '../../model/attendance_model.dart';
import '../../model/leave/leave_model.dart';
import '../../model/user_model.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/language_model.dart';
import '../../source/constant/local_data.dart';
import '../../source/styles/decoration.dart';
import '../../view_model/attendance_provider.dart';
import '../../view_model/employee_provider.dart';
import '../common/check_location.dart';
import '../common/dashboard.dart';
import 'custom_attendance_report.dart';
//
class AttendanceReport extends StatefulWidget {
  final String date1;
  final String date2;
  final String type;
  final String showType;
  final List<UserModel> empList;

  const AttendanceReport({super.key,required this.date1, required this.date2, required this.type, required this.showType, required this.empList});

  @override
  State<AttendanceReport> createState() => _AttendanceReportState();
}

class _AttendanceReportState extends State<AttendanceReport> {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();
  late String showType;

  /// ✅ ADDED: cached so dispose() never calls Provider.of on a deactivated context
  late final HomeProvider _homeProvider;

  /// ✅ Apply / Clear filter pannumbothu loading kaattura flag
  bool isFilterLoading = false;

  /// ✅ cache so repeated lat,lng pairs aren't re-geocoded
  final Map<String, String> _areaCache = {};

  /// ✅ Apply Filters: ippo thaan backend call aagum (selection la illa)
  Future<void> _applyFilters(
      AttendanceProvider att, LeaveProvider lev, dynamic user) async {
    if (!mounted) return;
    setState(() => isFilterLoading = true);

    try {
      final String uid = (user ?? "").toString();
      final String role = localData.storage.read("role").toString();

      att.search.clear();
      lev.search2.clear();

      att.changeFilter();
      lev.changeFilter();

      await Future.wait([
        att.getAttendanceReport(uid),
        att.getAbsentAttendanceReport(uid),
      ]);

      if (role == "1") {
        await lev.allLeaves(att.startDate, att.endDate, true, role, uid);
      } else {
        await lev.myLeaves(att.startDate, att.endDate, true, uid);
      }
    } catch (e) {
      print("Filter Error: $e");
    } finally {
      if (mounted) setState(() => isFilterLoading = false);
    }
  }

  /// ✅ Clear All: reset + fetch with loading
  Future<void> _clearFilters(AttendanceProvider att, LeaveProvider lev) async {
    if (!mounted) return;
    setState(() => isFilterLoading = true);

    try {
      att.initDate(
        id: localData.storage.read("id"),
        role: localData.storage.read("role"),
        isRefresh: false,
        date1: widget.date1,
        date2: widget.date2,
        type: widget.type,
      );
      await Future.wait([
        att.getAttendanceReport(localData.storage.read("id")),
        att.getAbsentAttendanceReport(localData.storage.read("id")),
      ]);
      lev.changeFilter();
      await lev.allSpecificLeaves(
        att.startDate,
        att.endDate,
        true,
        localData.storage.read("role"),
        localData.storage.read("id"),
      );
    } catch (e) {
      print("Clear Error: $e");
    } finally {
      if (mounted) setState(() => isFilterLoading = false);
    }
  }

  @override
  void initState() {
    showType = widget.showType;
    // ✅ ADDED: cache provider for dispose()
    _homeProvider = Provider.of<HomeProvider>(context, listen: false);
    check();
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      print(Provider.of<EmployeeProvider>(context, listen: false).userData.length);
      Provider.of<AttendanceProvider>(context, listen: false).initDate(id:localData.storage.read("id"),role:localData.storage.read("role"),isRefresh:true,date1:widget.date1,date2:widget.date2,type:widget.type);
      Provider.of<HomeProvider>(context, listen: false).loadFullDashboard(context);
      Provider.of<AttendanceProvider>(context, listen: false).getAbsentAttendanceReport(localData.storage.read("id"));
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      Provider.of<LeaveProvider>(context, listen: false).allAttendLeaves(
        today, today, true,
        localData.storage.read("role"),
        localData.storage.read("id"),
      );
    });
    super.initState();
  }

  // ✅ CHANGED: no setState inside initState
  void check(){
    final att = Provider.of<AttendanceProvider>(context, listen: false);
    if(showType=="Present"){
      att.selectedIndex=0;
    }else if(showType=="Absent"){
      att.selectedIndex=1;
    }else if(showType=="Late"){
      att.selectedIndex=2;
    }else if(showType=="Leave"){
      att.selectedIndex=3;
    }else if(showType=="Permission"){
      att.selectedIndex=4;
    }else{
      att.selectedIndex=0;
    }
  }
  var reportTypeList = [
    "All",
    "Present",
    "Absent",
    "Late",
    "Leave",
    "Permission",
  ];
  /// ✅ web-la content width: romba kuruga (50%) irukkaama, romba perusaavum pogaama
  double _webContentWidth(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    double c = w * 0.6;
    if (c < 720) c = 720;
    if (c > 1000) c = 1000;
    if (c > w * 0.95) c = w * 0.95;
    return c;
  }

  /// ✅ search pill (blue bar + search box + filter icon)
  /// web  -> available width ku Expanded (overflow aagaadhu)
  /// phone -> original fixed width (munnadi maathiriye)
  Widget _buildSearchPill(AttendanceProvider attProvider,
      EmployeeProvider empProvider, LeaveProvider levPvr, double phoneWidth) {
    final Widget searchField = Container(
      width: kIsWeb ? null : phoneWidth / 1.5,
      height: 45,
      decoration: customDecoration.baseBackgroundDecoration(
        radius: 30,
        color: Colors.transparent,
      ),
      child: TextFormField(
        cursorColor: colorsConst.primary,
        onChanged: (value) {
          attProvider.searchAttendanceReport(value.toString());
          levPvr.searchReport(value.toString());
        },
        textInputAction: TextInputAction.done,
        controller: attProvider.search,
        decoration: InputDecoration(
          hintText: "Search Name or ${constValue.customer}",
          hintStyle: TextStyle(color: colorsConst.primary, fontSize: 14),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: attProvider.search.text.isNotEmpty
              ? GestureDetector(
              onTap: () {
                attProvider.search.clear();
                attProvider.searchAttendanceReport("");
                levPvr.searchReport("");
              },
              child: Container(
                  width: 10,
                  height: 10,
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(assets.cancel2),
                  )))
              : null,
          errorStyle: const TextStyle(fontSize: 12.0, height: 0.20),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colorsConst.primary),
              borderRadius: BorderRadius.circular(30)),
          focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colorsConst.primary),
              borderRadius: BorderRadius.circular(30)),
          contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(30)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );

    return Container(
      width: kIsWeb ? null : phoneWidth / 1.2,
      decoration: customDecoration.baseBackgroundDecoration(
        radius: 30,
        color: colorsConst.primary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          kIsWeb ? Expanded(child: searchField) : searchField,
          InkWell(
            onTap: () => _openFilterDialog(attProvider, empProvider, levPvr),
            child: const Padding(
              padding: EdgeInsets.all(6.0),
              child: Icon(Icons.filter_alt, size: 27, color: Colors.white),
            ),
          ),
          5.width,
        ],
      ),
    );
  }

  bool isLoading = false;

  Future<void> _downloadReport(AttendanceProvider att, LeaveProvider lev) async {
    if (isLoading) return;
    setState(() => isLoading = true);
    try {
      final String role = localData.storage.read("role").toString();
      final String uid = localData.storage.read("id").toString();

      if (role == "1") {
        await lev.allLeaves(att.startDate, att.endDate, true, role, uid);
      } else {
        await lev.myLeaves(att.startDate, att.endDate, true, uid);
      }

      await excelReports.downloadAttendanceExcelReport(
        context,
        stDate: att.startDate,
        enDate: att.endDate,
        leaves: List.from(lev.myLevSearch),
      );
    } catch (e) {
      print("Download Error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _myFocusScopeNode.dispose();
    // ✅ CHANGED: use cached provider (Provider.of in dispose throws)
    _homeProvider.stopAutoRefresh();
    super.dispose();
  }

  /// ✅ reverse-geocodes a lat/lng pair (from backend data) into an area name
  /// mobile -> geocoding package, web -> Nominatim (OpenStreetMap)
  /// `late final` -> Geocoding() is created only on first use,
  /// so it never runs on Flutter Web (the usage below is guarded by kIsWeb).
  late final Geocoding geocodingService = Geocoding();
  Future<String> _getAreaName(String lat, String lng) async {
    try {
      if (lat.isEmpty || lng.isEmpty) return "-";
      final String key = "$lat,$lng";
      if (_areaCache.containsKey(key)) return _areaCache[key]!;

      final double? latitude = double.tryParse(lat);
      final double? longitude = double.tryParse(lng);
      if (latitude == null || longitude == null) return "-";

      String result = "-";

      if (kIsWeb) {
        final res = await http.get(Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=jsonv2'
                '&lat=$latitude&lon=$longitude&zoom=16&addressdetails=1&accept-language=en'));
        if (res.statusCode == 200) {
          final Map<String, dynamic> a =
          (jsonDecode(res.body)['address'] ?? {}) as Map<String, dynamic>;
          final String sub = (a['suburb'] ?? a['neighbourhood'] ?? a['city_district'] ?? '').toString();
          final String city = (a['city'] ?? a['town'] ?? a['village'] ?? a['county'] ?? '').toString();
          final String area = "$sub, $city".replaceAll(RegExp(r'^, |, $'), '').trim();
          if (area.isNotEmpty && area != ",") result = area;
        }
      } else {
        final List<Placemark> placemarks =
        await geocodingService.placemarkFromCoordinates(latitude, longitude);
        if (placemarks.isNotEmpty) {
          final Placemark place = placemarks.first;
          final String area = "${place.subLocality ?? ''} ${place.locality ?? ''}".trim();
          result = area.isNotEmpty ? area : (place.name ?? "-");
        }
      }

      _areaCache[key] = result;
      return result;
    } catch (e) {
      return "-";
    }
  }

  /// ✅ "check in/out : area1  area2" inline text
  Widget _buildCheckInOutInline(String lat1, String lng1, String lat2, String lng2) {
    return FutureBuilder<List<String>>(
      future: Future.wait([
        _getAreaName(lat1, lng1),
        (lat2.isNotEmpty && lng2.isNotEmpty)
            ? _getAreaName(lat2, lng2)
            : Future.value(""),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CustomText(text: "check in/out : ...", size: 12, colors: colorsConst.greyClr);
        }
        String area1 = snapshot.data![0];
        String area2 = snapshot.data![1];
        String combined = area2.isNotEmpty ? "$area1   $area2" : area1;
        return CustomText(text: "check in/out : $combined", size: 12, colors: colorsConst.greyClr);
      },
    );
  }

  /// ✅ containerized attendance row: avatar/name + In/Out/Total hrs, then role + area line
  Widget _buildAttendanceRow({
    required String name,
    required String role,
    required String inTime,
    required String outTime,
    required String totalHrs,
    required String lat1,
    required String lng1,
    required String lat2,
    required String lng2,
    required VoidCallback onTap, // Map open
    required VoidCallback onProfileTap, // Employee page
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: onProfileTap,
                    borderRadius: BorderRadius.circular(30),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.grey.shade300,
                      child: SvgPicture.asset(
                        assets.profile,
                        width: 16,
                        height: 16,
                      ),
                    ),
                  ),
                  8.width,
                  Expanded(
                    flex: 2,
                    child: CustomText(
                      text: name,
                      isBold: true,
                      size: 14,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "In:",
                          size: 11,
                          colors: colorsConst.greyClr,
                        ),
                        CustomText(text: inTime, size: 13),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "Out:",
                          size: 11,
                          colors: colorsConst.greyClr,
                        ),
                        CustomText(text: outTime, size: 13),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "Total hrs",
                          size: 11,
                          colors: colorsConst.greyClr,
                        ),
                        CustomText(text: totalHrs, size: 13),
                      ],
                    ),
                  ),
                ],
              ),
              8.height,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 38),
                  Expanded(
                    flex: 2,
                    child: CustomText(
                      text: role,
                      size: 12,
                      colors: colorsConst.greyClr,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _buildCheckInOutInline(
                      lat1,
                      lng1,
                      lat2,
                      lng2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // ✅ FILTER DIALOG (original design, alignment cleaned) + SEARCHABLE EMPLOYEE
  // ==========================================================================

  /// dialog open aagumbothu irundha From/To date (preset type kum date kum match aagudha nu check panna)
  String? _baseStart;
  String? _baseEnd;

  /// dialog open aagumbothu munnadiye custom date apply panni irundha
  bool _forceCustom = false;

  /// Apply pannumbothu user custom From/To date select pannirundhaa (outside chips ku)
  bool _appliedCustom = false;

  /// ✅ From/To date manually maathirundha "Today" nu kaattaama "Custom Range" nu kaattum
  bool _showCustom(AttendanceProvider att) {
    if (_forceCustom) return true;
    if (_baseStart == null || _baseEnd == null) return false;
    return att.startDate != _baseStart || att.endDate != _baseEnd;
  }

  /// label + field (same size / same gap everywhere)
  Widget _dialogField({
    required String label,
    required double width,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: label, colors: colorsConst.greyClr, size: 12),
        6.height,
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(5),
          child: Container(
            height: 40,
            width: width,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: customDecoration.baseBackgroundDecoration(
              radius: 5,
              color: Colors.white,
              borderColor: colorsConst.litGrey,
            ),
            child: child,
          ),
        ),
      ],
    );
  }

  /// ✅ opens the filter dialog (called from the filter icon)
  void _openFilterDialog(
      AttendanceProvider attProvider,
      EmployeeProvider empProvider,
      LeaveProvider levPvr,
      ) {
    _myFocusScopeNode.unfocus();

    // ✅ CHANGED: load only when nothing is available, and WITHOUT clearing
    // the existing lists (isRefresh:false)
    if (empProvider.userData.isEmpty &&
        empProvider.filterUserData.isEmpty &&
        widget.empList.isEmpty) {
      empProvider.getAllUsers(isRefresh: false);
    }

    // ✅ snapshot: Apply pannaama close pannaa restore panna
    final oldStart = attProvider.startDate;
    final oldEnd = attProvider.endDate;
    final oldType = attProvider.type;
    final oldUser = attProvider.user;
    final oldUserName = attProvider.userName;
    bool applied = false;

    _baseStart = attProvider.startDate;
    _baseEnd = attProvider.endDate;
    _forceCustom = _appliedCustom;

    final double webWidth = MediaQuery.of(context).size.width * 0.5;
    final double phoneWidth = MediaQuery.of(context).size.width * 0.95;
    final double fieldW = kIsWeb ? webWidth / 2.7 : phoneWidth / 2.7;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Consumer<AttendanceProvider>(
          builder: (_, custProvider, __) {
            // type maathunaa (base null) -> ippo irukkura date ah base ah edukkurom
            if (_baseStart == null || _baseEnd == null) {
              _baseStart = custProvider.startDate;
              _baseEnd = custProvider.endDate;
            }
            final bool isCustom = _showCustom(custProvider);

            // ✅ date picker app theme color la varanum -> Theme wrap pannitu
            // datePick ku themedCtx (Theme ku keela irukkura context) pass panrom
            return Theme(
              data: Theme.of(dialogCtx).copyWith(
                colorScheme: Theme.of(dialogCtx).colorScheme.copyWith(
                  primary: colorsConst.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(foregroundColor: colorsConst.primary),
                ),
              ),
              child: Builder(builder: (themedCtx) {
                return AlertDialog(
                  scrollable: true,
                  contentPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  content: SizedBox(
                    width: kIsWeb ? webWidth : phoneWidth,
                    child: Column(
                      children: [
                        20.height,

                        // ---------- Header (title center, close right) ----------
                        Row(
                          children: [
                            const SizedBox(width: 24),
                            const Expanded(
                              child: Center(
                                child: CustomText(
                                  text: 'Filters',
                                  colors: Colors.black,
                                  size: 16,
                                  isBold: true,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(dialogCtx, rootNavigator: true).pop();
                              },
                              child: SvgPicture.asset(assets.cancel),
                            ),
                          ],
                        ),
                        20.height,

                        // ---------- From / To date ----------
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _dialogField(
                              label: "From Date",
                              width: fieldW,
                              onTap: () {
                                custProvider.datePick(
                                  context: themedCtx,
                                  isStartDate: true,
                                  date: attProvider.startDate,
                                );
                              },
                              child: Row(
                                children: [
                                  Expanded(child: CustomText(text: custProvider.startDate)),
                                  SvgPicture.asset(assets.calendar2),
                                ],
                              ),
                            ),
                            _dialogField(
                              label: "To Date",
                              width: fieldW,
                              onTap: () {
                                custProvider.datePick(
                                  context: themedCtx,
                                  isStartDate: false,
                                  date: attProvider.endDate,
                                );
                              },
                              child: Row(
                                children: [
                                  Expanded(child: CustomText(text: custProvider.endDate)),
                                  SvgPicture.asset(assets.calendar2),
                                ],
                              ),
                            ),
                          ],
                        ),
                        16.height,

                        // ---------- Employee (SEARCHABLE) / Date range ----------
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✅ CHANGED: picker reads the employee list LIVE
                            // (userData -> filterUserData -> widget.empList)
                            _EmployeeSearchDropdown(
                              width: fieldW,
                              emp: empProvider,
                              fallback: widget.empList,
                              selectedId: (custProvider.user ?? "").toString(),
                              selectedName: custProvider.userName,
                              onSelected: (u) =>
                                  attProvider.selectUser(dialogCtx, u, widget.empList),
                            ),
                            _dialogField(
                              label: "Select Date Range",
                              width: fieldW,
                              child: DropdownButton<String>(
                                iconEnabledColor: colorsConst.greyClr,
                                isExpanded: true,
                                underline: const SizedBox(),
                                icon: const Icon(Icons.keyboard_arrow_down_outlined),
                                menuMaxHeight: 300,
                                // From/To manually maathirundha value null -> "Custom Range" nu kaattum
                                // illana only use the value if it exists exactly once in the list
                                value: (!isCustom &&
                                    attProvider.typeList.where((e) => e == attProvider.type).length == 1)
                                    ? attProvider.type
                                    : null,
                                hint: CustomText(
                                  text: isCustom ? "Custom Range" : "Select",
                                  colors: isCustom ? Colors.black : Colors.grey,
                                ),
                                onChanged: (value) {
                                  if (value == null) return;
                                  attProvider.changeType(
                                    value,
                                    localData.storage.read("id"),
                                    localData.storage.read("role"),
                                    false,
                                    widget.empList,
                                    context,
                                  );
                                  // preset select pannitaanga -> custom flag reset
                                  _forceCustom = false;
                                  _baseStart = null;
                                  _baseEnd = null;
                                },
                                items: attProvider.typeList.toSet().toList().map((list) {
                                  return DropdownMenuItem<String>(
                                    value: list,
                                    child: CustomText(
                                      text: list,
                                      colors: Colors.black,
                                      isBold: false,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        24.height,

                        // ---------- Buttons ----------
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomBtn(
                              width: 100,
                              text: 'Clear All',
                              callback: () {
                                applied = true;
                                _appliedCustom = false;
                                _forceCustom = false;
                                Navigator.of(dialogCtx, rootNavigator: true).pop();
                                _clearFilters(attProvider, levPvr);
                              },
                              bgColor: Colors.grey.shade200,
                              textColor: Colors.black,
                            ),
                            CustomBtn(
                              width: 100,
                              text: 'Apply Filters',
                              callback: () {
                                applied = true;
                                // custom date select pannirundhaa outside chips ku theriyanum
                                _appliedCustom = _showCustom(custProvider);
                                // pop-ku munnadi user-a capture pannunga
                                final selectedUser = custProvider.user;
                                Navigator.of(dialogCtx, rootNavigator: true).pop();
                                _applyFilters(attProvider, levPvr, selectedUser);
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
                );
              }),
            );
          },
        );
      },
    ).then((_) {
      // ✅ Apply pannaama close pannaa old values restore
      if (!applied) {
        attProvider.restoreFilter(
          start: oldStart,
          end: oldEnd,
          type: oldType,
          user: oldUser,
          userName: oldUserName,
        );
      }
    });
  }

  // ==========================================================================
  // ✅ MAP (thani page illa) -> same page la dialog aa open aagum.
  // ✅ CHANGED: Info card ippo map KULLA, KEELA (bottom) overlay-a irukkum.
  // Close button map mela top-right la irukkum.
  // Android / iOS / Web ellathukum same.
  // ==========================================================================

  void _openMapDialog({
    required String lat1,
    required String lng1,
    required String lat2,
    required String lng2,
    required String name,
    required String role,
    required String date,
    required String inTime,
    required String outTime,
    required String totalHrs,
  }) {
    final Size size = MediaQuery.of(context).size;
    final double w = kIsWeb ? size.width * 0.6 : size.width * 0.95;
    final double h = size.height * 0.85;

    final Future<String> inArea = _getAreaName(lat1, lng1);
    final Future<String> outArea =
    (lat2.trim().isNotEmpty && lng2.trim().isNotEmpty)
        ? _getAreaName(lat2, lng2)
        : Future.value("");

    showDialog(
      context: context,
      builder: (dialogCtx) {
        // map + overlays (close button top, info card bottom)
        final Widget mapStack = Stack(
          children: [
            // ---------- Map (full dialog) ----------
            Positioned.fill(
              child: CheckLocation(
                lat1: lat1,
                long1: lng1,
                lat2: lat2,
                long2: lng2,
                embedded: true,
              ),
            ),

            // ---------- Close button (top right, map mela) ----------
            Positioned(
              top: 10,
              right: 10,
              child: InkWell(
                onTap: () => Navigator.of(dialogCtx, rootNavigator: true).pop(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 6),
                    ],
                  ),
                  child: const Icon(Icons.close, size: 20, color: Colors.black),
                ),
              ),
            ),

            // ---------- Info card (map kulla, keela) ----------
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: _MapInfoCard(
                name: name,
                role: role,
                date: date,
                inTime: inTime,
                outTime: outTime,
                totalHrs: totalHrs,
                inArea: inArea,
                outArea: outArea,
              ),
            ),
          ],
        );

        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          clipBehavior: kIsWeb ? Clip.none : Clip.antiAlias,
          child: SizedBox(
            width: w,
            height: h,
            // web-la Clip.none thevai (map platform view issue) -> mobile la mattum ClipRRect
            child: kIsWeb
                ? mapStack
                : ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: mapStack,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var webWidth=_webContentWidth(context);
    var phoneWidth=MediaQuery.of(context).size.width * 0.95;
    return Consumer4<AttendanceProvider,EmployeeProvider,HomeProvider,LeaveProvider>
      (builder: (context,attProvider,empProvider,homeProvider,levPvr,_){
      // ✅ filters (date + employee) ellaa tab layum correct aa apply aaga, list ah inga filter pannrom
      final List<AttendanceModel> presentList = _userFiltered(attProvider);
      final List<dynamic> absentList = _filteredAbsent(attProvider);
      final List<LeaveModel> leaveList = _filteredLeaves(attProvider, levPvr);
      final int fullDayCount =
          leaveList.where((e) => e.dayType.toString() == "1").length;
      final int halfDayCount =
          leaveList.where((e) => e.dayType.toString() == "0.5").length;
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
              preferredSize: const Size(300, 50),
              child: CustomAppbar(text: showType.toString()=="Absent"?"Absent Report":showType.toString()=="Late"?"${constValue.lateAttendanceReport}":"${constValue.attReport}",callback: (){
                homeProvider.updateIndex(0);
                _myFocusScopeNode.unfocus();
                utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
              }),
            ),
            body: PopScope(
              canPop: false,
              onPopInvoked: (bool didPop) {
                homeProvider.updateIndex(0);
                _myFocusScopeNode.unfocus();
                if (!didPop) {
                  utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
                }
              },
              child: Center(
                child: SizedBox(
                  width: kIsWeb?webWidth:phoneWidth,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        20.height,
                        if(localData.storage.read("role")=="1")
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // ✅ web-la Expanded -> overflow aagaadhu, phone-la original width
                              kIsWeb
                                  ? Expanded(child: _buildSearchPill(attProvider, empProvider, levPvr, phoneWidth))
                                  : _buildSearchPill(attProvider, empProvider, levPvr, phoneWidth),
                              if (kIsWeb) 12.width,
                              GestureDetector(
                                onTap: () => _downloadReport(attProvider, levPvr),
                                child: isLoading
                                    ? const SizedBox(
                                  width: 27,
                                  height: 27,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                                    : const Icon(
                                  Icons.download_rounded,
                                  size: 27,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        if(localData.storage.read("role") !="1")
                          Row(
                            children: [
                              SizedBox(
                                width: 300,
                                child: CustomDropDown(
                                    text: "", valueList: attProvider.typeList,
                                    saveValue: attProvider.type,color: Colors.white,
                                    onChanged: (value){
                                      attProvider.changeType(value,localData.storage.read("id"),localData.storage.read("role"),false,widget.empList,context);
                                    }, width: kIsWeb?webWidth:phoneWidth),
                              ), 20.width,
                              GestureDetector(
                                onTap: () => _downloadReport(attProvider, levPvr),
                                child: isLoading
                                    ? const SizedBox(
                                  width: 27,
                                  height: 27,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                                    : const Icon(
                                  Icons.download_rounded,
                                  size: 27,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        10.height,
                        SizedBox(
                          width: kIsWeb?webWidth:phoneWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if(attProvider.filter==true)
                                CustomText(text: "Filter Selected",colors:colorsConst.greyClr,size: 14,),
                              Expanded(
                                child: Wrap(
                                  alignment: WrapAlignment.end,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 14,
                                  runSpacing: 4,
                                  children: [
                                    // ✅ Full / Half day count ippo Total Records line la
                                    if(showType=="Leave") ...[
                                      CustomText(
                                        text: "Full Day: ${fullDayCount.toString().padLeft(2, "0")}",
                                        size: 13,
                                        isBold: true,
                                        colors: const Color(0xff7E7E7E),
                                      ),
                                      CustomText(
                                        text: "Half Day: ${halfDayCount.toString().padLeft(2, "0")}",
                                        size: 13,
                                        isBold: true,
                                        colors: const Color(0xff7E7E7E),
                                      ),
                                    ],
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CustomText(text: "Total Records: ",colors:colorsConst.greyClr,size: 14,),
                                        CustomText(text: showType=="Leave"?leaveList.length.toString():showType=="Late"?attProvider.lateCountShow.toString():showType=="Absent"?absentList.length.toString():showType=="Present"?presentList.length.toString():attProvider.permisCount.toString(),colors:colorsConst.primary,size: 14,),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        10.height,
                        if(attProvider.filter==true)
                          SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              runSpacing: 5,
                              children: [
                                // ✅ custom From/To date select pannirundha same-day aanaalum date chip kaattum
                                if (attProvider.startDate.isNotEmpty &&
                                    attProvider.endDate.isNotEmpty &&
                                    (attProvider.startDate != attProvider.endDate || _appliedCustom))
                                  _filterChip(
                                    attProvider.startDate == attProvider.endDate
                                        ? attProvider.startDate
                                        : "${attProvider.startDate} - ${attProvider.endDate}",
                                  ),

                                // ✅ custom date apply pannirundha "Today" maathiri preset type chip kaattaadhu
                                if (!_appliedCustom && attProvider.type.isNotEmpty && attProvider.type!="null")
                                  _filterChip(attProvider.type),

                                if (attProvider.userName.isNotEmpty)
                                  _filterChip(attProvider.userName),

                              ],
                            ),
                          ),
                        15.height,
                        Padding(
                          padding: EdgeInsets.only(left: kIsWeb ? 0 : 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 45,
                                  child: ToggleButtons(

                                    isSelected: List.generate(
                                      attProvider.items.length,
                                          (index) => attProvider.selectedIndex == index,
                                    ),

                                    onPressed: (index) {
                                      setState(() {
                                        attProvider.selectedIndex = index;

                                        switch (index) {
                                          case 0:
                                            showType = "Present";
                                            break;
                                          case 1:
                                            showType = "Absent";
                                            break;
                                          case 2:
                                            showType = "Late";
                                            break;
                                          case 3:
                                            showType = "Leave";
                                            break;
                                          case 4:
                                            showType = "Permission";
                                            break;
                                        }
                                      });
                                    },

                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(5),
                                      bottomLeft: Radius.circular(5),
                                    ),
                                    borderWidth: 1,
                                    borderColor: Colors.grey.shade300,
                                    selectedBorderColor: Colors.green,
                                    fillColor: Colors.green,
                                    constraints: const BoxConstraints(
                                      minHeight: 45,
                                      minWidth: 0,
                                    ),

                                    children: attProvider.items.map((item) {
                                      final index = attProvider.items.indexOf(item);
                                      final isSelected = attProvider.selectedIndex == index;

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Center(
                                          child: CustomText(
                                            text: item,
                                            size: 12,
                                            colors: isSelected
                                                ? Colors.white
                                                : attProvider.itemColors[index].withOpacity(0.6),
                                            isBold: true,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ✅ isFilterLoading add pannirukku
                        (attProvider.refresh == false || isFilterLoading) ?
                        const Padding(
                          padding: EdgeInsets.all(100.0),
                          child: Loading(),
                        ):
                        attProvider.selectedIndex==0&&
                            presentList.isNotEmpty?
                        Flexible(
                          child: ListView.builder(
                            itemCount: presentList.length,
                            itemBuilder: (context, index) {

                              final sortedData =
                              List<AttendanceModel>.from(_userFiltered(attProvider));

                              sortedData.sort((a, b) {

                                DateTime aTime =
                                DateTime.parse(a.createdTs.toString().split(',')[0]);

                                DateTime bTime =
                                DateTime.parse(b.createdTs.toString().split(',')[0]);

                                return bTime.compareTo(aTime);

                              });

                              AttendanceModel data = sortedData[index];

                              // ✅ earlier time = In, later time = Out (lat/lng um pair aa move aagum)
                              final parts = _splitAttendance(data, attProvider);
                              final String inTime  = parts.inTime;
                              final String outTime = _outLabel(data, parts.outTime, levPvr);
                              final String timeD   = parts.timeD;
                              final String lat1 = parts.lat1;
                              final String lng1 = parts.lng1;
                              final String lat2 = parts.lat2;
                              final String lng2 = parts.lng2;

                              String timestamp = data.createdTs.toString();
                              List<String> times = timestamp.split(',');
                              DateTime startTime = DateTime.parse(times[0]);

                              String createdBy = formatCreatedDate(startTime);
                              String? prevCreatedBy;

                              if (index != 0) {
                                String prevTimestamp = sortedData[index - 1].createdTs.toString();
                                List<String> prevTimes = prevTimestamp.split(',');
                                DateTime prevStartTime = DateTime.parse(prevTimes[0]);
                                prevCreatedBy = formatCreatedDate(prevStartTime);
                              }

                              final showDateHeader = index == 0 || createdBy != prevCreatedBy;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  if(localData.storage.read("role")=="1" && showDateHeader)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                      child: CustomText(
                                        text: createdBy,
                                        colors: colorsConst.greyClr,
                                        size: 12,
                                      ),
                                    ),

                                  /// ✅ containerized attendance row (avatar/name + In/Out/Total hrs + role + area)
                                  AttendanceDetails(
                                    showDate: index == 0,
                                    date: data.date.toString(),
                                    img: data.image.toString(),
                                    inTime: inTime,
                                    outTime: outTime,
                                    timeD: timeD,
                                    name: data.firstname.toString(),
                                    role: data.role.toString(),

                                    /// ✅ passed so AttendanceDetails can show the
                                    /// check-in / check-out area name under In/Out time
                                    inLat: lat1,
                                    inLng: lng1,
                                    outLat: lat2,
                                    outLng: lng2,

                                    callback: () {
                                      _openMapDialog(
                                        lat1: lat1,
                                        lng1: lng1,
                                        lat2: lat2,
                                        lng2: lng2,
                                        name: data.firstname.toString(),
                                        role: data.role.toString(),
                                        date: data.date.toString(),
                                        inTime: inTime,
                                        outTime: outTime,
                                        totalHrs: timeD,
                                      );
                                    },

                                    perStatus: data.perStatus.toString(),
                                    perReason: data.perReason.toString(),
                                    perTime: data.perTime.toString(),
                                    perCreatedTs: data.perCreatedTs.toString(), empId: data.salesmanId, active: data.active,
                                  ),
                                  5.height
                                ],
                              );
                            },
                          ),
                        ):
                        attProvider.selectedIndex==1&&
                            absentList.isNotEmpty?
                        Flexible(
                          child: ListView.builder(
                            itemCount: absentList.length,
                            itemBuilder: (context, index) {
                              var data = absentList[index];
                              String? timestamp = data.missingDate?.toString();

                              if (timestamp == null || timestamp.isEmpty || timestamp == "null") {
                                return const SizedBox.shrink();
                              }

                              DateTime? dateTime = DateTime.tryParse(timestamp);
                              if (dateTime == null) {
                                return const SizedBox.shrink();
                              }

                              String dayOfWeek;
                              String dateStr = DateFormat('dd MMM yyyy').format(dateTime);
                              DateTime today = DateTime.now();
                              if (dateTime.day == today.day && dateTime.month == today.month && dateTime.year == today.year) {
                                dayOfWeek = 'Today • $dateStr';
                              } else if (dateTime.isAfter(today.subtract(const Duration(days: 1))) && dateTime.isBefore(today)) {
                                dayOfWeek = 'Yesterday • $dateStr';
                              } else {
                                dayOfWeek = dateStr;
                              }

                              String createdBy = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                              final showDateHeader = index == 0 || createdBy != getCreatedDate(absentList[index - 1]);

                              return Padding(
                                padding: EdgeInsets.fromLTRB(0, 10, 0, index == absentList.length - 1 ? 30 : 0),
                                child: Column(
                                  children: [
                                    if (showDateHeader)
                                      CustomText(text: dayOfWeek, colors: Colors.black),
                                    Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                if (localData.storage.read("role") == "1")
                                                  CircleAvatar(
                                                    radius: 15,
                                                    backgroundColor: Colors.grey.shade400,
                                                    child: SvgPicture.asset(assets.profile),
                                                  ),
                                                5.width,
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(text: data.firstname.toString(), isBold: true),

                                                  ],
                                                ),
                                              ],
                                            ),
                                            localData.storage.read("role") == "1"
                                                ? CustomText(text: data.role.toString(), colors: colorsConst.blueClr)
                                                : CustomText(
                                              text: "${dateTime.day}/${dateTime.month}/${dateTime.year}",
                                              colors: colorsConst.blueClr,
                                            ),],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ):
                        attProvider.selectedIndex==2 &&
                            attProvider.lateCountShow!=0? Flexible(
                          child: Builder(
                            builder: (context) {

                              final sortedData =
                              List<AttendanceModel>.from(_userFiltered(attProvider));

                              sortedData.sort((a, b) {
                                DateTime aTime =
                                DateTime.parse(a.createdTs.toString().split(',')[0]);
                                DateTime bTime =
                                DateTime.parse(b.createdTs.toString().split(',')[0]);
                                return bTime.compareTo(aTime);
                              });

                              // ✅ earlier time = In nu eduthu late check pannrom
                              final lateList = sortedData.where((data) {
                                final p = _splitAttendance(data, attProvider);
                                return isLate(p.inTime);
                              }).toList();

                              if (lateList.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
                                  child: CustomText(text: constValue.noData, size: 15),
                                );
                              }

                              return ListView.builder(
                                itemCount: lateList.length,
                                itemBuilder: (context, index) {

                                  AttendanceModel data = lateList[index];

                                  // ✅ compute lat/lng OUTSIDE the callback so they can be passed
                                  // into AttendanceDetails (for the area-name display) AND used
                                  // inside the map-icon tap callback.
                                  final parts = _splitAttendance(data, attProvider);
                                  final String inTime  = parts.inTime;
                                  final String outTime = _outLabel(data, parts.outTime, levPvr);
                                  final String timeD   = parts.timeD;
                                  final String lat1 = parts.lat1;
                                  final String lng1 = parts.lng1;
                                  final String lat2 = parts.lat2;
                                  final String lng2 = parts.lng2;

                                  String timestamp = data.createdTs.toString();
                                  List<String> times = timestamp.split(',');
                                  DateTime startTime = DateTime.parse(times[0]);

                                  String createdBy = formatCreatedDate(startTime);
                                  String? prevCreatedBy;

                                  if (index != 0) {
                                    String prevTimestamp = lateList[index - 1].createdTs.toString();
                                    List<String> prevTimes = prevTimestamp.split(',');
                                    DateTime prevStartTime = DateTime.parse(prevTimes[0]);
                                    prevCreatedBy = formatCreatedDate(prevStartTime);
                                  }

                                  final showDateHeader = index == 0 || createdBy != prevCreatedBy;

                                  return Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        5, 10, 5, index == lateList.length - 1 ? 30 : 0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [

                                        if (showDateHeader)
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                            child: CustomText(
                                              text: createdBy,
                                              colors: colorsConst.greyClr,
                                              size: 12,
                                            ),
                                          ),

                                        AttendanceDetails(
                                          showDate: index == 0,
                                          date: data.date.toString(),
                                          img: data.image.toString(),
                                          inTime: inTime,
                                          outTime: outTime,
                                          timeD: timeD,
                                          name: data.firstname.toString(),
                                          role: data.role.toString(),

                                          /// ✅ passed so AttendanceDetails can show the
                                          /// check-in / check-out area name under In/Out time
                                          inLat: lat1,
                                          inLng: lng1,
                                          outLat: lat2,
                                          outLng: lng2,

                                          callback: () {
                                            _openMapDialog(
                                              lat1: lat1,
                                              lng1: lng1,
                                              lat2: lat2,
                                              lng2: lng2,
                                              name: data.firstname.toString(),
                                              role: data.role.toString(),
                                              date: data.date.toString(),
                                              inTime: inTime,
                                              outTime: outTime,
                                              totalHrs: timeD,
                                            );
                                          },

                                          perStatus: data.perStatus.toString(),
                                          perReason: data.perReason.toString(),
                                          perTime: data.perTime.toString(),
                                          perCreatedTs: data.perCreatedTs.toString(), empId: data.salesmanId, active: data.active,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ):
                        attProvider.selectedIndex==3&&
                            leaveList.isNotEmpty?
                        Flexible(
                            child: itemBuilder(leaveList,levPvr)):
                        attProvider.selectedIndex == 4 &&
                            attProvider.permisCount != 0
                            ? Flexible(
                          child: Builder(
                            builder: (context) {

                              List<AttendanceModel> filteredList = attProvider.user.isEmpty
                                  ? List<AttendanceModel>.from(attProvider.getDailyAttendance)
                                  : attProvider.getDailyAttendance
                                  .where((e) =>
                              e.salesmanId.toString() ==
                                  attProvider.user.toString())
                                  .toList();

                              filteredList.sort((a, b) {
                                DateTime aTime =
                                DateTime.parse(a.createdTs.toString().split(',')[0]);
                                DateTime bTime =
                                DateTime.parse(b.createdTs.toString().split(',')[0]);
                                return bTime.compareTo(aTime);
                              });

                              if (filteredList.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
                                  child: CustomText(
                                    text: constValue.noData,
                                    size: 15,
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount: filteredList.length,
                                itemBuilder: (context, index) {
                                  AttendanceModel data = filteredList[index];

                                  // ✅ earlier time = In, later time = Out (lat/lng um pair aa move aagum)
                                  final parts = _splitAttendance(data, attProvider);
                                  final String inTime  = parts.inTime;
                                  final String outTime = _outLabel(data, parts.outTime, levPvr);
                                  final String timeD   = parts.timeD;
                                  final String lat1 = parts.lat1;
                                  final String lng1 = parts.lng1;
                                  final String lat2 = parts.lat2;
                                  final String lng2 = parts.lng2;

                                  String timestamp = data.createdTs.toString();
                                  List<String> createdTimes = timestamp.split(',');

                                  DateTime startTime =
                                  DateTime.parse(createdTimes[0]).toLocal();

                                  String createdBy = formatCreatedDate(startTime);

                                  if (createdBy.trim().isEmpty) {
                                    createdBy = "Today";
                                  }

                                  String? prevCreatedBy;

                                  if (index != 0) {
                                    String prevTimestamp =
                                    filteredList[index - 1].createdTs.toString();

                                    List<String> prevTimes = prevTimestamp.split(',');

                                    DateTime prevStart =
                                    DateTime.parse(prevTimes[0]).toLocal();

                                    prevCreatedBy = formatCreatedDate(prevStart);

                                    if (prevCreatedBy.trim().isEmpty) {
                                      prevCreatedBy = "Today";
                                    }
                                  }

                                  final bool showDateHeader =
                                      index == 0 || createdBy != prevCreatedBy;

                                  return data.perStatus.toString() != "null"
                                      ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (showDateHeader)
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                          child: CustomText(
                                            text: createdBy,
                                            colors: colorsConst.greyClr,
                                            size: 12,
                                          ),
                                        ),

                                      /// ✅ containerized attendance row (avatar/name + In/Out/Total hrs + role + area)
                                      AttendanceDetails(
                                        showDate: index == 0,
                                        date: data.date.toString(),
                                        img: data.image.toString(),
                                        inTime: inTime,
                                        outTime: outTime,
                                        timeD: timeD,
                                        name: data.firstname.toString(),
                                        role: data.role.toString(),

                                        /// ✅ passed so AttendanceDetails can show the
                                        /// check-in / check-out area name under In/Out time
                                        inLat: lat1,
                                        inLng: lng1,
                                        outLat: lat2,
                                        outLng: lng2,

                                        callback: () {
                                          _openMapDialog(
                                            lat1: lat1,
                                            lng1: lng1,
                                            lat2: lat2,
                                            lng2: lng2,
                                            name: data.firstname.toString(),
                                            role: data.role.toString(),
                                            date: data.date.toString(),
                                            inTime: inTime,
                                            outTime: outTime,
                                            totalHrs: timeD,
                                          );
                                        },

                                        perStatus: data.perStatus.toString(),
                                        perReason: data.perReason.toString(),
                                        perTime: data.perTime.toString(),
                                        perCreatedTs: data.perCreatedTs.toString(), empId: data.salesmanId, active: data.active,
                                      ),

                                      5.height
                                    ],
                                  )
                                      : 0.height;
                                },
                              );
                            },
                          ),
                        )
                            : Padding(
                          padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
                          child: CustomText(text: constValue.noData, size: 15),
                        ),
                      ]
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  String _outLabel(AttendanceModel data, String outTime, LeaveProvider lev) {
    if (outTime.trim().isNotEmpty && outTime != "-") return outTime;
    final day = DateTime.tryParse(data.createdTs.toString().split(',')[0].trim());
    if (day == null) return outTime;
    return lev.approvedLeaveOn(data.salesmanId.toString(), day) == "Full Day"
        ? "On Leave"
        : outTime;
  }

  String getCreatedDate(data) {
    final timestamp = data.missingDate.toString();
    final dateTime = DateTime.parse(timestamp);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
  Widget itemBuilder(List<LeaveModel> dataList, LeaveProvider levProvider) {
    var webWidth = _webContentWidth(context);
    var phoneWidth = MediaQuery.of(context).size.width * 0.95;

    final sortedData = List<LeaveModel>.from(dataList);
    sortedData.sort((a, b) =>
        DateTime.parse(b.startDate.toString())
            .compareTo(DateTime.parse(a.startDate.toString())));

    return ListView.builder(
      itemCount: sortedData.length,
      itemBuilder: (context, index) {
        final data = sortedData[index];

        final DateTime createdDateTime =
        DateTime.parse(data.createdTs.toString()).toLocal();

        final DateTime now = DateTime.now();

        String dayOfWeek;
        String dateStrLabel = DateFormat('dd MMM yyyy').format(createdDateTime);

        if (createdDateTime.year == now.year &&
            createdDateTime.month == now.month &&
            createdDateTime.day == now.day) {
          dayOfWeek = "Today • $dateStrLabel";
        } else if (createdDateTime.year == now.year &&
            createdDateTime.month == now.month &&
            createdDateTime.day == now.day - 1) {
          dayOfWeek = "Yesterday • $dateStrLabel";
        } else {
          dayOfWeek = DateFormat('dd MMM yyyy').format(createdDateTime);
        }

        final String createdBy =
        DateFormat('dd-MM-yyyy • hh:mm a')
            .format(createdDateTime);

        final start =
        DateTime.parse(data.startDate.toString());

        final end = (data.endDate != null &&
            data.endDate.toString() != "" &&
            data.startDate.toString() !=
                data.endDate.toString())
            ? DateTime.parse(data.endDate.toString())
            : null;

        String displayDate;

        if (end != null) {
          displayDate =
          "${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM').format(end)}";
        } else {
          displayDate =
              DateFormat('EEE, dd MMM').format(start);
        }

        return SizedBox(
          width: kIsWeb ? webWidth : phoneWidth,
          child: Column(
            children: [
              if (index == 0) 10.height,

              SizedBox(
                width: kIsWeb ? webWidth : phoneWidth,
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.end,
                  children: [
                    CustomText(
                      text: dayOfWeek,
                      colors: colorsConst.greyClr,
                    ),
                  ],
                ),
              ),

              6.height,

              Container(
                width: kIsWeb ? webWidth : phoneWidth,
                margin:
                const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(12),
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
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              CustomText(
                                text:
                                data.fName.toString(),
                                size: 16,
                                isBold: true,
                              ),
                              3.height,
                              CustomText(
                                text:
                                data.role.toString(),
                                size: 13,
                                colors:
                                const Color(0xffA80007),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.end,
                            children: [
                              CustomText(
                                text: displayDate,
                                size: 12,
                                isBold: true,
                                colors: const Color(
                                    0xff7E7E7E),
                              ),
                              5.height,
                              Container(
                                padding:
                                const EdgeInsets
                                    .symmetric(
                                    horizontal: 10,
                                    vertical: 5),
                                decoration:
                                BoxDecoration(
                                  color: const Color(
                                      0xffA80007),
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      20),
                                ),
                                child: CustomText(
                                  text:
                                  "${data.type} : ${data.dayType == "0.5" ? "Half / ${data.session}" : "Full Day"}",
                                  size: 11,
                                  colors:
                                  Colors.white,
                                  isBold: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      8.height,

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
                              text:
                              data.reason.toString(),
                              size: 13,
                              colors: const Color(
                                  0xff7E7E7E),
                            ),
                          ),
                        ],
                      ),

                      10.height,

                      Align(
                        alignment:
                        Alignment.centerRight,
                        child: CustomText(
                          text:
                          "Requested On : $createdBy",
                          size: 12,
                          colors: Colors.black,
                          isBold: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (index == sortedData.length - 1)
                80.height,
            ],
          ),
        );
      },
    );
  }
  bool isLate(String? inTime) {
    try {
      print("inTime => $inTime");

      if (inTime == null || inTime.trim().isEmpty || inTime == "null") {
        return false;
      }

      if (inTime.contains(",")) {
        inTime = inTime.split(",")[0].trim();
      }

      if (inTime.isEmpty || inTime == "-") return false;

      final format = DateFormat("hh:mm a");

      DateTime officeTime = format.parse("09:00 AM");

      DateTime userTime = format.parse(inTime);

      return userTime.isAfter(officeTime);

    } catch (e) {
      print("isLate ERROR => $inTime");
      return false;
    }
  }

  DateTime? _parseT(String s) {
    try {
      return DateFormat("hh:mm a").parse(s.trim());
    } catch (_) {
      return null;
    }
  }

  /// time / lat / lng ah pair pannitu, earlier time = In, later time = Out
  _AttParts _splitAttendance(AttendanceModel data, AttendanceProvider att) {
    final times = (data.time ?? "").split(",").map((e) => e.trim()).toList();
    final lats  = (data.lats ?? "").split(",").map((e) => e.trim()).toList();
    final lngs  = (data.lngs ?? "").split(",").map((e) => e.trim()).toList();

    final entries = <_TimeEntry>[];
    for (int i = 0; i < times.length; i++) {
      if (times[i].isEmpty || times[i] == "null" || times[i] == "-") continue;
      entries.add(_TimeEntry(
        times[i],
        i < lats.length ? lats[i] : "",
        i < lngs.length ? lngs[i] : "",
        _parseT(times[i]),
      ));
    }

    // ellaa time um parse aanaa mattum sort pannu
    if (entries.length > 1 && entries.every((e) => e.dt != null)) {
      entries.sort((a, b) => a.dt!.compareTo(b.dt!));
    }

    if (entries.isEmpty) {
      return _AttParts("-", "-", "-", "", "", "", "");
    }

    final _TimeEntry inE = entries.first;
    final _TimeEntry? outE = entries.length > 1 ? entries[1] : null;

    String timeD = "-";
    if (outE != null) {
      timeD = att.timeDifference("${inE.time},${outE.time}");
    }

    return _AttParts(
      inE.time,
      outE?.time ?? "-",
      timeD,
      inE.lat,
      inE.lng,
      outE?.lat ?? "",
      outE?.lng ?? "",
    );
  }

  // ==========================================================================
  // ✅ FILTER HELPERS (date + employee) - provider list la entha data vandhaalum
  // UI la selected From/To date & employee ku match aaganum
  // ==========================================================================
  DateTime? _parseDay(String? v) {
    if (v == null) return null;
    final String t = v.trim();
    if (t.isEmpty || t == "null") return null;
    final String d = t.split(' ')[0].split('T')[0];
    final DateTime? iso = DateTime.tryParse(d);
    if (iso != null) return DateTime(iso.year, iso.month, iso.day);
    for (final f in const ["dd-MM-yyyy", "dd/MM/yyyy", "dd MMM yyyy"]) {
      try {
        final x = DateFormat(f).parseStrict(d);
        return DateTime(x.year, x.month, x.day);
      } catch (_) {}
    }
    return null;
  }

  bool _nameMatch(String? a, String selected) {
    final String n = (a ?? "").trim().toLowerCase();
    final String s2 = selected.trim().toLowerCase();
    if (s2.isEmpty) return true;
    if (n.isEmpty) return false;
    return n == s2 || n.contains(s2) || s2.contains(n);
  }

  /// Present / Late: selected employee mattum
  List<AttendanceModel> _userFiltered(AttendanceProvider att) {
    final String u = (att.user ?? "").toString().trim();
    if (u.isEmpty || u == "null") {
      return List<AttendanceModel>.from(att.getDailyAttendance);
    }
    return att.getDailyAttendance
        .where((e) => e.salesmanId.toString() == u)
        .toList();
  }

  /// Absent: From/To date + employee
  List<dynamic> _filteredAbsent(AttendanceProvider att) {
    final DateTime? fs = _parseDay(att.startDate);
    final DateTime? fe = _parseDay(att.endDate);
    return att.noAttendanceList.where((d) {
      if (fs != null && fe != null) {
        final DateTime? md = _parseDay(d.missingDate?.toString());
        if (md != null && (md.isBefore(fs) || md.isAfter(fe))) return false;
      }
      return _nameMatch(d.firstname?.toString(), att.userName);
    }).toList();
  }

  /// Leave: From/To date (overlap) + employee
  List<LeaveModel> _filteredLeaves(AttendanceProvider att, LeaveProvider lev) {
    final DateTime? fs = _parseDay(att.startDate);
    final DateTime? fe = _parseDay(att.endDate);
    return lev.myLevSearch.where((l) {
      if (fs != null && fe != null) {
        final DateTime? ls = _parseDay(l.startDate?.toString());
        if (ls != null) {
          final DateTime le = _parseDay(l.endDate?.toString()) ?? ls;
          if (le.isBefore(fs) || ls.isAfter(fe)) return false;
        }
      }
      return _nameMatch(l.fName?.toString(), att.userName);
    }).toList();
  }

  String formatCreatedDate(DateTime dateTime) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime dataDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    String dateStr = DateFormat('dd MMM yyyy').format(dateTime);

    if (dataDate == today) {
      return "Today • $dateStr";
    } else if (dataDate == today.subtract(const Duration(days: 1))) {
      return "Yesterday • $dateStr";
    } else {
      return dateStr;
    }
  }
  Widget _filterChip(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff353535),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomText(
            text:text,colors: const Color(0xffF5F5F5),size: 12,
          ),
        ),
      ),
    );
  }
}

/// ✅ Employee field. Tap -> opens a small picker dialog (search + list).
/// Nothing expands inside the filter dialog, so it can't turn blank on web.
class _EmployeeSearchDropdown extends StatelessWidget {
  final double width;
  final EmployeeProvider emp;
  final List<UserModel> fallback;
  final String selectedId;
  final String selectedName;
  final ValueChanged<UserModel> onSelected;

  const _EmployeeSearchDropdown({
    required this.width,
    required this.emp,
    required this.fallback,
    required this.selectedId,
    required this.selectedName,
    required this.onSelected,
  });

  Future<void> _openPicker(BuildContext context) async {
    final UserModel? picked = await showDialog<UserModel>(
      context: context,
      builder: (_) => _EmployeePickerDialog(
        emp: emp,
        fallback: fallback,
        selectedId: selectedId,
      ),
    );

    if (picked != null && context.mounted) {
      onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasName = selectedName.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: "Employee Name", colors: colorsConst.greyClr, size: 12),
        6.height,
        InkWell(
          onTap: () => _openPicker(context),
          borderRadius: BorderRadius.circular(5),
          child: Container(
            height: 40,
            width: width,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: customDecoration.baseBackgroundDecoration(
              radius: 5,
              color: Colors.white,
              borderColor: colorsConst.litGrey,
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    text: hasName ? selectedName : "Select",
                    colors: hasName ? Colors.black : Colors.grey,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_outlined,
                    size: 20, color: colorsConst.greyClr),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ✅ Picker dialog. Reads the employee list LIVE from the provider, so it
/// updates when the list finishes loading. Falls back to the list passed
/// into the page.
class _EmployeePickerDialog extends StatefulWidget {
  final EmployeeProvider emp;
  final List<UserModel> fallback;
  final String selectedId;
  const _EmployeePickerDialog({
    required this.emp,
    required this.fallback,
    required this.selectedId,
  });

  @override
  State<_EmployeePickerDialog> createState() => _EmployeePickerDialogState();
}

class _EmployeePickerDialogState extends State<_EmployeePickerDialog> {
  final TextEditingController _search = TextEditingController();

  /// full list first, then the (possibly narrowed) filter list, then fallback
  List<UserModel> _source() {
    if (widget.emp.userData.isNotEmpty) return widget.emp.userData;
    if (widget.emp.filterUserData.isNotEmpty) return widget.emp.filterUserData;
    return widget.fallback;
  }

  @override
  void initState() {
    super.initState();
    if (_source().isEmpty) {
      // load without clearing anything
      widget.emp.getAllUsers(isRefresh: false);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: kIsWeb ? 380 : w * 0.85,
        height: 420,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: CustomText(
                        text: "Select Employee", size: 15, isBold: true),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              10.height,
              TextField(
                controller: _search,
                autofocus: true,
                cursorColor: colorsConst.primary,
                style: const TextStyle(fontSize: 13),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search, size: 18),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorsConst.litGrey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorsConst.primary),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              8.height,
              Expanded(
                // rebuilds when the provider's list changes (e.g. finishes loading)
                child: AnimatedBuilder(
                  animation: widget.emp,
                  builder: (_, __) {
                    final src = _source();

                    // unique by id, skip empty / "null" names, sort A-Z
                    final Map<String, UserModel> unique = {};
                    for (final u in src) {
                      final n = u.firstname.toString().trim();
                      if (n.isEmpty || n == "null") continue;
                      unique[u.id.toString()] = u;
                    }
                    final String q = _search.text.trim().toLowerCase();
                    final List<UserModel> filtered = unique.values
                        .where((u) =>
                        u.firstname.toString().toLowerCase().contains(q))
                        .toList()
                      ..sort((a, b) => a.firstname
                          .toString()
                          .toLowerCase()
                          .compareTo(b.firstname.toString().toLowerCase()));

                    // still loading the list
                    if (src.isEmpty && !widget.emp.empRefresh) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (filtered.isEmpty) {
                      return const Center(
                        child: CustomText(
                            text: "No employee found",
                            size: 12,
                            colors: Colors.grey),
                      );
                    }

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final u = filtered[i];
                        final bool selected =
                            widget.selectedId == u.id.toString();
                        return InkWell(
                          onTap: () => Navigator.of(context).pop(u),
                          child: Container(
                            width: double.infinity,
                            color: selected ? Colors.grey.shade100 : null,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: CustomText(
                              text: u.firstname.toString(),
                              size: 13,
                              colors: Colors.black,
                              isBold: selected,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ✅ Map KULLA (keela) overlay-a kaattura employee + check in/out + area card
/// ✅ CHANGED: close button remove (map mela top-right la irukku),
/// floating card decoration (rounded + shadow)
class _MapInfoCard extends StatelessWidget {
  final String name;
  final String role;
  final String date;
  final String inTime;
  final String outTime;
  final String totalHrs;
  final Future<String>? inArea;
  final Future<String>? outArea;

  const _MapInfoCard({
    required this.name,
    required this.role,
    required this.date,
    required this.inTime,
    required this.outTime,
    required this.totalHrs,
    this.inArea,
    this.outArea,
  });

  String _clean(String v) {
    final t = v.trim();
    return (t.isEmpty || t == "null") ? "-" : t;
  }

  /// office time 9:00 AM ku apram check in na "Late"
  bool get _isLate {
    try {
      final f = DateFormat("hh:mm a");
      return f.parse(inTime.trim()).isAfter(f.parse("09:00 AM"));
    } catch (_) {
      return false;
    }
  }

  Widget _area(Future<String>? f) {
    if (f == null) return const SizedBox.shrink();
    return FutureBuilder<String>(
      future: f,
      builder: (_, snap) {
        final String t = snap.hasData ? snap.data! : "...";
        if (t.isEmpty || t == "-") return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, size: 12, color: colorsConst.greyClr),
              2.width,
              Expanded(
                child: CustomText(text: t, size: 11, colors: colorsConst.greyClr),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _cell(String label, String value,
      {bool late = false, Future<String>? area}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomText(text: label, size: 11, colors: colorsConst.greyClr),
              if (late) ...[
                4.width,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "Late",
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFFE65100),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          4.height,
          CustomText(
            text: value,
            size: 14,
            isBold: true,
            colors: late ? const Color(0xFFE65100) : Colors.black,
          ),
          _area(area),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String out = _clean(outTime);
    final String total = out == "-" ? "-" : _clean(totalHrs);

    return Container(
      padding: const EdgeInsets.all(14),
      // ✅ CHANGED: floating card look (map mela overlay)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- employee ----------
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade300,
                child: SvgPicture.asset(assets.profile, width: 18, height: 18),
              ),
              10.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: _clean(name),
                      size: 14,
                      isBold: true,
                      colors: Colors.black,
                    ),
                    if (_clean(role) != "-") ...[
                      2.height,
                      CustomText(
                        text: _clean(role),
                        size: 12,
                        colors: colorsConst.blueClr,
                      ),
                    ],
                  ],
                ),
              ),
              if (_clean(date) != "-")
                CustomText(text: _clean(date), size: 12, colors: colorsConst.greyClr),
            ],
          ),
          12.height,
          Divider(height: 1, color: Colors.grey.shade300),
          12.height,
          // ---------- check in / out / total ----------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cell("Check In", _clean(inTime), late: _isLate, area: inArea),
              _cell("Check Out", out, area: out == "-" ? null : outArea),
              _cell("Total Hrs", total),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeEntry {
  final String time, lat, lng;
  final DateTime? dt;
  _TimeEntry(this.time, this.lat, this.lng, this.dt);
}

class _AttParts {
  final String inTime, outTime, timeD, lat1, lng1, lat2, lng2;
  _AttParts(this.inTime, this.outTime, this.timeD, this.lat1, this.lng1, this.lat2, this.lng2);
}