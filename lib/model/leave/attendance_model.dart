class LeaveAttModel {
  String? id;
  String? userId;
  String? userName;
  String? status;
  String? inTime;
  String? inLat;
  String? inLng;
  String? inImage;
  String? outTime;
  String? outLat;
  String? outLng;
  String? outImage;
  String? createdTs;
  String? roleName;
  String? updatedTs;
  String? projectName;
  String? projectId;
  String? permissionStatus;
  String? permissionOutTimes;
  String? permissionInTimes;
  String? permissionLats;
  String? permissionLongs;
  String? reason;
  String? inTimes;
  String? main;
  LeaveAttModel({
    this.projectName,
    this.id,
    this.userId,
    this.userName,
    this.status,
    this.inTime,
    this.inLat,
    this.inLng,
    this.inImage,
    this.outTime,
    this.outLat,
    this.outLng,
    this.outImage,
    this.createdTs,
    this.roleName,
    this.projectId,
    this.permissionStatus,
    this.permissionOutTimes,
    this.permissionInTimes,
    this.permissionLats,
    this.permissionLongs,
    this.reason,
    this.inTimes,
    this.main,
    this.updatedTs
  });
  factory LeaveAttModel.fromJson(Map<String, dynamic> json){
    return LeaveAttModel(
        main: json["is_main"],
        inTimes: json["inTimes"],
        projectName: json["project_name"],
        projectId: json["project_id"],
        id: json["id"],
        userId:json["usr_id"],
        userName:json["usr_name"],
        roleName:json["role_name"],
        status:json["status"],
        inTime:json["in_time"],
        inImage:json["in_image"],
        inLat:json["in_lattitude"],
        inLng:json["in_longitude"],
        outTime:json["out_time"],
        outImage:json["out_image"],
        outLat:json["out_lattitute"],
        outLng:json["out_longitude"],
        createdTs:json["created_ts"],
        permissionInTimes:json["permission_in_times"],
        permissionOutTimes:json["permission_out_times"],
        permissionStatus:json["permission_status"],
        permissionLats:json["permission_lattitudes"],
        permissionLongs:json["permission_longitudes"],
        reason:json["reason"],
        updatedTs:json["updated_ts"]
    );
  }
}