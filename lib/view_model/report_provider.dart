import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:master_code/model/report/work_report_model.dart';
import 'package:master_code/screens/report_dashboard/report_dashboard.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../component/custom_text.dart';
import '../model/add_document_model.dart';
import '../model/report/add_user_model.dart';
import '../model/user_model.dart';
import '../repo/report_repo.dart';
import '../component/month_calendar.dart';
import '../screens/common/camera.dart';
import '../screens/common/fullscreen_photo.dart';
import '../source/constant/api.dart';
import '../source/constant/assets_constant.dart';
import '../source/constant/colors_constant.dart';
import '../source/constant/default_constant.dart';
import '../source/constant/local_data.dart';
import '../source/utilities/utils.dart';


class ReportProvider with ChangeNotifier{
  final ReportRepository reportRepo = ReportRepository();
  dynamic _user;
  dynamic get user=>_user;
  void selectUser(UserModel value){
    _user=value.id;
    _userName=value.firstname;
    getCReport1(_user);
    getReport3(_user);
    getCReport3(_user);
    notifyListeners();
  }
  dynamic _type;
  dynamic get type =>_type;
  String _startDate = "";
  String get startDate => _startDate;
  String _endDate="";
  String get endDate => _endDate;
  void datePick({required BuildContext context, required String date, required bool isStartDate,required void Function() function}) {
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
         _startDate = formattedDate;
         _endDate = formattedDate;
        function();
        notifyListeners();
      }
    });
  }
  void datePick4({required BuildContext context, required String date, required String id}) {
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
      lastDate: DateTime(3000),
    ).then((value) {
      if (value != null) {
        String formattedDate = "${value.day.toString().padLeft(2, "0")}-"
            "${value.month.toString().padLeft(2, "0")}-"
            "${value.year.toString()}";
        _startDate4 = formattedDate;
        _endDate4 = formattedDate;
        notifyListeners();
        getCustomerTasks(id);
        getCustomerVisits(id);
        getCustomerExpense(id);
      }
    });
  }
  var typeList = ["Today","Yesterday","Last 7 Days","Last 30 Days","This Week","This Month","Last 3 months"];
  void initValue(){
    _user=null;
    _report3.clear();
    _type="Today";
    _type2="Today";
    _type3="Today";
    _type4="Today";
    daily();
    daily2();
    daily3();
    thisWeek4();
    String startDate = DateFormat("dd-MM-yyyy").format(DateTime(DateTime.now().year, DateTime.now().month, 1));
    String endDate = DateFormat("dd-MM-yyyy").format(DateTime(DateTime.now().year, DateTime.now().month + 1, 0));
    _month=DateFormat("MMM yyyy").format(DateTime.now());
    _month2=DateFormat("MMM yyyy").format(DateTime.now());
    _month4=DateFormat("MMM yyyy").format(DateTime.now());
    _monthStart=startDate;
    _monthStart2=startDate;
    _monthStart4=startDate;
    _monthEnd=endDate;
    _monthEnd2=endDate;
    _monthEnd4=endDate;
    notifyListeners();
  }
  void changeType(dynamic value){
    _type = value;
    if(_type=="Today"){
      daily();
    }else if(_type=="Yesterday"){
      yesterday();
    }else if(_type=="Last 7 Days"){
      last7Days();
    }else if(_type=="Last 30 Days"){
      last30Days();
    }else if(_type=="This Week"){
      thisWeek();
    }else if(_type=="This Month"){
      thisMonth();
    }else if(_type=="Last 3 months"){
      last3Month();
    }
    getReport1();
    notifyListeners();
  }
  DateTime stDt = DateTime.now();
  DateTime enDt = DateTime.now().add(const Duration(days: 1));
  void daily() {
    stDt=DateTime.now();
    enDt=DateTime.now().add(const Duration(days: 1));
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(stDt);
    if(localData.storage.read("role")!="1"){
      getCReport1(localData.storage.read("id"));
      getReport3(localData.storage.read("id"));
      getCReport3(localData.storage.read("id"));
    }
    notifyListeners();
  }
  void yesterday() {
    stDt=DateTime.now().subtract(const Duration(days: 1));
    enDt = DateTime.now();
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(stDt);
    if(localData.storage.read("role")!="1"){
      getCReport1(localData.storage.read("id"));
      getReport3(localData.storage.read("id"));
      getCReport3(localData.storage.read("id"));
    }
    notifyListeners();
  }
  void last7Days() {
    DateTime now = DateTime.now();
    DateTime lastWeekStart = now.subtract(const Duration(days: 6));
    DateTime lastWeekEnd = now;
    _startDate = DateFormat('dd-MM-yyyy').format(lastWeekStart);
    _endDate = DateFormat('dd-MM-yyyy').format(lastWeekEnd);
    if(localData.storage.read("role")!="1"){
      getCReport1(localData.storage.read("id"));
      getReport3(localData.storage.read("id"));
      getCReport3(localData.storage.read("id"));
    }
    notifyListeners();
  }
  void last30Days() {
    DateTime now = DateTime.now();
    DateTime lastMonthStart = now.subtract(const Duration(days: 29));
    DateTime lastMonthEnd = now;
    _startDate = DateFormat('dd-MM-yyyy').format(lastMonthStart);
    _endDate = DateFormat('dd-MM-yyyy').format(lastMonthEnd);
    if(localData.storage.read("role")!="1"){
      getCReport1(localData.storage.read("id"));
      getReport3(localData.storage.read("id"));
      getCReport3(localData.storage.read("id"));
    }
    notifyListeners();
  }
  void thisWeek() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;
    DateTime stDt = now.subtract(Duration(days: currentWeekday - 1));
    DateTime enDt = now.add(Duration(days: 7 - currentWeekday));
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    if(localData.storage.read("role")!="1"){
      getCReport1(localData.storage.read("id"));
      getReport3(localData.storage.read("id"));
      getCReport3(localData.storage.read("id"));
    }
    notifyListeners();
  }
  void thisMonth() {
    DateTime now = DateTime.now();
    stDt = DateTime(now.year, now.month, 1);
    enDt = now; // Today’s date
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    _month=DateFormat("MMM yyyy").format(stDt);
    if(localData.storage.read("role")!="1"){
      getCReport1(localData.storage.read("id"));
      getReport3(localData.storage.read("id"));
      getCReport3(localData.storage.read("id"));
    }
    notifyListeners();
  }
  void last3Month() {
    DateTime now = DateTime.now();
    DateTime stDt = DateTime(now.year, now.month - 2, now.day);
    DateTime enDt = now;

    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    if(localData.storage.read("role")!="1"){
      getCReport1(localData.storage.read("id"));
      getReport3(localData.storage.read("id"));
      getCReport3(localData.storage.read("id"));
    }
    notifyListeners();
  }
  void lastMonth() {
    DateTime now = DateTime.now();
    stDt = DateTime(now.year, now.month, 1);
    enDt = DateTime(now.year, now.month + 1, 0);
    stDt = DateTime(stDt.year, stDt.month - 1, 1);
    enDt = DateTime(enDt.year, enDt.month - 1, 1);
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(DateTime(enDt.year, enDt.month + 1, 0));
    if(localData.storage.read("role")!="1"){
      getCReport1(localData.storage.read("id"));
      getReport3(localData.storage.read("id"));
      getCReport3(localData.storage.read("id"));
    }
    notifyListeners();
  }
  String _monthStart= "";
  String get monthStart => _monthStart;
  String _monthEnd="";
  String get monthEnd => _monthEnd;
  String _month="";
  String get month => _month;
  void showCustomMonthPicker({
    required BuildContext context,
    required void Function() function,
  }) {
    // If _month already has a value like "Nov 2025", parse it
    DateTime now = DateTime.now();
    DateTime initialDate;

    try {
      initialDate = _month.isNotEmpty
          ? DateFormat("MMM yyyy").parse(_month)
          : now;
    } catch (e) {
      initialDate = now;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: SizedBox(
            width: 300,
            height: 400,
            child: CustomMonthPicker(
              initialMonth: initialDate.month,
              initialYear: initialDate.year,
              firstYear: 2024,
              lastYear: DateTime.now().year,
              // onSelected: onSelected,
              onSelected: (value) {
                int selectedMonth = value.month;
                int selectedYear = value.year;
                String startDate = DateFormat("dd-MM-yyyy").format(DateTime(selectedYear, selectedMonth, 1));
                String endDate = DateFormat("dd-MM-yyyy").format(DateTime(selectedYear, selectedMonth + 1, 0));
                _month=DateFormat("MMM yyyy").format(value);
                _startDate=startDate;
                _endDate=endDate;
                function();
                notifyListeners();
              },
            ),
          ),
        );
      },
    );
  }
  /// REPORT 1
  List _report1 = [];
  List get report1 => _report1;
  bool _refresh1=true;
  bool get refresh1 =>_refresh1;
  Future<void> getReport1() async {
    try {
      _report1=[];
      _refresh1=false;
      Map data = {
        "action": getAllData,
        "search_type":"report_1",
        "cos_id":localData.storage.read("cos_id"),
        "role":localData.storage.read("role"),
        "id":localData.storage.read("id"),
        "date1":_startDate,
        "date2":_endDate,
      };
      final response = await reportRepo.getReport(data);
      if(response.isNotEmpty){
        _report1=response;
        _refresh1=true;
      }
      else{
        _report1=[];
        _refresh1=true;
      }
    } catch (e) {
      _report1=[];
      _refresh1=true;
      // _roleValues.clear();
    }
    notifyListeners();
  }


  /// REPORT 2
  dynamic _type2;
  dynamic get type2 =>_type2;
  String _startDate2 = "";
  String get startDate2 => _startDate2;
  String _endDate2="";
  String get endDate2 => _endDate2;
  void datePick2({required BuildContext context}) {
    DateTime dateTime = DateTime.now();

    showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(1920),
      lastDate: DateTime(3000),
    ).then((value) {
      if (value != null) {
        String formattedDate = "${value.day.toString().padLeft(2, "0")}-"
            "${value.month.toString().padLeft(2, "0")}-"
            "${value.year.toString()}";

          _startDate2 = formattedDate;
          _endDate2 = formattedDate;
        getReport2();
        notifyListeners();
      }
    });
  }
  var typeList2 = ["Today","Yesterday","Last 7 Days","Last 30 Days","This Week","This Month","Last 3 months"];
  void changeType2(dynamic value){
    _type2 = value;
    if(_type2=="Today"){
      daily2();
    }else if(_type2=="Yesterday"){
      yesterday2();
    }else if(_type2=="Last 7 Days"){
      last7Days2();
    }else if(_type2=="Last 30 Days"){
      last30Days2();
    }else if(_type2=="This Week"){
      thisWeek2();
    }else if(_type2=="This Month"){
      thisMonth2();
    }else if(_type2=="Last 3 months"){
      last3Month2();
    }
    getReport2();
    notifyListeners();
  }
  DateTime stDt2 = DateTime.now();
  DateTime enDt2 = DateTime.now().add(const Duration(days: 1));
  void daily2() {
    stDt2=DateTime.now();
    enDt2=DateTime.now().add(const Duration(days: 1));
    _startDate2 = DateFormat('dd-MM-yyyy').format(stDt2);
    _endDate2 = DateFormat('dd-MM-yyyy').format(stDt2);
    notifyListeners();
  }
  void yesterday2() {
    stDt2=DateTime.now().subtract(const Duration(days: 1));
    enDt2 = DateTime.now();
    _startDate2 = DateFormat('dd-MM-yyyy').format(stDt2);
    _endDate2 = DateFormat('dd-MM-yyyy').format(stDt2);
    notifyListeners();
  }
  void last7Days2() {
    DateTime now = DateTime.now();
    DateTime lastWeekStart = now.subtract(const Duration(days: 6));
    DateTime lastWeekEnd = now;
    _startDate2 = DateFormat('dd-MM-yyyy').format(lastWeekStart);
    _endDate2 = DateFormat('dd-MM-yyyy').format(lastWeekEnd);
    notifyListeners();
  }
  void last30Days2() {
    DateTime now = DateTime.now();
    DateTime lastMonthStart = now.subtract(const Duration(days: 30));
    DateTime lastMonthEnd = now;
    _startDate2 = DateFormat('dd-MM-yyyy').format(lastMonthStart);
    _endDate2 = DateFormat('dd-MM-yyyy').format(lastMonthEnd);
    notifyListeners();
  }
  void thisWeek2() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;
    DateTime stDt = now.subtract(Duration(days: currentWeekday - 1));
    DateTime enDt = now.add(Duration(days: 7 - currentWeekday));
    _startDate2 = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate2 = DateFormat('dd-MM-yyyy').format(enDt);
    notifyListeners();
  }
  void thisMonth2() {
    DateTime now = DateTime.now();
    stDt2 = DateTime(now.year, now.month, 1);
    enDt2 = DateTime(now.year, now.month + 1, 0);
    _startDate2 = DateFormat('dd-MM-yyyy').format(stDt2);
    _endDate2 = DateFormat('dd-MM-yyyy').format(enDt2);
    _month2=DateFormat("MMM yyyy").format(stDt2);
    notifyListeners();
  }
  void last3Month2() {
    DateTime now = DateTime.now();
    DateTime stDt = DateTime(now.year, now.month - 3, 1);
    DateTime enDt = DateTime(now.year, now.month, 0);
    _startDate2 = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate2 = DateFormat('dd-MM-yyyy').format(enDt);
    notifyListeners();
  }
  void lastMonth2() {
    DateTime now = DateTime.now();
    stDt2 = DateTime(now.year, now.month, 1);
    enDt2 = DateTime(now.year, now.month + 1, 0);
    stDt2 = DateTime(stDt2.year, stDt2.month - 1, 1);
    enDt2 = DateTime(enDt2.year, enDt2.month - 1, 1);
    _startDate2 = DateFormat('dd-MM-yyyy').format(stDt2);
    _endDate2 = DateFormat('dd-MM-yyyy').format(DateTime(enDt2.year, enDt2.month + 1, 0));
    notifyListeners();
  }
  String _monthStart2= "";
  String get monthStart2 => _monthStart2;
  String _monthEnd2="";
  String get monthEnd2 => _monthEnd2;
  String _month2="";
  String get month2 => _month2;

  List _report2 = [];
  List get report2 => _report2;
  bool _refresh2=true;
  bool get refresh2 =>_refresh2;
  Future<void> getReport2() async {
    try {
      _report2=[];
      _refresh2=false;
      Map data = {
        "action": getAllData,
        "search_type":"report_3",
        "cos_id":localData.storage.read("cos_id"),
        "role":localData.storage.read("role"),
        "id":localData.storage.read("id"),
        "date1":_startDate2,
        "date2":_endDate2,
      };
      final response = await reportRepo.getReport(data);
      // print("nvfff ${data}");
      if(response.isNotEmpty){
        _report2=response;
        _refresh2=true;
      }
      else{
        _report2=[];
        _refresh2=true;
      }
    } catch (e) {
      _report2=[];
      _refresh2=true;
    }
    notifyListeners();
  }
  /// REPORT 4
  dynamic _type4;
  dynamic get type4 =>_type4;
  String _startDate4 = "";
  String get startDate4 => _startDate4;
  String _endDate4="";
  String get endDate4 => _endDate4;
  var typeList4 = ["Today","Yesterday","Last 7 Days","Last 30 Days","This Week","This Month","Last 3 months"];
  void changeType4(dynamic value,String id){
    _type4 = value;
    if(_type4=="Today"){
      daily4();
    }else if(_type4=="Yesterday"){
      yesterday4();
    }else if(_type4=="Last 7 Days"){
      last7Days4();
    }else if(_type4=="Last 30 Days"){
      last30Days4();
    }else if(_type4=="This Week"){
      thisWeek4();
    }else if(_type4=="This Month"){
      thisMonth4();
    }else if(_type4=="Last 3 months"){
      last3Month4();
    }
    getCustomerTasks(id);
    getCustomerVisits(id);
    getCustomerExpense(id);
    notifyListeners();
  }
  DateTime stDt4 = DateTime.now();
  DateTime enDt4 = DateTime.now().add(const Duration(days: 1));
  void daily4() {
    stDt4=DateTime.now();
    enDt4=DateTime.now().add(const Duration(days: 1));
    _startDate4 = DateFormat('dd-MM-yyyy').format(stDt4);
    _endDate4 = DateFormat('dd-MM-yyyy').format(stDt4);
    notifyListeners();
  }
  void yesterday4() {
    stDt4=DateTime.now().subtract(const Duration(days: 1));
    enDt4 = DateTime.now();
    _startDate4 = DateFormat('dd-MM-yyyy').format(stDt4);
    _endDate4 = DateFormat('dd-MM-yyyy').format(stDt4);
    notifyListeners();
  }
  void last7Days4() {
    DateTime now = DateTime.now();
    DateTime lastWeekStart = now.subtract(const Duration(days: 6));
    DateTime lastWeekEnd = now;
    _startDate4 = DateFormat('dd-MM-yyyy').format(lastWeekStart);
    _endDate4 = DateFormat('dd-MM-yyyy').format(lastWeekEnd);
    notifyListeners();
  }
  void last30Days4() {
    DateTime now = DateTime.now();
    DateTime lastMonthStart = now.subtract(const Duration(days: 30));
    DateTime lastMonthEnd = now;
    _startDate4 = DateFormat('dd-MM-yyyy').format(lastMonthStart);
    _endDate4 = DateFormat('dd-MM-yyyy').format(lastMonthEnd);
    notifyListeners();
  }
  void thisWeek4() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;
    DateTime stDt = now.subtract(Duration(days: currentWeekday - 1));
    DateTime enDt = now.add(Duration(days: 7 - currentWeekday));
    _startDate4 = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate4 = DateFormat('dd-MM-yyyy').format(enDt);
    notifyListeners();
  }
  void thisMonth4() {
    DateTime now = DateTime.now();
    stDt4 = DateTime(now.year, now.month, 1);
    enDt4 = now; // Today’s date
    _startDate4 = DateFormat('dd-MM-yyyy').format(stDt4);
    _endDate4 = DateFormat('dd-MM-yyyy').format(enDt4);
    _month4=DateFormat("MMM yyyy").format(stDt4);
    notifyListeners();
  }
  void last3Month4() {
    DateTime now = DateTime.now();
    DateTime stDt = DateTime(now.year, now.month - 3, 1);
    DateTime enDt = DateTime(now.year, now.month, 0);
    _startDate4 = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate4 = DateFormat('dd-MM-yyyy').format(enDt);
    notifyListeners();
  }
  void lastMonth4() {
    DateTime now = DateTime.now();
    stDt4 = DateTime(now.year, now.month, 1);
    enDt4 = DateTime(now.year, now.month + 1, 0);
    stDt4 = DateTime(stDt4.year, stDt4.month - 1, 1);
    enDt4 = DateTime(enDt4.year, enDt4.month - 1, 1);
    _startDate4 = DateFormat('dd-MM-yyyy').format(stDt4);
    _endDate4 = DateFormat('dd-MM-yyyy').format(DateTime(enDt4.year, enDt4.month + 1, 0));
    notifyListeners();
  }
  String _monthStart4= "";
  String get monthStart4 => _monthStart4;
  String _monthEnd4="";
  String get monthEnd4 => _monthEnd4;
  String _month4="";
  String get month4 => _month4;
  void showCustomMonthPicker4({
    required BuildContext context,
    required void Function() function,
  }) {
    // If _month already has a value like "Nov 2025", parse it
    DateTime now = DateTime.now();
    DateTime initialDate;

    try {
      initialDate = _month4.isNotEmpty
          ? DateFormat("MMM yyyy").parse(_month4)
          : now;
    } catch (e) {
      initialDate = now;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: SizedBox(
            width: 300,
            height: 400,
            child: CustomMonthPicker(
              initialMonth: initialDate.month,
              initialYear: initialDate.year,
              firstYear: 2024,
              lastYear: DateTime.now().year,
              // onSelected: onSelected,
              onSelected: (value) {
                int selectedMonth = value.month;
                int selectedYear = value.year;
                String startDate = DateFormat("dd-MM-yyyy").format(DateTime(selectedYear, selectedMonth, 1));
                String endDate = DateFormat("dd-MM-yyyy").format(DateTime(selectedYear, selectedMonth + 1, 0));
                _month4=DateFormat("MMM yyyy").format(value);
                _startDate4=startDate;
                _endDate4=endDate;
                function();
                notifyListeners();
              },
            ),
          ),
        );
      },
    );
  }
  List _report4 = [];
  List<FlSpot> _flSpot = [];
  List<String> _flText = [];
  List get report4 => _report4;
  List<FlSpot> get flSpot => _flSpot;
  List<String> get flText => _flText;
  bool _refresh4=true;
  bool get refresh4 =>_refresh4;
  Future<void> getReport4() async {
    try {
      _report4=[];
      _refresh4=false;
      Map data = {
        "action": getAllData,
        "search_type":"report_4",
        "cos_id":localData.storage.read("cos_id"),
        "role":localData.storage.read("role"),
        "id":localData.storage.read("id"),
        "date1":_startDate4,
        "date2":_endDate4,
      };
      final response = await reportRepo.getReport(data);
      if(response.isNotEmpty){
        _report4=response;
        for(var i=0;i<response.length;i++){
          DateTime dates = DateFormat('yyyy-MM-dd').parse(_report4[i]["created_date"]);
          String formatted = DateFormat('dd/MM - EEE').format(dates);
          _flSpot.add(FlSpot(i.toDouble(), double.parse(_report4[i]["user_count"])));
          _flText.add(formatted);
        }
        _refresh4=true;
      }
      else{
        _report4=[];
        _refresh4=true;
      }
    } catch (e) {
      _report4=[];
      _refresh4=true;
    }
    notifyListeners();
  }
  /// REPORT 3
  dynamic _type3;
  dynamic get type3 =>_type3;
  String _startDate3 = "";
  String get startDate3 => _startDate3;
  String _endDate3="";
  String get endDate3 => _endDate3;
  var typeList3 = ["Today","Yesterday","Last 7 Days","Last 30 Days","This Week","This Month","Last 3 months"];
  void changeType3(dynamic value){
    _type3 = value;
    if(_type3=="Today"){
      daily3();
    }else if(_type3=="Yesterday"){
      yesterday3();
    }else if(_type3=="Last 7 Days"){
      last7Days3();
    }else if(_type3=="Last 30 Days"){
      last30Days3();
    }else if(_type3=="This Week"){
      thisWeek3();
    }else if(_type3=="This Month"){
      thisMonth3();
    }else if(_type3=="Last 3 months"){
      last3Month3();
    }
    getReport3(localData.storage.read("role")=="1"?_user:localData.storage.read("id"));
    notifyListeners();
  }
  DateTime stDt3 = DateTime.now();
  DateTime enDt3 = DateTime.now().add(const Duration(days: 1));
  void daily3() {
    stDt3=DateTime.now();
    enDt3=DateTime.now().add(const Duration(days: 1));
    _startDate3 = DateFormat('dd-MM-yyyy').format(stDt3);
    _endDate3 = DateFormat('dd-MM-yyyy').format(stDt3);
    notifyListeners();
  }
  void yesterday3() {
    stDt3=DateTime.now().subtract(const Duration(days: 1));
    enDt3 = DateTime.now();
    _startDate3 = DateFormat('dd-MM-yyyy').format(stDt3);
    _endDate3 = DateFormat('dd-MM-yyyy').format(stDt3);
    notifyListeners();
  }
  void last7Days3() {
    DateTime now = DateTime.now();
    DateTime lastWeekStart = now.subtract(const Duration(days: 6));
    DateTime lastWeekEnd = now;
    _startDate3 = DateFormat('dd-MM-yyyy').format(lastWeekStart);
    _endDate3 = DateFormat('dd-MM-yyyy').format(lastWeekEnd);
    notifyListeners();
  }
  void last30Days3() {
    DateTime now = DateTime.now();
    DateTime lastMonthStart = now.subtract(const Duration(days: 29));
    DateTime lastMonthEnd = now;
    _startDate3 = DateFormat('dd-MM-yyyy').format(lastMonthStart);
    _endDate3 = DateFormat('dd-MM-yyyy').format(lastMonthEnd);
    notifyListeners();
  }
  void thisWeek3() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;
    DateTime stDt = now.subtract(Duration(days: currentWeekday - 1));
    DateTime enDt = now.add(Duration(days: 7 - currentWeekday));
    _startDate3 = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate3 = DateFormat('dd-MM-yyyy').format(enDt);
    notifyListeners();
  }
  void thisMonth3() {
    DateTime now = DateTime.now();
    stDt3 = DateTime(now.year, now.month, 1);
    enDt3 = DateTime(now.year, now.month + 1, 0);
    _startDate3 = DateFormat('dd-MM-yyyy').format(stDt3);
    _endDate3 = DateFormat('dd-MM-yyyy').format(enDt3);
    notifyListeners();
  }
  void last3Month3() {
    DateTime now = DateTime.now();
    DateTime stDt = DateTime(now.year, now.month - 2, now.day);
    DateTime enDt = now;

    _startDate3 = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate3 = DateFormat('dd-MM-yyyy').format(enDt);
    notifyListeners();
  }
  void lastMonth3() {
    DateTime now = DateTime.now();
    stDt3 = DateTime(now.year, now.month, 1);
    enDt3 = DateTime(now.year, now.month + 1, 0);
    stDt3 = DateTime(stDt3.year, stDt3.month - 1, 1);
    enDt3 = DateTime(enDt3.year, enDt3.month - 1, 1);
    _startDate3 = DateFormat('dd-MM-yyyy').format(stDt3);
    _endDate3 = DateFormat('dd-MM-yyyy').format(DateTime(enDt3.year, enDt3.month + 1, 0));
    notifyListeners();
  }

  List<MonthReport> _report3 = [];
  List<MonthReport> get report3 => _report3;
  bool _refresh3=true;
  bool get refresh3 =>_refresh3;
  List<MonthReport> _visitReport = [];
  List<MonthReport> get visitReport => _visitReport;
  Future<void> getReport3(String id) async {
    try {
      _visitReport=[];
      _reportRefresh=false;
      notifyListeners();
      Map data = {
        "action": taskDatas,
        "search_type":"emp_visits",
        "cos_id":localData.storage.read("cos_id"),
        "id":localData.storage.read("role")=="1"?id:localData.storage.read("id"),
        "role":localData.storage.read("role"),
        "date1":_startDate,
        "date2":_endDate,
      };
      final response = await reportRepo.getChartReport(data);
      if(response.isNotEmpty){
        _visitReport=response;
        _reportRefresh=true;
      }
      else{
        _visitReport=[];
        _reportRefresh=true;
      }
    } catch (e) {
      _visitReport=[];
      _reportRefresh=true;
    }
    notifyListeners();
  }
  String formatDate(String date) {
    DateTime dates = DateFormat('yyyy-MM-dd').parse(date);
    String formatted = DateFormat('dd/MM - EEE').format(dates);
    return formatted;
  }
  // String formatDate(String date) {
  //   List<String> parts = date.split('-');
  //   String year = parts[0];
  //   String month = parts[1];
  //   String day = parts[2];
  //
  //   // Remove leading zero from the day part if present
  //   if (day.startsWith('0')) {
  //     day = day.substring(1);
  //   }
  //
  //   return '$year-$month-$day';
  // }
  Widget getTitles(double value, TitleMeta meta,) {
    final style = TextStyle(
      color: colorsConst.primary.withOpacity(0.6),
      fontSize: 12,
    );
    int index = value.toInt();

    String formattedDate ="";
    if(_type3=="Last 30 Days"||_type3=="This Month"||_type3=="Last 3 months"){
      DateTime parsedDate = DateTime.parse(_report3[index].date.toString()); // parses "2025-04-15"
      formattedDate = DateFormat('dd-MMM\nyy').format(parsedDate);
    }else{
      formattedDate = DateFormat('dd/MM - EEE').format(DateFormat('yyyy-MM-dd').parse(_report3[index].date!)).split('-').last;
    }

    String text = index >= 0 && index <_report3.length ? formattedDate: '';
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 2,
      child: Text(text, style: style),
    );
  }
  Widget empGetTitles(double value, TitleMeta meta,) {
    final style = TextStyle(
      color: colorsConst.primary.withOpacity(0.6),
      fontSize: 12,
    );
    int index = value.toInt();

    String formattedDate ="";
    if(_type3=="Last 30 Days"||_type3=="This Month"||_type3=="Last 3 months"){
      DateTime parsedDate = DateTime.parse(_visitReport[index].date.toString()); // parses "2025-04-15"
      formattedDate = DateFormat('dd-MMM\nyy').format(parsedDate);
    }else{
      formattedDate = DateFormat('dd/MM - EEE').format(DateFormat('yyyy-MM-dd').parse(_visitReport[index].date!)).split('-').last;
    }

    String text = index >= 0 && index <_visitReport.length ? formattedDate: '';
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 2,
      child: Text(text, style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        getTitlesWidget: getTitles,
      ),
    ),
    leftTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    topTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    rightTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
  );
  FlTitlesData get empTitlesData => FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        getTitlesWidget: empGetTitles,
      ),
    ),
    leftTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    topTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    rightTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
  );

  FlBorderData get borderData => FlBorderData(
    show: false,
  );

  LinearGradient get _barsGradient => LinearGradient(
    colors: [
      colorsConst.blueClr,
      colorsConst.appRed,
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  List<BarChartGroupData> get barGroups => _report3.asMap().entries.map((entry) {
    int index = entry.key;
    double y = double.parse(entry.value.totalAttendance.toString());
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: _barsGradient,
          borderRadius: BorderRadius.circular(2),
        )
      ],
      showingTooltipIndicators: [0],
    );
  }).toList();
  List<BarChartGroupData> get empBarGroups => _visitReport.asMap().entries.map((entry) {
    int index = entry.key;
    double y = double.parse(entry.value.totalAttendance.toString());
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: _barsGradient,
          borderRadius: BorderRadius.circular(2),
        )
      ],
      showingTooltipIndicators: [0],
    );
  }).toList();

  LineChartBarData lineChartBarData() {
    List<FlSpot> spots = [];
    for(var i=0;i<_report4.length;i++){
      spots.add(FlSpot(double.parse((i).toString()), double.parse(_report4[i]["user_count"])));
    }
    return LineChartBarData(
      spots: spots,
      isCurved: false,
      color: Colors.blue,
      dotData: const FlDotData(show: true), // Enable dots
      belowBarData: BarAreaData(show: false),
      barWidth: 3,
    );
  }

  // X-Axis (Days of the Week)
  SideTitles bottomTitles() {
    List spots = [];
    for(var i=0;i<_report4.length;i++){
      spots.add(_report4[i]["created_date"]);
    }
    return SideTitles(
      showTitles: true,
      getTitlesWidget: (value, meta) {
        var days = spots;
        return Text(days[value.toInt()], style: const TextStyle(fontSize: 12));
      },
      interval: 1,
    );
  }

  // Y-Axis Labels
  SideTitles sideTitles() {
    return SideTitles(
      showTitles: true,
      interval: 25,
      getTitlesWidget: (value, meta) {
        return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
      },
    );
  }



 /// WORK REPORT
  bool _dataRefresh=false;
  String _selectName="";
  int _listIndex = 0;
  dynamic _projectName;
  dynamic _userName;
  dynamic _addName;
  dynamic _empName;
  String get selectName => _selectName;
  int get listIndex => _listIndex;
  bool get dataRefresh => _dataRefresh;
  dynamic get projectName => _projectName;
  dynamic get userName => _userName;
  dynamic get addName => _addName;
  dynamic get empName => _empName;
  List<ReportModel> _addedReport = <ReportModel>[];
  List<ReportModel> get addedReport => _addedReport;
  List<AddUserModel> _addWorker = <AddUserModel>[];
  List<AddUserModel> get addWorker => _addWorker;
  final TextEditingController date=TextEditingController();
  final TextEditingController planWork=TextEditingController();
  final TextEditingController finishedWork=TextEditingController();
  final TextEditingController pendingWork=TextEditingController();
  final TextEditingController comment=TextEditingController();
  final TextEditingController search=TextEditingController();
  final RoundedLoadingButtonController addCtr=RoundedLoadingButtonController();
  void clearValues(){
    _selectName= "";
    _addName = null;
    notifyListeners();
  }
  String _projectId="";
  String _engineerId="";
   void changeProject(dynamic value){
     var list = value.toString().split(',');
     _projectName = value;
    _projectId = list[0];
    notifyListeners();
  }
  void changeEmpName(dynamic value){
    var list = value.toString().split(',');
    _userName = value;
    _engineerId = list[0];
    notifyListeners();
  }

  void addWrkEmps(dynamic value,int index){
    var list = value.toString().split(',');
    _empName = value;
    _addWorker[index].name.text = list[1];
    notifyListeners();
  }
  void removeWrkEmps(int index){
    _addWorker.removeAt(index);
    notifyListeners();
  }
  void setIndex(int index){
    _listIndex=index;
    _selectName ="";
    _addName = null;
    notifyListeners();
  }
  void initWrkReport(){
    search.clear();
    date.text="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}";
    _userName = null;
    _empName = null;
    _engineerId="";
    _projectName =null;
    _projectId="";
    _addName=null;
    planWork.clear();
    finishedWork.clear();
    pendingWork.clear();
    addWorker.clear();
    addWorker.add(AddUserModel(
        inCtr: TextEditingController(), outCtr: TextEditingController(),
        name: TextEditingController(),id: TextEditingController()));
    notifyListeners();
  }
  void addUsers(int index){
    _listIndex =index + 1;
    _selectName = "";
    _addName = null;
    _addWorker.add(
        AddUserModel(
            inCtr: TextEditingController(
                text:_addWorker[index].inCtr.text),
            outCtr: TextEditingController(
                text:_addWorker[index].outCtr.text),
            name: TextEditingController(),
            id: TextEditingController()));
    notifyListeners();
  }


  void timePick(BuildContext context, {required TextEditingController timeController}) {
    TimeOfDay now = TimeOfDay.now();

    showTimePicker(
      context: context,
      initialTime: now,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false), // for 12-hour format
          child: child ?? const SizedBox(),
        );
      },
    ).then((pickedTime) {
      if (pickedTime != null) {
        String formattedTime = "${pickedTime.hourOfPeriod.toString().padLeft(2, '0')}:"
            "${pickedTime.minute.toString().padLeft(2, '0')} "
            "${pickedTime.period == DayPeriod.am ? 'AM' : 'PM'}";

        timeController.text = formattedTime;
        notifyListeners();
      }
    });
  }


  Future<void> getWorkReport() async {
    try {
      _addedReport=[];
      _dataRefresh=false;
      notifyListeners();
      Map data = {
        "action":getProjectData,
        "search_type":"all_work_report",
        "cos_id":localData.storage.read("cos_id"),
        "id":localData.storage.read("id"),
        "role":localData.storage.read("role"),
      };
      final response = await reportRepo.getAddReport(data);
      if(response.isNotEmpty){
        _addedReport=response;
        _dataRefresh=true;
      }
      else{
        _addedReport=[];
        _dataRefresh=true;
      }
    } catch (e) {
      _addedReport=[];
      _dataRefresh=true;
    }
    notifyListeners();
  }
  Future<void> insertWorkReport(context) async {
    try{
      List<Map<String, String>> workersList = [];
      for (int i = 0; i < _addWorker.length; i++) {
        workersList.add({
          "id": _addWorker[i].id.text.isEmpty?"0":_addWorker[i].id.text,
          "name": _addWorker[i].name.text,
          "in_time": _addWorker[i].inCtr.text,
          "out_time": _addWorker[i].outCtr.text,
        });
      }
      String jsonString = json.encode(workersList);
      Map<String, String> requestData = {
        "action":addWrkReport,
        "project_id": _projectId,
        "engineer_id": _engineerId,
        "data": jsonString,
        "log_file":localData.storage.read("mobile_number"),
        "platform":localData.storage.read("platform").toString(),
        "created_by":localData.storage.read("id"),
        "cos_id":localData.storage.read("cos_id"),
        "date":date.text.trim(),
        "plan_work":planWork.text.trim(),
        "finished_work":finishedWork.text.trim(),
        "pending_work":pendingWork.text.trim(),
      };

      final response = await reportRepo.insertWorkReport(requestData);
      if(response.isNotEmpty){
        if (response.toString().contains("ok")) {
          utils.showSuccessToast(context: context, text: constValue.success);
          addCtr.reset();
          getWorkReport();
          Future.microtask(() => Navigator.pop(context));
          notifyListeners();
        } else {
          addCtr.reset();
          utils.showErrorToast(context: context);
        }
      }else {
        addCtr.reset();
        utils.showErrorToast(context: context);
      }
    }catch(e){
      addCtr.reset();
      utils.showErrorToast(context: context);
    }
  }
