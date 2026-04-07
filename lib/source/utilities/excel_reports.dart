import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:master_code/model/leave/leave_model.dart';
import 'package:master_code/source/constant/default_constant.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../model/attendance_model.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, CellStyle;
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../repo/customer_repo.dart';
import '../constant/api.dart';
import '../constant/local_data.dart';
// import 'dart:html' as html;  // Only used in web

final ExcelReports excelReports = ExcelReports._();

class ExcelReports {
  ExcelReports._();
  String appColor="#45377D";
  final CustomerRepository custRepo = CustomerRepository();
  Future<void> exportAttendanceToExcel(context,{required List<AttendanceModel> chunked, required String date}) async {
    try{
      // chunked.sort((a, b) =>
      //     a.createdTs!.compareTo(b.createdTs.toString()));
      chunked.sort((a, b) {
        // First sort by firstname
        int nameCompare = a.firstname!.compareTo(b.firstname!);

        // If firstname same → then sort by createdTs
        if (nameCompare == 0) {
          return a.createdTs!.compareTo(b.createdTs!);
        }

        return nameCompare;
      });

      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      /// 1️⃣ Insert empty row and merge for title
      sheetObject.insertRowIterables([''], 0);
      var firstCell = CellIndex.indexByString("A1");
      var lastCell = CellIndex.indexByString("F1");
      sheetObject.merge(firstCell, lastCell);
      sheetObject.cell(firstCell).value = '${constValue.appName} Attendance Reports $date';

      // Style for the merged heading row
      CellStyle titleStyle = CellStyle(
        bold: true,
        fontSize: 10,
      );
      sheetObject.cell(firstCell).cellStyle = titleStyle;

      /// 2️⃣ Header row with your colors
      List<String> headers = [
        'Date',
        'Employee Name',
        'Role',
        'Check In/In-Time',
        'Check Out/Out-Time',
        'Total Hours'
      ];
      sheetObject.appendRow(headers);

      // Header style with background #45377D & font white (#FFFFFF)
      CellStyle headerStyle = CellStyle(
        backgroundColorHex: appColor,
        fontColorHex: "#FFFFFF",
        fontSize: 10,
        horizontalAlign: HorizontalAlign.Center,
      );

      for (int i = 0; i < headers.length; i++) {
        var headerCell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1));
        headerCell.cellStyle = headerStyle;
      }

