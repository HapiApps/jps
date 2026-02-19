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

  factory LeaveModel.fromJson(Map<String?, dynamic> json) => LeaveModel(
    session: json["session"],
    creater: json["creater"],
    id: json["id"],
    userId: json["user_id"],
    dayType: json["day_type"],
    dayCount: json["day_count"],
    levType: json["lev_type"],
    reason: json["reason"],
    startDate: json["start_date"],
    endDate: json["end_date"],
    status: json["status"],
    level: json["level"],
    createdTs: json["created_ts"],
    createdBy: json["created_by"],
    fName: json["f_name"],
    role: json["role"],
    type: json["type"],
  );
}
