import 'dart:async';
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
import '../model/user_model.dart';
import '../repo/attendance_repo.dart';
import '../repo/employee_repo.dart';
import '../screens/common/camera.dart';
import '../source/constant/api.dart';
import '../source/constant/local_data.dart';
import '../source/utilities/utils.dart';
import 'employee_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AttendanceProvider with ChangeNotifier{
  final AttendanceRepository attRepo = AttendanceRepository();
  final EmployeeRepository empRepo = EmployeeRepository();
  final TextEditingController search=TextEditingController();
  bool _mainCheckOut=false;
  bool _decrease=false;
  bool _increase=false;
  bool _isSelfie=false;
  bool _isPermission=false;
  bool get increase=>_increase;
  bool get decrease=>_decrease;
  bool get isSelfie=>_isSelfie;
  bool get isPermission=>_isPermission;
  void manageSelfie(){
    _isSelfie=!_isSelfie;
    notifyListeners();
  }
  void managePermission(){
    _isPermission=!_isPermission;
    notifyListeners();
  }
  List<AttendanceModel> _noAttendanceList = [];
  List<AttendanceModel> _noAttendanceList2 = [];
  List<AttendanceModel> get noAttendanceList=>_noAttendanceList;
  List<AttendanceModel> get noAttendanceList2=>_noAttendanceList2;

//   void checkType(context) {
//     _noAttendanceList.clear();
//     final empProvider = Provider.of<EmployeeProvider>(context, listen: false);
//     _refresh=false;
// print(_getDailyAttendance[0].salesmanId);
// print(empProvider.userData[0].id);
//     for (var emp in empProvider.userData) {
//       // check if this employee has attendance
//       bool hasAttendance = _getDailyAttendance.any(
//         (att) => att.salesmanId == emp.id,
//       );
//
//       // if not found, add to noAttendanceList
//       if (!hasAttendance) {
//         _noAttendanceList.add(emp);
//       }
//     }
//
//     // store or print
//     // print("Employees without attendance: ${_noAttendanceList.length}");
//     _noAttendanceList.sort((a, b) => a.firstname!.toLowerCase().compareTo(b.firstname!.toLowerCase()));
//     notifyListeners();
//   }

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
// void filterList(){
//   _filter=true;
//   _getDailyAttendance = _searchGetDailyAttendance.where((contact){
//     final empProviderDate1 = _startDate; // Start Date
//     final empProviderDate2 = _endDate; // End Date
//     final dateFormat = DateFormat('dd-MM-yyyy');
//     // print(contact.createdTs.toString());
//
//     String timestamp =contact.createdTs.toString();
//     List<String> times = timestamp.split(',');
//     DateTime startTime = DateTime.parse(times[0]);
//
//     DateTime  createdTsDate = startTime;
//     final parsedDate1 = dateFormat.tryParse(empProviderDate1);
//     final parsedDate2 = dateFormat.tryParse(empProviderDate2);
//     // print("///....../ ${createdTsDate}");
//     bool isWithinDateRange =
//         createdTsDate.isAfter(parsedDate1!.subtract(const Duration(days: 1))) &&
//             createdTsDate.isBefore(parsedDate2!.add(const Duration(days: 1)));
//     return isWithinDateRange;
//   }).toList();
//   // print("//// ${_startDate}");
//   // print("//// ${_endDate}");
//   // print("//// ${_filterCustomerData.length}");
//   notifyListeners();
// }
  List<UserModel> _userData=[];
  List<UserModel> get userData => _userData;

  // Future<void> getAllUsers({bool? isRefresh=true}) async {
  //   _userData.clear();
  //   notifyListeners();
  //   try {
  //     Map data = {
  //       "action": getAllData,
  //       "search_type": "allusers",
  //       "cos_id":localData.storage.read("cos_id"),
  //       "role":localData.storage.read("role"),
  //     };
  //     final response =await empRepo.getUsers(data);
  //     // print("response.toString()");
  //     // print(response.toString());
  //     if (response.isNotEmpty) {
  //       _userData=response;
  //       _refresh = true;
  //     } else {
  //     }
  //   } catch (e) {
  //     log(e.toString());
  //   }
  //   notifyListeners();
  // }
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
      // print("Dates...... ${_startDate}-${_endDate}");
      // print("Created ts......${contact.createdTs.toString()}");

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

