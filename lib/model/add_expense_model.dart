import 'package:flutter/cupertino.dart';
class AddExpTravelModel {
  TextEditingController from = TextEditingController();
  TextEditingController to = TextEditingController();
  TextEditingController stDate=TextEditingController();
  TextEditingController enDate=TextEditingController();
  TextEditingController stTime=TextEditingController();
  TextEditingController enTime=TextEditingController();
  TextEditingController amt=TextEditingController();
  TextEditingController remark=TextEditingController();
  dynamic mode;
  String modeId;
  String modeName;
  AddExpTravelModel({
    required this.from,
    required this.to,
    required this.stDate,
    required this.enDate,
    required this.stTime,
    required this.enTime,
    required this.amt,
    required this.mode,
    required this.modeId,
    required this.modeName,
    required this.remark,
  });

  factory AddExpTravelModel.fromJson(Map<String, dynamic> json) => AddExpTravelModel(
    from: TextEditingController(text: json["from"]),
    to: TextEditingController(text: json["to"]),
    stDate: TextEditingController(text: json["start_date"]),
    stTime: TextEditingController(text: json["start_time"]),
    enDate: TextEditingController(text: json["end_date"]),
    enTime: TextEditingController(text: json["end_time"]),
    mode: json["mode"],
    modeId: json["mode_id"],
    modeName: json["modeName"],
    amt: TextEditingController(text: json["amount"]),
    remark: TextEditingController(text: json["remark"]),
  );

  Map<String, dynamic> toJson() => {
    "from": from.text,
    "to": to.text,
    "start_date": stDate.text,
    "start_time": stTime.text,
    "end_date": enDate.text,
    "end_time": enTime.text,
    "mode": mode,
    "amount": amt.text,
    "remark": remark.text,
    "mode_id": modeId,
    "modeName": modeName
  };
}

class OtherExpModel {
  TextEditingController dateT = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController particular = TextEditingController();
  TextEditingController amount=TextEditingController();
  TextEditingController remark=TextEditingController();
  OtherExpModel({
    required this.dateT,
    required this.date,
    required this.particular,
    required this.amount,
    required this.remark,
  });

  factory OtherExpModel.fromJson(Map<String, dynamic> json) => OtherExpModel(
      dateT: TextEditingController(text: json["dateT"]),
      date: TextEditingController(text: json["date"]),
      particular: TextEditingController(text: json["particular"]),
      amount: TextEditingController(text: json["amount"]),
      remark: TextEditingController(text: json["remark"])
  );
  Map<String, dynamic> toJson() => {
    "dateT": dateT.text,
    "date": date.text,
    "particular": particular.text,
    "amount": amount.text,
    "remark": remark.text,
  };

}

class ConveyanceExpModel {
  TextEditingController from = TextEditingController();
  TextEditingController to = TextEditingController();
  TextEditingController date=TextEditingController();
  TextEditingController amt=TextEditingController();
  TextEditingController stTime=TextEditingController();
  TextEditingController remark=TextEditingController();
  dynamic mode;
  String modeId;
  String modeName;
  ConveyanceExpModel({
    required this.from,
    required this.to,
    required this.date,
    required this.amt,
    required this.mode,
    required this.modeId,
    required this.modeName,
    required this.remark,
  });

  factory ConveyanceExpModel.fromJson(Map<String, dynamic> json) => ConveyanceExpModel(
    from: TextEditingController(text: json["from"]),
    to: TextEditingController(text: json["to"]),
    date: TextEditingController(text: json["date"]),
    mode: json["mode"],
    modeId: json["mode_id"],
    modeName: json["modeName"],
    amt: TextEditingController(text: json["amount"]),
    remark: TextEditingController(text: json["remark"]),
  );

  Map<String, dynamic> toJson() => {
    "date": date.text,
    "from": from.text,
    "to": to.text,
    "mode": mode,
    "amount": amt.text,
    "remark": remark.text,
    "mode_id": modeId,
    "modeName": modeName
  };

}
class SimpleExpModel {
  String doc="";
  TextEditingController docName=TextEditingController();
  SimpleExpModel({
    required this.doc,
    required this.docName,
  });
  factory SimpleExpModel.fromJson(Map<String, dynamic> json) => SimpleExpModel(
      doc: json["doc"],
      docName: TextEditingController(text: json["docName"])
  );
  Map<String, dynamic> toJson() => {
    "doc": doc,
    "docName": docName.text
  };

}
