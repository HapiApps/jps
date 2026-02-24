import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:master_code/model/add_expense_model.dart';
import 'package:master_code/source/constant/default_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:master_code/view_model/employee_provider.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:excel/excel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:master_code/view_model/project_provider.dart';
import 'package:master_code/view_model/task_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../component/custom_text.dart';
import '../local_database/sqlite.dart';
import '../model/expense_model.dart';
import '../model/user_model.dart';
import '../repo/expense_repo.dart';
import '../screens/common/camera.dart';
import '../screens/common/dashboard.dart';
import '../component/month_calendar.dart';
import '../screens/common/fullscreen_photo.dart';
import '../screens/expense/expense_dashboard.dart';
import '../screens/task/task_report.dart';
import '../source/constant/api.dart';
import 'package:http/http.dart'as http;
import '../source/constant/assets_constant.dart';
import '../source/constant/colors_constant.dart';
import '../source/constant/local_data.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../source/utilities/excel_download_mobile.dart'
if (dart.library.html) '../source/utilities/excel_download_web.dart';

class ExpenseProvider with ChangeNotifier{
final ExpenseRepository expenseRepo = ExpenseRepository();
TextEditingController search     = TextEditingController();
void searchExpense(String value){
  if(_isFilter==false){
    final suggestions=_searchExpenseData.where(
            (user){
          final userFName=user.projectName.toString().toLowerCase();
          final userNumber = user.firstname.toString().toLowerCase();
          final amount = user.amount.toString().toLowerCase();
          final input=value.toString().toLowerCase();
          return userFName.contains(input) || userNumber.contains(input) || amount.contains(input);
        }).toList();
    _filterExpenseData=suggestions;
  }else{
    final suggestions=_filterExpenseData.where(
            (user){
          final userFName=user.projectName.toString().toLowerCase();
          final userNumber = user.firstname.toString().toLowerCase();
          final amount = user.amount.toString().toLowerCase();
          final input=value.toString().toLowerCase();
          return userFName.contains(input) || userNumber.contains(input) || amount.contains(input);
        }).toList();
    _filterExpenseData=suggestions;
    if(value.isEmpty){
      filterList();
    }
  }
  // _expenseData=suggestions;
  notifyListeners();
}
String _filter="1";
String get filter => _filter;
Future<void> getCustomerTaskExpense(String id,String date1,String date2) async {
  _expenseData.clear();
  _refresh=false;
  notifyListeners();
  try {
    Map data = {
      "action": taskDatas,
      "search_type":"customer_expense_details",
      "id":id,
      "date1":date1,
      "date2":date2,
      "role":localData.storage.read("role"),
      "cos_id":localData.storage.read("cos_id"),
      "user_id":localData.storage.read("role")=="1"?id:localData.storage.read("id"),
    };
    final response =await expenseRepo.userExpense(data);
    // print(data.toString());
    if (response.isNotEmpty) {
      _expenseData=response;
      _refresh=true;
    } else {
      _refresh=true;
    }
  } catch (e) {
    _refresh=true;
  }
  notifyListeners();
}
Future<void> getUserTaskExpense(String id,String date1,String date2) async {
  _expenseData.clear();
  _refresh=false;
  notifyListeners();
  try {
    Map data = {
      "action": taskDatas,
      "search_type":"emp_expense_details",
      "id":localData.storage.read("role")=="1"?id:localData.storage.read("id"),
      "date1":date1,
      "date2":date2,
      "role":localData.storage.read("role"),
      "cos_id":localData.storage.read("cos_id")
    };
    final response =await expenseRepo.userExpense(data);
    // print(data.toString());
    if (response.isNotEmpty) {
      _expenseData=response;
      _refresh=true;
    } else {
      _refresh=true;
    }
  } catch (e) {
    _refresh=true;
  }
  notifyListeners();
}
Future<void> exportToExcel({required BuildContext context, required bool isProject, required String amount, required String empName, required String place, required String customer, required String purpose, required List<ExpenseModel> dataList, List? mapList,} ) async {
  try {
    String appColor = "#45377D";
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    CellStyle titleStyle = CellStyle(
      backgroundColorHex: appColor,
      fontColorHex: "#FFFFFF",
      fontSize: 10,
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );

    CellStyle headerStyle = CellStyle(
      backgroundColorHex: "#D9D9D9",
      fontColorHex: "#000000",
      bold: true,
      fontSize: 10,
    );

    var firstCell = CellIndex.indexByString("A1");
    var lastCell = CellIndex.indexByString("H1");
    sheet.merge(firstCell, lastCell);
    sheet.cell(firstCell).value = "${constValue.appName} EXPENSE REPORT";
    sheet.cell(firstCell).cellStyle = titleStyle;

    var nameCell = CellIndex.indexByString("A2");
    var nameLastCell = CellIndex.indexByString("H2");
    sheet.merge(nameCell, nameLastCell);
    sheet.cell(nameCell).value = "Name : $empName";
    sheet.cell(nameCell).cellStyle = titleStyle;

    List<String> staticKeys = [isProject==false?'Place Visited':"From", isProject==false?'Purpose':'To', isProject==false?constValue.customerName:constValue.projectName, 'Amount'];
    List<String> staticValues = [place, purpose, customer, amount];

    for (int i = 0; i < staticKeys.length; i++) {
      var keyCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 2));
      var valueCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 2));
      keyCell.value = staticKeys[i];
      valueCell.value = staticValues[i];
      keyCell.cellStyle = headerStyle;
    }

    int currentRow = 6;

    for (var item in dataList) {
      var txFrom = item.txfrom?.split('||') ?? [];
      var txStartDate = item.txstartDate?.split('||') ?? [];
      var txStartTime = item.txstartTime?.split('||') ?? [];
      var txTo = item.txto?.split('||') ?? [];
      var txEndDate = item.txendDate?.split('||') ?? [];
      var txEndTime = item.txendTime?.split('||') ?? [];
      var txmode = item.txmode?.split('||') ?? [];
      var txamount = item.txamount?.split('||') ?? [];

      var dadate = item.dadate?.split('||') ?? [];
      var daparticular = item.daparticular?.split('||') ?? [];
      var daamount = item.daamount?.split('||') ?? [];

      var cedate = item.cedate?.split('||') ?? [];
      var cefrom = item.cefrom?.split('||') ?? [];
      var ceto = item.ceto?.split('||') ?? [];
      var cemode = item.cemode?.split('||') ?? [];
      var ceamount = item.ceamount?.split('||') ?? [];

      if (dadate.isNotEmpty && dadate[0] != "") {
        var daTitleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
        daTitleCell.value = "DA/Board/Lodging/Other Expense";
        daTitleCell.cellStyle = titleStyle;
        currentRow++;

        List<String> daHeader = ["# of Days", "Particular", "Amount"];
        for (int i = 0; i < daHeader.length; i++) {
          var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
          cell.value = daHeader[i];
          cell.cellStyle = headerStyle;
        }
        currentRow++;

        for (int i = 0; i < dadate.length; i++) {
          sheet.appendRow([dadate[i], daparticular[i], daamount[i]]);
          currentRow++;
        }
      }

      if (txStartDate.isNotEmpty && txStartDate[0] != "") {
        var travelTitleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
        travelTitleCell.value = "Travel Expenses";
        travelTitleCell.cellStyle = titleStyle;
        currentRow++;

        List<String> travelHeader = [
          "From",
          "Start Date",
          "Start Time",
          "To",
          "End Date",
          "End Time",
          "Mode",
          "Amount"
        ];
        for (int i = 0; i < travelHeader.length; i++) {
          var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
          cell.value = travelHeader[i];
          cell.cellStyle = headerStyle;
        }
        currentRow++;

        for (int i = 0; i < txFrom.length; i++) {
          sheet.appendRow([
            txFrom[i],
            txStartDate[i],
            txStartTime[i],
            txTo[i],
            txEndDate[i],
            txEndTime[i],
            txmode[i],
            txamount[i],
          ]);
          currentRow++;
        }
      }

      if (cedate.isNotEmpty && cedate[0] != "") {
        var ceTitleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
        ceTitleCell.value = "Local Conveyance Expense";
        ceTitleCell.cellStyle = titleStyle;
        currentRow++;

        List<String> ceHeader = ["Date", "From", "To", "Mode", "Amount"];
        for (int i = 0; i < ceHeader.length; i++) {
          var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
          cell.value = ceHeader[i];
          cell.cellStyle = headerStyle;
        }
        currentRow++;

        for (int i = 0; i < cedate.length; i++) {
          sheet.appendRow([cedate[i], cefrom[i], ceto[i], cemode[i], ceamount[i]]);
          currentRow++;
        }
      }
    }
    for (var item in mapList!) {
      if(item["purchase"].toString()!="null"){
        if (item is Map<String, dynamic> && item.isNotEmpty) {
          var miscTitleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
          miscTitleCell.value = "Expenses";
          miscTitleCell.cellStyle = titleStyle;
          currentRow++;

          List<String> miscHeader = ["Type", "Amount"];
          for (int i = 0; i < miscHeader.length; i++) {
            var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
            cell.value = miscHeader[i];
            cell.cellStyle = headerStyle;
          }
          currentRow++;

          item.forEach((key, value) {
            if (value != "null" && value.toString().trim().isNotEmpty) {
              sheet.appendRow([key, value.toString()]);
              currentRow++;
            }
          });
        }
      }
    }

    if (kIsWeb) {
      saveExcel(excel.encode(), "${empName}_expenses.xlsx");
    } else {
      await saveExcel(excel.encode(), "${empName}_expenses.xlsx");
    }
    downloadCtr.reset();
  } catch (e) {
    if (context.mounted) {
      utils.showWarningToast(context, text: "Something Went Wrong");
    }
    downloadCtr.reset();
    log("❌ Error: $e");
  } finally {
    downloadCtr.reset();
  }
}

