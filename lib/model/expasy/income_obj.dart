import 'dart:convert';

IncomeObj incomeObjFromJson(String str) => IncomeObj.fromJson(json.decode(str));

String incomeObjToJson(IncomeObj data) => json.encode(data.toJson());
class IncomeObj {
  String? responseCode;
  String? result;
  String? responseMsg;
  List<IncomeData> response;

  IncomeObj({
    this.responseCode,
    this.result,
    this.responseMsg,
    required this.response,
  });

  factory IncomeObj.fromJson(Map<String, dynamic> json) => IncomeObj(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
    response:
    List<IncomeData>.from(json["Response"].map((x) => IncomeData.fromJson(x))),
  );
  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
    "Response": List<dynamic>.from(response.map((x) => x.toJson())),
  };
}
class IncomeData {
  String id;
  String income;
  String userId;
  String createdBy;
  String updatedBy;
  String date;
  String reason;

  IncomeData({
    required this.id,
    required this.income,
    required this.userId,
    required this.createdBy,
    required this.updatedBy,
    required this.date,
    required this.reason,
  });

  factory IncomeData.fromJson(Map<String, dynamic> json) => IncomeData(
    id: json["id"],
    income: json["income"],
    userId: json["user_id"],
    createdBy: json["created_by"],
    updatedBy: json["updated_by"],
    date: json["date"],
    reason: json["reason"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "income": income,
    "user_id": userId,
    "created_by": createdBy,
    "updated_by": updatedBy,
    "date": date,
    "reason": reason,
  };
}
