import 'expense_fetch.dart';

class ExpensesModel {
  String? responseCode;
  String? result;
  String? responseMsg;
  List<Datum> response;

  ExpensesModel({
    this.responseCode,
    this.result,
    this.responseMsg,
    required this.response,
  });

  factory ExpensesModel.fromJson(Map<String, dynamic> json) => ExpensesModel(
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
        response:
            List<Datum>.from(json["Response"].map((x) => Datum.fromJson(x))),
      );
  Map<String, dynamic> toJson() => {
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
        "Response": List<dynamic>.from(response.map((x) => x.toJson())),
      };
}

class Datum {
  String? action;
  String? userAccount;
  String? mobile;
  String? city;
  String? shop;
  String? expenseHead;
  String? paymentType;
  String? particulars;
  String? gst;
  String? amount;
  String? date;
  String? userId;
  String? id;
  List<ExpenseList>? expenseList;

  Datum(
      {this.action,
      this.userAccount,
      this.mobile,
      this.city,
      this.shop,
      this.expenseHead,
      this.paymentType,
      this.particulars,
      this.gst,
      this.amount,
      this.date,
      this.userId,
      this.id,
        this.expenseList,
      });
  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        userId: json["userId"],
        userAccount: json["user_account"],
        mobile: json["mobile"],
        city: json["city"],
        shop: json["shop_name"],
        expenseHead: json["expense_head"],
        paymentType: json["payment_type"],
        particulars: json["particulars"],
        gst: json["gst"],
        amount: json["amount"],
        date: json["date"],
        id: json["id"],
    expenseList: (json['expenseList'] as List<dynamic>?)
        ?.map((e) => ExpenseList.fromJson(e))
        .toList(),
      );
  Map<String, dynamic> toJson() => {
        "userId": userId,
        "user_account": userAccount,
        "mobile": mobile,
        "city": city,
        "shop_name": shop,
        "expense_head": expenseHead,
        "payment_type": paymentType,
        "particulars": particulars,
        "gst": gst,
        "amount": amount,
        "date": date,
        "id": id,
    "expense_list": List<dynamic>.from((expenseList ?? []).map((x) => x.toJson())),
      };
}
