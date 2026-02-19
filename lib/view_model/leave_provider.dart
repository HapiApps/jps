import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:master_code/repo/attendance_repo.dart';
import 'package:master_code/repo/leave_repo.dart';
import 'package:master_code/screens/leave_management/leave_dashboard.dart';
import 'package:master_code/source/constant/local_data.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../component/custom_text.dart';
import '../component/month_calender.dart';
import '../model/attendance_model.dart';
import '../model/leave/attendance_model.dart';
import '../model/leave/holiday.dart';
import '../model/leave/holidays_model.dart';
import '../model/leave/leave_model.dart';
import '../model/leave/rules_model.dart';
import '../model/user_model.dart';
import '../screens/common/dashboard.dart';
import '../screens/leave_management/add_leave_rules.dart';
import '../screens/leave_management/apply_leave.dart';
import '../screens/leave_management/leave_report.dart';
import '../screens/leave_management/leave_type.dart';
import '../screens/leave_management/yearly_calendar.dart';
import '../source/constant/api.dart';
import '../source/constant/colors_constant.dart';
import '../source/utilities/utils.dart';
import 'employee_provider.dart';

class LeaveProvider with ChangeNotifier {
  final LeaveRepository leaveRepo = LeaveRepository();
  final AttendanceRepository attRepo = AttendanceRepository();
  dynamic _type;
  dynamic _dayType;
  dynamic _name;
  String _typeId="";
  String _stDate="";
  String _enDate="";
  String _nameId="";
  String _year="";
  String _report="Daily";
  bool _getLeave=false;
  bool get getLeave=> _getLeave;
  bool _allSelect =false;
  void changeValue(dynamic value) {
    _allSelect = value;
    holyDaysList.clear();

    for (var i = 0; i < futureHolidays.length; i++) {
      futureHolidays[i].isClick = value;
    }

    for (var i = 0; i < searchFutureHolidays.length; i++) {
      searchFutureHolidays[i].isClick = value;
      if (value == true) {
        holyDaysList.add({
          "lev_date": searchFutureHolidays[i].date,
          "reason": searchFutureHolidays[i].name,
          "created_by": localData.storage.read("id"),
          "platform": "1",
          "isClick": "1"
        });
      }
    }
    changeStatus(true);
    notifyListeners();
  }
  void changeCheckBox(dynamic value, String levDate) {
    for (var i = 0; i < futureHolidays.length; i++) {
      if (futureHolidays[i].date == levDate) {
        futureHolidays[i].isClick = value;
        break;
      }
    }

    for (var i = 0; i < searchFutureHolidays.length; i++) {
      if (searchFutureHolidays[i].date == levDate) {
        searchFutureHolidays[i].isClick = value;

        if (value == false) {
          holyDaysList.removeWhere((element) => element['lev_date'] == levDate);
        } else {
          holyDaysList.add({
            "lev_date": searchFutureHolidays[i].date,
            "reason": searchFutureHolidays[i].name,
            "created_by": localData.storage.read("id"),
            "platform": "1",
            "isClick": "1"
          });
        }
        break;
      }
    }

    // Update _allSelect based on search list (filtered)
    bool allClicked = searchFutureHolidays.every((element) => element.isClick == true);
    _allSelect = allClicked;
    changeStatus(true);
    notifyListeners();
  }
  bool get allSelect=> _allSelect;
  dynamic get type=> _type;
  dynamic get dayType=> _dayType;
  dynamic get name=> _name;
  String get report=> _report;
  String get typeId=> _typeId;
  String get nameId=> _nameId;
  String get stDate=> _stDate;
  String get enDate=> _enDate;
  String get year=> _year;
  bool _session1 =true;
  bool _session2 =false;
  bool get session1=> _session1;
  bool get session2=> _session2;
  void changeSession1(){
    _session1=!_session1;
    if(_session1==true){
      _session2=false;
    }else{
      _session2=true;
    }
    notifyListeners();
  }
  void changeSession2(){
    _session2=!_session2;
    if(_session2==true){
      _session1=false;
    }else{
      _session1=true;
    }
    notifyListeners();
  }
  List<Map<String, dynamic>> _rulesList = [];
  List<Map<String, dynamic>> get  rulesList => _rulesList;
  TextEditingController search=TextEditingController();
  TextEditingController search2=TextEditingController();
  TextEditingController reason=TextEditingController();
  void iniValues(){
    _type=null;
  _dayType=null;
  _name=null;
  search.clear();
  _typeId="";
  _nameId="";
  _rulesList.clear();
  _dayType="1";
  _stDate="";
  _enDate="";
  reason.clear();
  _session1=true;
  _session2=false;
  notifyListeners();
}
  DateTime selected = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  dynamic lastDate,end,yearr;
  void initVal(){
    start =("01-${(selected.month.toString().padLeft(2, "0"))}-${selected.year}");
    var ex = start.split("-");
    var date = DateTime(int.parse(ex.first), int.parse(ex[1]) + 1,0);
    lastDate = date.day;
    end = "${date.day.toString().padLeft(2, "0")}-${selected.month.toString().padLeft(2, "0")}-${selected.year}";
    month = DateFormat('MMMM').format(DateTime(0, int.parse(selected.month.toString().padLeft(2, "0"))));
    yearr = ex[0];
    _showDate7=start;
    levMonthD1=start;
    _showDate8=end;
    levMonthD2=end;
    noOfWorkingDay.text=lastDate.toString();
    getMonthLeaves(true,showDate7,showDate8);
  
  notifyListeners();
}

  bool _allSunday = false;
  bool _allSaturday = false;
  bool _saturday1 = false;
  bool _saturday2 = false;
  bool _saturday3 = false;
  bool _saturday4 = false;
  bool _saturday5 = false;
  bool _saturday6 = false;

  // Public getters
  bool get allSunday => _allSunday;
  bool get allSaturday => _allSaturday;
  bool get saturday1 => _saturday1;
  bool get saturday2 => _saturday2;
  bool get saturday3 => _saturday3;
  bool get saturday4 => _saturday4;
  bool get saturday5 => _saturday5;
  bool get saturday6 => _saturday6;

  void allSunDay(dynamic value){
    _allSunday = value;
      sundays.clear();
    changeStatus(true);
    notifyListeners();
  }
  void allSaturDay(dynamic value){
    _allSaturday = value;
    if (_allSaturday == true) {
      _saturday1 = true;
      _saturday2 = true;
      _saturday3 = true;
      _saturday4 = true;
      _saturday5 = true;
    } else {
      _saturday1 = false;
      _saturday2 = false;
      _saturday3 = false;
      _saturday4 = false;
      _saturday5 = false;
    }
    // if (_allSaturday == true) {
    //   getAllSaturdays(
    //       int.parse(_year),_allSaturday==true?1:0);
    // } else {
    //   getAllSaturdays(
    //       int.parse(_year),_allSaturday==true?1:0);
    customSaturdays1.clear();
    customSaturdays2.clear();
    customSaturdays3.clear();
    customSaturdays4.clear();
    customSaturdays5.clear();
    // }
    changeStatus(true);
    notifyListeners();
  }
  void firstSaturDay(dynamic value){
    _saturday1 = value;
    customSaturdays1.clear();
    if(_saturday1==true&&_saturday2==true&&_saturday3==true&&_saturday4==true&&_saturday5==true){
      _allSaturday=true;
    }else{
      _allSaturday=false;
    }
    changeStatus(true);
    notifyListeners();
  }
  void secondSaturDay(dynamic value){
    _saturday2 = value;
    customSaturdays2.clear();
    if(_saturday1==true&&_saturday2==true&&_saturday3==true&&_saturday4==true&&_saturday5==true){
      _allSaturday=true;
    }else{
      _allSaturday=false;
    }
    changeStatus(true);
    notifyListeners();
  }
  void thirdSaturDay(dynamic value){
    _saturday3 = value;
    customSaturdays3.clear();
    if(_saturday1==true&&_saturday2==true&&_saturday3==true&&_saturday4==true&&_saturday5==true){
      _allSaturday=true;
    }else{
      _allSaturday=false;
    }
    changeStatus(true);
    notifyListeners();
  }
  void fourthSaturDay(dynamic value){
    _saturday4 = value;
    customSaturdays4.clear();
    if(_saturday1==true&&_saturday2==true&&_saturday3==true&&_saturday4==true&&_saturday5==true){
      _allSaturday=true;
    }else{
      _allSaturday=false;
    }
    changeStatus(true);
    notifyListeners();
  }
  void fivthSaturDay(dynamic value){
    _saturday5 = value;
    customSaturdays5.clear();
    if(_saturday1==true&&_saturday2==true&&_saturday3==true&&_saturday4==true&&_saturday5==true){
      _allSaturday=true;
    }else{
      _allSaturday=false;
    }
    changeStatus(true);
    notifyListeners();
  }
  void searchDay(dynamic value){
    final suggestions = futureHolidays.where(
            (user) {
          final userFName = user.date.toString()
              .toLowerCase();
          final userNumber = user.name.toString()
              .toLowerCase();
          final input = value.toString()
              .toLowerCase();
          return userFName.contains(input) ||
              userNumber.contains(input);
        }).toList();
    searchFutureHolidays = suggestions;
    notifyListeners();
  }
  
  
  void getOwnLeaves(String id,String st,String en)async{
    _isLoading4=false;
    _allSelect= false;
    _isLeave= false;
    totalLeaveDays="0";
    myLev4Search.clear();
    ourLeaves(st,en,isLoading4,id);

    double a = myLev4Search.fold(0.0,(double sum, LeaveModel lvCount) => sum + double.parse(lvCount.dayCount));
    totalLeaveDays = a.toStringAsFixed(
        a.truncateToDouble() == a ? 0 : 1);

    notifyListeners();
  }
  List<AttendanceModel> _getDailyAttendance = <AttendanceModel>[];
  List<AttendanceModel> get getDailyAttendance => _getDailyAttendance;
  Future<void> getAttendanceReport(String id,String role) async {
    _refresh = false;
    _getDailyAttendance.clear();
    notifyListeners();
    try {
      Map data = {
        "action": getAllData,
        "search_type": "get_attendance",
        "salesman_id": id,
        "role": role,
        "cos_id":localData.storage.read("cos_id"),
        "st_dt": _d1,
        "en_dt": _d2
      };
      final response = await attRepo.getReport(data);
      // print("data.toString()");
      // print(data.toString());
      // print(response.toString());
      if (response.isNotEmpty){
        _getDailyAttendance=response;
        _refresh = true;
      }else {
        _refresh = true;
      }
    } catch (e) {
      // print("Errrrrrr$e");
      _refresh = true;
    }
    notifyListeners();
  }

