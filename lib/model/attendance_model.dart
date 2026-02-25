class AttendanceModel {
  AttendanceModel({
    this.salesmanId,
    this.id,
    this.date,
    this.time,
    this.status,
    this.lngs,
    this.lats,
    this.firstname,
    this.role,
    this.image,
    this.createdTs,
    this.perTime,
    this.perStatus,
    this.perReason,
    this.perCreatedTs,
    this.missingDate,
    this.isWorkDone,   // 🔥 ADD THIS
  });

  String? id;
  String? salesmanId;
  String? date;
  String? image;
  String? time;
  String? status;
  String? lats;
  String? lngs;
  String? firstname;
  String? role;
  String? createdTs;
  String? perTime;
  String? perStatus;
  String? perReason;
  String? perCreatedTs;
  String? missingDate;
  String? isWorkDone;   // 🔥 ADD THIS

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      AttendanceModel(
        id: json["id"],
        missingDate: json["missing_date"],
        salesmanId: json["salesman_id"],
        image: json["image"],
        date: json["date"],
        time: json["time"],
        status: json["status"],
        lats: json["lats"],
        lngs: json["lngs"],
        firstname: json["firstname"],
        role: json["role"],
        createdTs: json["created_ts"],
        perTime: json["per_time"],
        perStatus: json["per_status"],
        perReason: json["per_reason"],
        perCreatedTs: json["per_created_ts"],
        isWorkDone: json["is_work_done"]?.toString(),  // 🔥 ADD THIS
      );

  @override
  String toString() {
    return '''
AttendanceModel(
  salesmanId: $salesmanId,
  date: $date,
  time: $time,
  status: $status,
  isWorkDone: $isWorkDone,
  lats: $lats,
  lngs: $lngs,
  firstname: $firstname,
  role: $role,
  image: $image,
  createdTs: $createdTs,
  perTime: $perTime,
  perStatus: $perStatus,
  perReason: $perReason,
  perCreatedTs: $perCreatedTs
)''';
  }
}