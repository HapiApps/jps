import 'package:flutter/cupertino.dart';

class DayWorkPlanModel {
  String? companyId;
  String? companyName;

  List<Map<String, dynamic>> selectedCustomers = [];

  String? cusTypeId;
  String? cusTypeName;

  TextEditingController description = TextEditingController();

  String status = "0"; // default Yes
}