Future<void> exportExpenseReportAsPDF({required BuildContext context, required bool isProject, required String empName,  required String place, required String customer, required String purpose, required String amount, required String appAmt, required String status, required List<ExpenseModel> dataList, List? mapList, }) async {
  try {
    final pdf = pw.Document();

    /// Format ₹ amount
    String formatAmount(String amount) {
      final numValue = double.tryParse(amount.replaceAll(',', '')) ?? 0;
      final formatted = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs.').format(numValue);
      return formatted;
    }

    /// Helper: Load network image and clip with radius
    Future<pw.Widget> _buildNetworkImage(String url) async {
      try {
        final response = await http.get(Uri.parse("$imageFile?path=$url"));
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          if (bytes.isNotEmpty) {
            final img = pw.MemoryImage(bytes);
            return pw.ClipRRect(
              horizontalRadius: 10,
              verticalRadius: 10,
              child: pw.Image(img, width: 100, height: 100, fit: pw.BoxFit.cover),
            );
          }
        }
      } catch (e) {
        print('❌ Error fetching: $url → $e');
      }
      return pw.Container();
    }

    /// DA Images
    final daImages = dataList[0].document1?.split('||') ?? [];
    final daImageWidgets = <pw.Widget>[];
    for (final url in daImages) {
      if (url.isNotEmpty && url != 'null') {
        daImageWidgets.add(await _buildNetworkImage(url));
      }
    }

    /// Travel Images
    final travelImages = dataList[0].document2?.split('||') ?? [];
    final travelImageWidgets = <pw.Widget>[];
    for (final url in travelImages) {
      if (url.isNotEmpty && url != 'null') {
        travelImageWidgets.add(await _buildNetworkImage(url));
      }
    }

    /// Conveyance Images
    final conveyanceImages = dataList[0].document3?.split('||') ?? [];
    final conveyanceImageWidgets = <pw.Widget>[];
    for (final url in conveyanceImages) {
      if (url.isNotEmpty && url != 'null') {
        conveyanceImageWidgets.add(await _buildNetworkImage(url));
      }
    }

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              '${constValue.appName} EXPENSE REPORT',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: 'Name: ',
                      style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.TextSpan(
                      text: empName,
                      style: pw.TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: 'Status: ',
                      style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.TextSpan(
                      text: status,
                      style: pw.TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ]
          ),
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: isProject==false?'Place Visited: ':'From: ',
                  style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
                ),
                pw.TextSpan(
                  text: place,
                  style: pw.TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: isProject==false?'Purpose: ':'To: ',
                  style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
                ),
                pw.TextSpan(
                  text: purpose,
                  style: pw.TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: '${isProject==true?constValue.projectName:constValue.customerName}: ',
                  style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
                ),
                pw.TextSpan(
                  text: customer,
                  style: pw.TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: 'Amount: ',
                      style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.TextSpan(
                      text: formatAmount(amount),
                      style: pw.TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: 'Approved Amount: ',
                      style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.TextSpan(
                      text: appAmt,
                      style: pw.TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ]
          ),
          pw.SizedBox(height: 20),

          for (final item in dataList) ...[
            if ((item.dadate ?? '').isNotEmpty) ...[
              pw.Text(
                'DA/Board/Lodging/Other Expense',
                style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
              ),
              pw.Table.fromTextArray(
                headers: ['# of Days', 'Particular', 'Amount'],
                data: List.generate(
                  item.dadate!.split('||').length,
                      (i) => [
                    item.dadate!.split('||')[i],
                    item.daparticular!.split('||')[i],
                    formatAmount(item.daamount!.split('||')[i]),
                  ],
                ),
              ),
              if (daImageWidgets.isNotEmpty) ...[
                pw.SizedBox(height: 10),
                pw.Text('DA Documents:', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
                pw.Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: daImageWidgets,
                ),
              ],
            ],

            if ((item.txfrom ?? '').isNotEmpty) ...[
              pw.SizedBox(height: 20),
              pw.Text(
                'Travel Expenses',
                style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
              ),
              pw.Table.fromTextArray(
                headers: ['From', 'Start Date', 'Start Time', 'To', 'End Date', 'End Time', 'Mode', 'Amount'],
                data: List.generate(
                  item.txfrom!.split('||').length,
                      (i) => [
                    item.txfrom!.split('||')[i],
                    item.txstartDate!.split('||')[i],
                    item.txstartTime!.split('||')[i],
                    item.txto!.split('||')[i],
                    item.txendDate!.split('||')[i],
                    item.txendTime!.split('||')[i],
                    item.txmode!.split('||')[i],
                    formatAmount(item.txamount!.split('||')[i]),
                  ],
                ),
              ),
              if (travelImageWidgets.isNotEmpty) ...[
                pw.SizedBox(height: 10),
                pw.Text('Travel Documents:', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
                pw.Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: travelImageWidgets,
                ),
              ],
            ],

            if ((item.cedate ?? '').isNotEmpty) ...[
              pw.SizedBox(height: 20),
              pw.Text(
                'Local Conveyance Expense',
                style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
              ),
              pw.Table.fromTextArray(
                headers: ['Date', 'From', 'To', 'Mode', 'Amount'],
                data: List.generate(
                  item.cedate!.split('||').length,
                      (i) => [
                    item.cedate!.split('||')[i],
                    item.cefrom!.split('||')[i],
                    item.ceto!.split('||')[i],
                    item.cemode!.split('||')[i],
                    formatAmount(item.ceamount!.split('||')[i]),
                  ],
                ),
              ),
              if (conveyanceImageWidgets.isNotEmpty) ...[
                pw.SizedBox(height: 10),
                pw.Text('Local Conveyance Documents:', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
                pw.Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: conveyanceImageWidgets,
                ),
              ],
            ],
          ],
          for (final item in mapList!) ...[
            if (item["purchase"].toString()!="null"&&item is Map<String, dynamic>) ...[
              pw.SizedBox(height: 20),
              pw.Text(
                'Expenses',
                style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
              ),
              pw.Table.fromTextArray(
                headers: ['Type', 'Amount'],
                data: item.entries
                    .where((entry) => entry.value != "null" && entry.value.toString().trim().isNotEmpty)
                    .map((entry) => [entry.key, formatAmount(entry.value.toString())])
                    .toList(),
              ),
            ]
          ],
        ],
      ),
    );
    pdfDownloadCtr.reset();
    if (kIsWeb) {
      await savePDF(empName, pdf);
    } else {
      await savePDF(empName, pdf);
    }
    pdfDownloadCtr.reset();
  } catch (e) {
    utils.showWarningToast(context, text: "Something Went Wrong");
    pdfDownloadCtr.reset();
  }
}

void changeFilter(String value) {
  _filter = value;
  notifyListeners();
}
var _status;
int matched=0;
get status => _status;
List stList=["In Process","Rejected","Approved"];
void changeStatus(dynamic value) {
  _status = value;
  matched=0;
  for(var i=0;i<expenseData.length;i++){
    if(_status=="Rejected"&&expenseData[i].status=="0"){
      matched++;
    }else if(_status=="Approved"&&expenseData[i].status=="2"){
      matched++;
    }else if(_status=="In Process"&&expenseData[i].status=="1"){
      matched++;
    }
  }
  notifyListeners();
}

void removeFile(int index) {
  _selectedFiles1.removeAt(index);
  notifyListeners();
}
void removeFile2(int index) {
  _selectedFiles2.removeAt(index);
  notifyListeners();
}
void removeFile3(int index) {
  _selectedFiles3.removeAt(index);
  notifyListeners();
}
final ImagePicker picker = ImagePicker();

Future<void> pickFile() async {

  final List<XFile> files = await picker.pickMultiImage();

  if (files.isNotEmpty) {
    for (XFile file in files) {
      final int fileSizeBytes = File(file.path).lengthSync();
      final String formattedSize = formatFileSize(fileSizeBytes);

      _selectedFiles1.add({
        'name': file.name,
        'size': formattedSize,
        'path': file.path,
      });
    }

    notifyListeners();
  }
}
Future<void> pickFile2() async {

  final List<XFile> files = await picker.pickMultiImage();

  if (files.isNotEmpty) {
    for (XFile file in files) {
      final int fileSizeBytes = File(file.path).lengthSync();
      final String formattedSize = formatFileSize(fileSizeBytes);

      _selectedFiles2.add({
        'name': file.name,
        'size': formattedSize,
        'path': file.path,
      });
    }

    notifyListeners();
  }
}
Future<void> pickFile3() async {

  final List<XFile> files = await picker.pickMultiImage();

  if (files.isNotEmpty) {
    for (XFile file in files) {
      final int fileSizeBytes = File(file.path).lengthSync();
      final String formattedSize = formatFileSize(fileSizeBytes);

      _selectedFiles3.add({
        'name': file.name,
        'size': formattedSize,
        'path': file.path,
      });
    }

    notifyListeners();
  }
}
String formatFileSize(int bytes) {
  double kb = bytes / 1024;
  if (kb < 1024) {
    return "${kb.toStringAsFixed(2)} KB";
  } else {
    double mb = kb / 1024;
    return "${mb.toStringAsFixed(2)} MB";
  }
}
List<String> _selectedPhotos1 = [];
List<String> _selectedPhotos2 = [];
List<String> _selectedPhotos3 = [];

List<String> get selectedPhotos1 => _selectedPhotos1;
List<String> get selectedPhotos2 => _selectedPhotos2;
List<String> get selectedPhotos3 => _selectedPhotos3;
void removePhotos(int index) {
  _selectedPhotos1.removeAt(index);
  notifyListeners();
}
void removePhotos2(int index) {
  _selectedPhotos2.removeAt(index);
  notifyListeners();
}
void removePhotos3(int index) {
  _selectedPhotos3.removeAt(index);
  notifyListeners();
}
Future<void> pickCamera(BuildContext context) async {
  var imgData = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const CameraWidget(
            cameraPosition: CameraType.back,
          )));
  _selectedPhotos1.add(imgData);
  notifyListeners();
}
Future<void> pickCamera2(BuildContext context) async {
  var imgData = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const CameraWidget(
            cameraPosition: CameraType.back,
          )));
  _selectedPhotos2.add(imgData);
  notifyListeners();
}
Future<void> pickCamera3(BuildContext context) async {
  var imgData = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const CameraWidget(
            cameraPosition: CameraType.back,
          )));
  _selectedPhotos3.add(imgData);
  notifyListeners();
}

