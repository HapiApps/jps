class ExpenseModel {
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
  String? txfrom;
  String? txto;
  String? txstartDate;
  String? txstartTime;
  String? txendDate;
  String? txendTime;
  String? txmode;
  String? txamount;
  String? dadate;
  String? daparticular;
  String? daamount;
  String? cedate;
  String? cefrom;
  String? ceto;
  String? cemode;
  String? ceamount;
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
  String? document4;
  String? date;
  String? bus;
  String? auto;
  String? rent;
  String? food;
  String? purchase;
  String? expenseFrom;
  String? expenseTo;
  String? documentNames;

  ExpenseModel({
    this.id,
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
    this.txfrom,
    this.txto,
    this.txstartDate,
    this.txstartTime,
    this.txendDate,
    this.txendTime,
    this.txmode,
    this.txamount,
    this.dadate,
    this.daparticular,
    this.daamount,
    this.cedate,
    this.cefrom,
    this.ceto,
    this.cemode,
    this.ceamount,
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
    this.document4,
    this.date,
    this.bus,
    this.auto,
    this.food,
    this.rent,
    this.purchase,
    this.expenseFrom,
    this.expenseTo,
    this.documentNames,
  });

  factory ExpenseModel.fromJson(Map<String?, dynamic> json) => ExpenseModel(
    id: json["id"],
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
    txfrom: json["txfrom"],
    txto: json["txto"],
    txstartDate: json["txstart_date"],
    txstartTime: json["txstart_time"],
    txendDate: json["txend_date"],
    txendTime: json["txend_time"],
    txmode: json["txmode"],
    txamount: json["txamount"],
    dadate: json["dadate"],
    daparticular: json["daparticular"],
    daamount: json["daamount"],
    cedate: json["cedate"],
    cefrom: json["cefrom"],
    ceto: json["ceto"],
    cemode: json["cemode"],
    ceamount: json["ceamount"],
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
    document4: json["document4"],
    expenseTo: json["expense_to"],
    expenseFrom: json["expense_from"],
    purchase: json["purchase"],
    food: json["food"],
    rent: json["rent"],
    auto: json["auto"],
    bus: json["bus"],
    date: json["date"],
    documentNames: json["document_names"],
  );
  @override
  String toString() {
    return ''' 
ExpenseModel(
  id: $id,
  status: $status,
  firstname: $firstname,
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
  txfrom: $txfrom,
  txto: $txto,
  txstartDate: $txstartDate,
  txstartTime: $txstartTime,
  txendDate: $txendDate,
  txendTime: $txendTime,
  txmode: $txmode,
  txamount: $txamount,
  dadate: $dadate,
  daparticular: $daparticular,
  daamount: $daamount,
  cedate: $cedate,
  cefrom: $cefrom,
  ceto: $ceto,
  cemode: $cemode,
  ceamount: $ceamount,
  da_amt: $daAmt,
  conveyance_amt: $conveyanceAmt,
  travel_amt: $travelAmt,
  project_name: $projectName,
  task_title: $taskTitle
  document1: $document1
  document2: $document2
  document3: $document3
  document4: $document4
  document_names: $documentNames
  date: $date
  bus: $bus
  auto: $auto
  food: $food
  rent: $rent
  purchase: $purchase
  expense_from: $expenseFrom
  expense_to: $expenseTo
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
      'txfrom': txfrom,
      'txto': txto,
      'txstartDate': txstartDate,
      'txstartTime': txstartTime,
      'txendDate': txendDate,
      'txendTime': txendTime,
      'txmode': txmode,
      'txamount': txamount,
      'dadate': dadate,
      'daparticular': daparticular,
      'daamount': daamount,
      'cedate': cedate,
      'cefrom': cefrom,
      'ceto': ceto,
      'cemode': cemode,
      'ceamount': ceamount,
      'da_amt': daAmt,
      'conveyance_amt': conveyanceAmt,
      'travel_amt': travelAmt,
      'project_name': projectName,
      'task_title': taskTitle,
      'document1': document1,
      'document2': document2,
      'document3': document3,
      'document4': document4,
      'document_names': documentNames,
      'date': date,
      'bus': bus,
      'auto': auto,
      'food': food,
      'rent': rent,
      'purchase': purchase,
      'expense_from': expenseFrom,
      'expense_to': expenseTo,
    };
  }

}
