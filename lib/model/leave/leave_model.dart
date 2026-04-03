class LeaveModel {
  String? id;
  String? userId;
  String? dayType;
  String dayCount;
  String? levType;
  String? reason;
  String? startDate;
  String? endDate;
  String? status;
  String? level;
  String? createdTs;
  String? createdBy;
  String? fName;
  String? role;
  String? type;
  String? creater;
  String? session;

  LeaveModel({
    this.creater,
    this.id,
    this.userId,
    this.dayType,
    required this.dayCount,
    this.levType,
    this.reason,
    this.startDate,
    this.endDate,
    this.status,
    this.level,
    this.createdTs,
    this.createdBy,
    this.fName,
    this.role,
    this.type,
    this.session,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) => LeaveModel(
    session: json["session"]?.toString() ?? "",
    creater: json["creater"]?.toString() ?? "",
    id: json["id"]?.toString() ?? "",
    userId: json["user_id"]?.toString() ?? "",
    dayType: json["day_type"]?.toString() ?? "",
    dayCount: json["day_count"]?.toString() ?? "0",   // ✅ IMPORTANT
    levType: json["lev_type"]?.toString() ?? "",
    reason: json["reason"]?.toString() ?? "",
    startDate: json["start_date"]?.toString() ?? "",
    endDate: json["end_date"]?.toString() ?? "",
    status: json["status"]?.toString() ?? "",
    level: json["level"]?.toString() ?? "",
    createdTs: json["created_ts"]?.toString() ?? "",
    createdBy: json["created_by"]?.toString() ?? "",
    fName: json["f_name"]?.toString() ?? "",
    role: json["role"]?.toString() ?? "",
    type: json["type"]?.toString() ?? "",
  );
}