void initValues(String date){
  _overAllAmt=0;
  _convAmt=0;
  _otherAmt=0;
  _travelAmt=0;
  _travelIndex=0;
  _otherIndex=0;
  _conveyanceIndex=0;
  _conveyanceExp.clear();
  _travelExp.clear();
  _otherExp.clear();
  _selectedPhotos1.clear();
  _selectedPhotos2.clear();
  _selectedPhotos3.clear();
  _selectedFiles1.clear();
  _selectedFiles2.clear();
  _selectedFiles3.clear();
  visitPlace.clear();
  client.clear();
  purpose.clear();
  totalAmt.clear();
  updateIndex(0);
  _swipeIndex=0;
  _travelExp.add(AddExpTravelModel(
      from: TextEditingController(),
      to: TextEditingController(),
      stDate: TextEditingController(text: date),
      enDate: TextEditingController(),
      stTime: TextEditingController(),
      enTime: TextEditingController(), amt: TextEditingController(text: localData.storage.read("travel_amount")),mode: null, modeId: '', modeName: ''));
  _otherExp.add(OtherExpModel(
      date: TextEditingController(),
      particular: TextEditingController(),
      amount: TextEditingController()));
  _conveyanceExp.add(ConveyanceExpModel(
      from: TextEditingController(),
      to: TextEditingController(),
      date: TextEditingController(text: date),
      amt: TextEditingController(text: localData.storage.read("conveyance_amount")),
      mode: null, modeId: '', modeName: ''));
  notifyListeners();
}

void initValues2(){
  date.text="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}";
  _simpleExp.clear();
  from.clear();
  to.clear();
  bus.clear();
  auto.clear();
  food.clear();
  purchase.clear();
  _totalExpense=0;
  _toggleIndex=0;
  notifyListeners();
}

final TextEditingController visitPlace=TextEditingController();
final TextEditingController client=TextEditingController();
final TextEditingController purpose=TextEditingController();
final TextEditingController advance=TextEditingController();
final TextEditingController totalAmt=TextEditingController(text: "0");
final TextEditingController balanceTo=TextEditingController();
final TextEditingController voucherNo=TextEditingController();
final TextEditingController debitTo=TextEditingController();
TextEditingController deleteReason = TextEditingController();
TextEditingController approveAmt = TextEditingController();

final RoundedLoadingButtonController addCtr=RoundedLoadingButtonController();
late TabController tabController;
late TabController tabController2;
int _swipeIndex = 0;
int _swipeIndex2 = 0;
int get swipeIndex =>_swipeIndex;
int get swipeIndex2 =>_swipeIndex2;
List<Map<String, dynamic>> _selectedFiles1 = [];
List<Map<String, dynamic>> _selectedFiles2 = [];
List<Map<String, dynamic>> _selectedFiles3 = [];

List<Map<String, dynamic>> get selectedFiles1 => _selectedFiles1;
List<Map<String, dynamic>> get selectedFiles2 => _selectedFiles2;
List<Map<String, dynamic>> get selectedFiles3 => _selectedFiles3;

Future<void> getTypesOfExpense() async {
  expenseList.clear();
  List storedLeads = await LocalDatabase.getExpenseTypes();
  expenseList=storedLeads;
  notifyListeners();
}
Future<void> refreshExpense() async {
  _exType=null;
  expenseList.clear();
  List storedLeads = await LocalDatabase.getExpenseTypes();
  expenseList=storedLeads;
  notifyListeners();
}
void updateIndex(int index){
  _swipeIndex=index;
  tabController.index=index;
  notifyListeners();
}
void updateIndex2(int index){
  _swipeIndex2=index;
  tabController2.index=index;
  notifyListeners();
  // print("tabController2.index : ${tabController2.index}");
}

int _travelIndex = 0;
int get travelIndex =>_travelIndex;

double _overAllAmt = 0;

double _travelAmt = 0.0;
double get travelAmt =>_travelAmt;

double _otherAmt = 0;
double get otherAmt =>_otherAmt;

double _convAmt = 0.0;
double get convAmt =>_convAmt;
List<AddExpTravelModel> _travelExp=[];
List<AddExpTravelModel> get travelExp=>_travelExp;
void addExpTravel(String date){
  _travelExp.add(AddExpTravelModel(
      from: TextEditingController(),
      to: TextEditingController(),
      stDate: TextEditingController(text: date),
      enDate: TextEditingController(),
      stTime: TextEditingController(),
      enTime: TextEditingController(), amt: TextEditingController(text: localData.storage.read("travel_amount")),mode: null, modeId: '', modeName: ''));
  _travelIndex=_travelExp.length-1;
  notifyListeners();
}
void addTravelAmt() {
  for(var i=0;i<travelExp.length;i++){
    final from = _travelExp[_travelIndex].from.text.trim();
    final stTime = _travelExp[_travelIndex].stTime.text.trim();
    final to = _travelExp[_travelIndex].to.text.trim();
    final enDate = _travelExp[_travelIndex].enDate.text.trim();
    final enTime = _travelExp[_travelIndex].enTime.text.trim();
    // final amount = _travelExp[_travelIndex].amt.text.trim();
    final mode = _travelExp[_travelIndex].mode;
    // print("sjxnsnx");
    // print(from.isNotEmpty&&to.isNotEmpty&&stTime.isNotEmpty&&enDate.isNotEmpty&&enTime.isNotEmpty&&mode!=null);
    if(from.isNotEmpty&&to.isNotEmpty&&stTime.isNotEmpty&&enDate.isNotEmpty&&enTime.isNotEmpty&&mode!=null){
      _travelAmt = _calculateTotal(_travelExp.map((e) => e.amt.text).toList());
    }
  }
  _updateOverallAmt();
}

void addOtherAmt() {
  _otherAmt = _calculateTotal(_otherExp.map((e) => e.amount.text).toList());
  _updateOverallAmt();
}
bool checkValidation() {
  final from = _travelExp[_travelIndex].from.text.trim();
  final stTime = _travelExp[_travelIndex].stTime.text.trim();
  final to = _travelExp[_travelIndex].to.text.trim();
  final enDate = _travelExp[_travelIndex].enDate.text.trim();
  final enTime = _travelExp[_travelIndex].enTime.text.trim();
  final mode = _travelExp[_travelIndex].mode;

  bool hasAnyValue = from.isNotEmpty||stTime.isNotEmpty || to.isNotEmpty || enDate.isNotEmpty || enTime.isNotEmpty ||  mode != null;
  bool allFieldsFilled = from.isEmpty && stTime.isEmpty && to.isEmpty && enDate.isEmpty && enTime.isEmpty && mode == null;
  _updateOverallAmt();
  if(allFieldsFilled){
    return false;
  }else if(hasAnyValue){
    addTravelAmt();
    return true;
  }else{
    return false;
  }
}
bool checkValidation2() {
  _convAmt=0.0;
  final date = _conveyanceExp[_conveyanceIndex].date.text.trim();
  final from = _conveyanceExp[_conveyanceIndex].from.text.trim();
  final to = _conveyanceExp[_conveyanceIndex].to.text.trim();
  final mode = _conveyanceExp[_conveyanceIndex].mode;

  bool hasAnyValue = from.isNotEmpty&&(to.isEmpty || mode == null);
  bool hasAnyValue1 = to.isNotEmpty&&(from.isEmpty ||  mode == null);
  bool hasAnyValue2 = mode != null&&(from.isEmpty || to.isEmpty);
  bool allFieldsEmpty = from.isEmpty && to.isEmpty && mode == null;
  bool allFieldsFilled = date.isNotEmpty &&from.isNotEmpty && to.isNotEmpty && mode != null;
  if(allFieldsFilled){
    // print("0");
    addConvAmt();
    return false;
  }else if(allFieldsEmpty){
    // print("1");
    return false;
  }else if(hasAnyValue){
    // print("2");
    addConvAmt();
    return true;
  }else if(hasAnyValue1){
    // print("3");
    addConvAmt();
    return true;
  }else if(hasAnyValue2){
    // print("4");
    addConvAmt();
    return true;
  }else{
    // print("5");
    addConvAmt();
    return false;
  }
}
bool checkValidation3() {
  final days = _otherExp[_otherIndex].date.text.trim();
  final particular = _otherExp[_otherIndex].particular.text.trim();

  bool hasAnyValue = days.isNotEmpty&&(particular.isEmpty);
  bool hasAnyValue1 = particular.isNotEmpty&&(days.isEmpty);
  bool allFieldsFilled = days.isEmpty && particular.isEmpty;

  if(allFieldsFilled){
    return false;
  }else if(hasAnyValue){
    return true;
  }else if(hasAnyValue1){
    return true;
  }else{
    return false;
  }
}


void gradeWithDAAmt() {
  if (_otherExp[_otherIndex].date.text.isNotEmpty) {
    var add = double.parse(_otherExp[_otherIndex].date.text);
    var daAmount = double.parse(localData.storage.read("da_amount").toString());
    var addGrade = add * daAmount;
    _otherExp[_otherIndex].amount.text = addGrade.toStringAsFixed(2); // 2 decimal places
  } else {
    _otherExp[_otherIndex].amount.clear();
  }
  _updateOverallAmt();
  addOtherAmt();
  notifyListeners();
}

void addConvAmt() {
  // print("addConvAmt");
  _convAmt=0.0;
  _convAmt = _calculateTotal(_conveyanceExp.map((e) => e.amt.text).toList());
  _updateOverallAmt();
}

