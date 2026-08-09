// To parse this JSON data, do
//
//     final featuresModel = featuresModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/cupertino.dart';

List<FeaturesModel> featuresModelFromJson(String str) => List<FeaturesModel>.from(json.decode(str).map((x) => FeaturesModel.fromJson(x)));

String featuresModelToJson(List<FeaturesModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FeaturesModel {
  String? id;
  String? feature;
  String? active;
  String? componentId;
  String? componentName;
  String? componentActive;
  String? cId;

  FeaturesModel({
    this.id,
    this.feature,
    this.active,
    this.componentId,
    this.componentName,
    this.componentActive,
    this.cId,
  });

  factory FeaturesModel.fromJson(Map<String, dynamic> json) => FeaturesModel(
    id: json["id"],
    feature: json["feature"],
    active: json["active"],
    componentId: json["componentid"],
    componentName: json["componentname"],
    componentActive: json["componentactive"],
    cId: json["cid"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "feature": feature,
    "active": active,
  };
}

class ValuesModel {
  String? categories;
  String? id;
  String? value;
  String? required;
  String? active;
  String? uId;
  TextEditingController? valueCtr;

  ValuesModel({
    this.categories,
    this.id,
    this.value,
    this.required,
    this.active,
    this.uId,
    this.valueCtr,
  });

  factory ValuesModel.fromJson(Map<String, dynamic> json) => ValuesModel(
    categories: json["categories"],
    id: json["id"],
    value: json["value"],
    required: json["required"],
    active: json["active"],
    uId: json["u_id"],
    valueCtr: TextEditingController(text: json["value"]),
  );

  Map<String, dynamic> toJson() => {
    "categories": categories,
    "u_id": uId,
    "id": id,
    "value": value,
    "active": active,
    "required": required,
  };
  @override
  String toString() {
    return {
      'id': id,
      'value': value,
      'required': required,
      'active': active,
    }.toString();
  }
}
