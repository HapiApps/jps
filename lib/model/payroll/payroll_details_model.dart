class PayrollDetailsModel {
  String? id;
  String? fName;
  String? roleId;
  String? mobileNumber;
  String? salary;
  String? esi;
  String? pf;
  String? bankName;
  String? accNo;
  String? ifscCode;
  String? dutyDays;
  String? pan;
  String? empCd;
  String? doj;
  List<Cat>? cat;

  PayrollDetailsModel({
    required this.id,
    required this.fName,
    required this.roleId,
    required this.mobileNumber,
    required this.salary,
    required this.esi,
    required this.pf,
    required this.bankName,
    required this.accNo,
    required this.ifscCode,
    required this.dutyDays,
    required this.pan,
    required this.empCd,
    required this.doj,
    this.cat,
  });

  factory PayrollDetailsModel.fromJson(Map<String, dynamic> json) => PayrollDetailsModel(
    id: json["id"],
    fName: json["f_name"],
    roleId: json["role"],
    mobileNumber: json["mobile_number"],
    salary: json["salary"],
    esi: json["esi"],
    pf: json["pf"],
    bankName: json["bank_name"],
    accNo: json["acc_no"],
    ifscCode: json["ifsc_code"],
    dutyDays: json["duty_days"],
    doj: json["date_of_joining"],
    empCd: json["emp_cd"],
    pan: json["pan"],
    cat: json["cat"] != null
        ? List<Cat>.from(json["cat"].map((x) => Cat.fromJson(x)))
        : [],
  );
}

class Cat {
  String? category;
  String? categoryType;
  String? categoryAmount;

  Cat({
     this.category,
     this.categoryType,
     this.categoryAmount,
  });

  factory Cat.fromJson(Map<String, dynamic> json) => Cat(
    category: json["category"],
    categoryType: json["categoryType"],
    categoryAmount: json["category_amount"],
  );
}