double _calculateTotal(List<String> textFields) {
  return textFields.fold(0.0, (sum, value) {
    final clean = value.trim();
    return clean.isNotEmpty ? sum + (double.tryParse(clean) ?? 0.0) : sum;
  });
}

void _updateOverallAmt() {
  _overAllAmt=0.0;
  totalAmt.clear();
  _overAllAmt = _travelAmt + _otherAmt + _convAmt;
  totalAmt.text = _overAllAmt.toString();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    notifyListeners(); // ✅ safe after build
  });
}

// void addTravelAmt(){
//   var total=0;
//   _travelAmt=0;
//   _overAllAmt=0;
//   for(var i=0;i<_travelExp.length;i++){
//     if(_travelExp[i].amt.text.trim().isNotEmpty){
//       total+=int.parse(_travelExp[i].amt.text.trim());
//     }
//   }
//   _travelAmt=total;
//   _overAllAmt+=_travelAmt;
//   totalAmt.text+=_overAllAmt.toString();
//   print("_travelAmt ${_travelAmt}");
//   print("_overAllAmt ${_overAllAmt}");
//   print("totalAmt.text ${totalAmt.text}");
//   notifyListeners();
// }
// void addOtherAmt(){
//   var total=0;
//   _otherAmt=0;
//   _overAllAmt=0;
//   for(var i=0;i<_otherExp.length;i++){
//     if(_otherExp[i].amount.text.trim().isNotEmpty){
//       total+=int.parse(_otherExp[i].amount.text.trim());
//     }
//   }
//   _otherAmt=total;
//   _overAllAmt+=_otherAmt;
//   totalAmt.text+=_overAllAmt.toString();
//   print("_travelAmt 2 ${_otherAmt}");
//   print("_overAllAmt 2 ${_otherAmt}");
//   print("totalAmt.text 2 ${totalAmt.text}");
//   notifyListeners();
// }
// void addConvAmt(){
//   var total=0;
//   _convAmt=0;
//   for(var i=0;i<_conveyanceExp.length;i++){
//     if(_conveyanceExp[i].amt.text.trim().isNotEmpty){
//       total+=int.parse(_conveyanceExp[i].amt.text.trim());
//     }
//   }
//   _convAmt=total;
//   _overAllAmt+=_convAmt;
//   totalAmt.text+=_overAllAmt.toString();
//   print("_travelAmt 3 ${_convAmt}");
//   print("_overAllAmt 3 ${_overAllAmt}");
//   print("totalAmt.text 3 ${totalAmt.text}");
//   notifyListeners();
// }
void removeExpTravel(int index){
  _travelExp.removeAt(index);
  _travelIndex=_travelExp.length-1;
  addTravelAmt();
  notifyListeners();
}
void changeExpTravel(bool isAdd) {
  if (isAdd) {
    if (_travelIndex < _travelExp.length - 1) {
      _travelIndex++;
    }
  } else {
    if (_travelIndex > 0) {
      _travelIndex--;
    }
  }
  notifyListeners();
}

