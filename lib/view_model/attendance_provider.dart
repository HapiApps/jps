import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:master_code/view_model/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:master_code/view_model/leave_provider.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../component/custom_text.dart';
import '../model/attendance_model.dart';
import '../model/leave/leave_model.dart';
import '../model/user_model.dart';
import '../repo/attendance_repo.dart';
import '../repo/employee_repo.dart';
import '../screens/attendance/offline_attendance.dart';
import '../screens/common/camera.dart';
import '../source/constant/api.dart';
import '../source/constant/local_data.dart';
import '../source/utilities/utils.dart';

/// Innaiku user-ku irukkura leave nilai
enum LeaveBlock { none, fullDay, firstHalf, secondHalf }

class AttendanceProvider with ChangeNotifier{
  final AttendanceRepository attRepo = AttendanceRepository();
  final EmployeeRepository empRepo = EmployeeRepository();
  final TextEditingController search=TextEditingController();
  bool _mainCheckOut=false;
  bool _decrease=false;
  bool _increase=false;
  bool _isSelfie=false;

  bool get increase=>_increase;
  bool get decrease=>_decrease;
  bool get isSelfie=>_isSelfie;
  bool _isPermission = false;
  bool get isPermission => _isPermission;

  String _permissionStatus = "";
  String get permissionStatus => _permissionStatus;

  void setPermission(bool value) {
    _isPermission = value;
    notifyListeners();
  }

  void setPermissionStatus(String value) {
    _permissionStatus = value;
    notifyListeners();
  }
  void manageSelfie(){
    _isSelfie=!_isSelfie;
    notifyListeners();
  }

  List<AttendanceModel> _noAttendanceList = [];
  List<AttendanceModel> _noAttendanceList2 = [];
  List<LeaveModel> leave = [];
  List<AttendanceModel> get noAttendanceList=>_noAttendanceList;
  List<AttendanceModel> get noAttendanceList2=>_noAttendanceList2;

  void setAttendanceData(List<AttendanceModel> data) {
    _getDailyAttendance = data;
    _searchGetDailyAttendance = data;
    notifyListeners();
  }
  String _report = "Daily";
  String get report=>_report;
  final groupController = GroupButtonController();
  var reportList=["Daily","Weekly","Monthly"];
  final String _date1="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}";
  final String _date2="${DateTime.now().add(const Duration(days: 1)).day.toString().padLeft(2,"0")}-${DateTime.now().add(const Duration(days: 1)).month.toString().padLeft(2,"0")}-${DateTime.now().add(const Duration(days: 1)).year}";
  String get date1=>_date1;
  String get date2=>_date2;
  List attendanceList=[];
  List weekList=[];
  List monthList=[];
  RoundedLoadingButtonController downloadCtr=RoundedLoadingButtonController();
  String _showDate3="";
  String _showDate4="";
  String _showDate5="";
  String _showDate6="";
  dynamic _month=DateFormat('MMMM').format(DateTime(0, int.parse(DateTime.now().month.toString().padLeft(2, "0"))));

  String get month=>_month;
  String get showDate3=>_showDate3;
  String get showDate4=>_showDate4;
  String get showDate5=>_showDate5;
  String get showDate6=>_showDate6;
  bool _filter=false;
  bool get filter=>_filter;

  List<UserModel> _userData=[];
  List<UserModel> get userData => _userData;

  void changeFilter(){
    _filter=true;
    notifyListeners();
  }
  void filterList(){
    final dateFormat = DateFormat('dd-MM-yyyy');
    final parsedDate1 = dateFormat.parse(_startDate);
    final parsedDate2 = dateFormat.parse(_endDate);

    _getDailyAttendance = _searchGetDailyAttendance.where((contact) {
      String timestamp =contact.createdTs.toString();
      List<String> times = timestamp.split(',');
      DateTime startTime = DateTime.parse(times[0]);

      DateTime  createdTsDate = startTime;
      final createdDateOnly = DateTime(createdTsDate.year, createdTsDate.month, createdTsDate.day);

      final isWithinDateRange = !createdDateOnly.isBefore(parsedDate1) && !createdDateOnly.isAfter(parsedDate2);

      final isIdMatch = _user == contact.salesmanId;
      if (_user == null||_user=="") {
        return isWithinDateRange;
      }else {
        return isWithinDateRange && isIdMatch;
      }

    }).toList();
    notifyListeners();
  }

  dynamic _start,_end,year,lastDate,reason,_type;
  void initValues(){
    DateTime selected = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    groupController.selectIndex(0);
    _report= "Daily";
    _start =
    ("01-${(selected.month.toString().padLeft(2, "0"))}-${(selected.year.toString())}");
    var ex = _start.split("-");
    var date = DateTime(int.parse(ex.first), int.parse(ex[1]) + 1,0);
    lastDate = date.day;
    _end = "${date.day.toString().padLeft(2, "0")}-${date.month.toString().padLeft(2, "0")}-${selected.year}";
    _month = DateFormat('MMMM').format(DateTime(0, int.parse(selected.month.toString().padLeft(2, "0"))));
    year = ex[0];
    _showDate5=_start;
    _showDate6=_end;


    DateTime now = DateTime.now();
    int currentDayOfWeek = now.weekday;
    Duration differenceFromMonday = Duration(days: currentDayOfWeek - DateTime.monday);
    DateTime startOfWeek = now.subtract(differenceFromMonday);
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
    DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    String startOfWeekString = dateFormat.format(startOfWeek);
    String endOfWeekString = dateFormat.format(endOfWeek);

    _showDate3=startOfWeekString;
    _showDate4=endOfWeekString;
  }

