import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:master_code/source/constant/language_model.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../model/attendance_model.dart';
// Border / BorderStyle are hidden here so they don't clash with the excel package
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, CellStyle, Border, BorderStyle;
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../repo/customer_repo.dart';
import '../constant/api.dart';
import '../constant/language_model.dart';
import '../constant/local_data.dart';

final ExcelReports excelReports = ExcelReports._();

class ExcelReports {
  ExcelReports._();
  String appColor = "#45377D";
  final CustomerRepository custRepo = CustomerRepository();

  /// ================= ATTENDANCE RULES (change here if rules change) =================
  static const int _officeStartMin = 9 * 60;       // 09:00 AM
  static const int _graceEndMin = 9 * 60 + 10;     // 09:10 AM  (inga varaikum late illa)
  static const int _graceLimitMin = 9 * 60 + 15;   // 09:15 AM  (09:11-09:15 -> grace minus, 09:16+ -> full)
  static const int _permHalfDayLimitMin = 4 * 60;  // permission > 4 hrs -> half day leave

  Future<void> exportAttendanceToExcel(context,
      {required List<AttendanceModel> chunked, required String date}) async {
    try {
      chunked.sort((a, b) {
        // First sort by firstname
        int nameCompare = a.firstname!.compareTo(b.firstname!);

        // If firstname same -> then sort by createdTs
        if (nameCompare == 0) {
          return a.createdTs!.compareTo(b.createdTs!);
        }

        return nameCompare;
      });

      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      /// 1) Insert empty row and merge for title
      sheetObject.insertRowIterables([''], 0);
      var firstCell = CellIndex.indexByString("A1");
      var lastCell = CellIndex.indexByString("F1");
      sheetObject.merge(firstCell, lastCell);
      sheetObject.cell(firstCell).value =
      '${constValue.appName} Attendance Reports $date';

      CellStyle titleStyle = CellStyle(
        bold: true,
        fontSize: 10,
      );
      sheetObject.cell(firstCell).cellStyle = titleStyle;

      /// 2) Header row
      List<String> headers = [
        'Date',
        'Employee Name',
        'Role',
        'Check In/In-Time',
        'Check Out/Out-Time',
        'Total Hours'
      ];
      sheetObject.appendRow(headers);

      CellStyle headerStyle = CellStyle(
        backgroundColorHex: appColor,
        fontColorHex: "#FFFFFF",
        fontSize: 10,
        horizontalAlign: HorizontalAlign.Center,
      );

      for (int i = 0; i < headers.length; i++) {
        var headerCell = sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1));
        headerCell.cellStyle = headerStyle;
      }

      /// 3) Fill rows
      for (var i = 0; i < chunked.length; i++) {
        AttendanceModel data = chunked[i];
        var inTime = "", outTime = "-", timeD = "-";
        if (data.status.toString().contains("1,2")) {
          inTime = data.time!.split(",")[0];
          outTime = data.time!.split(",")[1];
          timeD = timeDifference(
              data.createdTs!.split(",")[0], data.createdTs!.split(",")[1]);
        } else if (data.status.toString().contains("2,1")) {
          inTime = data.time!.split(",")[1];
          outTime = data.time!.split(",")[0];
          timeD = timeDifference(
              data.createdTs!.split(",")[0], data.createdTs!.split(",")[1]);
        } else {
          inTime = data.time!.split(",")[0];
          timeD = "-";
        }
        sheetObject.appendRow([
          data.date.toString(),
          data.firstname.toString(),
          data.role.toString(),
          inTime,
          outTime,
          timeD,
        ]);
      }

      final bytes = excel.encode();