  void getMonthLeaves(bool isRefresh,String st,String en) async {
    fixedMonthLeaves.clear();
    fixedMonthLeaves=await yearlyLeaves(isRefresh,true,st,en);
  }
  List<Map<String, dynamic>> sundays = [];
  List<Map<String, dynamic>> saturdays = [];
  List<Map<String, dynamic>> customSaturdays1 = [];
  List<Map<String, dynamic>> customSaturdays2 = [];
  List<Map<String, dynamic>> customSaturdays3 = [];
  List<Map<String, dynamic>> customSaturdays4 = [];
  List<Map<String, dynamic>> customSaturdays5 = [];
  List<Map<String, dynamic>> allLeavesList = [];
  List<Map<String, dynamic>> holyDaysList = [];
  List<Holiday> searchFutureHolidays= <Holiday>[];
  List<Holiday> futureHolidays= <Holiday>[];
  List<Map<String, dynamic>> getFirstSaturdays(int year, List<Map<String, dynamic>> list,String value) {
    for (int month = 1; month <= 12; month++) {
      DateTime firstDayOfMonth = DateTime(year, month, 1);
      int firstSaturdayOffset = (6 - firstDayOfMonth.weekday + 7) % 7;
      DateTime firstSaturday = firstDayOfMonth.add(Duration(days: firstSaturdayOffset));

      list.add({
        "lev_date": "${firstSaturday.year}-${utils.returnPadLeft(firstSaturday.month.toString())}-${utils.returnPadLeft(firstSaturday.day.toString())}",
        "reason": "First Saturday",
        "created_by": localData.storage.read("id"),
        "platform": "1",
        "isClick":value,
      });
    }
    notifyListeners();
    return list;
  }

  List<Map<String, dynamic>> getSecondSaturdays(int year, List<Map<String, dynamic>> list,String value) {
    for (int month = 1; month <= 12; month++) {
      DateTime firstDayOfMonth = DateTime(year, month, 1);
      int firstSaturdayOffset = (6 - firstDayOfMonth.weekday + 7) % 7;
      DateTime firstSaturday = firstDayOfMonth.add(Duration(days: firstSaturdayOffset));

      // Calculate the second Saturday
      DateTime secondSaturday = firstSaturday.add(const Duration(days: 7)); // Add 7 days to get to the second Saturday

      list.add({
        "lev_date": "${secondSaturday.year}-${utils.returnPadLeft(secondSaturday.month.toString())}-${utils.returnPadLeft(secondSaturday.day.toString())}",
        "reason": "Second Saturday",
        "created_by": localData.storage.read("id"),
        "platform": "1",
        "isClick":value,
      });
    }
    notifyListeners();
    return list;
  }

  List<Map<String, dynamic>> getThirdSaturdays(int year, List<Map<String, dynamic>> list,String value) {
    for (int month = 1; month <= 12; month++) {
      DateTime firstDayOfMonth = DateTime(year, month, 1);
      int firstSaturdayOffset = (6 - firstDayOfMonth.weekday + 7) % 7;
      DateTime firstSaturday = firstDayOfMonth.add(Duration(days: firstSaturdayOffset));

      // Calculate the third Saturday
      DateTime thirdSaturday = firstSaturday.add(const Duration(days: 14)); // Add 14 days to get to the third Saturday

      list.add({
        "lev_date": "${thirdSaturday.year}-${utils.returnPadLeft(thirdSaturday.month.toString())}-${utils.returnPadLeft(thirdSaturday.day.toString())}",
        "reason": "Third Saturday",
        "created_by": localData.storage.read("id"),
        "platform": "1",
        "isClick":value,
      });
    }
    notifyListeners();
    return list;
  }

  // List<Map<String, dynamic>> getFourthSaturdays(int year, List<Map<String, dynamic>> list,String value) {
  //   for (int month = 1; month <= 12; month++) {
  //     DateTime firstDayOfMonth = DateTime(year, month, 1);
  //     int firstSaturdayOffset = (6 - firstDayOfMonth.weekday + 7) % 7;
  //     DateTime firstSaturday = firstDayOfMonth.add(Duration(days: firstSaturdayOffset));
  //
  //     // Calculate the fourth Saturday
  //     DateTime fourthSaturday = firstSaturday.add(const Duration(days: 21)); // Add 21 days to get to the fourth Saturday
  //
  //     list.add({
  //       "lev_date": "${fourthSaturday.year}-${utils.returnPadLeft(fourthSaturday.month.toString())}-${utils.returnPadLeft(fourthSaturday.day.toString())}",
  //       "reason": "Fourth Saturday",
  //       "created_by": localData.storage.read("id"),
  //       "platform": "1",
  //       "isClick":value,
  //     });
  //   }
  //   notifyListeners();
  //   return list;
  // }
///
  // List<Map<String, dynamic>> getFifthSaturdays(int year, List<Map<String, dynamic>> list,String value) {
  //   for (int month = 1; month <= 12; month++) {
  //     DateTime firstDayOfMonth = DateTime(year, month, 1);
  //     int firstSaturdayOffset = (6 - firstDayOfMonth.weekday + 7) % 7;
  //     DateTime firstSaturday = firstDayOfMonth.add(Duration(days: firstSaturdayOffset));
  //
  //     // Calculate the fifth Saturday
  //     DateTime fifthSaturday = firstSaturday.add(const Duration(days: 28)); // Add 28 days to get to the potential fifth Saturday
  //
  //     // Check if the month actually has a fifth Saturday
  //     if (fifthSaturday.month == month) {
  //       list.add({
  //         "lev_date": "${fifthSaturday.year}-${utils.returnPadLeft(fifthSaturday.month.toString())}-${utils.returnPadLeft(fifthSaturday.day.toString())}",
  //         "reason": "Fifth Saturday",
  //         "created_by": localData.storage.read("id"),
  //         "platform": "1",
  //         "isClick":value,
  //       });
  //     }
  //   }
  //   notifyListeners();
  //   return list;
  // }

  List<Map<String, dynamic>> getFourthSaturdays(int year, List<Map<String, dynamic>> list, String value) {
    for (int month = 1; month <= 12; month++) {
      DateTime firstDayOfMonth = DateTime(year, month, 1);
      // weekday: Mon=1, Sat=6, Sun=7. We want the offset to get to 6 (Saturday).
      int firstSaturdayOffset = (6 - firstDayOfMonth.weekday + 7) % 7;
      DateTime firstSaturday = firstDayOfMonth.add(Duration(days: firstSaturdayOffset));

      // Calculate the fourth Saturday (1st Saturday + 3 weeks/21 days)
      DateTime fourthSaturday = firstSaturday.add(const Duration(days: 21));

      list.add({
        "lev_date": "${fourthSaturday.year}-${utils.returnPadLeft(fourthSaturday.month.toString())}-${utils.returnPadLeft(fourthSaturday.day.toString())}",
        "reason": "Fourth Saturday",
        "created_by": localData.storage.read("id"),
        "platform": "1",
        "isClick": value,
      });

      // Verification line:
      if (month == 12) {
        print("✅ Fourth Saturday added for December: ${fourthSaturday.month}/${fourthSaturday.day}");
        // log("✅ list: ${list}");
      }
    }
    // notifyListeners(); // Only call once at the end of the combined process
    return list;
  }

  List<Map<String, dynamic>> getFifthSaturdays(int year, List<Map<String, dynamic>> list, String value) {
    for (int month = 1; month <= 12; month++) {
      DateTime firstDayOfMonth = DateTime(year, month, 1);
      int firstSaturdayOffset = (6 - firstDayOfMonth.weekday + 7) % 7;
      DateTime firstSaturday = firstDayOfMonth.add(Duration(days: firstSaturdayOffset));

      // Calculate the fifth Saturday (1st Saturday + 4 weeks/28 days)
      DateTime fifthSaturday = firstSaturday.add(const Duration(days: 28));

      // Check if the month actually has a fifth Saturday (e.g., a month needs 30 or 31 days
      // AND the first day must be close enough to Saturday)
      if (fifthSaturday.month == month) {
        list.add({
          "lev_date": "${fifthSaturday.year}-${utils.returnPadLeft(fifthSaturday.month.toString())}-${utils.returnPadLeft(fifthSaturday.day.toString())}",
          "reason": "Fifth Saturday",
          "created_by": localData.storage.read("id"),
          "platform": "1",
          "isClick": value,
        });

        // Verification line:
        if (month == 12) {
          print("✅ Fifth Saturday added for December: ${fifthSaturday.month}/${fifthSaturday.day}");
        }
      } else {
        // Verification line:
        if (month == 12) {
          print("❌ December $year does not have a Fifth Saturday.");
        }
      }
    }
    // notifyListeners(); // Only call once at the end of the combined process
    return list;
  }
  List<Map<String, dynamic>> calculateSaturdays(int year, String value) {
    List<Map<String, dynamic>> saturdayList = [];

    saturdayList = getFourthSaturdays(year, saturdayList, value);
    saturdayList = getFifthSaturdays(year, saturdayList, value);

    // 1. Check the list length (Should be 12 Fourth Sats + 4 or 5 Fifth Sats = ~16-17)
    print("Total Calculated Dates: ${saturdayList.length}");

    // 2. Search for the December entry explicitly
    final decemberFourthSat = saturdayList.firstWhere(
            (map) => map["lev_date"].endsWith('12-27'),
        orElse: () => {"lev_date": "NOT FOUND"} // Should not happen
    );

    print("Explicitly checking December 27: $decemberFourthSat");

    notifyListeners();
    return saturdayList;
  }
  ///
  // List<Map<String, dynamic>> getAllSaturdays(int year,int value) {
  //   for (int month = 1; month <= 12; month++) {
  //     DateTime firstDayOfMonth = DateTime(year, month, 1);
  //     int firstSaturdayOffset = (6 - firstDayOfMonth.weekday + 7) % 7;
  //     DateTime firstSaturday = firstDayOfMonth.add(Duration(days: firstSaturdayOffset));
  //     while (firstSaturday.month == month) {
  //       saturdays.add({
  //         "lev_date":"${firstSaturday.year}-${utils.returnPadLeft(firstSaturday.month.toString())}-${utils.returnPadLeft(firstSaturday.day.toString())}",
  //         "reason":"Saturday",
  //         "created_by":localData.storage.read("id"),
  //         "platform":"1",
  //         "isClick":value,
  //       });
  //       firstSaturday = firstSaturday.add(const Duration(days: 7));
  //     }
  //   }
  //   return saturdays;
  // }
  

