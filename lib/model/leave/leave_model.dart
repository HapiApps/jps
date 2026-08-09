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
  String? updatedBy;
  String? updatedTs;
  String? fName;
  String? role;
  String? type;
  String? creater;
  String? updater;
  String? session;

  // ✅ Leave Summary Fields
  String? leaveAllowed;
  String? leaveTaken;
  String? leaveBalance;

  LeaveModel({
    this.creater,
    this.updater,
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
    this.updatedTs,
    this.createdBy,
    this.createdTs,
    this.updatedBy,
    this.fName,
    this.role,
    this.type,
    this.session,
    this.leaveAllowed,
    this.leaveTaken,
    this.leaveBalance,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) => LeaveModel(
    session: json["session"]?.toString() ?? "",
    creater: json["creater"]?.toString() ?? "",
    updater: json["updater"]?.toString() ?? "",
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
    updatedTs: json["updated_ts"]?.toString() ?? "",
    updatedBy: json["updated_by"]?.toString() ?? "",
    fName: json["f_name"]?.toString() ?? "",
    role: json["role"]?.toString() ?? "",
    type: json["type"]?.toString() ?? "",
    // ✅ Leave Summary Mapping
    leaveAllowed: json["leave_allowed"]?.toString() ?? "0",
    leaveTaken: json["leave_taken"]?.toString() ?? "0",
    leaveBalance: json["leave_balance"]?.toString() ?? "0",
  );
}