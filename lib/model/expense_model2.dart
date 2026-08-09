import 'package:intl/intl.dart';

class ExpenseModel2 {
  String? id;
  String? status;
  String? firstname;
  String? role;
  String? placeVisited;
  String? clientName;
  String? purpose;
  String? advance;
  String? amount;
  String? balance;
  String? vocherNo;
  String? debitTo;
  String? createdTs;
  String? txFrom;
  String? txTo;
  String? txStartDate;
  String? txStartTime;
  String? txEndDate;
  String? txEndTime;
  String? txMode;
  String? txAmount;
  String? txRemark;
  String? daDate;
  String? daParticular;
  String? daAmount;
  String? daRemark;
  String? ceDate;
  String? ceFrom;
  String? ceTo;
  String? ceMode;
  String? ceAmount;
  String? ceRemark;
  String? daAmt;
  String? conveyanceAmt;
  String? travelAmt;
  String? projectName;
  String? taskTitle;
  String? approvalAmt;
  String? paidAmt;
  String? manageCmt;
  String? expDocs;
  String? createdBy;
  String? addressLine;
  String? city;
  String? state;
  String? document1;
  String? document2;
  String? document3;
  String? taskDate;
  String? type;
  String? daCreatedTs;
  String? daDateT;

  ExpenseModel2({
    this.id,
    this.type,
    this.status,
    this.firstname,
    this.role,
    this.placeVisited,
    this.clientName,
    this.purpose,
    this.advance,
    this.amount,
    this.balance,
    this.vocherNo,
    this.debitTo,
    this.createdTs,
    this.txFrom,
    this.txTo,
    this.txStartDate,
    this.txStartTime,
    this.txEndDate,
    this.txEndTime,
    this.txMode,
    this.txAmount,
    this.daDate,
    this.daParticular,
    this.daAmount,
    this.ceDate,
    this.ceFrom,
    this.ceTo,
    this.ceMode,
    this.ceAmount,
    this.daAmt,
    this.conveyanceAmt,
    this.travelAmt,
    this.projectName,
    this.taskTitle,
    this.approvalAmt,
    this.paidAmt,
    this.manageCmt,
    this.expDocs,
    this.createdBy,
    this.addressLine,
    this.city,
    this.state,
    this.document1,
    this.document2,
    this.document3,
    this.taskDate,
    this.txRemark,
    this.daRemark,
    this.ceRemark,
    this.daCreatedTs,
    this.daDateT,
  });

  factory ExpenseModel2.fromJson(Map<String?, dynamic> json) => ExpenseModel2(
    id: json["id"],
    type: json["type"],
    daCreatedTs: json["dacreated_ts"],
    txRemark: json["txremark"],
    daRemark: json["daremark"],
    ceRemark: json["ceremark"],
    taskDate: json["task_date"],
    approvalAmt: json["approval_amount"],
    paidAmt: json["paid_amount"],
    manageCmt: json["manage_cmt"],
    status: json["status"],
    firstname: json["firstname"],
    role: json["role"],
    placeVisited: json["place_visited"],
    clientName: json["client_name"],
    purpose: json["purpose"],
    advance: json["advance"],
    amount: json["amount"],
    balance: json["balance"],
    vocherNo: json["vocher_no"],
    debitTo: json["debit_to"],
    createdTs: json["created_ts"].toString(),
    txFrom: json["txfrom"],
    txTo: json["txto"],
    txStartDate: json["txstart_date"],
    txStartTime: json["txstart_time"],
    txEndDate: json["txend_date"],
    txEndTime: json["txend_time"],
    txMode: json["txmode"],
    txAmount: json["txamount"],
    daDate: json["dadate"],
    daParticular: json["daparticular"],
    daAmount: json["daamount"],
    daDateT: json["dadateT"],
    ceDate: json["cedate"],
    ceFrom: json["cefrom"],
    ceTo: json["ceto"],
    ceMode: json["cemode"],
    ceAmount: json["ceamount"],
    conveyanceAmt: json["conveyance_amt"],
    travelAmt: json["travel_amt"],
    daAmt: json["da_amt"],
    projectName: json["project_name"],
    taskTitle: json["task_title"],
    expDocs: json["expdocs"],
    createdBy: json["created_by"],
    addressLine: json["address_line_2"],
    city: json["city"],
    state: json["state"],
    document1: json["document1"],
    document2: json["document2"],
    document3: json["document3"],
  );
  @override
  String toString() {
    return ''' 
ExpenseModel2(
  id: $id,
  status: $status,
  firstname: $firstname,
  task_date: $taskDate,
  dadateT: $daDateT,
  role: $role,
  placeVisited: $placeVisited,
  clientName: $clientName,
  purpose: $purpose,
  advance: $advance,
  amount: $amount,
  balance: $balance,
  vocherNo: $vocherNo,
  debitTo: $debitTo,
  createdTs: $createdTs,
  txfrom: $txFrom,
  txto: $txTo,
  txstartDate: $txStartDate,
  txstartTime: $txStartTime,
  txendDate: $txEndDate,
  txendTime: $txEndTime,
  txmode: $txMode,
  txamount: $txAmount,
  dadate: $daDate,
  daparticular: $daParticular,
  daamount: $daAmount,
  cedate: $ceDate,
  cefrom: $ceFrom,
  ceto: $ceTo,
  cemode: $ceMode,
  ceamount: $ceAmount,
  da_amt: $daAmt,
  conveyance_amt: $conveyanceAmt,
  travel_amt: $travelAmt,
  project_name: $projectName,
  task_title: $taskTitle
  document1: $document1
  document2: $document2
  document3: $document3
)
''';
  }
  Map<String, dynamic> toJson() {
    return {
      'Name': firstname,
      'Role': role,
      'Place Visited': placeVisited,
      'Client Name': clientName,
      'Purpose': purpose,
      'Advance': advance,
      'Amount': amount,
      'Balance': balance,
      'Voucher No': vocherNo,
      'Debit To': debitTo,
      'Created': createdTs,
      'txfrom': txFrom,
      'txto': txTo,
      'txstartDate': txStartDate,
      'txstartTime': txStartTime,
      'txendDate': txEndDate,
      'txendTime': txEndTime,
      'txmode': txMode,
      'txamount': txAmount,
      'dadate': daDate,
      'daparticular': daParticular,
      'daamount': daAmount,
      'cedate': ceDate,
      'cefrom': ceFrom,
      'ceto': ceTo,
      'cemode': ceMode,
      'ceamount': ceAmount,
      'da_amt': daAmt,
      'conveyance_amt': conveyanceAmt,
      'travel_amt': travelAmt,
      'project_name': projectName,
      'task_title': taskTitle,
      'document1': document1,
      'document2': document2,
      'document3': document3,
    };
  }

}
// import 'package:flutter/material.dart'; // Required for BuildContext (if kept, but removed for clean data prep)

