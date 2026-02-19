import 'package:flutter/cupertino.dart';

class AddCustomerModel {
  String id = "";
  String role = "Decision Maker";
  String roleC = "Decision Maker";
  String active = "1";
  String newE = "1";
  TextEditingController name = TextEditingController();
  TextEditingController department = TextEditingController();
  TextEditingController whatsApp = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController designation = TextEditingController();
  bool isMain = false;
  bool isWhatsapp = false;

  AddCustomerModel({
    required this.newE,
    required this.id,
    required this.role,
    required this.roleC,
    required this.name,
    required this.department,
    required this.whatsApp,
    required this.phone,
    required this.email,
    required this.designation,
    this.isMain=false,
    this.isWhatsapp=false,
    this.active="1",
  });

  factory AddCustomerModel.fromJson(Map<String, dynamic> json) => AddCustomerModel(
    newE: json["newE"],
    id: json["id"],
    role: json["role"],
    roleC: json["roleC"],
    designation: TextEditingController(text: json["designation"]),
    name: TextEditingController(text: json["name"]),
    department: TextEditingController(text: json["department"]),
    whatsApp: TextEditingController(text: json["whatsApp"]),
    phone: TextEditingController(text: json["phone"]),
    email: TextEditingController(text: json["email"]),
    isMain: json["isMain"],
    isWhatsapp: json["isWhatsapp"],
    active: json["active"],
  );

}


class AddCmtImg {
  String img = "";

  AddCmtImg({
    required this.img
  });

  factory AddCmtImg.fromJson(Map<String, dynamic> json) => AddCmtImg(
      img: json["img"]
  );

}