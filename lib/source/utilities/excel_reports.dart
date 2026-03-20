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
// import 'dart:html' as html;  // Only used in web

final ExcelReports excelReports = ExcelReports._();

class ExcelReports {
  ExcelReports._();
  String appColor="#45377D";
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
  Future<void> exportFullAttendanceExcel(
      context, {
        required List<AttendanceModel> presentList,
        required List<AttendanceModel> absentList,
        required List<AttendanceModel> lateList,
        required List<AttendanceModel> permissionList,
        required List<dynamic> leaveList,
        required String date,
      }) async {
    try {
      var excel = Excel.createExcel();

      /// ❌ remove default sheet
      excel.delete('Sheet1');

      /// 🔹 DATE FORMAT
      String formatDate(String? input) {
        try {
          if (input == null || input.isEmpty) return "-";
          DateTime dt = DateTime.parse(input);
          return DateFormat('dd-MM-yyyy').format(dt);
        } catch (e) {
          return input ?? "-";
        }
      }

      /// 🔹 COMMON HEADER
      List<String> headers = [
        "Name",
        "Role",
        "Date",
        "In Time",
        "Out Time",
        "Total Hours",
        "Status"
      ];

      CellStyle headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: "#45377D",
        fontColorHex: "#FFFFFF",
      );

      /// 🔹 COMMON SHEET BUILDER
      void createSheet(String name, List<List<dynamic>> rows) {
        Sheet sheet = excel[name];

        /// TITLE
        sheet.merge(
          CellIndex.indexByString("A1"),
          CellIndex.indexByString("G1"),
        );

        sheet.cell(CellIndex.indexByString("A1")).value =
        "$name Report - ${formatDate(date)}";

        sheet.cell(CellIndex.indexByString("A1")).cellStyle = CellStyle(
          bold: true,
          fontSize: 12,
        );

        /// HEADER
        sheet.appendRow(headers);

        for (int i = 0; i < headers.length; i++) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1))
              .cellStyle = headerStyle;
        }

        /// DATA
        for (var row in rows) {
          sheet.appendRow(row);
        }
      }

      /// ===============================
      /// ✅ PRESENT
      /// ===============================
      List<List<dynamic>> presentRows = [];

      for (var data in presentList) {
        var inTime = "-";
        var outTime = "-";
        var timeD = "-";

        final times = (data.time ?? "").split(",");

        if (times.length > 1) {
          if (data.status.toString().contains("1,2")) {
            inTime = times[0];
            outTime = times[1];
          } else {
            inTime = times[1];
            outTime = times[0];
          }

          timeD = timeDifference(
            data.createdTs!.split(",")[0],
            data.createdTs!.split(",")[1],
          );
        } else if (times.isNotEmpty) {
          inTime = times[0];
        }

        presentRows.add([
          data.firstname,
          data.role,
          formatDate(data.date),
          inTime,
          outTime,
          timeD,
          "Present"
        ]);
      }

      createSheet("Present", presentRows);

      /// ===============================
      /// ❌ ABSENT
      /// ===============================
      List<List<dynamic>> absentRows = [];

      for (var data in absentList) {
        absentRows.add([
          data.firstname,
          data.role,
          formatDate(data.missingDate),
          "-",
          "-",
          "-",
          "Absent"
        ]);
      }

      createSheet("Absent", absentRows);

      /// ===============================
      /// ⏰ LATE
      /// ===============================
      List<List<dynamic>> lateRows = [];

      for (var data in lateList) {
        var inTime = "-";
        var outTime = "-";
        var timeD = "-";

        final times = (data.time ?? "").split(",");

        if (times.length > 1) {
          inTime = times[0];
          outTime = times[1];

          timeD = timeDifference(
            data.createdTs!.split(",")[0],
            data.createdTs!.split(",")[1],
          );
        }

        lateRows.add([
          data.firstname,
          data.role,
          formatDate(data.date),
          inTime,
          outTime,
          timeD,
          "Late"
        ]);
      }

      createSheet("Late", lateRows);

      /// ===============================
      /// 🟡 PERMISSION
      /// ===============================
      List<List<dynamic>> permissionRows = [];

      for (var data in permissionList) {
        String perTime = data.perTime ?? "-";
        String reason = data.perReason ?? "";

        String text = "Permission";

        if (perTime != "-") {
          text += " ($perTime)";
        }

        if (reason.isNotEmpty) {
          text += " - $reason";
        }

        permissionRows.add([
          data.firstname,
          data.role,
          formatDate(data.date),
          perTime,
          "-",
          "-",
          text
        ]);
      }

      createSheet("Permission", permissionRows);

      /// ===============================
      /// 🟣 LEAVE
      /// ===============================
      List<List<dynamic>> leaveRows = [];

      for (var data in leaveList) {
        String fromDate = formatDate(data.startDate);
        String toDate = formatDate(data.endDate);
        String reason = data.reason ?? "";

        String leaveText = fromDate;

        if (toDate != "-" && toDate != fromDate) {
          leaveText = "$fromDate to $toDate";
        }

        if (reason.isNotEmpty) {
          leaveText += " ($reason)";
        }

        leaveRows.add([
          data.fName ?? "-",
          data.role ?? "-",
          leaveText,
          "-",
          "-",
          "-",
          "Leave"
        ]);
      }

      createSheet("Leave", leaveRows);

      /// 🔹 SAVE
      final bytes = excel.encode();

      if (!kIsWeb) {
        _saveExcelMobile(
          bytes!,
          "Attendance_Report_${formatDate(date)}.xlsx",
          context,
        );
      }

    } catch (e) {
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