// 1. Expense Report Data Structure
// This class holds the four main tables and the final summary totals.
class ExpenseReportData2 {
  final List<Map<String, dynamic>> taskDetails;
  final List<Map<String, dynamic>> daDetails;
  final List<Map<String, dynamic>> travelDetails;
  final List<Map<String, dynamic>> conveyanceDetails;
  final double totalDaAmount;
  final double totalTravelAmount;
  final double totalConveyanceAmount;

  ExpenseReportData2({
    required this.taskDetails,
    required this.daDetails,
    required this.travelDetails,
    required this.conveyanceDetails,
    required this.totalDaAmount,
    required this.totalTravelAmount,
    required this.totalConveyanceAmount,
  });
}

// 2. Data Preparation Function (Core Logic)
ExpenseReportData2 prepareExpenseDataForExcel(List<ExpenseModel2> dataList) {
  // --- Initialization ---
  List<Map<String, dynamic>> taskDetails = [];
  List<Map<String, dynamic>> daDetails = [];
  List<Map<String, dynamic>> travelDetails = [];
  List<Map<String, dynamic>> conveyanceDetails = [];
  Map<String, List<ExpenseModel2>> groupedByProject = {};

  // --- 1. Task Details / Report Summary (Grouped by Project Name) ---
  for (var item in dataList) {
    final project = item.projectName ?? 'Unknown Project';
    groupedByProject.putIfAbsent(project, () => []).add(item);
  }

  groupedByProject.forEach((project, items) {
    List<DateTime> expenseDates = items
        .map((e) {
      try {
        final ts = e.taskDate ?? '';
        if (ts.isEmpty) return null;

        // Parse dd-MM-yyyy
        final parts = ts.split('-');
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        return DateTime(year, month, day);
      } catch (_) {
        return null;
      }
    })
        .whereType<DateTime>()
        .toList();

    if (expenseDates.isEmpty) return;

    expenseDates.sort();
    DateTime startDate = expenseDates.first;
    DateTime endDate = expenseDates.last;

    int noOfDays = endDate.difference(startDate).inDays + 1;

    double totalAmount = items.fold(
        0.0, (sum, e) => sum + (double.tryParse(e.amount ?? '0') ?? 0));

    final uniqueTaskTypes = items
        .map((e) => e.type ?? '')
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList();
    final taskType =
    uniqueTaskTypes.length == 1 ? uniqueTaskTypes.first : 'Multiple';

    taskDetails.add({
      'S.No': taskDetails.length + 1,
      'From Date': DateFormat('dd-MM-yyyy').format(startDate),
      'To Date': DateFormat('dd-MM-yyyy').format(endDate),
      'Customer Name': project,
      'Amount': totalAmount.toStringAsFixed(2),
      'Task Type': taskType,
      'No. of Days': noOfDays,
      'Per Day': (totalAmount / noOfDays).toStringAsFixed(2),
    });
  });

  // --- 2. DA / Board / Lodging / Other Expense ---
  for (var item in dataList) {
    List<String> daDates = item.daDate?.toString().split('||') ?? [];
    List<String> daCreatedTs = item.daCreatedTs?.toString().split('||') ?? [];
    List<String> daParts = item.daParticular?.toString().split('||') ?? [];
    List<String> daAmounts = item.daAmount?.toString().split('||') ?? [];
    List<String> daRemarks = item.daRemark?.toString().split('||') ?? [];


    for (int i = 0; i < daDates.length; i++) {
      // Use the timestamp if available, otherwise fallback to the date field
      String formattedDate = daDates[i];
      try {
        if (i < daCreatedTs.length && daCreatedTs[i].toString().isNotEmpty && daCreatedTs[i].toString() != "null") {
          DateTime parsedDate = DateTime.parse(daCreatedTs[i].toString());
          formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
        }
      } catch (e) {
        // Keep fallback date if parsing fails
      }

      if(daDates[i].isNotEmpty){
        double amount = double.tryParse(i < daAmounts.length ? daAmounts[i] : '0') ?? 0.0;

        daDetails.add({
          'Date (Entered)': formattedDate, // Using the clearer date field/parsed TS
          'No Of Days': daDates[i], // This is the actual 'dadate' field
          'Particular': i < daParts.length ? daParts[i] : '',
          'Remark': i < daRemarks.length ? daRemarks[i] : '',
          'Amount': amount.toStringAsFixed(2),
          'Project Name': item.projectName ?? '',
        });
      }
    }

    // --- 3. Travel Details ---
    List<String> txFroms = item.txFrom?.toString().split('||') ?? [];
    List<String> txTos = item.txTo?.toString().split('||') ?? [];
    List<String> txModes = item.txMode?.toString().split('||') ?? [];
    List<String> txAmounts = item.txAmount?.toString().split('||') ?? [];
    List<String> txStartDates = item.txStartDate?.toString().split('||') ?? [];
    List<String> txStartTimes = item.txStartTime?.toString().split('||') ?? [];
    List<String> txEndDates = item.txEndDate?.toString().split('||') ?? [];
    List<String> txEndTimes = item.txEndTime?.toString().split('||') ?? [];
    List<String> txRemarks = item.txRemark?.toString().split('||') ?? [];

    for (int i = 0; i < txFroms.length; i++) {
      if (txFroms[i].toString().isNotEmpty && txFroms[i].toString() != "null") {
        double amount = double.tryParse(i < txAmounts.length ? txAmounts[i] : '0') ?? 0.0;
        travelDetails.add({
          'From': txFroms[i],
          'Start Date': i < txStartDates.length ? txStartDates[i] : '',
          'Start Time': i < txStartTimes.length ? txStartTimes[i] : '',
          'To': i < txTos.length ? txTos[i] : '',
          'End Date': i < txEndDates.length ? txEndDates[i] : '',
          'End Time': i < txEndTimes.length ? txEndTimes[i] : '',
          'Mode': i < txModes.length ? txModes[i] : '',
          'Remark': i < txRemarks.length ? txRemarks[i] : '',
          'Amount': amount.toStringAsFixed(2),
          'Project Name': item.projectName ?? '',
        });
      }
    }

    // --- 4. Conveyance Details ---
    List<String> ceDates = item.ceDate?.toString().split('||') ?? [];
    List<String> ceFroms = item.ceFrom?.toString().split('||') ?? [];
    List<String> ceTos = item.ceTo?.toString().split('||') ?? [];
    List<String> ceModes = item.ceMode?.toString().split('||') ?? [];
    List<String> ceAmounts = item.ceAmount?.toString().split('||') ?? [];
    List<String> ceRemarks = item.ceRemark?.toString().split('||') ?? [];

    for (int i = 0; i < ceDates.length; i++) {
      if(ceDates[i].isNotEmpty){
        double amount = double.tryParse(i < ceAmounts.length ? ceAmounts[i] : '0') ?? 0.0;
        conveyanceDetails.add({
          'Date': ceDates[i],
          'From': i < ceFroms.length ? ceFroms[i] : '',
          'To': i < ceTos.length ? ceTos[i] : '',
          'Mode': i < ceModes.length ? ceModes[i] : '',
          'Remark': i < ceRemarks.length ? ceRemarks[i] : '',
          'Amount': amount.toStringAsFixed(2),
          'Project Name': item.projectName ?? '',
        });
      }
    }
  }

  // --- 5. Calculate Final Totals ---
  double daTotal = daDetails.fold<double>(
      0, (sum, e) => sum + (double.tryParse(e['Amount'] as String) ?? 0.0));
  double travelTotal = travelDetails.fold<double>(
      0, (sum, e) => sum + (double.tryParse(e['Amount'] as String) ?? 0.0));
  double conveyTotal = conveyanceDetails.fold<double>(
      0, (sum, e) => sum + (double.tryParse(e['Amount'] as String) ?? 0.0));

  return ExpenseReportData2(
    taskDetails: taskDetails,
    daDetails: daDetails,
    travelDetails: travelDetails,
    conveyanceDetails: conveyanceDetails,
    totalDaAmount: daTotal,
    totalTravelAmount: travelTotal,
    totalConveyanceAmount: conveyTotal,
  );
}