  List<Map<String, dynamic>> getAllSundays(int year,String value) {
    for (int month = 1; month <= 12; month++) {
      DateTime firstDayOfMonth = DateTime(year, month, 1);
      int firstSundayOffset = (7 - firstDayOfMonth.weekday) % 7;
      DateTime firstSunday = firstDayOfMonth.add(Duration(days: firstSundayOffset));
      while (firstSunday.month == month) {
        sundays.add({
          "lev_date":"${firstSunday.year}-${utils.returnPadLeft(firstSunday.month.toString())}-${utils.returnPadLeft(firstSunday.day.toString())}",
          "reason":"Sunday",
          "created_by":localData.storage.read("id"),
          "platform":"1",
          "isClick":value,
        });
        firstSunday = firstSunday.add(const Duration(days: 7));
      }
    }
    notifyListeners();
    // log(sundays.toString());
    return sundays;
  }

  void iniValues2(){
    search.clear();
    sundays.clear();
    saturdays.clear();
    allLeavesList.clear();
    customSaturdays1.clear();
    customSaturdays2.clear();
    customSaturdays3.clear();
    customSaturdays4.clear();
    customSaturdays5.clear();
    holyDaysList.clear();
    _allSunday=false;
    _allSaturday=false;
    _saturday1=false;
    _saturday2=false;
    _saturday3=false;
    _saturday4=false;
    _saturday5=false;
    _allSelect=false;
    _year="${DateTime.now().year}";

  notifyListeners();
}
  void listCheck(){
    changeStatus(false);
    getAllSundays(int.parse(_year), _allSunday==true?"1":"0");
    getFirstSaturdays(int.parse(_year),customSaturdays1, _saturday1==true?"1":"0");
    getSecondSaturdays(int.parse(_year),customSaturdays2, _saturday2==true?"1":"0");
    getThirdSaturdays(int.parse(_year),customSaturdays3, _saturday3==true?"1":"0");
    getFourthSaturdays(int.parse(_year),customSaturdays4, _saturday4==true?"1":"0");
    getFifthSaturdays(int.parse(_year),customSaturdays5, _saturday5==true?"1":"0");

    // for(var i=0;i<searchFutureHolidays.length;i++){
    //   for(var j=0;j<_fixedLeaves.length;j++){
    //     print(i);
    //     print(searchFutureHolidays[i].date.toString());
    //     print(_fixedLeaves[j].levDate.toString());
    //       if(_fixedLeaves[j].levDate.toString()==searchFutureHolidays[i].date.toString()){
    //         searchFutureHolidays[i].isClick=true;
    //         futureHolidays[i].isClick=true;
    //       }else{
    //         searchFutureHolidays[i].isClick=false;
    //         futureHolidays[i].isClick=false;
    //       }
    //   }
    // }
    for (var i = 0; i < searchFutureHolidays.length; i++) {
      bool isMatched = false;
      for (var j = 0; j < _fixedLeaves.length; j++) {
        if (_fixedLeaves[j].levDate.toString() == searchFutureHolidays[i].date.toString()) {
          isMatched = true;
          break; // no need to continue if match is found
        }
      }
      searchFutureHolidays[i].isClick = isMatched;
      futureHolidays[i].isClick = isMatched;
    }
    bool allClicked = searchFutureHolidays.every((element) => element.isClick == true);
    _allSelect = allClicked;

    var check1=0;
    for(var i=0;i<sundays.length;i++){
      for(var j=0;j<_fixedLeaves.length;j++){
        if(sundays[i]["lev_date"]==_fixedLeaves[j].levDate){
          check1++;
        }
      }
    }
    if(sundays.length==52||sundays.length>52){
      _allSunday=true;
      getAllSundays(int.parse(_year), _allSunday==true?"1":"0");
    }

    var sat1=0;
    for(var i=0;i<customSaturdays1.length;i++){
      for(var j=0;j<_fixedLeaves.length;j++){
        if(customSaturdays1[i]["lev_date"]==_fixedLeaves[j].levDate){
          sat1++;
        }
      }
    }
    if(customSaturdays1.length==12){
      _saturday1=true;
      getFirstSaturdays(int.parse(_year),customSaturdays1, _saturday1==true?"1":"0");
    }
    // print("check1.....${sat1}");
    // print("sundays.....${customSaturdays1.length}");
    var sat2=0;
    for(var i=0;i<customSaturdays2.length;i++){
      for(var j=0;j<_fixedLeaves.length;j++){
        if(customSaturdays2[i]["lev_date"]==_fixedLeaves[j].levDate){
          sat2++;
        }
      }
    }

    if(customSaturdays2.length==12){
      _saturday2=true;
      getSecondSaturdays(int.parse(_year),customSaturdays2, _saturday2==true?"1":"0");
    }
    var sat3=0;
    for(var i=0;i<customSaturdays3.length;i++){
      for(var j=0;j<_fixedLeaves.length;j++){
        if(customSaturdays3[i]["lev_date"]==_fixedLeaves[j].levDate){
          sat3++;
        }
      }
    }
    if(customSaturdays3.length==12){
      _saturday3=true;
      getThirdSaturdays(int.parse(_year),customSaturdays3, _saturday3==true?"1":"0");
    }
    var sat4=0;
    for(var i=0;i<customSaturdays4.length;i++){
      for(var j=0;j<_fixedLeaves.length;j++){
        if(customSaturdays4[i]["lev_date"]==_fixedLeaves[j].levDate){
          sat4++;
        }
      }
    }
    if(customSaturdays4.length==12){
      _saturday4=true;
      getFourthSaturdays(int.parse(_year),customSaturdays4, _saturday4==true?"1":"0");
    }
    var sat5=0;
    for(var i=0;i<customSaturdays5.length;i++){
      for(var j=0;j<_fixedLeaves.length;j++){
        if(customSaturdays5[i]["lev_date"]==_fixedLeaves[j].levDate){
          sat5++;
        }
      }
    }
    if(customSaturdays5.length>4){
      _saturday5=true;
      getFifthSaturdays(int.parse(_year),customSaturdays5, _saturday5==true?"1":"0");
    }
    if(_saturday1==true&&_saturday2==true&&_saturday3==true&&_saturday4==true&&_saturday5==true){
      _allSaturday=true;
    }
    _allSelect=false;
    notifyListeners();
  }
  void initDate(String date1,String date2){
    // _report = "Today";
    if(date1!=""){
      _startDate=date1;
      _endDate=date2;
    }else{
      stDt=DateTime.now();
      enDt=DateTime.now().add(const Duration(days: 1));
      _startDate = DateFormat('dd-MM-yyyy').format(stDt);
      _endDate = DateFormat('dd-MM-yyyy').format(stDt);
    }
    getLeaveReport(_filter);
    search2.clear();
    _typeReport="Today";
    _filter=false;
    notifyListeners();
}
  void iniValues3(){
    reason.clear();
    groupController.selectIndex(0);
    search.clear();
    _report = "Today";
    setCurrentWeek();
    setMonth();
    // setMonth(_showDate7,_showDate8,month);
    // setMonth(levMonthD1,levMonthD2,month);
    notifyListeners();
}
void changeSetting(){
    _settingPage = true;
  notifyListeners();
}
  void setCurrentWeek() {
    DateTime now = DateTime.now();
    dateTime1 = now.subtract(Duration(days: now.weekday - 1)); // First day of current week (Monday)
    dateTime2 = now.add(Duration(days: DateTime.daysPerWeek - now.weekday)); // Last day of current week (Sunday)
    _showDate3 = DateFormat('dd-MM-yyyy').format(dateTime1);
    _showDate4 = DateFormat('dd-MM-yyyy').format(dateTime2);
    notifyListeners();
  }
  void setMonth() {
    DateTime now = DateTime.now();
    DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDateOfMonth = DateTime(now.year, now.month + 1, 0);
    _showDate5 = DateFormat('dd-MM-yyyy').format(firstDateOfMonth);
    _showDate6 = DateFormat('dd-MM-yyyy').format(lastDateOfMonth);
    month = DateFormat('MMMM').format(firstDateOfMonth);
    notifyListeners();
  }
  void setDMonth() {
    DateTime now = DateTime.now();
    DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDateOfMonth = DateTime(now.year, now.month + 1, 0);
    _d1 = DateFormat('dd-MM-yyyy').format(firstDateOfMonth);
    _d2 = DateFormat('dd-MM-yyyy').format(lastDateOfMonth);
    dMonth = DateFormat('MMMM').format(firstDateOfMonth);
    notifyListeners();
  }
  DateTime customDate1 = DateTime.now();
  DateTime customDate2 = DateTime.now().add(const Duration(days: 1));
  void incrementDates() {
    customDate1 = customDate1.add(const Duration(days: 1));
    customDate2 = customDate2.add(const Duration(days: 1));
    _date1 = DateFormat('dd-MM-yyyy').format(customDate1);
    _date2 = DateFormat('dd-MM-yyyy').format(customDate2);
    notifyListeners();
  }