// bool _daily=false,_week=false,_monthR=false;
// bool get daily=>_daily;
// bool get week=>_week;
// bool get monthR=>_monthR;
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
  // String timeDifference (String dateTimeString1,String dateTimeString2) {
  //   DateTime startTime = DateTime.parse(dateTimeString1);
  //   DateTime endTime = DateTime.parse(dateTimeString2);
  //
  //   Duration difference = endTime.difference(startTime);
  //
  //   return difference.inHours==0?"${difference.inMinutes} Mins":"${difference.inHours} Hrs";
  // }
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
    applyFilter(list);
    notifyListeners();
  }
// void selectDate(String type){
//   if(type=="1"){
//
//   }else{
//
//   }
//   notifyListeners();
// }
  bool _check=false;
  bool _attCheck=false;
  bool _refresh=false;
  int _mainAttendance=0;
  String _permissionStatus = "";
  String get permissionStatus=>_permissionStatus;
  bool get mainCheckOut=>_mainCheckOut;
  bool get check=>_check;
  bool get attCheck=>_attCheck;
  bool get refresh=>_refresh;
  int get mainAttendance=>_mainAttendance;
  String _inTime = "", _outTime = "-";
  String get inTime=>_inTime;
  String get outTime=>_outTime;
  Future<void> getMainAttendance() async {
    try {
    _attCheck = false;
    _mainCheckOut = false;
    _isPermission = false;
    _mainAttendance = 0;
    _totalHrs="";
    _permissionStatus="";
    String reasonSave="";
    notifyListeners();
    Map data = {
      "action": getAllData,
      "search_type": "user_attendance",
      "id": localData.storage.read("id"),
      // "role": localData.storage.read("role"),
      "cos_id":localData.storage.read("cos_id"),
    };
    final response = await attRepo.getAttendance(data);
    log(data.toString());
    log(response.toString());
    log(response.first["status"].toString());
    log(response.first["status"].toString().contains("2").toString());
    if (response.isNotEmpty){
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd-MMM-yyyy').format(now);


      if(formattedDate==response.first["date"]){
        _mainCheckOut=response.first["status"].toString().contains("2")?true:false;
        if((response.first["status"].toString()=="1")||(response.first["status"].toString()=="1,2")){
          _mainAttendance = 1;
        }else{

        }
        if (response.first["status"].toString().contains("1,2")) {
          _inTime = response.first["time"].split(",")[0];
          _outTime = response.first["time"].split(",")[1];
          _totalHrs=getTimeDifferenceBetween(_inTime,outTime);
          _permissionStatus=response.first["per_status"].toString()=="null"?"":response.first["per_status"];
          reasonSave=response.first["per_reason"]=="null"?"":response.first["per_reason"];
          var split =_permissionStatus.toString().split(",");
          var split2 =reasonSave.toString().split(",");
          if(split.last=="1"){
            _isPermission=true;
            permissionReason.text=split2.last;
          }else{
            _isPermission=false;
          }
        }
        else if (response.first["status"].toString().contains("2,1")) {
          _outTime = response.first["time"].split(",")[0];
          _inTime = response.first["time"].split(",")[1];
          _totalHrs=getTimeDifferenceBetween(outTime,_inTime);
          _permissionStatus=response.first["per_status"]=="null"?"":response.first["per_status"];
          reasonSave=response.first["per_reason"]=="null"?"":response.first["per_reason"];
          var split =_permissionStatus.toString().split(",");
          var split2 =reasonSave.toString().split(",");
          if(split.last=="1"){
            _isPermission=true;
            permissionReason.text=split2.last;
          }else{
            _isPermission=false;
          }
        }
        else {
          _inTime = response.first["time"].split(",")[0];
          _permissionStatus=response.first["per_status"].toString()=="null"?"":response.first["per_status"].toString();
          reasonSave=response.first["per_reason"].toString()=="null"?"":response.first["per_reason"].toString();
          var split =_permissionStatus.toString().split(",");
          var split2 =reasonSave.toString().split(",");
          if(split.last=="1"){
            _isPermission=true;
            permissionReason.text=split2.last;
          }else{
            _isPermission=false;
          }
          print("_isPermission.........$_permissionStatus");
          print("_isPermission.........$_isPermission");
        }
        getLateCount("${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}","${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}");
      }
      _attCheck = true;
    }else {
      _totalHrs="";
      _permissionStatus="";
      _attCheck = true;
    }
    } catch (e) {
      _totalHrs="";
      _permissionStatus="";
      _attCheck = true;
    }
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
    applyFilter(list);
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
  Future<void> getAttendanceReport(String id) async {
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
      final response = await attRepo.getReport(data);
      print("response");
      print(response);
      if (response.isNotEmpty){
        _getDailyAttendance=response;
        _searchGetDailyAttendance=response;
        int count=0;
        int count2=0;
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
        print("permisCount......$permisCount");
        print("lateCountShow......$lateCountShow");
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
      // print("Errrrrrr$e");
      notifyListeners();
    }
    notifyListeners();
  }
  bool isLate(String inTime) {
    final format = DateFormat("hh:mm a");

    DateTime officeTime = format.parse("09:00 AM");
    DateTime userTime = format.parse(inTime);

    return userTime.isAfter(officeTime);
  }
  Future<void> getAbsentAttendanceReport(String id) async {
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
        print("_filter...... ${_filter}");
        print("Dates...... ${_user}");
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
        // print("missing......llll");
        _refresh = true;
      }
      notifyListeners();
    } catch (e) {
      // print("Errrrrrr$e");
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

            // Cutoff is exactly 9:00:00 AM on the same day
            var cutoff = DateTime(
              createdTs.year,
              createdTs.month,
              createdTs.day,
              9, // Hour
              0, // Minute
              0, // Second
            );
            if (createdTs.isAfter(cutoff)) {
              _lateCount++;
            } else {

            }
            // ------------------------------------------------------------------
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
      // print("Errrrrrr$e");
    }
    notifyListeners();
  }

  String _totalHrs = "";
  String _totalHrs2 = "";
  String get totalHrs=>_totalHrs;
  String get totalHrs2=>_totalHrs2;
  Future<void> getTotalHours(String date1,String date2) async {
    _totalHrs2 = "";
    notifyListeners();
    try {
      Map data = {
        "action": getAllData,
        "search_type": "get_attendance",
        "salesman_id": localData.storage.read("id"),
        "role": "0",
        "cos_id":localData.storage.read("cos_id"),
        "st_dt": date1,
        "en_dt": date2
      };
      print("Total hours.....");
      print(data.toString());
      final response = await attRepo.getReport(data);

      print(response.toString());
      if (response.isNotEmpty){
        if(response.length==1){
          if(response[0].time.toString().contains(",")){
            var split=response[0].time.toString().split(",");
            _totalHrs2=getTimeDifferenceBetween(split.first,split.last);
          }
          log("_totalHrs2 : $_totalHrs2");
        }else{
          Duration totalDuration = const Duration();
          Set<String> daysWorked = {};

          for (var entry in response) {
            final dates = entry.date.toString().split(',');
            final times = entry.time.toString().split(',');
            final timestamps = entry.createdTs.toString().split(',');
            final statuses = entry.status.toString().split(',');

            for (int i = 0; i < statuses.length; i++) {
              daysWorked.add(dates[i]); // Always count day once

              if (statuses[i] == '1' && (i + 1 < statuses.length && statuses[i + 1] == '2')) {
                final inTime = DateTime.parse(timestamps[i]);
                final outTime = DateTime.parse(timestamps[i + 1]);
                totalDuration += outTime.difference(inTime);
                i++; // skip next as it's already paired
              }
            }
          }

          final totalMinutes = totalDuration.inMinutes;
          final days = daysWorked.length;
          final hours = totalMinutes ~/ 60;
          final minutes = totalMinutes % 60;
          _totalHrs2 ="${days==0?"":days==1?"$days day":"$days days"} : $hours h : $minutes m";
          log("Total Working: $days days, $hours hrs, $minutes mins");
        }
      }else {
        _totalHrs2 = "";
      }
    } catch (e) {
      _totalHrs2 = "";
    }
    print("_totalHrs2...........${_totalHrs2}");
    notifyListeners();
  }
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

  void searchAttendanceReport(String value){
    final suggestions=_searchGetDailyAttendance.where(
            (user){
          final comFName=user.firstname.toString().toLowerCase();
          final userFName=user.role.toString().toLowerCase();
          final input=value.toString().toLowerCase();
          return comFName.contains(input) ||userFName.contains(input);
        }).toList();
    _getDailyAttendance=suggestions;

    final suggestions2=_noAttendanceList2.where(
            (user){
          final comFName=user.firstname.toString().toLowerCase();
          final input=value.toString().toLowerCase();
          return comFName.contains(input);
        }).toList();
    _noAttendanceList=suggestions2;
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
    // stDt = DateTime.now();
    // enDt = DateTime.now().add(const Duration(days: 1));
    // _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    // daily(id,role,refresh);
    // _endDate = DateFormat('dd-MM-yyyy').format(enDt);
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
      Provider.of<LeaveProvider>(context, listen: false).allLeaves(_startDate,_endDate,true);
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
      Provider.of<LeaveProvider>(context, listen: false).allLeaves(_startDate,_endDate,true);
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
      Provider.of<LeaveProvider>(context, listen: false).allLeaves(_startDate,_endDate,true);
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
      Provider.of<LeaveProvider>(context, listen: false).allLeaves(_startDate,_endDate,true);
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
      Provider.of<LeaveProvider>(context, listen: false).allLeaves(_startDate,_endDate,true);
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
      Provider.of<LeaveProvider>(context, listen: false).allLeaves(_startDate,_endDate,true);
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

  void last3Month(String id ,String role,bool? isRefresh) {
    // DateTime now = DateTime.now();
    // DateTime stDt = DateTime(now.year, now.month - 2, now.day);
    // DateTime enDt = now;
    //
    // _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    // _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    DateTime now = DateTime.now();

// Subtract 3 months from today
    DateTime stDt = DateTime(now.year, now.month - 3, now.day);
    DateTime enDt = now;

    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    if(localData.storage.read("role")!="1"){
      getAttendanceReport(id);
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

// String _latitude = "";
// String _longitude = "";
// String get latitude=>_latitude;
// String get longitude=>_longitude;
  /// Gets the current position once, with a timeout and error handling
// void getLocation() async {
//   const platform = MethodChannel('location');
//   try {
//     final String location = await platform.invokeMethod('getCurrentLocation');
//     _latitude=location.toString().split(",")[0];
//     _longitude=location.toString().split(",")[1];
//     log('Current location: $location');
//   } on PlatformException catch (e) {
//     log('Failed to get location: ${e.message}');
//   }
// }
  ///
// void getCurrentLocation() async {
//     const platform = MethodChannel('location');
//     try {
//         final String location = await platform.invokeMethod('getCurrentLocation');
//         _latitude=location.toString().split(",")[0];
//         _longitude=location.toString().split(",")[1];
//         log('Current location: $location');
//     } on PlatformException catch (e) {
//       log('Failed to get location: ${e.message}');
//     }
//   }
// void getLocation() async {
//     const platform = MethodChannel('location');
//     // try {
//       Map<Permission, PermissionStatus> status = await [
//         Permission.location,
//       ].request();
//       // print(status[Permission.location]==PermissionStatus.permanentlyDenied);
//       if (status[Permission.location] == PermissionStatus.granted) {
//         final String location = await platform.invokeMethod('getCurrentLocation');
//         _latitude=location.toString().split(",")[0];
//         _longitude=location.toString().split(",")[1];
//         log('Current location: $location');
//       }else{
//         var permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.deniedForever) {
//           log("Location permissions are permanently denied.");
//           await openAppSettings();
//         }
//       }
//     // } on PlatformException catch (e) {
//     //   log('Failed to get location: ${e.message}');
//     // }
//   }
// void manageLocation(context) async {
//     // try {
//       Map<Permission, PermissionStatus> status = await [
//         Permission.location,
//       ].request();
//       if (status[Permission.location] == PermissionStatus.granted) {
//         bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
//         if (!isLocationServiceEnabled) {
//           utils.showWarningToast(context, text: "Location services are disabled. Please enable them.");
//         }else{
//           // const platform = MethodChannel('location');
//           // final String location = await platform.invokeMethod('getCurrentLocation');
//           // _latitude=location.toString().split(",")[0];
//           // _longitude=location.toString().split(",")[1];
//          Position position= await Geolocator.getCurrentPosition();
//                  _latitude="${position.latitude}";
//                  _longitude="${position.longitude}";
//           log('Current location: $_latitude $_longitude');
//         }
//       }else{
//           log("Location permissions are denied.");
//           await openAppSettings();
//       }
//     // } on PlatformException catch (e) {
//     //   log('Failed to get location: ${e.message}');
//     // }
//   }

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
  Future putDailyAttendance(context, String status,String lat,String lng) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(
              child: Column(
                children: [
                  const CustomText(text: "Attendance Marking",
                    colors: Colors.grey,
                    size: 15,
                    isBold: true,),
                  10.height,
                  const CustomText(text: "Please Wait",
                    colors: Colors.grey,
                    size: 15,
                    isBold: true,),
                  20.height,
                  LoadingAnimationWidget.staggeredDotsWave(
                    color: colorsConst.secondary,
                    size: 25,
                  ),
                ],
              ),
            ),
          );
        }
    );

    Map<String, String> requestData = {
      "action": empAttendance,
      "log_file": localData.storage.read("mobile_number"),
      "salesman_id": localData.storage.read("id"),
      "lat": lat,
      "lng": lng,
      "img": "",
      "status": status,
      "cos_id":localData.storage.read("cos_id"),
    };
    final response =await attRepo.addAttendance(requestData,_profile);
    log(response.toString());
    if(response.isNotEmpty){
      log("Success");
      Navigator.pop(context);
      if(status=="1"){
        await FirebaseFirestore.instance.collection('attendance').add({
          'emp_id': localData.storage.read("id"),
          'time': DateTime.now(),
          'status': status,
        });
      }
      utils.showSuccessToast(text: status=="1"?"Check In Successfully":"Check Out Successfully",context: context);
      getMainAttendance();
      getTotalHours(date1, date2);
      Provider.of<AttendanceProvider>(context, listen: false).initDate(id:localData.storage.read("id"),role:localData.storage.read("role"),isRefresh: true,date1: "${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year.toString()}",date2: "${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year.toString()}");
      Provider.of<AttendanceProvider>(context, listen: false).getAttendanceReport(localData.storage.read("id"));
    }else{
      log("Failed");
      utils.showErrorToast(context: context);
      Navigator.pop(context);
    }
  }
  final TextEditingController permissionReason=TextEditingController();
  Future putDailyPermission(context, String status,String lat,String lng) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(
              child: Column(
                children: [
                  const CustomText(text: "Permission Marking",
                    colors: Colors.grey,
                    size: 15,
                    isBold: true,),
                  10.height,
                  const CustomText(text: "Please Wait",
                    colors: Colors.grey,
                    size: 15,
                    isBold: true,),
                  20.height,
                  LoadingAnimationWidget.staggeredDotsWave(
                    color: colorsConst.secondary,
                    size: 25,
                  ),
                ],
              ),
            ),
          );
        }
    );

    Map<String, String> requestData = {
      "action": empPermission,
      "log_file": localData.storage.read("mobile_number"),
      "salesman_id": localData.storage.read("id"),
      "permission_reason": permissionReason.text.trim(),
      "lat": lat,
      "lng": lng,
      "img": "",
      "status": status,
      "cos_id":localData.storage.read("cos_id"),
    };
    final response =await attRepo.addAttendance(requestData,_profile);
    log(response.toString());
    if(response.isNotEmpty){
      log("Success");
      if(status=="1"){
        Navigator.pop(context);
        Navigator.pop(context);
      }else{
        Navigator.pop(context);
      }
      utils.showSuccessToast(text: status=="1"?"Permission check in marked successfully":"Permission check out marked successfully",context: context);
      if(status=="2"){
        _isPermission=false;
        notifyListeners();
      }
      Provider.of<HomeProvider>(context, listen: false).getMainReport(false);
      getAttendanceReport(localData.storage.read("id"));
      getMainAttendance();
      if(localData.storage.read("role")=="1"){
        getLateCount(Provider.of<HomeProvider>(context, listen: false).startDate,Provider.of<HomeProvider>(context, listen: false).endDate,);
      }
    }else{
      log("Failed");
      utils.showErrorToast(context: context);
      Navigator.pop(context);
    }
  }

}