      /// 3️⃣ Fill rows
      for (var i = 0; i < chunked.length; i++) {
        AttendanceModel data = chunked[i];
        var inTime = "", outTime = "-", timeD = "-";
        if (data.status.toString().contains("1,2")) {
          inTime = data.time!.split(",")[0];
          outTime = data.time!.split(",")[1];
          timeD = timeDifference(data.createdTs!.split(",")[0], data.createdTs!.split(",")[1]);
        } else if (data.status.toString().contains("2,1")) {
          inTime = data.time!.split(",")[1];
          outTime = data.time!.split(",")[0];
          timeD = timeDifference(data.createdTs!.split(",")[0], data.createdTs!.split(",")[1]);
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

      // 👇 Detect if web
      if (kIsWeb) {
        // _downloadExcelWeb(bytes!, "${constValue.appName} Attendance Report.xlsx");
      } else {
        _saveExcelMobile(bytes!, "${constValue.appName} Attendance Report.xlsx", context);
      }
    }catch(e){
      utils.showWarningToast(context, text: "Something Went Wrong");
    }
  }
  Future<void> _saveExcelMobile(List<int> bytes, String filename, context) async {
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
  // void _downloadExcelWeb(List<int> bytes, String fileName) {
  //   final blob = html.Blob([bytes], 'application/vnd.ms-excel');
  //   final url = html.Url.createObjectUrlFromBlob(blob);
  //
  //   final anchor = html.AnchorElement(href: url)
  //     ..setAttribute("download", fileName)
  //     ..click();
  //
  //   html.Url.revokeObjectUrl(url);
  // }

  Future<void> exportUserAttendanceToExcel(context,{required List<AttendanceModel> chunked, required String date}) async {
    try{
      chunked.sort((a, b) =>
          a.createdTs!.compareTo(b.createdTs.toString()));
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      /// 1️⃣ Insert empty row and merge for title
      sheetObject.insertRowIterables([''], 0);
      var firstCell = CellIndex.indexByString("A1");
      var lastCell = CellIndex.indexByString("D1");
      sheetObject.merge(firstCell, lastCell);
      sheetObject.cell(firstCell).value = '${constValue.appName} ${chunked[0].firstname} ( ${chunked[0].role} ) Attendance Reports $date';

      // Style for the merged heading row
      CellStyle titleStyle = CellStyle(
        bold: true,
        fontSize: 10,
      );
      sheetObject.cell(firstCell).cellStyle = titleStyle;

      /// 2️⃣ Header row with your colors
      List<String> headers = [
        'Date',
        'In Time',
        'Out Time',
        'Total Hours'
      ];
      sheetObject.appendRow(headers);

      // Header style with background #45377D & font white (#FFFFFF)
      CellStyle headerStyle = CellStyle(
        backgroundColorHex: appColor,
        fontColorHex: "#FFFFFF",
        fontSize: 10,
        horizontalAlign: HorizontalAlign.Center,
      );

      for (int i = 0; i < headers.length; i++) {
        var headerCell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1));
        headerCell.cellStyle = headerStyle;
      }

      /// 3️⃣ Fill rows
      for (var i = 0; i < chunked.length; i++) {
        AttendanceModel data = chunked[i];
        var inTime = "", outTime = "-", timeD = "-";
        if (data.status.toString().contains("1,2")) {
          inTime = data.time!.split(",")[0];
          outTime = data.time!.split(",")[1];
          timeD = timeDifference(data.createdTs!.split(",")[0], data.createdTs!.split(",")[1]);
        } else if (data.status.toString().contains("2,1")) {
          inTime = data.time!.split(",")[1];
          outTime = data.time!.split(",")[0];
          timeD = timeDifference(data.createdTs!.split(",")[0], data.createdTs!.split(",")[1]);
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
      // 👇 Detect if web
      if (kIsWeb) {
        // _downloadExcelWeb(bytes!, "${constValue.appName} ${chunked[0].firstname} Attendance Report.xlsx");
      } else {
        _saveExcelMobile(bytes!, "${constValue.appName} ${chunked[0].firstname} Attendance Report.xlsx", context);
      }
    }catch(e){
      utils.showWarningToast(context, text: "Something Went Wrong");
    }
  }
  //
  Future<void> downloadAttendanceExcelReport(context,{required String stDate, required String enDate}) async {
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
      final response = await custRepo.getDashboardReport(data);
      if (response.isNotEmpty) {
        exportAttendanceSingleSheetExcel(
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
  }//
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
          if (time == null || time.isEmpty) return "-";
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

      /// ================= HEADER STYLE =================
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

      /// ================= GROUP EMPLOYEE WISE =================
      Set<String> employeeSet = {};
      Set<String> dateSet = {};

      for (var item in attendanceList) {
        if (item["firstname"] != null) employeeSet.add(item["firstname"]);
        if (item["date"] != null) dateSet.add(item["date"]);
      }

      List<String> employees = employeeSet.toList()..sort();
      List<String> dates = dateSet.toList()..sort();

      int rowIndex = 0;

      for (String emp in employees) {
        /// ================= TITLE ROW =================
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value =
        "$emp - Employee ( $startDate to $endDate ) Attendance Report";

        sheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
          CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: rowIndex),
        );

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .cellStyle = titleStyle;

        rowIndex++;

        /// ================= HEADER ROW =================
        List headers = [
          "Date",
          "Present",
          "In_Time",
          "Out_Time",
          "Work Hours", // ⭐ NEW
          "Absent",
          "Late",
          "Permission",
          "Permission_In",
          "Permission_Out",
          "Permission Hours", // ⭐ NEW
          "Permission Reason",
          "Leave",
          "Leave Reason",
        ];

        for (int col = 0; col < headers.length; col++) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex))
              .value = headers[col];

          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex))
              .cellStyle = headerStyle;
        }

        rowIndex++;

        int totalPresent = 0;
        int totalAbsent = 0;
        int totalLate = 0;
        int totalPermission = 0;
        int totalLeave = 0;

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
          int permission = 0;
          int leaveCount = 0;
          String reason = "-";

          String inTime = "-";
          String outTime = "-";
          String perIn = "-";
          String perOut = "-";
          String perReason = "-";

          if (record != null) {
            present = int.tryParse(record["present"]?.toString() ?? "0") ?? 0;
            absent = int.tryParse(record["absent"]?.toString() ?? "0") ?? 0;
            late = int.tryParse(record["late"]?.toString() ?? "0") ?? 0;

            permission = int.tryParse(
                record["permission"]?.toString() == "0" ? "0" : "1") ??
                0;

            leaveCount =
                int.tryParse(record["leave_count"]?.toString() ?? "0") ?? 0;

            reason = record["reason"]?.toString() ?? "-";

            inTime = record["in_time"]?.toString() ?? "-";
            outTime = record["out_time"]?.toString() ?? "-";

            perIn = record["per_in"]?.toString() ?? "-";
            perOut = record["per_out"]?.toString() ?? "-";

            perReason = record["permission_reason"]?.toString() ?? "-";
          }

          /// ================= WORK HOURS CALC =================
          int workMinutes = 0;
          int inMin = timeToMinutes(inTime);
          int outMin = timeToMinutes(outTime);

          if (inMin > 0 && outMin > 0 && outMin > inMin) {
            workMinutes = outMin - inMin;
          }

          /// ================= PERMISSION HOURS CALC =================
          int permissionMinutes = 0;
          int perInMin = timeToMinutes(perIn);
          int perOutMin = timeToMinutes(perOut);

          if (perInMin > 0 && perOutMin > 0 && perOutMin > perInMin) {
            permissionMinutes = perOutMin - perInMin;
          }

          totalWorkMinutes += workMinutes;
          totalPermissionMinutes += permissionMinutes;

          /// ================= Fill Row Values =================
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
              .value = formatDate(d);

          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
              .value = present;

          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
              .value = formatTime12(inTime);

          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
              .value = formatTime12(outTime);

          /// ⭐ Work Hours
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
              .value = minutesToHourFormat(workMinutes);

          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
              .value = absent;

          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
              .value = late;

          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
              .value = permission;

          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
              .value = formatTime12(perIn);

          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex))
              .value = formatTime12(perOut);

          /// ⭐ Permission Hours
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex))
              .value = minutesToHourFormat(permissionMinutes);

          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex))
              .value = perReason;

          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: rowIndex))
              .value = leaveCount;

          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: rowIndex))
              .value = reason;

          /// Apply Normal Style
          for (int col = 0; col <= 13; col++) {
            sheet
                .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex))
                .cellStyle = normalStyle;
          }

          rowIndex++;

          totalPresent += present;
          totalAbsent += absent;
          totalLate += late;
          totalPermission += permission;
          totalLeave += leaveCount;
        }

        /// ================= TOTAL ROW =================
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = "Total";

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = totalPresent;

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = "";

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = "";

        /// ⭐ TOTAL WORK HOURS
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = minutesToHourFormat(totalWorkMinutes);

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = totalAbsent;

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
            .value = totalLate;

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
            .value = totalPermission;

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
            .value = "";

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex))
            .value = "";

        /// ⭐ TOTAL PERMISSION HOURS
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex))
            .value = minutesToHourFormat(totalPermissionMinutes);

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex))
            .value = "";

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: rowIndex))
            .value = totalLeave;

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: rowIndex))
            .value = "";

        /// Total Row Style
        for (int col = 0; col <= 13; col++) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex))
              .cellStyle = totalStyle;
        }

        rowIndex++;

        /// gap row
        rowIndex++;
      }

      final bytes = excel.encode();

      if (!kIsWeb && bytes != null) {
        _saveExcelMobile(
          bytes,
          "JPS_Attendance_Report_${formatDate(startDate)}_to_${formatDate(endDate)}.xlsx",
          context,
        );
      }
    } catch (e) {
      print("Excel Error => $e");
      utils.showWarningToast(context, text: "Something went wrong");
    }
  }
  // Future<void> exportAttendanceSingleSheetExcel(
  //     context, {
  //       required List attendanceList,
  //       required List leaveList,
  //       required String startDate,
  //       required String endDate,
  //     })
  // async {
  //   try {
  //     var excel = Excel.createExcel();
  //     excel.delete('Sheet1');
  //
  //     Sheet sheet = excel["Sheet1"];
  //
  //     String formatDate(String? input) {
  //       try {
  //         if (input == null || input.isEmpty) return "-";
  //         return DateFormat('dd-MM-yyyy').format(DateTime.parse(input));
  //       } catch (e) {
  //         return input ?? "-";
  //       }
  //     }
  //
  //     /// ================= HEADER STYLE =================
  //     CellStyle headerStyle = CellStyle(
  //       bold: true,
  //       backgroundColorHex: "#45377D",
  //       fontColorHex: "#FFFFFF",
  //       horizontalAlign: HorizontalAlign.Center,
  //     );
  //
  //     CellStyle titleStyle = CellStyle(
  //       bold: true,
  //       horizontalAlign: HorizontalAlign.Left,
  //     );
  //
  //     CellStyle totalStyle = CellStyle(
  //       bold: true,
  //       horizontalAlign: HorizontalAlign.Center,
  //       backgroundColorHex: "#FFF2CC",
  //     );
  //     CellStyle totalStyle1 = CellStyle(
  //       bold: true,
  //       backgroundColorHex: "#FFFFFF", // White
  //       fontColorHex: "#000000",
  //       horizontalAlign: HorizontalAlign.Center,
  //       verticalAlign: VerticalAlign.Center,
  //     );
  //     /// ✅ DATA ROW FULL YELLOW STYLE
  //
  //     /// ================= GROUP EMPLOYEE WISE =================
  //     Set<String> employeeSet = {};
  //     Set<String> dateSet = {};
  //
  //     for (var item in attendanceList) {
  //       if (item["firstname"] != null) employeeSet.add(item["firstname"]);
  //       if (item["date"] != null) dateSet.add(item["date"]);
  //     }
  //
  //     List<String> employees = employeeSet.toList()..sort();
  //     List<String> dates = dateSet.toList()..sort();
  //
  //     int rowIndex = 0;
  //
  //     for (String emp in employees) {
  //       /// ================= TITLE ROW =================
  //       sheet
  //           .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
  //           .value = "$emp - Employee ( $startDate to $endDate ) Attendance Report";
  //
  //       /// merge A to H
  //       sheet.merge(
  //         CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
  //         CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex),
  //       );
  //
  //       sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
  //           .cellStyle = titleStyle;
  //
  //       rowIndex++;
  //
  //       /// ================= HEADER ROW =================
  //       List headers = [
  //         "Date",
  //         "Present",
  //         "In_Time",
  //         "Out_Time",
  //         "Absent",
  //         "Late",
  //         "Permission",
  //         "Permission_In",
  //         "Permission_Out",
  //         "Permission Reason",
  //         "Leave",
  //         "Leave Reason",
  //       ];
  //
  //       for (int col = 0; col < headers.length; col++) {
  //         sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex))
  //             .value = headers[col];
  //
  //         sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex))
  //             .cellStyle = headerStyle;
  //       }
  //
  //       rowIndex++;
  //
  //       int totalPresent = 0;
  //       int totalAbsent = 0;
  //       int totalLate = 0;
  //       int totalPermission = 0;
  //       int totalLeave = 0;
  //       int totalMinutes = 0;
  //
  //       /// ================= DATE LOOP =================
  //       for (String d in dates) {
  //         Map<String, dynamic>? record;
  //
  //         try {
  //           record = attendanceList.firstWhere(
  //                 (e) => e["firstname"] == emp && e["date"] == d,
  //           );
  //         } catch (e) {
  //           record = null;
  //         }
  //
  //         int present = 0;
  //         int absent = 0;
  //         int late = 0;
  //         int permission = 0;
  //         int leaveCount = 0;
  //         String totalHour = "0h 0m";
  //         String reason = "-";
  //
  //         if (record != null) {
  //           present = int.tryParse(record["present"]?.toString() ?? "0") ?? 0;
  //           absent = int.tryParse(record["absent"]?.toString() ?? "0") ?? 0;
  //           late = int.tryParse(record["late"]?.toString() ?? "0") ?? 0;
  //           permission =
  //               int.tryParse(record["permission"]!.toString() == "0"? "0" :"1") ?? 0;
  //
  //           leaveCount =
  //               int.tryParse(record["leave_count"]?.toString() ?? "0") ?? 0;
  //
  //           reason = record["reason"]?.toString() ?? "-";
  //           totalHour = record["total_hour"]?.toString() ?? "0h 0m";
  //
  //           if (totalHour.contains("h") && totalHour.contains("m")) {
  //             try {
  //               int h = int.parse(totalHour.split("h")[0].trim());
  //               int m = int.parse(
  //                 totalHour.split("h")[1].replaceAll("m", "").trim(),
  //               );
  //               totalMinutes += (h * 60) + m;
  //             } catch (e) {}
  //           }
  //         }
  //         String formatTime12(String? time) {
  //           try {
  //             if (time == null || time.isEmpty) return "-";
  //
  //             DateTime parsedTime = DateFormat("HH:mm:ss").parse(time);
  //             return DateFormat("hh:mm a").format(parsedTime); // 12-hour format
  //           } catch (e) {
  //             return time ?? "-";
  //           }
  //         }
  //         /// Fill Row Values
  //         sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value =
  //             formatDate(d);
  //
  //         sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).value =
  //             present;
  //
  //         sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex)).value =
  //             formatTime12(record?["in_time"]);
  //
  //         sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex)).value =
  //             formatTime12(record?["out_time"]);
  //
  //         sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex)).value =
  //             absent;
  //
  //         sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex)).value =
  //             late;
  //
  //         sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex)).value =
  //             permission;
  //
  //         sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex)).value =
  //             formatTime12(record?["per_in"]);
  //
  //         sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex)).value =
  //             formatTime12(record?["per_out"]);
  //
  //         sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex)).value =
  //             record?["permission_reason"] ?? "-";
  //
  //         sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex)).value =
  //             leaveCount;
  //
  //         sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex)).value =
  //             reason;
  //
  //         /// ✅ Apply Yellow Style For Full Row
  //         for (int col = 0; col <= 11; col++) {
  //           sheet
  //               .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex))
  //               .cellStyle = totalStyle1;
  //         }
  //
  //         rowIndex++;
  //
  //         totalPresent += present;
  //         totalAbsent += absent;
  //         totalLate += late;
  //         totalPermission += permission;
  //         totalLeave += leaveCount;
  //       }
  //
  //       /// ================= TOTAL HOURS =================
  //       int totalH = totalMinutes ~/ 60;
  //       int totalM = totalMinutes % 60;
  //
  //       /// ================= TOTAL ROW =================
  //       sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value = "Total";
  //
  //       /// Present
  //       sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).value = totalPresent;
  //
  //       /// In_Time → usually no total
  //       sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex)).value = "";
  //
  //       /// Out_Time → total hours
  //       sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex)).value =
  //       "";
  //
  //       /// Absent
  //       sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex)).value = totalAbsent;
  //
  //       /// Late
  //       sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex)).value = totalLate;
  //
  //       /// Permission
  //       sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex)).value = totalPermission;
  //
  //       /// Permission In → (optional count if needed)
  //       sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex)).value = "";
  //
  //       /// Permission Out → (optional)
  //       sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex)).value = "";
  //
  //       /// Permission Reason
  //       sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex)).value = "";
  //
  //       /// Leave
  //       sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex)).value = totalLeave;
  //
  //       /// Leave Reason
  //       sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex)).value = "";
  //       // sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value =
  //       // "Total";
  //       // sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).value =
  //       //     totalPresent;
  //       // sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex)).value =
  //       //     totalAbsent;
  //       // sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex)).value =
  //       //     totalLate;
  //       // sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex)).value =
  //       //     totalPermission;
  //       // sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex)).value =
  //       //     totalLeave;
  //       // sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex)).value =
  //       // "";
  //       // sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex)).value =
  //       // "${totalH}h ${totalM}m";
  //
  //       /// Total Row Style
  //       for (int col = 0; col <= 11; col++) {
  //         sheet
  //             .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex))
  //             .cellStyle = totalStyle;
  //       }
  //
  //       rowIndex++;
  //
  //       /// gap row
  //       rowIndex++;
  //     }
  //
  //     final bytes = excel.encode();
  //
  //     if (!kIsWeb && bytes != null) {
  //       _saveExcelMobile(
  //         bytes,
  //         "JPS_Attendance_Report_${formatDate(startDate)}_to_${formatDate(endDate)}.xlsx",
  //         context,
  //       );
  //     }
  //   } catch (e) {
  //     print("Excel Error => $e");
  //     utils.showWarningToast(context, text: "Something went wrong");
  //   }
  // }


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

  Future<void> userPayrollExport(List<Map<String,dynamic>> list,bool isSingleUser,String? userName,String? monthName,String? yearName)async{

    final Workbook workbook =Workbook();
    final Worksheet worksheet=workbook.worksheets[0];
    worksheet.getRangeByName('A1:V1').merge();
    worksheet.getRangeByName('A1:V1').cellStyle.hAlign= HAlignType.center;
    worksheet.getRangeByName('A2:V2').cellStyle.hAlign= HAlignType.center;
    worksheet.getRangeByName('A1').cellStyle.bold = true;worksheet.getRangeByName('A1').cellStyle.fontSize = 10;
    worksheet.getRangeByName('A2:V2').cellStyle.bold = true;worksheet.getRangeByName('A2:V2').cellStyle.fontSize = 10;
    worksheet.getRangeByName('A2:V2').columnWidth =10;
    worksheet.getRangeByName('B2').columnWidth =20;
    worksheet.getRangeByName('C2').columnWidth =30;
    worksheet.getRangeByName('D2').columnWidth =15;
    worksheet.getRangeByName('E2').columnWidth =15;
    worksheet.getRangeByName('I2').columnWidth =8;
    worksheet.getRangeByName('J2').columnWidth =8;
    worksheet.getRangeByName('T2').columnWidth =20;
    worksheet.getRangeByName('R2').columnWidth =20;
    worksheet.getRangeByName('O2').columnWidth =20;
    worksheet.getRangeByName('P2').columnWidth =20;
    worksheet.getRangeByName('Q2').columnWidth =20;
    worksheet.getRangeByName('U2').columnWidth =20;
    worksheet.getRangeByName('W2').columnWidth =30;
    worksheet.getRangeByName('X2').columnWidth =20;
    worksheet.getRangeByName('Y2').columnWidth =20;
    worksheet.getRangeByName('L2').columnWidth =20;
    worksheet.getRangeByName('S2').columnWidth =30;
    worksheet.getRangeByName('A2:V2').cellStyle.backColor='#CA1617';
    worksheet.getRangeByName('A2:V2').cellStyle.fontColor='#ffffff';
    worksheet.getRangeByName("A1").setText("${constValue.appName} - Payroll Report - $monthName - $yearName ${isSingleUser==true?" - $userName":""}");
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
    for(var i=0;i<list.length;i++){
      worksheet.getRangeByIndex(i+3,1).setNumber(i+1);
      worksheet.getRangeByIndex(i+3,2).setText(list[i]["Role"]);
      worksheet.getRangeByIndex(i+3,3).setText(list[i]["Name"]);
      worksheet.getRangeByIndex(i+3,4).setText(list[i]["Number"]);
      if(list[i]["Salary"].toString()==""||list[i]["Salary"].toString()=="null"||list[i]["Salary"].toString()=="0"){
        worksheet.getRangeByIndex(i+3,5).setText("0");
      }else{
        worksheet.getRangeByIndex(i+3,5).setNumber(double.parse(list[i]["Salary"].toString()));
      }
      worksheet.getRangeByIndex(i+3,6).setNumber(double.parse(list[i]["Duty"]));
      worksheet.getRangeByIndex(i+3,7).setNumber(double.parse(list[i]["OT"]));
      worksheet.getRangeByIndex(i+3,8).setNumber(double.parse(list[i]["Basic+DA"]));
      worksheet.getRangeByIndex(i+3,9).setNumber(double.parse(list[i]["HRA"]));
      worksheet.getRangeByIndex(i+3,10).setText(list[i]["CONV"]);
      worksheet.getRangeByIndex(i+3,11).setText(list[i]["WA"]);
      worksheet.getRangeByIndex(i+3,12).setNumber(double.parse(list[i]["Total Earn"]));
      worksheet.getRangeByIndex(i+3,13).setNumber(double.parse(list[i]["ESI"]));
      worksheet.getRangeByIndex(i+3,14).setNumber(double.parse(list[i]["PF"]));
      worksheet.getRangeByIndex(i+3,15).setText(list[i]["Categories1"]);
      worksheet.getRangeByIndex(i+3,16).setText(list[i]["Categories2"]);
      worksheet.getRangeByIndex(i+3,17).setNumber(double.parse(list[i]["Total DED"]));
      worksheet.getRangeByIndex(i+3,18).setNumber(double.parse(list[i]["NET Amount"]));
      worksheet.getRangeByIndex(i+3,19).setText(list[i]["SIGNATURE"]);
      worksheet.getRangeByIndex(i+3,20).setText(list[i]["bank_name"].toString()=="null"?"":list[i]["bank_name"].toString());
      worksheet.getRangeByIndex(i+3,21).setText(list[i]["acc_no"].toString()=="null"?"":list[i]["acc_no"].toString());
      worksheet.getRangeByIndex(i+3,22).setText(list[i]["ifsc_code"].toString()=="null"?"":list[i]["ifsc_code"].toString());
    }
    final List<int> bytes =workbook.saveAsStream();
    if(kIsWeb){
      AnchorElement(href: 'data:application/octet-stream;charset-utf-161e;base64,${base64.encode(bytes)}')
        ..setAttribute('download', '${constValue.appName} report.xlsx')
        ..click();
    }else{
      final String path=(await getApplicationSupportDirectory()).path;
      final String filename='$path/${constValue.appName}_payroll_report_${monthName}_$yearName.xlsx';
      final File file=File(filename);
      await file.writeAsBytes(bytes,flush: true);
      OpenFile.open(filename);
    }
  }

}

