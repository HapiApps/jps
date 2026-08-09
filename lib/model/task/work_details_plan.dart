class WorkPlanModelDetails {
  final String planId;
  final String userId;
  final String name;
  final String role;
  final String date;
  final String createdTime;
  final String updatedTime;
  final List<DailyWorkPlanDetails> plans;

  WorkPlanModelDetails({
    required this.planId,
    required this.userId,
    required this.name,
    required this.role,
    required this.date,
    required this.createdTime,
    required this.updatedTime,
    required this.plans,
  });

  factory WorkPlanModelDetails.fromJson(Map<String, dynamic> json) {
    return WorkPlanModelDetails(
      planId: json["plan_id"]?.toString() ?? "",
      userId: json["user_id"]?.toString() ?? "",
      name: json["name"] ?? "",
      role: json["role"] ?? "",
      date: json["date"] ?? "",
      createdTime: json["created_ts"]?.toString() ?? "",
      updatedTime: json["updated_ts"]?.toString() ?? "",
      plans: (json["plans"] as List? ?? [])
          .map((e) => DailyWorkPlanDetails.fromJson(e))
          .toList(),
    );
  }
}

class DailyWorkPlanDetails {
  final String planId;
  final String detailId;
  final String company;
  final String customer;
  final String desc;
  final String workStatus;
  final String createdTime;
  final String updatedTime;

  DailyWorkPlanDetails({
    required this.planId,
    required this.detailId,
    required this.company,
    required this.customer,
    required this.desc,
    required this.workStatus,
    required this.createdTime,
    required this.updatedTime,
  });

  factory DailyWorkPlanDetails.fromJson(Map<String, dynamic> json) {
    return DailyWorkPlanDetails(
      planId: json["plan_id"]?.toString() ?? "",
      detailId: json["detail_id"]?.toString() ?? "",
      company: json["company"] ?? "",
      customer: json["customer"] ?? "",
      desc: json["desc"] ?? "",
      workStatus: json["workStatus"]?.toString() ?? "",
      createdTime: json["created_ts"]?.toString() ?? "",
      updatedTime: json["updated_ts"]?.toString() ?? "",
    );
  }
}