      if (kIsWeb) {
        // _downloadExcelWeb(bytes!, "${constValue.appName} Attendance Report.xlsx");
      } else {
        _saveExcelMobile(
            bytes!, "${constValue.appName} Attendance Report.xlsx", context);
      }
    } catch (e) {
      utils.showWarningToast(context, text: "Something Went Wrong");
    }
  }

  /// Mobile save: external dir -> fallback to documents dir (iOS / null case),
  /// errors are caught so they never fail silently.
  Future<void> _saveExcelMobile(
      List<int> bytes, String filename, context) async {
    try {
      Directory? dir;
      try {
        dir = await getExternalStorageDirectory();
      } catch (_) {}
      dir ??= await getApplicationDocumentsDirectory();

      final path = '${dir.path}/$filename';

      File file = File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes);

      final result = await OpenFile.open(file.path);

      if (result.type != ResultType.done) {
        utils.showWarningToast(context, text: "No app found to open the file.");
      }
    } catch (e, st) {
      print("Save Error => $e\n$st");
      utils.showWarningToast(context, text: "File save panna mudiyala");
    }
  }

  /// Web download (uses AnchorElement from universal_html, same as payroll export)
  void _downloadExcelWebFile(List<int> bytes, String fileName) {
    AnchorElement(
        href:
        'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,${base64.encode(bytes)}')
      ..setAttribute('download', fileName)
      ..click();
  }

  Future<void> exportUserAttendanceToExcel(context,
      {required List<AttendanceModel> chunked, required String date}) async {
    try {
      chunked.sort((a, b) => a.createdTs!.compareTo(b.createdTs.toString()));
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      /// 1) Insert empty row and merge for title
      sheetObject.insertRowIterables([''], 0);
      var firstCell = CellIndex.indexByString("A1");
      var lastCell = CellIndex.indexByString("D1");
      sheetObject.merge(firstCell, lastCell);
      sheetObject.cell(firstCell).value =
      '${constValue.appName} ${chunked[0].firstname} ( ${chunked[0].role} ) Attendance Reports $date';

      CellStyle titleStyle = CellStyle(
        bold: true,
        fontSize: 10,
      );
      sheetObject.cell(firstCell).cellStyle = titleStyle;

      /// 2) Header row
      List<String> headers = ['Date', 'In Time', 'Out Time', 'Total Hours'];
      sheetObject.appendRow(headers);

      CellStyle headerStyle = CellStyle(
        backgroundColorHex: appColor,
        fontColorHex: "#FFFFFF",
        fontSize: 10,
        horizontalAlign: HorizontalAlign.Center,
      );

      for (int i = 0; i < headers.length; i++) {
        var headerCell = sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1));
        headerCell.cellStyle = headerStyle;
      }

      /// 3) Fill rows
      for (var i = 0; i < chunked.length; i++) {
        AttendanceModel data = chunked[i];
        var inTime = "", outTime = "-", timeD = "-";
        if (data.status.toString().contains("1,2")) {
          inTime = data.time!.split(",")[0];
          outTime = data.time!.split(",")[1];
          timeD = timeDifference(
              data.createdTs!.split(",")[0], data.createdTs!.split(",")[1]);
        } else if (data.status.toString().contains("2,1")) {
          inTime = data.time!.split(",")[1];
          outTime = data.time!.split(",")[0];
          timeD = timeDifference(
              data.createdTs!.split(",")[0], data.createdTs!.split(",")[1]);
        } else {
          inTime = data.time!.split(",")[0];
          timeD = "-";
        }
        sheetObject.appendRow([
          data.date.toString(),
          inTime,
          outTime,
          timeD,
        ]);
      }
      final bytes = excel.encode();
      if (kIsWeb) {
        // _downloadExcelWeb(bytes!, "${constValue.appName} ${chunked[0].firstname} Attendance Report.xlsx");
      } else {
        _saveExcelMobile(
            bytes!,
            "${constValue.appName} ${chunked[0].firstname} Attendance Report.xlsx",
            context);
      }
    } catch (e) {
      utils.showWarningToast(context, text: "Something Went Wrong");
    }
  }

  /// ✅ CHANGED: `leaves` (applied leave list) vaangum
  Future<void> downloadAttendanceExcelReport(context,
      {required String stDate,
        required String enDate,
        List leaves = const []}) async {
    try {
      Map data = {
        "action": getAllData,
        "search_type": "attendance_report_full",
        "salesman_id": localData.storage.read("id"),
        "role": localData.storage.read("role"),
        "cos_id": localData.storage.read("cos_id"),
        "st_dt": stDate,
        "en_dt": enDate,
      };
      print("respinse download${data}");
      final response = await custRepo.getDashboardReport(data);
      print("API response type: ${response.runtimeType}, length: ${response.length}");
      if (response.isNotEmpty) {
        await exportAttendanceSingleSheetExcel(
          context,
          attendanceList: response,
          leaveList: leaves, // ✅ CHANGED (was [])
          startDate: stDate,
          endDate: enDate,
        );
      } else {
        utils.showWarningToast(context, text: "No data found");
      }
    } catch (e, st) {
      print("Attendance Excel Error => $e\n$st");
      utils.showWarningToast(context, text: "Something went wrong");
    }
  }

  /// ==========================================================================
  /// ATTENDANCE REPORT (ONE sheet)
  ///  - OVERALL SUMMARY at the TOP:
  ///        Month + Working Days, then
  ///        Employee Name | Leave Taken | Leave Deducted | Permission Taken
  ///  - employee-wise day-by-day detail below it
  ///
  /// ✅ FIX: SUMMARY + DETAILS rendum ONE in-memory buffer-la collect aagum.
  ///  Nothing is written to the sheet until the very end. Then the buffer is
  ///  flushed in ascending row / col order (all cells first, merges last),
  ///  so file order == row order and the summary is ALWAYS on top
  ///  (monthly or short date range, both).
  ///
  /// RULES
  ///  - Check-in 09:10 varaikum -> late illa, permission illa (grace).
  ///  - 09:11 - 09:15  -> permission = check-in - 09:10   (9:12 -> 2 mins)
  ///  - 09:16 and above -> permission = check-in - 09:00  (9:20 -> 20 mins, grace minus illa)
  ///  - Applied permission (eg 9:00-9:30) -> grace minus pannaama apdiye.
  ///  - Applied permission late time-a cover pannirundha double count aagaadhu.
  ///  - Permission > 4 hrs -> every 4 hrs = 0.5 Half Day Leave.
  ///  - Check-in illa (past date, leave apply illa) -> detail-la Absent,
  ///    SUMMARY-la Leave Taken-la serum.
  ///  - Leave apply pannirundha (check-in illanaalum) -> Leave.
  /// ==========================================================================
  Future<void> exportAttendanceSingleSheetExcel(
      context, {
        required List attendanceList,
        required List leaveList,
        required String startDate,
        required String endDate,
      }) async {
    try {
      var excel = Excel.createExcel();
      // ONE sheet only: overall summary on TOP, employee details below it
      Sheet sheet = excel["Sheet1"];

      /// ================= HELPERS =================
      String formatDate(String? input) {
        try {
          if (input == null || input.isEmpty) return "-";
          return DateFormat('dd-MM-yyyy').format(DateTime.parse(input));
        } catch (e) {
          return input ?? "-";
        }
      }

      String formatTime12(String? time) {
        try {
          if (time == null || time.isEmpty || time == "-") return "-";
          DateTime parsedTime = DateFormat("HH:mm:ss").parse(time);
          return DateFormat("hh:mm a").format(parsedTime);
        } catch (e) {
          return time ?? "-";
        }
      }

      int timeToMinutes(String? time) {
        try {
          if (time == null || time.isEmpty || time == "-") return 0;
          DateTime t = DateFormat("HH:mm:ss").parse(time);
          return (t.hour * 60) + t.minute;
        } catch (e) {
          return 0;
        }
      }

      String minutesToHourFormat(int minutes) {
        int h = minutes ~/ 60;
        int m = minutes % 60;
        return "${h}h ${m}m";
      }

      /// "-" when 0, "45 mins" under 1 hr, else "1h 5m"
      String durationText(int minutes) {
        if (minutes <= 0) return "-";
        if (minutes < 60) return "$minutes mins";
        return minutesToHourFormat(minutes);
      }

      /// 1.0 -> 1 , 0.5 -> 0.5 (so the sheet doesn't show 1.0)
      dynamic numOut(double v) => v == v.roundToDouble() ? v.toInt() : v;

      /// "HH:mm:ss" / "hh:mm a" / "HH:mm" endha format-um minutes-a maathum
      int anyTimeToMinutes(String? t) {
        final s = (t ?? "").trim();
        if (s.isEmpty || s == "-" || s == "null") return 0;
        for (final f in ["HH:mm:ss", "hh:mm a", "HH:mm"]) {
          try {
            final d = DateFormat(f).parse(s);
            return d.hour * 60 + d.minute;
          } catch (_) {}
        }
        return 0;
      }

      /// endha date format vandhaalum -> DateTime (time illaama)
      DateTime? toDay(dynamic v) {
        final t = v?.toString().trim() ?? "";
        if (t.isEmpty || t == "null") return null;
        final p = t.split(' ')[0].split('T')[0];
        final iso = DateTime.tryParse(p);
        if (iso != null) return DateTime(iso.year, iso.month, iso.day);
        for (final f in ["dd-MM-yyyy", "dd/MM/yyyy"]) {
          try {
            final x = DateFormat(f).parseStrict(p);
            return DateTime(x.year, x.month, x.day);
          } catch (_) {}
        }
        return null;
      }

      /// normalized "yyyy-MM-dd" key
      String dayKey(dynamic v) {
        final x = toDay(v);
        return x == null ? "" : DateFormat('yyyy-MM-dd').format(x);
      }

      /// employee + date-ku applied leave irundha {days, reason}
      Map<String, dynamic>? findLeave(String emp, String d) {
        final day = toDay(d);
        if (day == null) return null;
        for (final l in leaveList) {
          if ((l.fName ?? "").toString().trim().toLowerCase() !=
              emp.trim().toLowerCase()) continue;
          final s = toDay(l.startDate);
          if (s == null) continue;
          final e = toDay(l.endDate) ?? s;
          if (day.isBefore(s) || day.isAfter(e)) continue;
          return {
            "days": l.dayType.toString() == "0.5" ? 0.5 : 1.0,
            "reason": (l.reason ?? "Leave").toString(),
          };
        }
        return null;
      }

      /// Oru employee + oru naal-ku ella permission (In, Out) pairs.
      /// [rows] = andha naal-ku vara ella records (API rendu row anuppinaalum serum)
      List<List<String>> getPermissionPairs(List<Map<String, dynamic>> rows) {
        final List<List<String>> pairs = [];
        final Set<String> seen = {};
        String s(dynamic v) => v?.toString().trim() ?? "";

        void addPair(String a, String b) {
          if (a.isEmpty || a == "null" || a == "-") return;
          final key = "$a|$b";
          if (seen.add(key)) pairs.add([a, b]);
        }

        for (final r in rows) {
          final pIn = s(r["per_in"]);
          final pOut = s(r["per_out"]);
          final pTime = s(r["per_time"]);
          final pStatus = s(r["per_status"]);

          // 1) per_in / per_out la comma list vandha
          if (pIn.contains(",") || pOut.contains(",")) {
            final ins = pIn.split(",").map((e) => e.trim()).toList();
            final outs = pOut.split(",").map((e) => e.trim()).toList();
            for (int i = 0; i < ins.length; i++) {
              addPair(ins[i], i < outs.length ? outs[i] : "");
            }
            continue;
          }

          // 2) per_time + per_status ("1,2,1,2") -> 1 = In, 2 = Out
          if (pTime.contains(",") && pStatus.isNotEmpty) {
            final times = pTime.split(",").map((e) => e.trim()).toList();
            final sts = pStatus.split(",").map((e) => e.trim()).toList();
            String? open;
            bool found = false;
            for (int i = 0; i < sts.length && i < times.length; i++) {
              if (sts[i] == "1") {
                open = times[i];
              } else if (sts[i] == "2" && open != null) {
                addPair(open, times[i]);
                open = null;
                found = true;
              }
            }
            if (found) continue;
          }

          // 3) single pair
          addPair(pIn, pOut);
        }
        return pairs;
      }

      /// Sunday + 3rd Saturday
      Map<String, dynamic> getWeekendInfo(String? dateStr) {
        try {
          if (dateStr == null || dateStr.isEmpty) {
            return {"isWeekend": false, "label": ""};
          }
          DateTime parsedDate = DateTime.parse(dateStr);

          if (parsedDate.weekday == DateTime.sunday) {
            return {"isWeekend": true, "label": "Sunday"};
          }

          if (parsedDate.weekday == DateTime.saturday) {
            int saturdayCount = 0;
            for (int day = 1; day <= parsedDate.day; day++) {
              DateTime tempDate =
              DateTime(parsedDate.year, parsedDate.month, day);
              if (tempDate.weekday == DateTime.saturday) {
                saturdayCount++;
              }
            }
            if (saturdayCount == 3) {
              return {"isWeekend": true, "label": "3rd Saturday"};
            }
          }
          return {"isWeekend": false, "label": ""};
        } catch (e) {
          return {"isWeekend": false, "label": ""};
        }
      }

      /// ================= STYLES =================
      CellStyle headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: "#45377D",
        fontColorHex: "#FFFFFF",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      CellStyle titleStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Left,
        verticalAlign: VerticalAlign.Center,
      );

      CellStyle totalStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "#FFF2CC",
      );

      CellStyle normalStyle = CellStyle(
        bold: false,
        backgroundColorHex: "#FFFFFF",
        fontColorHex: "#000000",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      /// Week-off row (green)
      CellStyle weekOffStyle = CellStyle(
        bold: true,
        backgroundColorHex: "#C6EFCE",
        fontColorHex: "#006100",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      /// Applied-leave row (yellow)
      CellStyle leaveStyle = CellStyle(
        bold: true,
        backgroundColorHex: "#FFEB9C",
        fontColorHex: "#9C6500",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      /// Absent (no check-in) row (light red)
      CellStyle absentStyle = CellStyle(
        bold: true,
        backgroundColorHex: "#FFC7CE",
        fontColorHex: "#9C0006",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      /// Late / permission->half-day row (light orange)
      CellStyle lateStyle = CellStyle(
        bold: false,
        backgroundColorHex: "#FFF3E0",
        fontColorHex: "#E65100",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      /// ================= GROUP EMPLOYEE WISE =================
      Set<String> employeeSet = {};
      Set<String> dateSet = {};

      for (var item in attendanceList) {
        if (item["firstname"] != null) employeeSet.add(item["firstname"]);
        final k = dayKey(item["date"]);
        if (k.isNotEmpty) dateSet.add(k);
      }
      // leave-la irukkuravangalayum serkkirom
      for (final l in leaveList) {
        final n = (l.fName ?? "").toString();
        if (n.isNotEmpty && n != "null") employeeSet.add(n);
      }

      List<String> employees = employeeSet.toList()..sort();

      /// start..end ellaa naalum (attendance row illanaalum)
      DateTime? parseRange(String v) {
        try {
          return DateFormat('dd-MM-yyyy').parseStrict(v);
        } catch (_) {
          return DateTime.tryParse(v);
        }
      }

      List<String> dates = [];
      final DateTime? rs = parseRange(startDate);
      final DateTime? re = parseRange(endDate);
      if (rs != null && re != null && !re.isBefore(rs)) {
        for (var x = DateTime(rs.year, rs.month, rs.day);
        !x.isAfter(re);
        x = DateTime(x.year, x.month, x.day + 1)) {
          dates.add(DateFormat('yyyy-MM-dd').format(x));
        }
      } else {
        dates = dateSet.toList()..sort();
      }

      /// employee + naal -> andha naal-ku vara ella rows
      final Map<String, List<Map<String, dynamic>>> rowsByEmpDay = {};
      for (final item in attendanceList) {
        final n = (item["firstname"] ?? "").toString();
        final k = dayKey(item["date"]);
        if (n.isEmpty || k.isEmpty) continue;
        rowsByEmpDay
            .putIfAbsent("$n|$k", () => [])
            .add(Map<String, dynamic>.from(item));
      }

      /// WORKING DAYS = total days in range - (Sunday / 3rd Saturday)
      int totalDaysInRange = dates.length;
      int weekOffDaysCount = dates.where((d) {
        Map<String, dynamic> info = getWeekendInfo(d);
        return info["isWeekend"] as bool;
      }).length;
      int workingDaysCount = totalDaysInRange - weekOffDaysCount;

      /// per-employee totals (used for the Summary)
      final List<Map<String, dynamic>> summaryRows = [];

      const int lastCol = 15; // last column index of the detail table

      /// ======================================================================
      /// ============ SUMMARY (TOP of the sheet) ==============================
      /// ======================================================================
      const int summaryColEnd = 10; // summary spans columns A..K
      const int summaryDataStart = 3; // banner(0) + title(1) + header(2)
      final int detailStartRow = summaryDataStart + employees.length + 2;

      String monthTitle;
      try {
        final DateTime s = parseRange(startDate)!;
        final DateTime e = parseRange(endDate)!;

        final bool isFullMonth = s.day == 1 &&
            s.year == e.year &&
            s.month == e.month &&
            e.day == DateTime(s.year, s.month + 1, 0).day;

        if (isFullMonth) {
          monthTitle = DateFormat('MMMMyyyy').format(s); // September2026
        } else if (s.year == e.year && s.month == e.month && s.day == e.day) {
          monthTitle = DateFormat('dd MMM yyyy').format(s);
        } else {
          monthTitle =
          "${DateFormat('dd MMM yyyy').format(s)} - ${DateFormat('dd MMM yyyy').format(e)}";
        }
      } catch (_) {
        monthTitle = "$startDate to $endDate";
      }

      String leaveText(double days) {
        if (days <= 0) return "-";
        if (days == 0.5) return "Half Day Leave";
        final String n = days == days.roundToDouble()
            ? days.toInt().toString()
            : days.toString();
        return days <= 1 ? "$n Day Leave" : "$n Days Leave";
      }

      String permissionText(int minutes) {
        if (minutes <= 0) return "-";
        final int h = minutes ~/ 60;
        final int m = minutes % 60;
        if (h == 0) return "$m Mins Permission";
        final String hLabel = h == 1 ? "Hour" : "Hours";
        if (m == 0) return "$h $hLabel Permission";
        return "$h $hLabel $m mins Permission";
      }

      final Border thin = Border(borderStyle: BorderStyle.Thin);

      CellStyle bannerStyle = CellStyle(
        bold: true,
        fontSize: 14,
        backgroundColorHex: "#45377D",
        fontColorHex: "#FFFFFF",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
      CellStyle sTitleLeft = CellStyle(
        bold: true,
        fontSize: 14,
        fontColorHex: "#4A86E8",
        backgroundColorHex: "#FFF2CC",
        horizontalAlign: HorizontalAlign.Left,
        verticalAlign: VerticalAlign.Center,
        leftBorder: thin,
        rightBorder: thin,
        topBorder: thin,
        bottomBorder: thin,
      );
      CellStyle sTitleRight = CellStyle(
        bold: true,
        fontSize: 14,
        fontColorHex: "#4A86E8",
        backgroundColorHex: "#FFF2CC",
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center,
        leftBorder: thin,
        rightBorder: thin,
        topBorder: thin,
        bottomBorder: thin,
      );
      CellStyle sHeader = CellStyle(
        bold: true,
        backgroundColorHex: "#45377D",
        fontColorHex: "#FFFFFF",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        leftBorder: thin,
        rightBorder: thin,
        topBorder: thin,
        bottomBorder: thin,
      );
      CellStyle sCell = CellStyle(
        backgroundColorHex: "#FFFBEA",
        horizontalAlign: HorizontalAlign.Left,
        verticalAlign: VerticalAlign.Center,
        leftBorder: thin,
        rightBorder: thin,
        topBorder: thin,
        bottomBorder: thin,
      );

      /// ======================================================================
      /// ============ BUFFER (summary + details rendum idhula thaan) ==========
      /// row -> col -> [value, style]
      /// ======================================================================
      final Map<int, Map<int, List<dynamic>>> cellBuf = {};
      final List<List<int>> mergeBuf = []; // [row, fromCol, toCol]

      List<dynamic> slot(int row, int col) => cellBuf
          .putIfAbsent(row, () => <int, List<dynamic>>{})
          .putIfAbsent(col, () => <dynamic>[null, null]);

      void bufVal(int row, int col, dynamic v) {
        slot(row, col)[0] = v;
      }

      void bufStyle(int row, int col, CellStyle s) {
        slot(row, col)[1] = s;
      }

      void bufMerge(int row, int fromCol, int toCol) {
        mergeBuf.add([row, fromCol, toCol]);
      }

      /// buffer -> sheet. ALWAYS ascending row, ascending col.
      /// Ella cell-um ezhuthina PIRAGU thaan merge pannum.
      void flushBuffer(Sheet target) {
        final List<int> rowKeys = cellBuf.keys.toList()..sort();
        for (final r in rowKeys) {
          final Map<int, List<dynamic>> cols = cellBuf[r]!;
          final List<int> colKeys = cols.keys.toList()..sort();
          for (final c in colKeys) {
            final List<dynamic> e = cols[c]!;
            final cell = target.cell(
                CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r));
            if (e[0] != null) cell.value = e[0];
            if (e[1] != null) cell.cellStyle = e[1] as CellStyle;
          }
        }
        final sortedMerges = [...mergeBuf]
          ..sort((a, b) =>
          a[0] != b[0] ? a[0].compareTo(b[0]) : a[1].compareTo(b[1]));
        for (final m in sortedMerges) {
          target.merge(
            CellIndex.indexByColumnRow(columnIndex: m[1], rowIndex: m[0]),
            CellIndex.indexByColumnRow(columnIndex: m[2], rowIndex: m[0]),
          );
        }
      }

      /// merged block (BUFFER-ku mattum ezhuthum, sheet-ah direct-a touch pannaadhu)
      void putBlock(int row, int startCol, int endCol, String value,
          CellStyle style) {
        bufVal(row, startCol, value);
        for (int c = startCol; c <= endCol; c++) {
          bufStyle(row, c, style);
        }
        if (endCol > startCol) bufMerge(row, startCol, endCol);
      }

      /// Summary columns:
      ///  Employee Name  = A..C
      ///  Leave Taken    = D..F
      ///  Leave Deducted = G..H  (blank for now)
      ///  Permission Taken = I..K
      void writeSummary() {
        // banner
        putBlock(0, 0, summaryColEnd,
            "OVERALL SUMMARY ( $startDate to $endDate )", bannerStyle);

        // month + working days
        putBlock(1, 0, 5, monthTitle, sTitleLeft);
        putBlock(1, 6, summaryColEnd,
            "Working Days: $workingDaysCount", sTitleRight);

        // column headers
        putBlock(2, 0, 2, "Employee Name", sHeader);
        putBlock(2, 3, 5, "Leave Taken", sHeader);
        putBlock(2, 6, 7, "Leave Deducted", sHeader);
        putBlock(2, 8, summaryColEnd, "Permission Taken", sHeader);

        // one row per employee
        int r = summaryDataStart;
        for (final s in summaryRows) {
          // total leave = applied leave + half day(s) from permission > 4 hrs
          //             + check-in illatha (absent) naatkal
          final double totalLeaveDays = (s["leave"] as double) +
              (s["halfDay"] as double) +
              (s["absentLeave"] as int).toDouble();

          putBlock(r, 0, 2, s["name"].toString(), sCell);
          putBlock(r, 3, 5, leaveText(totalLeaveDays), sCell);
          putBlock(r, 6, 7, "", sCell); // Leave Deducted (later)
          putBlock(r, 8, summaryColEnd,
              permissionText(s["permMinutes"] as int), sCell);
          r++;
        }
      }

      // column widths
      const List<double> colWidths = [
        14, 9, 11, 11, 12, 9, 9, 12, 11, 14, 14, 18, 14, 34, 9, 34
      ];
      for (int i = 0; i < colWidths.length; i++) {
        sheet.setColWidth(i, colWidths[i]);
      }

      /// ======================================================================
      /// ============ EMPLOYEE DETAILS (below the summary) ====================
      /// ======================================================================
      int rowIndex = detailStartRow;
      final DateTime nowDt = DateTime.now();
      final DateTime todayStart = DateTime(nowDt.year, nowDt.month, nowDt.day);

      for (String emp in employees) {
        /// ================= TITLE ROW =================
        bufVal(rowIndex, 0,
            "$emp - Employee ( $startDate to $endDate ) Attendance Report");
        bufMerge(rowIndex, 0, lastCol);
        bufStyle(rowIndex, 0, titleStyle);
        rowIndex++;

        /// ================= WORKING DAYS ROW =================
        bufVal(rowIndex, 0,
            "Total Days: $totalDaysInRange   |   Week Off (Sun/3rd Sat): $weekOffDaysCount   |   Working Days: $workingDaysCount   |   Grace: 09:10 AM");
        bufMerge(rowIndex, 0, lastCol);
        bufStyle(rowIndex, 0, totalStyle);
        rowIndex++;

        /// ================= HEADER ROW =================
        List headers = [
          "Date", // 0
          "Present", // 1
          "In_Time", // 2
          "Out_Time", // 3
          "Work Hours", // 4
          "Absent", // 5
          "Late", // 6
          "Late By", // 7
          "Permission", // 8
          "Permission_In", // 9
          "Permission_Out", // 10
          "Permission Hours", // 11 (after half-day conversion)
          "Half Day (Perm)", // 12
          "Permission Reason", // 13
          "Leave", // 14
          "Leave Reason", // 15
        ];

        for (int col = 0; col < headers.length; col++) {
          bufVal(rowIndex, col, headers[col]);
          bufStyle(rowIndex, col, headerStyle);
        }
        rowIndex++;

        int totalPresent = 0;
        int totalAbsent = 0;
        int totalAbsentAsLeave = 0; // check-in illatha naatkal (summary-la Leave)
        int totalLateDays = 0;
        int totalLateMinutes = 0;
        int totalPermission = 0;
        double totalHalfDay = 0;
        double totalLeave = 0;
        int totalWorkMinutes = 0;
        int totalPermissionMinutes = 0;

        /// ================= DATE LOOP =================
        for (String d in dates) {
          final List<Map<String, dynamic>> dayRows =
              rowsByEmpDay["$emp|$d"] ?? const [];
          final Map<String, dynamic>? record =
          dayRows.isNotEmpty ? dayRows.first : null;

          int present = 0;
          int absent = 0;
          int late = 0;
          int lateMinutes = 0;
          int permission = 0;
          double leaveCount = 0;
          double halfDayLeave = 0;
          String reason = "-";

          String inTime = "-";
          String outTime = "-";
          String perIn = "-";
          String perOut = "-";
          String perReason = "-";

          Map<String, dynamic> weekendInfo = getWeekendInfo(d);
          bool isWeekend = weekendInfo["isWeekend"] as bool;
          String weekendLabel = weekendInfo["label"] as String;

          /// true only when the employee actually applied leave on a working day
          bool isAppliedLeave = false;

          /// check-in illa + leave apply illa -> Absent (summary-la Leave)
          bool isNoCheckInDay = false;

          if (isWeekend) {
            // Sunday / 3rd Saturday -> week off
            leaveCount = 1;
            reason = weekendLabel;
          } else if (record != null) {
            present = int.tryParse(record["present"]?.toString() ?? "0") ?? 0;
            absent = int.tryParse(record["absent"]?.toString() ?? "0") ?? 0;

            permission = int.tryParse(
                record["permission"]?.toString() == "0" ? "0" : "1") ??
                0;

            leaveCount =
                double.tryParse(record["leave_count"]?.toString() ?? "0") ?? 0;

            reason = record["reason"]?.toString() ?? "-";

            inTime = record["in_time"]?.toString() ?? "-";
            outTime = record["out_time"]?.toString() ?? "-";

            /// if Out_Time was saved same as In_Time -> not checked out yet
            if (outTime == inTime) {
              outTime = "-";
            }

            perIn = record["per_in"]?.toString() ?? "-";
            perOut = record["per_out"]?.toString() ?? "-";
            perReason = record["permission_reason"]?.toString() ?? "-";

            if (leaveCount > 0) {
              isAppliedLeave = true;
            }
          }

          int inMin = timeToMinutes(inTime);
          int outMin = timeToMinutes(outTime);

          /// ================= LEAVE / ABSENT (check-in illa) =================
          if (!isWeekend) {
            // 1) leave apply pannirundha (check-in illanaalum) -> Leave
            final lv = findLeave(emp, d);
            if (lv != null && leaveCount == 0) {
              leaveCount = lv["days"] as double;
              reason = lv["reason"].toString();
              isAppliedLeave = true;
            }

            // 2) check-in illa + leave apply illa + past date -> Absent
            //    (detail-la Absent, summary-la Leave Taken-la serum)
            final DateTime? dayDt = DateTime.tryParse(d);
            final bool isPast = dayDt != null && dayDt.isBefore(todayStart);
            // API-la absent = 1 vandhaalum (innaiku naal-um) count aagum
            if (!isAppliedLeave && inMin == 0 && (absent == 1 || isPast)) {
              isNoCheckInDay = true;
              absent = 1;
            }

            // full day leave = absent illa
            if (leaveCount >= 1) absent = 0;
          }

          /// ================= LATE (grace 09:10, rule 09:15) =================
          /// 09:10 varaikum -> 0
          /// 09:11 - 09:15  -> check-in - 09:10
          /// 09:16 +        -> check-in - 09:00 (grace minus illa)
          final int lateStart =
          inMin <= _graceLimitMin ? _graceEndMin : _officeStartMin;
          int lateRaw = 0;
          if (!isWeekend &&
              !(isAppliedLeave && leaveCount >= 1) &&
              inMin > _graceEndMin) {
            lateRaw = inMin - lateStart;
          }

          /// ================= WORK HOURS =================
          int workMinutes = 0;
          if (inMin > 0 && outMin > 0 && outMin > inMin) {
            workMinutes = outMin - inMin;
          }

          /// ================= PERMISSION =================
          final List<List<String>> permPairs = getPermissionPairs(dayRows);

          int permissionMinutes = 0; // applied permission (grace minus illa)
          for (final p in permPairs) {
            final a = anyTimeToMinutes(p[0]);
            final b = anyTimeToMinutes(p[1]);
            // 5 mins-ku kammi (thappa apply panni udane off) ignore
            if (a > 0 && b > a + 5) permissionMinutes += (b - a);
          }

          // applied permission already cover panna late time-a double count panna koodathu
          int lateCovered = 0;
          if (lateRaw > 0) {
            for (final p in permPairs) {
              final a = anyTimeToMinutes(p[0]);
              final b = anyTimeToMinutes(p[1]);
              if (a <= 0 || b <= a + 5) continue;
              final from = a > lateStart ? a : lateStart;
              final to = b < inMin ? b : inMin;
              if (to > from) lateCovered += (to - from);
            }
          }
          final int latePermMinutes =
          (lateRaw - lateCovered) > 0 ? (lateRaw - lateCovered) : 0;

          if (lateRaw > 0) {
            late = 1;
            lateMinutes = lateRaw;
          }
          if (latePermMinutes > 0) {
            permissionMinutes += latePermMinutes; // late time = permission
          }

          // sheet-la kaattura In / Out (rendu permission irundha " / " vechu)
          final List<List<String>> validPairs = permPairs
              .where((p) =>
          anyTimeToMinutes(p[0]) > 0 &&
              anyTimeToMinutes(p[1]) > anyTimeToMinutes(p[0]) + 5)
              .toList();
          if (latePermMinutes > 0) {
            validPairs.add([
              inMin <= _graceLimitMin ? "09:10:00" : "09:00:00",
              inTime
            ]);
          }
          if (validPairs.isNotEmpty) {
            perIn = validPairs.map((p) => formatTime12(p[0])).join(" / ");
            perOut = validPairs.map((p) => formatTime12(p[1])).join(" / ");
          }

          int permissionCounted = permissionMinutes; // after half-day conversion
          while (permissionCounted > _permHalfDayLimitMin) {
            halfDayLeave += 0.5;
            permissionCounted -= _permHalfDayLimitMin;
          }
          permission = permissionCounted > 0 ? 1 : 0;

          String permissionHoursDisplay =
          (permissionMinutes > 0 && permissionCounted > 0)
              ? minutesToHourFormat(permissionCounted)
              : "-";

          String permissionReasonDisplay = perReason;
          if (latePermMinutes > 0) {
            final lateTxt = "Late (${durationText(latePermMinutes)})";
            permissionReasonDisplay = (perReason == "-" || perReason.isEmpty)
                ? lateTxt
                : "$perReason + $lateTxt";
          }
          if (halfDayLeave > 0) {
            permissionReasonDisplay =
            "$permissionReasonDisplay (Total ${minutesToHourFormat(permissionMinutes)} -> Half Day + ${minutesToHourFormat(permissionCounted)} Permission)";
          }

          String workHoursDisplay =
          workMinutes > 0 ? minutesToHourFormat(workMinutes) : "-";

          totalWorkMinutes += workMinutes;
          totalPermissionMinutes += permissionCounted;

          /// ================= FILL ROW (buffered) =================
          void put(int col, dynamic v) => bufVal(rowIndex, col, v);

          put(0, formatDate(d));
          put(1, present);
          put(2, formatTime12(inTime));
          put(3, formatTime12(outTime));
          put(4, workHoursDisplay);
          put(5, absent);
          put(6, late);
          put(7, late == 1 ? durationText(lateMinutes) : "-");
          put(8, permission);
          put(9, formatTime12(perIn));
          put(10, formatTime12(perOut));
          put(11, permissionHoursDisplay);
          put(12, numOut(halfDayLeave));
          put(13, permissionReasonDisplay);
          put(14, numOut(leaveCount));
          put(15, reason);

          /// Priority: Weekend -> Applied Leave -> Absent -> Late / HalfDay -> Normal
          CellStyle rowStyle = isWeekend
              ? weekOffStyle
              : (isAppliedLeave
              ? leaveStyle
              : (isNoCheckInDay
              ? absentStyle
              : ((late == 1 || halfDayLeave > 0)
              ? lateStyle
              : normalStyle)));

          for (int col = 0; col <= lastCol; col++) {
            bufStyle(rowIndex, col, rowStyle);
          }

          rowIndex++;

          totalPresent += present;
          totalAbsent += absent;
          if (isNoCheckInDay) totalAbsentAsLeave += 1;
          totalLateDays += late;
          totalLateMinutes += lateMinutes;
          totalPermission += permission;
          totalHalfDay += halfDayLeave;

          // only APPLIED leaves (not Sunday / 3rd Saturday week-off)
          if (isAppliedLeave) {
            totalLeave += leaveCount;
          }
        }

        /// ================= TOTAL ROW (buffered) =================
        void putTotal(int col, dynamic v) {
          bufVal(rowIndex, col, v);
          bufStyle(rowIndex, col, totalStyle);
        }

        for (int col = 0; col <= lastCol; col++) {
          putTotal(col, "");
        }
        putTotal(0, "Total");
        putTotal(1, totalPresent);
        putTotal(4, minutesToHourFormat(totalWorkMinutes));
        putTotal(5, totalAbsent);
        putTotal(6, totalLateDays);
        putTotal(7, durationText(totalLateMinutes));
        putTotal(8, totalPermission);
        putTotal(11, minutesToHourFormat(totalPermissionMinutes));
        putTotal(12, numOut(totalHalfDay));
        putTotal(14, numOut(totalLeave));

        rowIndex++;
        rowIndex++; // gap row

        /// ================= collect for Summary =================
        summaryRows.add({
          "name": emp,
          "leave": totalLeave,
          "halfDay": totalHalfDay,
          "absentLeave": totalAbsentAsLeave,
          "permMinutes": totalPermissionMinutes,
        });
      }

      /// ======================================================================
      /// ✅ ORDER MATTERS:
      ///   1) summary -> buffer (rows 0..n)   [summaryRows ippo fill aagiduchu]
      ///   2) buffer (summary + details) -> sheet, sorted row order
      /// ======================================================================
      print("EXCEL v3: summaryRows=${summaryRows.length}, employees=${employees.length}, detailStartRow=$detailStartRow, bufferedRows=${cellBuf.length}");
      writeSummary(); // summary -> buffer
      flushBuffer(sheet); // summary + details, ellam sorted row order-la
      print("EXCEL v3: sheet.maxRows=${sheet.maxRows}");

      /// ================= SAVE / DOWNLOAD =================
      final bytes = excel.encode();
      final String fileName =
          "${constValue.appName}_Attendance_Report_${formatDate(startDate)}_to_${formatDate(endDate)}.xlsx";

      if (bytes != null) {
        if (kIsWeb) {
          _downloadExcelWebFile(bytes, fileName);
        } else {
          await _saveExcelMobile(bytes, fileName, context);
        }
      }
    } catch (e, st) {
      print("Excel Error => $e\n$st");
      utils.showWarningToast(context, text: "Something went wrong");
    }
  }

  String timeDifference(String dateTimeString1, String dateTimeString2) {
    DateTime startTime = DateTime.parse(dateTimeString1);
    DateTime endTime = DateTime.parse(dateTimeString2);

    Duration difference = endTime.difference(startTime);

    int hours = difference.inHours;
    int minutes = difference.inMinutes % 60;

    if (hours == 0) {
      return "$minutes mins";
    } else if (minutes == 0) {
      return "$hours hrs";
    } else {
      return "$hours hrs $minutes mins";
    }
  }

  Future<void> userPayrollExport(List<Map<String, dynamic>> list,
      bool isSingleUser, String? userName, String? monthName, String? yearName) async {
    final Workbook workbook = Workbook();
    final Worksheet worksheet = workbook.worksheets[0];
    worksheet.getRangeByName('A1:V1').merge();
    worksheet.getRangeByName('A1:V1').cellStyle.hAlign = HAlignType.center;
    worksheet.getRangeByName('A2:V2').cellStyle.hAlign = HAlignType.center;
    worksheet.getRangeByName('A1').cellStyle.bold = true;
    worksheet.getRangeByName('A1').cellStyle.fontSize = 10;
    worksheet.getRangeByName('A2:V2').cellStyle.bold = true;
    worksheet.getRangeByName('A2:V2').cellStyle.fontSize = 10;
    worksheet.getRangeByName('A2:V2').columnWidth = 10;
    worksheet.getRangeByName('B2').columnWidth = 20;
    worksheet.getRangeByName('C2').columnWidth = 30;
    worksheet.getRangeByName('D2').columnWidth = 15;
    worksheet.getRangeByName('E2').columnWidth = 15;
    worksheet.getRangeByName('I2').columnWidth = 8;
    worksheet.getRangeByName('J2').columnWidth = 8;
    worksheet.getRangeByName('T2').columnWidth = 20;
    worksheet.getRangeByName('R2').columnWidth = 20;
    worksheet.getRangeByName('O2').columnWidth = 20;
    worksheet.getRangeByName('P2').columnWidth = 20;
    worksheet.getRangeByName('Q2').columnWidth = 20;
    worksheet.getRangeByName('U2').columnWidth = 20;
    worksheet.getRangeByName('W2').columnWidth = 30;
    worksheet.getRangeByName('X2').columnWidth = 20;
    worksheet.getRangeByName('Y2').columnWidth = 20;
    worksheet.getRangeByName('L2').columnWidth = 20;
    worksheet.getRangeByName('S2').columnWidth = 30;
    worksheet.getRangeByName('A2:V2').cellStyle.backColor = '#CA1617';
    worksheet.getRangeByName('A2:V2').cellStyle.fontColor = '#ffffff';
    worksheet.getRangeByName("A1").setText(
        "${constValue.appName} - Payroll Report - $monthName - $yearName ${isSingleUser == true ? " - $userName" : ""}");
    worksheet.getRangeByName("A2").setText("S.no");
    worksheet.getRangeByName("B2").setText("Role");
    worksheet.getRangeByName("C2").setText("Employee Name");
    worksheet.getRangeByName("D2").setText("Employee Number");
    worksheet.getRangeByName("E2").setText("Salary");
    worksheet.getRangeByName("F2").setText("Duty");
    worksheet.getRangeByName("G2").setText("Overtime");
    worksheet.getRangeByName("H2").setText("Basic+DA");
    worksheet.getRangeByName("I2").setText("HRA");
    worksheet.getRangeByName("J2").setText("CONV");
    worksheet.getRangeByName("K2").setText("WA");
    worksheet.getRangeByName("L2").setText("Total Earn");
    worksheet.getRangeByName("M2").setText("ESI");
    worksheet.getRangeByName("N2").setText("PF");
    worksheet.getRangeByName("O2").setText("Add Categories Amount");
    worksheet.getRangeByName("P2").setText("Deduct Categories Amount");
    worksheet.getRangeByName("Q2").setText("Total Deduction");
    worksheet.getRangeByName("R2").setText("Net Amounts");
    worksheet.getRangeByName("S2").setText("SIGNATURE");
    worksheet.getRangeByName("T2").setText("BANK ACCOUNT HOLDER NAME");
    worksheet.getRangeByName("U2").setText("ACCOUNT NUMBER");
    worksheet.getRangeByName("V2").setText("IFSC CODE");
    for (var i = 0; i < list.length; i++) {
      worksheet.getRangeByIndex(i + 3, 1).setNumber(i + 1);
      worksheet.getRangeByIndex(i + 3, 2).setText(list[i]["Role"]);
      worksheet.getRangeByIndex(i + 3, 3).setText(list[i]["Name"]);
      worksheet.getRangeByIndex(i + 3, 4).setText(list[i]["Number"]);
      if (list[i]["Salary"].toString() == "" ||
          list[i]["Salary"].toString() == "null" ||
          list[i]["Salary"].toString() == "0") {
        worksheet.getRangeByIndex(i + 3, 5).setText("0");
      } else {
        worksheet
            .getRangeByIndex(i + 3, 5)
            .setNumber(double.parse(list[i]["Salary"].toString()));
      }
      worksheet.getRangeByIndex(i + 3, 6).setNumber(double.parse(list[i]["Duty"]));
      worksheet.getRangeByIndex(i + 3, 7).setNumber(double.parse(list[i]["OT"]));
      worksheet.getRangeByIndex(i + 3, 8).setNumber(double.parse(list[i]["Basic+DA"]));
      worksheet.getRangeByIndex(i + 3, 9).setNumber(double.parse(list[i]["HRA"]));
      worksheet.getRangeByIndex(i + 3, 10).setText(list[i]["CONV"]);
      worksheet.getRangeByIndex(i + 3, 11).setText(list[i]["WA"]);
      worksheet.getRangeByIndex(i + 3, 12).setNumber(double.parse(list[i]["Total Earn"]));
      worksheet.getRangeByIndex(i + 3, 13).setNumber(double.parse(list[i]["ESI"]));
      worksheet.getRangeByIndex(i + 3, 14).setNumber(double.parse(list[i]["PF"]));
      worksheet.getRangeByIndex(i + 3, 15).setText(list[i]["Categories1"]);
      worksheet.getRangeByIndex(i + 3, 16).setText(list[i]["Categories2"]);
      worksheet.getRangeByIndex(i + 3, 17).setNumber(double.parse(list[i]["Total DED"]));
      worksheet.getRangeByIndex(i + 3, 18).setNumber(double.parse(list[i]["NET Amount"]));
      worksheet.getRangeByIndex(i + 3, 19).setText(list[i]["SIGNATURE"]);
      worksheet.getRangeByIndex(i + 3, 20).setText(
          list[i]["bank_name"].toString() == "null" ? "" : list[i]["bank_name"].toString());
      worksheet.getRangeByIndex(i + 3, 21).setText(
          list[i]["acc_no"].toString() == "null" ? "" : list[i]["acc_no"].toString());
      worksheet.getRangeByIndex(i + 3, 22).setText(
          list[i]["ifsc_code"].toString() == "null" ? "" : list[i]["ifsc_code"].toString());
    }
    final List<int> bytes = workbook.saveAsStream();
    if (kIsWeb) {
      AnchorElement(
          href:
          'data:application/octet-stream;charset-utf-161e;base64,${base64.encode(bytes)}')
        ..setAttribute('download', '${constValue.appName} report.xlsx')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String filename =
          '$path/${constValue.appName}_payroll_report_${monthName}_$yearName.xlsx';
      final File file = File(filename);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(filename);
    }
  }
}