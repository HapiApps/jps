import 'package:flutter/material.dart';

class AddUserModel {
  TextEditingController inCtr;
  TextEditingController outCtr;
  TextEditingController name;
  TextEditingController id;

  AddUserModel({
    required this.inCtr,
    required this.outCtr,
    required this.name,
    required this.id,
  });

  factory AddUserModel.fromJson(Map<String, dynamic> json) => AddUserModel(
    inCtr: json["inCtr"],
    outCtr: json["outCtr"],
    name: json["name"],
    id: json["id"],
  );
}