  void decrementDates() {
    customDate1 = customDate1.subtract(const Duration(days: 1));
    customDate2 = customDate2.subtract(const Duration(days: 1));
    _date1 = DateFormat('dd-MM-yyyy').format(customDate1);
    _date2 = DateFormat('dd-MM-yyyy').format(customDate2);
    notifyListeners();
  }
  Future<void> getCommonLeaves() async {
    _getLeave=false;
    futureHolidays.clear();
    searchFutureHolidays.clear();
    fetchHolidays(_year);
  }
  var month=DateFormat('MMMM').format(DateTime(0, int.parse(DateTime.now().month.toString().padLeft(2, "0"))));
  var dMonth=DateFormat('MMMM').format(DateTime(0, int.parse(DateTime.now().month.toString().padLeft(2, "0"))));
  var levMonthD1=DateFormat('MMMM').format(DateTime(0, int.parse(DateTime.now().month.toString().padLeft(2, "0"))));
  var levMonthD2=DateFormat('MMMM').format(DateTime(0, int.parse(DateTime.now().month.toString().padLeft(2, "0"))));
  DateTime dateTime1=DateTime.now();
  DateTime dateTime2=DateTime.now();
  DateTime date3=DateTime.now();
  DateTime date4=DateTime.now();
  void incrementWeek() {
    dateTime1 = dateTime1.add(const Duration(days: DateTime.daysPerWeek));
    dateTime2 = dateTime2.add(const Duration(days: DateTime.daysPerWeek));
    _showDate3 = DateFormat('dd-MM-yyyy').format(dateTime1);
    _showDate4 = DateFormat('dd-MM-yyyy').format(dateTime2);
    // getWeekly();
    notifyListeners();
  }

  void decrementWeek() {
    dateTime1 = dateTime1.subtract(const Duration(days: DateTime.daysPerWeek));
    dateTime2 = dateTime2.subtract(const Duration(days: DateTime.daysPerWeek));
    _showDate3 = DateFormat('dd-MM-yyyy').format(dateTime1);
    _showDate4 = DateFormat('dd-MM-yyyy').format(dateTime2);
    // getWeekly();
    notifyListeners();
  }
  void incrementMonth() {
    date3 = DateTime(date3.year, date3.month + 1, 1);
    date4 = DateTime(date4.year, date4.month + 1, 1);
    _showDate5 = DateFormat('dd-MM-yyyy').format(date3);
    _showDate6 = DateFormat('dd-MM-yyyy').format(DateTime(date4.year, date4.month + 1, 0));
    month = DateFormat('MMMM').format(date3);
    // getMonthly();
    notifyListeners();
  }
  void incrementMonth2() {
    date3 = DateTime(date3.year, date3.month + 1, 1);
    date4 = DateTime(date4.year, date4.month + 1, 1);
    _d1 = DateFormat('dd-MM-yyyy').format(date3);
    _d2 = DateFormat('dd-MM-yyyy').format(DateTime(date4.year, date4.month + 1, 0));
    dMonth = DateFormat('MMMM').format(date3);
    getOwnLeaves(localData.storage.read("id"),_d1,_d2);
    notifyListeners();
  }
  void decrementMonth() {
    date3 = DateTime(date3.year, date3.month - 1, 1);
    date4 = DateTime(date4.year, date4.month - 1, 1);
    _showDate5 = DateFormat('dd-MM-yyyy').format(date3);
    _showDate6 = DateFormat('dd-MM-yyyy').format(DateTime(date4.year, date4.month + 1, 0));
    month = DateFormat('MMMM').format(date3);
    // getMonthly(_filter);
    notifyListeners();
  }
  void decrementMonth2() {
    date3 = DateTime(date3.year, date3.month - 1, 1);
    date4 = DateTime(date4.year, date4.month - 1, 1);
    _d1 = DateFormat('dd-MM-yyyy').format(date3);
    _d2 = DateFormat('dd-MM-yyyy').format(DateTime(date4.year, date4.month + 1, 0));
    dMonth = DateFormat('MMMM').format(date3);
    getOwnLeaves(localData.storage.read("id"),_d1,_d2);
    notifyListeners();
  }
  DateTimeRange dateRange = DateTimeRange(start: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day), end: DateTime.now());
  DateTime lastRange = DateTime(DateTime.now().year, DateTime.december, 31);
  void showDatePickerCalendar(BuildContext context) {
  // selectedDate=null;
  // datesBetween = [];
  // betweenDates="";
  DateTime today = DateTime.now();
  selectedDate = PickerDateRange(today, today);
  datesBetween = getDatesInRange(selectedDate!.startDate!, selectedDate!.endDate!);

  DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  List<String> formattedDates = datesBetween.map((date) => dateFormat.format(date)).toList();
  betweenDates = formattedDates.join(' || ');

  _startDate = dateFormat.format(selectedDate!.startDate!);
  notifyListeners();
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
            maxDate: DateTime.now().add(const Duration(days: 365)),
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              selectedDate = args.value;
              if(selectedDate?.endDate!=null){
                _startDate="${selectedDate?.startDate?.day.toString().padLeft(2,"0")}"
                    "-${selectedDate?.startDate?.month.toString().padLeft(2,"0")}"
                    "-${selectedDate?.startDate?.year.toString()}";

                _endDate="${selectedDate?.endDate?.day.toString().padLeft(2,"0")}"
                    "-${selectedDate?.endDate?.month.toString().padLeft(2,"0")}"
                    "-${selectedDate?.endDate?.year.toString()}";
              }else{
                _startDate="${selectedDate?.startDate?.day.toString().padLeft(2,"0")}"
                    "-${selectedDate?.startDate?.month.toString().padLeft(2,"0")}"
                    "-${selectedDate?.startDate?.year.toString()}";
                _endDate="";
              }
              notifyListeners();
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
                  getLeaveReport(_filter);
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
}

  void reportPick({required BuildContext context,required String date,required String type}){
    DateTime dateTime=DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    ).then((value) async {
      dateTime=value!;
      date= ("${(dateTime.day.toString().padLeft(2,"0"))}-"
          "${(dateTime.month.toString().padLeft(2,"0"))}-"
          "${(dateTime.year.toString())}");
      // if(type=="1"){
      //   attendanceServices.getDailyReport();
      // }else if(type=="2"){
      //   attendanceServices.getWeeklyReport();
      // }else if(type=="3"){
      //   attendanceServices.getMonthlyReport();
      // }else if(type=="4"){
      //   attendanceServices.dailyRefresh();
      // }else if(type=="5"){
      // }
    });
  }
  void changeReportType(dynamic value){
    _report = value;
  notifyListeners();
}  void changeLeaveType(dynamic value){
   _type = value;
    var list = [];
    list.add(value);
    _typeId = list[0]["id"];
  notifyListeners();
}  void changeType(dynamic value){
    _dayType = value;
  notifyListeners();
}
void changePage(context){
    _settingPage = false;
    _addType=false;
    _selectedIndex = 0;
    utils.navigatePage(context, ()=>const DashBoard(child: LeaveManagementDashboard()));
    // setList();
  notifyListeners();
}
void searchReport(String value){
  if(_filter==false){
    final suggestions = myLev.where(
            (user) {
          final userName = user.fName.toString()
              .toLowerCase();
          final input = value.toString()
              .toLowerCase()
              .trim();
          return userName.contains(input);
        }).toList();
    myLevSearch = suggestions;
  }else{
    final suggestions = myLevSearch.where(
            (user) {
          final userName = user.fName.toString()
              .toLowerCase();
          final input = value.toString()
              .toLowerCase()
              .trim();
          return userName.contains(input);
        }).toList();
    myLevSearch = suggestions;
    if(value.isEmpty){
      getLeaveReport(_filter);
    }
  }
  notifyListeners();
}
void changePage2(){
    _addType=false;
    setList();
  notifyListeners();
}
  PickerDateRange? selectedDate;
  List<DateTime> datesBetween = [];
  String betweenDates="";
  void showDatePickerDialog(BuildContext context) {
    DateTime today = DateTime.now();
    if(_stDate!=""||_enDate!=""){
      DateFormat inputFormat = DateFormat('dd-MM-yyyy');

      DateTime start = inputFormat.parse(_stDate);
      DateTime end;

      if (_enDate != "" && _enDate!="") {
        end = inputFormat.parse(_enDate);
      } else {
        end = start;   // single-day selection
      }

      if (end.isBefore(start)) {
        final temp = start;
        start = end;
        end = temp;
      }

      selectedDate = PickerDateRange(start, end);
    }else{
      selectedDate = PickerDateRange(today, today);
    }
    notifyListeners();
    datesBetween = getDatesInRange(selectedDate!.startDate!, selectedDate!.endDate!);

    DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    List<String> formattedDates = datesBetween.map((date) => dateFormat.format(date)).toList();
    betweenDates = formattedDates.join(' || ');

    _stDate = dateFormat.format(selectedDate!.startDate!);
    notifyListeners();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomText(text: '   Select Date',colors: colorsConst.secondary,isBold: true,),
          content: SizedBox(
            height: 300, // Adjust height as needed
            width: 300, // Adjust width as needed
            child: SfDateRangePicker(
              minDate: DateTime.now(),
              initialSelectedRange: selectedDate,   // ✔ REQUIRED
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                selectedDate = args.value;
                _stDate="";
                _enDate="";
                if(selectedDate?.endDate!=null){
                  _stDate="${selectedDate?.startDate?.day.toString().padLeft(2,"0")}"
                      "-${selectedDate?.startDate?.month.toString().padLeft(2,"0")}"
                      "-${selectedDate?.startDate?.year.toString()}";

                  _enDate="${selectedDate?.endDate?.day.toString().padLeft(2,"0")}"
                      "-${selectedDate?.endDate?.month.toString().padLeft(2,"0")}"
                      "-${selectedDate?.endDate?.year.toString()}";
                }else{
                  _stDate="${selectedDate?.startDate?.day.toString().padLeft(2,"0")}"
                      "-${selectedDate?.startDate?.month.toString().padLeft(2,"0")}"
                      "-${selectedDate?.startDate?.year.toString()}";
                }
                notifyListeners();
              },
              selectionMode: DateRangePickerSelectionMode.range,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(text: 'Click and drag to select multiple dates',colors: colorsConst.greyClr,),
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
  }
  List<DateTime> getDatesInRange(DateTime start, DateTime end) {
    List<DateTime> days = [];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      days.add(DateTime(start.year, start.month, start.day + i));
    }
    return days;
  }
