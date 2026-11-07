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
  static const int _officeStartMin = 9 * 60;       // 09:00 AM  ("Late By" is counted from here)
  static const int _graceEndMin = 9 * 60 + 10;     // 09:10 AM  (late only AFTER this)
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

  Future<void> _saveExcelMobile(
      List<int> bytes, String filename, context) async {
    final dir = await getExternalStorageDirectory();
    final path = '${dir!.path}/$filename';

    File file = File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes);

    final result = await OpenFile.open(path);

    if (result.type != ResultType.done) {
      utils.showWarningToast(context, text: "No app found to open the file.");
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

  Future<void> downloadAttendanceExcelReport(context,
      {required String stDate, required String enDate}) async {
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
      if (response.isNotEmpty) {
        await exportAttendanceSingleSheetExcel(
          context,
          attendanceList: response,
          leaveList: [],
          startDate: stDate,
          endDate: enDate,
        );
      } else {
        utils.showWarningToast(context, text: "No data found");
      }
    } catch (e) {
      print("Attendance Excel Error => $e");
      utils.showWarningToast(context, text: "Something went wrong");
    }
  }

  /// ==========================================================================
  /// ATTENDANCE REPORT (2 sheets)
  ///  1) "Summary"    -> Month + Working Days, then Employee | Leave | Permission
  ///  2) "Attendance" -> employee-wise day-by-day detail (Late By, 4 hrs rule ...)
  ///
  /// RULES
  ///  - Grace time 09:10 AM. Late only when check-in is AFTER 09:10.
  ///  - "Late By" = check-in time minus 09:00 AM.
  ///  - Permission up to 4 hrs  -> stays Permission.
  ///  - Permission above 4 hrs  -> every 4 hrs = 0.5 Half Day Leave,
  ///    remaining stays Permission (6 hrs = Half Day + 2 hrs Permission).
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
      excel.delete('Sheet1');

      Sheet summarySheet = excel["Summary"];
      Sheet sheet = excel["Attendance"];

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
        if (item["date"] != null) dateSet.add(item["date"]);
      }

      List<String> employees = employeeSet.toList()..sort();
      List<String> dates = dateSet.toList()..sort();

      /// WORKING DAYS = total days in range - (Sunday / 3rd Saturday)
      int totalDaysInRange = dates.length;
      int weekOffDaysCount = dates.where((d) {
        Map<String, dynamic> info = getWeekendInfo(d);
        return info["isWeekend"] as bool;
      }).length;
      int workingDaysCount = totalDaysInRange - weekOffDaysCount;

      /// per-employee totals (used for the Summary sheet)
      final List<Map<String, dynamic>> summaryRows = [];

      const int lastCol = 15; // last column index of the detail sheet

      int rowIndex = 0;

      for (String emp in employees) {
        /// ================= TITLE ROW =================
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value =
        "$emp - Employee ( $startDate to $endDate ) Attendance Report";
        sheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
          CellIndex.indexByColumnRow(columnIndex: lastCol, rowIndex: rowIndex),
        );
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .cellStyle = titleStyle;
        rowIndex++;

        /// ================= WORKING DAYS ROW =================
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value =
        "Total Days: $totalDaysInRange   |   Week Off (Sun/3rd Sat): $weekOffDaysCount   |   Working Days: $workingDaysCount   |   Grace: 09:10 AM";
        sheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
          CellIndex.indexByColumnRow(columnIndex: lastCol, rowIndex: rowIndex),
        );
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .cellStyle = totalStyle;
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
          var c = sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex));
          c.value = headers[col];
          c.cellStyle = headerStyle;
        }
        rowIndex++;

        int totalPresent = 0;
        int totalAbsent = 0;
        int totalLateDays = 0;
        int totalLateMinutes = 0;
        int totalPermission = 0;
        double totalHalfDay = 0;
        double totalLeave = 0;
        int totalWorkMinutes = 0;
        int totalPermissionMinutes = 0;

        /// ================= DATE LOOP =================
        for (String d in dates) {
          Map<String, dynamic>? record;
          try {
            record = attendanceList.firstWhere(
                  (e) => e["firstname"] == emp && e["date"] == d,
            );
          } catch (e) {
            record = null;
          }

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

          /// ================= LATE (grace till 09:10) =================
          int inMin = timeToMinutes(inTime);
          int outMin = timeToMinutes(outTime);

          if (!isWeekend && !isAppliedLeave && inMin > _graceEndMin) {
            late = 1;
            lateMinutes = inMin - _officeStartMin;
          }

          /// ================= WORK HOURS =================
          int workMinutes = 0;
          if (inMin > 0 && outMin > 0 && outMin > inMin) {
            workMinutes = outMin - inMin;
          }

          /// ================= PERMISSION (4 hrs rule) =================
          int perInMin = timeToMinutes(perIn);
          int perOutMin = timeToMinutes(perOut);

          int permissionMinutes = 0; // actual permission taken
          if (perInMin > 0 && perOutMin > 0 && perOutMin > perInMin) {
            permissionMinutes = perOutMin - perInMin;
          }

          int permissionCounted = permissionMinutes; // after half-day conversion
          if (permissionMinutes > _permHalfDayLimitMin) {
            while (permissionCounted > _permHalfDayLimitMin) {
              halfDayLeave += 0.5;
              permissionCounted -= _permHalfDayLimitMin;
            }
            permission = permissionCounted > 0 ? 1 : 0;
          }

          String permissionHoursDisplay =
          (permissionMinutes > 0 && permissionCounted > 0)
              ? minutesToHourFormat(permissionCounted)
              : "-";

          String permissionReasonDisplay = perReason;
          if (halfDayLeave > 0) {
            permissionReasonDisplay =
            "$perReason (Total ${minutesToHourFormat(permissionMinutes)} -> Half Day + ${minutesToHourFormat(permissionCounted)} Permission)";
          }

          String workHoursDisplay =
          workMinutes > 0 ? minutesToHourFormat(workMinutes) : "-";

          totalWorkMinutes += workMinutes;
          totalPermissionMinutes += permissionCounted;

          /// ================= FILL ROW =================
          void put(int col, dynamic v) {
            sheet
                .cell(CellIndex.indexByColumnRow(
                columnIndex: col, rowIndex: rowIndex))
                .value = v;
          }

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

          /// Priority: Weekend -> Applied Leave -> Late / HalfDay -> Normal
          CellStyle rowStyle = isWeekend
              ? weekOffStyle
              : (isAppliedLeave
              ? leaveStyle
              : ((late == 1 || halfDayLeave > 0) ? lateStyle : normalStyle));

          for (int col = 0; col <= lastCol; col++) {
            sheet
                .cell(CellIndex.indexByColumnRow(
                columnIndex: col, rowIndex: rowIndex))
                .cellStyle = rowStyle;
          }

          rowIndex++;

          totalPresent += present;
          totalAbsent += absent;
          totalLateDays += late;
          totalLateMinutes += lateMinutes;
          totalPermission += permission;
          totalHalfDay += halfDayLeave;

          // only APPLIED leaves (not Sunday / 3rd Saturday week-off)
          if (isAppliedLeave) {
            totalLeave += leaveCount;
          }
        }

        /// ================= TOTAL ROW =================
        void putTotal(int col, dynamic v) {
          var c = sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex));
          c.value = v;
          c.cellStyle = totalStyle;
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

        /// ================= collect for Summary sheet =================
        summaryRows.add({
          "name": emp,
          "leave": totalLeave,
          "halfDay": totalHalfDay,
          "permMinutes": totalPermissionMinutes,
        });
      }

      /// ======================================================================
      /// ================= SUMMARY SHEET (matches the image) ==================
      /// ======================================================================

      // title: "September2026" (single month) or "date to date"
      String monthTitle;
      try {
        final DateTime s = DateTime.parse(startDate);
        final DateTime e = DateTime.parse(endDate);
        monthTitle = (s.year == e.year && s.month == e.month)
            ? DateFormat('MMMMyyyy').format(s)
            : "${formatDate(startDate)} to ${formatDate(endDate)}";
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

      CellStyle sTitleLeft = CellStyle(
        bold: true,
        fontSize: 14,
        fontColorHex: "#4A86E8",
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
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center,
        leftBorder: thin,
        rightBorder: thin,
        topBorder: thin,
        bottomBorder: thin,
      );
      CellStyle sCell = CellStyle(
        horizontalAlign: HorizontalAlign.Left,
        verticalAlign: VerticalAlign.Center,
        leftBorder: thin,
        rightBorder: thin,
        topBorder: thin,
        bottomBorder: thin,
      );

      summarySheet.setColWidth(0, 28);
      summarySheet.setColWidth(1, 24);
      summarySheet.setColWidth(2, 30);

      // header row: A1:B1 merged (month), C1 (working days)
      summarySheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = monthTitle;
      summarySheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0),
      );
      summarySheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .cellStyle = sTitleLeft;
      summarySheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .cellStyle = sTitleLeft;

      summarySheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
          .value = "Working Days: $workingDaysCount";
      summarySheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
          .cellStyle = sTitleRight;

      // employee rows: Name | Leave | Permission
      int sRow = 1;
      for (final s in summaryRows) {
        // total leave = applied leave + half day(s) made from permission > 4 hrs
        final double totalLeaveDays =
            (s["leave"] as double) + (s["halfDay"] as double);

        final List<String> vals = [
          s["name"].toString(),
          leaveText(totalLeaveDays),
          permissionText(s["permMinutes"] as int),
        ];

        for (int col = 0; col < vals.length; col++) {
          var c = summarySheet.cell(
              CellIndex.indexByColumnRow(columnIndex: col, rowIndex: sRow));
          c.value = vals[col];
          c.cellStyle = sCell;
        }
        sRow++;
      }

      /// ================= SAVE / DOWNLOAD =================
      final bytes = excel.encode();
      final String fileName =
          "${constValue.appName}_Attendance_Report_${formatDate(startDate)}_to_${formatDate(endDate)}.xlsx";

      if (bytes != null) {
        if (kIsWeb) {
          _downloadExcelWebFile(bytes, fileName);
        } else {
          _saveExcelMobile(bytes, fileName, context);
        }
      }
    } catch (e) {
      print("Excel Error => $e");
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