/// PROJECT REPORT

  final TextEditingController addDate=TextEditingController(text: "${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}");
  final TextEditingController prjDate1=TextEditingController();
  final TextEditingController prjDate2=TextEditingController();

  List<ReportModel> _projectReport = <ReportModel>[];
  List<ReportModel> _searchProjectReport = <ReportModel>[];
  List<ReportModel> get projectReport  => _projectReport;
  List<ReportModel> get searchProjectReport  => _searchProjectReport;
  List<AddDocumentModel> _addDocuments = <AddDocumentModel>[];
  List<AddDocumentModel> get addDocuments => _addDocuments;

  void searchPrjReport(dynamic value){
  final suggestions = _projectReport.where(
          (user) {
        final userName = user.fName.toString().toLowerCase();
        final city = user.projectName.toString().toLowerCase();
        final input = value.toString().toLowerCase().trim();
        return userName.contains(input) ||city.contains(input);
      }).toList();
    _searchProjectReport = suggestions;
    notifyListeners();
  }
  Future<void> getProjectReport() async {
    try {
      _projectReport=[];
      _searchProjectReport=[];
      search.clear();
      _dataRefresh=false;
      notifyListeners();
      Map data = {
        "action":getProjectData,
        "search_type":"all_project_report",
        "cos_id":localData.storage.read("cos_id"),
        "id":localData.storage.read("id"),
        "role":localData.storage.read("role"),
        // "st_dt": prjDate1.text,
        // "en_dt": prjDate2.text
      };
      final response = await reportRepo.getAddReport(data);
      if(response.isNotEmpty){
        _searchProjectReport=response;
        _projectReport=response;
        _dataRefresh=true;
      }
      else{
        _projectReport=[];
        _searchProjectReport=[];
        _dataRefresh=true;
      }
    } catch (e) {
      _projectReport=[];
      _searchProjectReport=[];
      _dataRefresh=true;
    }
    notifyListeners();
  }
  Future<void> insertProjectReport(context) async {
    try{
      List<Map<String, String>> documentList = [];
      for (int i = 0; i < addDocuments.length; i++) {
        documentList.add({
          "document_name": "",
          "image_$i": addDocuments[i].imagePath,
        });
      }
      String jsonString = json.encode(documentList);
      Map<String, String> requestData = {
        "action": addProjectReport,
        "project_id": _projectId,
        "data": jsonString,
        "log_file":localData.storage.read("mobile_number"),
        "platform":localData.storage.read("platform").toString(),
        "usr_id":localData.storage.read("id"),
        "created_by":localData.storage.read("id"),
        "cos_id":localData.storage.read("cos_id"),
        "date":addDate.text,
        "comment":comment.text.trim(),
      };

      final response = await reportRepo.insertProjectReport(documentList,requestData);
      if(response.isNotEmpty){
        if (response.toString().contains("ok")) {
          utils.showSuccessToast(context: context, text: constValue.success);
          addCtr.reset();
          getProjectReport();
          Future.microtask(() => Navigator.pop(context));
          notifyListeners();
        } else {
          addCtr.reset();
          utils.showErrorToast(context: context);
        }
      }else {
        addCtr.reset();
        utils.showErrorToast(context: context);
      }
    }catch(e){
      addCtr.reset();
      utils.showErrorToast(context: context);
    }
  }
  void initProjReport(){
    _projectName =null;
    _projectId="";
    _addDocuments.clear();
    comment.clear();
    _addDocuments.add(AddDocumentModel(imagePath: ''));
    notifyListeners();
  }
  void removeDocument(int index){
    _addDocuments.removeAt(index);
    notifyListeners();
  }
  void addDocument(){
    _addDocuments.add(
        AddDocumentModel(imagePath: ''));
    notifyListeners();
  }
  void signDialog(context,{required int index}){
    showDialog(context: context,
        builder: (context){
          return AlertDialog(
              title: const Center(
                child: Column(
                  children: [
                    CustomText(text: "Pick Document From",colors: Colors.black,size: 15,isBold: true,),
                  ],
                ),
              ),
              content: SizedBox(
                height: 120,
                width: 300,
                // color: Colors.red,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if(!kIsWeb)
                          GestureDetector(
                            onTap: ()async{
                              var imgData = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const CameraWidget(cameraPosition: CameraType.front),
                                ),
                              );
                              if (!context.mounted) return;
                              _addDocuments[index].imagePath = imgData;
                              Navigator.pop(context);
                              notifyListeners();
                            },
                            child: Column(
                              children: [
                                SvgPicture.asset(assets.cam),
                                5.height,
                                const CustomText(text: "Camera",colors: Colors.grey,isBold: true),
                              ],
                            ),
                          ),
                        GestureDetector(
                          onTap: () async {
                            if(!kIsWeb){
                              FilePickerResult? result = await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['png','jpeg','jpg'],
                              );
                              if (result != null){
                                _addDocuments[index].imagePath = result.files.single.path!;
                              }
                            }
                            notifyListeners();
                            Navigator.pop(context);
                          },
                          child: Column(
                            children: [
                              SvgPicture.asset(assets.gallery),
                              5.height,
                              const CustomText(text: "Gallery",colors: Colors.grey,isBold: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if(_addDocuments[index].imagePath !="")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              _addDocuments[index].imagePath="";
                              notifyListeners();
                              Navigator.pop(context);
                            },
                            child:CustomText(text: "Remove",colors: colorsConst.primary,size: 15,isBold: true),
                          ),
                          TextButton(onPressed: () {
                            Navigator.of(context).pop();
                            utils.navigatePage(context, ()=>FullScreen(image:_addDocuments[index].imagePath, isNetwork: false));
                          },
                            child:CustomText(text: "Full View",colors: colorsConst.primary,size: 15,isBold: true),
                          ),
                        ],
                      ),
                  ],
                ),
              )
          );
        }
    );
  }
  List _customerTasks = [];
  List get customerTasks => _customerTasks;

  List _taskReport = [];
  List get taskReport => _taskReport;
  bool _reportRefresh=true;
  bool get reportRefresh =>_reportRefresh;
  Future<void> getCReport1(String id) async {
    try {
      _taskReport=[];
      _reportRefresh=false;
      notifyListeners();
      Map data = {
        "action": taskDatas,
        "search_type":"emp_tasks",
        "cos_id":localData.storage.read("cos_id"),
        "role":localData.storage.read("role"),
        "id":localData.storage.read("role")=="1"?id:localData.storage.read("id"),
        "date1":_startDate,
        "date2":_endDate,
      };
      final response = await reportRepo.getChangeReport(data);
      print(response.toString());
      if(response.isNotEmpty){
        _taskReport=response;
        _reportRefresh=true;
      }
      else{
        _taskReport=[];
        _reportRefresh=true;
      }
    } catch (e) {
      _taskReport=[];
      _reportRefresh=true;
    }
    notifyListeners();
  }
  List<MonthReport> _expenseReport = [];
  List<MonthReport> get expenseReport => _expenseReport;
  Future<void> getCReport3(String id) async {
    try {
      _expenseReport=[];
      _reportRefresh=false;
      notifyListeners();
      Map data = {
        "action": taskDatas,
        "search_type":"emp_expense",
        "cos_id":localData.storage.read("cos_id"),
        "role":localData.storage.read("role"),
        "id":localData.storage.read("role")=="1"?id:localData.storage.read("id"),
        "date1":_startDate,
        "date2":_endDate,
      };
      final response = await reportRepo.getChartReport(data);
      if(response.isNotEmpty){
        _expenseReport=response;
        _reportRefresh=true;
      }
      else{
        _expenseReport=[];
        _reportRefresh=true;
      }
    } catch (e) {
      _expenseReport=[];
      _reportRefresh=true;
    }
    notifyListeners();
  }
  late TabController tabController;
  void updateIndex(int index){
    tabController.index=index;
    notifyListeners();
  }
  List<MonthReport> _customerVisits = [];
  List<MonthReport> get customerVisits => _customerVisits;
  double maxY = 100; // Or calculate your maximum

  FlTitlesData get employeeExpenseTitlesData => FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 35, // change panniratha
        getTitlesWidget: expenseTitles,
      ),
    ),
    leftTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    topTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    rightTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
  );
  Widget expenseTitles(double value, TitleMeta meta,) {
    final style = TextStyle(
      color: colorsConst.primary.withOpacity(0.6),
      fontSize: 11,
    );
    int index = value.toInt();

    String formattedDate ="";
    if(_expenseReport.length>7){
      DateTime parsedDate = DateTime.parse(_expenseReport[index].dt.toString()); // parses "2025-04-15"
      formattedDate = DateFormat('dd-MMM\nyy').format(parsedDate);
    }else{
      formattedDate = DateFormat('dd/MM - EEE').format(DateFormat('yyyy-MM-dd').parse(_expenseReport[index].dt!)).split('-').last;
    }

    String text = index >= 0 && index <_expenseReport.length ? formattedDate: '';
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0.2,
      child: Container(
          height: _expenseReport.length>7?30:13,color: Colors.transparent,
          child: Text(text, style: style,)),
    );
  }

  List<BarChartGroupData> get barGroups3 => _customerVisits.asMap().entries.map((entry) {
    int index = entry.key;
    double y = double.parse(entry.value.totalAttendance.toString());
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 10,
          borderRadius: BorderRadius.circular(5),
          gradient: _barsGradient,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maxY,
            color: Colors.grey.shade200,
          ),
        ),
      ],
      showingTooltipIndicators: [0],
    );
  }).toList();
  FlBorderData get expBorderData => FlBorderData(
    show: false,
  );

  List<BarChartGroupData> get expBarGroups => _expenseReport.asMap().entries.map((entry) {
    int index = entry.key;
    double y = double.parse(entry.value.total.toString());
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 35, // or your barWidth
          gradient: _expenseBarsGradient,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.zero,
            topRight: Radius.zero,
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5),
          ),
        )
      ],
      showingTooltipIndicators: [0],
    );
  }).toList();

  LinearGradient get _expenseBarsGradient => LinearGradient(
    colors: [
      colorsConst.appRed,
      colorsConst.appRed,
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
  Future<void> getCustomerTasks(String id) async {
    try {
      _customerTasks=[];
      _reportRefresh=false;
      notifyListeners();
      Map data = {
        "action": taskDatas,
        "search_type":"customer_tasks",
        "cos_id":localData.storage.read("cos_id"),
        "role":localData.storage.read("role"),
        "user_id":localData.storage.read("id"),
        "id":id,
        "date1":_startDate4,
        "date2":_endDate4,
      };
      final response = await reportRepo.getReport(data);
      if(response.isNotEmpty){
        _customerTasks=response;
        _reportRefresh=true;
      }
      else{
        _customerTasks=[];
        _reportRefresh=true;
      }
    } catch (e) {
      _customerTasks=[];
      _reportRefresh=true;
    }
    notifyListeners();
  }
  Future<void> getCustomerVisits(String id) async {
    try {
      _customerVisits=[];
      _reportRefresh=false;
      notifyListeners();
      Map data = {
        "action": taskDatas,
        "search_type":"customer_visits",
        "cos_id":localData.storage.read("cos_id"),
        "role":localData.storage.read("role"),
        "user_id":localData.storage.read("id"),
        "id":id,
        "date1":_startDate4,
        "date2":_endDate4,
      };
      final response = await reportRepo.getChartReport(data);
      if(response.isNotEmpty){
        _customerVisits=response;
        _reportRefresh=true;
      }
      else{
        _customerVisits=[];
        _reportRefresh=true;
      }
    } catch (e) {
      _customerVisits=[];
      _reportRefresh=true;
    }
    notifyListeners();
  }
  List<MonthReport> _customerExpenseReport = [];
  List<MonthReport> get customerExpenseReport => _customerExpenseReport;

  Future<void> getCustomerExpense(String id) async {
    try {
      _customerExpenseReport=[];
      _reportRefresh=false;
      notifyListeners();
      Map data = {
        "action": taskDatas,
        "search_type":"customer_expense",
        "cos_id":localData.storage.read("cos_id"),
        "role":localData.storage.read("role"),
        "user_id":localData.storage.read("id"),
        "id":id,
        "date1":_startDate4,
        "date2":_endDate4,
      };
      final response = await reportRepo.getChartReport(data);
      if(response.isNotEmpty){
        _customerExpenseReport=response;
        _reportRefresh=true;
      }
      else{
        _customerExpenseReport=[];
        _reportRefresh=true;
      }
    } catch (e) {
      _customerExpenseReport=[];
      _reportRefresh=true;
    }
    notifyListeners();
  }
  FlTitlesData get titlesData3 => FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        getTitlesWidget: getTitles3,
      ),
    ),
    leftTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    topTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    rightTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
  );
  Widget getTitles3(double value, TitleMeta meta,) {
    final style = TextStyle(
      color: colorsConst.primary.withOpacity(0.6),
      fontSize: 12,
    );
    int index = value.toInt();

    String formattedDate ="";
    if(_customerVisits.length>=7){
      DateTime parsedDate = DateTime.parse(_customerVisits[index].date.toString()); // parses "2025-04-15"
      formattedDate = DateFormat('dd-MMM\nyy').format(parsedDate);
    }else{
      formattedDate = DateFormat('dd/MM - EEE').format(DateFormat('yyyy-MM-dd').parse(_customerVisits[index].date!)).split('-').last;
    }

    String text = index >= 0 && index <_customerVisits.length ? formattedDate: '';
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 2,
      child: Text(text, style: style),
    );
  }

  FlBorderData get borderData3 => FlBorderData(
    show: false,
  );

  FlTitlesData get expTitlesData4 => FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 35, // or 60 or more
        getTitlesWidget: expenseTitles4,
      ),
    ),
    leftTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    topTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    rightTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
  );

  Widget expenseTitles4(double value, TitleMeta meta,) {
    final style = TextStyle(
      color: colorsConst.primary.withOpacity(0.6),
      fontSize: 11,
    );
    int index = value.toInt();

    String formattedDate ="";
    if(_customerExpenseReport.length>7){
      DateTime parsedDate = DateTime.parse(_customerExpenseReport[index].date.toString()); // parses "2025-04-15"
      formattedDate = DateFormat('dd-MMM\nyy').format(parsedDate);
    }else{
      formattedDate = DateFormat('dd/MM - EEE').format(DateFormat('yyyy-MM-dd').parse(_customerExpenseReport[index].date!)).split('-').last;
    }

    String text = index >= 0 && index <_customerExpenseReport.length ? formattedDate: '';
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0.2,
      child: Container(
          height: _customerExpenseReport.length>7?30:13,color: Colors.transparent,
          child: Text(text, style: style)),
    );
  }

  List<BarChartGroupData> get expBarGroups4 => _customerExpenseReport.asMap().entries.map((entry) {
    int index = entry.key;
    double y = double.parse(entry.value.total.toString());
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 35, // or your barWidth
          gradient: _expenseBarsGradient,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.zero,
            topRight: Radius.zero,
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5),
          ),
        )
      ],
      showingTooltipIndicators: [0],
    );
  }).toList();
  List<BarChartGroupData> get barGroups4 => _customerExpenseReport.asMap().entries.map((entry) {
    int index = entry.key;
    double y = double.parse(entry.value.totalAttendance.toString());
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: _barsGradient,
          borderRadius: BorderRadius.circular(2),
        )
      ],
      showingTooltipIndicators: [0],
    );
  }).toList();

}