void changeIndex(int index){
    _selectedIndex = index;
    _addType = false;
    _settingPage = false;
    // setList();
  notifyListeners();
  }
   List<Widget> _mainContents = [];
   List<Widget> get mainContents => _mainContents;
  void changeAddType(){
    _addType = true;
    // setList();
  notifyListeners();
}
void setList(){
  _mainContents = [
    const FixedLeave(),
    _addType==false?
    const LeaveTypes():const AddType(),
    const ViewMyLeaves(),
    const ApplyLeave(),
    const AddLeaveRules(),
  ];
}
  List types=[];
  RoundedLoadingButtonController submitCtr=RoundedLoadingButtonController();
  RoundedLoadingButtonController addCtr=RoundedLoadingButtonController();
  RoundedLoadingButtonController leaveCtr=RoundedLoadingButtonController();
  String _levCount1 = "Full  Day 0\nHalf Day 0";
  String _levCount2 = "Full  Day 0\nHalf Day 0";
  String _levCount3 = "Full  Day 0\nHalf Day 0";
  String _levCount4 = "Full  Day 0\nHalf Day 0";
  String get levCount1 => _levCount1;
  String get levCount2 => _levCount2;
  String get levCount3 => _levCount3;
  String get levCount4 => _levCount4;
  bool _refresh = true;
  bool _isLeave = true;
  bool _isLoading = false;
  bool _isLoading2 = false;
  bool _isLoading3 = false;
  bool _isLoading4 = false;
  bool _settingPage = false;
  bool _addType = false;
  bool _getTypes = true;
  bool get refresh => _refresh;
  bool get isLeave => _isLeave;
  bool get isLoading => _isLoading;
  bool get isLoading2 => _isLoading2;
  bool get isLoading3 => _isLoading3;
  bool get isLoading4 => _isLoading4;
  bool get settingPage => _settingPage;
  bool get getTypes => _getTypes;
  bool get addType => _addType;
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
  void selectUser(dynamic value) {
      var list = value.toString().split(',');
      _name = value;
      _nameId = list[0];
      localData.storage.write("leave_emp_name",list[1]);
      // _nameId = value.id.toString();
    notifyListeners();
  }
  void selectUser2(dynamic value) {
      var list = value.toString().split(',');
      _name = value;
      _nameId = list[0];
      // _nameId = value.id.toString();
      getLeavesRules(_nameId);
    notifyListeners();
  }
  Future<void> addLeaveRule(context) async {
    try {
      final Map<String, dynamic> data = {
        'action': addLeaveRules,
        'ruleList': rulesList, // The list
        'log_file': localData.storage.read("mobile_number"), // The list
      };
      final response =await leaveRepo.addEmployee(data);
      log(response.toString());
      if (response["status_code"]==200){
        utils.showSuccessToast(context: context,text: "Updated Successfully");
        rulesList.clear();
        getLeavesRules(_nameId);
        submitCtr.reset();
      }else {
        utils.showErrorToast(context: context);
        submitCtr.reset();
      }
    } catch (e) {
      log(e.toString());
      utils.showErrorToast(context: context);
      submitCtr.reset();
    }
    notifyListeners();
  }

  Future<void> addTypes(context) async {
    try {
      Map data = {
        "action":leaveType,
        "search_type":"add_leave",
        "type":reason.text.trim(),
        "created_by":localData.storage.read("id"),
        "platform": localData.storage.read("platform"),
        "cos_id":localData.storage.read("cos_id")
      };
      final response =await leaveRepo.addEmployee(data);
      log(response.toString());
      if (response.toString().contains("already exits")){
        utils.showWarningToast(context,text: "This type already exits");
        addCtr.reset();
      }else if (response["status_code"]==200){
        utils.showSuccessToast(context: context,text: "Added Successfully");
        _selectedIndex=1;
        _addType=false;
        getLeaveTypes();
        addCtr.reset();
      }else {
        utils.showErrorToast(context: context);
        addCtr.reset();
      }
    } catch (e) {
      log(e.toString());
      utils.showErrorToast(context: context);
      addCtr.reset();
    }
    notifyListeners();
  }

  Future<void> deleteLeaveType(context,String typeId) async {
    try {
      Map data = {
        "action":leaveType,
        "search_type":"type_delete",
        "id":typeId,
        "updated_by":localData.storage.read("id"),
        "up_platform": localData.storage.read("platform"),
        "cos_id":localData.storage.read("cos_id")
      };
      final response =await leaveRepo.addEmployee(data);
      log(response.toString());
      if (response.toString().contains("Data deleted Successfully")){
        Navigator.pop(context);
        utils.showSuccessToast(context: context,text: "Deleted Successfully");
        setList();
        getLeaveTypes();
        submitCtr.reset();
      }else {
        utils.showErrorToast(context: context);
        submitCtr.reset();
      }
    } catch (e) {
      log(e.toString());
      utils.showErrorToast(context: context);
      submitCtr.reset();
    }
    notifyListeners();
  }
  Future<void> deleteLeave(context,String leaveId) async {
    try {
      Map data = {
        "action":leaveType,
        "search_type":"leave_delete",
        "id":leaveId,
        "updated_by":localData.storage.read("id"),
        "up_platform": localData.storage.read("platform"),
        "cos_id":localData.storage.read("cos_id")
      };
      final response =await leaveRepo.addEmployee(data);
      log(response.toString());
      if (response.toString().contains("Data deleted Successfully")){
        Navigator.pop(context);
        utils.showSuccessToast(context: context,text: "Deleted Successfully");
        getLeaveReport(_filter);
        submitCtr.reset();
      }else {
        utils.showErrorToast(context: context);
        submitCtr.reset();
      }
    } catch (e) {
      log(e.toString());
      utils.showErrorToast(context: context);
      submitCtr.reset();
    }
    notifyListeners();
  }

  Future<void> fixLeaves(context,String date,String reason) async {
    try {
      Map data = {
        "action":fixLeave,
        "search_type":"fix_leave",
        "platform":localData.storage.read("platform"),
        "created_by":localData.storage.read("id"),
        "reason":reason,
        "lev_date":date,
        "cos_id":localData.storage.read("cos_id")
      };
      final response =await leaveRepo.addEmployee(data);
      log(response.toString());
      if(response.toString().contains("Leave already applied on this date")){
        Navigator.pop(context);
        utils.showWarningToast(context,text: "Leave already applied on this date.");
        submitCtr.reset();
      } else if(response.toString().contains("This date already exists")){
        Navigator.pop(context);
        utils.showWarningToast(context,text: "Leave already applied on this date.");
        submitCtr.reset();
      }else if (response["status_code"]==200){
        submitCtr.reset();
        Navigator.pop(context);
        utils.showSuccessToast(context:context,text: "Fixed Successfully");
        getTotalLeaves(true);
      }else {
        Navigator.pop(context);
        utils.showErrorToast(context: context);
        submitCtr.reset();
      }
    } catch (e) {
      log(e.toString());
      utils.showErrorToast(context: context);
      submitCtr.reset();
    }
    notifyListeners();
  }

  Future<void> updateLeaves(context,String id,String reason) async {
    try {
      Map data = {
        "action":fixLeave,
        "search_type":"leave_update",
        "id":id,
        "up_platform":localData.storage.read("platform"),
        "updated_by":localData.storage.read("id"),
        "reason":reason,
        "cos_id":localData.storage.read("cos_id")
      };
      final response =await leaveRepo.addEmployee(data);
      log(response.toString());
      if (response.toString().contains("Data Modified Successfully")){
        utils.showSuccessToast(context: context,text: "Updated Successfully");
        submitCtr.reset();
        getTotalLeaves(false);
        Navigator.pop(context);
      }else if(response.toString().contains("Leave already applied on this date")){
        utils.showWarningToast(context,text: "Leave already applied on this date.");
        submitCtr.reset();
      } else if(response.toString().contains("This date already exists")){
        Navigator.pop(context);
        utils.showWarningToast(context,text: "Leave already applied on this date.");
        submitCtr.reset();
      }else {
        Navigator.pop(context);
        utils.showErrorToast(context: context);
        submitCtr.reset();
      }
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);
      utils.showErrorToast(context: context);
      submitCtr.reset();
    }
    notifyListeners();
  }

  Future<void> deleteLeaves(context,String id) async {
    try {
      Map data = {
        "action":fixLeave,
        "search_type":"leave_delete",
        "id":id,
        "up_platform":localData.storage.read("platform"),
        "updated_by":localData.storage.read("id"),
        "cos_id":localData.storage.read("cos_id")
      };
      final response =await leaveRepo.addEmployee(data);
      log(response.toString());
      if (response.toString().contains("Data deleted Successfully")){
        utils.showSuccessToast(context:context,text: "Deleted Successfully");
        submitCtr.reset();
        getTotalLeaves(false);
        Navigator.pop(context);
      }else if(response.toString().contains("Leave already applied on this date")){
        Navigator.pop(context);
        utils.showWarningToast(context,text: "Leave already applied on this date.");
        submitCtr.reset();
      } else if(response.toString().contains("This date already exists")){
        Navigator.pop(context);
        utils.showWarningToast(context,text: "Leave already applied on this date.");
        submitCtr.reset();
      }else {
        utils.showErrorToast(context: context);
        submitCtr.reset();
      }
    } catch (e) {
      log(e.toString());
      utils.showErrorToast(context: context);
      submitCtr.reset();
    }
    notifyListeners();
  }

  Future<void> leaveApply(context) async {
    try {
      Map data = {
        "action":applyLeave,
        "search_type":"apply",
        "reason":reason.text.trim(),
        "day_type":dayType.toString(),
        "lev_type":typeId,
        "start_date":stDate,
        "end_date":enDate==""?stDate:enDate,
        "platform":localData.storage.read("platform"),
        "created_by":localData.storage.read("id"),
        "user_id":localData.storage.read("role")=="1"?nameId:localData.storage.read("id"),
        "cos_id":localData.storage.read("cos_id"),
        "session":_session1==true?"Morning":"Afternoon",
      };
      final response =await leaveRepo.addEmployee(data);
      log(response.toString());
      if (response.toString().contains('Leave application successful')){
        utils.showSuccessToast(context:context,text: "Applied Successfully");
        Provider.of<EmployeeProvider>(context, listen: false).sendAdminNotification(
          "${localData.storage.read("role")!="1"?localData.storage.read("f_name"):localData.storage.read("leave_emp_name")} Requested for ${_dayType.toString()=="0.5"?"Half Day Leave":"Leave"} - $stDate ${enDate==""?"":" to $enDate"}",
          reason.text.trim(),
          "1",
        );
        await FirebaseFirestore.instance.collection('attendance').add({
          'emp_id': localData.storage.read("id"),
          'time': DateTime.now(),
          'status': "",
        });
        leaveCtr.reset();
        if({"1"}.contains(localData.storage.read("role"))){
          _selectedIndex=2;
        }else{
          getLeaveReport(_filter);
          Navigator.pop(context);
        }
        leaveCtr.reset();
      }else if(response.toString().contains("This day already has a leave for")){
        utils.showWarningToast(context,text: response["Failed"]);
        leaveCtr.reset();
      }else if(response.toString().contains("Leave already applied on this date")){
        utils.showWarningToast(context,text: "Leave already applied on this date.");
        leaveCtr.reset();
      }else if(response.toString().contains("Half-day leave already applied for Afternoon")){
        utils.showWarningToast(context,text: "Half-day leave already applied for Afternoon on this date");
        leaveCtr.reset();
      }else if(response.toString().contains("Half-day leave already applied for Morning")){
        utils.showWarningToast(context,text: "Half-day leave already applied for Morning on this date");
        leaveCtr.reset();
      }else if(response.toString().contains("Half-day leave already applied on")){
        utils.showWarningToast(context,text: "Half-day leave already applied on this date");
        leaveCtr.reset();
      }else {
        utils.showErrorToast(context: context);
        leaveCtr.reset();
      }
      leaveCtr.reset();
    } catch (e) {
      log(e.toString());
      utils.showErrorToast(context: context);
      leaveCtr.reset();
    }
    leaveCtr.reset();
    notifyListeners();
  }
  // List<Map<String, dynamic>> cleanFirstSaturdays(List<Map<String, dynamic>> list) {
  //   final Map<String, Map<String, dynamic>> uniqueMap = {};
  //
  //   for (var item in list) {
  //     String date = item['lev_date'];
  //     if (!uniqueMap.containsKey(date) || item['isClick'] == "1") {
  //       uniqueMap[date] = item;
  //     }
  //   }
  //
  //   return uniqueMap.values.toList();
  // }
  bool _isChanged=false;
  bool get isChanged=> _isChanged;
