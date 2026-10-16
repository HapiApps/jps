import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group_button/group_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:video_player/video_player.dart';
import '../component/custom_text.dart';
import '../local_database/sqlite.dart';
import '../model/audio_model.dart';
import '../model/customer/customer_attendance_model.dart';
import '../model/leave/holidays_model.dart';
import '../model/task/task_data_model.dart';
import '../model/task/task_details_model.dart';
import '../model/user_model.dart';
import '../repo/task_repo.dart';
import '../model/task/task_chart_model.dart';
import '../screens/attendance/offline_attendance.dart';
import '../screens/common/camera.dart';
import '../screens/common/dashboard.dart';
import '../screens/task/view_task.dart';
import '../source/constant/api.dart';
import '../source/constant/colors_constant.dart';
import '../source/constant/language_model.dart';
import '../source/constant/local_data.dart';
import 'employee_provider.dart';
import 'home_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class TaskProvider with ChangeNotifier {
  // ===========================================================================
  // PERFORMANCE CORE
  // ===========================================================================

  /// view_task.dart listens with Selector<TaskProvider, int>(p.dataVersion).
  /// Every real data change bumps this (automatically via notifyListeners()).
  /// The 1-second timer tick does NOT bump it -> list is not rebuilt each second.
  int _dataVersion = 0;
  int get dataVersion => _dataVersion;

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    _dataVersion++;
    super.notifyListeners();
  }

  /// Timer widgets can listen to this (ValueListenableBuilder) instead of the
  /// whole provider.
  final ValueNotifier<int> tickNotifier = ValueNotifier<int>(0);

  /// Debug-only logging (print is slow in release builds)
  void _log(Object? message) {
    if (kDebugMode) debugPrint(message.toString());
  }

  /// Date parse cache (dd-MM-yyyy). Avoids re-parsing the same string
  /// thousands of times on every build / filter.
  static final DateFormat _df = DateFormat('dd-MM-yyyy');
  final Map<String, DateTime?> _dateCache = {};

  DateTime? _parseTaskDate(String? s) {
    if (s == null) return null;
    final key = s.trim();
    if (key.isEmpty) return null;
    return _dateCache.putIfAbsent(key, () {
      try {
        return _df.parse(key);
      } catch (_) {
        return null;
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    timer?.cancel();
    _uiTicker?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _completeSub?.cancel();
    _a2PosSub?.cancel();
    _a2CompleteSub?.cancel();
    tickNotifier.dispose();
    super.dispose();
  }

  // ===========================================================================

  void updateTaskComment(int index, String commentText) {
    _filterUserData[index].lastComment = commentText;
    _filterUserData[index].lastCommentBy = localData.storage.read("f_name");
    _filterUserData[index].commentCount =
    "${int.parse(_filterUserData[index].commentCount ?? '0') + 1}";
    notifyListeners();
  }

  late VideoPlayerController videoPlayerController;
  final TaskRepo _taskRepo = TaskRepo();
  bool _isDisposed = false;
  RoundedLoadingButtonController completeCtr = RoundedLoadingButtonController();
  RoundedLoadingButtonController startCtr = RoundedLoadingButtonController();
  RoundedLoadingButtonController holdCtr = RoundedLoadingButtonController();
  RoundedLoadingButtonController resumeCtr = RoundedLoadingButtonController();
  RoundedLoadingButtonController taskCtr = RoundedLoadingButtonController();
  RoundedLoadingButtonController taskStatusCtr = RoundedLoadingButtonController();

  String formatDuration2(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  bool isAddTaskLoading = false;
  bool _incompleteMode = false;
  GroupButtonController statusController = GroupButtonController();
  bool _isFilter = false;
  bool get isFilter => _isFilter;
  String _startDate = "";
  String get startDate => _startDate;
  String lStatus = "";
  String _endDate = "";
  String get endDate => _endDate;
  String _companyName = "";
  String get companyName => _companyName;

  void setFilterDate(String value) {
    if (_filterDate == value) return; // avoid unnecessary rebuild
    _filterDate = value;
    notifyListeners();
  }

  final ScrollController scrollController = ScrollController();
  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void changeFilterStatusTab(String id) {
    _statusIds = id;
    filterList(); // filterList already notifies
  }

  void setDefaultType() {
    if (typeList.isNotEmpty && (type == null || type.toString().isEmpty)) {
      _type = typeList.first["id"].toString();
      notifyListeners();
    }
  }

  void filterList() {
    if (_startDate.isEmpty || _endDate.isEmpty) {
      notifyListeners();
      return;
    }

    // Incomplete screen la user date filter apply pannala na date check venaam
    final bool applyDate = !(_incompleteMode && _isFilter != true);

    DateTime parsedStartDate;
    DateTime parsedEndDate;

    try {
      final startDate = _df.parse(_startDate);
      final endDate = _df.parse(_endDate);

      parsedStartDate = DateTime(startDate.year, startDate.month, startDate.day);
      parsedEndDate = DateTime(endDate.year, endDate.month, endDate.day);
    } catch (e) {
      _log("Start/End Date Parse Error: $e");
      return;
    }

    // values that do not change per task -> computed once, outside the loop
    final selectedType = _fType.toString().trim().toLowerCase();
    final searchName = _assignedNames.trim().toLowerCase();
    final selectedCompany = _companyName.toString().trim().toLowerCase();
    final selectedStatus = _statusIds.toString().trim();

    _filterUserData = _searchAllTasks.where((contact) {
      // ---------------- DATE CHECK ----------------
      bool isWithinDateRange = true;

      if (applyDate) {
        final taskDate = _parseTaskDate(contact.taskDate);
        if (taskDate == null) return false;

        final taskDateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);

        isWithinDateRange = !taskDateOnly.isBefore(parsedStartDate) &&
            !taskDateOnly.isAfter(parsedEndDate);
      }
      if (!isWithinDateRange) return false;

      // ---------------- TYPE CHECK ----------------
      final contactType = (contact.type ?? "").toString().trim().toLowerCase();
      final isTypeMatch = selectedType.isEmpty || selectedType == contactType;
      if (!isTypeMatch) return false;

      // ---------------- EMPLOYEE CHECK ----------------
      bool isEmpMatch = true;
      if (searchName.isNotEmpty) {
        final assignedList = (contact.assignedNames ?? "")
            .toString()
            .split(',')
            .map((e) => e.trim().toLowerCase())
            .where((e) => e.isNotEmpty);

        isEmpMatch = assignedList.any((name) =>
        name == searchName ||
            name.contains(searchName) ||
            searchName.contains(name));
      }
      if (!isEmpMatch) return false;

      // ---------------- CUSTOMER CHECK ----------------
      final contactCompany =
      (contact.projectName ?? "").toString().trim().toLowerCase();
      final isCusMatch =
          selectedCompany.isEmpty || selectedCompany == contactCompany;
      if (!isCusMatch) return false;

      // ---------------- STATUS CHECK ----------------
      final taskStatus = (contact.statval ?? "").toString().trim();
      return selectedStatus.isEmpty || taskStatus == selectedStatus;
    }).toList();

    notifyListeners();
  }

  String _fType = "";
  String get fType => _fType;

  String? _filterTypeId; // dropdown selection for the FILTER only
  String? get filterTypeId => _filterTypeId;

  void checkFilterType(dynamic value) {
    String id = "";
    String name = "";

    if (value == null) {
      // cleared
    } else if (value is Map) {
      id = (value["id"] ?? "").toString();
      name = (value["value"] ?? "").toString().trim();
    } else {
      // dropdown gave an id (or a name) -> resolve it from typeList
      final s = value.toString().trim();
      final match = typeList.cast<dynamic>().firstWhere(
            (e) =>
        e["id"].toString() == s ||
            e["value"].toString().trim().toLowerCase() == s.toLowerCase(),
        orElse: () => null,
      );
      if (match != null) {
        id = match["id"].toString();
        name = match["value"].toString().trim();
      }
    }

    if (name.toLowerCase() == "all") {
      id = "";
      name = "";
    }

    _filterTypeId = id.isEmpty ? null : id;
    _fType = name; // ALWAYS the type NAME, which is what task.type contains

    filterList(); // apply immediately
  }

  void filterList2() {
    DateTime parsedStartDate;
    DateTime parsedEndDate;
    try {
      parsedStartDate = _df.parse(_startDate);
      parsedEndDate = _df.parse(_endDate);
    } catch (e) {
      _log("filterList2 date parse error: $e");
      return;
    }

    _filterUserData = _searchAllTasks.where((contact) {
      final taskDate = _parseTaskDate(contact.taskDate?.toString());
      if (taskDate == null) return false;
      final taskDateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);

      final isWithinDateRange =
          !taskDateOnly.isBefore(parsedStartDate) && !taskDateOnly.isAfter(parsedEndDate);

      final isTypeMatch = _fType.isEmpty ||
          _fType.toLowerCase() == (contact.type ?? "").toString().trim().toLowerCase();
      final isEmpMatch =
          _userName == "" || contact.assignedNames.toString().contains(_userName);
      final isCusMatch = _companyName == "" || contact.projectName == _companyName;

      return isWithinDateRange && isTypeMatch && isEmpMatch && isCusMatch;
    }).toList();

    notifyListeners();
  }

  void changeName(value) {
    _companyName = value!.companyName.toString();
    filterList();
  }

  String _stDate = "";
  String _enDate = "";
  String get stDate => _stDate;
  String get enDate => _enDate;
  PickerDateRange? selectedDate2;
  List<DateTime> datesBetween = [];
  String betweenDates = "";
  List<DateTime> getDatesInRange(DateTime start, DateTime end) {
    List<DateTime> days = [];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      days.add(DateTime(start.year, start.month, start.day + i));
    }
    return days;
  }

  void showDatePickerDialog(BuildContext context) {
    DateTime today = DateTime.now();
    selectedDate2 = PickerDateRange(today, today);
    datesBetween = getDatesInRange(selectedDate2!.startDate!, selectedDate2!.endDate!);

    DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    List<String> formattedDates = datesBetween.map((date) => dateFormat.format(date)).toList();
    betweenDates = formattedDates.join(' || ');

    _stDate = dateFormat.format(selectedDate2!.startDate!);
    notifyListeners();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomText(
            text: '   Select Date',
            colors: colorsConst.secondary,
            isBold: true,
          ),
          content: SizedBox(
            height: 300,
            width: 300,
            child: SfDateRangePicker(
              minDate: DateTime(2025),
              maxDate: DateTime.now(),
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                selectedDate2 = args.value;
                _startDate = "";
                _endDate = "";
                if (selectedDate2?.endDate != null) {
                  _startDate = "${selectedDate2?.startDate?.day.toString().padLeft(2, "0")}"
                      "-${selectedDate2?.startDate?.month.toString().padLeft(2, "0")}"
                      "-${selectedDate2?.startDate?.year.toString()}";

                  _endDate = "${selectedDate2?.endDate?.day.toString().padLeft(2, "0")}"
                      "-${selectedDate2?.endDate?.month.toString().padLeft(2, "0")}"
                      "-${selectedDate2?.endDate?.year.toString()}";
                } else {
                  _startDate = "${selectedDate2?.startDate?.day.toString().padLeft(2, "0")}"
                      "-${selectedDate2?.startDate?.month.toString().padLeft(2, "0")}"
                      "-${selectedDate2?.startDate?.year.toString()}";
                  _endDate = "${selectedDate2?.startDate?.day.toString().padLeft(2, "0")}"
                      "-${selectedDate2?.startDate?.month.toString().padLeft(2, "0")}"
                      "-${selectedDate2?.startDate?.year.toString()}";
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
                CustomText(
                  text: 'Click and drag to select multiple dates',
                  colors: colorsConst.greyClr,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: const CustomText(text: 'Cancel', colors: Colors.grey, isBold: true),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: CustomText(text: 'OK', colors: colorsConst.primary, isBold: true),
                  onPressed: () {
                    if (selectedDate2 != null) {
                      datesBetween = getDatesInRange(
                        selectedDate2!.startDate!,
                        selectedDate2!.endDate ?? selectedDate2!.startDate!,
                      );
                    }
                    DateFormat dateFormat = DateFormat('dd-MM-yyyy');

                    List<String> formattedDates =
                    datesBetween.map((date) => dateFormat.format(date)).toList();
                    betweenDates = formattedDates.join(' || ');
                    filterList2();
                    initFilterValue(false);
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

  void initDateValue(String date1, String date2, String type) {
    _isFilter = false;
    _filterType = type;
    _type = null;
    _companyName = "";
    _fType = "";
    _filterTypeId = null; // NEW
    _filterUserData = _allTasks;
    _userName = "";
    _filterDate = "";
    _startDate = date1;
    _endDate = date2;
    search.clear();
    filterList();
  }

  void initFilterValue(bool isClear, {String? date1, String? date2, String? type}) {
    if (isClear == false) {
      _isFilter = true;
    } else {
      _isFilter = false;
      _filterType = type;
      _type = null;
      _companyName = "";
      _fType = "";
      _filterTypeId = null; // NEW
      _filterUserData = _allTasks;
      _userName = "";
      _filterDate = "";
      _startDate = date1!;
      _endDate = date2!;
      search.clear();
      _assignedNames = "";
    }
    search.clear();
    notifyListeners();
  }

  void filterPick({required BuildContext context, required String date, required bool isStartDate}) {
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
      lastDate: DateTime(2050),
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

  dynamic _filterType;
  dynamic get filterType => _filterType;
  void changeFilterType(dynamic value) {
    _filterType = value;
    if (_filterType == "Today") {
      daily();
    } else if (_filterType == "Yesterday") {
      yesterday();
    } else if (_filterType == "Last 7 Days") {
      last7Days();
    } else if (_filterType == "Last 30 Days") {
      last30Days();
    } else if (_filterType == "This Week") {
      thisWeek();
    } else if (_filterType == "This Month") {
      thisMonth();
    } else if (_filterType == "Last 3 months") {
      last3Month();
    }
    notifyListeners();
  }

  DateTime stDt = DateTime.now();
  DateTime enDt = DateTime.now().add(const Duration(days: 1));
  void daily() {
    stDt = DateTime.now();
    enDt = DateTime.now().add(const Duration(days: 1));
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(stDt);
    notifyListeners();
  }

  void yesterday() {
    stDt = DateTime.now().subtract(const Duration(days: 1));
    enDt = DateTime.now();
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(stDt);
    notifyListeners();
  }

  void last7Days() {
    DateTime now = DateTime.now();
    DateTime lastWeekStart = now.subtract(const Duration(days: 6));
    DateTime lastWeekEnd = now;
    _startDate = DateFormat('dd-MM-yyyy').format(lastWeekStart);
    _endDate = DateFormat('dd-MM-yyyy').format(lastWeekEnd);
    notifyListeners();
  }

  void last30Days() {
    DateTime now = DateTime.now();
    DateTime lastMonthStart = now.subtract(const Duration(days: 29));
    DateTime lastMonthEnd = now;
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
    stDt = DateTime(now.year, now.month, 1); // Start of month
    enDt = now; // Today's date
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
    notifyListeners();
  }

  void last3Month() {
    DateTime now = DateTime.now();
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

  var filterTypeList = [
    "Today",
    "Yesterday",
    "Last 7 Days",
    "Last 30 Days",
    "This Week",
    "This Month",
    "Last 3 months"
  ];
  dynamic _user;
  dynamic get user => _user;
  String _userName = "";
  String get userName => _userName;
  void selectUser(UserModel value) {
    _user = value.id;
    _userName = value.firstname.toString();
    filterList();
  }

  Future<void> downloadAllTask(BuildContext context) async {
    notifyListeners();

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      Map data = {
        "action": taskDatas,
        "search_type": "download_task_reports",
        "cos_id": localData.storage.read("cos_id"),
        "role": localData.storage.read("role"),
        "id": localData.storage.read("id"),
        "date1": _startDate,
        "date2": _endDate,
      };

      final response = await _taskRepo.downloadReport(data);
      _log("log response$response");
      if (!context.mounted) return;

      if (response.isNotEmpty) {
        List<DTaskModel> taskList = List<DTaskModel>.from(response);

        List<DTaskModel> filteredList = taskList.where((task) {
          final isTypeMatch = _fType.isEmpty || (_fType == task.type);

          final isEmpMatch =
              _userName.isEmpty || (task.assignedNames ?? "").contains(_userName);

          final isCusMatch =
              _companyName.isEmpty || (_companyName == (task.projectName ?? ""));

          return isTypeMatch && isEmpMatch && isCusMatch;
        }).toList();

        filteredList = List<DTaskModel>.from(filteredList);

        if (filteredList.isNotEmpty) {
          await exportTaskEmployeeWiseExcel(
            taskList: filteredList,
            fromDate: _startDate,
            toDate: _endDate,
          );

          if (context.mounted) Navigator.pop(context);
        } else {
          if (context.mounted) {
            Navigator.pop(context);
            utils.showWarningToast(context, text: "No Task Found");
          }
        }
      } else {
        if (context.mounted) {
          Navigator.pop(context);
          utils.showWarningToast(context, text: "No Task Found");
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        utils.showWarningToast(context, text: "No Task Found");
      }
    }

    notifyListeners();
  }

  Future<void> downloadAllOnlyEmpTask(BuildContext context) async {
    notifyListeners();

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      Map data = {
        "action": taskDatas,
        "search_type": "download_reports_work",
        "cos_id": localData.storage.read("cos_id"),
        "role": localData.storage.read("role"),
        "id": localData.storage.read("id"),
        "date1": _startDate,
        "date2": _endDate,
      };

      final response = await _taskRepo.downloadReport(data);
      _log("log response$response");
      if (!context.mounted) return;

      if (response.isNotEmpty) {
        List<DTaskModel> taskList = List<DTaskModel>.from(response);

        List<DTaskModel> filteredList = taskList.where((task) {
          final isTypeMatch = _fType.isEmpty || (_fType == task.type);

          final isEmpMatch =
              _userName.isEmpty || (task.assignedNames ?? "").contains(_userName);

          final isCusMatch =
              _companyName.isEmpty || (_companyName == (task.projectName ?? ""));

          return isTypeMatch && isEmpMatch && isCusMatch;
        }).toList();

        filteredList = List<DTaskModel>.from(filteredList);

        if (filteredList.isNotEmpty) {
          await exportTaskOnlyEmployeeWiseExcel(
            taskList: taskList,
            fromDate: _startDate,
            toDate: _endDate,
            role: "2",
            userName: localData.storage.read("f_name").toString(),
          );

          if (context.mounted) Navigator.pop(context);
        } else {
          if (context.mounted) {
            Navigator.pop(context);
            utils.showWarningToast(context, text: "No Task Found");
          }
        }
      } else {
        if (context.mounted) {
          Navigator.pop(context);
          utils.showWarningToast(context, text: "No Task Found");
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        utils.showWarningToast(context, text: "No Task Found");
      }
    }
    notifyListeners();
  }

  Future<void> exportTaskWithCommentsBlockExcel({
    required List<DTaskModel> taskList,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheet = excel["Sheet1"];

      CellStyle titleStyle = CellStyle(
        bold: true,
        fontSize: 16,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      CellStyle headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: "#D9E1F2",
        fontColorHex: "#000000",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      CellStyle subHeaderStyle = CellStyle(
        bold: true,
        backgroundColorHex: "#FFF2CC",
        fontColorHex: "#000000",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      CellStyle dataStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Left,
        verticalAlign: VerticalAlign.Top,
        textWrapping: TextWrapping.WrapText,
      );

      sheet.appendRow(["TASK COMMENT REPORT DETAILS ($fromDate to $toDate)"]);
      sheet.merge(
        CellIndex.indexByString("A1"),
        CellIndex.indexByString("G1"),
      );
      sheet.cell(CellIndex.indexByString("A1")).cellStyle = titleStyle;

      sheet.appendRow([""]);

      int rowIndex = 2;

      String safeText(dynamic value) {
        if (value == null) return "";
        String text = value.toString();
        if (text == "null") return "";
        return text.trim();
      }

      List<Map<String, String>> parseComments(String? commentsFull) {
        List<Map<String, String>> comments = [];

        if (commentsFull == null || commentsFull.trim().isEmpty) return comments;

        List<String> rawComments = commentsFull.split("||");

        for (var c in rawComments) {
          List<String> parts = c.split("|");

          String name = parts.isNotEmpty ? parts[0].trim() : "";
          String comment = parts.length > 1 ? parts[1].trim() : "";
          String time = parts.length > 2 ? parts[2].trim() : "";

          String formattedTime = "";

          if (time.isNotEmpty) {
            try {
              DateTime dt = DateTime.parse(time.trim());
              formattedTime =
              "${DateFormat("dd-MM-yyyy").format(dt)} ${DateFormat("hh:mm a").format(dt)}";
            } catch (e) {
              formattedTime = time;
            }
          }

          comments.add({
            "time": formattedTime,
            "name": name,
            "comment": comment,
          });
        }

        return comments;
      }

      for (int i = 0; i < taskList.length; i++) {
        final task = taskList[i];

        sheet.appendRow([
          "Task Date",
          "Task Title",
          "Company",
          "Task type",
          "Assigned",
          "Created By",
          "Status",
        ]);

        for (int col = 0; col < 7; col++) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex))
              .cellStyle = headerStyle;
        }

        rowIndex++;

        sheet.appendRow([
          safeText(task.taskDate),
          safeText(task.taskTitle),
          safeText(task.projectName),
          safeText(task.type),
          safeText(task.assignedNames),
          safeText(task.creator),
          safeText(task.status),
        ]);

        for (int col = 0; col < 7; col++) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex))
              .cellStyle = dataStyle;
        }

        rowIndex++;

        sheet.appendRow([""]);
        rowIndex++;

        sheet.appendRow(["COMMENTS"]);
        sheet.merge(
          CellIndex.indexByString("A${rowIndex + 1}"),
          CellIndex.indexByString("C${rowIndex + 1}"),
        );

        sheet.cell(CellIndex.indexByString("A${rowIndex + 1}")).cellStyle = subHeaderStyle;

        rowIndex++;

        sheet.appendRow(["Date Time", "Sender", "Comments"]);

        for (int col = 0; col < 3; col++) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex))
              .cellStyle = headerStyle;
        }

        rowIndex++;

        List<Map<String, String>> comments = parseComments(task.commentsFull);

        if (comments.isEmpty) {
          sheet.appendRow(["-", "-", "No Comments"]);
          rowIndex++;
        } else {
          for (var c in comments) {
            sheet.appendRow([
              c["time"] ?? "",
              c["name"] ?? "",
              c["comment"] ?? "",
            ]);

            sheet
                .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
                .cellStyle = dataStyle;

            rowIndex++;
          }
        }

        sheet.appendRow([""]);
        sheet.appendRow([""]);
        rowIndex += 2;
      }

      sheet.setColWidth(0, 22);
      sheet.setColWidth(1, 35);
      sheet.setColWidth(2, 30);
      sheet.setColWidth(3, 20);
      sheet.setColWidth(4, 25);
      sheet.setColWidth(5, 18);
      sheet.setColWidth(6, 15);

      sheet.setColWidth(0, 22);
      sheet.setColWidth(1, 18);
      sheet.setColWidth(2, 60);

      final dir = await getApplicationDocumentsDirectory();

      String cleanFromDate = fromDate.replaceAll("/", "-").replaceAll(":", "-");
      String cleanToDate = toDate.replaceAll("/", "-").replaceAll(":", "-");

      String filePath =
          "${dir.path}/Task_Comments_Block_${cleanFromDate}_to_$cleanToDate.xlsx";

      final bytes = excel.encode();
      if (bytes == null) return;

      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      await OpenFile.open(filePath);
    } catch (e) {
      _log("Excel Export Error => $e");
    }
  }

  Future<void> downloadAllTaskComment(BuildContext context) async {
    notifyListeners();

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      Map data = {
        "action": taskDatas,
        "search_type": "download_reports_work",
        "cos_id": localData.storage.read("cos_id"),
        "role": localData.storage.read("role"),
        "id": localData.storage.read("id"),
        "date1": _startDate,
        "date2": _endDate
      };

      final response = await _taskRepo.downloadReport(data);

      if (!context.mounted) return;

      if (response.isNotEmpty) {
        List<DTaskModel> taskList = List<DTaskModel>.from(response);

        List<DTaskModel> test = taskList.where((task) {
          final isTypeMatch = _fType.isEmpty || _fType == task.type;

          final isEmpMatch =
              _userName.isEmpty || (task.assignedNames ?? "").contains(_userName);

          final isCusMatch =
              _companyName.isEmpty || (task.projectName ?? "") == _companyName;

          return isTypeMatch && isEmpMatch && isCusMatch;
        }).toList();

        test = List<DTaskModel>.from(test);

        if (test.isNotEmpty) {
          if (context.mounted) Navigator.pop(context);

          await exportTaskWithCommentsBlockExcel(
            taskList: test,
            fromDate: _startDate,
            toDate: _endDate,
          );
        } else {
          if (context.mounted) Navigator.pop(context);
          utils.showWarningToast(context, text: "No Task Found");
        }
      } else {
        if (context.mounted) Navigator.pop(context);
        utils.showWarningToast(context, text: "No Task Found");
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      utils.showWarningToast(context, text: "No Task Found");
    }

    notifyListeners();
  }

  Future<void> exportTaskEmployeeWiseExcel({
    required List<DTaskModel> taskList,
    required String fromDate,
    required String toDate,
  }) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel["Sheet1"];

    /// =================== STYLES ===================
    CellStyle titleStyle = CellStyle(
      bold: true,
      fontSize: 16,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    CellStyle headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: "#FFFF00",
      fontColorHex: "#000000",
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    CellStyle empStyle = CellStyle(
      bold: true,
      backgroundColorHex: "#D9E1F2",
      fontColorHex: "#000000",
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
    );

    /// =================== TOP TITLE ===================
    sheet.appendRow(["${constValue.appName} TASK REPORT DETAILS"]);
    sheet.merge(
      CellIndex.indexByString("A1"),
      CellIndex.indexByString("I1"),
    );
    sheet.cell(CellIndex.indexByString("A1")).cellStyle = titleStyle;

    sheet.appendRow([""]);

    /// =================== GROUP BY EMPLOYEE ===================
    Map<String, List<DTaskModel>> groupedTasks = {};

    for (var task in taskList) {
      String names = task.assignedNames ?? "Unknown";

      List<String> empList = names.split(",");

      for (var emp in empList) {
        String empName = emp.trim();
        if (empName.isEmpty) empName = "Unknown";

        groupedTasks.putIfAbsent(empName, () => []);
        groupedTasks[empName]!.add(task);
      }
    }

    int rowIndex = 2;

    /// =================== LOOP EMPLOYEE WISE ===================
    groupedTasks.forEach((empName, tasks) {
      tasks.sort((a, b) {
        DateTime da = parseDate(a.taskDate);
        DateTime db = parseDate(b.taskDate);
        return da.compareTo(db);
      });

      sheet.appendRow(["$empName ($fromDate to $toDate)"]);

      sheet.merge(
        CellIndex.indexByString("A${rowIndex + 1}"),
        CellIndex.indexByString("I${rowIndex + 1}"),
      );

      sheet.cell(CellIndex.indexByString("A${rowIndex + 1}")).cellStyle = empStyle;

      rowIndex++;

      sheet.appendRow([
        "Task Created Date",
        "Task Title",
        "Company",
        "Task type",
        "Service Date",
        "Assigned To",
        "Created By",
        "Status",
        "Working Time",
      ]);

      for (int col = 0; col < 9; col++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex))
            .cellStyle = headerStyle;
      }
      rowIndex++;

      for (var task in tasks) {
        var hoursList = task.employeeHours.toString().split('||');
        var statusList = task.employeeStatus.toString().split('||');

        String hours = "";

        if (hoursList.isNotEmpty && hoursList.first.isNotEmpty) {
          for (var i = 0; i < hoursList.length; i++) {
            hours +=
            "${statusList[i].split("##")[0]} : ${hoursList[i] == "" ? "0 sec" : formatHours(hoursList[i].split("##")[1])} ";
          }
        }

        sheet.appendRow([
          task.taskDate ?? "-",
          task.taskTitle ?? "-",
          task.projectName ?? "-",
          task.type ?? "-",
          task.taskDate ?? "-",
          task.assignedNames ?? "-",
          task.creator ?? "-",
          task.status ?? "-",
          hours,
        ]);

        rowIndex++;
      }

      sheet.appendRow([""]);
      rowIndex++;
    });

    /// =================== COLUMN WIDTH ===================
    sheet.setColWidth(0, 22);
    sheet.setColWidth(1, 50);
    sheet.setColWidth(2, 30);
    sheet.setColWidth(3, 25);
    sheet.setColWidth(4, 18);
    sheet.setColWidth(5, 30);
    sheet.setColWidth(6, 18);
    sheet.setColWidth(7, 15);
    sheet.setColWidth(8, 15);

    /// =================== SAVE FILE ===================
    final dir = await getApplicationDocumentsDirectory();

    String filePath = "${dir.path}/Employee_Task_Report_($fromDate to $toDate).xlsx";

    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    await OpenFile.open(filePath);
  }

  Future<void> exportTaskOnlyEmployeeWiseExcel({
    required List<DTaskModel> taskList,
    required String fromDate,
    required String toDate,
    required String role,
    String? userName, // employee login name
  }) async {
    _log("### EXPORT CALLED ### tasks=${taskList.length} role=$role user=$userName");

    var excel = Excel.createExcel();
    Sheet sheet = excel["Sheet1"];

    /// null / empty na blank
    String clean(String? v) =>
        (v == null || v.trim().isEmpty || v.trim() == "null") ? "" : v.trim();

    bool hasWages(DTaskModel t) => clean(t.wagesWorkers).isNotEmpty;

    /// =================== STYLES ===================
    CellStyle titleStyle = CellStyle(
      bold: true,
      fontSize: 16,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    CellStyle headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: "#FFFF00",
      fontColorHex: "#000000",
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    CellStyle wagesHeaderStyle = CellStyle(
      bold: true,
      backgroundColorHex: "#C6EFCE",
      fontColorHex: "#000000",
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    CellStyle empStyle = CellStyle(
      bold: true,
      backgroundColorHex: "#D9E1F2",
      fontColorHex: "#000000",
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
    );

    CellStyle normalStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
    );

    /// =================== REMOVE DUPLICATE ROWS ===================
    final Set<String> seen = {};
    final List<DTaskModel> uniqueTasks = [];
    for (final t in taskList) {
      final key = [
        t.taskDate,
        t.taskTitle,
        t.projectName,
        t.type,
        t.assignedNames,
        t.creator,
        t.status,
        clean(t.wagesWorkers),
        clean(t.wagesAddedBy),
        clean(t.wagesDescription),
        clean(t.wagesHours),
        clean(t.wagesAmount),
      ].join("|");
      if (seen.add(key)) uniqueTasks.add(t);
    }
    _log("AFTER DEDUPE: ${uniqueTasks.length} (from ${taskList.length})");
    _log("TASKS WITH WAGES: ${uniqueTasks.where(hasWages).length}");

    /// =================== FILTER LIST ===================
    List<DTaskModel> filteredTasks = [];

    if (role.toString().trim() == "1") {
      filteredTasks = uniqueTasks;
    } else {
      String filter = (userName ?? "").trim().toLowerCase();

      filteredTasks = uniqueTasks.where((task) {
        String assignedNames = task.assignedNames.trim();
        if (assignedNames.isEmpty) return false;

        List<String> empList = assignedNames.split(",");

        return empList.any((e) => e.trim().toLowerCase() == filter);
      }).toList();
    }

    /// =================== WAGES COLUMNS NEEDED? ===================
    final bool anyWages = filteredTasks.any(hasWages);
    final int totalCols = anyWages ? 13 : 8;
    final String lastCol = anyWages ? "M" : "H";
    _log("AFTER FILTER: ${filteredTasks.length} | anyWages=$anyWages");

    /// =================== TOP TITLE ===================
    sheet.appendRow(["${constValue.appName} TASK REPORT DETAILS"]);
    sheet.merge(CellIndex.indexByString("A1"), CellIndex.indexByString("${lastCol}1"));
    sheet.cell(CellIndex.indexByString("A1")).cellStyle = titleStyle;

    sheet.appendRow([""]);

    /// =================== GROUP BY EMPLOYEE ===================
    Map<String, List<DTaskModel>> groupedTasks = {};

    for (var task in filteredTasks) {
      String names = task.assignedNames.isEmpty ? "Unknown" : task.assignedNames;
      List<String> empList = names.split(",");

      for (var emp in empList) {
        String empName = emp.trim();
        if (empName.isEmpty) empName = "Unknown";

        if (role.toString().trim() != "1") {
          if (empName.toLowerCase() != (userName ?? "").trim().toLowerCase()) {
            continue;
          }
        }

        groupedTasks.putIfAbsent(empName, () => []);
        groupedTasks[empName]!.add(task);
      }
    }

    if (groupedTasks.isEmpty) {
      sheet.appendRow(["No Tasks Found"]);
    }

    int rowIndex = 2;

    /// =================== LOOP EMPLOYEE WISE ===================
    groupedTasks.forEach((empName, tasks) {
      tasks.sort((a, b) {
        final wa = hasWages(a) ? 0 : 1;
        final wb = hasWages(b) ? 0 : 1;
        if (wa != wb) return wa.compareTo(wb);
        DateTime da = parseDate(a.taskDate);
        DateTime db = parseDate(b.taskDate);
        return da.compareTo(db);
      });

      sheet.appendRow(["$empName ($fromDate to $toDate)"]);

      sheet.merge(
        CellIndex.indexByString("A${rowIndex + 1}"),
        CellIndex.indexByString("$lastCol${rowIndex + 1}"),
      );

      sheet.cell(CellIndex.indexByString("A${rowIndex + 1}")).cellStyle = empStyle;

      rowIndex++;

      sheet.appendRow([
        "Task Created Date",
        "Task Title",
        "Company",
        "Task type",
        "Service Date",
        "Assigned To",
        "Created By",
        "Status",
        if (anyWages) ...[
          "Wages Workers",
          "Wages Added By",
          "Work Description",
          "Wages Hours",
          "Wages Amount (₹)",
        ],
      ]);

      for (int col = 0; col < totalCols; col++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex))
            .cellStyle = col >= 8 ? wagesHeaderStyle : headerStyle;
      }

      rowIndex++;

      for (var task in tasks) {
        final bool w = hasWages(task);

        sheet.appendRow([
          task.taskDate.isEmpty ? "-" : task.taskDate,
          task.taskTitle.isEmpty ? "-" : task.taskTitle,
          task.projectName.isEmpty ? "-" : task.projectName,
          task.type.isEmpty ? "-" : task.type,
          task.taskDate.isEmpty ? "-" : task.taskDate,
          task.assignedNames.isEmpty ? "-" : task.assignedNames,
          task.creator.isEmpty ? "-" : task.creator,
          task.status.isEmpty ? "-" : task.status,
          if (anyWages) ...[
            w ? clean(task.wagesWorkers) : "",
            w ? clean(task.wagesAddedBy) : "",
            w ? clean(task.wagesDescription) : "",
            w ? clean(task.wagesHours) : "",
            w ? clean(task.wagesAmount) : "",
          ],
        ]);

        for (int col = 0; col < totalCols; col++) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex))
              .cellStyle = normalStyle;
        }

        rowIndex++;
      }

      sheet.appendRow([""]);
      rowIndex++;
    });

    /// =================== COLUMN WIDTH ===================
    sheet.setColWidth(0, 22);
    sheet.setColWidth(1, 50);
    sheet.setColWidth(2, 30);
    sheet.setColWidth(3, 25);
    sheet.setColWidth(4, 18);
    sheet.setColWidth(5, 30);
    sheet.setColWidth(6, 18);
    sheet.setColWidth(7, 15);
    if (anyWages) {
      sheet.setColWidth(8, 45);
      sheet.setColWidth(9, 20);
      sheet.setColWidth(10, 45);
      sheet.setColWidth(11, 14);
      sheet.setColWidth(12, 18);
    }

    /// =================== SAVE FILE ===================
    final dir = await getApplicationDocumentsDirectory();

    String fileName = role.toString().trim() == "1"
        ? "All_Employee_Task_Report_($fromDate to $toDate).xlsx"
        : "${userName}_Task_Report_($fromDate to $toDate).xlsx";

    String filePath = "${dir.path}/$fileName";

    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    await OpenFile.open(filePath);
  }

  Future<void> generatePdf(List<DTaskModel> taskList, BuildContext context) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();

    /// Image Loader
    Future<pw.MemoryImage?> loadAndCompressImage(String url,
        {int maxWidth = 600, int maxHeight = 600, int quality = 50}) async {
      try {
        final response = await http.get(Uri.parse("$imageFile?path=$url"));
        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          img.Image? image = img.decodeImage(response.bodyBytes);
          if (image != null) {
            image = img.copyResize(
              image,
              width: image.width > maxWidth ? maxWidth : image.width,
              height: image.height > maxHeight ? maxHeight : image.height,
            );
            return pw.MemoryImage(img.encodeJpg(image, quality: quality));
          }
        }
      } catch (_) {}
      return null;
    }

    /// Preload Images
    Map<DTaskModel, List<pw.MemoryImage>> taskImages = {};
    for (var task in taskList) {
      final images = <pw.MemoryImage>[];
      final docs = [task.docsType1, task.docsType2, task.docsType3];

      for (var docList in docs) {
        if (docList != null && docList.isNotEmpty) {
          for (var url in docList) {
            if (url.isNotEmpty && url != "null") {
              final imgData = await loadAndCompressImage(url);
              if (imgData != null) images.add(imgData);
            }
          }
        }
      }
      taskImages[task] = images;
    }

    /// Build Task Section
    pw.Widget buildTaskSection(DTaskModel task, List<pw.MemoryImage> images) {
      List<Map<String, String>> comments = [];

      if (task.commentsFull != null && task.commentsFull!.trim().isNotEmpty) {
        final rawComments = task.commentsFull!.split("||");

        for (var c in rawComments) {
          final parts = c.split("|");

          String name = parts.isNotEmpty ? parts[0].trim() : "";
          String comment = parts.length > 1 ? parts[1].trim() : "";
          String time = parts.length > 2 ? parts[2].trim() : "";

          String date = "";
          String formattedTime = "";

          if (time.isNotEmpty) {
            final dt = DateTime.tryParse(time);
            if (dt != null) {
              date = DateFormat('dd-MM-yyyy').format(dt);
              formattedTime = DateFormat('hh:mm a').format(dt);
            }
          }

          comments.add({
            "name": name,
            "comment": comment,
            "date": date,
            "time": formattedTime,
          });
        }
      }

      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Divider(),
          pw.Text("Task Reports - ${task.taskDate}",
              style: pw.TextStyle(fontSize: 16, font: boldFont)),
          pw.SizedBox(height: 5),
          pw.Text("Task: ${task.taskTitle}", style: pw.TextStyle(font: font)),
          pw.Text("Company: ${task.projectName}", style: pw.TextStyle(font: font)),
          pw.Text("Assigned To: ${task.assignedNames}", style: pw.TextStyle(font: font)),
          pw.Text("Created By: ${task.creator}", style: pw.TextStyle(font: font)),
          pw.SizedBox(height: 10),
          if (comments.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Comments", style: pw.TextStyle(font: boldFont, fontSize: 14)),
                pw.SizedBox(height: 5),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(6),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text("Time",
                              style: pw.TextStyle(font: boldFont, fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text("Name",
                              style: pw.TextStyle(font: boldFont, fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text("Comment",
                              style: pw.TextStyle(font: boldFont, fontSize: 10)),
                        ),
                      ],
                    ),
                    ...comments.map((c) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              "${c["date"]} ${c["time"]}",
                              style: pw.TextStyle(font: font, fontSize: 9),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              c["name"] ?? "",
                              style: pw.TextStyle(font: font, fontSize: 9),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              c["comment"] ?? "",
                              style: pw.TextStyle(font: font, fontSize: 9),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          pw.SizedBox(height: 10),
          if (images.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Documents", style: pw.TextStyle(font: boldFont)),
                pw.SizedBox(height: 5),
                ...images.map((img) => pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Image(img, width: 150, height: 100),
                ))
              ],
            ),
        ],
      );
    }

    for (var task in taskList) {
      pdf.addPage(
        pw.MultiPage(
          build: (context) => [buildTaskSection(task, taskImages[task] ?? [])],
        ),
      );
    }

    Navigator.pop(context);
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  /// DATE PARSE FUNCTION (dd-MM-yyyy support)
  DateTime parseDate(String? date) {
    if (date == null || date.isEmpty) return DateTime(2000);

    try {
      return DateFormat("dd-MM-yyyy").parse(date);
    } catch (e) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        return DateTime(2000);
      }
    }
  }

  /// CREATED TS FORMAT FUNCTION (server format: 2026-04-04 17:28:11)
  String formatDate(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "-";

    try {
      DateTime dt = DateTime.parse(dateTime);
      return DateFormat("dd-MM-yyyy hh:mm a").format(dt);
    } catch (e) {
      return dateTime;
    }
  }

  // Helper to chunk large lists into smaller lists
  List<List<T>> chunkList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }

  late CalendarDataSource dataSource;

  String _year = "";
  String get year => _year;
  int total = 0;

  dynamic _defaultMonth = DateTime.now().month;
  dynamic get defaultMonth => _defaultMonth;
  String _thisMonthLeave = "0";
  String get thisMonthLeave => _thisMonthLeave;

  int _filterTasks = 0;
  int get filterTasks => _filterTasks;
  List<HolyDaysModel> _fixedLeaves = <HolyDaysModel>[];
  List<HolyDaysModel> get fixedLeaves => _fixedLeaves;

  List<TaskData> get filteredTasks {
    final month = utils.returnPadLeft(defaultMonth.toString());
    return _allTasks.where((task) {
      final dateStr = task.taskDate ?? "";
      final st = _parseTaskDate(dateStr);
      if (st == null) return false;

      final sameMonth = month == utils.returnPadLeft(st.month.toString());
      final dateMatch = (filterDate == "" || filterDate == dateStr);

      return sameMonth && dateMatch;
    }).toList();
  }

  void checkMonth(ViewChangedDetails details) {
    _filterDate = "";
    _defaultMonth = details.visibleDates[15].month;
    final month = utils.returnPadLeft(_defaultMonth.toString());
    var count = 0;
    for (var i = 0; i < _allTasks.length; i++) {
      final st = _parseTaskDate(_allTasks[i].taskDate?.toString());
      if (st == null) continue;
      if (month == utils.returnPadLeft(st.month.toString())) {
        count++;
      }
    }
    _thisMonthLeave = count.toString();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void changeMonth(dynamic value) {
    _defaultMonth = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void checkMonth2() {
    var count = 0;
    for (var i = 0; i < _allTasks.length; i++) {
      if (_filterDate == _allTasks[i].taskDate.toString()) {
        count++;
      }
    }
    _filterTasks = count;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  String _filterDate = "";
  String get filterDate => _filterDate;
  void filterDateList(String value, DateTime dateTime) {
    _filterDate = value;
    _selectedDate = dateTime;
    notifyListeners();
  }

  var _statusT;
  String _filter = "1";
  String statusId = "";
  String _statusIds = "";
  String get statusIds => _statusIds;
  int matched = 0;
  get statusT => _statusT;
  String get filter => _filter;

  void changeFilterStatus(dynamic value) {
    _status = value;
    statusId = "";
    matched = 0;
    var list = [];
    list.add(value);
    statusId = list[0]["value"];
    for (var i = 0; i < _allTasks.length; i++) {
      if (statusId == _allTasks[i].statval) {
        matched++;
      }
    }
    notifyListeners();
  }

  void changeFilter(String value) {
    _filter = value;
    notifyListeners();
  }

  void changeStatusT(String value) {
    _statusT = value;
    lStatus = value;
    notifyListeners();
  }

  void setStatus(String value) {
    for (var i = 0; i < statusList.length; i++) {
      if (statusList[i]["value"] == value) {
        statusController = GroupButtonController(selectedIndex: i);
      }
    }
    notifyListeners();
  }

  TextEditingController search = TextEditingController();
  TextEditingController search2 = TextEditingController();
  TextEditingController taskDescCont = TextEditingController();
  TextEditingController projectNameCont = TextEditingController();
  TextEditingController departmentCont = TextEditingController();
  TextEditingController projectSearchCont = TextEditingController();
  TextEditingController taskDt = TextEditingController();
  TextEditingController taskEt = TextEditingController();
  TextEditingController taskTitleCont = TextEditingController();
  List<TextEditingController> fileNameCont = <TextEditingController>[];

  void searchTask2(String value) {
    _filterTasks = 0;
    final input = value.toLowerCase();
    final suggestions = _searchAllTasks.where((user) {
      final userFName = user.projectName.toString().toLowerCase();
      final userNumber = user.assignedNames.toString().toLowerCase();
      return userFName.contains(input) || userNumber.contains(input);
    }).toList();
    _allTasks = suggestions;
    _filterTasks = _taskList.length;
    if (value.isEmpty) {
      _filterTasks = _searchAllTasks.length;
    }
    notifyListeners();
  }

  String _signPrefix = "Mr";
  String _assignedId = "";
  String _assName = "";
  String get assName => _assName;
  String _assignedNames = "";
  String get assignedNames => _assignedNames;

  String _cusId = "";
  String _cusName = "";
  String get cusId => _cusId;
  String get cusName => _cusName;
  var _title;
  var _department;
  var _type;
  String? _status;
  bool _isUpdate = false;
  String _level = "Normal";
  String _taskSDate = "";
  String _taskEDate = "";
  String _taskSTime = "";
  String _taskETime = "";
  String _changeTaskStatus = "";

  bool get isUpdate => _isUpdate;
  void updateChanges() {
    _isUpdate = true;
    notifyListeners();
  }

  String get signPrefix => _signPrefix;
  String get assignedId => _assignedId;
  get title => _title;
  get department => _department;
  get type => _type;
  String? get status => _status;
  String get level => _level;
  String get taskSDate => _taskSDate;
  String get taskEDate => _taskEDate;
  String get taskSTime => _taskSTime;
  String get taskETime => _taskETime;
  String get changeTaskStatus => _changeTaskStatus;

  var prefix = ["Mr", "Mrs", "Dr", "Ms"];
  List<String> titleList = ["Bug Report", "UI Update", "API Integration", "Issue Fix"];
  var departmentList = ["UI/UX Design", "Development", "Testing", "HR"];
  var fullStatusList = [
    "Assigned",
    "In-Queue",
    "Started",
    "On Hold",
    "New Issues",
    "Cancelled",
    "Completed"
  ];

  void changeSignPrefix(String value) {
    _signPrefix = value;
    notifyListeners();
  }

  void changedTaskStatus(String value) {
    _changeTaskStatus = value;
    notifyListeners();
  }

  Future<void> refreshCusType() async {
    _selectType = null;
    cusTypeList.clear();
    List storedLeads = await LocalDatabase.getCusTypes();
    cusTypeList = storedLeads;
    if (cusTypeList.isNotEmpty) {
      _selectType = cusTypeList[0];
    }
    notifyListeners();
  }

  void changeAssignedIs(context, List<dynamic> names) {
    List<String> ids = [];
    List<String> selectedNames = [];

    var list = Provider.of<EmployeeProvider>(context, listen: false).activeEmps;

    for (var name in names) {
      var found = list.firstWhere(
            (element) =>
        element.firstname.toString().trim().toLowerCase() ==
            name.toString().trim().toLowerCase(),
        orElse: () => UserModel(id: "0", firstname: ''),
      );

      if (found.id != "0") {
        ids.add(found.id.toString());
        selectedNames.add(found.firstname.toString());
      }
    }

    _assignedId = ids.join(",");
    _assignedNames = selectedNames.join(", ").replaceAll(".", ",");

    _log("Assigned IDs: $_assignedId");
    _log("Assigned Names: $_assignedNames");

    notifyListeners();
  }

  void changeTitle(String value) {
    _title = value;
    notifyListeners();
  }

  void changeDepartment(String value) {
    _department = value;
    notifyListeners();
  }

  void changeType(dynamic value) {
    _selectType = value;
    _type = value;
    _log("VVV $value");
    localData.storage.write("type_id", value);
    notifyListeners();
  }

  void changeCusType(dynamic value) {
    _selectType = value;
    _type = value;
    localData.storage.write("cus_type", value["id"].toString());
    localData.storage.write("cus_type", value);
    notifyListeners();
  }

  void changeStatus(dynamic value) {
    _status = value is Map ? value["id"].toString() : value.toString();
    localData.storage.write("status_id", _status);
    _log("Selected Status ID => $_status");
    notifyListeners();
  }

  void setTodayDate() {
    final now = DateTime.now();

    String formattedDate = "${now.day.toString().padLeft(2, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.year}";

    taskDt.text = formattedDate;
    taskEt.text = formattedDate;

    notifyListeners();
  }

  void setStatusByName(String value) {
    try {
      final selectedStatus = statusList.firstWhere(
            (status) =>
        status["value"].toString().trim().toLowerCase() == value.trim().toLowerCase(),
      );

      _status = selectedStatus["id"].toString();
      _log("Selected Status ID => $_status");
      localData.storage.write("status_id", _status);
      _isUpdate = false;
      notifyListeners();
    } catch (e) {
      _log("Status not found: $value");
    }
  }

  void changeLevel(String value) {
    _level = value;
    notifyListeners();
  }

  List<Map<String, dynamic>> _selectedFiles = [];

  List<Map<String, dynamic>> get selectedFiles => _selectedFiles;
  final ImagePicker picker = ImagePicker();

  /// Pick Image or File from Gallery
  Future<void> pickFile() async {
    final List<XFile> files = await picker.pickMultiImage();

    if (files.isNotEmpty) {
      for (XFile file in files) {
        final int fileSizeBytes = File(file.path).lengthSync();
        final String formattedSize = formatFileSize(fileSizeBytes);

        _selectedFiles.add({
          'name': file.name,
          'size': formattedSize,
          'path': file.path,
        });
        fileNameCont.add(TextEditingController());
      }

      notifyListeners();
    }
  }

  /// Format file size dynamically (KB or MB)
  String formatFileSize(int bytes) {
    double kb = bytes / 1024;
    if (kb < 1024) {
      return "${kb.toStringAsFixed(2)} KB";
    } else {
      double mb = kb / 1024;
      return "${mb.toStringAsFixed(2)} MB";
    }
  }

  /// Remove File from List
  void removeFile(int index) {
    _selectedFiles.removeAt(index);
    fileNameCont.removeAt(index);
    notifyListeners();
  }

  void removeVideo(int index) {
    _videos.removeAt(index);
    notifyListeners();
  }

  List<String> _assignList = [];
  List<String> get assignList => _assignList;

  final List<Map<String, dynamic>> _assignItems = [
    {'name': 'Selvi', 'selected': false},
    {'name': 'Priya Mehra', 'selected': false},
    {'name': 'Aditya Singh', 'selected': false},
    {'name': 'Meera Nair', 'selected': false},
  ];

  List<Map<String, dynamic>> get assignItems => _assignItems;

  String get selectedItemsText {
    final selectedNames =
    _assignItems.where((item) => item['selected']).map((item) => item['name']).toList();
    return selectedNames.isEmpty ? 'Select Assignees' : selectedNames.join(', ');
  }

  void toggleSelectAll(bool? isSelected) {
    for (var item in _assignItems) {
      item['selected'] = isSelected ?? false;
    }
    notifyListeners();
  }

  void toggleItem(int index, bool? isSelected) {
    _assignItems[index]['selected'] = isSelected ?? false;
    notifyListeners();
  }

  final AudioRecorder _record = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();

  String? _audioPath;
  String? _currentlyPlayingPath;
  bool _isRecording = false;
  bool _isPlaying = true;
  bool _isVedioPlaying = false;
  bool _isLoading = false;
  bool _isProjectLoading = false;
  bool _isDepartmentLoading = false;
  bool _isTaskLoading = false;
  bool _isError = false;
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void datePick({required BuildContext context, required TextEditingController date}) {
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
        date.text = formattedDate;
        notifyListeners();
      }
    });
  }

  Future<void> customTimePicker({
    required BuildContext context,
    required bool isStartTime,
  }) async {
    TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          );
        });
    if (time != null) {
      var selectedTime = _formatTime12Hour(time, context);
      if (isStartTime) {
        _taskSTime = selectedTime.toString();
      } else {
        _taskETime = selectedTime.toString();
      }
      notifyListeners();
    }
  }

  String _formatTime12Hour(TimeOfDay time, BuildContext context) {
    int hour = time.hourOfPeriod;
    String period = time.period == DayPeriod.am ? 'AM' : 'PM';

    String hourStr = hour.toString().padLeft(2, '0');
    String minuteStr = time.minute.toString().padLeft(2, '0');

    return '$hourStr:$minuteStr $period';
  }

  String? get currentlyPlayingPath => _currentlyPlayingPath;
  String? get audioPath => _audioPath;
  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  bool get isVideoPlaying => _isVedioPlaying;
  bool get isLoading => _isLoading;
  bool get isProjectLoading => _isProjectLoading;
  bool get isDepartmentLoading => _isDepartmentLoading;
  bool get isTaskLoading => _isTaskLoading;
  bool get isError => _isError;
  int _recordingDuration = 0;
  int get recordingDuration => _recordingDuration;

  List<AddAudioModel> audioList = [];
  final AudioPlayer player = AudioPlayer();
  void deleteAudio(int index) {
    audioList.removeAt(index);
    notifyListeners();
  }

  int currentIndex = -1;

  // playAudio2 subscriptions (kept so they can be cancelled -> no listener pile-up)
  StreamSubscription? _a2PosSub;
  StreamSubscription? _a2CompleteSub;

  Future<void> playAudio2(int index) async {
    try {
      AddAudioModel audio = audioList[index];

      // Pause current audio
      if (audio.play) {
        audio.position = await player.getCurrentPosition() ?? Duration.zero;

        await player.pause();

        audio.play = false;
        notifyListeners();
        return;
      }

      // Stop previous playing audio
      if (currentIndex != -1 && currentIndex != index) {
        audioList[currentIndex].play = false;
        audioList[currentIndex].position = Duration.zero;

        await player.stop();
      }

      currentIndex = index;

      // cancel old listeners BEFORE adding new ones
      await _a2PosSub?.cancel();
      await _a2CompleteSub?.cancel();

      // Play selected audio
      await player.play(
        DeviceFileSource(audio.audioPath),
        position: audio.position,
      );

      audio.play = true;

      audio.duration = await player.getDuration() ??
          Duration(milliseconds: (audio.second * 1000).toInt());

      notifyListeners();

      // Listen for completion
      _a2CompleteSub = player.onPlayerComplete.listen((event) {
        audio.play = false;
        audio.position = Duration.zero;
        notifyListeners();
      });

      // Update current position
      _a2PosSub = player.onPositionChanged.listen((position) {
        if (currentIndex == index) {
          audio.position = position;
          notifyListeners();
        }
      });
    } catch (e) {
      _log("Audio Play Error: $e");
    }
  }

  Duration _position = Duration.zero;
  Duration? _duration;

  Duration get position => _position;
  Duration? get duration => _duration;

  Timer? timer;
  late DateTime _startTime;

  final List<String> _videos = [];

  List<String> get videos => _videos;

  List<TaskData> get _taskList {
    final month = utils.returnPadLeft(defaultMonth.toString());
    return _allTasks.where((task) {
      final dateStr = task.taskDate ?? "";
      if (dateStr.isEmpty) return false;

      final st = _parseTaskDate(dateStr);
      if (st == null) return false;

      final sameMonth = month == utils.returnPadLeft(st.month.toString());
      final dateMatch = (filterDate == "" || filterDate == dateStr);

      return sameMonth && dateMatch;
    }).toList();
  }

  List<String> _projectDropList = [];
  List<DepResponse> _departmentList = [];
  List<TaskData> get taskList => _taskList;
  List<String> get projectDropList => _projectDropList;
  List<DepResponse> get serverDepartmentList => _departmentList;
  List<TaskResponse> _taskDetailsList = [];
  List<TaskResponse> get taskDetailsList => _taskDetailsList;
  List<dynamic> _userNameList = [];
  List<dynamic> get userNameList => _userNameList;

  String _recordingTime = "";
  String formatDurationTime(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    return formatTime(hours: hours, minutes: minutes, seconds: secs);
  }

  String formatTime({
    required int hours,
    required int minutes,
    required int seconds,
  }) {
    if (hours > 0) {
      return "$hours.$minutes.$seconds";
    } else if (minutes > 0) {
      return "$minutes.$seconds";
    } else {
      return "0.$seconds";
    }
  }

  Future<void> pickedVideo() async {
    final XFile? recordedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (recordedFile != null) {
      _videos.add(recordedFile.path);
    }
    notifyListeners();
  }

  Future<VideoPlayerController> initializeVideoController(String path) async {
    try {
      final controller = VideoPlayerController.file(File(path));
      await controller.initialize();
      await controller.pause();
      return controller;
    } catch (e) {
      throw "Video error";
    }
  }

  List<AddAudioModel> _recordedAudioPaths = [];
  List<AddAudioModel> get recordedAudioPaths => _recordedAudioPaths;

  Future<void> startRecording() async {
    try {
      if (_isRecording) return;

      _recordingDuration = 0;

      final dir = await getApplicationDocumentsDirectory();

      final path = "${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a";

      final permission = await _record.hasPermission();

      if (!permission) {
        debugPrint("Microphone permission denied");
        return;
      }

      await _record.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
          bitRate: 128000,
        ),
        path: path,
      );

      _isRecording = true;

      timer?.cancel();

      timer = Timer.periodic(
        const Duration(seconds: 1),
            (_) {
          if (_isRecording) {
            _recordingDuration++;
            notifyListeners();
          }
        },
      );

      notifyListeners();
    } catch (e) {
      debugPrint("Record Error: $e");
      _isRecording = false;
      timer?.cancel();
      notifyListeners();
    }
  }

  Future<void> stopRecording() async {
    if (!_isRecording) return;

    try {
      final path = await _record.stop();

      timer?.cancel();
      timer = null;

      _isRecording = false;

      if (path != null && path.isNotEmpty) {
        final audioFile = File(path);

        if (await audioFile.exists()) {
          _recordedAudioPaths.insert(
            0,
            AddAudioModel(
              audioPath: path,
              time: DateTime.now().toString(),
              second: recordingDuration.toDouble(),
              duration: Duration(seconds: recordingDuration),
            ),
          );

          _log("Recorded Audio Path: $path");
          _log("Recorded Audio Count: ${_recordedAudioPaths.length}");
        } else {
          _log("Audio file does not exist: $path");
        }
      }

      _recordingDuration = 0;
    } catch (e) {
      debugPrint("Stop Recording Error: $e");
      _isRecording = false;
      timer?.cancel();
      timer = null;
    }

    notifyListeners();
  }

  void removeAudio(int index) {
    _recordedAudioPaths.removeAt(index);
    notifyListeners();
  }

  StreamSubscription? _durationSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _completeSub;
  Future<void> playAudio(String audioPath, int index) async {
    if (audioPath.isEmpty) return;

    try {
      for (var i = 0; i < _recordedAudioPaths.length; i++) {
        _recordedAudioPaths[i].play = false;
      }

      await _durationSub?.cancel();
      await _positionSub?.cancel();
      await _completeSub?.cancel();

      await audioPlayer.stop();

      _isPlaying = true;
      _recordedAudioPaths[index].play = true;
      notifyListeners();

      _durationSub = audioPlayer.onDurationChanged.listen((durationV) {
        _recordedAudioPaths[index].duration = durationV;
        notifyListeners();
      });

      _positionSub = audioPlayer.onPositionChanged.listen((positionV) {
        _recordedAudioPaths[index].position = positionV;
        notifyListeners();
      });

      _completeSub = audioPlayer.onPlayerComplete.listen((event) {
        _isPlaying = false;
        _recordedAudioPaths[index].position = Duration.zero;
        _recordedAudioPaths[index].play = false;
        notifyListeners();
      });

      await audioPlayer.play(DeviceFileSource(audioPath));
    } catch (e) {
      _isPlaying = false;
      _recordedAudioPaths[index].play = false;
      log("Play Audio Error: $e");
      notifyListeners();
    }
  }

  Future<void> stopAudio() async {
    try {
      await audioPlayer.pause();
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      log("Stop Audio Error: $e");
    }
  }

  Future<void> loadAudioDuration(String url) async {
    try {
      await audioPlayer.setSourceUrl(url);
      Duration? fetchedDuration = await audioPlayer.getDuration();
      if (fetchedDuration != null) {
        _duration = fetchedDuration;
      }
    } catch (e) {
      // ignore
    }
    notifyListeners();
  }

  String calculateDueDays(String dateRange,
      {String? timeRange, String? updatedDate, String? status}) {
    try {
      List<String> dates = dateRange.split("||");
      DateTime endDate = DateFormat("dd-MM-yyyy").parse(dates[1].trim());

      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime taskEndDate = DateTime(endDate.year, endDate.month, endDate.day);

      if (status == "Completed") {
        String updateDateStr = updatedDate.toString();
        DateTime updateDate = DateTime.parse(updateDateStr);
        int diffDays = updateDate.difference(taskEndDate).inDays;
        if (diffDays > 0) {
          return "Completed - Extra $diffDays days";
        } else {
          return "Completed";
        }
      }

      if (taskEndDate == today && timeRange != null && timeRange.contains("||")) {
        List<String> times = timeRange.split("||");

        String endTimeStr = times[1].trim();
        if (endTimeStr.isEmpty) {
          endTimeStr = "11:59 PM";
        }

        DateTime parsedEndTime = DateFormat("hh:mm a").parse(endTimeStr);

        DateTime endTime = DateTime(
          today.year,
          today.month,
          today.day,
          parsedEndTime.hour,
          parsedEndTime.minute,
        );

        if (now.isAfter(endTime)) {
          return "Overdue";
        } else {
          int remainingMinutes = endTime.difference(now).inMinutes;
          int hours = remainingMinutes ~/ 60;
          int minutes = remainingMinutes % 60;

          return hours == 0
              ? "$minutes minutes left"
              : "$hours hours $minutes minutes left";
        }
      }

      if (taskEndDate.isBefore(today)) {
        return "Overdue";
      }

      int remainingDays = taskEndDate.difference(today).inDays;
      return "$remainingDays days left";
    } catch (e) {
      return "Invalid Input";
    }
  }

  bool _refresh = true;
  bool get refresh => _refresh;

  bool _viewRefresh = true;
  bool get viewRefresh => _viewRefresh;
  List<TaskData> _allTasks = <TaskData>[];
  List<TaskData> _searchAllTasks = <TaskData>[];
  List<TaskData> get allTasks => _allTasks;
  List<TaskData> get searchAllTasks => _searchAllTasks;
  List<UserModel> assignEmployees = [];
  List historyDetails = [];

  Future<void> getTaskUsers() async {
    _log("========== getTaskUsers() CALLED ==========");

    try {
      Map data = {
        "action": getAllData,
        "search_type": "task_users",
        "cos_id": localData.storage.read("cos_id"),
        "role": localData.storage.read("role"),
      };

      final response = await _taskRepo.getUsers(data);

      _log("Response Length: ${response.length}");

      if (response.isNotEmpty) {
        assignEmployees = [];
        assignEmployees = response;
      } else {
        assignEmployees = [];
      }
    } catch (e, stackTrace) {
      assignEmployees = [];
      _log("ERROR in getTaskUsers(): $e");
      _log(stackTrace);
    }

    notifyListeners();
  }

  Future<void> getStatusHistory(String taskId) async {
    try {
      _refresh = false;
      Map data = {
        "action": taskDatas,
        "search_type": "task_status_history",
        "cos_id": localData.storage.read("cos_id"),
        "role": localData.storage.read("role"),
        "id": localData.storage.read("id"),
        "task_id": taskId,
      };
      final response = await _taskRepo.getTasks(data);
      log(response.toString());
      if (response.isNotEmpty) {
        historyDetails = response;
        _refresh = true;
      } else {
        historyDetails = [];
        _refresh = true;
      }
    } catch (e) {
      historyDetails = [];
      _refresh = true;
      log(e.toString());
    }
    notifyListeners();
  }

  void initValue() {
    _isRecording = false;
    _selectedFiles.clear();
    _recordedAudioPaths.clear();
    selectedPhotos.clear();
    taskDescCont.clear();
    taskTitleCont.clear();

    _type = null;
    _status = null;
    _assignedId = "";
    _level = "Normal";

    if (typeList.isNotEmpty) {
      _type = typeList[0]["id"].toString();
    }

    if (statusList.isNotEmpty) {
      final match = statusList
          .where((status) => status["value"].toString().trim() == "Assigned")
          .toList();

      final selectedStatus = match.isNotEmpty ? match.first : statusList.first;

      _status = selectedStatus["id"].toString();
    }

    final now = DateTime.now();
    taskDt.text = "${now.day.toString().padLeft(2, "0")}-"
        "${now.month.toString().padLeft(2, "0")}-"
        "${now.year}";

    notifyListeners();
  }

  void initEditValue(context, TaskData data) {
    taskDescCont.text = data.taskDesc.toString();
    taskTitleCont.text = data.taskTitle.toString();
    _level = data.level.toString();
    taskDt.text = data.taskDate.toString();
    taskEt.text = data.taskTime.toString().isNotEmpty
        ? data.taskTime.toString()
        : data.taskDate.toString();
    _assignedId = data.assigned.toString();
    _assName = data.assignedNames.toString();
    _cusId = data.companyId.toString();
    _cusName = data.projectName.toString();

    _status = null;
    _type = null;

    /// STATUS
    final selectedStatus = statusList.firstWhere(
          (status) => status["value"]?.trim() == data.statval?.trim(),
      orElse: () => <String, String>{
        "id": statusList.isNotEmpty ? statusList[0]["id"]! : "",
        "value": statusList.isNotEmpty ? statusList[0]["value"]! : "",
      },
    );

    _status = selectedStatus["id"]?.toString();

    localData.storage.write("status_id", _status);

    /// TYPE
    final selectedType = typeList.firstWhere(
          (status) => status["value"] == data.type,
      orElse: () => <String, String>{
        "id": typeList.isNotEmpty ? typeList[0]["id"]! : "",
        "value": typeList.isNotEmpty ? typeList[0]["value"]! : "",
      },
    );

    _type = selectedType["id"];

    localData.storage.write("type_id", selectedType["id"]);

    changeAssignedIs(context, data.assignedNames.toString().split(","));

    notifyListeners();
  }

  Future<void> addTask({
    context,
    required String id,
  }) async {
    try {
      List<Map<String, String>> customersList = [];

      // Selected Files
      for (int i = 0; i < _selectedFiles.length; i++) {
        final filePath = _selectedFiles[i]['path'].toString();
        customersList.add({"image_$i": filePath});
      }

      // Recorded Audio
      for (int i = 0; i < _recordedAudioPaths.length; i++) {
        final int index = _selectedFiles.length + i;
        final String audioPath = _recordedAudioPaths[i].audioPath.toString();
        customersList.add({"image_$index": audioPath});
      }

      // Selected Photos
      for (int i = 0; i < selectedPhotos.length; i++) {
        final int index = _selectedFiles.length + _recordedAudioPaths.length + i;
        final String photoPath = selectedPhotos[i].toString();
        customersList.add({"image_$index": photoPath});
      }

      final String jsonString = json.encode(customersList);

      final Map<String, String> data = {
        'project_name': id,
        'task_title': taskTitleCont.text.trim(),
        'task_desc': taskDescCont.text.trim(),
        'department': departmentCont.text.trim(),
        'log_file': localData.storage.read("mobile_number").toString(),
        'type': _type.toString(),
        'assigned': assignedId.toString(),
        'level': level.toString(),
        'status': _status.toString(),
        'user_id': localData.storage.read("id").toString(),
        'task_date': taskDt.text.trim(),
        'task_time': taskEt.text.trim(),
        'action': adTask,
        'cos_id': localData.storage.read("cos_id").toString(),
        'data': jsonString,
        'version': localData.versionNumber.toString(),
      };

      debugPrint("ADD TASK DATA => $data");

      final response = await _taskRepo.addTask(data, customersList);
      log(response.toString());
      debugPrint("ADD TASK RESPONSE => $response");

      if (response.toString().contains("200")) {
        utils.showSuccessToast(
          context: context,
          text: constValue.successTask,
        );

        await _sendTaskNotifications(
          context: context,
          taskTitle: taskTitleCont.text.trim(),
          taskDesc: taskDescCont.text.trim(),
          taskDate: taskDt.text.trim(),
          taskId: "", // backend new task id return pannina inga podu
        );

        taskCtr.reset();
        getAllTask(true);

        if (!context.mounted) return;

        final homeProvider = Provider.of<HomeProvider>(context, listen: false);

        utils.navigatePage(
          context,
              () => DashBoard(
            child: ViewTask(
              date1: homeProvider.startDate,
              date2: homeProvider.endDate,
              type: homeProvider.type,
            ),
          ),
        );

        homeProvider.checkThisMonth();
        homeProvider.loadFullDashboard(context);
      } else {
        utils.showErrorToast(context: context);
        taskCtr.reset();
      }
    } catch (e) {
      debugPrint("ADD TASK ERROR => $e");
      utils.showWarningToast(context, text: e.toString());
      taskCtr.reset();
    }

    notifyListeners();
  }

  /// Task add pannina aprm notification anuppum helper
  Future<void> _sendTaskNotifications({
    required BuildContext context,
    required String taskTitle,
    required String taskDate,
    required String taskId, required String taskDesc,
  }) async {
    if (!context.mounted) return;

    try {
      final String role = localData.storage.read("role").toString();
      final String myName = localData.storage.read("f_name").toString();
      final String assignedEmployeeIds = _assignedId.toString();

      final String title = "$taskTitle by $myName";
      final String msg = "$taskTitle || $taskDate";

      debugPrint("TASK NOTIF role=$role "
          "myId=${localData.storage.read("id")} "
          "assignedIds='$assignedEmployeeIds' taskId='$taskId'");

      final empProvider = Provider.of<EmployeeProvider>(context, listen: false);

      /// 1) Assigned employee(s)-ku
      final String safeAssignedIds =
      (assignedEmployeeIds.isEmpty || assignedEmployeeIds == "null")
          ? ""
          : assignedEmployeeIds;

      if (safeAssignedIds.isNotEmpty) {
        await empProvider.sendSomeUserNotification(
          title,
          msg,
          safeAssignedIds,
          taskId,
          taskDate,
        );
      }

      /// 2) Admin(s)-ku
      final String adminIds = await empProvider.getAdminIds();

      if (adminIds.isNotEmpty) {
        await empProvider.sendSomeUserNotification(
          "$taskTitle assigned to $assignedNames",
          msg,
          adminIds,
          taskId,
          taskDate,
        );
      } else {
        debugPrint("No admin ids found, fallback to sendAdminNotification");
        await empProvider.sendAdminNotification(
          "$taskTitle assigned to $assignedNames",
          taskTitle,
          "1",
          taskId,
          role == "1" ? "1" : "",
        );
      }
    } catch (e) {
      debugPrint("Task notification error: $e");
    }
  }

  Future<void> updateTaskDetail(context,
      {required String taskId,
        required String id,
        required bool isDirect,
        required List numberList,
        required String companyName}) async {
    try {
      Map<String, String> data = {
        'id': taskId,
        'project_name': id,
        'task_title': taskTitleCont.text.trim(),
        'task_desc': taskDescCont.text.trim(),
        'department': departmentCont.text.trim(),
        'log_file': localData.storage.read("mobile_number"),
        'type': localData.storage.read("type_id"),
        'assigned': assignedId,
        'level': level,
        'status': localData.storage.read("status_id"),
        'user_id': localData.storage.read("id"),
        'task_date': taskDt.text.trim(),
        'task_time': taskEt.text.trim(),
        'action': updateTask,
        'cos_id': localData.storage.read("cos_id"),
      };
      final response = await _taskRepo.updateTask(data);
      log(response.toString());
      if (response.toString().contains("200")) {
        utils.showSuccessToast(context: context, text: constValue.updated);
        try {
          await Provider.of<EmployeeProvider>(context, listen: false)
              .sendSomeUserNotification(
            "${taskTitleCont.text.trim()} (${localData.storage.read("f_name")})",
            taskTitleCont.text.trim(),
            assignedId,
            "",
            taskDt.text.trim(),
          );
        } catch (e) {
          _log("User notification error: $e");
        }

        // admin notification (always run)
        try {
          await Provider.of<EmployeeProvider>(context, listen: false)
              .sendAdminNotification(
              "${taskTitleCont.text.trim()}(${localData.storage.read("f_name")})",
              taskTitleCont.text.trim(),
              "",
              localData.storage.read("role"),
              "");
        } catch (e) {
          _log("Admin notification error: $e");
        }
        taskCtr.reset();
        final home = Provider.of<HomeProvider>(context, listen: false);
        home.loadFullDashboard(context);
        utils.navigatePage(
          context,
              () => DashBoard(
            child: ViewTask(
              date1: home.startDate,
              date2: home.endDate,
              type: home.type,
            ),
          ),
        );
      } else {
        utils.showErrorToast(context: context);
        taskCtr.reset();
      }
    } catch (e) {
      utils.showWarningToast(context, text: "Failed");
      taskCtr.reset();
    }
    notifyListeners();
  }

  Future<void> updateLevelDetail(context, {required String id, required String level}) async {
    try {
      Map<String, String> data = {
        'id': id,
        'level': level,
        'user_id': localData.storage.read("id"),
        'action': updateLevel,
        'cos_id': localData.storage.read("cos_id"),
        'log_file': localData.storage.read("mobile_number"),
      };
      final response = await _taskRepo.updateTask(data);
      _log(data.toString());
      log(response.toString());
      if (response.toString().contains("200")) {
        utils.showSuccessToast(context: context, text: constValue.updated);
        taskCtr.reset();
        getAllTask(false);
      } else {
        utils.showErrorToast(context: context);
        taskCtr.reset();
      }
    } catch (e) {
      utils.showWarningToast(context, text: "Failed");
      taskCtr.reset();
    }
    notifyListeners();
  }

  String formatHours(String time) {
    final parts = time.split(":");

    if (parts.length != 3) return time;

    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final seconds = int.parse(parts[2]);

    List<String> result = [];

    if (hours > 0) {
      result.add("${hours}h");
    }

    if (minutes > 0) {
      result.add("${minutes}m");
    }

    if (seconds > 0) {
      result.add("${seconds}s");
    }
    return result.toString() == "null" || result.isEmpty ? "0 sec" : result.join(" ");
  }

  List<CustomerAttendanceModel> _customerAttendanceReport = <CustomerAttendanceModel>[];
  List<CustomerAttendanceModel> get customerAttendanceReport => _customerAttendanceReport;

  Future<void> getAttendance(String id) async {
    _refresh = false;
    _customerAttendanceReport.clear();
    notifyListeners();
    try {
      Map data = {
        "action": getAllData,
        "search_type": "task_visits",
        "task_id": id,
        "id": localData.storage.read("id"),
        "cos_id": localData.storage.read("cos_id"),
        "role": localData.storage.read("role"),
      };
      final response = await _taskRepo.getAttendances1(data);
      log(data.toString());
      log(response.toString());
      if (response.isNotEmpty) {
        _customerAttendanceReport = response;
        _refresh = true;
      } else {
        _refresh = true;
      }
    } catch (e) {
      _refresh = true;
    }
    notifyListeners();
  }

  Future<void> getUserTaskAttendance(String id, String date1, String date2) async {
    _refresh = false;
    _customerAttendanceReport.clear();
    notifyListeners();
    try {
      Map data = {
        "action": taskDatas,
        "search_type": "emp_visits_details",
        "id": localData.storage.read("role") == "1" ? id : localData.storage.read("id"),
        "date1": date1,
        "date2": date2,
        "cos_id": localData.storage.read("cos_id"),
        "role": localData.storage.read("role"),
      };
      final response = await _taskRepo.getAttendances(data);
      log(data.toString());
      log(response.toString());
      if (response.isNotEmpty) {
        _customerAttendanceReport = response;
        _refresh = true;
      } else {
        _refresh = true;
      }
    } catch (e) {
      _refresh = true;
    }
    notifyListeners();
  }

  Future<void> getCustomerTaskAttendance(String id, String date1, String date2) async {
    _refresh = false;
    _customerAttendanceReport.clear();
    notifyListeners();
    try {
      Map data = {
        "action": taskDatas,
        "search_type": "customer_visits_details",
        "id": id,
        "date1": date1,
        "date2": date2,
        "cos_id": localData.storage.read("cos_id"),
        "role": localData.storage.read("role"),
        "user_id": localData.storage.read("role") == "1" ? id : localData.storage.read("id"),
      };
      final response = await _taskRepo.getAttendances(data);
      log(data.toString());
      log(response.toString());
      if (response.isNotEmpty) {
        _customerAttendanceReport = response;
        _refresh = true;
      } else {
        _refresh = true;
      }
    } catch (e) {
      _refresh = true;
    }
    notifyListeners();
  }

  String crtDate(String dateTimeString, String type) {
    var parts = dateTimeString.split(' ');
    var dateParts = parts[0].split('-');
    var formattedDate = "${dateParts[2]}/${dateParts[1]}/${dateParts[0]}";

    var timeParts = parts[1].split(':');
    int hour = int.parse(timeParts[0]);
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12 == 0 ? 12 : hour % 12;

    if (type == "1") {
      return formattedDate;
    } else {
      return "$hour:${timeParts[1]} $period";
    }
  }

  Future<void> editTask(
      {context,
        required TaskData data,
        required String taskId,
        required String coId,
        required bool isDirect}) async {
    try {
      final response = await _taskRepo.updateTaskStatusApi(
          taskId: taskId, status: localData.storage.read("status_id"));
      _log(response.toString());
      if (response.toString().contains("200")) {
        utils.showSuccessToast(context: context, text: constValue.updated);
        taskStatusCtr.reset();
        Provider.of<HomeProvider>(context, listen: false).loadFullDashboard(context);
        getAllTask(false);
        getStatusHistory(data.id.toString());
      } else {
        utils.showErrorToast(context: context);
        taskStatusCtr.reset();
      }
    } catch (e) {
      utils.showWarningToast(context, text: "Failed");
      taskStatusCtr.reset();
    }
    notifyListeners();
  }

  Future<void> getAllCoTask(String coId, bool isRefresh) async {
    if (isRefresh == true) {
      _filter = "1";
      statusId = "";
      matched = 0;
      _status = null;
      search.clear();
      _allTasks.clear();
      _searchAllTasks.clear();
      _refresh = false;
    }
    notifyListeners();
    try {
      Map data = {
        "action": taskDatas,
        "search_type": "co_tasks",
        "co_id": coId,
        "cos_id": localData.storage.read("cos_id"),
        "role": localData.storage.read("role"),
        "id": localData.storage.read("id")
      };
      final response = await _taskRepo.getReport(data);
      if (response.isNotEmpty) {
        _allTasks = response;
        _searchAllTasks = response;
        _refresh = true;
      }
    } catch (e) {
      _allTasks = [];
      _searchAllTasks = [];
      _refresh = true;
    }
    notifyListeners();
  }

  String _profile = "";
  String get profile => _profile;
  Future<void> signDialog(
      {required BuildContext context,
        required String img,
        required Function(String newImg) onTap}) async {
    _profile = "";
    var imgData = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const CameraWidget(
              cameraPosition: CameraType.front,
              isSelfie: true,
            )));
    if (!context.mounted) return;
    if (imgData != null) {
      final compressedFile = await compressImage(imgData);
      onTap(compressedFile.path);
    }
  }

  Future<XFile> compressImage(String filePath) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.absolute.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      targetPath,
      quality: 70,
    );

    return result!;
  }

  void profilePick(String imgData) {
    _profile = imgData;
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

  String _checkAtt = "";
  String _checkAttName = "";
  String get checkAtt => _checkAtt;
  String get checkAttName => _checkAttName;
  List<TaskData> _filterUserData = <TaskData>[];
  List<TaskData> get filterUserData => _filterUserData;

  Future<void> getAllTask(bool isRefresh, {String? date1, String? date2, String? type}) async {
    _log("=====  getAllTask START =====");
    _incompleteMode = false;
    _checkAtt = "";
    _checkAttName = "";

    if (isRefresh == true) {
      _filter = "1";
      statusId = "";
      matched = 0;
      _filterDate = "";
      _filterTasks = 0;
      _status = null;

      search.clear();
      search2.clear();

      _allTasks.clear();
      _searchAllTasks.clear();
      _filterUserData.clear();

      dataSource.appointments!.clear();

      _viewRefresh = false;
    }

    try {
      Map data = {
        "action": taskDatas,
        "search_type": "all_tasks",
        "cos_id": localData.storage.read("cos_id"),
        "role": localData.storage.read("role"),
        "id": localData.storage.read("id"),
      };

      final response = await _taskRepo.getReport(data);

      if (response.isNotEmpty) {
        _allTasks = response;
        _searchAllTasks = response;
        _filterUserData = response;

        _log("_allTasks length : ${_allTasks.length}");

        // collect appointments, add + notify ONCE after the loop
        final List<Appointment> newApps = [];
        final monthPad = utils.returnPadLeft(defaultMonth.toString());

        for (var i = 0; i < response.length; i++) {
          String? dateStr = response[i].taskDate;

          // TIMER SETUP
          String id = response[i].id.toString();
          int totalSeconds = int.tryParse(response[i].totalHours.toString()) ?? 0;
          String status = response[i].workStatus.toString();

          taskTimers[id] = TaskTimer(
            accumulatedSeconds: totalSeconds,
            isRunning: status == "Start",
            startTime: status == "Start" ? DateTime.now() : null,
            isCompleted: (status == "Completed" || status == "Complete"),
          );

          if (status == "Start") {
            _startUiTicker();
          }

          // EMPTY / INVALID DATE SKIP
          final parsedDate = _parseTaskDate(dateStr);
          if (parsedDate == null) continue;

          newApps.add(Appointment(
            startTime: parsedDate,
            endTime: parsedDate,
            subject: response[i].statval.toString(),
            color: colorsConst.red2,
          ));

          if (monthPad == utils.returnPadLeft(parsedDate.month.toString())) {
            _thisMonthLeave = "1";
          }
        }

        if (newApps.isNotEmpty) {
          dataSource.appointments!.addAll(newApps);
          dataSource.notifyListeners(CalendarDataSourceAction.add, newApps);
        }

        /// CHECKED TASK
        for (var i = 0; i < response.length; i++) {
          if (response[i].isChecked.toString() == "1") {
            _checkAtt = response[i].id.toString();
            _checkAttName = response[i].projectName.toString();
            break;
          }
        }

        filterList();
        _viewRefresh = true;
      }
    } catch (e) {
      _allTasks = [];
      _searchAllTasks = [];
      _filterUserData = [];

      _checkAtt = "";
      _checkAttName = "";

      _viewRefresh = true;
    }

    _log("===== getAllTask END =====");

    notifyListeners();
  }

  Future<void> getAllIncompleteTask(bool isRefresh,
      {String? date1, String? date2, String? type}) async {
    _incompleteMode = true; // date filter skip panna

    _checkAtt = "";
    _checkAttName = "";

    if (isRefresh == true) {
      _filter = "1";
      statusId = "";
      matched = 0;
      _filterDate = "";
      _filterTasks = 0;
      _status = null;

      search.clear();
      search2.clear();

      _allTasks.clear();
      _searchAllTasks.clear();
      _filterUserData.clear();

      dataSource.appointments!.clear();

      _viewRefresh = false;
    }

    try {
      Map data = {
        "action": taskDatas,
        "search_type": "all_incomplete_tasks",
        "cos_id": localData.storage.read("cos_id"),
        "role": localData.storage.read("role"),
        "id": localData.storage.read("id"),
      };

      // ---------- OFFLINE SAVE LOGIC START ----------
      final cacheKey = "incomplete_${data['cos_id']}_${data['id']}_${data['role']}";
      List<TaskData> response = [];

      // 1. Net irundha server la irundhu edu, phone la save pannu
      try {
        response = await _taskRepo.getReport(data);
        if (response.isNotEmpty) {
          localData.storage.write(
            cacheKey,
            jsonEncode(response.map((e) => e.toJson()).toList()),
          );
        }
      } catch (e) {
        _log("Server error (offline?): $e");
      }

      // 2. Net illa / response empty na, save panna data edu
      if (response.isEmpty) {
        final saved = localData.storage.read(cacheKey);
        if (saved != null) {
          response = (jsonDecode(saved) as List)
              .map((e) => TaskData.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
      // ---------- OFFLINE SAVE LOGIC END ----------

      if (response.isNotEmpty) {
        response = List<TaskData>.from(response)
          ..sort((a, b) => b.createdTs.toString().compareTo(a.createdTs.toString()));

        _allTasks = response;
        _searchAllTasks = response;
        _filterUserData = response;

        final List<Appointment> newApps = [];
        final monthPad = utils.returnPadLeft(defaultMonth.toString());

        for (var i = 0; i < response.length; i++) {
          String? dateStr = response[i].taskDate;

          // TIMER SETUP
          String id = response[i].id.toString();
          int totalSeconds = int.tryParse(response[i].totalHours.toString()) ?? 0;
          String status = response[i].workStatus.toString();

          taskTimers[id] = TaskTimer(
            accumulatedSeconds: totalSeconds,
            isRunning: status == "Start",
            startTime: status == "Start" ? DateTime.now() : null,
            isCompleted: (status == "Completed" || status == "Complete"),
          );

          if (status == "Start") {
            _startUiTicker();
          }

          // EMPTY / INVALID DATE SKIP
          final parsedDate = _parseTaskDate(dateStr);
          if (parsedDate == null) continue;

          newApps.add(Appointment(
            startTime: parsedDate,
            endTime: parsedDate,
            subject: response[i].statval.toString(),
            color: colorsConst.red2,
          ));

          if (monthPad == utils.returnPadLeft(parsedDate.month.toString())) {
            _thisMonthLeave = "1";
          }
        }

        if (newApps.isNotEmpty) {
          dataSource.appointments!.addAll(newApps);
          dataSource.notifyListeners(CalendarDataSourceAction.add, newApps);
        }

        // CHECKED TASK
        for (var i = 0; i < response.length; i++) {
          if (response[i].isChecked.toString() == "1") {
            _checkAtt = response[i].id.toString();
            _checkAttName = response[i].projectName.toString();
            break;
          }
        }

        filterList();
        _viewRefresh = true;
      } else {
        // Server um empty, cache um illa -> loading nikkaama irukka
        _viewRefresh = true;
      }
    } catch (e) {
      _allTasks = [];
      _searchAllTasks = [];
      _filterUserData = [];

      _checkAtt = "";
      _checkAttName = "";

      _viewRefresh = true;
    }

    notifyListeners();
  }

  List<TaskData> _userAllTasks = <TaskData>[];
  List<TaskData> get userAllTasks => _userAllTasks;

  Future<void> getUserTasks(String id, String date1, String date2) async {
    _filter = "1";
    statusId = "";
    matched = 0;
    _filterDate = "";
    _filterTasks = 0;
    _status = null;
    _userAllTasks.clear();
    _viewRefresh = false;
    notifyListeners();
    try {
      Map data = {
        "action": taskDatas,
        "search_type": "emp_tasks_details",
        "cos_id": localData.storage.read("cos_id"),
        "role": localData.storage.read("role"),
        "id": localData.storage.read("role") == "1" ? id : localData.storage.read("id"),
        "date1": date1,
        "date2": date2
      };
      final response = await _taskRepo.getReport(data);
      if (response.isNotEmpty) {
        _userAllTasks = response;
        _viewRefresh = true;
      }
    } catch (e) {
      _userAllTasks = [];
      _viewRefresh = true;
    }
    notifyListeners();
  }

  Future<void> getCustomerTasks(String id, String date1, String date2) async {
    _filter = "1";
    statusId = "";
    matched = 0;
    _filterDate = "";
    _filterTasks = 0;
    _status = null;
    _userAllTasks.clear();
    _viewRefresh = false;
    notifyListeners();
    try {
      Map data = {
        "action": taskDatas,
        "search_type": "customer_tasks_details",
        "cos_id": localData.storage.read("cos_id"),
        "role": localData.storage.read("role"),
        "user_id": localData.storage.read("role") == "1" ? id : localData.storage.read("id"),
        "id": id,
        "date1": date1,
        "date2": date2
      };
      final response = await _taskRepo.getReport(data);
      if (response.isNotEmpty) {
        _userAllTasks = response;
        _viewRefresh = true;
      }
    } catch (e) {
      _userAllTasks = [];
      _viewRefresh = true;
    }
    notifyListeners();
  }

  Future<void> taskAttDirect(context,
      {required String status,
        required String lat,
        required String lng,
        required String taskId}) async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Center(
                child: Column(
                  children: [
                    const CustomText(
                      text: "Marking Please Wait",
                      colors: Colors.grey,
                      size: 15,
                      isBold: true,
                    ),
                    20.height,
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: colorsConst.primary,
                      size: 25,
                    ),
                  ],
                ),
              ),
            );
          });
      Map<String, String> data = {
        "action": taskAtt,
        "log_file": localData.storage.read("mobile_number"),
        "line_id": "0",
        "line_customer_id": taskId,
        "salesman_id": localData.storage.read("id"),
        "self_img_count": "0",
        "comp_img_count": "0",
        "collection_amt": "0",
        "sales_amt": "0",
        "is_checked_out": status,
        "lat": lat,
        "lng": lng,
        "traveled_kms": "0.0",
        "id": localData.storage.read("tk_id").toString(),
        "cos_id": localData.storage.read("cos_id"),
      };
      final response = await _taskRepo.addAttendance(data, _profile);
      if (response.isNotEmpty) {
        localData.storage.write("tk_id", response[0]["id"]);
        utils.showSuccessToast(
            text: status == "1" ? "Check In Successful" : "Check Out Successful",
            context: context);
        getAllTask(false);
        Navigator.of(context, rootNavigator: true).pop();
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        utils.showErrorToast(context: context);
        notifyListeners();
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      log(e.toString());
      utils.showErrorToast(context: context);
    } finally {
      notifyListeners();
    }
  }

  Future<void> taskAttendance(context,
      {required String status,
        required String taskId,
        required String coId,
        required String lat,
        required String lng}) async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Center(
                child: Column(
                  children: [
                    const CustomText(
                      text: "Marking Please Wait",
                      colors: Colors.grey,
                      size: 15,
                      isBold: true,
                    ),
                    20.height,
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: colorsConst.primary,
                      size: 25,
                    ),
                  ],
                ),
              ),
            );
          });
      Map<String, String> data = {
        "action": taskAtt,
        "log_file": localData.storage.read("mobile_number"),
        "line_id": "0",
        "line_customer_id": taskId,
        "salesman_id": localData.storage.read("id"),
        "self_img_count": "0",
        "comp_img_count": "0",
        "collection_amt": "0",
        "sales_amt": "0",
        "is_checked_out": status,
        "lat": lat,
        "lng": lng,
        "traveled_kms": "0.0",
        "id": localData.storage.read("tk_id"),
        "cos_id": localData.storage.read("cos_id"),
      };
      final response = await _taskRepo.addAttendance(data, _profile);
      log(response.toString());
      if (response.isNotEmpty) {
        localData.storage.write("tk_id", response[0]["id"]);
        utils.showSuccessToast(
            text: status == "1" ? "Check In Successful" : "Check Out Successful",
            context: context);
        getAllCoTask(coId, false);
        Navigator.of(context, rootNavigator: true).pop();
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        utils.showErrorToast(context: context);
      }
    } catch (e) {
      log(e.toString());
      Navigator.of(context, rootNavigator: true).pop();
      utils.showErrorToast(context: context);
    }
    notifyListeners();
  }

  var typeList = [];
  var customerList = [];
  var cusTypeList = [];
  var statusList = [];

  bool _addRefresh = true;
  bool get addRefresh => _addRefresh;
  dynamic _selectType;
  dynamic get selectType => _selectType;
  dynamic _selectType1;
  dynamic get selectType1 => _selectType1;

  void changeTypeValue(dynamic value) {
    _selectType = null;
    _selectType = value;
    var list = [];
    list.add(value);
    localData.storage.write("type_id", list[0]["id"]);
    localData.storage.write("typeName", list[0]["value"]);

    notifyListeners();
  }

  String? typeId;
  String? typeName;

  void changeTypeValue1(Object? value) {
    if (value == null) return;

    final selected = typeList.firstWhere(
          (e) => e['id'].toString() == value.toString(),
      orElse: () => <String, String>{},
    );

    if (selected.isEmpty) {
      _log("Type not found");
      return;
    }

    _selectType = selected;

    localData.storage.write("type_id", selected["id"].toString());

    _log("Saved TYPE ID => ${selected["id"]}");

    notifyListeners();
  }

  Future<void> getTaskType(bool isRefresh) async {
    try {
      _selectType = null;

      if (isRefresh == true) {
        _addRefresh = false;
        notifyListeners();
      }

      Map data = {
        "action": getAllData,
        "search_type": "cmt_type",
        "cat_id": "7",
        "cos_id": localData.storage.read("cos_id")
      };

      final response = await _taskRepo.getListDatas(data);

      log("Data => ${data.toString()}");
      log("Response task list=> ${response.toString()}");

      if (response.isNotEmpty) {
        List<Map<String, String>> list = response
            .map((e) => {
          "id": e['id'].toString(),
          "value": e['value'].toString().trim(),
          "categories": e['categories'].toString(),
          "created_ts": e['created_ts'].toString(),
          "created_by": e['created_by'].toString(),
        })
            .toList();

        if (!kIsWeb) {
          await LocalDatabase.insertTaskType(list);
          getAllTypes();
        } else {
          typeList.clear();
          typeList = list;
          if (typeList.isNotEmpty) {
            changeType(typeList.first["id"].toString());
          }
          _addRefresh = true;
          notifyListeners();
        }
      } else {
        _addRefresh = true;
      }
    } catch (e) {
      _addRefresh = true;
    }

    notifyListeners();
  }

  Future<void> getCustomerType(bool isRefresh) async {
    try {
      _selectType = null;

      if (isRefresh == true) {
        _addRefresh = false;
        notifyListeners();
      }

      Map data = {
        "action": getAllData,
        "search_type": "cus_type",
        "cat_id": "12",
        "cos_id": localData.storage.read("cos_id")
      };

      final response = await _taskRepo.getListDatas(data);

      log("Data => ${data.toString()}");
      log("Response task list=> ${response.toString()}");

      if (response.isNotEmpty) {
        List<Map<String, String>> list = response
            .map((e) => {
          "id": e['id'].toString(),
          "value": e['value'].toString().trim(),
          "categories": e['categories'].toString(),
          "created_ts": e['created_ts'].toString(),
          "created_by": e['created_by'].toString(),
        })
            .toList();
        if (!kIsWeb) {
          await LocalDatabase.insertCusType(list);
          getAllCusTypes();
        } else {
          cusTypeList.clear();
          cusTypeList = list;
          _addRefresh = true;
          notifyListeners();
        }
      } else {
        _addRefresh = true;
      }
    } catch (e) {
      _addRefresh = true;
    }

    notifyListeners();
  }

  TextEditingController typeCtr = TextEditingController();

  Future<void> getTaskStatuses() async {
    try {
      Map data = {
        "action": getAllData,
        "search_type": "cmt_type",
        "cat_id": "8",
        "cos_id": localData.storage.read("cos_id")
      };

      final response = await _taskRepo.getListDatas(data);

      log("Task status ${response.toString()}");

      if (response.isNotEmpty) {
        List<Map<String, String>> list = response
            .map<Map<String, String>>((e) => {
          "id": e['id'].toString(),
          "value": e['value'].toString(),
          "categories": e['categories'].toString(),
        })
            .toList();

        /// always update provider list
        statusList = list;

        _log("STATUS LIST $statusList");

        /// save offline
        if (!kIsWeb) {
          await LocalDatabase.insertTaskStatus(list);
        }

        notifyListeners();
      }
    } catch (e) {
      _log("STATUS ERROR $e");
    }
  }

  Future<void> getAllTypes() async {
    typeList.clear();
    List storedLeads = await LocalDatabase.getTaskTypes();
    typeList = storedLeads;
    _addRefresh = true;
    _selectType = null;
    notifyListeners();
  }

  Future<void> refreshTypes() async {
    _type = null;
    typeList.clear();
    List storedLeads = await LocalDatabase.getTaskTypes();
    typeList = storedLeads;
    notifyListeners();
  }

  Future<void> getTypeSts() async {
    statusList.clear();
    List storedLeads = await LocalDatabase.getTaskStatus();
    statusList = storedLeads;
    notifyListeners();
  }

  Future<void> refreshStatus() async {
    _status = null;
    statusList.clear();
    List storedLeads = await LocalDatabase.getTaskStatus();
    statusList = storedLeads;
    notifyListeners();
  }

  Future<void> getAllCusTypes() async {
    cusTypeList.clear();

    List storedLeads = await LocalDatabase.getCusTypes();
    cusTypeList = storedLeads;

    _addRefresh = true;

    if (cusTypeList.isNotEmpty) {
      _selectType ??= cusTypeList[0];
    }

    notifyListeners();
  }

  Future<void> refreshCusTypes() async {
    _type = null;
    cusTypeList.clear();
    List storedLeads = await LocalDatabase.getCusTypes();
    cusTypeList = storedLeads;
    notifyListeners();
  }

  Future<void> fetchUserNameList() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _taskRepo.getUserNames();
      if (response["ResponseCode"].toString() == "200") {
        List<dynamic> data = response["Response"] ?? [];
        _userNameList = data;
        _assignList = [];
        _assignList = _userNameList.map((e) => e["f_name"].toString()).toList();
      } else {
        _userNameList = [];
      }
    } catch (e) {
      _userNameList = [];
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// CHART
  String _totalCount = "";
  String _pendingCount = "";
  String _completedCount = "";
  String _overdueCount = "";
  double _pendingCountPer = 0.0;
  double _completedCountPer = 0.0;
  double _overdueCountPer = 0.0;
  bool _isDashboardLoading = false;

  String get totalCount => _totalCount;
  String get pendingCount => _pendingCount;
  String get completedCount => _completedCount;
  String get overdueCount => _overdueCount;
  double get pendingCountPer => _pendingCountPer;
  double get completedCountPer => _completedCountPer;
  double get overdueCountPer => _overdueCountPer;
  bool get isDashboardLoading => _isDashboardLoading;

  Future<void> fetchTaskCount() async {
    _isDashboardLoading = true;
    notifyListeners();
    try {
      final response = await _taskRepo.getDashboardCount();
      if (response["ResponseCode"].toString() == "200") {
        List<dynamic> data = response["Response"] ?? [];
        _totalCount = data[0]["total_count"];
        _pendingCount = data[0]["pending_count"];
        _completedCount = data[0]["complete_count"];
        _overdueCount = data[0]["overdue_count"];
        double total = double.tryParse(_totalCount) ?? 1;
        double completed = double.tryParse(_completedCount) ?? 0;
        double pending = double.tryParse(_pendingCount) ?? 0;
        double overdue = double.tryParse(_overdueCount) ?? 0;
        _completedCountPer = (completed / total) * 100;
        _pendingCountPer = (pending / total) * 100;
        _overdueCountPer = (overdue / total) * 100;
        notifyListeners();
      } else {
        _totalCount = "0";
        _pendingCount = "0";
        _completedCount = "0";
        _overdueCount = "0";
      }
      notifyListeners();
    } catch (e) {
      _totalCount = "0";
      _pendingCount = "0";
      _completedCount = "0";
      _overdueCount = "0";
      notifyListeners();
    } finally {
      _isDashboardLoading = false;
      notifyListeners();
    }
  }

  /// copy of customer add visit page
  final List<String> _selectedPhotos = [];

  List<String> get selectedPhotos => _selectedPhotos;

  Future<void> pickCamera(BuildContext context) async {
    var imgData = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const CameraWidget(
              cameraPosition: CameraType.back,
            )));
    _selectedPhotos.add(imgData);
    notifyListeners();
  }

  void removePhotos(int index) {
    _selectedPhotos.removeAt(index);
    notifyListeners();
  }

  final AudioRecorder record = AudioRecorder();

  bool isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && (uri.hasScheme && uri.hasAuthority);
  }

  String formatDuration(Duration d) {
    String minutes = d.inMinutes.toString().padLeft(2, '0');
    String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> insertTaskType(context) async {
    try {
      Map<String, String> data = {
        "action": addTaskType,
        "meta_id": "7",
        "value": typeCtr.text.trim(),
        "created_by": localData.storage.read("id"),
        "platform": localData.storage.read("platform").toString(),
        "cos_id": localData.storage.read("cos_id").toString(),
        "log_file": localData.storage.read("mobile_number").toString(),
      };
      final response = await _taskRepo.addType(data);
      _log(data.toString());
      _log(response.toString());
      if (response.toString().contains("This type already exits")) {
        utils.showWarningToast(context, text: "This type already exits");
        taskCtr.reset();
      } else if (response["status_code"] == 200) {
        utils.showSuccessToast(context: context, text: constValue.success);
        getTaskType(true);
        Navigator.pop(context);
        taskCtr.reset();
      } else {
        utils.showErrorToast(context: context);
        taskCtr.reset();
      }
    } catch (e) {
      log(e.toString());
      utils.showErrorToast(context: context);
      taskCtr.reset();
    }
    notifyListeners();
  }

  void deleteType(context, String id) async {
    try {
      Map data = {
        "action": delete,
        "ops": "type",
        "id": id,
        "meta_id": "7",
        "updated_by": localData.storage.read("id"),
        "platform": localData.storage.read("platform"),
        "cos_id": localData.storage.read("cos_id"),
      };
      final response = await _taskRepo.addType(data);
      if (response["status_code"] == 200) {
        utils.showSuccessToast(context: context, text: constValue.deleted);
        if (!kIsWeb) {
          await LocalDatabase.deleteTaskTypeById(id);
        }
        getTaskType(false);
        Navigator.pop(context);
        taskCtr.reset();
      } else {
        utils.showErrorToast(context: context);
        taskCtr.reset();
      }
    } catch (e) {
      utils.showErrorToast(context: context);
      taskCtr.reset();
    }
    notifyListeners();
  }

  bool isAssignedDisabled = false;
  bool isStartedDisabled = false;
  bool isCompletedDisabled = false;

  void updateDisableStatus(String currentStatus) {
    isAssignedDisabled = false;
    isStartedDisabled = false;
    isCompletedDisabled = false;

    if (currentStatus == "Assigned") {
      isAssignedDisabled = true;
    } else if (currentStatus == "Started") {
      isAssignedDisabled = true;
      isStartedDisabled = true;
    } else if (currentStatus == "Completed") {
      isAssignedDisabled = true;
      isStartedDisabled = true;
      isCompletedDisabled = true;
    }
  }

  String selectedStatusValue = "Assigned";

  Color getButtonColor(String status, bool isSelected) {
    if (isSelected) {
      if (status == "Assigned") return Colors.orange;
      if (status == "Started") return Colors.blue;
      if (status == "Completed") return Colors.green;
    }
    return Colors.white;
  }

  Color getBorderColor(String status) {
    if (status == "Assigned") return Colors.orange;
    if (status == "Started") return Colors.blue;
    if (status == "Completed") return Colors.green;
    return Colors.grey;
  }

  Color getTextColor(String status, bool isSelected) {
    if (isSelected) return Colors.white;

    if (status == "Assigned") return Colors.orange;
    if (status == "Started") return Colors.blue;
    if (status == "Completed") return Colors.green;

    return Colors.black;
  }

  String currentStatus = "Assigned"; // default

  bool isButtonDisabled(String status) {
    if (currentStatus == "Assigned") {
      return status == "Assigned";
    }

    if (currentStatus == "Started") {
      return status == "Assigned" || status == "Started";
    }

    if (currentStatus == "Completed") {
      return true;
    }

    return false;
  }

  Color getStatusColor(String status) {
    if (status == "Assigned") return Colors.orange;
    if (status == "Started") return Colors.blue;
    if (status == "Completed") return Colors.green;
    return colorsConst.primary;
  }

  /// holds data AFTER date/status filter applied, BEFORE search applied
  List<TaskData> _filteredBeforeSearch = [];

  void updateFilteredBeforeSearch(List<TaskData> dateFilteredList) {
    _filteredBeforeSearch = dateFilteredList;
    searchTask(search.text);
  }

  /// searchTask — searches within _filteredBeforeSearch, NOT _allTasks
  void searchTask(String value) {
    final input = value.toLowerCase();

    if (value.trim().isEmpty) {
      _filterUserData = List.from(_filteredBeforeSearch);
    } else {
      final suggestions = _filteredBeforeSearch.where((user) {
        final userFName = user.projectName.toString().toLowerCase();
        final userNumber = user.assignedNames.toString().toLowerCase();

        return userFName.contains(input) || userNumber.contains(input);
      }).toList();

      _filterUserData = suggestions;
    }

    notifyListeners();
  }
  void selectEmployeeFilter(UserModel value) {
    _assignedNames = value.firstname.toString();
    notifyListeners();
  }
  /// Call this whenever date filter / status tab changes
  void applyDateAndStatusFilter() {
    List<TaskData> baseList = List<TaskData>.from(allTasks);

    /// ---- DATE FILTER ----
    if (isFilter == true) {
      DateTime? from;
      DateTime? to;
      try {
        final f = _df.parse(startDate);
        final t = _df.parse(endDate);
        from = DateTime(f.year, f.month, f.day);
        to = DateTime(t.year, t.month, t.day);
      } catch (_) {}

      baseList = baseList.where((task) {
        if (from == null || to == null) return false;
        final taskDate = _parseTaskDate(task.taskDate.toString());
        if (taskDate == null) return false;
        final taskOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);
        return (taskOnly.isAtSameMomentAs(from) || taskOnly.isAfter(from)) &&
            (taskOnly.isAtSameMomentAs(to) || taskOnly.isBefore(to));
      }).toList();
    } else {
      final today = DateTime.now();
      baseList = baseList.where((task) {
        final taskDate = _parseTaskDate(task.taskDate.toString());
        if (taskDate == null) return false;
        return taskDate.year == today.year &&
            taskDate.month == today.month &&
            taskDate.day == today.day;
      }).toList();
    }

    /// ---- STATUS TAB FILTER ----
    if (statusIds.isNotEmpty) {
      baseList = baseList.where((task) => task.statval.toString() == statusIds).toList();
    }

    _filteredBeforeSearch = baseList;

    /// ---- RE-APPLY SEARCH TEXT ----
    if (search.text.trim().isNotEmpty) {
      searchTask(search.text.trim());
    } else {
      _filterUserData = List<TaskData>.from(_filteredBeforeSearch);
      notifyListeners();
    }
  }

  Future<void> editTaskType(context, String id) async {
    try {
      Map<String, String> data = {
        "action": updateTaskType,
        "id": id,
        "meta_id": "7",
        "value": typeCtr.text.trim(),
        "created_by": localData.storage.read("id"),
        "platform": localData.storage.read("platform").toString(),
        "cos_id": localData.storage.read("cos_id").toString(),
        "log_file": localData.storage.read("mobile_number").toString(),
      };
      final response = await _taskRepo.addType(data);
      _log(data.toString());
      _log(response.toString());
      if (response.toString().contains("This type already exits")) {
        utils.showWarningToast(context, text: "This type already exits");
        taskCtr.reset();
      } else if (response["status_code"] == 200) {
        utils.showSuccessToast(context: context, text: constValue.updated);
        getTaskType(true);
        Navigator.pop(context);
        taskCtr.reset();
      } else {
        utils.showErrorToast(context: context);
        taskCtr.reset();
      }
    } catch (e) {
      log(e.toString());
      utils.showErrorToast(context: context);
      taskCtr.reset();
    }
    notifyListeners();
  }

  Future<void> insertTaskStatus(context) async {
    try {
      Map<String, String> data = {
        "action": addTaskType,
        "meta_id": "8",
        "value": typeCtr.text.trim(),
        "created_by": localData.storage.read("id"),
        "platform": localData.storage.read("platform").toString(),
        "cos_id": localData.storage.read("cos_id").toString(),
        "log_file": localData.storage.read("mobile_number").toString(),
      };
      final response = await _taskRepo.addType(data);
      _log(data.toString());
      _log(response.toString());
      if (response.toString().contains("already exits")) {
        utils.showWarningToast(context, text: "This status already exits");
        taskCtr.reset();
      } else if (response["status_code"] == 200) {
        utils.showSuccessToast(context: context, text: constValue.success);
        getTaskStatuses();
        Navigator.pop(context);
        taskCtr.reset();
      } else {
        utils.showErrorToast(context: context);
        taskCtr.reset();
      }
    } catch (e) {
      log(e.toString());
      utils.showErrorToast(context: context);
      taskCtr.reset();
    }
    notifyListeners();
  }

  void deleteStatus(context, String id) async {
    try {
      Map data = {
        "action": delete,
        "ops": "type",
        "id": id,
        "meta_id": "8",
        "updated_by": localData.storage.read("id"),
        "platform": localData.storage.read("platform"),
        "cos_id": localData.storage.read("cos_id"),
      };
      final response = await _taskRepo.addType(data);
      if (response["status_code"] == 200) {
        utils.showSuccessToast(context: context, text: constValue.deleted);
        if (!kIsWeb) {
          await LocalDatabase.deleteTaskStatusById(id);
        }
        getTaskStatuses();
        getTypeSts();
        Navigator.pop(context);
        taskCtr.reset();
      } else {
        utils.showErrorToast(context: context);
        taskCtr.reset();
      }
    } catch (e) {
      utils.showErrorToast(context: context);
      taskCtr.reset();
    }
    notifyListeners();
  }

  Future<void> editTaskStatus(context, String id) async {
    try {
      Map<String, String> data = {
        "action": updateTaskType,
        "id": id,
        "meta_id": "8",
        "value": typeCtr.text.trim(),
        "created_by": localData.storage.read("id"),
        "platform": localData.storage.read("platform").toString(),
        "cos_id": localData.storage.read("cos_id").toString(),
        "log_file": localData.storage.read("mobile_number").toString(),
      };
      final response = await _taskRepo.addType(data);
      _log(data.toString());
      _log(response.toString());
      if (response.toString().contains("already exits")) {
        utils.showWarningToast(context, text: "This status already exits");
        taskCtr.reset();
      } else if (response["status_code"] == 200) {
        utils.showSuccessToast(context: context, text: constValue.updated);
        getTaskStatuses();
        Navigator.pop(context);
        taskCtr.reset();
      } else {
        utils.showErrorToast(context: context);
        taskCtr.reset();
      }
    } catch (e) {
      log(e.toString());
      utils.showErrorToast(context: context);
      taskCtr.reset();
    }
    notifyListeners();
  }

  Future<void> getAdminUsers() async {
    try {
      Map data = {
        "action": getAllData,
        "search_type": "admin_users",
        "cos_id": localData.storage.read("cos_id"),
      };

      final response = await _taskRepo.getAdminUsers(data);

      _log("ADMIN RESPONSE LENGTH: ${response.length}");

      if (response.isNotEmpty) {
        List<String> adminIds =
        response.map<String>((user) => user["id"].toString()).toList();

        await localData.storage.write("admin_ids", adminIds);

        _log("SAVED ADMIN IDS: ${localData.storage.read("admin_ids")}");
      } else {
        _log("No admin users found");
      }
    } catch (e) {
      _log("Get Users Error: $e");
    }

    notifyListeners();
  }

  // ===========================================================================
  // TASK TIMERS
  // ===========================================================================
  Map<String, TaskTimer> taskTimers = {};
  Timer? _uiTicker;

  /// Ticks every second. It does NOT bump dataVersion, so
  /// Selector<TaskProvider, int>(dataVersion) in view_task does not rebuild.
  ///  - Timer widgets should listen to `tickNotifier` (ValueListenableBuilder).
  ///  - `super.notifyListeners()` is kept only so OLD screens that still use
  ///    Consumer/watch for the timer text (e.g. TaskDetails) keep working.
  ///    Once every timer text is wrapped in a ValueListenableBuilder you can
  ///    delete that line.
  void _startUiTicker() {
    _uiTicker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isDisposed) return;
      tickNotifier.value++;
      super.notifyListeners(); // no dataVersion bump
    });
  }

  void _stopUiTickerIfNoneRunning() {
    if (!taskTimers.values.any((t) => t.isRunning)) {
      _uiTicker?.cancel();
      _uiTicker = null;
    }
  }

  int currentSeconds(String id) {
    final t = taskTimers[id];
    if (t == null) return 0;
    int secs = t.accumulatedSeconds;
    if (t.isRunning && t.startTime != null) {
      secs += DateTime.now().difference(t.startTime!).inSeconds;
    }
    return secs;
  }

  void _updateTimerOnLog(String id, String level) {
    taskTimers.putIfAbsent(id, () => TaskTimer());
    final t = taskTimers[id]!;

    if (level == "Start") {
      t.startTime = DateTime.now();
      t.isRunning = true;
      _startUiTicker();
    } else if (level == "Hold") {
      if (t.isRunning && t.startTime != null) {
        t.accumulatedSeconds += DateTime.now().difference(t.startTime!).inSeconds;
      }
      t.isRunning = false;
      t.startTime = null;
      _stopUiTickerIfNoneRunning();
    } else if (level == "Complete") {
      if (t.isRunning && t.startTime != null) {
        t.accumulatedSeconds += DateTime.now().difference(t.startTime!).inSeconds;
      }
      t.isRunning = false;
      t.startTime = null;
      t.isCompleted = true;
      _stopUiTickerIfNoneRunning();
    }
  }

  Future<void> insertTaskLogHistory(context,
      {required String id, required String level}) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(
              child: Column(
                children: [
                  const CustomText(text: "Loading", colors: Colors.grey, size: 15, isBold: true),
                  10.height,
                  const CustomText(
                      text: "Please Wait", colors: Colors.grey, size: 15, isBold: true),
                  20.height,
                  LoadingAnimationWidget.staggeredDotsWave(
                      color: colorsConst.secondary, size: 25),
                ],
              ),
            ),
          );
        },
      );
      Map<String, String> data = {
        'task_id': id,
        'status': level,
        'user_id': localData.storage.read("id"),
        'action': insertTaskLog,
        'cos_id': localData.storage.read("cos_id"),
        'log_file': localData.storage.read("mobile_number"),
      };
      final response = await _taskRepo.addType(data);
      _log(data.toString());
      log(response.toString());

      if (response.toString().contains("200")) {
        utils.showSuccessToast(context: context, text: constValue.updated);

        _updateTimerOnLog(id, level);

        getAllTask(false);
        Navigator.pop(context);
      } else {
        utils.showErrorToast(context: context);
        Navigator.pop(context);
      }
    } catch (e) {
      utils.showWarningToast(context, text: "Failed");
      Navigator.pop(context);
    }
    notifyListeners();
  }

  void resetOnLogout() {
    final now = DateTime.now();

    // timers / streams / audio
    timer?.cancel();
    timer = null;
    _uiTicker?.cancel();
    _uiTicker = null;
    _durationSub?.cancel();
    _durationSub = null;
    _positionSub?.cancel();
    _positionSub = null;
    _completeSub?.cancel();
    _completeSub = null;
    _a2PosSub?.cancel();
    _a2PosSub = null;
    _a2CompleteSub?.cancel();
    _a2CompleteSub = null;
    audioPlayer.stop().catchError((_) {});
    player.stop().catchError((_) {});
    if (_isRecording) {
      _record.stop().catchError((_) => null);
      record.stop().catchError((_) => null);
    }
    taskTimers.clear();
    _dateCache.clear();

    // filter / date
    _isFilter = false;
    _startDate = "";
    _endDate = "";
    _stDate = "";
    _enDate = "";
    lStatus = "";
    _companyName = "";
    _fType = "";
    _filterTypeId = null;
    _filterType = null;
    selectedDate2 = null;
    datesBetween = [];
    betweenDates = "";
    stDt = now;
    enDt = now.add(const Duration(days: 1));
    _user = null;
    _userName = "";
    _year = "";
    total = 0;
    _defaultMonth = now.month;
    _thisMonthLeave = "0";
    _filterTasks = 0;
    _fixedLeaves = <HolyDaysModel>[];
    _filterDate = "";
    _statusT = null;
    _filter = "1";
    statusId = "";
    _statusIds = "";
    matched = 0;

    // add / edit task form
    _signPrefix = "Mr";
    _assignedId = "";
    _assName = "";
    _assignedNames = "";
    _cusId = "";
    _cusName = "";
    _title = null;
    _department = null;
    _type = null;
    _status = null;
    _isUpdate = false;
    _level = "Normal";
    _taskSDate = "";
    _taskEDate = "";
    _taskSTime = "";
    _taskETime = "";
    _changeTaskStatus = "";
    _selectedFiles = [];
    _selectedPhotos.clear();
    _assignList = [];
    for (final item in _assignItems) {
      item['selected'] = false;
    }
    fileNameCont = <TextEditingController>[];
    _selectType = null;
    _selectType1 = null;
    typeId = null;
    typeName = null;
    isAddTaskLoading = false;

    // audio / video
    _audioPath = null;
    _currentlyPlayingPath = null;
    _isRecording = false;
    _isPlaying = true;
    _isVedioPlaying = false;
    _recordingDuration = 0;
    _recordingTime = "";
    _position = Duration.zero;
    _duration = null;
    currentIndex = -1;
    audioList = [];
    _recordedAudioPaths = [];
    _videos.clear();

    // loading flags
    _isLoading = false;
    _isProjectLoading = false;
    _isDepartmentLoading = false;
    _isTaskLoading = false;
    _isError = false;
    _refresh = true;
    _viewRefresh = true;
    _addRefresh = true;
    _isDashboardLoading = false;
    _selectedDate = now;

    // lists / data
    _projectDropList = [];
    _departmentList = [];
    _taskDetailsList = [];
    _userNameList = [];
    _allTasks = <TaskData>[];
    _searchAllTasks = <TaskData>[];
    _filteredBeforeSearch = [];
    _filterUserData = <TaskData>[];
    _userAllTasks = <TaskData>[];
    assignEmployees = [];
    historyDetails = [];
    _customerAttendanceReport = <CustomerAttendanceModel>[];
    typeList = [];
    customerList = [];
    cusTypeList = [];
    statusList = [];

    // dashboard counts
    _totalCount = "";
    _pendingCount = "";
    _completedCount = "";
    _overdueCount = "";
    _pendingCountPer = 0.0;
    _completedCountPer = 0.0;
    _overdueCountPer = 0.0;

    // status buttons
    isAssignedDisabled = false;
    isStartedDisabled = false;
    isCompletedDisabled = false;
    selectedStatusValue = "Assigned";
    currentStatus = "Assigned";

    // misc
    _profile = "";
    _checkAtt = "";
    _checkAttName = "";
    try {
      dataSource.appointments?.clear();
    } catch (_) {}

    // text controllers
    search.clear();
    search2.clear();
    taskDescCont.clear();
    taskTitleCont.clear();
    projectNameCont.clear();
    departmentCont.clear();
    projectSearchCont.clear();
    taskDt.clear();
    taskEt.clear();
    typeCtr.clear();

    notifyListeners();
  }

  // ===========================================================================
  // WAGES
  // ===========================================================================
  bool isWagesLoading = false;

  static const String _offlineWorkersKey = "offline_wages_workers";

  static const String _offlineWorkKey = "offline_wages_work";

  bool _isWagesSuccess(String response) {
    try {
      final d = json.decode(response);

      if (d is Map) {
        final v = (d['status'] ?? d['code'] ?? d['success'] ?? d['result'] ?? '')
            .toString()
            .toLowerCase();

        return v == '200' || v == 'success' || v == 'true' || v == '1';
      }
    } catch (_) {}

    return response.contains("200");
  }

  bool isWagesSyncing = false;

  Future<List<Map<String, dynamic>>> _getOfflineWorkers() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_offlineWorkersKey);

    if (value == null || value.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(value);

      if (decoded is List) {
        return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      _log("GET OFFLINE WORKERS ERROR: $e");
    }

    return [];
  }

  Future<void> _saveOfflineWorkers(List<Map<String, dynamic>> workers) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_offlineWorkersKey, jsonEncode(workers));
  }

  Future<List<Map<String, dynamic>>> _getOfflineWork() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_offlineWorkKey);

    if (value == null || value.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(value);

      if (decoded is List) {
        return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      _log("GET OFFLINE WORK ERROR: $e");
    }

    return [];
  }

  Future<void> _saveOfflineWork(List<Map<String, dynamic>> workList) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_offlineWorkKey, jsonEncode(workList));
  }

  Future<int> getPendingWagesCount() async {
    try {
      final list = await _getOfflineWork();

      return list.where((item) => item["sync_status"]?.toString() == "pending").length;
    } catch (e) {
      _log("PENDING WAGES COUNT ERROR: $e");
      return 0;
    }
  }

  Future<bool> hasPendingWages() async {
    final count = await getPendingWagesCount();
    return count > 0;
  }

  // ---------- ADD WORKER ----------
  Future<bool> addWages({
    required BuildContext context,
    required String empName,
    required String empContact,
    required String rate,
  }) async {
    bool success = false;

    try {
      isWagesLoading = true;
      notifyListeners();

      final data = {
        'created_by': localData.storage.read("id").toString(),
        'cos_id': localData.storage.read("cos_id").toString(),
        'emp_name': empName.trim(),
        'emp_contact': empContact.trim(),
        'rate': rate.trim(),
        'action': 'insert_wages',
      };

      _log("ADD WAGES DATA: $data");

      final response = await _taskRepo.addWages(data);

      _log("ADD WAGES RESPONSE: $response");

      if (_isWagesSuccess(response.toString())) {
        utils.showSuccessToast(
          context: context,
          text: "Worker added successfully",
        );

        success = true;
      } else {
        utils.showErrorToast(context: context);
      }
    } catch (e) {
      _log("ADD WAGES ERROR: $e");

      utils.showWarningToast(context, text: e.toString());
    }

    isWagesLoading = false;
    notifyListeners();

    return success;
  }

  // ---------- FETCH ALL WORKERS ----------
  Future<List<Map<String, dynamic>>> getWages() async {
    try {
      final data = {
        'cos_id': localData.storage.read("cos_id").toString(),
        'user_id': localData.storage.read("id").toString(),
        'action': 'select_wages',
      };

      _log("SELECT WAGES DATA: $data");

      final response = await _taskRepo.getWages(data);

      _log("SELECT WAGES RESPONSE: $response");

      final decoded = json.decode(response);

      List raw = [];

      if (decoded is List) {
        raw = decoded;
      } else if (decoded is Map) {
        for (final key in ['data', 'result', 'wages', 'list']) {
          if (decoded[key] is List) {
            raw = decoded[key];
            break;
          }
        }
      }

      final workers = raw.map((e) => Map<String, dynamic>.from(e)).toList();

      if (workers.isNotEmpty) {
        await _saveOfflineWorkers(workers);
      }

      return workers;
    } catch (e) {
      _log("SELECT WAGES ERROR: $e");

      final localWorkers = await _getOfflineWorkers();

      _log("OFFLINE WORKERS LOADED: ${localWorkers.length}");

      return localWorkers;
    }
  }

  // ---------- Status: local pending mudhalla, apparam server ----------
  Future<String> getWagesStatus({
    required String taskId,
    required String wageEmpId,
  }) async {
    final local = await getOfflineWagesStatus(
      taskId: taskId,
      wageEmpId: wageEmpId,
    );
    if (local.isNotEmpty) return local;

    try {
      final response = await checkWagesEntry(
        taskId: taskId,
        wageEmpId: wageEmpId,
      );

      if (response.isEmpty) return "";

      final decoded = json.decode(response);

      if (decoded is Map) {
        final data = decoded['data'];
        if (data is List && data.isNotEmpty && data[0] is Map) {
          final value = data[0]['status'];
          if (value != null) return value.toString();
        }
      }
    } catch (e) {
      _log("ONLINE WAGES STATUS ERROR: $e");
    }

    return "";
  }

  Future<String> checkWagesEntry({
    required String taskId,
    required String wageEmpId,
  }) async {
    try {
      final data = {
        'created_by': localData.storage.read("id").toString(),
        'user_id': localData.storage.read("id").toString(),
        'cos_id': localData.storage.read("cos_id").toString(),
        'task_id': taskId,
        'wage_emp_id': wageEmpId,
        'action': 'chk_wages_entry',
      };

      _log("CHECK WAGES DATA: $data");

      final response = await _taskRepo.getWorkDetails(data);

      _log("CHECK WAGES RESPONSE: $response");

      return response;
    } catch (e) {
      _log("CHECK WAGES ERROR: $e");

      return '';
    }
  }

  // ---------- Offline save ----------
  Future<bool> saveOfflineWagesWork({
    required String taskId,
    required String empId,
    required String empName,
    required String empContact,
    required String rate,
    required String description,
    required String status,
    required String checkIn,
    required String checkOut,
    required String lat,
    required String lng,
  }) async {
    try {
      await OfflineAttendanceService.addWages(
        wagesData: {
          "wage_emp_id": empId,
          "task_id": taskId,
          "wages_description": description,
          "check_in": checkIn,
          "check_out": checkOut,
          "status": status,
        },
        lat: lat,
        lng: lng,
        status: status,
        includeAttendance: false, // wages mattum, attendance illa
      );

      notifyListeners();
      _log("OFFLINE WAGES SAVED (status $status)");
      return true;
    } catch (e) {
      _log("SAVE OFFLINE WAGES ERROR: $e");
      return false;
    }
  }

  // ---------- Check-in ----------
  Future<bool> saveWagesCheckIn({
    required BuildContext context,
    required String taskId,
    required String empId,
    required String empName,
    required String empContact,
    required String rate,
    required String description,
    required String checkIn,
    required String lat,
    required String lng,
  }) async {
    Future<bool> saveLocal() async {
      final ok = await saveOfflineWagesWork(
        taskId: taskId,
        empId: empId,
        empName: empName,
        empContact: empContact,
        rate: rate,
        description: description,
        status: "1",
        checkIn: checkIn,
        checkOut: "",
        lat: lat,
        lng: lng,
      );
      if (ok && context.mounted) {
        utils.showWarningToast(context, text: "Saved offline. It will sync later.");
      }
      return ok;
    }

    // Internet illana direct-a offline save (error toast varaadhu)
    if (!await OfflineAttendanceService.isOnline()) {
      return saveLocal();
    }

    try {
      final success = await addWorkDetails(
        context: context,
        taskId: taskId,
        empId: empId,
        description: description,
        status: "1",
        lat: lat,
        lng: lng,
        checkIn: checkIn,
        checkOut: "",
      );
      if (success) return true;
    } catch (e) {
      _log("SAVE WAGES CHECK IN ERROR: $e");
    }

    return saveLocal();
  }

  Future<bool> saveWagesCheckOut({
    required BuildContext context,
    required String taskId,
    required String empId,
    required String checkOut,
    required String lat,
    required String lng,
  }) async {
    Future<bool> saveLocal() async {
      // 1) Pending check-in irundha adhulaye check-out serkkum
      bool ok = await updateOfflineWagesCheckOut(
        taskId: taskId,
        empId: empId,
        checkOut: checkOut,
        lat: lat,
        lng: lng,
      );

      // 2) Check-in already server-la irundha, check-out mattum pending
      if (!ok) {
        ok = await saveOfflineWagesWork(
          taskId: taskId,
          empId: empId,
          empName: "",
          empContact: "",
          rate: "",
          description: "",
          status: "2",
          checkIn: "",
          checkOut: checkOut,
          lat: lat,
          lng: lng,
        );
      }

      if (ok && context.mounted) {
        utils.showWarningToast(
          context,
          text: "Check out saved offline. It will sync later.",
        );
      }
      return ok;
    }

    if (!await OfflineAttendanceService.isOnline()) {
      return saveLocal();
    }

    try {
      final data = {
        'cos_id': localData.storage.read("cos_id").toString(),
        'user_id': localData.storage.read("id").toString(),
        'created_by': localData.storage.read("id").toString(),
        'wage_emp_id': empId,
        'task_id': taskId,
        'check_out': checkOut,
        'lat': lat,
        'lng': lng,
        'status': '2',
        'action': 'update_wages_work_details',
      };

      final response = await _taskRepo.addWorkDetails(data);
      _log("UPDATE WAGES CHECK OUT RESPONSE: $response");

      if (_isWagesSuccess(response.toString())) {
        if (context.mounted) {
          utils.showSuccessToast(
            context: context,
            text: "Work completed successfully",
          );
        }
        return true;
      }
    } catch (e) {
      _log("ONLINE CHECK OUT ERROR: $e");
    }

    return saveLocal();
  }

  Future<bool> updateOfflineWagesCheckOut({
    required String taskId,
    required String empId,
    required String checkOut,
    required String lat,
    required String lng,
  }) async {
    try {
      final ok = await OfflineAttendanceService.updateWagesCheckOut(
        taskId: taskId,
        empId: empId,
        checkOut: checkOut,
        lat: lat,
        lng: lng,
      );
      if (ok) notifyListeners();
      return ok;
    } catch (e) {
      _log("UPDATE OFFLINE CHECKOUT ERROR: $e");
      return false;
    }
  }

  Future<String> getOfflineWagesStatus({
    required String taskId,
    required String wageEmpId,
  }) async {
    try {
      final workList = await _getOfflineWork();

      final records = workList
          .where(
            (item) =>
        item["task_id"]?.toString() == taskId &&
            item["wage_emp_id"]?.toString() == wageEmpId &&
            item["sync_status"]?.toString() == "pending",
      )
          .toList();

      if (records.isEmpty) {
        return "";
      }

      records.sort(
            (a, b) => (a["created_at"] ?? "")
            .toString()
            .compareTo((b["created_at"] ?? "").toString()),
      );

      return records.last["status"]?.toString() ?? "";
    } catch (e) {
      _log("OFFLINE STATUS ERROR: $e");
      return "";
    }
  }

  Future<bool> addWorkDetails({
    required BuildContext context,
    required String taskId,
    required String empId,
    required String description,
    required String status,
    required String lat,
    required String lng,
    String checkIn = '',
    String checkOut = '',
  }) async {
    bool success = false;

    try {
      final data = {
        'cos_id': localData.storage.read("cos_id").toString(),
        'user_id': localData.storage.read("id").toString(),
        'created_by': localData.storage.read("id").toString(),
        'wage_emp_id': empId,
        'task_id': taskId,
        'work_description': description.trim(),
        'check_in': checkIn,
        'check_out': checkOut,
        'lat': lat,
        'lng': lng,
        'status': status,
        'action': 'insert_wages_work_details',
      };

      _log("ADD WORK DATA: $data");

      final response = await _taskRepo.addWorkDetails(data);

      _log("ADD WORK RESPONSE: $response");

      if (_isWagesSuccess(response.toString())) {
        utils.showSuccessToast(
          context: context,
          text: "Work details added successfully",
        );

        success = true;
      } else {
        utils.showErrorToast(context: context);
      }
    } catch (e) {
      _log("ADD WORK ERROR: $e");
    }

    return success;
  }

  Future<List<Map<String, dynamic>>> getWorkDetails({
    required String taskId,
  }) async {
    List<Map<String, dynamic>> onlineData = [];

    try {
      final data = {
        'task_id': taskId,
        'cos_id': localData.storage.read("cos_id").toString(),
        'user_id': localData.storage.read("id").toString(),
        'action': 'select_wages_work_details',
      };

      _log("SELECT WORK DATA: $data");

      final response = await _taskRepo.getWorkDetails(data);

      _log("SELECT WORK RESPONSE: $response");

      final decoded = json.decode(response);

      List raw = [];

      if (decoded is List) {
        raw = decoded;
      } else if (decoded is Map) {
        for (final key in ['data', 'result', 'work', 'list']) {
          if (decoded[key] is List) {
            raw = decoded[key];
            break;
          }
        }
      }

      onlineData = raw.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      _log("ONLINE WORK DETAILS ERROR: $e");
    }

    final localList = await _getOfflineWork();

    final localDataForTask = localList
        .where(
          (item) =>
      item["task_id"]?.toString() == taskId &&
          item["sync_status"]?.toString() == "pending",
    )
        .map(
          (item) => {
        "wage_emp_id": item["wage_emp_id"],
        "task_id": item["task_id"],
        "emp_name": item["emp_name"],
        "emp_contact": item["emp_contact"],
        "rate": item["rate"],
        "work_description": item["work_description"],
        "check_in": item["check_in"],
        "check_out": item["check_out"],
        "status": item["status"],
        "lat": item["lat"],
        "lng": item["lng"],
        "created_at": item["created_at"],
      },
    )
        .toList();

    _log("ONLINE WORK COUNT: ${onlineData.length}");
    _log("LOCAL PENDING WORK COUNT: ${localDataForTask.length}");

    return [
      ...onlineData,
      ...localDataForTask,
    ];
  }
}
class TaskTimer {
  DateTime? startTime;
  int accumulatedSeconds;
  bool isRunning;
  bool isCompleted;
  TaskTimer({
    this.startTime,
    this.accumulatedSeconds = 0,
    this.isRunning = false,
    this.isCompleted = false,
  });
}