  String timeDifference(String timeRange) {
    // Split the two times
    List<String> parts = timeRange.split(',');

    DateFormat format = DateFormat("hh:mm a");

    DateTime startTime = format.parse(parts[0].trim());
    DateTime endTime = format.parse(parts[1].trim());

    Duration difference = endTime.difference(startTime);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} Mins";
    } else {
      int hours = difference.inHours;
      int minutes = difference.inMinutes.remainder(60);

      return minutes == 0
          ? "$hours Hrs"
          : "$hours Hrs $minutes Mins";
    }
  }
  String timeDifferences(String inTime, String outTime) {

    // ❌ If any time missing → return "-"
    if (inTime.isEmpty || outTime.isEmpty || inTime == "-" || outTime == "-") {
      return "-";
    }

    try {

      DateTime inDate  = DateFormat("hh:mm a").parse(inTime);
      DateTime outDate = DateFormat("hh:mm a").parse(outTime);

      Duration diff = outDate.difference(inDate);

      int hours   = diff.inHours;
      int minutes = diff.inMinutes.remainder(60);

      return "${hours}h ${minutes}m";

    } catch (e) {
      return "-"; // Prevent crash if API sends bad data
    }
  }
  var typeList = ["Today","Yesterday","Last 7 Days","Last 30 Days","This Week","This Month","Last 3 months"];
  dynamic get type=>_type;
  void changeType(value,String id ,String role,bool? isRefresh,List<UserModel>? list,context){
    _type=value;
    if(_type=="Today"){
      daily(id,role,isRefresh,context);
    }else if(_type=="Yesterday"){
      yesterday(id,role,isRefresh,context);
    }else if(_type=="Last 7 Days"){
      last7Days(id,role,isRefresh,context);
    }else if(_type=="Last 30 Days"){
      last30Days(id,role,isRefresh,context);
    }else if(_type=="This Week"){
      thisWeek(id,role,isRefresh,context);
    }else if(_type=="This Month"){
      thisMonth(id,role,isRefresh,context);
    }else if(_type=="Last 3 months"){
      last3Month(id,role,isRefresh);
    }else{

    }
    // applyFilter(list);
    notifyListeners();
  }

  bool _check=false;
  bool _attCheck=false;
  bool _refresh=false;
  int _mainAttendance=0;
  bool get mainCheckOut=>_mainCheckOut;
  bool get check=>_check;
  bool get attCheck=>_attCheck;
  bool get refresh=>_refresh;
  int get mainAttendance=>_mainAttendance;
  String _inTime = "", _outTime = "-";
  String get inTime=>_inTime;
  String get outTime=>_outTime;

  Future<void> getMainAttendance({bool fromReport = false}) async {
    try {
      final Map data = {
        "action": getAllData,
        "search_type": "user_attendance",
        "id": localData.storage.read("id"),
        "cos_id": localData.storage.read("cos_id"),
      };

      final response = await attRepo.getAttendance(data);
      log(data.toString());
      log(response.toString());

      // Reset AFTER response, so the button never flickers back to "Check In"
      if (!fromReport) {
        _mainCheckOut = false;
        _isPermission = false;
        _mainAttendance = 0;
        _totalHrs = "";
        _permissionStatus = "";
      }

      if (response.isNotEmpty) {
        final String today = DateFormat('dd-MMM-yyyy').format(DateTime.now());
        final String myId = localData.storage.read("id").toString();

        final userData = response.firstWhere(
              (e) => e["salesman_id"].toString() == myId,
          orElse: () => null,
        );

        if (userData != null) {
          // server may send "29-Sep-2026,29-Sep-2026" (in + out)
          final bool isToday = userData["date"]
              .toString()
              .split(",")
              .any((d) => d.trim() == today);

          if (isToday) {
            final String status = userData["status"].toString();
            final List<String> times = (userData["time"]?.toString() ?? "")
                .split(",")
                .map((e) => e.trim())
                .toList();

            /// CHECKOUT
            _mainCheckOut = status.contains("2");

            /// ATTENDANCE STATUS (covers "1", "1,2", "2,1")
            if (status.contains("1")) {
              _mainAttendance = 1;
            }

            /// TIMES
            if (status.contains("1,2")) {
              _inTime = times[0];
              _outTime = times.length > 1 ? times[1] : "-";
              if (times.length > 1) {
                _totalHrs = getTimeDifferenceBetween(_inTime, _outTime);
              }
            } else if (status.contains("2,1")) {
              _outTime = times[0];
              _inTime = times.length > 1 ? times[1] : times[0];
              if (times.length > 1) {
                _totalHrs = getTimeDifferenceBetween(_outTime, _inTime);
              }
            } else if (times.isNotEmpty && times[0].isNotEmpty) {
              _inTime = times[0];
            }

            /// PERMISSION
            final String perStatus = userData["per_status"].toString();
            final String reasonSave = userData["per_reason"].toString();

            if (!fromReport) {
              if (perStatus != "null" && perStatus.isNotEmpty) {
                _permissionStatus = perStatus.split(",").last;
                _isPermission = _permissionStatus == "1";
              } else {
                _permissionStatus = "";
                _isPermission = false;
              }

              if (reasonSave != "null" && reasonSave.isNotEmpty) {
                permissionReason.text = reasonSave.split(",").last;
              }
            }

            /// LATE COUNT
            final String t =
                "${DateTime.now().day.toString().padLeft(2, "0")}-${DateTime.now().month.toString().padLeft(2, "0")}-${DateTime.now().year}";
            getLateCount(t, t);
          }
        }
        _attCheck = true;
      } else {
        _totalHrs = "";
        _permissionStatus = "";
        _attCheck = true;
      }
    } catch (e) {
      print("Attendance Error: $e");
      _attCheck = true;
    }

    if (!fromReport) applyPendingState();

    notifyListeners();
  }
  DateTime parseTime(String time) {
    final now = DateTime.now(); // Get today's date
    final parts = time.split(" ");
    final period = parts[1]; // AM or PM
    final timeParts = parts[0].split(":");
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    if (period == "PM" && hour != 12) {
      hour += 12;
    } else if (period == "AM" && hour == 12) {
      hour = 0;
    }

    return DateTime(now.year, now.month, now.day, hour, minute); // Use today's date
  }
  dynamic _user;
  dynamic get user=>_user;
  String _userName="";
  String get userName=>_userName;
  void selectUser(context,UserModel value,List<UserModel>? list){
    _user=value.id;
    _userName=value.firstname.toString();
    // applyFilter(list);
    notifyListeners();
  }

  void restoreFilter({
    required String start,
    required String end,
    required dynamic type,
    required dynamic user,
    required String userName,
  }) {
    _startDate = start;
    _endDate = end;
    _type = type;
    _user = user;
    _userName = userName;
    notifyListeners();
  }

  List<AttendanceModel> _getDailyAttendance = <AttendanceModel>[];
  List<AttendanceModel> _getUserAttendance = <AttendanceModel>[];
  List<AttendanceModel> _searchGetDailyAttendance = <AttendanceModel>[];
  List<AttendanceModel> get getDailyAttendance => _getDailyAttendance;
  List<AttendanceModel> get getUserAttendance => _getUserAttendance;
  void datePick({required BuildContext context,  required String date, required bool isStartDate}) {
    DateTime dateTime = DateTime.now();
    final parsedDate = DateFormat('dd-MM-yyyy').parse(date);
    final now = DateTime.now();
    DateTime initDate = DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      now.hour,
      now.minute,
      now.second,
    );
    showDatePicker(
      context: context,
      initialDate: initDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    ).then((value) {
      if (value != null) {
        String formattedDate = "${value.day.toString().padLeft(2, "0")}-"
            "${value.month.toString().padLeft(2, "0")}-"
            "${value.year.toString()}";

        if (isStartDate) {
          _startDate = formattedDate;
        } else {
          _endDate = formattedDate;
        }

        notifyListeners();
      }
    });
  }
  List _missingDateList = [];
  List get missingDateList=>_missingDateList;
  DateTime parseDMY(String date) {
    // date = "08-12-2025"
    List<String> parts = date.split("-");
    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  int selectedIndex = 0;

  final List<String> items = [
    "Present",
    "Absent",
    "Late",
    "Leave",
    "Permission",
  ];
  final statusController = GroupButtonController();
  var _grpType;
  get expense => _grpType;
  void changeExpense(String value,int index) {
    _grpType = value;
    selectedIndex=index;
    notifyListeners();
  }
  // Each button color
  final List<Color> itemColors = [
    Colors.green,   // Present
    Colors.red,     // Absent
    Colors.orange,  // Late
    Colors.blue,    // Leave
    Color(0XFFAC30DD),// Leave
  ];
  String lastRefreshed="";
  bool asc=false;
  int permisCount=0;
  int lateCountShow=0;
  String? workDoneDate;
  int _isWorkDone = 0;

  int get isWorkDone => _isWorkDone;

  void setWorkDone(dynamic value) {
    _isWorkDone = int.tryParse(value.toString()) ?? 0;
    notifyListeners();
  }
  bool isWorkDoneToday() {
    if (workDoneDate == null || workDoneDate!.isEmpty) return false;

    try {
      DateTime today = DateTime.now();
      DateTime doneDate = DateTime.parse(workDoneDate!);
      print("today ${today.year == doneDate.year &&
          today.month == doneDate.month &&
          today.day == doneDate.day}");
      return today.year == doneDate.year &&
          today.month == doneDate.month &&
          today.day == doneDate.day;
    } catch (e) {
      return false;
    }
  }
  void filterWorkDoneEmployees() {

    _searchGetDailyAttendance = _getDailyAttendance
        .where((element) => element.isWorkDone == 1)
        .toList();

    notifyListeners();
  }
  void setAttendanceDatas(List<AttendanceModel> data) {
    attendanceList = data;
    notifyListeners();
  }

  void setAbsentData(List<AttendanceModel> data) {
    _noAttendanceList2= data;
    notifyListeners();
  }

  void setLeaveData(List<LeaveModel> data) {
    leave = data;
    notifyListeners();
  }
  Future<void> loadAttendanceDashboard(BuildContext context) async {

    try {

      Map data = {
        "action": "attendance_report",
        "salesman_id": localData.storage.read("id"),
        "role": localData.storage.read("role"),
        "cos_id": localData.storage.read("cos_id"),
        "st_dt": _startDate,
        "en_dt": _endDate,
      };

      final response = await attRepo.getAttendanceFullReport(data);

      final attendanceProvider =
      Provider.of<AttendanceProvider>(context, listen: false);

      /* ================= ATTENDANCE ================= */

      attendanceProvider.setAttendanceData(
        (response["attendance"] as List)
            .map((e) => AttendanceModel.fromJson(e))
            .toList(),
      );

      /* ================= ABSENT ================= */

      attendanceProvider.setAbsentData(
        (response["absent"] as List)
            .map((e) => AttendanceModel.fromJson(e))
            .toList(),
      );

      /* ================= LEAVE ================= */

      attendanceProvider.setLeaveData(
        (response["leave"] as List)
            .map((e) => LeaveModel.fromJson(e))
            .toList(),
      );

    } catch (e) {

      print("Dashboard Error : $e");

    }

  }

  /// Grace 09:10 AM. Late only when check-in is AFTER 09:10
  /// (Excel report / SQL / attendance_detail oda same rule).
  bool isLate(String inTime) {
    try {
      final t = inTime.trim();
      if (t.isEmpty || t == "-" || t == "null") return false;
      final format = DateFormat("hh:mm a");
      return format.parse(t).isAfter(format.parse("09:10 AM"));
    } catch (_) {
      return false; // bad time -> crash aagaadhu
    }
  }
  Future<void> getAttendanceReport(String id)
  async {
    _refresh = false;
    _getDailyAttendance.clear();
    _searchGetDailyAttendance.clear();
    permisCount=0;
    lateCountShow=0;
    notifyListeners();
    try {
      Map data = {
        "action": getAllData,
        "search_type": "get_attendance",
        "salesman_id": id,
        "role": localData.storage.read("role"),
        "cos_id":localData.storage.read("cos_id"),
        "st_dt": _startDate,
        "en_dt": _endDate
      };
      print("attendance report now data: ${data}");
      final response = await attRepo.getReport(data);
      print("response");
      if (response.isNotEmpty){
        _getDailyAttendance=response;
        _searchGetDailyAttendance=response;
        int count=0;
        int count2=0;
        _isWorkDone = int.tryParse(response[0].isWorkDone.toString()) ?? 0;
        notifyListeners();
        print("Work Done Value ---> $_isWorkDone");
        for(var i=0;i<response.length;i++){
          if(response[i].perStatus.toString()!="null"){
            count++;
          }
        }
        permisCount=count;
        for(var i=0;i<response.length;i++){
          var inTime = "";
          if (response[i].status.toString().contains("1,2")) {
            inTime = response[i].time!.split(",")[0];
          }else if (response[i].status.toString().contains("2,1")) {
            inTime = response[i].time!.split(",")[1];
          }else {
            inTime = response[i].time!.split(",")[0];
          }
          if(isLate(inTime)){
            count2++;
          }
        }
        lateCountShow=count2;
        if(_filter==true){
          filterList();
        }
        _refresh = true;
      }else {
        _refresh = true;
      }
      lastRefreshed=DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now());
      notifyListeners();
    } catch (e) {
      notifyListeners();
    }
    notifyListeners();
  }
  Future<void> getAbsentAttendanceReport(String id)
  async {
    _refresh = false;
    _noAttendanceList.clear();
    notifyListeners();
    try {
      Map data = {
        "action": getAllData,
        "search_type": "absent_attendance",
        "salesman_id": id,
        "role": localData.storage.read("role"),
        "cos_id":localData.storage.read("cos_id"),
        "st_dt": _startDate,
        "en_dt": _endDate
      };
      final response = await attRepo.getReport(data);

      if (response.isNotEmpty){
        _noAttendanceList2=response;
        if (_filter == true) {
          final dateFormat = DateFormat('dd-MM-yyyy');
          final parsedDate1 = dateFormat.parse(_startDate);
          final parsedDate2 = dateFormat.parse(_endDate);

          _noAttendanceList = response.where((contact) {
            // API la irukura date
            DateTime missingDate = DateTime.parse(contact.missingDate.toString());

            final createdDateOnly =
            DateTime(missingDate.year, missingDate.month, missingDate.day);

            final isWithinDateRange = !createdDateOnly.isBefore(parsedDate1) &&
                !createdDateOnly.isAfter(parsedDate2);

            final isIdMatch = _user == contact.id;

            if (_user == null || _user == "") {
              return isWithinDateRange;
            } else {
              return isWithinDateRange && isIdMatch;
            }
          }).toList();
        }else{
          _noAttendanceList=response;
        }
        _refresh = true;
      }else {
        _refresh = true;
      }
      notifyListeners();
    } catch (e) {
      _refresh = true;
      notifyListeners();
    }
    notifyListeners();
  }
  Future<void> getUserAttendanceReport(String id,String role,bool isFilter,{bool? isAbsent,bool? isLate,List<UserModel>? list}) async {
    _refresh = false;
    _getUserAttendance.clear();
    notifyListeners();
    try {
      Map data = {
        "action": getAllData,
        "search_type": "get_attendance",
        "salesman_id": id,
        "role": role,
        "cos_id":localData.storage.read("cos_id"),
        "st_dt": _startDate,
        "en_dt": _endDate
      };
      final response = await attRepo.getReport(data);
      print(data.toString());
      if (response.isNotEmpty){
        _getUserAttendance=response;
        _refresh = true;
      }else {
        _refresh = true;
      }
      notifyListeners();
    } catch (e) {
      _refresh = true;
      notifyListeners();
    }
    notifyListeners();
  }
  int _lateCount=0;
  int get lateCount=>_lateCount;
  Future<void> getLateCount(String startDate,String endDate) async {
    try {
      Map data = {
        "action": getAllData,
        "search_type": "get_attendance",
        "salesman_id": localData.storage.read("id"),
        "role": localData.storage.read("role"),
        "cos_id":localData.storage.read("cos_id"),
        "st_dt": startDate,
        "en_dt": endDate
      };
      print(data.toString());
      final response = await attRepo.getReport(data);

      print(response.toString());
      if (response.isNotEmpty) {
        _lateCount = 0;

        for (var i = 0; i < response.length; i++) {
          try {
            // Safely access and process the timestamp string
            var createdTsStr = response[i].createdTs?.toString() ?? "";
            if (createdTsStr.isEmpty) continue;

            // Take only the first timestamp and trim spaces
            var firstTs = createdTsStr.split(",")[0].trim();

            var createdTs = DateTime.parse(firstTs);

            // Grace till 09:10 (minute level) -> 09:10:59 varaikkum late illa
            var cutoff = DateTime(
              createdTs.year,
              createdTs.month,
              createdTs.day,
              9,  // Hour
              10, // Minute
              59, // Second
            );
            if (createdTs.isAfter(cutoff)) {
              _lateCount++;
            }
          } catch (e) {
            print("Error parsing createdTs at index $i: $e");
          }
        }

        print("Total late count: $_lateCount");

      }
      else {
        _lateCount = 0;
      }
    } catch (e) {
      _lateCount = 0;
    }
    notifyListeners();
  }

  String _totalHrs = "";
  String _totalHrs2 = "";
  String get totalHrs=>_totalHrs;
  String get totalHrs2=>_totalHrs2;

  String getTimeDifferenceBetween(String time1, String time2) {
    DateTime now = DateTime.now();

    DateTime? parseTime(String timeStr) {
      final regex = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false);
      final match = regex.firstMatch(timeStr.trim());

      if (match == null) return null;

      int hour = int.parse(match.group(1)!);
      int minute = int.parse(match.group(2)!);
      String period = match.group(3)!.toUpperCase();

      // Convert to 24-hour format
      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      return DateTime(now.year, now.month, now.day, hour, minute);
    }

    DateTime? dt1 = parseTime(time1);
    DateTime? dt2 = parseTime(time2);

    if (dt1 == null || dt2 == null) return 'Invalid time format';

    Duration difference = dt1.difference(dt2).abs();

    int hours = difference.inHours;
    int minutes = difference.inMinutes % 60;

    return '$hours : $minutes mins';
  }

  void searchAttendanceReport(String value) {

    final input = value.toLowerCase().trim();

    /// RESET WHEN SEARCH EMPTY
    if (input.isEmpty) {

      _getDailyAttendance = List.from(_searchGetDailyAttendance);
      _noAttendanceList = List.from(_noAttendanceList2);

      notifyListeners();
      return;
    }

    /// SEARCH PRESENT LIST
    final suggestions = _searchGetDailyAttendance.where((user) {

      final name = user.firstname.toString().toLowerCase();
      final role = user.role.toString().toLowerCase();

      return name.contains(input) || role.contains(input);

    }).toList();

    _getDailyAttendance = suggestions;

    /// SEARCH ABSENT LIST
    final suggestions2 = _noAttendanceList2.where((user) {

      final name = user.firstname.toString().toLowerCase();

      return name.contains(input);

    }).toList();

    _noAttendanceList = suggestions2;

    notifyListeners();
  }
  void searchAttendanceReport2(String value){
    List old=missingDateList;
    final suggestions=missingDateList.where(
            (user){
          final comFName=user.toString().toLowerCase();
          final input=value.toString().toLowerCase();
          return comFName.contains(input);
        }).toList();
    _missingDateList=suggestions;
    if(value.isEmpty){
      _missingDateList=old;
    }
    notifyListeners();
  }
  String _startDate = "";
  String get startDate => _startDate;
  String _endDate="";
  String get endDate => _endDate;
  DateTime stDt = DateTime.now();
  DateTime enDt = DateTime.now().add(const Duration(days: 1));
  PickerDateRange? selectedDate;
  List<DateTime> datesBetween = [];
  String betweenDates="";
  void sorting(context) {
    if (asc) {
      // ASC → A to Z
      _getDailyAttendance.sort((a, b) => (a.firstname ?? '').compareTo(b.firstname ?? ''));
      _noAttendanceList.sort((a, b) => (a.firstname ?? '').compareTo(b.firstname ?? ''));
      Provider.of<LeaveProvider>(context, listen: false).myLevSearch.sort((a, b) => (a.fName ?? '').compareTo(b.fName ?? ''));
      asc = false;
    } else {
      // DESC → Z to A
      _getDailyAttendance.sort((a, b) => (b.firstname ?? '').compareTo(a.firstname ?? ''));
      _noAttendanceList.sort((a, b) => (b.firstname ?? '').compareTo(a.firstname ?? ''));
      Provider.of<LeaveProvider>(context, listen: false).myLevSearch.sort((a, b) => (b.fName ?? '').compareTo(a.fName ?? ''));
      asc = true;
    }

    notifyListeners(); // if using Provider
    print(asc);
  }

  void initDate({required String id, required String role, bool? isRefresh, String? date1, String? date2, String? type}){
    _type=type ?? "Today";
    _increase=false;
    _decrease=false;
    asc=false;
    // selectedIndex=0;
    search.clear();
    _filter=false;
    _user=null;
    _userName="";
    _user="";
    _startDate=date1 ??_startDate;
    _endDate=date2 ??_endDate;
    notifyListeners();
  }
  void daily(String id ,String role,bool? isRefresh,context) {
    stDt=DateTime.now();
    enDt=DateTime.now().add(const Duration(days: 1));
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(stDt);
    if(localData.storage.read("role")!="1"){
      getAttendanceReport(id,);
      getAbsentAttendanceReport(id);
      Provider.of<LeaveProvider>(context, listen: false).allLeaves(_startDate,_endDate,true,localData.storage.read("role"),localData.storage.read("id"));
    }
    notifyListeners();
  }
  void yesterday(String id ,String role,bool? isRefresh,context) {
    stDt=DateTime.now().subtract(const Duration(days: 1));
    enDt = DateTime.now();
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(stDt);
    if(localData.storage.read("role")!="1"){
      getAttendanceReport(id,);
      getAbsentAttendanceReport(id);
      Provider.of<LeaveProvider>(context, listen: false).allLeaves(_startDate,_endDate,true,localData.storage.read("role"),localData.storage.read("id"));
    }
    notifyListeners();
  }
  void last7Days(String id ,String role,bool? isRefresh,context) {
    DateTime now = DateTime.now();
    DateTime lastWeekStart = now.subtract(const Duration(days: 6));
    DateTime lastWeekEnd = now;
    _startDate = DateFormat('dd-MM-yyyy').format(lastWeekStart);
    _endDate = DateFormat('dd-MM-yyyy').format(lastWeekEnd);
    if(localData.storage.read("role")!="1"){
      getAttendanceReport(id,);
      getAbsentAttendanceReport(id);
      Provider.of<LeaveProvider>(context, listen: false).allLeaves(_startDate,_endDate,true,localData.storage.read("role"),localData.storage.read("id"));
    }
    notifyListeners();
  }
  void last30Days(String id ,String role,bool? isRefresh,context) {
    DateTime now = DateTime.now();
    DateTime lastMonthStart = now.subtract(const Duration(days: 29));
    DateTime lastMonthEnd = now;
    _startDate = DateFormat('dd-MM-yyyy').format(lastMonthStart);
    _endDate = DateFormat('dd-MM-yyyy').format(lastMonthEnd);
    if(localData.storage.read("role")!="1"){
      getAttendanceReport(id,);
      getAbsentAttendanceReport(id);
      Provider.of<LeaveProvider>(context, listen: false).allLeaves(_startDate,_endDate,true,localData.storage.read("role"),localData.storage.read("id"));
    }
    notifyListeners();
  }
  void thisWeek(String id ,String role,bool? isRefresh,context) {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;
    DateTime stDt = now.subtract(Duration(days: currentWeekday - 1));
    DateTime enDt = now.add(Duration(days: 7 - currentWeekday));
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    if(localData.storage.read("role")!="1"){
      getAttendanceReport(id,);
      getAbsentAttendanceReport(id);
      Provider.of<LeaveProvider>(context, listen: false).allLeaves(_startDate,_endDate,true,localData.storage.read("role"),localData.storage.read("id"));
    }
    notifyListeners();
  }
  void thisMonth(String id ,String role,bool? isRefresh,context) {
    DateTime now = DateTime.now();
    stDt = DateTime(now.year, now.month, 1);
    enDt = now; // Today’s date
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    if(localData.storage.read("role")!="1"){
      getAttendanceReport(id,);
      getAbsentAttendanceReport(id);
      Provider.of<LeaveProvider>(context, listen: false).allLeaves(_startDate,_endDate,true,localData.storage.read("role"),localData.storage.read("id"));
    }
    notifyListeners();
  }
  String _monthName = DateFormat('MMMM yyyy').format(DateTime.now());
  String get monthName => _monthName;
  void increaseMonth(String id, String role, bool? isRefresh) {
    // Move to next month
    stDt = DateTime(stDt.year, stDt.month + 1, 1);
    enDt = DateTime(stDt.year, stDt.month + 1, 0);
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    _monthName = DateFormat('MMMM yyyy').format(stDt);
    getUserAttendanceReport(id, role, true);
    notifyListeners();
  }

  void decreaseMonth(String id, String role, bool? isRefresh) {
    // Move to previous month
    stDt = DateTime(stDt.year, stDt.month - 1, 1);
    enDt = DateTime(stDt.year, stDt.month, 0);
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    _monthName = DateFormat('MMMM yyyy').format(stDt);
    getUserAttendanceReport(id, role, true);
    notifyListeners();
  }

  void last3Month(String id, String role, bool? isRefresh) {
    DateTime now = DateTime.now();
    DateTime stDt = DateTime(now.year, now.month - 3, now.day);
    DateTime enDt = now;

    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    if (localData.storage.read("role") != "1") {
      getAttendanceReport(id);
      getAbsentAttendanceReport(id);
    }
    notifyListeners();
  }
  void applyFilter(List<UserModel>? list){
    if(selectedIndex==1){
      getAttendanceReport(localData.storage.read("id"));
    }else if(selectedIndex==2){
      getAttendanceReport(localData.storage.read("id"));
    }else{
      getAttendanceReport(localData.storage.read("id"));
    }
  }
  void showDatePickerDialog(BuildContext context,List<UserModel>? list) {
    selectedDate=null;
    datesBetween = [];
    betweenDates="";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomText(text: '   Select Date',colors: colorsConst.secondary,isBold: true,),
          content: SizedBox(
            height: 300, // Adjust height as needed
            width: 300, // Adjust width as needed
            child: SfDateRangePicker(
              minDate: DateTime.now().subtract(const Duration(days: 365)),
              maxDate: DateTime.now(),
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                selectedDate = args.value;
                _startDate="";
                _endDate="";
                if(selectedDate?.endDate!=null){
                  print("start end");
                  _startDate="${selectedDate?.startDate?.day.toString().padLeft(2,"0")}"
                      "-${selectedDate?.startDate?.month.toString().padLeft(2,"0")}"
                      "-${selectedDate?.startDate?.year.toString()}";

                  _endDate="${selectedDate?.endDate?.day.toString().padLeft(2,"0")}"
                      "-${selectedDate?.endDate?.month.toString().padLeft(2,"0")}"
                      "-${selectedDate?.endDate?.year.toString()}";
                }else{
                  print("end");
                  _startDate="${selectedDate?.startDate?.day.toString().padLeft(2,"0")}"
                      "-${selectedDate?.startDate?.month.toString().padLeft(2,"0")}"
                      "-${selectedDate?.startDate?.year.toString()}";
                  _endDate="${selectedDate?.startDate?.day.toString().padLeft(2,"0")}"
                      "-${selectedDate?.startDate?.month.toString().padLeft(2,"0")}"
                      "-${selectedDate?.startDate?.year.toString()}";
                  if(_startDate=="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}"){
                    _decrease=true;
                    _increase=false;
                  }
                }
              },
              selectionMode: DateRangePickerSelectionMode.range,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(text: 'Click and drag to select multiple dates',colors: colorsConst.primary,),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: const CustomText(text:'Cancel',colors: Colors.grey,isBold: true,),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: CustomText(text: 'OK',colors: colorsConst.primary,isBold: true,),
                  onPressed: () {
                    if (selectedDate != null) {
                      datesBetween = getDatesInRange(
                        selectedDate!.startDate!,
                        selectedDate!.endDate ?? selectedDate!.startDate!,
                      );
                    }
                    DateFormat dateFormat = DateFormat('dd-MM-yyyy');

                    List<String> formattedDates = datesBetween.map((date) => dateFormat.format(date)).toList();
                    betweenDates = formattedDates.join(' || ');
                    applyFilter(list);
                    notifyListeners();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
    notifyListeners();
  }
  List<DateTime> getDatesInRange(DateTime start, DateTime end) {
    List<DateTime> days = [];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      days.add(DateTime(start.year, start.month, start.day + i));
    }
    return days;
  }

  String _profile="";
  String get profile=>_profile;
  Future<void> signDialog({required BuildContext context, required String img,required Function(String newImg) onTap}) async {
    var imgData = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const CameraWidget(
              cameraPosition: CameraType.front,
              isSelfie: true,
            )));
    if (!context.mounted) return;
    // Navigator.pop(context);
    if (imgData != null) {
      onTap(imgData);
    }
  }
  void profilePick(String imgData){
    _profile = imgData;
    notifyListeners();
  }

  // =====================================================================
  // ✅ CHANGED BLOCK START  (offline sync / attendance fix)
  // =====================================================================

  bool _syncing = false;
  bool get isSyncing => _syncing;

  // =====================================================================
  // LEAVE vs ATTENDANCE  (NEW)
  // =====================================================================

  LeaveBlock _todayLeave = LeaveBlock.none;
  LeaveBlock get todayLeave => _todayLeave;

  /// Check-in pannitu apram full-day leave potta -> UI "On Leave" nu kaattum
  /// (check-in panni checkout pannala nu kaattakoodadhu)
  bool get leaveAfterCheckIn =>
      _todayLeave == LeaveBlock.fullDay && _mainAttendance == 1 && !_mainCheckOut;

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// dd-MM-yyyy  &  yyyy-MM-dd rendaiyum parse pannum (string compare bug fix)
  DateTime? _parseAnyDate(dynamic v) {
    final s = v?.toString().trim() ?? "";
    if (s.isEmpty || s == "null") return null;
    try {
      final datePart = s.split(" ").first.split("T").first;
      final p = datePart.split("-");
      if (p.length == 3) {
        if (p[0].length == 4) {
          return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
        }
        return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
      }
      return _dateOnly(DateTime.parse(s));
    } catch (_) {
      return null;
    }
  }

  /// Leave data server-la irundhu load aagiducha nu (fail-open fallback-ku)
  bool _leaveChecked = false;
  bool get leaveChecked => _leaveChecked;

  /// TRUE na mattum attendance block. Full-day leave + innum check-in pannala.
  /// Check-in pannitu apram leave potta -> check-OUT allow.
  /// Half-day leave -> eppovum allow.
  bool get attendanceBlockedByLeave =>
      _todayLeave == LeaveBlock.fullDay && _mainAttendance == 0;

  /// status "1" = approved (approveApply-la status=="1" -> approve).
  bool _isApprovedLeave(String? st) {
    final s = (st ?? "").toLowerCase().trim();
    return s == "1" || s.contains("approv");
  }

  /// LOGGED-IN user-oda leave list kudunga (LeaveProvider.refreshMyTodayLeave call pannum)
  void computeTodayLeave(List<LeaveModel> leaves) {
    final today = _dateOnly(DateTime.now());
    final myId = localData.storage.read("id").toString();
    LeaveBlock result = LeaveBlock.none;

    for (final l in leaves) {
      // vera user-oda leave irundha ignore
      final uid = l.userId?.toString() ?? "";
      if (uid.isNotEmpty && uid != myId) continue;

      // APPROVED mattum
      if (!_isApprovedLeave(l.status)) continue;

      final from = _parseAnyDate(l.startDate);
      final to = _parseAnyDate(l.endDate) ?? from;
      if (from == null || to == null) continue;

      // date-only, inclusive -> "next day block aagudhu" bug fix
      if (today.isBefore(from) || today.isAfter(to)) continue;

      if (l.dayType?.toString() == "0.5") {
        // half day -> block illa, result mattum note pannum
        if (result == LeaveBlock.none) {
          final sess = (l.session ?? "").toLowerCase();
          result = sess.contains("after")
              ? LeaveBlock.secondHalf
              : LeaveBlock.firstHalf;
        }
      } else {
        result = LeaveBlock.fullDay;
        break;
      }
    }

    _leaveChecked = true;
    _todayLeave = result;
    notifyListeners();
  }

  bool _isMarking = false;
  bool _isMarkingPermission = false;

  /// Last reason a sync failed (shown in the toast, useful for debugging).
  String _lastSyncError = "";
  String get lastSyncError => _lastSyncError;

  String _lastAttError = "";

  /// A server reply counts as success only if it is non-empty AND does not
  /// say error/failed. Adjust the list to match what your PHP returns.
  bool _isSuccessResponse(dynamic response) {
    if (response is! Map || response.isEmpty) return false;
    const bad = ["error", "failed", "fail", "false", "0"];
    final status = response["status"]?.toString().toLowerCase();
    if (status != null && bad.contains(status)) return false;
    return true;
  }

  /// 1️⃣ Pure API call. Dialog/toast illa. Online + sync rendukkum use aagum.
  Future<bool> _sendAttendance({
    required String status,
    required String lat,
    required String lng,
    String? markedAt,
    String? empId,
  }) async {
    _lastAttError = "";
    try {
      final String uid = (empId ?? localData.storage.read("id"))?.toString() ?? "";

      final Map<String, String> requestData = {
        "action": empAttendance,
        "log_file": localData.storage.read("mobile_number")?.toString() ?? "",
        "salesman_id": uid,
        "lat": lat,
        "lng": lng,
        "img": "",
        "status": status,
        "cos_id": localData.storage.read("cos_id")?.toString() ?? "",
      };

      if (markedAt != null) {
        requestData["emp_id"] = uid;
        requestData["is_offline"] = "1";
        if (status == "1") {
          requestData["check_in"] = markedAt;
        } else {
          requestData["check_out"] = markedAt;
        }
      }

      log("ATT REQ: $requestData");

      dynamic response;
      try {
        response = await attRepo.addAttendance(requestData, _profile);
      } catch (e, st) {
        log("ATT ERROR: $e\n$st");
        _lastAttError = e.toString();
        response = {};
      }
      log("ATT RES: $response");

      final ok = _isSuccessResponse(response);
      if (!ok && _lastAttError.isEmpty) {
        if (response is Map && response.isNotEmpty) {
          _lastAttError = (response["message"] ??
              response["msg"] ??
              response["error"] ??
              response.toString())
              .toString();
        } else {
          _lastAttError = "Empty response from server";
        }
      }
      return ok;
    } catch (e, st) {
      log("sendAttendance error: $e\n$st");
      _lastAttError = e.toString();
      return false;
    }
  }

  /// 2️⃣ Wages + attendance JSON-a server-ku anuppu
  // item -> Map illa List<Map> rendume accept pannum
  // CHANGED: returns SyncResult (ok / retry / message) instead of bool
  Future<SyncResult> _sendOfflineWages(dynamic input) async {
    try {
      List<Map<String, dynamic>> toList(dynamic raw) {
        if (raw is Map) {
          return raw.isEmpty ? [] : [Map<String, dynamic>.from(raw)];
        }
        if (raw is List) {
          return raw
              .whereType<Map>()
              .where((e) => e.isNotEmpty)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        return [];
      }

      String pick(dynamic primary, dynamic fallback, [String def = ""]) {
        final x = primary?.toString() ?? "";
        if (x.isNotEmpty) return x;
        final y = fallback?.toString() ?? "";
        return y.isNotEmpty ? y : def;
      }

      String fullDateTime(String v, String markedAt) {
        if (v.isEmpty) return "";
        if (v.contains("-")) return v;
        final t = v.split(":").length == 2 ? "$v:00" : v;
        // CHANGED: guard substring so a short markedAt can't throw RangeError
        final datePart = markedAt.length >= 10
            ? markedAt.substring(0, 10)
            : DateTime.now().toString().substring(0, 10);
        return "$datePart $t";
      }

      final String userId = localData.storage.read("id")?.toString() ?? "";
      final String cosId = localData.storage.read("cos_id")?.toString() ?? "";

      // input Map-a irundhalum List-a irundhalum -> items list
      final List<Map<String, dynamic>> items = toList(input);

      final List<Map<String, dynamic>> attendanceRows = [];
      final List<Map<String, dynamic>> wagesRows = [];

      for (final item in items) {
        final wList = toList(item["wagesData"]);
        final aList = toList(item["attendanceData"]);
        if (wList.isEmpty && aList.isEmpty) continue;

        final String defaultMarkedAt = pick(
          item["markedAt"],
          null,
          DateTime.now().toString().substring(0, 19),
        );

        // ---- Attendance ----
        for (int i = 0; i < aList.length; i++) {
          final a = aList[i];
          final w = i < wList.length ? wList[i] : <String, dynamic>{};

          final String markedAt = pick(a["markedAt"], defaultMarkedAt);

          String status = pick(a["status"], w["status"]);
          if (status.isEmpty || status == "0") status = "1";

          final String rawIn = pick(a["check_in"], w["check_in"]);
          final String rawOut = pick(a["check_out"], w["check_out"]);

          attendanceRows.add({
            "emp_id": pick(a["emp_id"], item["emp_id"]),
            "user_id": userId,
            "check_in": status == "1"
                ? fullDateTime(rawIn.isEmpty ? markedAt : rawIn, markedAt)
                : "",
            "check_out": status == "2"
                ? fullDateTime(rawOut.isEmpty ? markedAt : rawOut, markedAt)
                : "",
            "status": status,
            "lat": pick(a["lat"], item["lat"]),
            "lng": pick(a["lng"], item["lng"]),
          });
        }

        // ---- Wages ----
        for (final w in wList) {
          wagesRows.add({
            "wage_emp_id": w["wage_emp_id"]?.toString() ?? "",
            "task_id": w["task_id"]?.toString() ?? "",
            "wages_description": w["wages_description"]?.toString() ?? "",
            "check_in": w["check_in"]?.toString() ?? "",
            "check_out": w["check_out"]?.toString() ?? "",
            "status": pick(w["status"], null, "1"),
            "lat": pick(w["lat"], item["lat"]),
            "lng": pick(w["lng"], item["lng"]),
          });
        }
      }

      if (attendanceRows.isEmpty && wagesRows.isEmpty) {
        log("sendOfflineWages: empty entry, skipping");
        return const SyncResult(true, false, "empty entry"); // empty entry-a delete panna ok
      }

      final Map<String, dynamic> body = {
        "action": "insert_offline_wages",
        "cos_id": cosId,
        "user_id": userId,
        if (attendanceRows.isNotEmpty) "attendanceData": attendanceRows,
        if (wagesRows.isNotEmpty) "wagesData": wagesRows,
      };

      log("wages request: ${jsonEncode(body)}");

      final r = await attRepo.insertOfflineWagesResult(body);
      log("wages sync: $r");
      return r;
    } catch (e, st) {
      // Bad local data (not a network problem) -> retry=false so it counts
      // toward maxRejects instead of blocking the queue forever.
      log("sendOfflineWages error: $e\n$st");
      return SyncResult(false, false, "Local data error: $e");
    }
  }
  void _refreshAfterAttendance(BuildContext context) {
    final now = DateTime.now();
    final today =
        "${now.day.toString().padLeft(2, "0")}-${now.month.toString().padLeft(2, "0")}-${now.year}";

    Provider.of<HomeProvider>(context, listen: false).loadFullDashboard(context);
    getMainAttendance();
    initDate(
      id: localData.storage.read("id"),
      role: localData.storage.read("role"),
      isRefresh: true,
      date1: today,
      date2: today,
    );
    getAttendanceReport(localData.storage.read("id"));
  }

  /// 4️⃣ Offline-la save
  /// CHANGED: optional [message] so the caller can say WHY it was queued
  Future<void> saveOffline(
      BuildContext context,
      String kind,
      String status,
      String lat,
      String lng, {
        String? reason,
        String? message,
      }) async {
    await OfflineAttendanceService.add(
      kind: kind,
      status: status,
      lat: lat,
      lng: lng,
      reason: reason,
    );

    // UI-a local-a maathu, appo thaan button text/color maarum
    if (kind == "attendance") {
      if (status == "1") {
        _mainAttendance = 1;
      } else {
        _mainAttendance = 1;
        _mainCheckOut = true;
      }
    }
    notifyListeners();

    if (context.mounted) {
      utils.showSuccessToast(
        context: context,
        text: message ?? "No internet. Saved offline, will sync later.",
      );
    }
  }

  /// 5️⃣ Main function (button click-la ithu thaan call aagum)
  Future putDailyAttendance(
      BuildContext context,
      String status,
      String? lat,
      String? lng,
      ) async {
    // Block double tap / selfie + button race
    if (_isMarking) return;

    // Location validation
    if (lat == null ||
        lng == null ||
        lat.isEmpty ||
        lng.isEmpty ||
        lat == "0.0" ||
        lng == "0.0") {
      utils.showWarningToast(
        context,
        text: "Location not available. Please enable GPS and try again.",
      );
      return;
    }

    // FULL-DAY leave + innum check-in pannala -> block.
    // Half-day leave -> ALLOW (oru session work pannuvaanga).
    // Check-in pannitu apram leave potta -> check-OUT ku allow.
    if (_todayLeave == LeaveBlock.fullDay && _mainAttendance == 0) {
      utils.showWarningToast(context, text: "You are on leave today");
      return;
    }

    _isMarking = true;
    try {
      // Net illana offline save
      final online = await OfflineAttendanceService.isOnline();
      if (!online) {
        await saveOffline(context, "attendance", status, lat, lng);
        return;
      }

      // CHANGED: Pending irundha muthala SILENT-a sync pannu (no error toast here)
      if (OfflineAttendanceService.hasPending) {
        await syncPending(context, silent: true);
      }
      if (!context.mounted) return;

      // CHANGED: earlier attendance entries still stuck na, indha tap-a
      // server-ku direct-a anuppaadha (check-out before check-in reject aagum).
      // Queue-la pinnadi save pannu, order maaraadhu.
      if (OfflineAttendanceService.attendancePendingCount > 0) {
        await saveOffline(
          context,
          "attendance",
          status,
          lat,
          lng,
          message: "Saved. Earlier entries are still pending, will sync in order.",
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(
              child: Column(
                children: [
                  const CustomText(
                      text: "Attendance Marking",
                      colors: Colors.grey,
                      size: 15,
                      isBold: true),
                  10.height,
                  const CustomText(
                      text: "Please Wait",
                      colors: Colors.grey,
                      size: 15,
                      isBold: true),
                  20.height,
                  LoadingAnimationWidget.staggeredDotsWave(
                      color: colorsConst.secondary, size: 25),
                ],
              ),
            ),
          );
        },
      );

      final ok = await _sendAttendance(status: status, lat: lat, lng: lng);

      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (!context.mounted) return;

      if (ok) {
        utils.showSuccessToast(
          text: status == "1" ? "Check In Successfully" : "Check Out Successfully",
          context: context,
        );
        _refreshAfterAttendance(context);
      } else {
        utils.showErrorToast(context: context);
      }
    } finally {
      _isMarking = false;
    }
  }

  /// CHANGED: [silent] = no error toast (used when called from putDailyAttendance).
  /// A server-rejected item no longer blocks the whole queue.
  Future<void> syncPending(
      BuildContext context, {
        bool manual = false,
        bool silent = false,
      }) async {
    if (_syncing) return;

    // Remove entries nothing can upload (e.g. kind == "permission"),
    // otherwise they keep the pending count above zero forever.
    await OfflineAttendanceService.purgeUnsupported();

    if (!OfflineAttendanceService.hasPending) {
      if (manual && context.mounted) {
        utils.showWarningToast(context, text: "No pending data");
      }
      return;
    }

    if (!await OfflineAttendanceService.isOnline()) {
      if (manual && context.mounted) {
        utils.showWarningToast(context, text: "No internet. Try again later.");
      }
      return;
    }

    _syncing = true;
    _lastSyncError = "";
    notifyListeners();

    int synced = 0;
    int dropped = 0;
    bool failed = false;
    bool stop = false; // network/server down -> stop, try again later

    try {
      // 1) Attendance entries
      for (final item in OfflineAttendanceService.getAll()) {
        final kind = item["kind"]?.toString();
        final id = item["id"].toString();

        final SyncResult r;
        if (kind == "attendance") {
          r = await _sendOfflineAttendance(item);
        } else if (kind == "wages") {
          r = await _sendOfflineWages(item);
        } else {
          continue;
        }

        if (r.ok) {
          await OfflineAttendanceService.remove(id);
          synced++;
        } else if (r.retry) {
          // Network / 5xx / timeout: keep item, stop, try again later.
          failed = true;
          _lastSyncError = r.message;
          stop = true;
          break;
        } else {
          // Server REJECTED this item: count it, don't block the rest.
          failed = true;
          _lastSyncError = r.message;
          final n = await OfflineAttendanceService.markAttemptFailed(id,
              wages: false, error: r.message);
          if (n >= OfflineAttendanceService.maxRejects) {
            log("DROP attendance item $id after $n rejects: ${r.message}");
            await OfflineAttendanceService.remove(id);
            dropped++;
          }
        }
      }

      // 2) Wages (thani list)
      if (!stop) {
        for (final item in OfflineAttendanceService.getAllWages()) {
          final id = item["id"].toString();
          final r = await _sendOfflineWages(item);

          if (r.ok) {
            await OfflineAttendanceService.removeWage(id);
            synced++;
          } else if (r.retry) {
            failed = true;
            _lastSyncError = r.message;
            break;
          } else {
            failed = true;
            _lastSyncError = r.message;
            final n = await OfflineAttendanceService.markAttemptFailed(id,
                wages: true, error: r.message);
            if (n >= OfflineAttendanceService.maxRejects) {
              log("DROP wages item $id after $n rejects: ${r.message}");
              await OfflineAttendanceService.removeWage(id);
              dropped++;
            }
          }
        }
      }
    } finally {
      _syncing = false;
      OfflineAttendanceService.refreshCount();
      notifyListeners();
    }

    if (!context.mounted) return;

    if (synced > 0) {
      utils.showSuccessToast(
        context: context,
        text: "$synced offline entries synced",
      );
      _refreshAfterAttendance(context);
    }

    if (dropped > 0 && !silent) {
      utils.showWarningToast(
        context,
        text: "$dropped entries were rejected by the server and removed.",
      );
    }

    if (failed && !silent) {
      utils.showWarningToast(
        context,
        text: _lastSyncError.isNotEmpty
            ? "Sync failed: $_lastSyncError"
            : "Sync failed. Server did not return a reason (check logs).",
      );
    }
  }
  // CHANGED: returns SyncResult
  Future<SyncResult> _sendOfflineAttendance(Map<String, dynamic> item) {
    final status = item["status"]?.toString() ?? "1";
    final markedAt = item["markedAt"]?.toString() ?? "";

    return _sendOfflineWages({
      "emp_id": item["emp_id"],
      "lat": item["lat"],
      "lng": item["lng"],
      "markedAt": markedAt,
      "attendanceData": {
        "emp_id": item["emp_id"],
        "check_in": status == "1" ? markedAt : "",
        "check_out": status == "2" ? markedAt : "",
        "status": status,
        "lat": item["lat"],
        "lng": item["lng"],
      },
    });
  }

  /// 7️⃣ App restart-ku aprom offline state-a UI-la thirumba podu.
  /// getMainAttendance()-la `if (!fromReport) applyPendingState();` call irukkanum.
  void applyPendingState() {
    final myId = localData.storage.read("id").toString();
    final today = DateTime.now().toString().substring(0, 10);

    final pending = OfflineAttendanceService.getAll()
        .where((e) =>
    e["kind"] == "attendance" &&
        e["emp_id"] == myId &&
        e["markedAt"].toString().startsWith(today))
        .toList();
    if (pending.isEmpty) return;

    for (final e in pending) {
      if (e["status"] == "1") {
        _mainAttendance = 1;
      } else if (e["status"] == "2") {
        _mainAttendance = 1;
        _mainCheckOut = true;
      }
    }
  }

  // =====================================================================
  // ✅ CHANGED BLOCK END
  // =====================================================================

  final TextEditingController permissionReason=TextEditingController();
  Future putDailyPermission(context, String status, String lat, String lng) async {

    if (_isMarkingPermission) return;
    _isMarkingPermission = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Column(
              children: [
                const CustomText(
                  text: "Permission Marking",
                  colors: Colors.grey,
                  size: 15,
                  isBold: true,
                ),
                10.height,
                const CustomText(
                  text: "Please Wait",
                  colors: Colors.grey,
                  size: 15,
                  isBold: true,
                ),
                20.height,
                LoadingAnimationWidget.staggeredDotsWave(
                  color: colorsConst.secondary,
                  size: 25,
                ),
              ],
            ),
          ),
        );
      },
    );

    // CHANGED: .toString() on storage values (int in production -> TypeError)
    Map<String, String> requestData = {
      "action": empPermission,
      "log_file": localData.storage.read("mobile_number")?.toString() ?? "",
      "salesman_id": localData.storage.read("id")?.toString() ?? "",
      "permission_reason": permissionReason.text.trim(),
      "lat": lat,
      "lng": lng,
      "img": "",
      "status": status,
      "cos_id": localData.storage.read("cos_id")?.toString() ?? "",
    };

    dynamic response;
    try {
      response = await attRepo.addAttendance(requestData, _profile);
    } catch (e) {
      response = {};
    }
    log(response.toString());

    if (response.isNotEmpty) {
      /// 🔴 IMPORTANT STATE UPDATE
      _permissionStatus = status;

      if (status == "1") {
        _isPermission = true;
      } else {
        _isPermission = false;
      }
      /// CLOSE LOADING
      Navigator.pop(context);

      /// CLOSE DIALOG (ONLY FOR IN)
      if (status == "1") {
        Navigator.pop(context);
      }

      /// SUCCESS MESSAGE
      utils.showSuccessToast(
        text: status == "1"
            ? "Permission check in marked successfully"
            : "Permission check out marked successfully",
        context: context,
      );
      print("permissionStatus 1234 = ${_permissionStatus}");
      notifyListeners();

      /// REFRESH DATA
      Provider.of<HomeProvider>(context, listen: false).loadFullDashboard(context);
      getAttendanceReport(localData.storage.read("id"));
      getMainAttendance();

      permissionReason.clear();
      if (localData.storage.read("role") == "1") {
        getLateCount(
          Provider.of<HomeProvider>(context, listen: false).startDate,
          Provider.of<HomeProvider>(context, listen: false).endDate,
        );
      }

    } else {
      permissionReason.clear();
      log("Failed");
      utils.showErrorToast(context: context);
      Navigator.pop(context);

    }
    _isMarkingPermission = false;
  }
  void resetOnLogout() {
    final now = DateTime.now();

    _mainCheckOut = false;
    _decrease = false;
    _increase = false;
    _isSelfie = false;
    _isPermission = false;
    _permissionStatus = "";
    _check = false;
    _attCheck = false;
    _refresh = false;
    _filter = false;
    asc = false;

    _mainAttendance = 0;
    _todayLeave = LeaveBlock.none;
    _leaveChecked = false;
    _inTime = "";
    _outTime = "-";
    _totalHrs = "";
    _totalHrs2 = "";

    _lateCount = 0;
    permisCount = 0;
    lateCountShow = 0;
    _isWorkDone = 0;
    workDoneDate = null;
    lastRefreshed = "";

    _noAttendanceList = [];
    _noAttendanceList2 = [];
    leave = [];
    attendanceList = [];
    weekList = [];
    monthList = [];
    _userData = [];
    _getDailyAttendance = <AttendanceModel>[];
    _getUserAttendance = <AttendanceModel>[];
    _searchGetDailyAttendance = <AttendanceModel>[];
    _missingDateList = [];
    datesBetween = [];

    _user = null;
    _userName = "";
    _type = null;
    _grpType = null;
    _report = "Daily";
    selectedIndex = 0;
    selectedDate = null;
    betweenDates = "";
    _startDate = "";
    _endDate = "";
    stDt = now;
    enDt = now.add(const Duration(days: 1));
    _monthName = DateFormat('MMMM yyyy').format(now);
    _month = DateFormat('MMMM').format(now);
    _showDate3 = "";
    _showDate4 = "";
    _showDate5 = "";
    _showDate6 = "";
    _start = null;
    _end = null;
    year = null;
    lastDate = null;
    reason = null;

    _profile = "";

    search.clear();
    permissionReason.clear();

    notifyListeners();
  }
}