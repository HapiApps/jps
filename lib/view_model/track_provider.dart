import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/track/empData_model.dart';
import '../model/user_model.dart';
import '../repo/track_repo.dart';
import 'dart:math'as math;
import '../source/constant/api.dart';

class TrackProvider with ChangeNotifier{
  final TackRepository trackRepo = TackRepository();

  /// Daily track short report
  List<EmployeeData> _todayDisplayList=<EmployeeData>[];
  List<EmployeeData> _searchTodayDisplayList=<EmployeeData>[];
  List<EmployeeData> get todayDisplayList => _todayDisplayList;
  List<EmployeeData> get searchTodayDisplayList => _searchTodayDisplayList;
  bool _isTrack =true;
  bool get isTrack => _isTrack;
  String _startDate = "";
  String get startDate => _startDate;
  String _endDate="";
  String get endDate => _endDate;
  DateTime stDt = DateTime.now();
  DateTime enDt = DateTime.now().add(const Duration(days: 1));
  void initDate(){
    stDt = DateTime.now();
    enDt = DateTime.now().add(const Duration(days: 1));
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    notifyListeners();
  }
  String formatTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString); // Current DateTime
    return DateFormat("h:mm a").format(dateTime);
  }
  void searchTrack(String value){
    final suggestions=_searchTodayDisplayList.where(
            (user){
          final comFName=user.firstname.toString().toLowerCase();
          final userFName=user.number.toString().toLowerCase();
          final input=value.toString().toLowerCase();
          return comFName.contains(input) || userFName.contains(input);
        }).toList();
    _todayDisplayList=suggestions;
    notifyListeners();
  }
  String duration(String time1, String time2) {
    // Convert 12-hour format to 24-hour format
    DateFormat inputFormat = DateFormat("hh:mm a"); // 12-hour format with AM/PM
    DateFormat outputFormat = DateFormat("HH:mm"); // 24-hour format

    String startTime24 = outputFormat.format(inputFormat.parse(time1));
    String endTime24 = outputFormat.format(inputFormat.parse(time2));

    // Parse and calculate duration
    DateTime now = DateTime.now();
    DateTime startDateTime = DateTime.parse("${now.year}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")} $startTime24:00");
    DateTime endDateTime = DateTime.parse("${now.year}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")} $endTime24:00");

    Duration diff = endDateTime.difference(startDateTime);

    // Format output
    return "${diff.inHours}h ${diff.inMinutes % 60}m ${diff.inSeconds % 60}s";
  }
  // void filterDialog(BuildContext context){
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         actions: [
  //           20.height,
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               70.width,
  //               const CustomText(
  //                 text: 'Filters',
  //                 colors: Colors.black,
  //                 size: 16,
  //                 isBold: true,
  //               ),
  //               30.width,
  //               InkWell(
  //                 onTap: () {
  //                   Navigator.of(context, rootNavigator: true).pop();
  //                 },
  //                 child: SvgPicture.asset(assets.cancel),
  //               )
  //             ],
  //           ),
  //           20.height,
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   CustomText(
  //                     text: "From Date",
  //                     colors: colorsConst.greyClr,
  //                     size: 12,
  //                   ),
  //                   InkWell(
  //                     onTap: () {
  //                       datePick(
  //                         context: context,
  //                         date: _startDate,
  //                       );
  //                     },
  //                     child: Container(
  //                       height: 30,
  //                       width: MediaQuery.of(context).size.width * 0.35,
  //                       decoration: customDecoration.baseBackgroundDecoration(
  //                         color: Colors.white,
  //                         radius: 5,
  //                         borderColor: colorsConst.litGrey,
  //                       ),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           CustomText(text: _startDate),
  //                           5.width,
  //                           SvgPicture.asset(assets.calendar2),
  //                         ],
  //                       ),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   CustomText(
  //                     text: "To Date",
  //                     colors: colorsConst.greyClr,
  //                     size: 12,
  //                   ),
  //                   InkWell(
  //                     onTap: () {
  //                       datePick(
  //                         context: context,
  //                         date: _endDate,
  //                       );
  //                     },
  //                     child: Container(
  //                       height: 30,
  //                       width: MediaQuery.of(context).size.width * 0.35,
  //                       decoration: customDecoration.baseBackgroundDecoration(
  //                         color: Colors.white,
  //                         radius: 5,
  //                         borderColor: colorsConst.litGrey,
  //                       ),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           CustomText(text: _endDate),
  //                           5.width,
  //                           SvgPicture.asset(assets.calendar2),
  //                         ],
  //                       ),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             ],
  //           ),
  //           10.height,
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               CustomText(
  //                 text: "Select Date Range",
  //                 colors: colorsConst.greyClr,
  //                 size: 12,
  //               ),
  //               Container(
  //                 height: 30,
  //                 width: MediaQuery.of(context).size.width * 0.72,
  //                 decoration: customDecoration.baseBackgroundDecoration(
  //                   radius: 5,
  //                   color: Colors.white,
  //                   borderColor: colorsConst.litGrey,
  //                 ),
  //                 child: DropdownButton(
  //                   iconEnabledColor: colorsConst.greyClr,
  //                   isExpanded: true,
  //                   underline: const SizedBox(),
  //                   icon: const Icon(Icons.keyboard_arrow_down_outlined),
  //                   value: _filterType,
  //                   onChanged: (value) {
  //                     changeFilterType(value);
  //                   },
  //                   items: filterTypeList.map((list) {
  //                     return DropdownMenuItem(
  //                       value: list,
  //                       child: CustomText(
  //                         text: "  $list",
  //                         colors: Colors.black,
  //                         isBold: false,
  //                       ),
  //                     );
  //                   }).toList(),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           20.height,
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               CustomBtn(
  //                 width: 100,
  //                 text: 'Clear All',
  //                 callback: () {
  //                   initFilterValue(true);
  //                   Navigator.of(context, rootNavigator: true).pop();
  //                 },
  //                 bgColor: Colors.grey.shade200,
  //                 textColor: Colors.black,
  //               ),
  //               CustomBtn(
  //                 width: 100,
  //                 text: 'Apply Filters',
  //                 callback: () {
  //                   initFilterValue(false);
  //                   filterList();
  //                   Navigator.of(context, rootNavigator: true).pop();
  //                 },
  //                 bgColor: colorsConst.primary,
  //                 textColor: Colors.white,
  //               ),
  //             ],
  //           ),
  //           20.height,
  //         ],
  //       );
  //     },
  //   );
  // }
  bool _filter=false;
  bool get filter=>_filter;
  dynamic _filterType;
  String get filterType =>_filterType;
  var filterTypeList = ["Today","Yesterday","Last 7 Days","Last 30 Days","This Week","This Month","Last 3 months"];
  void initFilterValue(bool isClear){
    if(isClear==false){
      _filter=true;
    }else{
      _filter=false;
      daily();
      _filterType="Today";
      // _filterCustomerData=_customerData;
    }
    notifyListeners();
  }
  void daily() {
    stDt=DateTime.now();
    enDt=DateTime.now().add(const Duration(days: 1));
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    notifyListeners();
  }
  void yesterday() {
    stDt=DateTime.now().subtract(const Duration(days: 1));
    enDt = DateTime.now();
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    notifyListeners();
  }
  void last7Days() {
    DateTime now = DateTime.now();
    DateTime lastWeekStart = now.subtract(const Duration(days: 6));
    DateTime lastWeekEnd = now.add(const Duration(days: 1));
    _startDate = DateFormat('dd-MM-yyyy').format(lastWeekStart);
    _endDate = DateFormat('dd-MM-yyyy').format(lastWeekEnd);
    notifyListeners();
  }
  void last30Days() {
    DateTime now = DateTime.now();
    DateTime lastMonthStart = now.subtract(const Duration(days: 30));
    DateTime lastMonthEnd = now.add(const Duration(days: 1));
    _startDate = DateFormat('dd-MM-yyyy').format(lastMonthStart);
    _endDate = DateFormat('dd-MM-yyyy').format(lastMonthEnd);
    notifyListeners();
  }
  void thisWeek() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;
    DateTime stDt = now.subtract(Duration(days: currentWeekday - 1));
    DateTime enDt = now.add(Duration(days: 7 - currentWeekday));
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    notifyListeners();
  }
  void thisMonth() {
    DateTime now = DateTime.now();
    stDt = DateTime(now.year, now.month, 1);
    enDt = now; // Today’s date
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    notifyListeners();
  }
  void last3Month() {
    DateTime now = DateTime.now();

// Subtract 3 months from today
    DateTime stDt = DateTime(now.year, now.month - 3, now.day);
    DateTime enDt = now;

    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
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
    notifyListeners();
  }
  void changeFilterType(dynamic value){
    _filterType = value;
    if(_filterType=="Today"){
      daily();
    }else if(_filterType=="Yesterday"){
      yesterday();
    }else if(_filterType=="Last 7 Days"){
      last7Days();
    }else if(_filterType=="Last 30 Days"){
      last30Days();
    }else if(_filterType=="This Week"){
      thisWeek();
    }else if(_filterType=="This Month"){
      thisMonth();
    }else if(_filterType=="Last 3 months"){
      last3Month();
    }
    notifyListeners();
  }
  dynamic _user;
  dynamic get user=>_user;
  void selectUser(UserModel value){
    _user=value.id;
    // getAttendanceReport(_user,"0");
    notifyListeners();
  }
  void datePick({required BuildContext context, required bool isStartDate}) {
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

        if (isStartDate) {
          _startDate = formattedDate;
        } else {
          _endDate = formattedDate;
        }

        notifyListeners();
      }
    });
  }

  Future toTrack() async {
    _isTrack=false;
    _todayDisplayList.clear();
    _searchTodayDisplayList.clear();
    notifyListeners();
    try {
      Map data = {
        "action":getTrackDetails,
        "search_type":"admin_track_today",
        "st":_startDate,
        "en":_endDate,
      };
      final response =await trackRepo.getTodayTrack(data);
      // print(data.toString());
      if (response.isNotEmpty) {
        // final  List dataList= json.decode(request.body);
        List<Map<String, dynamic>> convertDynamicList(List<dynamic> dynamicList) {
          return dynamicList.cast<Map<String, dynamic>>();
        }
        List<Map<String, dynamic>> convertedList = convertDynamicList(response);
        _todayDisplayList = processEmployeeData(convertedList);
        _searchTodayDisplayList = processEmployeeData(convertedList);
        _isTrack=true;
      }else{
        _isTrack=true;
        _todayDisplayList.clear();
        _searchTodayDisplayList.clear();
      }
    } catch (e) {
      _isTrack=true;
      _todayDisplayList.clear();
      _searchTodayDisplayList.clear();
    }
    notifyListeners();
  }
  List _detailReport=[];
  dynamic get detailReport=>_detailReport;
  Future todayReport(String id) async {
    try {
      _isTrack=false;
      detailReport.clear();
      Map data = {
        "action":getTrackDetails,
        "search_type":"emp_today_report",
        "id":id,
        "date":_startDate,
      };
      final response =await trackRepo.getTodayTrack(data);
      // print(data.toString());
      if (response.isNotEmpty) {
        // final  List dataList= json.decode(request.body);
        List<Map<String, dynamic>> convertDynamicList(List<dynamic> dynamicList) {
          return dynamicList.cast<Map<String, dynamic>>();
        }
        List<Map<String, dynamic>> convertedList = convertDynamicList(response);
        processData(convertedList);
        _isTrack=true;
      }else{
        _isTrack=true;
        _detailReport.clear();
      }
    } catch (e) {
      _isTrack=true;
      _detailReport.clear();
    }
    notifyListeners();
  }
  String _totalDst="0.0",_time1="",_time2="";
  String get totalDst=>_totalDst;
  String get time1=>_time1;
  String get time2=>_time2;

  void processData(List<Map<String, dynamic>> data) {
    // Group data by unit_id and unit_name
    final groupedData = <String, List<Map<String, dynamic>>>{};
    double totalOutputDistance=getDistanceFromGPSPointsInRoute(data);

    for (var entry in data) {
      final key = '${entry['unit_id']}-${entry['unit_name']}';
      if (!groupedData.containsKey(key)) {
        groupedData[key] = [];
      }
      groupedData[key]!.add(entry);
    }

    // Prepare output
    double totalDistance = 0.0;
    int totalUnitCount = 0;
    final unitWiseData = [];

    groupedData.forEach((key, entries) {
      // print("Entries $entries");
      entries.sort((a, b) =>
          DateTime.parse(a['created_ts']).compareTo(DateTime.parse(b['created_ts'])));

      final startEntry = entries.first;
      final endEntry = entries.last;

      final startTime = startEntry['created_ts'];
      final endTime = endEntry['created_ts'];
      final visitCount = entries.length;

      // Determine start and end images
      final startImage = entries.firstWhere(
            (e) => e['status'] == '1' && e['image'].isNotEmpty,
        orElse: () => {},
      )['image'];

      final endImage = entries.firstWhere(
            (e) => e['status'] == '2' && e['image'].isNotEmpty,
        orElse: () => {},
      )['image'];

      // final distance = entries.fold(0.0, (sum, entry) {
      //   return sum + (entry['lat'] != null && entry['lng'] != null ? 0.1 : 0.0); // Dummy calculation
      // });
      double totalD=getDistanceFromGPSPointsInRoute(entries);
      totalDistance =totalD;

      if (startEntry['unit_name'] != 'null') {
        totalUnitCount++;
      }

      unitWiseData.add({
        'Unit Name': startEntry['unit_name'],
        'Start Time': startTime,
        'End Time': endTime,
        'Distance': totalDistance.toStringAsFixed(2),
        'Visit Count': visitCount,
        'Start Image': startImage ?? '',
        'End Image': endImage ?? '',
      });
    });

    _time1=data.first['created_ts'];
    _time2=data.last['created_ts'];
   _totalDst=totalOutputDistance.toStringAsFixed(2);
    _detailReport=unitWiseData;
  }

  static double getDistanceFromGPSPointsInRoute(List gpsList) {
    double totalDistance = 0.0;

    for (var i = 0; i < gpsList.length-1; i++) {
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 -
          c((double.parse(gpsList[i + 1]["lat"]) - double.parse(gpsList[i]["lat"])) * p) / 2 +
          c(double.parse(gpsList[i + 1]["lat"]) * p) *
              c(double.parse(gpsList[i + 1]["lat"]) * p) *
              (1 - c((double.parse(gpsList[i + 1]["lng"]) - double.parse(gpsList[i]["lng"])) * p)) /
              2;
      double distance = 12742 * asin(sqrt(a));
      totalDistance += distance;
      // print('Distance is ${12742 * asin(sqrt(a))}');
    }
    // print('Total distance is $totalDistance');
    return totalDistance;
  }

  List<EmployeeData> processEmployeeData(List<Map<String, dynamic>> data) {
    Map<String, List<Map<String, dynamic>>> groupedData = {};

    // Group data by firstname
    for (var entry in data) {
      String firstname = entry['firstname'];
      if (!groupedData.containsKey(firstname)) {
        groupedData[firstname] = [];
      }
      groupedData[firstname]!.add(entry);
    }

    List<EmployeeData> result = [];

    // Process each employee's data
    groupedData.forEach((firstname, records) {
      records.sort((a, b) => a['created_ts'].compareTo(b['created_ts']));

      String startTime = records.first['created_ts'];
      String endTime = records.last['created_ts'];

      // Validate or determine consistent values for id, role, and number
      String id = records.first['emp_id']; // Assuming id is consistent across records
      String number = records.first['mobile_number']; // Assuming mobile_number is consistent
      String role = records.first['role_name']; // Assuming role_name is consistent
      String trackOn = records.first['track_on']; // Assuming role_name is consistent
      String image = records.first['image']; // Assuming role_name is consistent

      double totalDistance = 0;
      Set<String> uniqueUnits = {};

      for (int i = 0; i < records.length - 1; i++) {
        double lat1 = double.parse(records[i]['lat']);
        double lon1 = double.parse(records[i]['lng']);
        double lat2 = double.parse(records[i + 1]['lat']);
        double lon2 = double.parse(records[i + 1]['lng']);

        totalDistance += calculateDistance(lat1, lon1, lat2, lon2);

        if (records[i]['unit_name'] != "null") {
          uniqueUnits.add(records[i]['unit_name']);
        }
      }

      // Include the last record's unit_name
      if (records.last['unit_name'] != "null") {
        uniqueUnits.add(records.last['unit_name']);
      }

      result.add(EmployeeData(
        firstname: firstname,
        trackOn: trackOn,
        image: image,
        startTime: startTime,
        endTime: endTime,
        totalDistance: totalDistance,
        totalVisitUnitCount: uniqueUnits.length,
        id: id,
        role: role,
        number: number,
      ));
    });

    return result;
  }
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = math.cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * math.asin(math.sqrt(a));
  }

}
