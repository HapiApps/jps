class WorkPlanItem {
  String comId;
  String cusId;
  String value;
  String status;

  WorkPlanItem({
    required this.comId,
    required this.cusId,
    required this.value,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      "com_id": comId,
      "cus_id": cusId,
      "value": value,
      "status": status,
    };
  }
}
class WorkPlanRequest {
  String cosId;
  String uId;
  String date;
  List<WorkPlanItem> plans;

  WorkPlanRequest({
    required this.cosId,
    required this.uId,
    required this.date,
    required this.plans,
  });

  Map<String, dynamic> toJson() {
    return {
      "action": "insert_work_plan",
      "cos_id": cosId,
      "u_id": uId,
      "date": date,
      "plans": plans.map((e) => e.toJson()).toList(),
    };
  }
}