var formatter = NumberFormat('#,##,000');
int _otherIndex = 0;
int _toggleIndex = 0;
int _totalExpense = 0;
dynamic _projectName;
int get otherIndex =>_otherIndex;
int get toggleIndex =>_toggleIndex;
int get totalExpense =>_totalExpense;
dynamic get projectName =>_projectName;
void changeProject(dynamic value){
  var list = value.toString().split(',');
  _projectName = value;
  notifyListeners();
}
void changeIndex(int index){
  _toggleIndex=index;
  notifyListeners();
}
  void expenseAmt(){
    var a=int.parse(bus.text.isEmpty?"0":bus.text);
    var b=int.parse(auto.text.isEmpty?"0":auto.text);
    var c=int.parse(rent.text.isEmpty?"0":rent.text);
    var d=int.parse(food.text.isEmpty?"0":food.text);
    var e=int.parse(purchase.text.isEmpty?"0":purchase.text);
    _totalExpense=a+b+c+d+e;
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
                            _simpleExp[index].doc = imgData;
                            Navigator.pop(context);
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
                              _simpleExp[index].doc = result.files.single.path!;
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
                  if(_simpleExp[index].doc !="")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                          TextButton(
                            onPressed: () {
                              _simpleExp[index].doc="";
                               notifyListeners();
                              Navigator.pop(context);
                            },
                            child:CustomText(text: "Remove",colors: colorsConst.primary,size: 15,isBold: true),
                          ),
                        TextButton(onPressed: () {
                          Navigator.of(context).pop();
                         utils.navigatePage(context, ()=>FullScreen(image:_simpleExp[index].doc, isNetwork: false));
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
  PickerDateRange? selectedDate;
  List<DateTime> datesBetween = [];
  String betweenDates="";
  List<DateTime> getDatesInRange(DateTime start, DateTime end) {
    List<DateTime> days = [];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      days.add(DateTime(start.year, start.month, start.day + i));
    }
    return days;
  }
  String _stDate="";
  String _enDate="";
  String get stDate=> _stDate;
  String get enDate=> _enDate;
  var _type;
  String typeId="";
  get type=>_type;
  bool _isFilter=false;
  bool get isFilter=>_isFilter;
  String _companyName="";
  String get companyName => _companyName;
  dynamic _filterType;
  dynamic get filterType =>_filterType;
  String _filterDate = "";
  String get filterDate=>_filterDate;
  var filterTypeList = ["Today","Yesterday","Last 7 Days","Last 30 Days","This Week","This Month","Last 3 months"];
  String _userName="";
  String get userName=>_userName;


  void filterPick({required BuildContext context, required bool isStartDate}) {
    DateTime dateTime = DateTime.now();

    showDatePicker(
      context: context,
      initialDate: dateTime,
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
  void checkFilterType(dynamic value) {
    _type = value;
    // print("value");
    // print(value);
    // var list = [];
    // list.add(value);
    // typeId=list[0]["id"];
    // print("typeId----${typeId}");
    notifyListeners();
  }
  void changeName(value) {
    _companyName=value!.companyName.toString();
    notifyListeners();
  }
  // void filterList() {
  //   print(_startDate);
  //   print(_endDate);
  //   final dateFormat = DateFormat('dd-MM-yyyy');
  //   final parsedStartDate = dateFormat.parse(_startDate);
  //   final parsedEndDate = dateFormat.parse(_endDate);
  //
  //   _filterExpenseData = _searchExpenseData.where((contact) {
  //     // Parse contact.taskDate (in dd-MM-yyyy format)
  //     final taskDate = dateFormat.parse(contact.createdTs.toString());
  //     final taskDateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);
  //
  //     // Filter by date range
  //     final isWithinDateRange =
  //         !taskDateOnly.isBefore(parsedStartDate) && !taskDateOnly.isAfter(parsedEndDate);
  //
  //     // Optional filters
  //     // final isTypeMatch = _fType == "" || _fType == contact.type;
  //     final isEmpMatch = _userName == "" || contact.createdBy.toString().contains(_userName);
  //     final isCusMatch = _companyName == "" || contact.projectName == _companyName;
  //
  //     // Return if all filters match isTypeMatch &&
  //     return isWithinDateRange && isEmpMatch && isCusMatch;
  //   }).toList();
  //
  //   notifyListeners();
  // }

  List<ExpenseModel> _filterExpenseData = <ExpenseModel>[];
  List<ExpenseModel> get filterExpenseData => _filterExpenseData;

  void filterList() {
    final startDate = DateFormat('dd-MM-yyyy').parse(_startDate);
    final endDate = DateFormat('dd-MM-yyyy').parse(_endDate);

    _filterExpenseData = _searchExpenseData.where((contact) {
      DateTime taskDate;

      if (contact.createdTs is DateTime) {
        taskDate = DateTime.parse(contact.createdTs.toString());
      } else {
        // If string in yyyy-MM-dd or yyyy-MM-dd HH:mm:ss
        taskDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(contact.createdTs.toString());
      }

      final taskDateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);

      final isWithinDateRange =
          !taskDateOnly.isBefore(startDate) && !taskDateOnly.isAfter(endDate);

       print("status $_type : ${contact.status}");
      var tId="";
      if(_type=="In Process"){
        tId="1";
      }else if(_type=="Approved"){
        tId="2";
      }else{
        tId="0";
      }

      final isStatusMatch = _type == null || contact.status.toString().contains(tId);
      final isEmpMatch = _userName == "" || contact.firstname.toString().contains(_userName);
      final isCusMatch = _companyName == "" || contact.projectName == _companyName;

      return isWithinDateRange && isStatusMatch && isEmpMatch && isCusMatch;
    }).toList();

    // print("Filtered Count: ${_filterExpenseData.length}");
    notifyListeners();
  }
  void initFilterList(String date1,String date2) {
    final startDate = DateFormat('dd-MM-yyyy').parse(date1);
    final endDate = DateFormat('dd-MM-yyyy').parse(date2);

    _filterExpenseData = _searchExpenseData.where((contact) {
      DateTime taskDate;

      if (contact.createdTs is DateTime) {
        taskDate = DateTime.parse(contact.createdTs.toString());
      } else {
        // If string in yyyy-MM-dd or yyyy-MM-dd HH:mm:ss
        taskDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(contact.createdTs.toString());
      }

      final taskDateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);

      final isWithinDateRange =
          !taskDateOnly.isBefore(startDate) && !taskDateOnly.isAfter(endDate);

      // print("status $typeId : ${contact.status}");

      final isStatusMatch = _type == null || contact.status.toString().contains(typeId);
      final isEmpMatch = _userName == "" || contact.firstname.toString().contains(_userName);
      final isCusMatch = _companyName == "" || contact.projectName == _companyName;

      return isWithinDateRange && isStatusMatch && isEmpMatch && isCusMatch;
    }).toList();

    print("Filtered Count: ${_filterExpenseData.length}");
    notifyListeners();
  }

  void initFilterValue(bool isClear){
    if(isClear==false){
      _isFilter=true;
    }else{
      _isFilter=false;
      daily();
      _filterType="Today";
      _type=null;
      _companyName="";
      _filterExpenseData=_expenseData;
    }
    _filterDate="";
    _stDate="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}";
    _enDate="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}";
    search.clear();
    notifyListeners();
  }
  void initExpenseValue(String date1,String date2,String type){
    _isFilter=false;
    _filterType=type;
    _type=null;
    _companyName="";
    _filterExpenseData=_expenseData;
    _filterDate="";
    _startDate=date1;
    _endDate=date2;
    search.clear();
    initFilterList(date1,date2);
    notifyListeners();
  }

  void changeDate(){
    typeId="";
    _userName="";
    _stDate="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}";
    _enDate="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}";
  }
  void showDatePickerDialog(BuildContext context) {
    DateTime today = DateTime.now();
    selectedDate = PickerDateRange(today, today);
    datesBetween = getDatesInRange(selectedDate!.startDate!, selectedDate!.endDate!);

    DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    List<String> formattedDates = datesBetween.map((date) => dateFormat.format(date)).toList();
    betweenDates = formattedDates.join(' || ');

    _startDate = dateFormat.format(selectedDate!.startDate!);
    notifyListeners();
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
              minDate: DateTime(2025), // Disable past dates
              maxDate: DateTime.now(),
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                selectedDate = args.value;
                _startDate="";
                _endDate="";
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
                  _endDate="${selectedDate?.startDate?.day.toString().padLeft(2,"0")}"
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
                    initFilterValue(false);
                    filterList();
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

List<SimpleExpModel> _simpleExp=[];
List<SimpleExpModel> get simpleExp=>_simpleExp;
TextEditingController date=TextEditingController(text: "${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}");
TextEditingController from = TextEditingController();
TextEditingController to = TextEditingController();
TextEditingController bus = TextEditingController();
TextEditingController auto = TextEditingController();
TextEditingController rent = TextEditingController();
TextEditingController food = TextEditingController();
TextEditingController purchase = TextEditingController();

void addSimpleExp(){
  _simpleExp.add(SimpleExpModel(
      doc: "",
      docName: TextEditingController()));
  notifyListeners();
}

List<OtherExpModel> _otherExp=[];
List<OtherExpModel> get otherExp=>_otherExp;
void addOtherExp(){
  _otherExp.add(OtherExpModel(
      date: TextEditingController(),
      particular: TextEditingController(),
      amount: TextEditingController()));
  _otherIndex=_otherExp.length-1;
  notifyListeners();
}
void removeOtherExp(int index){
  _otherExp.removeAt(index);
  _otherIndex=_otherExp.length-1;
  gradeWithDAAmt();
  notifyListeners();
}
void changeOtherExp(bool isAdd) {
  if (isAdd) {
    if (_otherIndex < _otherExp.length - 1) {
      _otherIndex++;
    }
  } else {
    if (_otherIndex > 0) {
      _otherIndex--;
    }
  }
  notifyListeners();
}



int _conveyanceIndex = 0;
int get conveyanceIndex =>_conveyanceIndex;
List<ConveyanceExpModel> _conveyanceExp=[];
List<ConveyanceExpModel> get conveyanceExp=>_conveyanceExp;
void addConveyanceExp(String date){
  _conveyanceExp.add(ConveyanceExpModel(
      from: TextEditingController(),
      to: TextEditingController(),
      date: TextEditingController(text: date),
      amt: TextEditingController(text: localData.storage.read("conveyance_amount")),
      mode: null, modeId: '', modeName: ''));
  _conveyanceIndex=_conveyanceExp.length-1;
  notifyListeners();
}
void removeConveyanceExp(int index){
  _conveyanceExp.removeAt(index);
  _conveyanceIndex=_conveyanceExp.length-1;
  addConvAmt();
  notifyListeners();
}
void changeConveyanceExp(bool isAdd) {
  if (isAdd) {
    if (_conveyanceIndex < _conveyanceExp.length - 1) {
      _conveyanceIndex++;
    }
  } else {
    if (_conveyanceIndex > 0) {
      _conveyanceIndex--;
    }
  }
  notifyListeners();
}

// final List _modeList=["Bike","Car","Bus","Auto","Train","Flight"];
// List get modeList =>_modeList;
void updateMode(dynamic value){
  _conveyanceExp[_conveyanceIndex].mode=value;
  var list = [];
  list.add(value);
  _conveyanceExp[_conveyanceIndex].modeId=list[0]["id"].toString();
  _conveyanceExp[_conveyanceIndex].modeName=list[0]["value"].toString();
  notifyListeners();
}
void updateTraMode(dynamic value){
  _travelExp[_travelIndex].mode=value;
  var list = [];
  list.add(value);
  _travelExp[_travelIndex].modeId=list[0]["id"].toString();
  _travelExp[_travelIndex].modeName=list[0]["value"].toString();
  notifyListeners();
}
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

  // void showDatePickerDialog(BuildContext context) {
  //   DateTime today = DateTime.now();
  //   selectedDate = PickerDateRange(today, today);
  //   datesBetween = getDatesInRange(selectedDate!.startDate!, selectedDate!.endDate!);
  //
  //   DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  //   List<String> formattedDates = datesBetween.map((date) => dateFormat.format(date)).toList();
  //   betweenDates = formattedDates.join(' || ');
  //
  //   _startDate = dateFormat.format(selectedDate!.startDate!);
  //   notifyListeners();
  //   notifyListeners();
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: CustomText(text: '   Select Date',colors: colorsConst.secondary,isBold: true,),
  //         content: SizedBox(
  //           height: 300, // Adjust height as needed
  //           width: 300, // Adjust width as needed
  //           child: SfDateRangePicker(
  //             minDate: DateTime(2025), // Disable past dates
  //             maxDate: DateTime.now(),
  //             onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
  //               selectedDate = args.value;
  //               _startDate="";
  //               _endDate="";
  //               if(selectedDate?.endDate!=null){
  //                 _startDate="${selectedDate?.startDate?.day.toString().padLeft(2,"0")}"
  //                     "-${selectedDate?.startDate?.month.toString().padLeft(2,"0")}"
  //                     "-${selectedDate?.startDate?.year.toString()}";
  //
  //                 _endDate="${selectedDate?.endDate?.day.toString().padLeft(2,"0")}"
  //                     "-${selectedDate?.endDate?.month.toString().padLeft(2,"0")}"
  //                     "-${selectedDate?.endDate?.year.toString()}";
  //               }else{
  //                 _startDate="${selectedDate?.startDate?.day.toString().padLeft(2,"0")}"
  //                     "-${selectedDate?.startDate?.month.toString().padLeft(2,"0")}"
  //                     "-${selectedDate?.startDate?.year.toString()}";
  //                 _endDate="${selectedDate?.startDate?.day.toString().padLeft(2,"0")}"
  //                     "-${selectedDate?.startDate?.month.toString().padLeft(2,"0")}"
  //                     "-${selectedDate?.startDate?.year.toString()}";
  //               }
  //               notifyListeners();
  //             },
  //             selectionMode: DateRangePickerSelectionMode.range,
  //           ),
  //         ),
  //         actions: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               CustomText(text: 'Click and drag to select multiple dates',colors: colorsConst.greyClr,),
  //             ],
  //           ),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               TextButton(
  //                 child: const CustomText(text:'Cancel',colors: Colors.grey,isBold: true,),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //               ),
  //               TextButton(
  //                 child: CustomText(text: 'OK',colors: colorsConst.primary,isBold: true,),
  //                 onPressed: () {
  //                   if (selectedDate != null) {
  //                     datesBetween = getDatesInRange(
  //                       selectedDate!.startDate!,
  //                       selectedDate!.endDate ?? selectedDate!.startDate!,
  //                     );
  //                   }
  //                   DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  //
  //                   List<String> formattedDates = datesBetween.map((date) => dateFormat.format(date)).toList();
  //                   betweenDates = formattedDates.join(' || ');
  //                   initFilterValue(false);
  //                   filterList();
  //                   notifyListeners();
  //                   Navigator.of(context).pop();
  //                 },
  //               ),
  //             ],
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
 
  Future<void> insertExpense(
      context, {
        required String taskId,
        required String coId,
        required List numberList,
        required String companyName,
        required String tType,
        required String desc,
      }) async {
   try{
     List<Map<String, String>> customersList = [];

     // Gather image/document files
     for (int i = 0; i < _selectedFiles1.length; i++) {
       customersList.add({
         "images_$i": _selectedFiles1[i]['path'],
         "type": "1",
       });
     }

     for (int i = 0; i < _selectedFiles2.length; i++) {
       customersList.add({
         "images_${i + _selectedFiles1.length}": _selectedFiles2[i]['path'],
         "type": "2",
       });
     }
     for (int i = 0; i < _selectedFiles3.length; i++) {
       customersList.add({
         "images_${i + _selectedFiles1.length + _selectedFiles2.length}": _selectedFiles3[i]['path'],
         "type": "3",
       });
     }
     for (int i = 0; i < _selectedPhotos1.length; i++) {
       customersList.add({
         "images_${i + _selectedFiles1.length + _selectedFiles2.length + _selectedFiles3.length}": _selectedPhotos1[i],
         "type": "1",
       });
     }
     for (int i = 0; i < _selectedPhotos2.length; i++) {
       customersList.add({
         "images_${i + _selectedFiles1.length + _selectedFiles2.length + _selectedFiles3.length + _selectedPhotos1.length}": _selectedPhotos2[i],
         "type": "2",
       });
     }
     for (int i = 0; i < _selectedPhotos3.length; i++) {
       customersList.add({
         "images_${i + _selectedFiles1.length + _selectedFiles2.length + _selectedFiles3.length + _selectedPhotos1.length + _selectedPhotos2.length}": _selectedPhotos3[i],
         "type": "3",
       });
     }
     String jsonString = json.encode(customersList);

     // Remove incomplete entries
     _conveyanceExp.removeWhere((e) =>
     e.date.text.trim().isEmpty ||
         e.from.text.trim().isEmpty ||
         e.to.text.trim().isEmpty ||
         e.mode == null ||
         e.amt.text.trim().isEmpty
     );

     _travelExp.removeWhere((e) =>
     e.from.text.trim().isEmpty ||
         e.stDate.text.trim().isEmpty ||
         e.stTime.text.trim().isEmpty ||
         e.to.text.trim().isEmpty ||
         e.enDate.text.trim().isEmpty ||
         e.enTime.text.trim().isEmpty ||
         e.mode == null ||
         e.amt.text.trim().isEmpty
     );

     _otherExp.removeWhere((e) =>
     e.date.text.trim().isEmpty ||
         e.particular.text.trim().isEmpty ||
         e.amount.text.trim().isEmpty
     );

     Map<String, String> data = {
       "action": insertExp,
       "task_id": taskId,
       "emp_id": localData.storage.read("id"),
       "place_visited": visitPlace.text.trim(),
       "client_name": client.text.trim(),
       "purpose": purpose.text.trim(),
       "advance": advance.text.trim(),
       "amount": totalAmt.text.trim(),
       "balance": balanceTo.text.trim(),
       "vocher_no": voucherNo.text.trim(),
       "debit_to": debitTo.text.trim(),
       "travel_amt": _travelAmt.toString(),
       "da_amt": _otherAmt.toString(),
       "conveyance_amt": _convAmt.toString(),
       "created_by": localData.storage.read("id"),
       "platform": localData.storage.read("platform").toString(),
       "cos_id": localData.storage.read("cos_id"),
       "data": jsonString,
       "travel_expense": json.encode(_travelExp.map((e) => e.toJson()).toList()),
       "da_expense": json.encode(_otherExp.map((e) => e.toJson()).toList()),
       "conveyance_expense": json.encode(_conveyanceExp.map((e) => e.toJson()).toList()),
     };

     var uri = Uri.parse(phpFile);
     var request = http.MultipartRequest("POST", uri);

     for (var i = 0; i < customersList.length; i++) {
       var fieldName = customersList[i].keys.first; // e.g., "images_0"
       var imagePath = customersList[i][fieldName];
       if (imagePath != null && imagePath.isNotEmpty) {
         var file = await http.MultipartFile.fromPath(fieldName, imagePath);
         request.files.add(file);
       }
     }

     request.fields.addAll(data);

     var response = await request.send();
     var result = await http.Response.fromStream(response);
     // print('Files ....${request.files}');
     // print('RESULT ....${result.body}');
     if (result.body.contains("success")) {
       utils.showSuccessToast(context: context, text: constValue.success);
       Provider.of<TaskProvider>(context, listen: false).getAllTask(false);
       utils.navigatePage(context, () => DashBoard(
         child: TaskReport(
           taskId: taskId,
           coId: coId,
           numberList: numberList,
           isTask: false,
           coName: companyName,
           description: desc,
           type: tType,
             callback: () {
               Future.microtask(() => Navigator.pop(context));
               Future.microtask(() => Navigator.pop(context));
             }, index: 2,
         ),
       ));
       Provider.of<EmployeeProvider>(context, listen: false).sendRoleNotification(
         "Expenses added to task.",
         "Expenses added to task ${companyName=="null"?"":companyName} - Amount - ${totalAmt.text.trim()}",
         "1",
       );
       await FirebaseFirestore.instance.collection('attendance').add({
         'emp_id': localData.storage.read("id"),
         'time': DateTime.now(),
         'status': "",
       });
       addCtr.reset();
       notifyListeners();
     } else {
       addCtr.reset();
       utils.showErrorToast(context: context);
     }
   }catch(e){
     addCtr.reset();
     utils.showErrorToast(context: context);
   }
  }


  Future<void> createExp(context, {required String projectId}) async {
    try{
      List<Map<String, String>> loanControllers = [];
      for (int i = 0; i < _simpleExp.length; i++) {
        loanControllers.add({
          "image_$i": _simpleExp[i].doc,
          "document_names": _simpleExp[i].docName.text,
        });
      }
      String jsonString = json.encode(loanControllers);
      Map<String, String> requestData = {
        "action": createExpense,
        "project_id": projectId,
        "data": jsonString,
        "log_file":localData.storage.read("mobile_number"),
        "platform":localData.storage.read("platform").toString(),
        "emp_id":localData.storage.read("id"),
        "date":date.text,
        "expense_from":from.text.trim(),
        "expense_to":to.text.trim(),
        "bus":bus.text.isEmpty?"0":bus.text.trim(),
        "auto":auto.text.isEmpty?"0":auto.text.trim(),
        "rent":rent.text.isEmpty?"0":rent.text.trim(),
        "food":food.text.isEmpty?"0":food.text.trim(),
        "purchase":purchase.text.isEmpty?"0":purchase.text.trim(),
        "amount":totalExpense.toString(),
        "created_by":localData.storage.read("id"),
        "cos_id":localData.storage.read("cos_id"),
      };

      var uri = Uri.parse(phpFile);
      var request = http.MultipartRequest("POST", uri);

      for (var i = 0; i < loanControllers.length; i++) {
        var fieldName = loanControllers[i].keys.first; // e.g., "images_0"
        var imagePath = loanControllers[i][fieldName];
        if (imagePath != null && imagePath.isNotEmpty) {
          var file = await http.MultipartFile.fromPath(fieldName, imagePath);
          request.files.add(file);
        }
      }
      request.fields.addAll(requestData);
      var response = await request.send();
      var result = await http.Response.fromStream(response);
      print('Files ....${request.files}');
      print('RESULT ....${result.body}');
      if (result.body.contains("ok")) {
        utils.showSuccessToast(context: context, text: constValue.success);
        addCtr.reset();
        Navigator.pop(context);
        Provider.of<ProjectProvider>(context, listen: false).getAllProject(true);
        notifyListeners();
      } else {
        addCtr.reset();
        utils.showErrorToast(context: context);
      }
    }catch(e){
      addCtr.reset();
      utils.showErrorToast(context: context);
    }
  }

  var reportTypeList = [
  "Total",
  "DA",
  "Travel",
  "Conveyance"
];
List expenseList=[];
void initIndex(){
  statusController.selectIndex(0);
  notifyListeners();
}
final statusController = GroupButtonController();
var _expense;
get expense => _expense;
void changeExpense(String value) {
  _expense = value;
  notifyListeners();
}
bool _refresh = true;
bool _deRefresh = true;
bool get refresh =>_refresh;
bool get deRefresh =>_deRefresh;
List<ExpenseModel> _expenseData = <ExpenseModel>[];
List<ExpenseModel> _searchExpenseData = <ExpenseModel>[];
List<ExpenseModel> _expenseDetail = <ExpenseModel>[];
List<ExpenseModel> get expenseData => _expenseData;
List<ExpenseModel> get searchExpenseData => _searchExpenseData;
List<ExpenseModel> get expenseDetail => _expenseDetail;
  Future<void> getExpenseType() async {
    try {
      expenseList.clear();
      notifyListeners();
      Map data = {
        "action": getAllData,
        "search_type":"category",
        "cat_id":"6",
        "cos_id": localData.storage.read("cos_id")
      };
      final response =await expenseRepo.getReport(data);
      // print(data.toString());
      // print(response.toString());
      if (response.isNotEmpty) {
        List<Map<String, String>> callList = response.map((e) => {
          "id": e['id'].toString(),
          "value": e['value'].toString(),
          "categories": e['categories'].toString()
        }).toList();
        if(!kIsWeb){
          await LocalDatabase.insertExpenseType(callList);
        }else{
          expenseList=callList;
          notifyListeners();
        }
      }
    } catch (e) {
      // _refresh=true;
    }
    notifyListeners();
  }

Future<void> getExpenseDetails(String id) async {
  _expenseDetail.clear();
  _deRefresh=false;
  notifyListeners();
  try {
    Map data = {
      "action": getAllData,
      "search_type":"expense_details",
      "id":id,
      "cos_id":localData.storage.read("cos_id")
    };
    final response =await expenseRepo.trackList(data);
    // print(data.toString());
    if (response.isNotEmpty) {
      _expenseDetail=response;
      // print(_expenseDetail);
      _deRefresh=true;
    } else {
      _deRefresh=true;
    }
  } catch (e) {
    _deRefresh=true;
  }
  notifyListeners();
}
  Future<void> getAllExpense({String? date1, String? date2}) async {
    _filter="1";
    _status=null;
    matched=0;
    search.clear();
    _expenseData.clear();
    _searchExpenseData.clear();
    _filterExpenseData.clear();
    _refresh=false;
    notifyListeners();
    try {
      Map data = {
        "action": getAllData,
        "search_type":"emp_expense",
        "id":localData.storage.read("id"),
        "role":localData.storage.read("role"),
        "cos_id":localData.storage.read("cos_id")
      };
      final response =await expenseRepo.trackList(data);
      // print(data.toString());
      // print(response.toString());
      if (response.isNotEmpty) {
        _expenseData=response;
        _searchExpenseData=response;
        _filterExpenseData=response;
        filterList();
        initFilterList(date1!,date2!);
        _refresh=true;
      } else {
        _refresh=true;
      }
    } catch (e) {
      _refresh=true;
    }
    notifyListeners();
  }
Future<void> getTaskExpense(String taskId) async {
  _expenseData.clear();
  _searchExpenseData.clear();
  _refresh=false;
  notifyListeners();
  try {
    Map data = {
      "action": getAllData,
      "search_type":"task_expense",
      "task_id":taskId,
      "id":localData.storage.read("id"),
      "role":localData.storage.read("role"),
      "cos_id":localData.storage.read("cos_id")
    };
    final response =await expenseRepo.trackList(data);
    // print(data.toString());
    if (response.isNotEmpty) {
      _expenseData=response;
      _searchExpenseData=response;
      _refresh=true;
    } else {
      _refresh=true;
    }
  } catch (e) {
    _refresh=true;
  }
  notifyListeners();
}

final RoundedLoadingButtonController downloadCtr=RoundedLoadingButtonController();
final RoundedLoadingButtonController pdfDownloadCtr=RoundedLoadingButtonController();
final RoundedLoadingButtonController approveCtr=RoundedLoadingButtonController();
final RoundedLoadingButtonController rejectCtr=RoundedLoadingButtonController();
Future<void> expenseActive(context,{required String createdBy,required String companyName,required bool isDirect,
  required String expenseId,required String visitId,required String companyId,required String status}) async {
  try {
    Map<String, String> data = {
      "action": manageExpense,
      "expense_id": expenseId,
      "status": status,
      "manage_cmt": deleteReason.text,
      "approval_amount": approveAmt.text,
      "updated_by": localData.storage.read("id"),
      "up_platform": localData.storage.read("platform").toString(),
      "log_file": localData.storage.read("mobile_number").toString(),
    };
    final response =await expenseRepo.manageExpense(data);
    log(response.toString());
    if (response["status_code"]==200){
      utils.showSuccessToast(context: context,text: status=="0"?"Rejected successfully":"Approved successfully.",);
      Provider.of<HomeProvider>(context, listen: false).getMainReport(false);
      if(status=="0"){
        Provider.of<EmployeeProvider>(context, listen: false).sendUserNotification(
            "Your Expenses Rejected",
            "Task $companyName – Expenses of ₹${approveAmt.text.trim()} Rejected."
                "\nReason: ${deleteReason.text.trim()}.",createdBy);
      }else{
        Provider.of<EmployeeProvider>(context, listen: false).sendUserNotification(
            "Your Expenses Approved",
            "Expenses Approved for Task at ${companyName=="null"?"":companyName}",createdBy);
      }
      Navigator.pop(context);
      Navigator.pop(context);
      if(isDirect==true){
        getAllExpense(date1:Provider.of<HomeProvider>(context, listen: false).startDate,date2:Provider.of<HomeProvider>(context, listen: false).endDate);
      }else{
        getTaskExpense(visitId);
      }
      rejectCtr.reset();
      approveCtr.reset();
    }else {
      utils.showErrorToast(context: context);
      approveCtr.reset();
      rejectCtr.reset();
    }
  } catch (e) {
    log(e.toString());
    utils.showErrorToast(context: context);
    rejectCtr.reset();
    approveCtr.reset();
  }
  notifyListeners();
}
  List<ExpenseModel> _downloadExpenseData = <ExpenseModel>[];
  List<ExpenseModel> get downloadExpenseData => _downloadExpenseData;

  Future<void> downloadAllExpense(context) async {
    _downloadExpenseData.clear();
    notifyListeners();
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      Map data = {
        "action": getAllData,
        "search_type":"download_expense_details",
        "id":localData.storage.read("id"),
        "role":localData.storage.read("role"),
        "date1":_startDate,
        "date2":_endDate,
        "cos_id":localData.storage.read("cos_id")
      };
      final response =await expenseRepo.trackList(data);
      // print(data.toString());
      if (response.isNotEmpty) {
        _downloadExpenseData = response.where((contact) {
          final isStatusMatch = _type == null || contact.status.toString().contains(typeId);
          final isEmpMatch = _userName == "" || contact.firstname.toString().contains(_userName);
          final isCusMatch = _companyName == "" || contact.projectName == _companyName;

          return isStatusMatch && isEmpMatch && isCusMatch;
        }).toList();
        downloadCtr.reset();
        exportAllExpenseReportAsPDF(context: context,empName: "",dataList: _downloadExpenseData);
        _refresh=true;
      } else {
        utils.showWarningToast(context, text: "No Expense Found");
        Navigator.pop(context);
        downloadCtr.reset();
      }
    } catch (e) {
      utils.showWarningToast(context, text: "No Expense Found");
      Navigator.pop(context);
      downloadCtr.reset();
    }
    notifyListeners();
  }

  Future<void> exportAllExpenseReportAsPDF({required BuildContext context,required String empName,required List<ExpenseModel> dataList}) async {
    try {
      downloadCtr.reset();
      final pdf = pw.Document();

      // ₹ Formatter
      String formatAmount(String amount) {
        final numValue = double.tryParse(amount.replaceAll(',', '')) ?? 0;
        final formatted = NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(numValue);
        return formatted;
      }

      final fontRegular = pw.Font.ttf(await rootBundle.load('assets/font/Roboto-Regular.ttf'));

      // Compress & preload image from network
      Future<pw.MemoryImage?> loadImage(String url) async {
        try {
          final response = await http.get(Uri.parse("$imageFile?path=$url"));
          if (response.statusCode == 200) {
            final bytes = response.bodyBytes;
            if (bytes.isNotEmpty) {
              final compressed = await FlutterImageCompress.compressWithList(
                bytes,
                quality: 60,
                minWidth: 600,
                minHeight: 600,
              );
              return pw.MemoryImage(compressed);
            }
          }
        } catch (_) {}
        return null;
      }

      // Cache images
      final Map<String, pw.MemoryImage> imageCache = {};
      for (final item in dataList) {
        for (final url in [
          ...?item.document1?.split('||'),
          ...?item.document2?.split('||'),
          ...?item.document3?.split('||'),
        ]) {
          if (url.isNotEmpty && url != 'null' && !imageCache.containsKey(url)) {
            final img = await loadImage(url);
            if (img != null) imageCache[url] = img;
          }
        }
      }

      // Function: Build image rows (3 per row)
      List<pw.Widget> buildImageRows(List<pw.MemoryImage> images) {
        const perRow = 3;
        List<pw.Widget> rows = [];
        for (int i = 0; i < images.length; i += perRow) {
          rows.add(
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: images
                  .skip(i)
                  .take(perRow)
                  .map((img) => pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.ClipRRect(
                  horizontalRadius: 10,
                  verticalRadius: 10,
                  child: pw.Image(img, width: 170, height: 120), // Bigger image
                ),
              ))
                  .toList(),
            ),
          );
        }
        return rows;
      }

      pdf.addPage(
        pw.MultiPage(
          theme: pw.ThemeData.withFont(base: fontRegular),
          build: (pw.Context context) {
            List<pw.Widget> content = [];

            content.add(
              pw.Header(
                level: 0,
                child: pw.Text(
                  'EXPENSE REPORT',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
            );

            for (final item in dataList) {
              final visitedParts = [
                item.addressLine,
                item.city,
                item.state,
              ];

              final visited = visitedParts
                  .where((e) => e != null && e.trim().isNotEmpty)
                  .join(", ");

              content.addAll([
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Added By : ${item.firstname} (${item.role})',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Status : ${item.status.toString() == "0" ? "Rejected" : item.status.toString() == "2" ? "Approved" : "In Process"}',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.Text(
                  '${constValue.customerName} : ${item.projectName ?? 'N/A'}',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                if(visited!="")
                pw.Text(
                  'Place Visited : $visited',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Text('Purpose : ${item.taskTitle ?? 'N/A'}', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Amount : ${formatAmount(item.amount ?? '0')}', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Approved Amount : ${formatAmount(item.approvalAmt ?? '0')}', style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 10),
              ]);

              // DA Section
              if ((item.dadate ?? '').isNotEmpty) {
                content.addAll([
                  pw.Text('DA/Board/Lodging/Other Expense', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Table.fromTextArray(
                    headers: ['# of Days', 'Particular', 'Amount'],
                    data: List.generate(
                      item.dadate!.split('||').length,
                          (i) => [
                        item.dadate!.split('||')[i],
                        item.daparticular!.split('||')[i],
                        formatAmount(item.daamount!.split('||')[i])
                      ],
                    ),
                  ),
                ]);

                if ((item.document1 ?? '').isNotEmpty) {
                  final images = item.document1!
                      .split('||')
                      .where((url) => url.isNotEmpty && url != 'null')
                      .map((url) => imageCache[url])
                      .whereType<pw.MemoryImage>()
                      .toList();
                  if (images.isNotEmpty) {
                    content.addAll([
                      pw.SizedBox(height: 10),
                      pw.Text('DA Documents:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ...buildImageRows(images),
                    ]);
                  }
                }
              }

              // Travel Section
              if ((item.txfrom ?? '').isNotEmpty) {
                content.addAll([
                  pw.SizedBox(height: 10),
                  pw.Text('Travel Expense', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Table.fromTextArray(
                    headers: ['From', 'Start Date', 'Start Time', 'To', 'End Date', 'End Time', 'Mode', 'Amount'],
                    data: List.generate(
                      item.txfrom!.split('||').length,
                          (i) => [
                        item.txfrom!.split('||')[i],
                        item.txstartDate!.split('||')[i],
                        item.txstartTime!.split('||')[i],
                        item.txto!.split('||')[i],
                        item.txendDate!.split('||')[i],
                        item.txendTime!.split('||')[i],
                        item.txmode!.split('||')[i],
                        formatAmount(item.txamount!.split('||')[i])
                      ],
                    ),
                  ),
                ]);

                if ((item.document2 ?? '').isNotEmpty) {
                  final images = item.document2!
                      .split('||')
                      .where((url) => url.isNotEmpty && url != 'null')
                      .map((url) => imageCache[url])
                      .whereType<pw.MemoryImage>()
                      .toList();
                  if (images.isNotEmpty) {
                    content.addAll([
                      pw.SizedBox(height: 10),
                      pw.Text('Travel Documents:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ...buildImageRows(images),
                    ]);
                  }
                }
              }

              // Conveyance
              if ((item.cedate ?? '').isNotEmpty) {
                content.addAll([
                  pw.SizedBox(height: 10),
                  pw.Text('Conveyance Expense', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Table.fromTextArray(
                    headers: ['Date', 'From', 'To', 'Mode', 'Amount'],
                    data: List.generate(
                      item.cedate!.split('||').length,
                          (i) => [
                        item.cedate!.split('||')[i],
                        item.cefrom!.split('||')[i],
                        item.ceto!.split('||')[i],
                        item.cemode!.split('||')[i],
                        formatAmount(item.ceamount!.split('||')[i])
                      ],
                    ),
                  ),
                ]);

                if ((item.document3 ?? '').isNotEmpty) {
                  final images = item.document3!
                      .split('||')
                      .where((url) => url.isNotEmpty && url != 'null')
                      .map((url) => imageCache[url])
                      .whereType<pw.MemoryImage>()
                      .toList();
                  if (images.isNotEmpty) {
                    content.addAll([
                      pw.SizedBox(height: 10),
                      pw.Text('Conveyance Documents:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ...buildImageRows(images),
                    ]);
                  }
                }
              }

              content.add(pw.Divider());
            }

            return content;
          },
        ),
      );
      downloadCtr.reset();
      // Save PDF (replace with your own save method)
      final bytes = await pdf.save();
      downloadCtr.reset();
      await savePDF("All_Expenses_Report", pdf);
      Navigator.pop(context); // close loader
      downloadCtr.reset();
    } catch (e) {
      downloadCtr.reset();
      Navigator.pop(context); // close loader if error
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something Went Wrong")));
    }
  }

void calBalance(){
  balanceTo.clear();
  balanceTo.text=(int.parse(totalAmt.text)-int.parse(advance.text)).toString();
  notifyListeners();
}
  void initValue(){
    _type="Today";
    _type2="Today";
    _type3="Today";
    _exType=null;
    _user=null;
    search.clear();
    _month2=DateFormat("MMM yyyy").format(DateTime.now());
    notifyListeners();
    daily();
    daily2();
    daily3();
    // _month=DateFormat("MMM yyyy").format(DateTime.now());
    // _month2=DateFormat("MMM yyyy").format(DateTime.now());
    // _month4=DateFormat("MMM yyyy").format(DateTime.now());
    // _monthStart=startDate;
    // _monthStart2=startDate;
    // _monthStart4=startDate;
    // _monthEnd=endDate;
    // _monthEnd2=endDate;
    // _monthEnd4=endDate;
    notifyListeners();
  }

  dynamic _exType;
  dynamic get exType=>_exType;
  void selectType(value){
    _exType=value;
    var list = [];
    list.add(value);
    localData.storage.write("mode_id", list[0]["id"]);
    expenseHeadReport(localData.storage.read("mode_id"));
    notifyListeners();
  }
  List<MonthReport> _report = [];
  List<MonthReport> get report => _report;
  var typeList = ["Today","Yesterday","Last 7 Days","Last 30 Days","This Week","This Month","Last 3 months"];
  bool _refresh1=true;
  bool get refresh1 =>_refresh1;
  Future<void> expenseHeadReport(String id) async {
    try {
      _report=[];
      _refresh1=false;
      Map data = {
        "action": getAllData,
        "search_type":"expense_head",
        "cos_id":localData.storage.read("cos_id"),
        "role":localData.storage.read("role"),
        "id":localData.storage.read("role")=="1"?id:localData.storage.read("id"),
        "mode_id":localData.storage.read("mode_id"),
        "date1":_startDate,
        "date2":_endDate,
      };
      final response = await expenseRepo.getChartReport(data);
      if(response.isNotEmpty){
        _report=response;
        _refresh1=true;
      }
      else{
        _report=[];
        _refresh1=true;
      }
    } catch (e) {
      _report=[];
      _refresh1=true;
    }
    notifyListeners();
  }

  String _startDate = "";
  String get startDate => _startDate;
  String _endDate="";
  String get endDate => _endDate;
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
    expenseHeadReport(localData.storage.read("mode_id"));
    notifyListeners();
  }
  DateTime stDt = DateTime.now();
  DateTime enDt = DateTime.now().add(const Duration(days: 1));
  void daily() {
    stDt=DateTime.now();
    // enDt=DateTime.now().add(const Duration(days: 1));
    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(stDt);
    notifyListeners();
  }
  void yesterday() {
    stDt=DateTime.now().subtract(const Duration(days: 1));
    // enDt = DateTime.now();
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

  /// REPORT 2
  dynamic _type2;
  dynamic get type2 =>_type2;
  String _startDate2 = "";
  String get startDate2 => _startDate2;
  String _endDate2="";
  String get endDate2 => _endDate2;
  void datePick2({required BuildContext context,required String date,}) {
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
    DateTime lastMonthStart = now.subtract(const Duration(days: 29));
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

// Subtract 3 months from today
    DateTime stDt = DateTime(now.year, now.month - 3, now.day);
    DateTime enDt = now;

    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
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

  void showCustomMonthPicker2({
    required BuildContext context,
    required void Function() function,
  }) {
    DateTime now = DateTime.now();
    DateTime initialDate;
    try {
      initialDate = _month2.isNotEmpty
          ? DateFormat("MMM yyyy").parse(_month2)
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
                _month2=DateFormat("MMM yyyy").format(value);
                _startDate2=startDate;
                _endDate2=endDate;
                function();
                notifyListeners();
              },
            ),
          ),
        );
      },
    );
  }
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
        "search_type":"travels_report",
        "cos_id":localData.storage.read("cos_id"),
        "role":localData.storage.read("role"),
        "id":localData.storage.read("id"),
        "date1":_startDate2,
        "date2":_endDate2,
      };
      final response = await expenseRepo.getReport(data);
      // print("nvf ${data}");
      // print("nvf ${response}");
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

  List<BarChartGroupData> get barGroups => _report.asMap().entries.map((entry) {
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
  List<BarChartGroupData> get barGroups2 => _report3.asMap().entries.map((entry) {
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
  FlTitlesData get titlesData2 => FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        getTitlesWidget: getTitles2,
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
  Widget getTitles(double value, TitleMeta meta,) {
    final style = TextStyle(
      color: colorsConst.primary.withOpacity(0.6),
      fontSize: 12,
    );
    int index = value.toInt();

    String formattedDate ="";
    if(_type=="Last 30 Days"||_type=="This Month"||_type=="Last 3 months"){
      DateTime parsedDate = DateTime.parse(_report[index].expenseDate.toString()); // parses "2025-04-15"
      formattedDate = DateFormat('dd-MMM\nyy').format(parsedDate);
    }else{
      formattedDate = DateFormat('dd/MM - EEE').format(DateFormat('yyyy-MM-dd').parse(_report[index].expenseDate!)).split('-').last;
    }

    String text = index >= 0 && index <_report.length ? formattedDate: '';
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 2,
      child: Text(text, style: style),
    );
  }
  Widget getTitles2(double value, TitleMeta meta,) {
    final style = TextStyle(
      color: colorsConst.primary.withOpacity(0.6),
      fontSize: 12,
    );
    int index = value.toInt();
    String formattedDate ="";
    if(_type3=="Last 30 Days"||_type3=="This Month"||_type3=="Last 3 months"){
      DateTime parsedDate = DateTime.parse(_report3[index].date2.toString()); // parses "2025-04-15"
      formattedDate = DateFormat('dd-MMM\nyy').format(parsedDate);
    }else{
      formattedDate = DateFormat('dd/MM - EEE').format(DateFormat('yyyy-MM-dd').parse(_report3[index].date2!)).split('-').last;
    }

    String text = index >= 0 && index <_report3.length ? formattedDate: '';
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Text(text, style: style),
      ),
    );
  }

  // String formatDate(String date) {
  //   DateTime dates = DateFormat('yyyy-MM-dd').parse(date);
  //   String formatted = DateFormat('dd/MM - EEE').format(dates);
  //   return formatted;
  // }

  dynamic _user;
dynamic get user=>_user;
  dynamic _type3;
  dynamic get type3 =>_type3;
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
    getReport3();
    notifyListeners();
  }
  DateTime stDt3 = DateTime.now();
  DateTime enDt3 = DateTime.now().add(const Duration(days: 1));
  String _startDate3 = "";
  String get startDate3 => _startDate3;
  String _endDate3="";
  String get endDate3 => _endDate3;
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

// Subtract 3 months from today
    DateTime stDt = DateTime(now.year, now.month - 3, now.day);
    DateTime enDt = now;

    _startDate = DateFormat('dd-MM-yyyy').format(stDt);
    _endDate = DateFormat('dd-MM-yyyy').format(enDt);
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
  Future<void> getReport3() async {
    try {
      _report3=[];
      _refresh3=false;
      Map data = {
        "action": getAllData,
        "search_type":"emp_expense_report",
        "cos_id":localData.storage.read("cos_id"),
        "role":localData.storage.read("role"),
        "id":localData.storage.read("role")=="1"?_user:localData.storage.read("id"),
        "date1":_startDate3,
        "date2":_endDate3,
      };
      final response = await expenseRepo.getChartReport(data);
      // print("nvf ${data}");
      // print("_report3 ${response}");
      if(response.isNotEmpty){
        _report3=response;
        _refresh3=true;
      }
      else{
        _report3=[];
        _refresh3=true;
      }
    } catch (e) {
      _report3=[];
      _refresh3=true;
    }
    notifyListeners();
  }
  void selectUser(UserModel value){
    _user=value.id;
    getReport3();
    notifyListeners();
  }

  Future<void> showPermissionDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: CustomText(text:"Permission Required",colors: colorsConst.primary,isBold: true,),
        content: CustomText(text:"This feature requires storage permission. Please enable it from Settings.",colors: colorsConst.secondary,),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              downloadCtr.reset();
            },
            child: CustomText(text:"Not Now",colors: colorsConst.appRed),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
              downloadCtr.reset();
            },
            child:  CustomText(text:"Go to Settings",colors: colorsConst.blueClr),
          ),
        ],
      ),
    );
  }
  void deleteDoc(int index){
    _simpleExp.removeAt(index);
    notifyListeners();
  }
}