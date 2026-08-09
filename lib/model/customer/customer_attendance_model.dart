class CustomerAttendanceModel {
  String? id;
  String? salesmanId;
  String? checkInTs;
  String? checkOutTs;
  String? isCheckedOut;
  String? inLat;
  String? inLng;
  String? outLat;
  String? outLng;
  String? firstname;
  String? role;
  String? inImage;
  String? outImage;
  String? taskTitle;
  String? projectName;
  String? projectId;

  CustomerAttendanceModel({
    this.id,
    this.salesmanId,
    this.checkInTs,
    this.checkOutTs,
    this.isCheckedOut,
    this.inLat,
    this.inLng,
    this.outLat,
    this.outLng,
    this.firstname,
    this.role,
    this.inImage,
    this.outImage,
    this.taskTitle,
    this.projectName,
    this.projectId,
  });

  factory CustomerAttendanceModel.fromJson(Map<String, dynamic> json) => CustomerAttendanceModel(
    id: json["id"],
    salesmanId: json["salesman_id"],
    checkInTs: json["check_in_ts"],
    checkOutTs: json["check_out_ts"],
    isCheckedOut: json["is_checked_out"],
    inLat: json["in_lat"],
    inLng: json["in_lng"],
    outLat: json["out_lat"],
    outLng: json["out_lng"],
    firstname: json["firstname"],
    role: json["role"],
    inImage: json["in_image"],
    outImage: json["out_image"],
    taskTitle: json["task_title"],
    projectName: json["project_name"],
    projectId: json["line_customer_id"],
  );
}