void changeStatus(bool value){
  _isChanged=value;
  notifyListeners();
}
  Future<void> insertLeaveDays(context) async {
    getAllSundays(int.parse(_year), _allSunday == true ? "1" : "0");
    getFirstSaturdays(int.parse(_year), customSaturdays1, _saturday1 == true ? "1" : "0");
    getSecondSaturdays(int.parse(_year), customSaturdays2, _saturday2 == true ? "1" : "0");
    getThirdSaturdays(int.parse(_year), customSaturdays3, _saturday3 == true ? "1" : "0");
    getFourthSaturdays(int.parse(_year), customSaturdays4, _saturday4 == true ? "1" : "0");
    getFifthSaturdays(int.parse(_year), customSaturdays5, _saturday5 == true ? "1" : "0");
    notifyListeners();
    List<Map<String, dynamic>> dataList = [];
    for(var i=0;i<searchFutureHolidays.length;i++){
      dataList.add({
        "lev_date":searchFutureHolidays[i].date,
        "reason":searchFutureHolidays[i].name,
        "created_by":localData.storage.read("id"),
        "platform":"1",
        "isClick":searchFutureHolidays[i].isClick==true?"1":"0",
      });
    }

    dataList.addAll(sundays);
    dataList.addAll(customSaturdays1);
    dataList.addAll(customSaturdays2);
    dataList.addAll(customSaturdays3);
    dataList.addAll(customSaturdays4);
    dataList.addAll(customSaturdays5);

    // final cleanedList = cleanFirstSaturdays(dataList);
    log("cleanedList : $dataList");
    // log(cleanedList.toString());
    notifyListeners();
    if(dataList.isEmpty){
      utils.showWarningToast(context, text: "Select leave dates");
      submitCtr.reset();
    }else{
      final Map<String, dynamic> data = {
        'action': listLeaves,
        "cos_id": localData.storage.read("cos_id"),
        'leaveList': dataList,
      };
      final response = await leaveRepo.addEmployee(data);
      if (response.toString().contains("Inserted Successfully")) {
        utils.showSuccessToast(context: context, text: "Updated Successfully");
        getTotalLeaves(true);
        _settingPage = false;
        setList();
        notifyListeners();
        submitCtr.reset();
      }
      else {
        // utils.toast(context: context, text: "Failed");
        // submitCtr.reset();
        utils.showSuccessToast(context: context, text: "Updated Successfully");
        getTotalLeaves(true);
        _settingPage = false;
        setList();
        notifyListeners();
        submitCtr.reset();
      }
    }
    notifyListeners();
  }


  bool hasAppointment(DateTime date) {
    return dataSource.appointments!.any((appt) =>
    appt.startTime.year == date.year &&
        appt.startTime.month == date.month &&
        appt.startTime.day == date.day);
  }
  bool hasStatus(DateTime date, String status) {
    return dataSource.appointments!.any((appt) =>
    appt.startTime.year == date.year &&
        appt.startTime.month == date.month &&
        appt.startTime.day == date.day &&
        (appt.subject?.toLowerCase() ?? '') == status.toLowerCase());
  }
  String _filterDate = "";
  String get filterDate=>_filterDate;
  DateTime _calenderSelectedDate = DateTime.now();

  DateTime get calenderSelectedDate => _calenderSelectedDate;
  void filterDateList(String value,DateTime dateTime){
    _filterDate=value;
    _calenderSelectedDate = dateTime;
    // print("filterDateList");
    notifyListeners();
  }
  int _filterTasks = 0;
  int get filterTasks=>_filterTasks;
  void checkMonth(ViewChangedDetails details){
    _filterDate="";
    // _filterTasks=0;
    // _thisMonthLeave="0";

    _defaultMonth = details.visibleDates[15].month;
    int count = 0;

    Set<String> uniqueDates = {};

    for (var i = 0; i < _fixedLeaves.length; i++) {

      String dateStr = _fixedLeaves[i].levDate.toString(); // "2025-05-03"
      DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(dateStr);

      // print("➡️ Raw levDate: $dateStr");
      // print("➡️ Parsed date: $parsedDate");

      if (_defaultMonth == parsedDate.month) {

        String onlyDate = parsedDate.toIso8601String().substring(0, 10);

        if (uniqueDates.contains(onlyDate)) {
          // print("⚠️ Duplicate date skipped: $onlyDate");
        } else {
          // print("✅ New date added: $onlyDate");
        }

        uniqueDates.add(onlyDate);
      }
    }

    // print("📊 Unique leave dates (this month): $uniqueDates");
    // print("📌 Leave count (this month): ${uniqueDates.length}");

    _thisMonthLeave = uniqueDates.length.toString();


    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

  }

  void getTotalLeaves(bool isRefresh) async {
    _fixedLeaves=await yearlyLeaves(isRefresh,false,"01-01-$_year","31-12-$_year");
  }
  List<RulesModel> _leavesRules= <RulesModel>[];
  List<RulesModel> get  leavesRules=> _leavesRules;

  void getLeavesRules(String empId) async {
    for(var j=0;j<types.length;j++){
      types[j]["days"].text='0';
    }
    _leavesRules.clear();
    _isLeave=false;
    await getRules(empId);
    // leavesRules=await getRules(empId);
    if(_leavesRules.isNotEmpty){
      for (var i=0;i<_leavesRules.length;i++){
        for(var j=0;j<types.length;j++){
          if(_leavesRules[i].typeId.toString()==types[j]["id"]){
            types[j]["days"].text=_leavesRules[i].days.toString();
          }
        }
      }
    }
    _isLeave=true;
  }

  Future<void> getRules(String empId) async {
    try {
      Map data = {
        "action":getLeaveData,
        "search_type":"emp_leave_rules",
        "emp_id":empId,
        "cos_id":localData.storage.read("cos_id")
      };
      // print("rules");
      final response = await leaveRepo.getRules(data);
      // print(response);
      if(response.isNotEmpty){
        _leavesRules=response;
        _isLeave=true;
      }
      else{
        _isLeave=true;
      }
    } catch (e) {
      _isLeave=true;
    }
    notifyListeners();
  }

  Future<void> getLeaveTypes() async {
    try {
      Map data = {
        "action":getLeaveData,
        "search_type":"leave_types",
        "cos_id":localData.storage.read("cos_id")
      };
      final response = await leaveRepo.getList(data);
      if(response.isNotEmpty) {
        types.clear();
        for (var i = 0; i < response.length; i++) {
          types.add({
            "id": response[i]["id"],
            "type": response[i]["type"],
            "days": TextEditingController(text: '0')
          });
          _getTypes = true;
        }
      }
      else{
        _getTypes=true;
      }
    } catch (e) {
      _getTypes=true;
    }
    notifyListeners();
  }
  void initDates({required String id, required String role, bool? isRefresh, String? date1, String? date2, String? type}){
    _typeReport=type;
    search.clear();
    _filter=false;
    _user=null;
    _userName="";
    daily(id, role, isRefresh);
    notifyListeners();
  }
  Future<List<LeaveModel>> ourLeaves(String st,String en,bool refresh,String id) async {
    try {
      myLev4Search.clear();
      notifyListeners();
      Map data = {
        "action":getLeaveData,
        "search_type":"my_leave",
        "id":id,
        "st_dt":st,
        "en_dt":en==""?st:en,
        "cos_id":localData.storage.read("cos_id")
      };
      final response = await leaveRepo.getLeave(data);
      if(response.isNotEmpty){
        _isLoading4=true;
        myLev4Search=response;
        return response;
      }
      else{
        _isLoading4=true;
        myLev4Search.clear();
        notifyListeners();
        throw Exception('Failed to work flow');
      }
    } catch (e) {
      _isLoading4=true;
      myLev4Search.clear();
      notifyListeners();
      throw Exception('Failed to work flow');
    }
  }
  Future<List<LeaveModel>> myLeaves(String st,String en,bool refresh,String id) async {
    try {
      _levCount1="Full  Day 0\nHalf Day 0";
      myLevSearch.clear();
      myLev.clear();
      notifyListeners();
      Map data = {
        "action":getLeaveData,
        "search_type":"my_leave",
        "id":id,
        "st_dt":st,
        "en_dt":en==""?st:en,
        "cos_id":localData.storage.read("cos_id")
      };
      final response = await leaveRepo.getLeave(data);
      if(response.isNotEmpty){
        _isLoading=true;
        _isLoading2=true;
        _isLoading3=true;
        _isLoading4=true;
        refresh=true;
        notifyListeners();
        myLevSearch=response;
        myLev=response;
        if(_filter==true){
          final dateFormat = DateFormat('dd-MM-yyyy');
          final parsedDate1 = dateFormat.parse(_startDate);
          final parsedDate2 = dateFormat.parse(_endDate);

          myLevSearch = myLev.where((contact) {
            String timestamp = contact.startDate.toString();
            List<String> times = timestamp.split(',');
            DateTime startTime = DateTime.parse(times[0]);

            DateTime createdTsDate = startTime;
            final createdDateOnly = DateTime(
                createdTsDate.year, createdTsDate.month, createdTsDate.day);

            final isWithinDateRange =
                !createdDateOnly.isBefore(parsedDate1) &&
                    !createdDateOnly.isAfter(parsedDate2);

            final isIdMatch = _user == contact.userId;

            // 🔍 Print matching conditions
            if (_user == null || _user == "") {
              if (isWithinDateRange) {
                print("MATCH → Date: $createdDateOnly | User: ${contact.userId}");
              }
              return isWithinDateRange;
            } else {
              if (isWithinDateRange && isIdMatch) {
                print(
                    "MATCH → Date: $createdDateOnly | User Match: ${contact.userId}");
              }
              return isWithinDateRange && isIdMatch;
            }
          }).toList();
        }
        _levCount1="Full  Day 0\nHalf Day 0";
        Map<String, Map<String, dynamic>> employeeMap = {};
        Map<String, Map<String, dynamic>> halfEmployeeMap = {};
        num h=0;
        num f=0;
        for (var item in myLevSearch) {
          // print("item.dayType");
          // print(item.dayType);
          String id = item.userId ?? '';

          if (item.dayType.toString() == "0.5") {
            h += double.tryParse(item.dayCount ?? "0") ?? 0;
            if (!halfEmployeeMap.containsKey(id)) {
              halfEmployeeMap[id] = {'id': id};
            }
          } else {
            f += int.tryParse(item.dayCount ?? "0") ?? 0;
            if (!employeeMap.containsKey(id)) {
              employeeMap[id] = {'id': id};
            }
          }
        }
        _levCount1="Full  Day $f\nHalf Day $h";
        // print("--------");
        // print("${myLev.length}");
        // print("${myLevSearch.length}");
        return response;
      }
      else{
        _levCount1="Full  Day 0\nHalf Day 0";
        _isLoading=true;
        _isLoading2=true;
        _isLoading3=true;
        _isLoading4=true;
        refresh=true;
        myLevSearch.clear();
        myLev.clear();
        notifyListeners();
        throw Exception('Failed to work flow');
      }
    } catch (e) {
      _levCount1="Full  Day 0\nHalf Day 0";
      _isLoading=true;
      _isLoading2=true;
      _isLoading3=true;
      _isLoading4=true;
      refresh=true;
      myLevSearch.clear();
      myLev.clear();
      notifyListeners();
      throw Exception('Failed to work flow');
    }
  }

  Future<List<LeaveModel>> allLeaves(String st,String en,bool refresh) async {
    try {
      _levCount1="Full  Day 0\nHalf Day 0";
      myLevSearch.clear();
      myLev.clear();
      notifyListeners();
      Map data = {
        "action":getLeaveData,
        "search_type":"all_leave",
        "st_dt":st,
        "en_dt":en,
        "cos_id":localData.storage.read("cos_id")
      };
      final response = await leaveRepo.getLeave(data);
      // print(data);
      // print(response);
      if(response.isNotEmpty){
        _isLoading=true;
        _isLoading2=true;
        _isLoading3=true;
        _isLoading4=true;
        notifyListeners();
        myLevSearch=response;
        myLev=response;
        if(_filter==true){
          final dateFormat = DateFormat('dd-MM-yyyy');
          final parsedDate1 = dateFormat.parse(_startDate);
          final parsedDate2 = dateFormat.parse(_endDate);

          myLevSearch = myLev.where((contact) {
            String timestamp = contact.startDate.toString();
            List<String> times = timestamp.split(',');
            DateTime startTime = DateTime.parse(times[0]);

            DateTime createdTsDate = startTime;
            final createdDateOnly = DateTime(
                createdTsDate.year, createdTsDate.month, createdTsDate.day);

            final isWithinDateRange =
                !createdDateOnly.isBefore(parsedDate1) &&
                    !createdDateOnly.isAfter(parsedDate2);

            final isIdMatch = _user == contact.userId;

            // 🔍 Print matching conditions
            if (_user == null || _user == "") {
              if (isWithinDateRange) {
                print("MATCH → Date: $createdDateOnly | User: ${contact.userId}");
              }
              return isWithinDateRange;
            } else {
              if (isWithinDateRange && isIdMatch) {
                print(
                    "MATCH → Date: $createdDateOnly | User Match: ${contact.userId}");
              }
              return isWithinDateRange && isIdMatch;
            }
          }).toList();
        }
        _levCount1="Full  Day 0\nHalf Day 0";
        Map<String, Map<String, dynamic>> employeeMap = {};
        Map<String, Map<String, dynamic>> halfEmployeeMap = {};
        num h=0;
        num f=0;
        for (var item in myLevSearch) {
          String id = item.userId ?? '';

          if (item.dayType.toString() == "0.5") {
            h += double.tryParse(item.dayCount ?? "0") ?? 0;
            if (!halfEmployeeMap.containsKey(id)) {
              halfEmployeeMap[id] = {'id': id};
            }
          } else {
            f += int.tryParse(item.dayCount ?? "0") ?? 0;
            if (!employeeMap.containsKey(id)) {
              employeeMap[id] = {'id': id};
            }
          }
        }
        _levCount1="Full  Day ${employeeMap.values.toList().length}\nHalf Day ${halfEmployeeMap.values.toList().length}";
        // print("--------");
        // print("${myLev.length}");
        // print("${myLevSearch.length}");
        return response;
      }
      else{
        _levCount1="Full  Day 0\nHalf Day 0";
        _isLoading=true;
        _isLoading2=true;
        _isLoading3=true;
        _isLoading4=true;
        myLevSearch.clear();
        myLev.clear();
        notifyListeners();
        throw Exception('Failed to work flow');
      }
    } catch (e) {
      _levCount1="Full  Day 0\nHalf Day 0";
      _isLoading=true;
      _isLoading2=true;
      _isLoading2=true;
      _isLoading3=true;
      _isLoading4=true;
      myLevSearch.clear();
      myLev.clear();
      notifyListeners();
      throw Exception('Failed to work flow');
    }
  }

  Future<List<Holiday>> fetchHolidays(String year) async {
    try {
      searchFutureHolidays=[];
      futureHolidays=[];
      notifyListeners();
      Map data = {
        "action":getLeaveData,
        "search_type":"year_leave",
        "st_dt":"$year-01-01",
        "en_dt":"$year-12-31",
        "cos_id":localData.storage.read("cos_id")
      };
      final response = await leaveRepo.getHolyDays(data);
      if(response.isNotEmpty){
        _getLeave=true;
        searchFutureHolidays=response;
        futureHolidays=response;
        notifyListeners();
        return response;
      }
      else{
        searchFutureHolidays=[];
        futureHolidays=[];
        _getLeave=true;
        notifyListeners();
        throw Exception('Failed to work flow');
      }
    } catch (e) {
      searchFutureHolidays=[];
      futureHolidays=[];
      _getLeave=true;
      notifyListeners();
      throw Exception('Failed to work flow');
    }
  }


  int total=0;
  late CalendarDataSource dataSource;


  dynamic _defaultMonth=DateTime.now().month;
  dynamic get defaultMonth =>_defaultMonth;
  String _thisMonthLeave = "0";
  String get thisMonthLeave=>_thisMonthLeave;
  List<HolyDaysModel> _fixedLeaves= <HolyDaysModel>[];
  List<HolyDaysModel> get fixedLeaves=> _fixedLeaves;
  void checkMonth2() {
    var count = 0;
    final DateFormat formatter = DateFormat('dd-MM-yyyy');

    for (var i = 0; i < _fixedLeaves.length; i++) {
      String formattedLevDate = formatter.format(DateTime.parse(_fixedLeaves[i].levDate.toString()));
      // print('_filterDate onTap: $_filterDate');
      // print('Formatted levDate: $formattedLevDate');

      if (_filterDate == formattedLevDate) {
        count++;
      }
    }

    _filterTasks = count;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
  String _startDate = "";
  String get startDate => _startDate;
  String _endDate="";
  String get endDate => _endDate;
  dynamic _user;
  dynamic get user=>_user;
  String _userName="";
  String get userName=>_userName;
  var typeList = ["Today","Yesterday","Last 7 Days","Last 30 Days","This Week","This Month","Last 3 months"];
  dynamic _typeReport;
  dynamic get typeReport=>_typeReport;
  void changeRrtType(value,String id ,String role,bool? isRefresh){
    _typeReport=value;
    if(_typeReport=="Today"){
      daily(id,role,isRefresh);
    }else if(_typeReport=="Yesterday"){
      yesterday(id,role,isRefresh);
    }else if(_typeReport=="Last 7 Days"){
      last7Days(id,role,isRefresh);
    }else if(_typeReport=="Last 30 Days"){
      last30Days(id,role,isRefresh);
    }else if(_typeReport=="This Week"){
      thisWeek(id,role,isRefresh);
    }else if(_typeReport=="This Month"){
      thisMonth(id,role,isRefresh);
    }else if(_typeReport=="Last 3 months"){
      last3Month(id,role,isRefresh);
    }else{

    }

    notifyListeners();
  }
  DateTime stDt = DateTime.now();
  DateTime enDt = DateTime.now().add(const Duration(days: 1));
  void daily(String id ,String role,bool? isRefresh) {
    stDt=DateTime.now();
    enDt=DateTime.now().add(const Duration(days: 1));
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(stDt);
    getLeaveReport(_filter);
    notifyListeners();
  }
  void yesterday(String id ,String role,bool? isRefresh) {
    stDt=DateTime.now().subtract(const Duration(days: 1));
    enDt = DateTime.now();
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(stDt);
    getLeaveReport(_filter);
    notifyListeners();
  }
  void last7Days(String id ,String role,bool? isRefresh) {
    DateTime now = DateTime.now();
    DateTime lastWeekStart = now.subtract(const Duration(days: 6));
    DateTime lastWeekEnd = now;
    _startDate = DateFormat('dd-MM-yyyy').format(lastWeekStart);
    _endDate = DateFormat('dd-MM-yyyy').format(lastWeekEnd);
    getLeaveReport(_filter);
    notifyListeners();
  }
  void last30Days(String id ,String role,bool? isRefresh) {
    DateTime now = DateTime.now();
    DateTime lastMonthStart = now.subtract(const Duration(days: 29));
    DateTime lastMonthEnd = now;
    _startDate = DateFormat('dd-MM-yyyy').format(lastMonthStart);
    _endDate = DateFormat('dd-MM-yyyy').format(lastMonthEnd);
    getLeaveReport(_filter);
    notifyListeners();
  }
  void thisWeek(String id ,String role,bool? isRefresh) {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;
    DateTime stDt = now.subtract(Duration(days: currentWeekday - 1));
    DateTime enDt = now.add(Duration(days: 7 - currentWeekday));
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    getLeaveReport(_filter);
    notifyListeners();
  }
  void thisMonth(String id ,String role,bool? isRefresh) {
    DateTime now = DateTime.now();
    stDt = DateTime(now.year, now.month, 1);
    enDt = now; // Today’s date
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    getLeaveReport(_filter);
    notifyListeners();
  }
  void last3Month(String id ,String role,bool? isRefresh) {
    DateTime now = DateTime.now();
    DateTime stDt = DateTime(now.year, now.month - 2, now.day);
    DateTime enDt = now;

    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    getLeaveReport(_filter);
    notifyListeners();
  }

  void selectUserReport(UserModel value){
    _user=value.id;
    _userName=value.firstname.toString();
    // filterList(true);
    notifyListeners();
  }
  void datePick({required BuildContext context,  required String date, required bool isStartDate}) {
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
      lastDate: DateTime(
        DateTime.now().year,
        DateTime.now().month + 1,
        DateTime.now().day,
      ),
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
  Future<List<HolyDaysModel>> yearlyLeaves(bool isRefresh,bool isMonthly,String date1,String date2) async {
    // try{

    _defaultMonth =DateTime.now().month;
      if(isRefresh==true){
        _refresh=false;
        fixedLeaves.clear();
        _thisMonthLeave="0";
      }
    dataSource.dispose();
    dataSource.appointments?.clear();
    notifyListeners();
      Map data = {
        "action":getLeaveData,
        "search_type":"yearly_leaves",
        "st_dt":date1,
        "en_dt":date2,
        "cos_id":localData.storage.read("cos_id")
      };
      final request = await http.post(Uri.parse(leavePhpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print(data.toString());
      // print(request.body);
      if (request.statusCode == 200) {
        final List response= json.decode(request.body);
        total=response.length;
        if(isMonthly==false){
          // for(var i=0;i<response.length;i++){
          //   DateTime dateObject = DateTime.parse(response[i]["lev_date"]);
          //   Appointment app = Appointment(
          //     startTime: dateObject,
          //     endTime: dateObject,
          //     subject: response[i]["reason"],
          //     color: colorsConst.primary,
          //   );
          //   dataSource.appointments!.add(app);
          //   dataSource.notifyListeners(CalendarDataSourceAction.add, <Appointment>[app]);
          //   // print("Adding Appointment....");
          //   var count=0;
          //   for(var i=0;i<response.length;i++){
          //     var st = DateTime.parse(response[i]["lev_date"].toString());
          //     if(utils.returnPadLeft(defaultMonth.toString())==utils.returnPadLeft(st.month.toString())){
          //       count++;
          //     }
          //   }
          //   _thisMonthLeave=count.toString();
          // }
          Set<String> uniqueDates = {};

          for (var i = 0; i < response.length; i++) {
            DateTime dateObject = DateTime.parse(response[i]["lev_date"]);

            // print("➡️ Raw Date from API: ${response[i]["lev_date"]}");
            // print("➡️ Parsed Date: $dateObject");

            // Add appointment
            Appointment app = Appointment(
              startTime: dateObject,
              endTime: dateObject,
              subject: response[i]["reason"],
              color: colorsConst.primary,
            );

            dataSource.appointments!.add(app);
            dataSource.notifyListeners(
              CalendarDataSourceAction.add,
              <Appointment>[app],
            );

            // Month check + unique date logic
            if (utils.returnPadLeft(defaultMonth.toString()) ==
                utils.returnPadLeft(dateObject.month.toString())) {

              String onlyDate = dateObject.toIso8601String().substring(0, 10);

              if (uniqueDates.contains(onlyDate)) {
                // print("⚠️ Duplicate date skipped: $onlyDate");
              } else {
                // print("✅ New date added for count: $onlyDate");
              }

              uniqueDates.add(onlyDate);
            }
          }

          // print("📊 Unique leave dates in this month: $uniqueDates");
          // print("📌 Total Leave Count (This Month): ${uniqueDates.length}");

          _thisMonthLeave = uniqueDates.length.toString();
          // print("📌 _thisMonthLeave: ${_thisMonthLeave}");
        }
        _refresh=true;
        notifyListeners();
        return response.map((json) => HolyDaysModel.fromJson(json)).toList();
      } else {
        total=0;
        _refresh=true;
        dataSource.appointments?.clear();
        fixedLeaves.clear();
        notifyListeners();
        throw Exception('Failed to load album');
      }
    // }catch(e){
    //   total=0;
    //   _refresh=true;
    //   notifyListeners();
    //   throw Exception('Failed to load album');
    // }
  }


  final groupController = GroupButtonController();
  var reportList=["Today","  This Week  ","  This month  ","Other"];

  void customPick({required BuildContext context}){
    DateTime dateTime=DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(2024),
      lastDate: DateTime(3024),
    ).then((value) async {
      dateTime=value!;
      _date1= ("${(dateTime.day.toString().padLeft(2,"0"))}-"
          "${(dateTime.month.toString().padLeft(2,"0"))}-"
          "${(dateTime.year.toString())}");
      _date2= ("${(dateTime.add(const Duration(days: 1)).day.toString().padLeft(2,"0"))}-"
          "${(dateTime.month.toString().padLeft(2,"0"))}-"
          "${(dateTime.year.toString())}");
      notifyListeners();
    });
  }

  List<LeaveModel> myLev= <LeaveModel>[];
  List<LeaveModel> myLev2= <LeaveModel>[];
  List<LeaveModel> myLev3= <LeaveModel>[];
  List<LeaveModel> myLev4= <LeaveModel>[];
  List<LeaveModel> myLevSearch= <LeaveModel>[];
  List<LeaveModel> myLev2Search= <LeaveModel>[];
  List<LeaveModel> myLev3Search= <LeaveModel>[];
  List<LeaveModel> myLev4Search= <LeaveModel>[];
  String _date1="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}";
  String _date2="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}";
  String _showDate3="";
  String _showDate4="";
  String _showDate5="";
  String _showDate6="";
  String _showDate7="";
  String _showDate8="";
  String _d1="";
  String _d2="";
  String get d1=>_d1;
  String get d2=>_d2;
  String get date1=>_date1;
  String get date2=>_date2;
  String get showDate3=>_showDate3;
  String get showDate4=>_showDate4;
  String get showDate5=>_showDate5;
  String get showDate6=>_showDate6;
  String get showDate7=>_showDate7;
  String get showDate8=>_showDate8;
  void getLeaveReport(bool refresh)async{
    _isLoading=false;
    myLev.clear();
    myLevSearch.clear();
    if(localData.storage.read("role")=="1"){
      allLeaves(_startDate,_endDate,_filter);
    }else{
      myLeaves(_startDate,_endDate,_isLoading,localData.storage.read("id"));
    }
  }
  void changeFilter(){
    _filter=true;
    notifyListeners();
  }
  bool _filter=false;
  bool get filter=>_filter;
  void filterList(bool isFilter) {
    _filter = isFilter;
    final dateFormat = DateFormat('dd-MM-yyyy');
    final parsedDate1 = dateFormat.parse(_startDate);
    final parsedDate2 = dateFormat.parse(_endDate);

    myLev = myLevSearch.where((contact) {
      String timestamp = contact.createdTs.toString();
      List<String> times = timestamp.split(',');
      DateTime startTime = DateTime.parse(times[0]);

      DateTime createdTsDate = startTime;
      final createdDateOnly = DateTime(
          createdTsDate.year, createdTsDate.month, createdTsDate.day);

      final isWithinDateRange =
          !createdDateOnly.isBefore(parsedDate1) &&
              !createdDateOnly.isAfter(parsedDate2);

      final isIdMatch = _user == contact.userId;

      // 🔍 Print matching conditions
      if (_user == null || _user == "") {
        if (isWithinDateRange) {
          print("MATCH → Date: $createdDateOnly | User: ${contact.userId}");
        }
        return isWithinDateRange;
      } else {
        if (isWithinDateRange && isIdMatch) {
          print(
              "MATCH → Date: $createdDateOnly | User Match: ${contact.userId}");
        }
        return isWithinDateRange && isIdMatch;
      }
    }).toList();

    notifyListeners();
  }

  dynamic start;
  List<HolyDaysModel> fixedMonthLeaves= <HolyDaysModel>[];
  String totalLeaveDays="0";
  TextEditingController noOfWorkingDay =TextEditingController();
  List<LeaveAttModel> userAttendanceReport = <LeaveAttModel>[];

}
